path      = require 'path'

Module    = require './module'
{Prelude} = require './wrapper'


module.exports = (entry, options, callback) ->
  if typeof options == 'function'
    [callback, options] = [options, {}]

  callback ?= ->
  options  ?= {}

  main = new Module entry,
    requireAs: path.basename entry
    include:   options.include
    exclude:   options.exclude
    export:    options.export
    paths:     options.paths ? []

  wrapper = new Prelude
    bare:    options.bare
    prelude: options.prelude

  main.parse (err) =>
    return callback err if err?

    main.toplevel = wrapper
    callback null, main
