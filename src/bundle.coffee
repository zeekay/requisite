fs   = require 'fs'
path = require 'path'

module.exports = ({entry, output, libs}) ->
  output = output or "#{entry.replace path.extname(entry), ''}.js"
  libs = libs or []

  bundler = require('./requisite').createBundler
    entry: entry
    prepend: libs

  bundler.bundle (err, content) ->
    fs.writeFile output, content, 'utf8', (err) ->
      throw err if err
