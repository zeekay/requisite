requisite = require '../lib'

describe 'requisite', ->
  describe '#walk', ->
    it 'should parse all dependencies', (done) ->
      requisite.walk './test/assets/entry',
        exclude: /excluded/
        include: ['./included']
      , (err, bundle, required, async, excluded) ->
        done()
