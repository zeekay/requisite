{dirname, join} = require 'path'
{parse} = require 'url'

bundle = require './bundle'


module.exports = (opts = {}) ->
  maxAge = opts.maxAge or 0
  cached = null

  middleware = (req, res, next) ->
    url = parse req.url, true, true

    # strip extension from module path
    path = url.pathname.replace /\.\w+$/, ''

    unless cached?
      # set urlRoot so async requires work
      opts.urlRoot ?= dirname req.originalUrl
      opts.entry   ?= path

      # create bundle
      bundle opts, (err, _bundle) ->
        return next err if err?

        cached = _bundle
        middleware req, res, next
      return

    now = new Date().toUTCString()
    res.setHeader 'Date', now unless res.getHeader 'Date'
    res.setHeader 'Cache-Control', 'public, max-age=' + (maxAge / 1000) unless res.getHeader 'Cache-Control'
    res.setHeader 'Last-Modified', now unless res.getHeader 'Last-Modified'
    res.setHeader 'Content-Type', 'application/javascript; charset=UTF-8'

    if req.method == 'HEAD'
      res.writeHead 200
      return res.end()

    if req.method != 'GET'
      return next()

    # reparse in case of changes
    cached.parse {deep: true}, (err) ->
      return next err if err?

      unless (mod = cached.find path)?
        return next()

      res.writeHead 200
      res.end mod.toString(), 'utf8'

  # Wrap this is a named function to make debugging easier.
  `function requisite(req, res, next) { return middleware(req, res, next); };`
