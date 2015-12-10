path = require 'path'

{requireTry} = require '../utils'

# look for .scss|sass files inside the node_modules folder
resolveNpm = do ->
  cache = {}

  (url, file, cb) ->
    if cache[url]?
      return cb file: cache[url]

    cache[url] = url

    # look for modules installed through npm
    try
      cache[url] = path.relative process.cwd(), require.resolve url
    catch err
      console.error err

    cb file: cache[url]

module.exports = (opts, cb) ->
  sass = requireTry 'node-sass'

  includePaths = [
    path.join process.cwd(), 'node_modules'
    path.dirname opts.absolutePath
  ]

  try
    bourbon = require 'node-bourbon'
    includePaths = includePaths.concat bourbon.includePaths
  catch err

  sass.render
    data:         opts.source
    importer:     resolveNpm
    includePaths: includePaths
    outputStyle: 'nested'
  , (err, res) ->
    return cb err if err?

    cb null, """
    module.exports = #{JSON.stringify res.css.toString()}
    """
