program = require 'jade/node_modules/commander'
version = require('../package.json').version

program
  .version(version)
  .usage('-i <input> -o <output> -t <template>')
  .option('-i, --input <file>', 'markdown file to use as input')
  .option('-o, --output <file>', 'where to output rendered content')
  .option('-t, --template <file>', 'jade template to use')
  .parse(process.argv)

help = ->
  console.log program.helpInformation()
  process.exit()

help() if !program.template or !program.input or !program.output
