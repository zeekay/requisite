{requireTry} = require '../utils'

module.exports = (options, callback) ->
  marked = requireTry 'marked'

  marked.setOptions
    gfm: true
    pedantic: false
    smartLists: true
    tables: true

  source = JSON.stringify marked options.source
  callback null, "module.exports = #{source}"
