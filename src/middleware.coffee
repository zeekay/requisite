url    = require 'url'
bundle = require './bundle'
{join} = require 'path'

module.exports = (options={}) ->
  maxAge   = options.maxAge or 0
  src      = options.src ? process.cwd()
  cache    = {}

  middleware = (req, res, next) ->
    # parse url to deal with oddness, strip extension from module path
    path = (url.parse req.url, true, true).pathname.replace /\.\w+$/, ''

    unless (cached = cache[path])?
      bundle (join src, path), options, (err, _bundle) ->
        return next err if err?

        cache[path] = _bundle
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
    cached.parse {deep: true}, (err) ->
      return next err if err?

      console.log path
      unless (mod = cached.find path)?
        return next()

      res.writeHead 200
      res.end mod.toString(), 'utf8'

  # Wrap this is a named function to make debugging easier.
  `function requisite(req, res, next) { return middleware(req, res, next); };`
