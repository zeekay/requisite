exec = require 'executive'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  exec './node_modules/.bin/coffee -bc -m -o lib/ src/'
  console.log 'done'

task 'watch', 'watch for changes and recompile project', ->
  exec './node_modules/.bin/coffee -bc -m -w -o lib/ src/'

task 'gh-pages', 'Publish docs to gh-pages', ->
  brief = require 'brief'
  brief.update()

task 'test', 'Run tests', ->
  exec './node_modules/.bin/mocha test/ --compilers coffee:coffee-script -R spec -t 5000 -c'

task 'publish', 'Publish project', ->
  exec """
     ./node_modules/.bin/coffee -bc -o lib/ src/
     git push
     npm publish
    """.split '\n', ->
    invoke 'gh-pages'
