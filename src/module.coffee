fs          = require 'fs'
path        = require 'path'
escapeRegex = require 'lodash.escaperegexp'

Promise = require 'broken'

codegen        = require './codegen'
compilers      = require './compilers'
parse          = require './parse'
resolver       = require './resolver'
walk           = require './walk'
wrapper        = require './wrapper'

{isFunction, isString} = require './utils'

class Module
  constructor: (requiredAs, opts = {}) ->
    # cache for modules
    @moduleCache = opts.moduleCache ? {}

    # relative or unqualified require to module
    @requiredAs = requiredAs

    # absolute path to module requiring us
    @requiredBy = opts.requiredBy

    @resolver = opts.resolver ? resolver()

    # compiler/extension opts
    @compilers = compilers
    for k,v of opts.compilers
      @compilers[k] = v

    @extensions = ('.' + ext for ext of @compilers)

    # async, whether or not to include in bundled modules
    @async = opts.async ? false

    # excluded modules, forcefully included modules
    @exclude = opts.exclude
    @include = opts.include

    # modules only to be included from provided path
    if opts.resolveAs?
      @include ?= {}
      exclude   = []

      for k, v of opts.resolveAs
        @include[k] = v
        mod = escapeRegex k
        exclude.push "^#{mod}$|^#{mod}\/"

      # Recreate exclude regex to ensure nothing matching module name can be resolved
      exclude = exclude.join '|'
      if @exclude?
        exclude = @exclude + '|' + exclude

      @exclude = new RegExp exclude

    # paths to search for modules
    @paths = opts.paths

    # whether to wrap module
    @bare   = opts.bare
    @strict = opts.strict

    # Should module be exported or required automatically
    @exported = opts.exported ? false
    @required = opts.required ? true

    # optional urlRoot to append to async requires
    @urlRoot = opts.urlRoot ? ''

    # ast / source generated by @parse()
    @ast    = null
    @source = null

    # Optionally passed in if resolved in advance
    @absolutePath   = opts.absolutePath
    @basePath       = opts.basePath
    @normalizedPath = opts.normalizedPath
    @relativePath   = opts.relativePath
    @requireAs      = opts.requireAs

    unless @absolutePath? and @normalizedPath?
      @resolve()

    # modules that this module depends on
    @dependencies = {}

    # modules that depend on this one
    @dependents = {}

    # whether to generate sourceMap
    @enableSourceMap = opts.sourceMap
    @sourceMapRoot   = opts.sourceMapRoot

  findMod: (requireAs, modulePath) ->
    mod = @resolver modulePath,
      paths:      @paths
      basePath:   @basePath
      extensions: @extensions
      requiredAs: requireAs

    mod.requireAs  = requireAs
    mod.basePath   = @basePath
    mod.requiredBy = @absolutePath

    mod

  # resolve paths
  resolve: ->
    @[k] = v for k, v of @resolver @requiredAs,
      basePath:   @basePath
      paths:      @paths
      requiredBy: @requiredBy

  # compile source using appropriately compiler
  compile: (cb) ->
    p = new Promise (resolve, reject) =>
      fs.stat @absolutePath, (err, stat) =>
        return reject new Error "Unable to find module '#{@absolutePath}': #{err}" if err?

        if @mtime? and stat.mtime < @mtime
          return resolve()

        @mtime = stat.mtime
        extension = (path.extname @absolutePath).substr 1

        fs.readFile @absolutePath, 'utf8', (err, source) =>
          unless (compiler = @compilers[extension])?
            throw new Error "No suitable compiler found for #{@absolutePath}"

          opts =
            source:        source
            filename:      @normalizedPath
            absolutePath:  @absolutePath
            sourceMap:     @enableSourceMap
            sourceMapRoot: @sourceMapRoot

          # call compiler with a reference to this module
          compiler.call @,  opts, (err, source, sourceMap) =>
            return reject err if err?

            @source    = source
            @sourceMap = sourceMap

            resolve()
    p.callback cb
    p

  # parse source file into ast
  parse: (opts, cb) ->
    if isFunction opts
      [cb, opts] = [opts, {}]

    if opts.deep
      for k,v of @moduleCache
        delete @moduleCache[k]

    p = new Promise (resolve, reject) =>
      @compile (err) =>
        return reject err if err?

        # parse source to AST
        @ast = parse @source,
          filename:  @normalizedPath
          sourceMap: @sourceMap

        # transform AST to use root-relative paths
        try
          dependencies = @transform()
        catch err
          return reject err

        # cache ourself
        @moduleCache[@requireAs] = @

        @dependencies = {}

        # force include dependencies if requested
        if @include?
          for k,v of @include
            mod = @findMod k, v
            dependencies.unshift mod

        # parse dependencies into fully-fledged modules
        @traverse dependencies, opts, (err) =>
          reject err if err?
          resolve @

    p.callback cb
    p

  # transform require expressions in AST to use root-relative paths
  transform: ->
    dependencies = []
    try
      @walkAst (node) =>
        if node.type == 'CallExpression' and node.callee.name == 'require'
          [required, callback] = node.arguments

          if required.type == 'Literal' and isString required.value
            # skip excluded modules
            if @exclude?.test required.value
              return true

            mod = @resolver required.value,
              basePath:   @basePath
              extensions: @extensions
              requiredAs: required.value
              requiredBy: @absolutePath

            # is async?
            if mod.async = callback?
              required.value = path.join @urlRoot, mod.requireAs

            else
              # transform node
              required.value = mod.requireAs

            # add to list of dependencies
            dependencies.push mod
          return true
    catch err
      # Warn if unable to resolve all dependencies, most likely this is a
      # previously bundled js file...
      console.warn err.toString().replace /^Error:/, 'Warning:'
    dependencies

  # traverse dependencies recursively, parsing them as well
  traverse: (dependencies, opts, cb) ->
    if isFunction opts
      [cb, opts] = [opts, {}]

    dependencies ?= @dependencies.slice 0
    opts         ?= {}
    cb           ?= ->

    p = new Promise (resolve, reject) =>
      return resolve() if dependencies.length == 0

      dep = dependencies.shift()

      # TODO: figure out if this is needed
      # if @exclude?.test dep.requireAs
      #   # if excluced module, just continue
      #   return @traverse dependencies, opts, callback

      # already seen this module
      if @dependencies[dep.requireAs]?
        return @traverse dependencies, opts, cb

      # use cached module if previously parsed by someone else
      if (cached = @find dep.requireAs)?
        unless cached.external
          @dependencies[cached.requireAs] = cached
          cached.dependents[@requireAs] = @
        return @traverse dependencies, opts, cb

      dep.moduleCache = @moduleCache
      dep.resolver    = @resolver
      dep.urlRoot     = @urlRoot
      dep.strict      = @strict

      # create module and parse it
      mod = new Module dep.requiredAs, dep
      mod.exclude = @exclude
      mod.dependents[@requireAs] = @
      @dependencies[mod.requireAs] = mod

      # parse dependency as well
      mod.parse (err) =>
        return reject err if err?

        # continue parsing deps
        @traverse dependencies, opts, cb

    p.callback cb
    p

  append: (mod) ->
    for node in mod.ast?.body ? []
      @ast.body.push node
    return

  find: (query) ->
    switch typeof query
      when 'function'
        for k,v of @moduleCache
          return v if query v
      when 'string'
        # strip leading dot slash / slash
        requireAs = query.replace /^\.?\/+/, ''

        # return top level module if query is empty
        return @moduleCache[@requireAs] if requireAs == ''

        # try to find as relative module
        relative = @moduleCache['./' + requireAs]
        return relative if relative?

        # try to find node_module
        nodeModule = @moduleCache[requireAs]
        return nodeModule if nodeModule?

        # this behavior is probably bad?
        # throw new Error "Unable to find module #{requireAs}"
      else
        throw new Error 'Invalid query for find'

  wrapped: ->
    return @ast if @bare

    define = new wrapper.Define
      absolutePath:   @absolutePath
      async:          @async
      mtime:          @mtime
      normalizedPath: @normalizedPath
      relativePath:   @relativePath
      requireAs:      @requireAs
      strict:         @strict
      urlRoot:        @urlRoot

    for node in @ast.body
      define.body.push node

    define.ast

  # walk nodes in ast calling fn
  walkAst: (fn) ->
    walk @ast, fn

  # walk module cache calling fn
  walkCache: (fn) ->
    for mod in @moduleCache
      fn mod

  # walk dependencies calling fn
  walkDependencies: (mod, fn) ->
    if isFunction mod
      [fn, mod] = [mod, @]

    # maintain a reference of modules seen to prevent infinite recursion (and for efficiency)
    seen = {}

    walkDeps = (mod, fn) ->
      return if seen[mod.requireAs]

      seen[mod.requireAs] = true

      for k,v of mod.dependencies
        continue if seen[k]

        unless (fn v) == false
          walkDeps v, fn

    walkDeps mod, fn

  bundle: ->
    toplevel = (@toplevel ? new wrapper.Wrapper()).clone()

    @walkDependencies (mod) ->
      if mod.async or mod.external
        return

      if mod.ast?
        for node in mod.wrapped().body
          toplevel.body.push node

    for node in @wrapped().body
      toplevel.body.push node

    unless @async or @bare
      if @exported
        for node in (parse "global.#{path.basename @requireAs} = require('#{@requireAs}');").body
          toplevel.body.push node

      else if @required
        for node in (parse "require('#{@requireAs}');").body
          toplevel.body.push node

    toplevel.ast

  toString: (opts = {}) ->
    opts.sourceMap     ?= @enableSourceMap
    opts.sourceMapRoot ?= @sourceMapRoot
    codegen @bundle(), opts

module.exports = Module
