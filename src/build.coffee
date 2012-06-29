fs   = require 'fs'
path = require 'path'

mkdir = (path, cb) ->
  cb = cb or ->
  mode = 0o777 & (~process.umask())
  fs.mkdir path, mode, (err) ->
    if err?.code is 'ENOENT'
      mkdir path.dirname(path), (err) ->
        mkdir path, (err) ->
          cb null
    cb null

module.exports = ({after, before, entry, output, minify}) ->
  entry = path.resolve entry

  bundler = require('./bundle')
    after: after
    before: before
    entry: entry
    minify: minify

  bundler.bundle (err, content) ->
    if output
      mkdir path.dirname(output), (err) ->
        fs.writeFile output, content, 'utf8', (err) ->
          throw err if err
    else
      console.log content
