Module  = require './module'
Wrapper = require './wrapper'

exportEntry = (name, requireAs) ->
  acorn = require 'acorn'
  path  = require 'path'
  acorn.parse "global.#{path.basename name} = require('#{requireAs}');"

module.exports = (entry, options, callback) ->
  if typeof options == 'function'
    [callback, options] = [options, {}]

  options.include ?= []

  wrapper = new Wrapper
    bare:    options.bare
    prelude: options.prelude

  main = new Module entry,
    exclude: options.exclude

  appendIncludes = (callback) ->
    if options.include.length == 0
      callback null
    else
      module = new Module options.include.pop()
      module.parse =>
        main.append module
        appendIncludes callback

  main.parse =>
    if options.export?
      main.append exportEntry options.export, main.requireAs

    appendIncludes ->
      wrapper.wrap main
      callback null, main
