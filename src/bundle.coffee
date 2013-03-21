async     = require 'async'
Module    = require './module'
{Prelude} = require './wrapper'

addIncludes = (includes, main, callback) ->
  async.map ([k,v] for k,v of includes), ([requireAs, absolutePath], callback) ->
    mod = new Module absolutePath,
      absolutePath: absolutePath
      basePath: main.basePath
      requireAs: requireAs

    mod.parse ->
      main.dependencies[requireAs] = mod
      callback()

  , (err) ->
    throw err if err

    callback()

module.exports = (entry, options, callback) ->
  if typeof options == 'function'
    [callback, options] = [options, {}]

  options.includes ?= {}

  main = new Module entry,
    exclude: options.exclude
    export: options.export

  wrapper = new Prelude
    bare:    options.bare
    prelude: options.prelude

  main.parse =>
    addIncludes options.includes, main, ->
      main.toplevel = wrapper
      callback null, main
