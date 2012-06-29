compilers      = require './compilers'
fs             = require 'fs'
{exists, uniq} = require './utils'
{join, sep}    = require 'path'

module.exports = (root) ->
  # Maintain a cache of resolved paths.
  cache = {}

  # Build list of extensions to check for.
  extensions = do ->
    ext = ['', '.js', '.coffee']
    # Add extensions from `compilers`.
    for k,v of compilers
      ext.push '.' + k
    # Return list of extensions with duplicates dropped.
    uniq ext

  # Build list of valid node_modules paths.
  modulePaths = do (root) ->
    last = ''
    paths = []
    for path in root.split sep
      last = join last, sep, path
      paths.push join last, 'node_modules'
    paths.shift()
    paths = paths.reverse()
    # Append any extra paths found in NODE_PATH
    if process.env.NODE_PATH
      paths = paths.concat process.env.NODE_PATH.split ':'
    paths

  # Resolve directory/npm module to index/main file.
  resolveDirectory = (path, cb) ->
    packageJson = join path, 'package.json'
    exists packageJson, (exist) ->
      if exist
        fs.readFile packageJson, (err, content) ->
          main = JSON.parse(content).main
          if main
            resolveRelative join(path, main), cb
          else
            resolveRelative join(path, 'index'), cb
      else
        resolveRelative join(path, 'index'), cb

  # Resolve path to npm module.
  resolveModule = (name, cb) ->
    idx = 0
    iterate = ->
      if idx == modulePaths.length
        throw new Error "Unable to resolve module #{name}"
      path = join modulePaths[idx], name
      exists path, (exist) ->
        if exist
          resolveDirectory path, cb
        else
          idx++
          iterate()
    iterate()

  # Resolve path to relative module.
  resolveRelative = resolveRelative = (path, cb) ->
    idx = 0
    iterate = ->
      if idx == extensions.length
        throw new Error "Unable to resolve path to module #{path}"
      fs.realpath path+extensions[idx], cache, (err, resolved) ->
        if not err
          fs.lstat resolved, (err, stats) ->
            if stats.isDirectory()
              resolveDirectory resolved, cb
            else if stats.isFile()
              cache[path] = resolved
              cb null, resolved
            else
              throw new Error "What the fuck!?"
        else
          idx++
          iterate()
    iterate()

  resolver =
    resolveDirectory: resolveDirectory
    resolveModule: resolveModule
    resolveRelative: resolveRelative
    resolve: (path, cb) ->
      # if path starts with . or / it's relative
      if /^[./]/.test path
        resolveRelative path, cb
      else
        resolveModule path, cb
