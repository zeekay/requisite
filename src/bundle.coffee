path      = require 'path'

Module    = require './module'
{Prelude} = require './wrapper'


module.exports = (entry, opts = {}, cb = ->) ->
  if typeof opts == 'function'
    [cb, opts] = [opts, {}]

  main = new Module entry,
    bare:      opts.bare
    urlRoot:   opts.urlRoot
    export:    opts.export
    exclude:   opts.exclude
    include:   opts.include
    paths:     opts.paths ? []
    requireAs: path.basename entry

  main.parse (err) =>
    return cb err if err?

    unless opts.bare
      wrapper = new Prelude
        prelude: opts.prelude

      main.toplevel = wrapper

    cb null, main
