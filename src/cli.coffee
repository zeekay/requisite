#!/usr/bin/env coffee
fs           = require 'fs'
path         = require 'path'
postmortem   = require 'postmortem'
requisite    = require '../lib'
{formatDate} = require '../lib/utils'

error = (message) ->
  console.log message
  process.exit 1

help = ->
  console.log """

  Usage: requisite [options] [files]

  Options:

    -h, --help                   display this help
    -v, --version                display version
    -a, --async                  prelude should support async requires
    -b, --bare                   compile without a top-level function wrapper
    -d, --dedupe                 deduplicate modules (when multiple are specified)
    -e, --export <name>          export module as <name>
    -i, --include <module>       additional module to include, in <require as>:<path to module> format
    -m, --minify                 minify output
    -o, --output <file>          write bundle to file instead of stdout, {} may be used as a placeholder.
    -p, --prelude <file>         file to use as prelude
        --no-prelude             exclude prelude from bundle
        --prelude-only           only output prelude
    -s, --strict                 add "use strict" to each bundled module.
    -w, --watch                  write bundle to file and and recompile on file changes
    -x, --exclude <regex>        regex to exclude modules from being parsed
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
  async:   false
  bare:    false
  base:    null
  dedupe:  false
  exclude: []
  export:  null
  files:   []
  include: []
  minify:  false
  output:  null
  prelude: null
  strict:  false
  watch:   false

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
    when '-d', '--dedupe'
      opts.dedupe = true
    when '-x', '--exclude'
      opts.exclude.push args.shift()
    when '-e', '--export'
      opts.export = args.shift()
    when '-i', '--include'
      [requireAs, absolutePath] = args.shift().split ':'
      opts.include[requireAs] = absolutePath
    when '-m', '--minify'
      opts.minify = true
    when '-o', '--output'
      opts.output = args.shift()
    when '-p', '--prelude'
      opts.prelude = args.shift()
    when '--no-prelude'
      opts.prelude = false
    when '--prelude-only'
      opts.preludeOnly = true
    when '-s', '--strict'
      opts.strict = true
    when '-w', '--watch'
      opts.watch = true
    when '--base'
      opts.base = args.shift()
    else
      error 'Unrecognized option' if opt.charAt(0) is '-'
      opts.files.push opt

unless (opts.files.length or opts.preludeOnly)
  help()

if opts.watch and not opts.output?
  error 'Output must be specified when using watch.'

if opts.files.length > 1 and (opts.output?.indexOf '{}') == -1
  error 'Output filenames overlap, perhaps you meant -o {}.js?'

# If dedupe is chosen, prevent top level modules from being bundled into other
# top level modules.
if opts.dedupe
  for file in opts.files
    extname = path.extname file
    opts.exclude.push "^#{file.replace extname, ''}$"

# Build exclude regex.
opts.exclude = new RegExp opts.exclude.join '|'

outputName = (requiredAs, opts) ->
    # Build output filename
    filename = path.basename bundle.requiredAs
    ext      = path.extname filename
    extout   = path.extname opts.output

    # Prevent duplicating extension
    if ext == extout
      filename = filename.replace ext, ''

    # Handle wildcard output filenames
    opts.output.replace '{}', filename

outputBundle = (bundle, opts) ->
  if opts.output?
    output = outputName bundle.requiredAs, opts
    fs.writeFileSync output, bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts

bundleFile = (file, moduleCache = {}) ->
  opts.entry       = file
  opts.moduleCache = moduleCache

  next = (bundle) ->
    # Write bundle to stdout or output file
    outputBundle bundle, opts

    # If output deduped, only output prelude for first module, pass along moduleCache to each bundle.
    opts.prelude = false if opts.dedupe
    moduleCache  = if opts.dedupe then bundle.moduleCache else {}

    # Handle next file.
    bundleFile opts.files.shift(), moduleCache if opts.files.length

  unless opts.watch
    requisite.bundle opts, (err, bundle) ->
      return postmortem.prettyPrint err if err?

      next bundle
  else
    requisite.watch opts, (err, bundle, filename) ->
      return postmortem.prettyPrint err if err?

      if filename?
        console.log "#{formatDate()} - recompiling, #{filename} changed"
      else
        console.log "#{formatDate()} - compiled #{opts.output}"
      next bundle

bundleFile opts.files.shift()
