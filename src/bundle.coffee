Module    = require './module'
{Prelude} = require './wrapper'
path      = require 'path'
toRegex   = require 'to-regexp'

createWrapper = (opts) ->
  new Prelude
    async:         opts.async
    bare:          opts.bare
    globalRequire: opts.globalRequire
    prelude:       opts.prelude
    preludeAsync:  opts.preludeAsync

module.exports = (opts = {}, cb = ->) ->
  if typeof opts == 'function'
    [cb, opts] = [opts, {}]

  if opts.preludeOnly
    unless opts.bare
      opts.globalRequire = true
    return cb null, createWrapper opts

  # Base paths
  basePath      = opts.base ? opts.src
  sourceMapRoot = basePath ? ('/' + path.dirname opts.entry)

  # Make sure we have a regular expression
  exclude   = toRegex opts.exclude
  include   = null
  resolveAs = null

  if (Object.keys opts.include ? {}).length
    include   = opts.include
  if (Object.keys (opts.resolveAs ? opts.resolve ? {})).length
    resolveAs = opts.resolveAs

  # Build module
  mod = new Module opts.entry,
    bare:          opts.bare
    basePath:      basePath
    compilers:     opts.compilers
    exclude:       exclude
    export:        opts.export
    include:       include
    moduleCache:   opts.moduleCache
    paths:         opts.paths ? []
    resolveAs:     resolveAs
    sourceMap:     opts.sourceMap ? true
    sourceMapRoot: opts.sourceMapRoot ? sourceMapRoot
    strict:        opts.strict
    urlRoot:       opts.urlRoot

  mod.parse (err) ->
    return cb err if err?

    # Detect async
    unless opts.async
      for k,v of mod.moduleCache
        if v.async
          opts.async = true
          break

    # Add wrapper
    unless opts.bare
      mod.toplevel = createWrapper opts

    cb null, mod
