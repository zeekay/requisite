assert = require 'assert'

fs = require 'fs'
path = require 'path'
requisite = require '../src'

# make dummy node_module
mod = path.resolve __dirname + '/../node_modules/mod'
if not path.existsSync mod
  fs.mkdirSync mod
  fs.writeFileSync path.join(mod, 'index.js'), "module.exports = {x: 42};"

bundler = requisite.createBundler
  entry: __dirname + '/assets/entry'

bundlerM = requisite.createBundler
  entry: __dirname + '/assets/entry'
  minify: true

# Verify that bundled output matches expected.js
checkExpected = (b, expected, done) ->
  fs.readFile __dirname + expected, 'utf8', (err, expectedData) ->
    b.bundle (err, actualData) ->
      e = expectedData.trim().split('\n')
      a = actualData.trim().split('\n')
      for line, idx in e
        if not /^\s*?\/\//.test line
          assert.equal a[idx], line
      done()

describe 'bundler', ->
  describe '#bundle()', ->
    it 'bundled JavaScript should match expected', (done) ->
      checkExpected bundler, '/assets/expected.js', done

    it 'bundled JavaScript should still match expected after rebundling', (done) ->
      checkExpected bundler, '/assets/expected.js', done

    it 'bundled & minified JavaScript should match expected', (done) ->
      checkExpected bundlerM, '/assets/expected.min.js', done

    it 'bundled & minified JavaScript should match expected after rebundling', (done) ->
      checkExpected bundlerM, '/assets/expected.min.js', done
