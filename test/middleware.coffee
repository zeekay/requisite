async   = require 'async'
express = require 'express'
fs      = require 'fs'
request = require 'superagent'
should  = require('chai').should()
require('chai').config.includeStack = true

requisite = require '../'

app = null
before (done) ->
  app = express()
  app.use '/js', requisite.middleware src: './fixtures'
  app.listen 34561, done

get = (url, cb) ->
  request.get('http://localhost:34561' + url).buffer().end cb

shouldContainModules = (text, files, done) ->
  async.map files, (file, cb) ->
    fs.readFile file, 'utf8', (err, data) ->
      return cb err if err?

      text.should.contain data

      cb null

  , done
  return

describe 'middleware', ->
  it 'should serve entry module', (done) ->
    get '/js/entry.js', (err, res) ->
      res.ok.should.be.ok

      shouldContainModules res.text, [
        './fixtures/relative-prop.js'
        './fixtures/relative.js'
      ], done
    return

  it.skip 'should serve async modules', (done) ->
    get '/js/async-lambda.js', (err, res) ->
      res.ok.should.be.ok

      shouldContainModules res.text, [
        './test/assets/async-lambda.js'
        './fixtures/nested-async.js'
      ], done
    return
