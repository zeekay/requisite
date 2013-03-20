Module  = require './module'
{Prelude} = require './wrapper'

module.exports = (entry, options, callback) ->
  if typeof options == 'function'
    [callback, options] = [options, {}]

  options.include ?= []

  main = new Module entry,
    exclude: options.exclude
    export: options.export

  wrapper = new Prelude
    bare:    options.bare
    prelude: options.prelude

  main.parse =>
    addIncludes = (callback) ->
      if options.include.length == 0
        callback null
      else
        module = new Module options.include.pop()
        module.parse =>
          main.dependencies[module.requireAs] = module
          addIncludes callback

    addIncludes ->
      main.toplevel = wrapper
      callback null, main
