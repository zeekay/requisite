exec = require('shortcake').exec.interactive
fs   = require 'fs'

task 'build', 'compile src/*.coffee to lib/*.js', (done) ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/', ->
    exec 'node_modules/.bin/coffee -bcm -o .test test/', done

task 'watch', 'watch for changes and recompile project', ->
  exec 'node_modules/.bin/coffee -bcmw -o lib/ src/'
  exec 'node_modules/.bin/coffee -bcmw -o .test test/'

task 'gh-pages', 'Publish github page', ->
  require('brief').update()

task 'test', 'run tests', (options, done) ->
  # link npm test module into node_modules
  if not fs.existsSync 'node_modules/unqualified'
    fs.symlinkSync '../fixtures/node_modules/unqualified', 'node_modules/unqualified'

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
  #{test}", done

task 'publish', 'Publish project', ->
  exec [
    'cake build'
    'git push'
    'npm publish'
  ]

task 'test:watch', 'watch for changes and recompile, re-run tests', (options) ->
  invoke 'build', ->
    invoke 'test', ->
      runningTests = false

      require('vigil').watch __dirname, (filename, stats) ->
        return if runningTests

        if /\.coffee$/.test filename
          if /^test/.test filename
            out = '.test/'
            options.test = ".test/#{path.basename filename.split '.', 1}.js"
          else if /^src/.test filename
            out = (path.dirname filename).replace /^src/, 'lib'
            options.test = '.test'
          else
            console.log 'wut'
            return

          runningTests = true
          exec "node_modules/.bin/coffee -bcm -o #{out} #{filename}", ->
            console.log "#{(new Date).toLocaleTimeString()} - compiled #{filename}"
            invoke 'test', ->
              runningTests = false
