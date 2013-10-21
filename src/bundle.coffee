async     = require 'async'
Module    = require './module'
{Prelude} = require './wrapper'

addIncludes = (options, main, callback) ->
  async.map ([k,v] for k,v of options.include), ([requireAs, absolutePath], _callback) ->
    mod = new Module absolutePath,
      absolutePath: absolutePath
      basePath: main.basePath
      requireAs: requireAs

    mod.parse paths: options.paths, (err) =>
      return callback err if err?
      main.dependencies[requireAs] = mod
      _callback()

  , (err) ->
    throw err if err

    callback()

module.exports = (entry, options, callback) ->
  if typeof options == 'function'
    [callback, options] = [options, {}]

  options.include ?= {}

  main = new Module entry,
    exclude: options.exclude
    export: options.export

  wrapper = new Prelude
    bare:    options.bare
    prelude: options.prelude

  main.parse paths: options.paths, (err) =>
    return callback err if err?

    addIncludes options, main, ->
      main.toplevel = wrapper
      callback null, main
