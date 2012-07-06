fs            = require 'fs'
should        = require('chai').should()
{existsSync}  = require '../src/utils'
{join}        = require 'path'
{exec}        = require 'child_process'

describe 'cli', ->
  stdout = null
  reqFiles = [
    'require.define(["/a","70f886d883"]'
    'require.define(["/b","8908bb92f8"]'
    'require.define(["/c","318af1af20"]'
    'require.define(["/entry","21568343a3"]'
  ]
  reqDirectories = [
    'require.define(["/test/assets/foo","58c67562d2"]'
  ]
  reqModules = [
    'require.define(["/node_modules/mod","e63313c6a9"]'
  ]
  reqTemplates = [
    'require.define(["/test/assets/template","04e021b689"]'
  ]
  prelude = 'require = (function() {'
  jadeRuntime = 'jade=function(exports){Array.isArray||(Array.isArray=function(arr)'
  callEntry = "require('21568343a3');"
  afterScripts = "alert('after');"
  beforeScripts = "alert('before');"

  before (done) ->
    # Generate dummy npm module if necessary.
    mod = join __dirname, '..', 'node_modules', 'mod'
    if not existsSync mod
      fs.mkdirSync mod
      fs.writeFileSync join(mod, 'index.js'), "module.exports = {x: 42};"

    pathTo = (file) -> join __dirname, file
    cmd = "#{pathTo '../bin/requisite'}
          -e #{pathTo './assets/entry'}
          -b #{pathTo './assets/vendor/before.js'}
          -a #{pathTo './assets/vendor/after.js'}"

    exec cmd, (error, _stdout, stderr) ->
      throw error if error
      throw stderr if stderr
      stdout = _stdout
      done()

  describe 'bundle#bundle()', ->
    it 'should include the appropriate prelude', ->
      stdout.should.have.string prelude

    it 'should find and define all absolute/relatively required files properly', ->
      for str in reqFiles
        stdout.should.have.string str

    it 'should find and define all absolute/relatively required directories properly', ->
      for str in reqDirectories
        stdout.should.have.string str

    it 'should find and define all modules required from node_modules', ->
      for str in reqModules
        stdout.should.have.string str

    it 'should include appropriate vendor scripts after bundled code', ->
      stdout.should.have.string afterScripts

    it 'should include appropriate vendor scripts before bundled code', ->
      stdout.should.have.string beforeScripts

    it 'should find and define all modules required from node_modules', ->
      for str in reqModules
        stdout.should.have.string str

    it 'should find and define all jade templates', ->
      for str in reqTemplates
        stdout.should.have.string str

    it 'should include the jade runtime', ->
      stdout.should.have.string jadeRuntime

    it 'should automatically call the entry module', ->
      stdout.should.have.string callEntry
