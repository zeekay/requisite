fs     = require 'fs'
path   = require 'path'
bundle = require './bundle'

module.exports = (entry, options, callback) ->
  watchedDirs = {}

  bundle entry, options, (err, _bundle) ->
    # callback immediately with bundle
    callback err, _bundle

    # add dir to watched Dirs
    watchedDirs[path.dirname _bundle.absolutePath] = true

    # find all directories
    _bundle.walkDependencies (mod) ->
      dir = path.dirname mod.absolutePath
      watchedDirs[dir] = true

    # loop through dirs we need to watch
    for dir of watchedDirs
      do (dir) ->

        # add watcher on directory
        fs.watch dir, (event, filename) ->
          absolutePath = path.join dir, filename
          return unless fs.existsSync absolutePath

          _bundle.parse {deep: true}, (err) ->
            callback err, _bundle
