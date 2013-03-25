should = require('chai').should()
bundle = require '../lib/bundle'

describe 'bundle', ->
  it 'should bundle all dependencies', (done) ->
    bundle './test/assets/entry',
      exclude: /excluded/
      include: ['./test/assets/included']
      export: 'entry'
    , (err, bundle) ->
      done()
