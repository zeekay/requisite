module.exports =
  js: (options, callback) ->
    callback null, options.source

  json: (options, callback) ->
    callback null, "module.exports = #{options.source}"

  html: (options, callback) ->
    callback null, "module.exports = #{JSON.stringify options.source}"

  coffee: require './coffee'
  jade: require './jade'
