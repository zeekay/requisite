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
  it 'should match expected.js', (done) ->
    b.bundle (err, data) ->
      console.log data
      fs.readFile __dirname + '/assets/expected.js', 'utf8', (err, content) ->
        assert.equal data.trim(), content.trim(), 'content is wrong'
        done()
