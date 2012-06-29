assert = require 'assert'

fs = require 'fs'
path = require 'path'
requisite = require '../src'

# make dummy node_module
mod = path.resolve __dirname + '/../node_modules/mod'
if not path.existsSync mod
  fs.mkdirSync mod
  fs.writeFileSync path.join(mod, 'index.js'), "module.exports = {x: 42};"

# Create bundlers
bundler = requisite.createBundler
  entry: __dirname + '/assets/entry'

bundlerMin = requisite.createBundler
  entry: __dirname + '/assets/entry'
  minify: true

# Write out expected data.
# bundler.bundle (err, actualData) ->
#   fs.writeFileSync __dirname + '/assets/expected.js', actualData.split('\n').sort().join('\n').trim()

# bundlerM.bundle (err, actualData) ->
#   fs.writeFileSync __dirname + '/assets/expected.min.js', actualData.split(';').sort().join(';').trim()

# Verify that bundled output matches expected.js
checkExpected = (done) ->
  fs.readFile __dirname + '/assets/expected.js', 'utf8', (err, expectedData) ->
    bundler.bundle (err, actualData) ->
      assert.equal actualData.split('\n').sort().join('\n').trim(), expectedData.trim()
      done()

checkExpectedMin = (done) ->
  fs.readFile __dirname + '/assets/expected.min.js', 'utf8', (err, expectedData) ->
    bundlerMin.bundle (err, actualData) ->
      assert.equal actualData.split(';').sort().join(';').trim(), expectedData.trim()
      done()

describe 'bundler', ->
  describe '#bundle()', ->
    it 'bundled JavaScript should match expected', (done) ->
      checkExpected done

    it 'bundled JavaScript should still match expected after rebundling', (done) ->
      checkExpected done

    it 'bundled & minified JavaScript should match expected', (done) ->
      checkExpectedMin done

    it 'bundled & minified JavaScript should match expected after rebundling', (done) ->
      checkExpectedMin done
