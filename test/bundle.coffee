should = require('chai').should()
bundle = require '../lib/bundle'

describe 'bundle', ->
  it 'should bundle all dependencies', (done) ->
    bundle
      entry: './fixtures/entry',
      exclude: /excluded/
      include: ['./fixtures/included']
      export: 'entry'
    , (err, bundle) ->
      done()
