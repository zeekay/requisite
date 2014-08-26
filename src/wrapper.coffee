fs     = require 'fs'
path   = require 'path'

Module = require './module'
utils  = require './utils'


class Wrapper
  constructor: ->
    @ast = utils.parse ''
    @body = @ast.body

  walk: (fn) ->
    utils.walk @ast, fn

  toString: (opts) ->
    utils.codegen @ast, opts

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
      @ast = utils.parse '(function (global){}.call(this, this))'
      @walk (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      prelude = utils.parse fs.readFileSync @prelude
      for node in prelude.body
        @body.push node

      if @async
        preludeAsync = utils.parse fs.readFileSync @preludeAsync
        for node in preludeAsync.body
          @body.push node

      if @globalRequire
        for node in (utils.parse "global.require = require").body
          @body.push node


class Define extends Wrapper
  constructor: (opts = {}) ->
    absolutePath = opts.absolutePath ? ''
    requireAs    = opts.requireAs    ? ''
    async        = opts.async        ? false
    strict       = opts.strict       ? false

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

    @ast = utils.parse """
      // source: #{absolutePath}
      require.#{defineType}("#{requireAs}", function(module, exports, __dirname, __filename) {
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
