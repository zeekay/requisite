#!/usr/bin/env coffee
clone        = require 'clone'
fs           = require 'fs'
path         = require 'path'
toRegex      = require 'to-regexp'

requisite    = require '../lib'
{formatDate} = require '../lib/utils'

error = (message) ->
  console.error message
  process.exit 1

help = ->
  console.log """

  Usage: requisite [options] [files]

  Options:

    -h, --help                   display this help
    -v, --version                display version
    -a, --async                  bundle is expected to be required asynchronously
    -b, --bare                   compile without a top-level function wrapper
    -n, --naked                  compile without a module-level function wrapper
    -d, --dedupe                 deduplicate modules (when multiple are specified)
    -i, --include <module:path>  force inclusion of module found at path
    -g, --global                 make prelude require global
        --export                 automatically export entry module as global
        --no-require             do not automatically require entry module
    -m, --minify                 minify output
        --minifier               minifier to use
    -o, --output <file>          write bundle to file instead of stdout, {} may be used as a placeholder
    -p, --prelude <file>         file to use as prelude
        --prelude-async          include async prelude
        --prelude-only           only output prelude
        --no-prelude             exclude prelude from bundle
    -r, --resolve <module:path>  do not automatically resolve module, use provided path
        --require-as <path>      resolve bundle using providing path
    -s, --skip <path>            skip modules matching path
        --source-map             enable source maps
        --strict                 add "use strict" to each bundled module
        --strip-debug            strip `alert`, `console`, `debugger` statements
    -w, --watch                  write bundle to file and and recompile on file changes
    -x, --exclude <glob|regex>   exclude modules matching glob or regex from being automatically parsed
        --base                   path all requires should be relative to

  Examples:

    # bundle javascript file and all it's dependencies
    $ requisite module.js -o bundle.js

    # bundle several modules, appending .bundle.js to output
    $ requisite *.js -o {}.bundle.js
  """
  process.exit 0

version = ->
  console.log require('../package').version
  process.exit 0

opts =
  async:        false
  bare:         false
  base:         null
  dedupe:       false
  exclude:      []
  exported:     null
  files:        []
  include:      {}
  minify:       false
  naked:        false
  output:       []
  prelude:      null
  preludeAsync: null
  required:     true
  resolved:     {}
  skip:         []
  sourceMap:    false
  strict:       false
  stripDebug:   false
  watch:        false

args = process.argv.slice 2

while opt = args.shift()
  switch opt
    when '-h', '--help'
      help()
    when '-v', '--version'
      version()
    when '-a', '--async'
      opts.async = true
    when '-b', '--bare'
      opts.bare = true
    when '-n', '--naked'
      opts.bare  = true
      opts.naked = true
    when '-d', '--dedupe'
      opts.dedupe = true
    when '-g', '--global'
      opts.globalRequire = true
    when '-x', '--exclude'
      opts.exclude.push args.shift()
    when '-s', '--skip'
      opts.skip.push args.shift()
    when '--no-require'
      opts.required = false
    when '--export'
      opts.exported = true
    when '-i', '--include'
      opts.include ?= {}
      [requireAs, absolutePath] = args.shift().split ':'
      opts.include[requireAs] = absolutePath
    when '-m', '--minify'
      opts.minify = true
    when '--minifier'
      opts.minifier = args.shift()
    when '-o', '--output'
      opts.output.push args.shift()
    when '-p', '--prelude'
      opts.prelude = args.shift()
    when '--no-prelude'
      opts.prelude = false
    when '--source-map'
      opts.sourceMap = true
    when '--prelude-async', '--async-prelude'
      opts.includeAsync = true
    when '--prelude-only'
      opts.preludeOnly = true
    when '-r', '--resolve'
      [requireAs, modulePath]  = args.shift().split ':'
      opts.resolved[requireAs] = modulePath
    when '--require-as'
      opts.requireAs = args.shift()
    when '-s', '--strict'
      opts.strict = true
    when '--strip-debug'
      opts.stripDebug = true
    when '-w', '--watch'
      opts.watch = true
    when '--base'
      opts.base = args.shift()
    else
      error "Unrecognized option: '#{opt}'" if opt.charAt(0) is '-'
      opts.files.push opt

unless (opts.files.length or opts.preludeOnly)
  help()

if opts.watch and not opts.output.length
  error 'Output must be specified when using watch.'

# check that we have distinct outputs
if opts.files.length > 1 and (opts.output.indexOf '{}') == -1
  seen = {}
  for out in opts.output
    if seen[out]?
      error 'Output filenames overlap, perhaps you meant -o {}.js?'
    seen[out] = true

# If dedupe is chosen, prevent top level modules from being bundled into other
# top level modules.
if opts.dedupe
  for file in opts.files
    extname = path.extname file
    opts.exclude.push "^#{file.replace extname, ''}$"

# Build exclude regex.
if opts.exclude.length > 0
  opts.exclude = toRegex opts.exclude

outputName = (filename, output) ->
  # Handle wildcard output filenames
  output.replace '{}', filename
        .replace /\.\w+$/, '.js'
        .replace /\.\/\//, ''

outputBundle = (bundle, opts) ->
  if opts.output?
    fs.writeFileSync (outputName bundle.normalizedPath, opts.output), bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts

bundleFile = (file, moduleCache = {}) ->
  return unless file?

  _opts = clone opts
  _opts.entry       = file
  _opts.moduleCache = moduleCache
  _opts.output      = opts.output.shift()
  _opts.prelude     = false if _opts.dedupe

  unless opts.watch
    requisite.bundle _opts, (err, bundle) ->
      return console.error (err.formattedMessage ? err.stack) if err?

      outputBundle bundle, _opts
      moduleCache = if opts.dedupe then bundle.moduleCache else {}
      bundleFile opts.files.shift(), moduleCache
  else
    requisite.watch _opts, (err, bundle, filename) ->
      return console.error (err.formattedMessage ? err.stack) if err?

      if filename?
        console.log "#{formatDate()} - recompiling, #{filename} changed"
      else
        console.log "#{formatDate()} - compiled #{outputName bundle.normalizedPath, _opts.output}"

      outputBundle bundle, _opts
      moduleCache = if opts.dedupe then bundle.moduleCache else {}
      bundleFile opts.files.shift(), moduleCache

bundleFile opts.files.shift()
