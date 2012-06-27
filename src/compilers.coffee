coffee = require 'coffee-script'
fs     = require 'fs'
jade   = require 'jade'
uglify = require('uglify-js').uglify
parser = require('uglify-js').parser

minify = (src) ->
  ast = parser.parse src
  ast = uglify.ast_mangle ast
  ast = uglify.ast_squeeze ast
  uglify.gen_code ast

exports.js = (body, filename) ->
  body

exports.json = (body, filename) ->
  "module.exports = #{body}"

exports.coffee = (body, filename) ->
  coffee.compile body, bare: true, header: false

exports.html = (body, filename) ->
  "module.exports = #{JSON.stringify}"

require.extensions['.html'] = (module, filename) ->
  body = fs.readFileSync filename, 'utf8'
  module.exports = JSON.stringify body

exports.jade = (body, filename) ->
  func = jade.compile body,
    client: true
    debug: false
    compileDebug: false
  "    module.exports = #{minify func.toString()}"

require.extensions['.jade'] = (module, filename) ->
  body = fs.readFileSync filename, 'utf8'
  module.exports = jade.compile body
