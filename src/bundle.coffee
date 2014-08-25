path      = require 'path'
Module    = require './module'
{Prelude} = require './wrapper'


module.exports = (opts = {}, cb = ->) ->
  if typeof opts == 'function'
    [cb, opts] = [opts, {}]

  main = new Module opts.entry,
    bare:        opts.bare
    basePath:    opts.src
    exclude:     opts.exclude
    export:      opts.export
    include:     opts.include
    moduleCache: opts.moduleCache
    paths:       opts.paths ? []
    requireAs:   path.basename opts.entry
    strict:      opts.strict
    urlRoot:     opts.urlRoot
    sourceMap:   opts.sourceMap ? true

  main.parse (err) ->
    return cb err if err?

    async = false

    for k,v of main.moduleCache
      if v.async
        async = true
        break

    unless opts.bare
      wrapper = new Prelude
        async:         async
        globalRequire: opts.globalRequire
        prelude:       opts.prelude
        preludeAsync:  opts.preludeAsync

      main.toplevel = wrapper

    cb null, main
