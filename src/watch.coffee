fs     = require 'fs'
path   = require 'path'
vigil  = require 'vigil'
bundle = require './bundle'


module.exports = (options, cb) ->
  watched = {}

  bundle options, (err, _bundle) ->
    return cb err if err?
    cb null, _bundle

    dir = path.dirname _bundle.absolutePath

    # rebuild bundle if module has changed
    rebuildBundle = (filename, stats) ->
      absPath = path.resolve (path.join dir, filename)

      # Try to be too smart
      mod = _bundle.find (mod) ->
        return absPath == mod.absolutePath

      unless mod?
        console.warn filename, 'not found in bundle'
        return

      _bundle.parse {deep: true}, (err) ->
        return cb err if err?
        cb null, _bundle, filename

    watch = (dir) ->
      return if watched[dir]
      watched[dir] = true
      vigil.watch dir, {recurse: true}, rebuildBundle

    watch dir

    _bundle.walkDependencies (mod) ->
      watch path.dirname mod.absolutePath
