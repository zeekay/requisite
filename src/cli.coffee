#!/usr/bin/env coffee
help = ->
  console.log """
  Usage: requisite path/to/entry-module [options]

  Options:
    -b, --bare                   Compile without a top-level function wrapper
    -e, --export  <name>         Export module as <name>
    -h, --help                   Display this help
    -i, --include [modules...]   Additional modules to parse and include
    -p, --prelude <file>         File to use as prelude, or false to disable
    -x, --exclude <regex>        Regex to exclude modules from being parsed
  """
  process.exit(1)

options =
  bare: false
  exclude: null
  export: null
  include: []
  prelude: null

args = process.argv.slice 2

entry = args.shift()

if (not entry?) or entry.charAt(0) == '-'
  help()

while opt = args.shift()
  switch opt
    when '-b', '--bare'
      options.bare = true
    when '-x', '--exclude'
      options.exclude = new RegExp args.shift()
    when '-e', '--export'
      options.export = args.shift()
    when '-p', '--prelude'
      options.prelude = args.shift()
    when '-h', '--help'
      help()
    else
      help()

requisite = require('../lib')

requisite.bundle entry, options, (err, bundle) ->
  throw err if err?

  console.log bundle
