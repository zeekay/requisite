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
      # make available as via find
      @modules[mod.requireAs] = mod

      # append all dependencies as well
      seen = {}
      deps = []

      for k,v of mod.dependencies
        seen[k] = true
        deps.push v

      while (dep = deps.shift())?
        if dep.async
          @modules[dep.requireAs] = dep
        else if not dep.excluded
          @append dep.ast
          for k, v of dep.dependencies
            unless seen[k]?
              seen[k] = true
              deps.push v

  find: (requireAs) ->
    key = requireAs.replace /^\//, ''
    @modules[key]

  toString: (options) ->
    console.log codegen @ast, options

module.exports = Wrapper
