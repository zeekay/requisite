# clone ast
clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  inst = new obj.constructor()

  for key of obj
    inst[key] = clone obj[key]

  return inst

# generate string from ast, optionally minify
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

# parse source into ast
parse = (source, options) ->
  parser = require options.parser ? 'acorn'
  if options.comment
    parser = require 'esprima'
    ast = parser.parse source,
      raw: true
      tokens: true
      range: true
      comment: true
    ast = require('escodegen').attachComments ast, ast.comments, ast.tokens
  else
    ast = parser.parse source

# walk ast
walk = (node, visitor) ->
  if node? and typeof node == 'object'
    unless visitor node
      for k,v of node
        walk v, visitor

  else if Array.isArray node
    for el in node
      walk el, visitor

# draw simple graph of dependencies
graph = (mod) ->
  # walk dependencies
  seen = {}
  walkdeps = (mod, fn, depth = 0) ->
    if seen[mod.requireAs]
      fn mod, depth, true
      return

    seen[mod.requireAs] = true

    depth += 1

    for k,v of mod.dependencies
      unless (fn v, depth) == false
        walkdeps v, fn, depth

  console.log mod.requireAs

  lines = []

  walkdeps mod, (mod, depth, seen) ->
    if seen
      lines.pop()
      return

    line = '├─' + mod.requireAs

    if depth > 0
      line = (new Array depth*2).join(' ') + line
    lines.push [line, depth]

  for [line, depth], idx in lines
    unless lines[idx+1]?
      lines[idx][0] = line.replace '├─', '└─'
    else
      [nextLine, nextDepth] = lines[idx+1]
      if nextLine? and depth != nextDepth
        lines[idx][0] = line.replace '├─', '└─'

  console.log (line[0] for line in lines).join '\n'

module.exports =
  clone: clone
  codegen: codegen
  graph: graph
  parse: parse
  walk: walk
