fs     = require 'fs'
path   = require 'path'
vigil  = require 'vigil'

bundle = require './bundle'


module.exports = (options, cb) ->
  bundle options, (err, _bundle) ->
    return cb err if err?
    cb null, _bundle

    watched = {}

    # rebuild bundle
    rebuildBundle = ->
      _bundle.parse {deep: true}, (err) ->
        return cb err if err?
        cb null, _bundle

    watch = (dir) ->
      return if watched[dir]

      vigil.watch dir, {recurse: false}, rebuildBundle

    watch path.dirname _bundle.absolutePath

    _bundle.walkDependencies (mod) ->
      watch path.dirname mod.absolutePath
