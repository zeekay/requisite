path         = require 'path'
{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  stylus = requireTry 'stylus'

  stylus.render opts.source, filename: opts.filename, (err, css) ->
    return cb err if err?

    cb null, """
    module.exports = #{css}
    """
