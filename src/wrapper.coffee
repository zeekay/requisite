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

  toString: (options) ->
    utils.codegen @ast, options

  clone: ->
    new @constructor @

class Prelude extends Wrapper
  constructor: (options = {}) ->

    @async        = options.async ? true
    @bare         = options.bare ? false
    @prelude      = options.prelude ? (path.join __dirname, 'prelude.js')
    @preludeAsync = options.preludeAsync ? (path.join __dirname, 'prelude-async.js')

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
        unless @bare
          for node in (utils.parse "global.require = require").body
            @body.push node

class Define extends Wrapper
  constructor: (options) ->
    requireAs = options.requireAs
    absolutePath = options.absolutePath ? ''
    async = options.async ? false

    @ast = utils.parse """
      // source: #{absolutePath}
      require.#{if async then 'async' else 'define'}("#{requireAs}", function(module, exports, __dirname, __filename) {
        // replaced with source
      });
      """

    @walk (node) =>
      if node.type == 'BlockStatement'
        @body = node.body

module.exports =
  Wrapper: Wrapper
  Prelude: Prelude
  Define: Define
