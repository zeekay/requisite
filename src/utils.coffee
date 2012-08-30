fs       = require 'fs'
path     = require 'path'
util     = require 'util'
{spawn}  = require 'child_process'
{minify} = require './ast'

# The location of exists/existsSync changed in node v0.8.0.
# Export a few things for compatibility purposes.
if fs.existsSync
  # node v0.8.0+
  exports.existsSync = existsSync = fs.existsSync
  exports.exists     = fs.exists
  exports.sep        = path.sep
else
  # node v0.6.0+
  exports.existsSync = existsSync = path.existsSync
  exports.exists     = path.exists
  if process.platform == 'win32'
    exports.sep = '\\'
  else
    exports.sep = '/'

# Filter duplicate items from an array, preserving order.
exports.uniq = (arr) ->
  seen = {}
  uniq = []
  for i in arr
    if i not in seen
      seen[i] = true
      uniq.push i
  uniq

# detect whether an array of files contains a glob pattern
exports.globRequired = (files) ->
  for file in files
    if '*' in file or '+' in file
      return true
  return false

# find all files
exports.globAll = (patterns, callback) ->
  glob = require 'glob'

  idx = 0
  files = []

  iterate = ->
    if idx == patterns.length
      callback null, files
    else
      pattern = patterns[idx]
      idx += 1

      glob pattern, {nosort: true, silent: true}, (err, _files) ->
        for file in _files
          files.push file
        iterate()
  iterate()

# Concatenate files or strings together
exports.concat = (files, opts, callback) ->
  if not files or files.length == 0
    return callback null, ''

  # passed callback as second argument
  if typeof opts is 'function'
    [opts, callback] = [{}, opts]

  if not Array.isArray files
    files = [files]

    if exports.globRequired files
      exports.globAll files, (err, _files) ->
        throw err if err
        exports.concat _files, opts, callback
      return

  idx = 0
  concatenated = ''

  iterate = ->
    exports.exists files[idx], (exists) ->
      concat = (body) ->
        idx += 1
        concatenated += body

        if idx == files.length
          if opts.minify
            callback null, minify concatenated
          else
            callback null, concatenated
        else
          iterate()

      if exists
        # valid file
        fs.readFile files[idx], 'utf8', (err, body) ->
          throw err if err
          concat body
      else
        # we assume it's a string
        concat files[idx]
  iterate()

# Date -> String formated nicely
exports.fmtDate = (dateObj) ->
  date = dateObj.toLocaleDateString()
  time = dateObj.toLocaleTimeString().replace /[0-9]{1,2}(:[0-9]{2}){2}/, (time) ->
    hms = time.split ':'
    h = +hms[0]
    suffix = 'am' if h < 12 or 'pm'
    hms[0] = h % 12 or 12
    hms.join(':')  + ' ' + suffix.toUpperCase()
  date + ' ' + time

# Deep inspect helper
exports.inspect = (value) ->
  console.log util.inspect value, false, null, true

# Non-blocking exec, merely pipes stdin/stdout.
# May be called with an array of cmds which will
# be executed serially.
exports.exec = (args, callback) ->
  serial = (arr) ->
    idx = 0

    iterate = ->
      exports.exec arr[idx], ->
        idx += 1
        if idx == arr.length
          return
        else
          iterate()
    iterate()

    # passed callback as second argument
    if typeof opts is 'function'
      callback = opts

  if Array.isArray args
    return serial args

  args = args.split(/\s+/g)
  cmd = args.shift()
  proc = spawn cmd, args

  # echo stdout/stderr
  proc.stdout.on 'data', (data) ->
    process.stdout.write data

  proc.stderr.on 'data', (data) ->
    process.stderr.write data

  # callback on completion
  proc.on 'exit', (code) ->
    if typeof callback is 'function'
      callback null, code
