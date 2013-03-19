module.exports = (entry, options={}) ->
  maxAge = options.maxAge or 0
  bundle = null

  middleware = (req, res, next) ->
    unless bundle?
      require('./bundle') entry, options, (err, _bundle) ->
        bundle = _bundle
        middleware req, res, next
      return

    url = req.url

    unless (mod = bundle.find url)?
      return next()

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

    res.writeHead 200

    res.end mod.toString(), 'utf8'

  # Wrap this is a named function to make debugging easier.
  `function requisite(req, res, next) { return middleware(req, res, next); };`
