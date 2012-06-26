{exec} = require './src/utils'

task 'build', 'Generate docs and compile project', ->
  invoke 'docs'
  invoke 'compile'

task 'compile', 'Compile *.coffee -> *.js', ->
  console.log 'coffee: Compiling src/*.coffee -> lib/*.js'
  exec './node_modules/.bin/coffee -bc -o lib/ src/'

task 'docs', 'Generate docs with docco', ->
  exec './node_modules/.bin/docco-husky src/'

task 'gh-pages', 'Publish docs to gh-pages', ->
  brief  = require 'brief'
  brief.updateGithubPages()

task 'test', 'Run tests', ->
  exec './node_modules/.bin/mocha ./test --compilers coffee:coffee-script -R spec -t 5000 -c'

task 'publish', 'Push to Github and publish current version on NPM', ->
  exec [
    './node_modules/.bin/coffee -bc -o lib/ src/'
    'git push'
    'npm publish'
  ]
