fs      = require 'fs'
path    = require 'path'
util    = require 'util'
{spawn} = require 'child_process'

# The location of exists/existsSync changed in node v0.8.0.
if fs.existsSync
  exports.existsSync = existsSync = fs.existsSync
  exports.exists     = fs.exists
else
  exports.existsSync = existsSync = path.existsSync
  exports.exists     = path.exists

# Filter duplicate items from an array, preserving order.
exports.uniq = (arr) ->
  seen = {}
  uniq = []
  for i in arr
    if i not in seen
      seen[i] = true
      uniq.push i
  uniq

# Display error message and quit
exports.fatal = (message, err) ->
  console.error message
  console.trace err.toString().substring 7
  process.exit()

# Concatenate files or strings together
exports.concat = (files, callback) ->
  if not files or files.length == 0
    return callback null, ''

  if not Array.isArray files
    files = [files]

  idx = 0
  concatenated = ''

  iterate = ->
    exports.exists files[idx], (exists) ->
      concat = (body) ->
        idx += 1
        concatenated += body

        if idx == files.length
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
