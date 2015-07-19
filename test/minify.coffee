should = require('chai').should()
bundle = require '../lib/bundle'
minify = require '../lib/minify'

describe 'minify', ->
  describe '#esmangle', ->
    it 'should minify bundle', (done) ->
      bundle
        entry: './fixtures/entry'
        exclude: /excluded/
        include: ['./fixtures/included']
        export: 'entry'
      , (err, bundle) ->
        bundle.toString
          minify: true
          minifier: 'esmangle'
        done()

  describe '#uglify', ->
    it 'should minify bundle', (done) ->
      bundle
        entry: './fixtures/entry'
        exclude: /excluded/
        include: ['./fixtures/included']
        export: 'entry'
      , (err, bundle) ->
        bundle.toString
          minify: true
          minifier: 'uglify-js'
        done()
