module.exports = (options, callback) ->
  jade    = require 'jade'

  func = jade.compile options.source,
    client: true
    compileDebug: false
    debug: false
    filename: options.filename

  callback null, """
    jade = require('requisite/lib/compilers/jade-runtime.js');
    module.exports = #{func.toString()}
    """
