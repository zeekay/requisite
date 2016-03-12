fs     = require 'fs'
path   = require 'path'

Module  = require './module'
codegen = require './codegen'
parse   = require './parse'
walk    = require './walk'


class Wrapper
  constructor: ->
    @ast = parse ''
    @body = @ast.body

  walk: (fn) ->
    walk @ast, fn

  toString: (opts) ->
    codegen @ast, opts

  clone: ->
    new @constructor @


class Prelude extends Wrapper
  constructor: (opts = {}) ->
    @async         = opts.async         ? true
    @bare          = opts.bare          ? false
    @globalRequire = opts.globalRequire ? false
    @prelude       = opts.prelude       ? (path.join __dirname, 'prelude.js')
    @preludeAsync  = opts.preludeAsync  ? (path.join __dirname, 'prelude-async.js')

    super()

    unless @bare
      @ast = parse '(function (global){}.call(this, this))'
      @walk (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      prelude = parse fs.readFileSync @prelude
      for node in prelude.body
        @body.push node

      if @async
        preludeAsync = parse fs.readFileSync @preludeAsync
        for node in preludeAsync.body
          @body.push node

      if @globalRequire
        for node in (parse "global.require = require").body
          @body.push node


class Define extends Wrapper
  constructor: (opts = {}) ->
    absolutePath   = opts.absolutePath ? ''
    normalizedPath = opts.normalizedPath
    relativePath   = opts.relativePath
    requireAs      = opts.requireAs    ? ''
    async          = opts.async        ? false
    strict         = opts.strict       ? false

    if async
      defineType = 'async'
      requireAs  = path.join opts.urlRoot, requireAs
    else
      defineType = 'define'

    if strict
      useStrict = "'use strict';"
    else
      useStrict = ''

    # deal with escaping weirdness
    requireAs = requireAs.replace /\\/g, '\\\\'

    sourcePath = relativePath ? normalizedPath ? absolutePath

    @ast = parse """
      // source: #{sourcePath}
      require.#{defineType}("#{requireAs}", function(module, exports, __dirname, __filename, process) {
        #{useStrict}
      });
      """

    @walk (node) =>
      if node.type == 'BlockStatement'
        @body = node.body


module.exports =
  Define:  Define
  Prelude: Prelude
  Wrapper: Wrapper
