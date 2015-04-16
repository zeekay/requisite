module.exports = (options, callback) ->
  source = JSON.stringify options.source
  callback null, "module.exports = #{source}"
