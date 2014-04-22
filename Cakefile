exec = require 'executive'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcm -o .test test/'

task 'watch', 'watch for changes and recompile project', ->
  exec 'node_modules/.bin/coffee -bcmw -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcmw -o .test test/'

task 'gh-pages', 'Publish github page', ->
  require('brief').update()

task 'test', 'run tests', (options) ->
  test = options.test ? '.test'
  if options.grep?
    grep = "--grep #{options.grep}"
  else
    grep = ''

  exec "NODE_ENV=test node_modules/.bin/mocha
  --colors
  --reporter spec
  --timeout 5000
  --compilers coffee:coffee-script/register
  --require postmortem/register
  #{grep}
  #{test}"

task 'publish', 'Publish project', ->
  exec [
    'cake build'
    'git push'
    'npm publish'
  ]
