fs = require 'fs'
path = require 'path'
resolve = require 'resolve'
uglify = require 'uglify-js'

log = ->
  console.log.apply console, arguments

print = (ast, options = {}) ->
  unless options.minify
    options.beautify     ?= true
    options.comments     ?= -> true
    options.indent_level ?= 2
    options.semicolons   ?= false

  if options.sourceMap
    sourceMap = uglify.SourceMap
      file: options.normalizedPath
      orig: options.sourceMap
    options.source_map = sourceMap

  # if options.minify
  #   # compress
  #   compressor = uglify.Compressor()
  #   ast = ast.transform compressor
  #   ast.figure_out_scope()

  #   # mangle
  #   ast.compute_char_frequency()
  #   ast.mangle_names()

  delete options.minify

  stream = uglify.OutputStream options
  ast.print stream

  if options.sourceMap
    code: stream.toString()
    sourceMap: sourceMap.toString()
  else
    stream.toString()

class Module
  # global cache of modules
  @moduleCache = {}
  @compilers     = require './compilers'
  @extensions    = ['.js'].concat ('.' + ext for ext of @compilers)

  constructor: (requiredAs, options = {}) ->
    if (cached = Module.moduleCache[@requiredAs])?
      cached.requiredFrom.push options.requiredFrom
      return cached

    # how module was initially required
    @requiredAs = requiredAs

    # async, whether or not to include in bundled modules
    @async = options.async ? false

    # array of regexes to use to remove
    if options.exclude?
      @exclude = options.exclude

    # extension available after resolution
    @extension = null

    # source available after being compiled
    @source = null

    # available after being parsed
    @ast = null
    @dependencies =
      async:    {}
      excluded: {}
      required: {}

    # list of modules required from
    @requiredFrom = []
    if (@initialRequirer = options.requiredFrom)?
      @requiredFrom.push @initialRequirer

    # dir to resolve from
    @resolveFrom = options.resolveFrom
    unless @resolveFrom?
      if @initialRequirer?
        @resolveFrom = path.dirname @initialRequirer
      else
        @resolveFrom = path.dirname path.resolve @requiredAs
        @requireAs = @requiredAs = './' + path.basename @requiredAs

    # base path for use by dependencies
    @basePath = options.basePath ? @resolveFrom ? path.dirname @absolutePath

    # derive absolute paths if possible
    if options.absolutePath?
      @_derivePaths options.absolutePath

    # allow requireAs to be overridden.
    @requireAs = options.requireAs if options.requireAs?

  # derive all absolute paths and get extension
  _derivePaths: (abspath) ->
    @absolutePath = abspath
    @extension = (path.extname abspath).substr 1
    @normalizedPath = path.join './', (abspath.replace @basePath, '')
    @requireAs = @normalizedPath.replace (new RegExp(".#{@extension}$")), ''
    if @requiredAs.charAt '.'
      @requireAs = './' + @requireAs

  # wrap source in define statement.
  _wrappedSource: ->
    """
    // source: #{@absolutePath}
    require.#{if @async then 'async' else 'define'}("#{@requireAs}", function(module, exports, __dirname, __filename) {
      #{@source}
    });
    """

  # resolve absolute path to module
  resolve: ->
    if @absolutePath? and @requireAs?
      return

    if @async
      return @requireAs = path.join './', (@resolveFrom.replace @basePath, ''), @requiredAs

    log "resolving #{@requiredAs} from #{@resolveFrom} #{if @initialRequirer? then 'required by ' + (@initialRequirer.replace @basePath, '').substr 1 else ''}"

    filename = resolve.sync @requiredAs,
      basedir: @resolveFrom
      extensions: Module.extensions

    @_derivePaths filename
    filename

  # compile source using appropriately compiler
  compile: (callback) ->
    unless @absolutePath?
      @resolve()

    fs.readFile @absolutePath, 'utf8', (err, source) =>
      unless (compiler = Module.compilers[@extension])? and typeof compiler is 'function'
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

    @ast = uglify.parse @_wrappedSource(),
      filename: @normalizedPath

    nodes = []

    @ast.walk new uglify.TreeWalker (node, descend) ->
      # detect valid require statement for transform
      if (node instanceof uglify.AST_Call) \
          # node must start with require
          and node.start.value == 'require' \
          # node may not end with define, i.e., require.define
          and (not node.expression?.end?.value != 'define') \
          and node.args[0].value?
        nodes.push node
      return

    while node = nodes.shift()
      required = node.args[0]
      extraArg = node.args[1]

      unless extraArg?
        async = false
      else if extraArg.start.value = 'function'
        async = true

      if required.value == @requiredAs
        continue

      # create new module for new dependency
      module = new Module required.value,
        async: async
        basePath: @basePath
        exclude: @exclude
        requiredFrom: @absolutePath
        resolveFrom: path.dirname @absolutePath

      # resolve path to module so we can get a normalized path
      try
        module.resolve()
      catch err
        if /Cannot find module/.test err.message
          # try and lookup module in moduleCache
          unless (module = Module.moduleCache[required.value])?
            throw err

      # normalize require path in AST
      required.value = module.requireAs

      if @exclude? and @exclude.test module.requireAs
        # excluded dependency
        @dependencies.excluded[module.requireAs] = module

      else if module.async
        # async dependency
        @dependencies.async[module.requireAs] = module

      else
        # normal dependency
        if (cached = Module.moduleCache[module.requireAs])?
          @dependencies.required[module.requireAs] = cached
        else
          @dependencies.required[module.requireAs] = module
          Module.moduleCache[module.requireAs]   = module

    Module.moduleCache[@requireAs] = @
    callback null, @ast
    return

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

  append: (ast) ->
    @lastNode.body = @lastNode.body.concat ast.body
    @lastNode.end  = ast.end

  toString: (options) ->
    print @ast, options

module.exports =
  Module:  Module

  Wrapper: Wrapper

  print:   print

  bundle: (entry, options, callback) ->
    @walk entry, options, (err, wrapper) ->
      wrapper.toString options

  walk: (entry, options, callback) ->
    if typeof options == 'function'
      [callback, options] = [options, {}]

    async        = {}
    required     = {}
    excluded     = {}
    unresolved   = [new Module entry, {exclude: options.exclude}]

    if options.include?
      for extra in options.include
        unresolved.push new Module extra

    iterate = ->
      module = unresolved.shift()
      module.parse (err) ->
        throw err if err?

        required[module.requireAs] = module

        for k, v of module.dependencies.required
          unless required[k]?
            required[k] = v
            unresolved.push v

        for k, v of module.dependencies.async
          async[k] = v

        for k, v of module.dependencies.excluded
          excluded[k] = v

        return iterate() unless unresolved.length == 0

        wrapper = new Wrapper
          bare: options.bare
          prelude: options.prelude

        for k, v of required
          wrapper.append v.ast

        callback null, wrapper, required, async, excluded

    iterate()
