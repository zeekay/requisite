fs   = require 'fs'
path = require 'path'

# Pretty print Date object.
formatDate = (date = new Date) ->
  (/\d{2}:\d{2}:\d{2}/.exec date)[0]

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
parse = (source, options = {}) ->
  parser = require 'esprima'
  ast = parser.parse source,
    comment: true
    range: true
    raw: true
    tokens: true
  ast = require('escodegen').attachComments ast, ast.comments, ast.tokens

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

outputName = (requiredAs, opts) ->
    # Build output filename
    filename = path.basename bundle.requiredAs
    ext      = path.extname filename
    extout   = path.extname opts.output

    # Prevent duplicating extension
    if ext == extout
      filename = filename.replace ext, ''

    # Handle wildcard output filenames
    opts.output.replace '{}', filename

outputBundle = (bundle, opts) ->
  if opts.output?
    output = outputName bundle.requiredAs, opts
    fs.writeFileSync output, bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts

outputPrelude = (opts) ->
  prelude = path.resolve (path.join __dirname, '..', 'lib', 'prelude.js')
  prelude = fs.readFileSync prelude, 'utf8'

  if opts.output?
    fs.writeFileSync output, prelude, 'utf8'
  else
    console.log prelude

module.exports =
  clone:         clone
  codegen:       codegen
  formatDate:    formatDate
  graph:         graph
  outputBundle:  outputBundle
  outputPrelude: outputPrelude
  parse:         parse
  walk:          walk
