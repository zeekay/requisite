compilers = require './compilers'
crypto    = require 'crypto'
fs        = require 'fs'
{parse}   = require './ast'
{resolve} = require './resolve'

{dirname, extname, join} = require 'path'
{concat, fatal, fmtDate, uniq} = require './utils'

cache = {}

find = (entry, cb) ->
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
      path = join parent.base, require
    else
      # this is an npm module
      path = require

    resolve path, (err, filename) ->
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

      walk = (file) ->
        # we must go deeper
        count += file.requires.length
        for require in file.requires
          iterate require, file

        if count > 0
          --count
        else
          # done recursing
          cb null, cache

      fs.stat filename, (err, stat) ->
        throw err if err

        if (not cache[filename]?.mtime) or (cache[filename].mtime < stat.mtime)
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

            file.ast = parse body
            file.requires = file.ast.findRequires()

            cache[filename] = file
            walk file
        else
          walk cache[filename]

  iterate entry

# Returns bundled up requirements
bundle = (opts, cb) ->
  find opts.entry, (err, requires) ->
    cb err, (wrap require, opts for _, require of requires).join('\n\n')

# Wraps a required module in a define statement.
wrap = (file, opts={}) ->

  # Generate AST with updated require calls.
  map = {}
  for require, filename of file.resolved
    map[require] = cache[filename].hash
  ast = file.ast.updateRequires(map)

  if opts.minify
    "require.define(['#{file.hash}'], function (require, module, exports) {(function(){#{ast.minify().toString(false)}}).call(this)});"
  else
    source = file.filename
    aliases = JSON.stringify file.aliases.concat file.hash
    modified = fmtDate file.mtime
    """
    // source: #{source}
    // modified: #{modified}
    require.define(#{aliases}, function (require, module, exports) {(function(){
    #{ast.toString()}
    }).call(this)});
    """

# Returns prelude file
prelude = (opts, cb) ->
  path = __dirname
  path += if opts.minify then '/prelude-minify' else '/prelude'

  resolve path, (err, filename) ->
    fs.readFile filename, 'utf8', (err, data) ->
      ext = extname(filename).substring 1
      cb err, compilers[ext](data, filename)

module.exports =
  cli: -> require './cli'
  bundle: bundle
  find: find
  wrap: wrap
  createBundler: (opts) ->
    opts.after = opts.after or []
    opts.before = opts.before or []
    bundler =
      bundle: (cb) ->
        concat opts.before, (err, before) ->
          prelude opts, (err, prelude) ->
            bundle opts, (err, bundle) ->
              resolve opts.entry, (err, filename) ->
                opts.after = opts.after.concat """
                // Require entrypoint automatically.
                require(#{JSON.stringify cache[filename].hash});
                """
                concat opts.after, (err, after) ->
                  cb err, [before, prelude, bundle, after].join('\n').trim()
