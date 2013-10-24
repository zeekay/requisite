fs    = require 'fs'
path  = require 'path'

compilers = require './compilers'
resolve   = require './resolve'
utils     = require './utils'
wrapper   = require './wrapper'

class Module
  @moduleCache = {}

  constructor: (requiredAs, options = {}) ->
    # relative or unqualified require to module
    @requiredAs   = requiredAs

    # absolute path to module requiring us
    @requiredBy   = options.requiredBy

    # compiler/extension options
    @compilers    = options.compilers ? compilers
    @extensions   = ('.' + ext for ext of compilers)

    # async, whether or not to include in bundled modules
    @async        = options.async ? false
    @exclude      = options.exclude
    @include      = options.include

    # what to export module as
    @export       = options.export ? false

    # ast / source generated by @parse()
    @ast          = null
    @source       = null

    # Optionally passed in if resolved in advance
    @absolutePath   = options.absolutePath
    @basePath       = options.basePath
    @normalizedPath = options.normalizedPath
    @requireAs      = options.requireAs

    unless @absolutePath? and @normalizedPath?
      @resolve()

    # modules that this module depends on
    @dependencies = {}

    # modules that depend on this one
    @dependents   = {}

  # resolve paths
  resolve: ->
    @[k] = v for k, v of resolve @requiredAs,
      requireAs:  @requireAs
      requiredBy: @requiredBy
      basePath:   @basePath

  # compile source using appropriately compiler
  compile: (callback) ->
    fs.stat @absolutePath, (err, stat) =>
      throw err if err?

      if @mtime? and @mtime <= stat.mtime
        return callback()

      @mtime = stat.mtime
      extension = (path.extname @absolutePath).substr 1

      fs.readFile @absolutePath, 'utf8', (err, source) =>
        unless (compiler = @compilers[extension])?
          throw new Error "No suitable compiler found for #{@absolutePath}"

        # call compiler with a reference to this module
        compiler.call @, {source: source, filename: @normalizedPath}, (err, source, sourceMap) =>
          throw err if err?

          @source = source
          @sourceMap = sourceMap

          callback()

  # parse source file into ast
  parse: (options, callback) ->
    if typeof options == 'function'
      [callback, options] = [options, {}]

    if options.deep
      Module.moduleCache = {}

    @compile =>
      # parse source to AST
      @ast = utils.parse @source, filename: @normalizedPath

      # transform AST to use root-relative paths
      try
        dependencies = @transform()
      catch err
        return callback err

      # cache ourself
      Module.moduleCache[@requireAs] = @

      @dependencies = {}

      # force include dependencies if requested
      if @include?
        for k, v of @include
          mod = resolve v,
            basePath:   @basePath
            extensions: @extensions
            requiredAs: k

          mod.requireAs = k

          # add to list of dependencies
          dependencies.unshift mod

      # parse dependencies into fully-fledged modules
      @traverse dependencies, options, callback

  # transform require expressions in AST to use root-relative paths
  transform: ->
    dependencies = []
    @walkAst (node) =>
      if node.type == 'CallExpression' and node.callee.name == 'require'
        [required, callback] = node.arguments

        if required.type == 'Literal' and typeof required.value is 'string'
          mod = resolve required.value,
            basePath:   @basePath
            extensions: @extensions
            requiredAs: required.value
            requiredBy: @absolutePath

          # transform node
          required.value = mod.requireAs

          # is async?
          mod.async = callback?

          # add to list of dependencies
          dependencies.push mod
        return true
    dependencies

  # traverse dependencies recursively, parsing them as well
  traverse: (dependencies, options, callback) ->
    if typeof options == 'function'
      [callback, options] = [options, {}]

    dependencies ?= @dependencies.slice 0
    options      ?= {}
    callback     ?= ->

    return callback() if dependencies.length == 0

    dep = dependencies.shift()

    # if excluced module, just continue
    if @exclude? and @exclude.test dep.requireAs
      return @traverse dependencies, options, callback

    # already seen this module
    if @dependencies[dep.requireAs]?
      return @traverse dependencies, options, callback

    # use cached module if previously parsed by someone else
    if (cached = @find dep.requireAs)?
      @dependencies[cached.requireAs] = cached
      cached.dependents[@requireAs] = @
      return @traverse dependencies, options, callback

    # create module and parse it baby
    mod = new Module dep.requiredAs, dep
    mod.exclude = @exclude
    mod.dependents[@requireAs] = @
    @dependencies[mod.requireAs] = mod

    # parse dependency as well
    mod.parse =>
      # continue parsing deps
      @traverse dependencies, options, callback

  append: (mod) ->
    for node in mod.ast?.body ? []
      @ast.body.push node
    return

  find: (query) ->
    switch typeof query
      when 'function'
        for k,v of Module.moduleCache
          return v if query v
      when 'string'
        requireAs = query.replace /^\//, ''
        Module.moduleCache[requireAs]
      else
        throw new Error 'Invalid query for find'

  wrapped: ->
    define = new wrapper.Define
      absolutePath: @absolutePath
      async: @async
      requireAs: @requireAs
      mtime: @mtime

    for node in @ast.body
      define.body.push node
    define.ast

  # walk nodes in ast calling fn
  walkAst: (fn) ->
    utils.walk @ast, fn

  # walk module cache calling fn
  walkCache: (fn) ->
    for mod in Module.moduleCache
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
      if mod.ast?
        for node in mod.wrapped().body
          toplevel.body.push node
      else
        console.error 'warning: ast missing', mod.requireAs

    for node in @wrapped().body
      toplevel.body.push node

    if @export
      for node in (utils.parse "global.#{@export} = require('#{@requireAs}');").body
        toplevel.body.push node

    toplevel.ast

  toString: (options) ->
    utils.codegen @bundle(), options

module.exports = Module
