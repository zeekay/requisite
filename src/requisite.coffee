compilers = require './compilers'
crypto    = require 'crypto'
fs        = require 'fs'
{resolve} = require './resolve'
{parse}   = require './ast'

{dirname, extname, join} = require 'path'
{fatal, prettyDate, readFiles, uniq} = require './utils'

cache = {}

findDependencies = (entry, callback) ->
  count = 0

  alias = do ->
    base = dirname(entry).length
    (filename) ->
      filename = filename.replace(/\\/g, '/')
      if /node_modules/i.test filename
        idx = filename.indexOf '/node_modules'
        base = idx
      name = filename.substring base
      name = name.split('.')
      name.pop()
      name.join('.').replace /\/index$/, ''

  iterate = (require, parent) ->
    if parent and /^[./]/.test require
      # this is a relative require
      requirePath = join parent.base, require
    else
      # this is an npm module
      requirePath = require

    resolve requirePath, (err, filename) ->
      if parent
        # Add to parent's map of resolved modules
        parent.resolved[require] = filename

      file =
        base: dirname filename
        body: ''
        ext: extname(filename).substring 1
        filename: filename
        mtime: null
        aliases: [alias filename]
        requireAs: require
        requires: []
        resolved: {}

      fs.stat filename, (err, stat) ->
        throw err if err

        if (not cache[filename]?.mtime) or (cache[filename].mtime < stat.mtime)
          console.log "#{filename} not cached"
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

            cache[filename] = file

            # we must go deeper
            count += file.requires.length
            for require in file.requires
              iterate require, file

            if count > 0
              --count
            else
              # done recursing
              callback null, cache
        else
          file = cache[filename]

          # we must go deeper
          count += file.requires.length
          for require in file.requires
            iterate require, file

          if count > 0
            --count
          else
            # done recursing
            callback null, cache

  iterate entry

# Wraps a required module in a define statement.
wrap = (file) ->
  if Object.keys(file.resolved).length and file.ast
    # Update require calls
    map = {}
    for require, filename of file.resolved
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

prelude = (callback) ->
  resolve __dirname + '/prelude', (err, filename) ->
    fs.readFile filename, 'utf8', (err, data) ->
      ext = extname(filename).substring 1
      callback err, compilers[ext](data, filename)

# Bundles up client-side JS, traversing from an initial entry point.
bundle = (entry, opts, callback) ->
  findDependencies entry, (err, requires) ->
    callback err, (wrap require, opts for _, require of requires).join('\n\n')

exports.cli = -> require './cli'

exports.createBundler = ({entry, prepend}) ->
  bundler =
    bundle: (opts, callback) ->
      if typeof opts is 'function'
        [callback, opts] = [opts, {}]

      readFiles prepend, (err, a) ->
        prelude (err, b) ->
          bundle entry, opts, (err, c) ->
            cache = {}
            callback err, a + b + c
