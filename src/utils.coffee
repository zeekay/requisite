codegen = (ast, options = {}) ->
  unless options.minify
    options =
      comment: yes
      format:
        indent:
          style: '  '
          base: 0
        quotes: 'auto'
        escapeless: yes
        parentheses: no
        compact: no
        semicolons: no
    require('escodegen').generate ast, options
  else
    minifier = options.minifier ? 'uglify'
    minify = require './minify'
    minify[minifier] ast, options

walk = (node, visitor) ->
  if node? and typeof node == 'object'
    unless visitor node
      for k,v of node
        walk v, visitor

  else if Array.isArray node
    for el in node
      walk el, visitor

clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  inst = new obj.constructor()

  for key of obj
    inst[key] = clone obj[key]

  return inst

module.exports =
  codegen: codegen
  walk: walk
  clone: clone
