exports.js = (body, filename) ->
  body

exports.json = (body, filename) ->
  "module.exports = #{body}"

exports.coffee = (body, filename) ->
  coffee = require 'coffee-script'
  coffee.compile body, bare: true, header: false

exports.html = (body, filename) ->
  "module.exports = #{JSON.stringify body}"

exports.jade = (body, filename) ->
  jade = require 'jade'
  func = jade.compile body,
    client: true
    debug: false
    compileDebug: false
  "    module.exports = #{func.toString()}"
