{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  pug = requireTry 'pug'

  fn = pug.compileClient opts.source,
    filename:     opts.filename
    compileDebug: false
    debug:        false
    pretty:       true

  cb null, """
  module.exports = #{fn.toString()}"
  """
