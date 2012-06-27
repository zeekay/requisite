compilers  = require './compilers'
crypto     = require 'crypto'
fs         = require 'fs'
{parse}    = require './ast'

utils      = require './utils'
prettyDate = utils.prettyDate
readFiles  = utils.readFiles

path       = require 'path'
dirname    = path.dirname
extname    = path.extname
join       = path.join

cache = {}

fatal = (message, err) ->
  console.error message
  console.trace err.toString().substring 7
  process.exit()

resolve = (path) ->
  try
    require.resolve path
  catch err
    fatal "Error: Unable to resolve path to '#{path}'", err

find = (entry, callback) ->
  count = 0
  filename = resolve entry

  alias = do ->
    base = dirname(filename).length
    (filename) ->
      if /node_modules/i.test filename
        idx = filename.indexOf '/node_modules'
        base = idx
      name = filename.substring base
      name = name.split('.')
      name.pop()
      name.join('.').replace /\/index$/, ''

  iterate = (filename, as) ->
    file =
      base: dirname filename
      body: ''
      ext: extname(filename).substring 1
      filename: filename
      mtime: null
      aliases: [alias filename]
      requireAs: as
      requires: []
      resolved: []

    if not cache[filename]
      cache[filename] = file

    fs.stat filename, (err, stat) ->
      throw err if err

      # traverse required files
      traverse = (file) ->
        count += file.requires.length

        for require in file.requires
          if /^[./]/.test require
            # this is a relative require
            filename = resolve join(file.base, require)
          else
            # npm module
            filename = resolve require

          file.resolved.push [filename, require]

          # we must go deeper
          iterate filename, require

        if count > 0
          --count
        else
          # done recursing
          callback null, cache

      if (not cache[filename].mtime) or (cache[filename].mtime < stat.mtime)
        file.mtime = stat.mtime

        # Create a unique hash for this file
        shasum = crypto.createHash 'sha1'
        stream = fs.ReadStream filename
        stream.setEncoding 'utf8'

        body = ''

        stream.on 'data', (data) ->
          shasum.update data
          body += data

        stream.on 'end', ->
          file.hash = shasum.digest('hex').substring 0, 10
          try
            body = compilers[file.ext](body, filename)
          catch err
            fatal "Error: Failed to compile #{filename}", err

          if file.ext in ['js', 'coffee']
            file.ast = ast = parse body
            body = ast.toString()
            file.requires = ast.findRequires()

          file.body = body
          traverse file
      else
        # use cached version of the file
        traverse cache[filename]

  iterate filename, entry

# Wraps a required module in a define statement.
wrap = (file, {minify}) ->

  # update require statements
  if file.resolved.length and file.ast
    map = {}
    for [filename, require] in file.resolved
      map[require] = cache[filename].hash
    file.ast.updateRequires(map)
    file.body = file.ast.toString()

  source = file.filename
  aliases = JSON.stringify file.aliases.concat file.hash
  modified = prettyDate file.mtime

  """
  // source: #{source}
  // modified: #{modified}
  require.define(#{aliases}, function (require, module, exports) {(function(){
  #{file.body}
  }).call(this)});
  """
prelude = (err, callback) ->
  filename = resolve __dirname + '/prelude'
  fs.readFile filename, 'utf8', (err, data) ->
    ext = extname(filename).substring 1
    callback err, compilers[ext](data, filename)

# Bundles up client-side JS, traversing from an initial entry point.
bundle = (entry, opts, callback) ->
  if typeof opts is 'function'
    [callback, opts] = [opts, {}]

  find entry, (err, requires) ->
    callback err, (wrap require, opts for _, require of requires).join('\n\n')

exports.createBundler = ({entry, prepend}) ->
  bundler =
    bundle: (opts, callback) ->
      if typeof opts is 'function'
        [callback, opts] = [opts, {}]

      readFiles prepend, (err, a) ->
        prelude (err, b) ->
          bundle entry, opts, (err, c) ->
            throw err if err
            callback err, a + b + c
