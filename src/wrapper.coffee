acorn = require 'acorn'
fs    = require 'fs'
path  = require 'path'

Module          = require './module'
{codegen, walk} = require './utils'

class Wrapper
  constructor: (options = {}) ->
    @prelude  = options.prelude ? (path.join __dirname, 'prelude.js')
    @bare     = options.bare ? false
    @ast      = acorn.parse ''
    @body     = @ast.body

    unless @bare
      @ast = acorn.parse '(function (global){}.call(this))'
      walk @ast, (node) =>
        if node.type == 'BlockStatement'
          @body = node.body

    if @prelude
      @append acorn.parse fs.readFileSync @prelude

  # can be passed an ast or module instance
  append: (mod) ->
    if (isModule = mod instanceof Module)
      ast = mod.ast
    else
      ast = mod

    if ast.body?
      for node in ast.body
        @body.push node

    if isModule
      # append all dependencies as well
      seen = {}
      deps = []

      for k,v of mod.dependencies
        seen[k] = true
        deps.push v

      while (dep = deps.shift())?
        unless dep.async or dep.excluded
          @append dep.ast
          for k, v of dep.dependencies
            unless seen[k]?
              seen[k] = true
              deps.push v

  toString: (options) ->
    codegen @ast, options

module.exports = Wrapper
