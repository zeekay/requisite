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

  iterate = ->
    unless options.include.length == 0
      module = new Module options.include.pop()
      module.parse =>
        wrapper.append module
        iterate()
    else
      main = new Module entry,
        exclude: options.exclude

      main.parse =>
        wrapper.append main

        if options.export?
          wrapper.append exportEntry options.export, main.requireAs

        callback null, wrapper

  iterate()
