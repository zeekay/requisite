jade = require 'jade'

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
  func = jade.compile body,
    client: true
    debug: false
    compileDebug: false
  "    module.exports = #{func.toString()}"

exports.jade.before = ->
  # Add Jade runtime automatically
  require('fs').readFileSync(require.resolve('jade/runtime.min'), 'utf8')
