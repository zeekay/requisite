compilers = require './compilers'
fs        = require 'fs'
{exists}  = require './utils'
{join}    = require 'path'
{sep}     = require './utils'
{uniq}    = require './utils'
{resolve} = require 'path'

module.exports = (root) ->
  # Get absolute path
  root = resolve root

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
    paths = paths.reverse()
    # Append any extra paths found in NODE_PATH
    if process.env.NODE_PATH
      paths = paths.concat process.env.NODE_PATH.split ':'
    paths

  console.log modulePaths

  # Resolve directory/npm module to index/main file.
  resolveDirectory = (path, cb) ->
    packageJson = join path, 'package.json'
    exists packageJson, (exist) ->
      if exist
        fs.readFile packageJson, (err, content) ->
          main = JSON.parse(content).main
          if main
            resolveFile join(path, main), cb
          else
            resolveFile join(path, 'index'), cb
      else
        resolveFile join(path, 'index'), cb

  # Resolve path to npm module.
  resolveModule = (name, cb) ->
    idx = 0
    iterate = ->
      if idx == modulePaths.length
        return cb new Error "Unable to resolve module #{name}"
      path = join modulePaths[idx], name
      exists path, (exist) ->
        if exist
          resolveDirectory path, cb
        else
          idx++
          iterate()
    iterate()

  # Resolve path to relative module.
  resolveFile = resolveFile = (path, cb) ->
    idx = 0
    iterate = ->
      if idx == extensions.length
        return cb new Error "Unable to resolve path to module #{path}"
      fs.realpath path+extensions[idx], cache, (err, resolved) ->
        if not err
          fs.lstat resolved, (err, stats) ->
            if stats.isDirectory()
              resolveDirectory resolved, cb
            else if stats.isFile()
              cache[path] = resolved
              cb null, resolved
            else
              return cb new Error "What the fuck!?"
        else
          idx++
          iterate()
    iterate()

  resolver =
    resolveDirectory: resolveDirectory
    resolveFile: resolveFile
    resolveModule: resolveModule
    resolve: (path, cb) ->
      # if path starts with . or / or C:\\ it's a file
      if /^\.\/|\/|^\w\:\\/.test path
        resolveFile path, cb
      else
        resolveModule path, cb
