{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  pug = requireTry 'pug'

  fn = pug.compile opts.source,
    filename:     opts.filename
    compileDebug: false
    debug:        false
    pretty:       true

  source = JSON.stringify fn()

  cb null, """
  module.exports = #{source};
  """
