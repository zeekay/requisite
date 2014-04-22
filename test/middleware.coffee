async   = require 'async'
express = require 'express'
fs      = require 'fs'
request = require 'superagent'
should  = require 'should'

middleware = require '../lib/middleware'

PORT = 34561

get = (url, cb) ->
  request.get "localhost:#{PORT}#{url}", cb

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
    app.use middleware entry: './test/assets/entry'
    app.listen PORT, -> done()

  it 'should serve entry module', (done) ->
    get '/entry.js', (res) ->
      console.log res.text

      res.ok.should.be.ok

      shouldContainModules res.text, [
        './test/assets/relative-prop.js'
        './test/assets/relative.js'
      ], -> done()

  it 'should serve async modules', (done) ->
    get '/async-lambda.js', (res) ->
      console.log res.text

      res.ok.should.be.ok

      # console.log res.text

      shouldContainModules res.text, [
        # './test/assets/async-lambda.js'
        './test/assets/nested-async.js'
      ], -> done()
