async     = require 'async'
Module    = require './module'
{Prelude} = require './wrapper'

addIncludes = (includes, main, callback) ->
  console.log 'adding includes'

  async.map ([k,v] for k,v of includes), ([requireAs, absolutePath], callback) ->
    mod = new Module absolutePath,
      absolutePath: absolutePath
      basePath: main.basePath
      requireAs: requireAs

    mod.parse (err) ->
      return callback err if err?
      main.dependencies[requireAs] = mod
      callback()

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

  main.parse (err) =>
    return callback err if err?

    addIncludes options.include, main, ->
      main.toplevel = wrapper
      callback null, main
