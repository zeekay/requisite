{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  jade = requireTry 'jade'

  fn = jade.compile opts.source,
    compileDebug: false
    debug:        false
    filename:     opts.filename
    pretty:       false

  source = JSON.stringify fn()

  cb null, """
  module.exports = #{source};
  """
