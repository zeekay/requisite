extensions = ('.' + ext for ext of require('./compilers'))
path       = require 'path'
resolve    = require 'resolve'

module.exports = ->
  cache = {}

  (requiredAs, options = {}) ->
    # asked to cache lookup in advance
    if options.cache?
      cache[options.resolveFrom+requiredAs] = options
      return

    options.paths      ?= []
    options.extensions ?= extensions

    if (requiredBy = options.requiredBy)?
      # normal dependency
      resolveFrom = path.dirname requiredBy
      basePath    = options.basePath
    else
      # entry module, all required modules should be resolved relative to it's dir
      resolveFrom = path.dirname path.resolve requiredAs
      basePath    = resolveFrom
      requiredAs  = './' + path.basename requiredAs

    # use cached resolution if possible
    return cached if (cached = cache[resolveFrom+requiredAs])?

    try
      absolutePath = resolve.sync requiredAs,
        basedir:    resolveFrom
        extensions: options.extensions
    catch err

    while (not absolutePath?) and (nextPath = options.paths.shift())?
      try
        absolutePath = resolve.sync requiredAs,
          basedir:    nextPath
          extensions: options.extensions
      catch err

    throw err unless absolutePath?

    extension      = path.extname absolutePath
    if (absolutePath.indexOf basePath) != -1
      normalizedPath = absolutePath.replace basePath, ''
    else
      start = absolutePath.indexOf 'node_modules'
      normalizedPath = absolutePath.substring start, absolutePath.length

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
