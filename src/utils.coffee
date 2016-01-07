fs   = require 'fs'
os   = require 'os'
path = require 'path'

# Pretty print Date object.
exports.formatDate = (date = new Date) ->
  (/\d{2}:\d{2}:\d{2}/.exec date)[0]

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
