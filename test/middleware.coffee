async   = require 'async'
express = require 'express'
fs      = require 'fs'
request = require 'superagent'
should  = require('chai').should()

middleware = require '../lib/middleware'

PORT = 3456

get = (url, callback) ->
  request.get("localhost:#{PORT}#{url}").buffer().end callback

shouldContainModules = (text, files, callback) ->
  async.map files, (file, _callback) ->
    fs.readFile file, 'utf8', (err, data) ->
      throw err if err

      text.should.contain data

      _callback null

  , (err, results) ->
    throw err if err
    callback()

describe 'middleware', ->
  app = null
  before (done) ->
    app = express()
    app.use middleware './test/assets/entry',
      export: 'entry'
    app.listen PORT, -> done()

  it 'should serve entry module', (done) ->
    get '/entry', (res) ->
      res.ok.should.be.ok

      console.log res.text

      shouldContainModules res.text, [
        './test/assets/relative-prop.js'
        './test/assets/relative.js'
      ], -> done()

  it 'should serve async modules', (done) ->
    get '/async-lambda', (res) ->
      res.ok.should.be.ok

      # console.log res.text

      shouldContainModules res.text, [
        # './test/assets/async-lambda.js'
        './test/assets/nested-async.js'
      ], -> done()
