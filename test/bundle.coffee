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
  after: []
  before: []

minifiedBundler = requisite.createBundler
  entry: __dirname + '/assets/entry'
  after: []
  before: []
  minify: true

# Verify that bundled output matches expected.js
checkExpected = (bundler, expected, done) ->
  bundler.bundle (err, actual) ->
    fs.readFile __dirname + expected, 'utf8', (err, expected) ->
      expected = expected.trim().split('\n')
      actual   = actual.trim().split('\n')
      for line, idx in expected
        if not /^\s*?\/\//.test line
          assert.equal actual[idx], line
      done()

describe 'bundler', ->
  describe '#bundle()', ->
    it 'bundled JavaScript should match expected', (done) ->
      checkExpected(bundler, '/assets/expected.js', done)

    it 'bundled JavaScript should still match expected after rebundling', (done) ->
      checkExpected(bundler, '/assets/expected.js', done)

    it 'bundled & minified JavaScript should match expected', (done) ->
      checkExpected(minifiedBundler, '/assets/expected.min.js', done)

    it 'bundled & minified JavaScript should match expected after rebundling', (done) ->
      checkExpected(minifiedBundler, '/assets/expected.min.js', done)
