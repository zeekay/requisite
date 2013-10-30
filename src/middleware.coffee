url    = require 'url'
bundle = require './bundle'

module.exports = (options={}) ->
  unless options.entry?
    throw new Error 'Entry module unspecified'

  maxAge = options.maxAge or 0
  cache  = null

  middleware = (req, res, next) ->
    unless cache?
      bundle options.entry, options, (err, _bundle) ->
        return next err if err?

        cache = _bundle
        middleware req, res, next
      return

    now = new Date().toUTCString()
    res.setHeader 'Date', now unless res.getHeader 'Date'
    res.setHeader 'Cache-Control', 'public, max-age=' + (maxAge / 1000) unless res.getHeader 'Cache-Control'
    res.setHeader 'Last-Modified', now unless res.getHeader 'Last-Modified'
    res.setHeader 'Content-Type', 'application/javascript'

    if req.method == 'HEAD'
      res.writeHead 200
      return res.end()

    if req.method != 'GET'
      return next()

    # reparse in case of changes
    cache.parse {deep: true}, (err) ->
      return next err if err?

      # parse url to deal with oddness, strip extension from module path
      path = (url.parse req.url, true, true).pathname.replace /\.\w+$/, ''

      unless (mod = cache.find path)?
        return next()

      res.writeHead 200
      res.end mod.toString(), 'utf8'

  # Wrap this is a named function to make debugging easier.
  `function requisite(req, res, next) { return middleware(req, res, next); };`
