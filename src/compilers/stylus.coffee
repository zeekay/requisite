path         = require 'path'
{requireTry} = require '../utils'

module.exports = (opts, cb) ->
  stylus = requireTry 'stylus'

  stylus.render opts.source, filename: opts.filename, (err, css) ->
    return cb err if err?

    source = JSON.stringify css

    cb null, """
    module.exports = #{source};
    """
