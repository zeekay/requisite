Promise      = require 'broken'
path         = require 'path'
toRegex      = require 'to-regexp'

Module       = require './module'
{Prelude}    = require './wrapper'
{isFunction} = require './utils'

createWrapper = (opts) ->
  new Prelude
    bare:          opts.bare
    globalRequire: opts.globalRequire
    prelude:       opts.prelude
    preludeAsync:  opts.preludeAsync
    includeAsync:  opts.includeAsync

module.exports = (opts = {}, cb = ->) ->
  if isFunction opts
    [cb, opts] = [opts, {}]

  p = new Promise (resolve, reject) ->
    # Return only prelude
    if opts.preludeOnly
      unless opts.bare
        opts.globalRequire = true
      return resolve createWrapper opts

    # Base paths
    basePath      = opts.base ? opts.src
    sourceMapRoot = basePath ? '/' + (path.relative process.cwd(), path.dirname opts.entry)

    # Make sure we have sane exclude, include, resolved to pass to modules
    exclude  = toRegex opts.exclude
    include  = opts.include  ? {}
    resolved = opts.resolved ? {}

    # Do not pass empty objects
    unless (Object.keys include).length
      include = null
    unless (Object.keys resolve).length
      resolved = null

    # Build module
    mod = new Module opts.entry,
      basePath:      basePath
      compilers:     opts.compilers
      exclude:       exclude
      exported:      opts.exported
      required:      opts.required
      include:       include
      moduleCache:   opts.moduleCache
      paths:         opts.paths ? []
      resolved:      resolved
      sourceMap:     opts.sourceMap ? true
      sourceMapRoot: opts.sourceMapRoot ? sourceMapRoot
      strict:        opts.strict
      urlRoot:       opts.urlRoot

    mod.parse (err) ->
      return reject err if err?

      # Detect async
      if opts.async? and opts.async
        mod.async = true
      else
        for k,v of mod.moduleCache
          if v.async
            opts.includeAsync = true
            break

      # Add wrapper
      unless opts.bare
        mod.toplevel = createWrapper opts

      # Allow declaration to be overridden
      if opts.requireAs?
        mod.requireAs = opts.requireAs

      resolve mod

  p.callback cb
  p
