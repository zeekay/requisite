program = require 'commander'
version = require('../package.json').version

module.exports = ->
  list = (val) -> val.split ','

  program
    .version(version)
    .usage('--entry <input> [-output <output>, --libs <lib1,lib2>]')
    .option('-e, --entry <entry-point>', 'entry point to your code')
    .option('-o, --output <file>', 'where to compile your code to')
    .option('-a, --after <files>', 'files which should be appended to compiled output', list)
    .option('-b, --before <files>', 'files which should be prepended to compiled output', list)
    .option('-p, --no-prelude', 'Do not include prelude')
    .option('-n, --no-require-entry', 'Do not automatically require entry')
    .option('-h, --no-compiler-hooks', 'Do not include scripts injected by compilers (i.e., jade runtime)')
    .option('-m, --minify', 'minify bundled code')
    .parse(process.argv)

  help = ->
    console.log program.helpInformation()
    process.exit()

  help() unless program.entry

  require('./build')(program)
