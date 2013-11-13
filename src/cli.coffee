#!/usr/bin/env coffee
fs        = require 'fs'
requisite = require('../lib')


error = (message) ->
  console.log message
  process.exit 1


help = ->
  console.log """

  Usage: requisite path/to/entry-module [options]

  options:
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
  process.exit 0


version = ->
  console.log require('../package').version
  process.exit 0


args = process.argv.slice 2
entry = args.shift()

opts =
  entry:   entry
  bare:    false
  include: []
  exclude: null
  export:  null
  minify:  false
  output:  null
  prelude: null
  watch:   false

if (not entry?) or entry.charAt(0) == '-'
  if entry in ['-v', '--version']
    version()
  else
    help()

while opt = args.shift()
  switch opt
    when '-b', '--bare'
      opts.bare = true
    when '-i', '--include'
      while (module = args.shift())? and module.charAt(0) != '-'
        try
          [requireAs, absolutePath] = module.split ':'
          opts.include[requireAs] = absolutePath
        catch err
          help 1, 'Invalid argument to include'
    when '-x', '--exclude'
      opts.exclude = new RegExp args.shift()
    when '-e', '--export'
      opts.export = args.shift()
    when '-m', '--minify'
      opts.minify = true
    when '-o', '--output'
      opts.output = args.shift()
    when '-p', '--prelude'
      opts.prelude = args.shift()
    when '-w', '--watch'
      opts.watch = true
    when '-h', '--help'
      help()
    else
      error 'Unknown argument'


if opts.watch and not opts.output?
  error 'Output must be specified when using watch'


writeBundle = (bundle) ->
  if opts.output?
    fs.writeFileSync opts.output, bundle.toString opts, 'utf8'
  else
    console.log bundle.toString opts


requisite.bundle opts, (err, bundle) ->
  writeBundle bundle

  if opts.watch
    requisite.watch opts, ->
      console.log "#{/\d{2}:\d{2}:\d{2}/.exec(new Date())[0]} - recompiling, #{filename} changed"
      writeBundle bundle
