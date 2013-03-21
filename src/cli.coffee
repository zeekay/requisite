#!/usr/bin/env coffee

fs = require 'fs'
requisite = require('../lib')

writeBundle = (bundle, options) ->
  _options =
    minify: options.minify
    minifer: options.minifer

  if options.output?
    fs.writeFileSync options.output, bundle.toString _options, 'utf8'
  else
    console.log bundle.toString _options

help = (code, message) ->
  console.log """

  Usage: requisite path/to/entry-module [options]

  Options:
    -b, --bare                   Compile without a top-level function wrapper
    -e, --export <name>          Export module as <name>
    -i, --include [module, ...]  Additional modules to include, in <require as>:<path to module> format
    -m, --minify                 Minify output
    -o, --output <file>          Write bundle to file instead of stdout
    -p, --prelude <file>         File to use as prelude, or false to disable
        --no-prelude             Exclude prelude from bundle
    -w, --watch                  Write bundle to file and and recompile on file changes
    -x, --exclude <regex>        Regex to exclude modules from being parsed

    -v, --version                Display version
    -h, --help                   Display this help
  """
  console.log '\n' + message if message
  process.exit code

options =
  bare: false
  exclude: null
  export: null
  include: []
  minify: false
  output: null
  prelude: null
  watch: false

args = process.argv.slice 2

entry = args.shift()

if (not entry?) or entry.charAt(0) == '-'
  if entry in ['-v', '--version']
    console.log require('../package').version
    process.exit 0
  else
    help 1

while opt = args.shift()
  switch opt
    when '-b', '--bare'
      options.bare = true
    when '-i', '--include'
      while (module = args.shift())? and module.charAt(0) != '-'
        try
          [requireAs, absolutePath] = module.split ':'
          options.include[requireAs] = absolutePath
        catch err
          help 1, 'Invalid argument to include'
    when '-x', '--exclude'
      options.exclude = new RegExp args.shift()
    when '-e', '--export'
      options.export = args.shift()
    when '-m', '--minify'
      options.minify = true
    when '-o', '--output'
      options.output = args.shift()
    when '-p', '--prelude'
      options.prelude = args.shift()
    when '-w', '--watch'
      options.watch = true
    when '-h', '--help'
      help 0
    else
      help 1

if options.watch and not options.output?
  help 1, 'Output must be specified when using watch'

requisite.bundle entry, options, (err, bundle) ->
  writeBundle bundle, options

  if options.watch
    requisite.watch bundle, (event, filename, mod) ->
      console.log "#{/\d{2}:\d{2}:\d{2}/.exec(new Date())[0]} - recompiling, #{filename} changed"
      writeBundle bundle, options
