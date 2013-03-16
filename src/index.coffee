Module  = require './module'
Wrapper = require './wrapper'

exportEntry = (name, requireAs) ->
  acorn = require 'acorn'
  path  = require 'path'
  acorn.parse "global.#{path.basename name} = require('#{requireAs}');"

module.exports =
  Module:  Module
  Wrapper: Wrapper

  bundle: (entry, options, callback) ->
    @parse entry, options, (err, wrapper) ->
      throw err if err

      callback null, wrapper.toString options

  walk: (module) ->
    required   = {}
    async      = {}
    excluded   = {}

    seen       = {}
    unresolved = [module]

    while (module = unresolved.shift())
      for k, v of module.dependencies
        unless seen[k]
          seen[k] = v

          if v.async
            async[k] = v
          else if v.excluded
            excluded[k] = v
          else
            required[k] = v

          for k, v of v.dependencies
            unresolved.push v

    async: async
    excluded: excluded
    required: required

  parse: (entry, options, callback) ->
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
