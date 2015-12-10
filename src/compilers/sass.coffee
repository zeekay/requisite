path = require 'path'

{requireTry} = require '../utils'

# Look for .scss|sass files inside the node_modules folder
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

# Add bourbon to include paths
addBourbon = do ->
  bourbonPath = null

  (includePaths) ->
    unless bourbonPath?
      try
        bourbonPath = path.dirname require.resolve 'bourbon'
      catch err

    if bourbonPath
      includePaths.concat bourbonPath
    else
      includePaths

module.exports = (opts, cb) ->
  sass = requireTry 'node-sass'

  includePaths = [
    path.join process.cwd(), 'node_modules'
    path.dirname opts.absolutePath
  ]

  # Try to include path to Bourbon
  includePaths = addBourbon includePaths

  sass.render
    # importer:     resolveNpm
    data:         opts.source
    includePaths: includePaths
    outputStyle: 'nested'
  , (err, res) ->
    return cb err if err?

    cb null, """
    module.exports = #{JSON.stringify res.css.toString()}
    """
