fs        = require 'fs'
os        = require 'os'
path      = require 'path'

acorn     = require 'acorn'
convert   = require 'convert-source-map'
escodegen = require 'escodegen'
isRegex   = require 'is-regex'
isString  = require 'is-string'

{SourceMapConsumer} = require 'source-map'
{traverse}          = require 'estraverse'


exports.toRegex = (r) ->
  return r if isRegex r

  if isString r
    return new RegExp "^#{r}"

  if Array.isArray r
    return new RegExp r '|'

  throw new Error 'Unable to create regex from ' + r


# Pretty print Date object.
exports.formatDate = (date = new Date) ->
  (/\d{2}:\d{2}:\d{2}/.exec date)[0]

# parse source into ast
exports.parse = (source, opts = {}) ->
  comments = []
  tokens   = []

  _opts =
    # for preserving comments
    ranges:     true
    onComment:  comments
    onToken:    tokens

    # for source maps
    locations:  true
    sourceFile: opts.filename

  ast = acorn.parse source, _opts
  escodegen.attachComments ast, comments, tokens
  ast

guessMinifier = ->
  try
    return 'uglifyjs' if require.resolve 'uglify-js'
  catch err

  try
    require.resolve 'esmangle'
  catch err
    throw new Error('Unable to determine minifier to use')

  'esmangle'

# generate string from ast, optionally minify
exports.codegen = (ast, opts = {}) ->
  # Minified
  if opts.minify
    minifier = opts.minifier ? guessMinifier()
    if /uglify/.test minifier
      minifier = 'uglifyjs'
    minify = require './minify'
    return minify[minifier] ast, opts

  _opts =
    comment: yes
    format:
      indent:
        style: '  '
        base: 0
      compact: no
      escapeless: yes
      parentheses: no
      quotes: 'auto'
      semicolons: no

  # No source map
  unless opts.sourceMap
    return escodegen.generate ast, _opts

  # Source maps
  _opts.sourceMap         = true
  _opts.sourceMapWithCode = true
  _opts.sourceMapRoot     = opts.sourceMapRoot ? ""

  output = escodegen.generate ast, _opts
  code   = output.code
  map    = output.map

  if opts.onlySourceMap
    convert.fromObject(map).toJSON()
  else
    code + convert.fromObject(map).toComment()

# walk ast
exports.walk = walk = (node, visitor) ->
  if node? and typeof node == 'object'
    unless visitor node
      for k,v of node
        walk v, visitor

  else if Array.isArray node
    for el in node
      walk el, visitor

# draw simple graph of dependencies
exports.graph = (mod) ->
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

# Nice error message when missing compiler.
exports.requireTry = (pkg) ->
  try
    require pkg
  catch err
    console.error "Unable to require '#{pkg}'. Try `npm install -g #{pkg}`."
    throw new Error "Missing compiler"

# Gets path relative to basePath and normalizes it.
exports.normalizePath = (absolutePath, basePath) ->
  if (absolutePath.indexOf basePath) != -1
    normalizedPath = absolutePath.replace basePath, ''
  else
    start = absolutePath.indexOf 'node_modules'
    normalizedPath = absolutePath.substring start, absolutePath.length

  if os.platform() == 'win32'
    normalizedPath.replace /^\\+/, ''
  else
    normalizedPath.replace /^\/+/, ''

exports.sourceMapToAst = (ast, map) ->
  map = new SourceMapConsumer(map)

  traverse ast, enter: (node) ->
    unless node.type and node.loc
      return

    origStart = map.originalPositionFor node.loc.start

    if !origStart.line
      delete node.loc
      return

    origEnd = map.originalPositionFor node.loc.end

    if origEnd.line and (origEnd.line < origStart.line or origEnd.column < origStart.column)
      origEnd.line = null

    node.loc =
      start:
        line: origStart.line
        column: origStart.column
      source: origStart.source
      name: origStart.name

    if origEnd.line
      node.loc.end =
        line: origEnd.line
        column: origEnd.column

    return
  ast
