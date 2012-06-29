compilers = require './compilers'
fs        = require 'fs'
{join}    = require 'path'
{sep}     = require 'path'
{split}   = require 'path'
{uniq}    = require './utils'

# cache seen paths
cache = {}

# extensions we check for
extensions = do ->
  ext = ['', '.js', '.coffee']
  # add extensions from compilers
  for k,v of compilers
    ext.push '.' + k
  uniq ext

# node_modules paths
modulePaths = do ->
  # add all paths up to root
  last = ''
  paths = []
  root = process.cwd()
  for path in root.split sep
    last = join last, sep, path
    paths.push join last, 'node_modules'
  paths.shift()
  paths.reverse().concat process.env.NODE_PATH.split ':'

# Resolves entry point of relative directory of node module
exports.resolveDirectory = resolveDirectory = (path, callback) ->
  packageJson = join path, 'package.json'
  fs.exists packageJson, (exists) ->
    if exists
      fs.readFile packageJson, (err, content) ->
        main = JSON.parse(content).main
        if main
          resolveRelative join(path, main), callback
        else
          resolveRelative join(path, 'index'), callback
    else
      resolveRelative join(path, 'index'), callback

# Asynchronously resolve path to node_modules
exports.resolveModule = resolveModule = (name, callback) ->
  idx = 0
  iterate = ->
    if idx == modulePaths
      throw new Error "Unable to resolve module #{name}"
    path = join modulePaths[idx], name
    fs.exists path, (exists) ->
      if exists
        callback null, require.resolve path
      else
        idx++
        iterate()
  iterate()

# Asynchronously resolve path to relative modules
exports.resolveRelative = resolveRelative = (path, callback) ->
  idx = 0
  iterate = ->
    if idx == extensions.length
      throw new Error "Unable to resolve path to module #{path}"
    fs.realpath path+extensions[idx], cache, (err, resolved) ->
      if not err
        fs.lstat resolved, (err, stats) ->
          if stats.isDirectory()
            resolveDirectory resolved, (err, resolved) ->
              cache[path] = resolved
              callback null, resolved
          else
            cache[path] = resolved
            callback null, resolved
      else
        idx++
        iterate()
  iterate()

# Asynchronously resolve path to module
exports.resolve = (path, callback) ->
  # if path starts with . or / it's relative
  if {'.': true, '/': true}[path[0]]
    resolveRelative path, callback
  else
    resolveModule path, callback
