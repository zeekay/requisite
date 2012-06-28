fs = require 'fs'
{dirname, extname} = require 'path'

mkdir = (path, cb) ->
  cb = cb or ->
  mode = 0o777 & (~process.umask())
  fs.mkdir path, mode, (err) ->
    if err?.code is 'ENOENT'
      mkdir dirname(path), (err) ->
        mkdir path, (err) ->
          cb null
    cb null


module.exports = ({entry, output, libs}) ->
  output = output or "#{entry.replace extname(entry), ''}-bundle.js"
  libs = libs or []

  bundler = require('./requisite').createBundler
    entry: entry
    prepend: libs

  bundler.bundle (err, content) ->
    mkdir dirname(output), (err) ->
      fs.writeFile output, content, 'utf8', (err) ->
        throw err if err
