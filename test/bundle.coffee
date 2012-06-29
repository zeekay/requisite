assert          = require 'assert'
fs              = require 'fs'
createBundler   = require '../src/bundle'
{existsSync}    = require '../src/utils'
{resolve, join} = require 'path'

# Drop comments and sort content.
normalize = (content, char='\n') ->
  content.split(char)
    .sort()
    .filter((v) -> /s*?\/\//.test v and v.trim())
    .join(char)

# Verify that generated output matches expected output.
checkExpected = (done, bundler, expected, char='\n') ->
  fs.readFile expected, 'utf8', (err, expectedData) ->
    bundler.bundle (err, actualData) ->
      assert.equal normalize(actualData), expectedData
      done()

describe 'bundle', ->
  # Declare bundlers in outer scope so tests have access to them.
  bundler = null
  bundlerMin = null

  before ->
    # Create bundlers
    bundler = createBundler
      entry: __dirname + '/assets/entry'

    bundlerMin = createBundler
      entry: __dirname + '/assets/entry'
      minify: true

    # Generate dummy npm module if necessary.
    mod = resolve __dirname + '/../node_modules/mod'
    if not existsSync mod
      fs.mkdirSync mod
      fs.writeFileSync join(mod, 'index.js'), "module.exports = {x: 42};"

    # Write out expected data.
    if not existsSync __dirname + '/assets/expected.js'
      bundler.bundle (err, actualData) ->
        fs.writeFileSync __dirname + '/assets/expected.js', normalize(actualData)

    if not existsSync __dirname + '/assets/expected.min.js'
      bundlerMin.bundle (err, actualData) ->
        fs.writeFileSync __dirname + '/assets/expected.min.js', normalize(actualData, ';')

  describe 'bundle#bundle()', ->
    it 'bundled JavaScript should match expected', (done) ->
      checkExpected done, bundler, __dirname + '/assets/expected.js'

    it 'bundled JavaScript should still match expected after rebundling', (done) ->
      checkExpected done, bundler, __dirname + '/assets/expected.js'

    it 'bundled & minified JavaScript should match expected', (done) ->
      checkExpected done, bundlerMin, __dirname + '/assets/expected.min.js', ';'

    it 'bundled & minified JavaScript should match expected after rebundling', (done) ->
      checkExpected done, bundlerMin, __dirname + '/assets/expected.min.js', ';'
