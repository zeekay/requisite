should = require('chai').should()
bundle = require '../lib/bundle'

opts =
  entry:     './fixtures/entry',
  export:    'entry'

  exclude:   /excluded/
  include:   ['./fixtures/included']

  bare:      true
  sourceMap: false

describe 'bundle', ->
  it 'should bundle all dependencies', (done) ->
    bundle opts, (err, bundle) ->
      bundle.toString().should.contain "rqzt.define('./relative'"
      done()
    return

  it 'should bundle all dependencies and return promise', (done) ->
    bundle(opts).then (bundle) ->
      bundle.toString().should.contain "rqzt.define('./relative'"
      done()
    return
