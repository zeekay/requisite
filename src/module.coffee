fs        = require 'fs'
path      = require 'path'
compilers = require './compilers'
resolver  = require './resolver'
utils     = require './utils'
wrapper   = require './wrapper'


class Module
  constructor: (requiredAs, opts = {}) ->
    # cache for modules
    @moduleCache  = opts.moduleCache ? {}

    # relative or unqualified require to module
    @requiredAs   = requiredAs

    # absolute path to module requiring us
    @requiredBy   = opts.requiredBy

    @resolver     = opts.resolver ? resolver()

    # compiler/extension opts
    @compilers    = opts.compilers ? compilers
    @extensions   = ('.' + ext for ext of compilers)

    # async, whether or not to include in bundled modules
    @async        = opts.async ? false
    @exclude      = opts.exclude
    @include      = opts.include
    @paths        = opts.paths

    # whether to wrap module
    @bare         = opts.bare
    @strict       = opts.strict

    # export or require module
    @export       = opts.export ? false
    @require      = opts.require ? true

    # optional urlRoot to append to async requires
    @urlRoot      = opts.urlRoot ? ''

    # ast / source generated by @parse()
    @ast          = null
    @source       = null

    # Optionally passed in if resolved in advance
    @absolutePath   = opts.absolutePath
    @basePath       = opts.basePath
    @normalizedPath = opts.normalizedPath
    @requireAs      = opts.requireAs

    unless @absolutePath? and @normalizedPath?
      @resolve()

    # modules that this module depends on
    @dependencies = {}

    # modules that depend on this one
    @dependents   = {}

  # resolve paths
  resolve: ->
    @[k] = v for k, v of @resolver @requiredAs,
      paths:      @paths
      requireAs:  @requireAs
      requiredBy: @requiredBy
      basePath:   @basePath

  # compile source using appropriately compiler
  compile: (callback) ->
    fs.stat @absolutePath, (err, stat) =>
      return callback new Error "Unable to find module '#{@absolutePath}'" if err?

      if @mtime? and stat.mtime < @mtime
        return callback()

      @mtime = stat.mtime
      extension = (path.extname @absolutePath).substr 1

      fs.readFile @absolutePath, 'utf8', (err, source) =>
        unless (compiler = @compilers[extension])?
          throw new Error "No suitable compiler found for #{@absolutePath}"

        # call compiler with a reference to this module
        compiler.call @, {source: source, filename: @normalizedPath}, (err, source, sourceMap) =>
          return callback err if err?

          @source = source
          @sourceMap = sourceMap

          callback()

  # parse source file into ast
  parse: (opts, callback) ->
    if typeof opts == 'function'
      [callback, opts] = [opts, {}]

    if opts.deep
      for k,v of @moduleCache
        delete @moduleCache[k]

    @compile (err) =>
      return callback err if err?

      # parse source to AST
      @ast = utils.parse @source, filename: @normalizedPath

      # transform AST to use root-relative paths
      try
        dependencies = @transform()
      catch err
        return callback err

      # cache ourself
      @moduleCache[@requireAs] = @

      @dependencies = {}

      # force include dependencies if requested
      if @include?
        for k, v of @include
          mod = @resolver v,
            paths:      @paths
            basePath:   @basePath
            extensions: @extensions
            requiredAs: k

          mod.requireAs  = k
          mod.basePath   = @basePath
          mod.requiredBy = @absolutePath

          # add to list of dependencies
          dependencies.unshift mod

      # parse dependencies into fully-fledged modules
      @traverse dependencies, opts, callback

  # transform require expressions in AST to use root-relative paths
  transform: ->
    dependencies = []
    @walkAst (node) =>
      if node.type == 'CallExpression' and node.callee.name == 'require'
        [required, callback] = node.arguments

        if required.type == 'Literal' and typeof required.value is 'string'
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
    dependencies

  # traverse dependencies recursively, parsing them as well
  traverse: (dependencies, opts, callback) ->
    if typeof opts == 'function'
      [callback, opts] = [opts, {}]

    dependencies ?= @dependencies.slice 0
    opts         ?= {}
    callback     ?= ->

    return callback() if dependencies.length == 0

    dep = dependencies.shift()

    # if excluced module, just continue
    if @exclude? and @exclude.test dep.requireAs
      console.log 'excluded', dep.requireAs
      return @traverse dependencies, opts, callback

    # already seen this module
    if @dependencies[dep.requireAs]?
      return @traverse dependencies, opts, callback

    # use cached module if previously parsed by someone else
    if (cached = @find dep.requireAs)?
      @dependencies[cached.requireAs] = cached
      cached.dependents[@requireAs] = @
      return @traverse dependencies, opts, callback

    dep.moduleCache = @moduleCache
    dep.resolver    = @resolver
    dep.urlRoot     = @urlRoot
    dep.strict      = @strict

    # create module and parse it baby
    mod = new Module dep.requiredAs, dep
    mod.exclude = @exclude
    mod.dependents[@requireAs] = @
    @dependencies[mod.requireAs] = mod

    # parse dependency as well
    mod.parse (err) =>
      return callback err if err?

      # continue parsing deps
      @traverse dependencies, opts, callback

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
        requireAs = @requireAs if requireAs == ''
        @moduleCache[requireAs]
      else
        throw new Error 'Invalid query for find'

  wrapped: ->
    return @ast if @bare

    define = new wrapper.Define
      strict:       @strict
      absolutePath: @absolutePath
      async:        @async
      urlRoot:      @urlRoot
      requireAs:    @requireAs
      mtime:        @mtime

    for node in @ast.body
      define.body.push node
    define.ast

  # walk nodes in ast calling fn
  walkAst: (fn) ->
    utils.walk @ast, fn

  # walk module cache calling fn
  walkCache: (fn) ->
    for mod in @moduleCache
      fn mod

  # walk dependencies calling fn
  walkDependencies: (mod, fn) ->
    if typeof mod == 'function'
      [fn, mod] = [mod, @]

    # maintain a reference of modules seen to prevent infinite recursion (and for efficiency)
    seen = {}

    walk = (mod, fn) ->
      return if seen[mod.requireAs]

      seen[mod.requireAs] = true

      for k,v of mod.dependencies
        continue if seen[k]

        unless (fn v) == false
          walk v, fn

    walk mod, fn

  bundle: ->
    toplevel = (@toplevel ? new wrapper.Wrapper()).clone()

    @walkDependencies (mod) ->
      if mod.ast? and not mod.async
        for node in mod.wrapped().body
          toplevel.body.push node

    for node in @wrapped().body
      toplevel.body.push node

    unless @async or @bare
      if @export
        for node in (utils.parse "global.#{@export} = require('#{@requireAs}');").body
          toplevel.body.push node

      else if @require
        for node in (utils.parse "require('#{@requireAs}');").body
          toplevel.body.push node

    toplevel.ast

  toString: (opts) ->
    utils.codegen @bundle(), opts

module.exports = Module
