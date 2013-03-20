extensions = ('.' + ext for ext of require('./compilers'))
path       = require 'path'
resolve    = require 'resolve'

cache      = {}

module.exports = (requiredAs, options = {}) ->
  # asked to cache lookup in advance
  if options.cache?
    cache[options.resolveFrom+requiredAs] = options
    return

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

  absolutePath = resolve.sync requiredAs,
    basedir:    resolveFrom
    extensions: options.extensions ? extensions

  extension      = path.extname absolutePath
  normalizedPath = path.join './', (absolutePath.replace basePath, '')
  requireAs      = normalizedPath.replace extension, ''

  cache[resolveFrom+requiredAs] =
    absolutePath:   absolutePath
    basePath:       basePath
    extension:      extension
    normalizedPath: normalizedPath
    requireAs:      requireAs
    requiredAs:     requiredAs
    requiredBy:     requiredBy
