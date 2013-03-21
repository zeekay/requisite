fs     = require 'fs'
path   = require 'path'
Module = require './module'

module.exports = (bundle, callback) ->
  watchedDirs = {}
  watchedDirs[path.dirname bundle.absolutePath] = true

  bundle.walkDependencies bundle, (mod) ->
    dir = path.dirname mod.absolutePath
    watchedDirs[dir] = true

  for dir of watchedDirs
    do (dir) ->
      fs.watch dir, (event, filename) ->
        absolutePath = path.join dir, filename
        return unless fs.existsSync absolutePath

        mod = Module.find (mod) ->
          mod.absolutePath == absolutePath

        mod.parse {deep: false, force: true}, ->
          callback event, filename, mod
