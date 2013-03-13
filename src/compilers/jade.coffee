compile = (options) ->
  func = require('jade').compile options.source,
    client: true
    compileDebug: false
    debug: false
    filename: options.filename

  """
  jade = require('jade-runtime');

  module.exports = #{func.toString()}
  """

module.exports = (options, callback) ->
  module = new @constructor 'jade-runtime',
    absolutePath: require('path').join __dirname, 'jade-runtime.js'
    requireAs: 'jade-runtime'
    requiredFrom: @absolutePath

  module.parse =>
    @dependencies['jade-runtime'] = module
    callback null, compile options
