bresolve = require 'browser-resolve-sync'
builtins = require './builtins'
os       = require 'os'
path     = require 'path'

extensions = ('.' + ext for ext of require('./compilers'))

NODE_PATHS = (process.env.NODE_PATH ? '').split(':')

# Simple wrapper around browser-resolve-sync to deal with oddities in it's API.
resolve = (pkg, opts) ->
  try
    absolutePath = bresolve pkg,
      # filename is a bit of a hack, browser-resolve-sync uses this as as the
      # `base` for resolving things, so I append a fake filename which
      # browser-resolve-sync will lop off with `path.dirname`.
      filename:   path.join opts.basedir, 'ENOENT'
      extensions: opts.extensions
  catch err
    null

module.exports = ->
  cache = {}

  (requiredAs, options = {}) ->
    # asked to cache lookup in advance
    if options.cache?
      cache[options.resolveFrom+requiredAs] = options
      return

    paths = NODE_PATHS.concat options.paths ? []
    options.extensions ?= extensions

    if (requiredBy = options.requiredBy)?
      # normal dependency
      resolveFrom = path.dirname requiredBy
      basePath    = options.basePath
    else
      # entry module, all required modules should be resolved relative to it's dir
      resolveFrom = options.basePath ? path.dirname path.resolve requiredAs
      basePath    = resolveFrom
      requiredAs  = './' + path.basename requiredAs

    # use cached resolution if possible
    return cached if (cached = cache[resolveFrom+requiredAs])?

    # resolve absolute path to module
    if builtins[requiredAs]?
      # No need to resolve builtins
      absolutePath = builtins[requiredAs]
    else
      absolutePath = resolve requiredAs,
        basedir:    resolveFrom
        extensions: options.extensions

      while (not absolutePath?) and (nextPath = paths.shift())?
        absolutePath = resolve requiredAs,
          basedir:    nextPath
          extensions: options.extensions

    unless absolutePath?
      err = "Unable to resolve module '#{requiredAs}' required from '#{requiredBy}'"
      throw new Error err

    extension = path.extname absolutePath

    if (absolutePath.indexOf basePath) != -1
      normalizedPath = absolutePath.replace basePath, ''
    else
      start = absolutePath.indexOf 'node_modules'
      normalizedPath = absolutePath.substring start, absolutePath.length

    if os.platform() == 'win32'
      normalizedPath = normalizedPath.replace /^\\+/, ''
    else
      normalizedPath = normalizedPath.replace /^\/+/, ''

    requireAs = options.requireAs ? normalizedPath.replace extension, ''

    cache[resolveFrom+requiredAs] =
      absolutePath:   absolutePath
      basePath:       basePath
      extension:      extension
      normalizedPath: normalizedPath
      requireAs:      requireAs
      requiredAs:     requiredAs
      requiredBy:     requiredBy
