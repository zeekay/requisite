createBundler = require '../src/bundle'
fs            = require 'fs'
should        = require('chai').should()
{existsSync}  = require '../src/utils'
{join}        = require 'path'

describe 'bundle', ->
  # Declare bundlers in outer scope so tests have access to them.
  bundler = null
  bundleContent = null

  before (done) ->
    # Create bundlers
    bundler = createBundler
      entry: join __dirname, '/assets/entry'

    # Generate dummy npm module if necessary.
    mod = join __dirname, '..', 'node_modules', 'mod'
    if not existsSync mod
      fs.mkdirSync mod
      fs.writeFileSync join(mod, 'index.js'), "module.exports = {x: 42};"

    bundler.bundle (err, content) ->
      throw err if err
      bundleContent = content
      done()

  describe 'bundle#bundle()', ->
    it 'should find and define all absolute/relatively required modules properly', ->
      required = '''
        require.define(["/a","70f886d883"]
        require.define(["/b","8908bb92f8"]
        require.define(["/c","318af1af20"]
        require.define(["/test/assets/foo","58c67562d2"]
        require.define(["/test/assets/template","04e021b689"]
        require.define(["/entry","21568343a3"]
        '''.split('\n')

      for define in required
        bundleContent.should.have.string define

    it 'should find and define all modules required from node_modules', ->
      bundleContent.should.have.string 'require.define(["/node_modules/mod","e63313c6a9"]'

    it 'should include the jade runtime', ->
      bundleContent.should.have.string 'jade=function(exports){Array.isArray||(Array.isArray=function(arr){'
