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

module.exports = (opts) ->
  # Get full path to entry
  opts.entry = path.resolve opts.entry

  # Create bundler with our opts
  bundler = require('./bundle')(opts)

  # Bundle Javascript, output to file if opts.output or stdout
  bundler.bundle (err, content) ->
    if opts.output
      mkdir path.dirname(opts.output), (err) ->
        fs.writeFile opts.output, content, 'utf8', (err) ->
          throw err if err
    else
      console.log content
