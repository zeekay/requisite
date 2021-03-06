bresolve = (require 'browser-resolve').sync
os       = require 'os'
path     = require 'path'

builtins        = require './builtins'
{normalizePath} = require './utils'

extensions = ('.' + ext for ext of require('./compilers'))

NODE_PATHS = (process.env.NODE_PATH ? '').split(':')
NODE_PATHS.push process.cwd()

cwd = process.cwd()

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
  cache = do ->
    _cache = {}

    (resolveFrom, requiredAs, mod) ->
      if requiredAs.charAt(0) == '.'
        key = resolveFrom+requiredAs
      else
        key = requiredAs

      if mod?
        _cache[key] = mod
      else
        _cache[key]

  (requiredAs, opts = {}) ->
    # asked to cache lookup in advance
    if opts.cache?
      cache opts.resolveFrom, requiredAs, opts
      return

    paths = NODE_PATHS.concat opts.paths ? []
    opts.extensions ?= extensions

    if (requiredBy = opts.requiredBy)?
      # normal dependency
      resolveFrom = path.dirname requiredBy
      basePath    = opts.basePath
    else
      # entry module, all required modules should be resolved relative to it's dir
      base = opts.basePath ? (path.dirname path.resolve requiredAs)
      basePath = resolveFrom = path.resolve base
      requiredAs = './' + (path.resolve requiredAs).replace basePath, ''

    # use cached resolution if possible
    return cached if (cached = cache resolveFrom, requiredAs)?

    # resolve absolute path to module
    if builtins[requiredAs]?
      # No need to resolve builtins
      absolutePath = builtins[requiredAs]
    else
      absolutePath = resolve requiredAs,
        basedir:    resolveFrom
        extensions: opts.extensions

      while (not absolutePath?) and (nextPath = paths.shift())?
        absolutePath = resolve requiredAs,
          basedir:    nextPath
          extensions: opts.extensions

    unless absolutePath?
      err = "Unable to resolve module '#{requiredAs}' required from '#{requiredBy}'"
      throw new Error err

    extension   = path.extname absolutePath
    extensionRe = new RegExp extension + '$'

    normalizedPath = normalizePath absolutePath, basePath
    relativePath   = normalizePath absolutePath, cwd
    requireAs      = normalizedPath.replace extensionRe, ''
                                   .replace /\/index$/, ''

    # Strip off any leading node_modules paths (we flatten modules)
    if (match = /(.*node_modules\/)([/._-\w])+$/.exec requireAs)
      requireAs = requireAs.replace match[1], ''
    else
      requireAs = './' + requireAs

    cache resolveFrom, requiredAs,
      absolutePath:   absolutePath
      basePath:       basePath
      extension:      extension
      normalizedPath: normalizedPath
      relativePath:   relativePath
      requireAs:      requireAs
      requiredAs:     requiredAs
      requiredBy:     requiredBy
