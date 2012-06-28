coffee = require 'coffee-script'
fs     = require 'fs'

exports.js = (body, filename) ->
  body

exports.json = (body, filename) ->
  "module.exports = #{body}"

exports.coffee = (body, filename) ->
  coffee.compile body, bare: true, header: false

exports.html = (body, filename) ->
  "module.exports = #{JSON.stringify body}"

require.extensions['.html'] = (module, filename) ->
  body = fs.readFileSync filename, 'utf8'
  module.exports = JSON.stringify body

exports.jade = (body, filename) ->
  jade = require 'jade'
  func = jade.compile body,
    client: true
    debug: false
    compileDebug: false
  "    module.exports = #{func.toString()}"

require.extensions['.jade'] = (module, filename) ->
  jade = require 'jade'
  body = fs.readFileSync filename, 'utf8'
  module.exports = jade.compile body
