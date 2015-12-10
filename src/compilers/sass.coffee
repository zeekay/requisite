fs   = require 'fs'
path = require 'path'

{requireTry} = require '../utils'


findNpm = (url) ->
  try
    path.relative process.cwd(), require.resolve url
  catch err
    path.relative process.cwd(), require.resolve url


# look for .scss|sass files inside the node_modules folder
resolveNpm = do ->
  cache = {}

  (url, file, cb) ->
    # check if the path was already found and cached
    return cb file: cache[url] if cache[url]?

    # look for modules installed through npm
    try
      newPath = findNpm url
      cache[url] = newPath # cache request
      return cb file: newPath
    catch e
      # if your module could not be found, just return the original url
      cache[url] = url
      return cb file: url
    return


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
    throw err if err?

    cb null, """
    module.exports = #{JSON.stringify res.css.toString()}
    """
