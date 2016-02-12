should = require('chai').should()
bundle = require '../lib/bundle'

opts =
  entry: './fixtures/entry',
  exclude: /excluded/
  include: ['./fixtures/included']
  export: 'entry'

describe 'bundle', ->
  it 'should bundle all dependencies', (done) ->
    bundle opts, (err, bundle) ->
      bundle.toString().should.contain "require.define('./relative'"
      done()

  it 'should bundle all dependencies and return promise', (done) ->
    bundle(opts).then (bundle) ->
      bundle.toString().should.contain "require.define('./relative'"
      done()
