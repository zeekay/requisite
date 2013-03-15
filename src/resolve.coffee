extensions = ('.' + ext for ext of require('./compilers'))
path       = require 'path'
resolve    = require 'resolve'

cache      = {}

module.exports = (requiredAs, options = {}) ->
  unless (requiredBy = options.requiredBy)?
    # entry module, all required modules should be resolved relative to it's dir
    resolveFrom = path.dirname path.resolve requiredAs
    basePath    = resolveFrom
    requiredAs  = './' + path.basename requiredAs
  else
    resolveFrom = path.dirname requiredBy
    basePath    = options.basePath

  unless (absolutePath = cache[resolveFrom+requiredAs])?
    absolutePath = cache[resolveFrom+requiredAs] = resolve.sync requiredAs,
      basedir:    resolveFrom
      extensions: options.extensions ? extensions

  extension      = path.extname absolutePath
  normalizedPath = path.join './', (absolutePath.replace basePath, '')
  requireAs      = normalizedPath.replace extension, ''

  absolutePath:   absolutePath
  basePath:       path.dirname absolutePath
  extension:      extension
  normalizedPath: normalizedPath
  requireAs:      requireAs
  requiredAs:     requiredAs
  requiredBy:     requiredBy
