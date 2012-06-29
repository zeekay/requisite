assert        = require 'assert'
createBundler = require '../src/bundle'
fs            = require 'fs'
{existsSync}  = require '../src/utils'
{join}        = require 'path'

# Drop comments and sort content.
normalize = (content, char='\n') ->
  content.split(char)
    .sort()
    .filter((v) -> not (/s*?\/\//.test v) and v.trim())
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
  expected = join __dirname, 'assets', 'expected.js'
  expectedMin = join __dirname, 'assets', 'expected.min.js'

  before ->
    # Create bundlers
    bundler = createBundler
      entry: join __dirname, '/assets/entry'

    bundlerMin = createBundler
      entry: join __dirname, '/assets/entry'
      minify: true

    # Generate dummy npm module if necessary.
    mod = join __dirname, '..', 'node_modules', 'mod'
    if not existsSync mod
      fs.mkdirSync mod
      fs.writeFileSync join(mod, 'index.js'), "module.exports = {x: 42};"

    # Write out expected data.
    if not existsSync expected
      bundler.bundle (err, actualData) ->
        fs.writeFileSync expected, normalize(actualData)

    if not existsSync expectedMin
      bundlerMin.bundle (err, actualData) ->
        fs.writeFileSync expectedMin, normalize(actualData, ';')

  describe 'bundle#bundle()', ->
    it 'bundled JavaScript should match expected', (done) ->
      checkExpected done, bundler, expected

    it 'bundled JavaScript should still match expected after rebundling', (done) ->
      checkExpected done, bundler, expected

    it 'bundled & minified JavaScript should match expected', (done) ->
      checkExpected done, bundlerMin, expected, ';'

    it 'bundled & minified JavaScript should match expected after rebundling', (done) ->
      checkExpected done, bundlerMin, expected, ';'
