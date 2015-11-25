module.exports = (opts, cb) ->
  source = JSON.stringify opts.source

  cb null, """
  module.exports = #{source};
  """
