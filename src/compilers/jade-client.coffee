{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  jade = requireTry 'jade'

  fn = jade.compileClient opts.source,
    compileDebug: false
    debug:        false
    filename:     opts.filename
    pretty:       false

  cb null, """
  module.exports = #{fn.toString()}"
  """
