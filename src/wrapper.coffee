acorn = require 'acorn'
fs    = require 'fs'
path  = require 'path'

Module          = require './module'
{codegen, walk} = require './utils'

class Wrapper
  constructor: (options = {}) ->
    @prelude  = options.prelude ? (path.join __dirname, 'prelude.js')
    @bare     = options.bare    ? false
    @ast      = acorn.parse ''
    @body     = @ast.body

    unless @bare
      @ast = acorn.parse '(function (global){}.call(this))'
      walk @ast, (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      @append (acorn.parse fs.readFileSync @prelude).body[0]

  # can be passed an ast or module instance
  append: (module) ->
    if (isModule = module instanceof Module)
      ast = module.ast
    else
      ast = module

    @body.push ast

    if isModule
      # append all dependencies as well
      seen = {}
      dependencies = (v for k, v of module.dependencies)
      while (dependency = dependencies.shift())?
        unless dependency.async or dependency.excluded
          @append dependency.ast
          for k, v of dependency.dependencies
            unless seen[v]?
              dependencies.push seen[k] = v

  toString: (options) ->
    codegen @ast, options

module.exports = Wrapper
