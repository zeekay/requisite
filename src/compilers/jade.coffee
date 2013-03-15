module.exports = (options, callback) ->
  jade    = require 'jade'
  path    = require 'path'
  resolve = require '../resolve'

  # cache runtime resolution
  resolve 'jade-runtime',
    absolutePath: require('path').join __dirname, 'jade-runtime.js'
    resolveFrom: path.dirname @absolutePath
    cache: true

  func = jade.compile options.source,
    client: true
    compileDebug: false
    debug: false
    filename: options.filename

  callback null, """
    jade = require('jade-runtime');

    module.exports = #{func.toString()}
    """
