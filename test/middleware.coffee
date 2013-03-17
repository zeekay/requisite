should  = require('chai').should()
request = require 'superagent'
express = require 'express'

middleware = require '../lib/middleware'

describe 'middleware', ->
  app = null
  before (done) ->
    app = express()
    app.use (middleware './test/assets/entry')
    app.listen 3456, ->
      done()

  it 'should serve entry module', (done) ->
    request.get('localhost:3456/entry')
      .buffer()
      .end (res) ->
        res.ok.should.be.ok

        console.log res.text

        done()

  it 'should serve async modules', (done) ->
    request.get('localhost:3456/async-lambda')
      .buffer()
      .end (res) ->
        res.ok.should.be.ok

        console.log res.text

        done()
