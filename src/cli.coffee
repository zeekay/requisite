#!/usr/bin/env coffee
fs        = require 'fs'
requisite = require('../lib')

error = (message) ->
  console.log message
  process.exit 1

help = ->
  console.log """

  Usage: requisite [options] [files]

  Options:

    -h, --help                   Display this help
    -v, --version                Display version
    -b, --bare                   Compile without a top-level function wrapper
    -e, --export <name>          Export module as <name>
    -i, --include [module, ...]  Additional modules to include, in <require as>:<path to module> format
    -m, --minify                 Minify output
    -o, --output <file>          Write bundle to file instead of stdout
    -p, --prelude <file>         File to use as prelude, or false to disable
        --no-prelude             Exclude prelude from bundle
    -s, --strict                 Add "use strict" to each bundled module.
    -w, --watch                  Write bundle to file and and recompile on file changes
    -x, --exclude <regex>        Regex to exclude modules from being parsed

  Examples:

    # bundle javascript file and all it's dependencies
    $ requisite module.js

  """
  process.exit 0

version = ->
  console.log require('../package').version
  process.exit 0

opts =
  bare:    false
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
  error 'Output must be specified when using watch'

writeBundle = (bundle) ->
  if opts.output?
    fs.writeFileSync opts.output, bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts

for file in opts.files
  do (file) ->
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
