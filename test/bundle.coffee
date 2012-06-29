assert = require 'assert'

fs = require 'fs'
path = require 'path'
requisite = require '../src'

# make dummy node_module
mod = path.resolve __dirname + '/../node_modules/mod'
if not path.existsSync mod
  fs.mkdirSync mod
  fs.writeFileSync path.join(mod, 'index.js'), "module.exports = {x: 42};"

b = requisite.createBundler
  entry: __dirname + '/assets/entry'
  prepend: []

describe 'bundler', ->
  describe '#bundle()', ->
    it 'should match expected.js', (done) ->
      b.bundle (err, actual) ->
        fs.readFile __dirname + '/assets/expected.js', 'utf8', (err, expected) ->
          expected = expected.trim().split('\n')
          actual   = actual.trim().split('\n')
          for line, idx in expected
            if not /^\s*?\/\//.test line
              assert.equal actual[idx], line, "Line #{idx+1} does not match"
          done()
