acorn = require 'acorn'
fs    = require 'fs'
path  = require 'path'

Module          = require './module'
{codegen, walk} = require './utils'

class Wrapper
  constructor: (options = {}) ->
    @bare     = options.bare ? false
    @prelude  = options.prelude ? (path.join __dirname, 'prelude.js')

    @ast      = acorn.parse ''
    @body     = @ast.body
    @modules  = {}

    unless @bare
      @ast = acorn.parse '(function (global){}.call(this))'
      walk @ast, (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      prelude = acorn.parse fs.readFileSync @prelude
      for node in prelude.body
        @body.push node

  wrap: (module) ->
    for node in module.ast.body
      @body.push node
    module.ast = @ast
    module

  toString: (options) ->
    codegen @ast, options

module.exports = Wrapper
