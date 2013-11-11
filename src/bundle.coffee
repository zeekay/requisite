path      = require 'path'

Module    = require './module'
{Prelude} = require './wrapper'


module.exports = (opts = {}, cb = ->) ->
  if typeof opts == 'function'
    [cb, opts] = [opts, {}]

  main = new Module opts.entry,
    bare:      opts.bare
    urlRoot:   opts.urlRoot
    export:    opts.export
    exclude:   opts.exclude
    include:   opts.include
    paths:     opts.paths ? []
    requireAs: path.basename opts.entry

  main.parse (err) =>
    return cb err if err?

    unless opts.bare
      wrapper = new Prelude
        prelude: opts.prelude

      main.toplevel = wrapper

    cb null, main
