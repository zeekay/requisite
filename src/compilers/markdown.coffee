marked = require 'marked'

module.exports = (options, callback) ->
  marked.setOptions
    gfm: true
    pedantic: false
    smartLists: true
    tables: true

  source = JSON.stringify marked options.source
  callback null, "module.exports = #{source}"
