acorn = require 'acorn'
fs    = require 'fs'
path  = require 'path'

Module          = require './module'
{codegen, walk} = require './utils'

class Wrapper
  constructor: ->
    @ast = acorn.parse ''
    @body = @ast.body

  walk: (fn) ->
    walk @ast, fn

  toString: (options) ->
    codegen @ast, options

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
      @ast = acorn.parse '(function (global){}.call(this, this))'
      @walk (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      prelude = acorn.parse fs.readFileSync @prelude
      for node in prelude.body
        @body.push node
      if @async
        preludeAsync = acorn.parse fs.readFileSync @preludeAsync
        for node in preludeAsync.body
          @body.push node
        unless @bare
          for node in (acorn.parse "global.require = require").body
            @body.push node

class Define extends Wrapper
  constructor: (options) ->
    requireAs = options.requireAs
    absolutePath = options.absolutePath ? ''
    async = options.async ? false

    @ast = acorn.parse """
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
