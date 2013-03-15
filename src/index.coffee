fs        = require 'fs'
path      = require 'path'
uglify    = require 'uglify-js'
resolve   = require './resolve'
compilers = require './compilers'
{log, print} = require './utils'

class Module
  @moduleCache = {}

  constructor: (requiredAs, options = {}) ->
    # relative or unqualified require to module
    @requiredAs = requiredAs

    # absolute path to module requiring us
    @requiredBy     = options.requiredBy

    # paths may be passed in if resolved in advance
    @absolutePath   = options.absolutePath
    @basePath       = options.basePath
    @normalizedPath = options.normalizedPath
    @requireAs      = options.requireAs

    # compiler/extension options
    @compilers    = options.compilers ? compilers
    @extensions   = ('.' + ext for ext of compilers)

    # async, whether or not to include in bundled modules
    @async        = options.async ? false
    @exclude      = options.exclude

    # ast / source generated by @parse()
    @ast          = null
    @source       = null

    # modules that this module depends on
    @dependencies =
      async:        {}
      excluded:     {}
      required:     {}

    # modules that depend on this one
    @dependents = []
    if @requiredBy?
      @dependents.push @requiredBy

    # resolve rest of paths if necessary
    unless options.absolutePath? and options.requireAs?
      @[k] = v for k, v of resolve @requiredAs,
        requiredBy: @requiredBy
        basePath:   @basePath

    # cache ourself
    Module.moduleCache[@requireAs] = @

  # source wrapped in define statement.
  wrap: (ast) ->
    wrapper = uglify.parse """
      // source: #{@absolutePath}
      require.#{if @async then 'async' else 'define'}("#{@requireAs}", function(module, exports, __dirname, __filename) {
        // replaced with source
      });
      """
    wrapper.body[0].body.args[1].body = [ast]
    wrapper

  # compile source using appropriately compiler
  compile: (callback) ->
    extension = (@extension ? path.extname @absolutePath).substr 1
    fs.readFile @absolutePath, 'utf8', (err, source) =>
      unless (compiler = @compilers[extension])? and typeof compiler is 'function'
        throw new Error "No suitable compiler found for #{@absolutePath}"

      # call compiler with a reference to this module
      compiler.call @, {source: source, filename: @normalizedPath}, (err, source, sourceMap) =>
        throw err if err

        @source = source
        @sourceMap = sourceMap

        callback()

  # parse source file into ast
  parse: (callback) ->
    unless @source?
      @compile =>
        @parse callback
      return

    # parse source
    ast = uglify.parse @source,
      filename: @normalizedPath

    # find all requires
    calls = []
    ast.walk new uglify.TreeWalker (node, descend) ->
      calls.push node if node instanceof uglify.AST_Call and \
                         node.start.value == 'require' and \
                         node.expression.end.value == 'require'

    # wrap module now that requires have been found
    @ast = @wrap ast

    # resolve paths to all required modules
    @resolveDependencies calls

    # fully parse all required dependencies
    required = (module for requiredAs, module of @dependencies.required)
    @parseDependencies required, callback

  resolveDependencies: (calls) ->
    while call = calls.shift()
      # module required
      required = call.args[0]

      # async if extra arg exists
      async    = call.args[1]?

      paths = resolve required.value,
        basePath:   @basePath
        extensions: @extensions
        requiredAs: required.value
        requiredBy: @absolutePath

      # normalize require path in AST
      required.value = paths.requireAs

      if @exclude? and @exclude.test paths.requireAs
        @dependencies.excluded[paths.requireAs] = paths
        continue

      if (cached = Module.moduleCache[paths.requireAs])?
        @dependencies.required[paths.requireAs] = cached
        continue

      module = new Module paths.requiredAs, paths
      module.async = async
      module.exclude = @exclude

      if module.async
        # async dependency
        @dependencies.async[module.requireAs] = module
      else
        @dependencies.required[module.requireAs] = module

  parseDependencies: (unresolved, callback) ->
    if unresolved.length == 0
      return callback null

    module = unresolved.shift()
    module.parse (err) =>
      throw err if err

      @parseDependencies unresolved, callback

  toString: (options) ->
    print @ast, options

class Wrapper
  constructor: (options = {}) ->
    @prelude  = options.prelude ? (path.join __dirname, 'prelude.js')
    @bare     = options.bare    ? false
    @ast      = uglify.parse ''
    @lastNode = @ast

    unless @bare
      @ast = uglify.parse '(function (global){}.call(this))',
        toplevel: @ast

      @ast.walk new uglify.TreeWalker (node, descend) =>
        if node instanceof uglify.AST_Function
          @lastNode = node

    if typeof @prelude == 'string' and @prelude != ''
      prelude = uglify.parse (fs.readFileSync @prelude, 'utf8'),
        filename: 'requisite/prelude.js'

      @append prelude

  # can be passed an ast or module instance
  append: (module) ->
    if (isModule = module instanceof Module)
      ast = module.ast
    else
      ast = module

    @lastNode.body = @lastNode.body.concat ast.body
    @lastNode.end  = ast.end

    if isModule
      # append all dependencies as well
      seen = {}
      dependencies = (v for k, v of module.dependencies.required)
      while (dependency = dependencies.shift())?
        @append dependency.ast
        for k, v of dependency.dependencies.required
          unless seen[v]?
            dependencies.push seen[k] = v

  toString: (options) ->
    print @ast, options

module.exports =
  Module:  Module

  Wrapper: Wrapper

  bundle: (entry, options, callback) ->
    @parse entry, options, (err, wrapper) ->
      throw err if err

      callback null, wrapper.toString options

  parse: (entry, options, callback) ->
    if typeof options == 'function'
      [callback, options] = [options, {}]

    wrapper = new Wrapper
      prelude: options.prelude
      bare:    options.bare

    main = new Module entry,
      exclude: options.exclude

    main.parse ->
      # append main module
      wrapper.append main

      # append any included modules
      if (unresolved = options.include)?
        iterate = ->
          unless unresolved.length == 0
            module = new Module unresolved.pop(),
              requiredBy: main.absolutePath
              basePath: main.basePath
            module.parse ->
              wrapper.append module
              iterate()
          else
            callback null, wrapper
        iterate()
