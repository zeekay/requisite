#!/usr/bin/env coffee

help = (code) ->
  console.log """
  Usage: requisite path/to/entry-module [options]

  Options:
    -b, --bare                   Compile without a top-level function wrapper
    -e, --export  <name>         Export module as <name>
    -h, --help                   Display this help
    -i, --include [modules...]   Additional modules to parse and include
    -p, --prelude <file>         File to use as prelude, or false to disable
    -m, --minify                 Minify output
    -x, --exclude <regex>        Regex to exclude modules from being parsed
  """
  process.exit code

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
    when '-i', '--include'
      while (module = args.shift())? and module.charAt(0) != '-'
        options.include.push module
    when '-x', '--exclude'
      options.exclude = new RegExp args.shift()
    when '-e', '--export'
      options.export = args.shift()
    when '-m', '--minify'
      options.minify = args.shift()
    when '-p', '--prelude'
      options.prelude = args.shift()
    when '-h', '--help'
      help 0
    else
      help 1

requisite = require('../lib')

requisite.bundle entry, options, (err, bundle) ->
  throw err if err?

  console.log bundle.toString
    minify: options.minify
