fs      = require 'fs'
util    = require 'util'
{spawn} = require 'child_process'

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

exports.readFiles = (files, callback) ->
  if not Array.isArray files
    files = [files]

  if files.length == 0
    return callback null, ''

  complete = 0
  concatenated = ''

  iterate = ->
    fs.readFile files[complete], 'utf8', (err, body) ->

      complete += 1
      concatenated += body + '\n\n'

      if complete == files.length
        callback err, concatenated
      else
        iterate()

  iterate()

exports.prettyDate = (dateObj) ->
  date = dateObj.toLocaleDateString()
  time = dateObj.toLocaleTimeString().replace /[0-9]{1,2}(:[0-9]{2}){2}/, (time) ->
    hms = time.split ':'
    h = +hms[0]
    suffix = 'am' if h < 12 or 'pm'
    hms[0] = h % 12 or 12
    hms.join(':')  + ' ' + suffix.toUpperCase()
  date + ' ' + time
exports.inspect = (value) ->
  console.log util.inspect value, false, null, true

exports.exec = (args, callback) ->
  # Simple serial execution of commands, no error handling
  serial = (arr) ->
    complete = 0
    iterate = ->
      exports.exec arr[complete], ->
        complete += 1
        if complete == arr.length
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
