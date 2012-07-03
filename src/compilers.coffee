jade = require 'jade'

exports.js = (body, filename) ->
  body

exports.json = (body, filename) ->
  "module.exports = #{body}"

exports.coffee = (body, filename) ->
  coffee = require 'coffee-script'
  coffee.compile body, bare: true, header: false

exports.coffee.error = (err, body, filename) ->
  lineno = /Parse error on line (\d+)/.exec(err.message)[1]
  return err if not lineno

  n = parseInt lineno, 10
  lines = body.split '\n'
  msg = err.message.split(':')
  msg.shift()
  err.message = "#{msg} on line #{n} of #{filename}"

  extra = []
  for i in [n-4..n+3]
    continue if i < 0 or not lines[i]
    extra.push " #{if i+1 == n then '>' else ' '} #{i+1}. #{lines[i]}"

  err.stack = "\n#{extra.join('\n')}\n\n#{err.stack}"
  err

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
