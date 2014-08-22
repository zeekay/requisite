#!/usr/bin/env coffee
fs        = require 'fs'
path      = require 'path'
requisite = require '../lib'

error = (message) ->
  console.log message
  process.exit 1

help = ->
  console.log """

  Usage: requisite [options] [files]

  Options:

    -h, --help                   display this help
    -v, --version                display version
    -b, --bare                   compile without a top-level function wrapper
    -d, --dedupe                 deduplicate modules (when multiple are specified)
    -e, --export <name>          export module as <name>
    -i, --include [module, ...]  additional modules to include, in <require as>:<path to module> format
    -m, --minify                 minify output
    -o, --output <file>          write bundle to file instead of stdout, {} may be used as a placeholder.
    -p, --prelude <file>         file to use as prelude
        --no-prelude             exclude prelude from bundle
    -s, --strict                 add "use strict" to each bundled module.
    -w, --watch                  write bundle to file and and recompile on file changes
    -x, --exclude <regex>        regex to exclude modules from being parsed

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
  bare:    false
  dedupe:  false
  exclude: null
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
    when '-b', '--bare'
      opts.bare = true
    when '-d', '--dedupe'
      opts.dedupe = true
    when '-x', '--exclude'
      opts.exclude = new RegExp args.shift()
    when '-e', '--export'
      opts.export = args.shift()
    when '-i', '--include'
      while (module = args.shift())? and module.charAt(0) != '-'
        try
          [requireAs, absolutePath] = module.split ':'
          opts.include[requireAs] = absolutePath
        catch err
          help 1, 'Invalid argument to include'
    when '-m', '--minify'
      opts.minify = true
    when '-o', '--output'
      opts.output = args.shift()
    when '-p', '--prelude'
      opts.prelude = args.shift()
    when '--no-prelude'
      opts.prelude = false
    when '-s', '--strict'
      opts.strict = true
    when '-w', '--watch'
      opts.watch = true
    else
      error 'Unrecognized option' if opt.charAt(0) is '-'
      opts.files.push opt

unless opts.files.length
  help()

if opts.watch and not opts.output?
  error 'Output must be specified when using watch.'

if opts.files.length > 1 and (opts.output.indexOf '{}') == -1
  error 'Output filenames overlap, perhaps you meant -o {}.js?'

writeBundle = (bundle) ->
  if opts.output?
    filename = path.basename bundle.requiredAs
    ext      = path.extname filename
    extout   = path.extname opts.output

    # Prevent duplicating extension
    if ext == extout
      filename = filename.replace ext, ''

    # Handle wildcard output filenames
    output = opts.output.replace '{}', filename

    fs.writeFileSync output, bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts

for file in opts.files
  do (file, opts) ->
    opts = JSON.parse JSON.stringify opts
    opts.entry = file

    unless opts.watch
      requisite.bundle opts, (err, bundle) ->
        writeBundle bundle
    else
      requisite.watch opts, (err, bundle, filename) ->
        if filename?
          console.log "#{/\d{2}:\d{2}:\d{2}/.exec(new Date())[0]} - recompiling, #{filename} changed"
        else
          console.log "#{/\d{2}:\d{2}:\d{2}/.exec(new Date())[0]} - compiled #{opts.output}"

        writeBundle bundle
