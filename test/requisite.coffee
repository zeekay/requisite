requisite = require '../lib'

describe 'requisite', ->
  describe '#parse', ->
    it 'should parse all dependencies', (done) ->
      console.log()
      requisite.parse './test/assets/entry',
        exclude: /excluded/
        include: ['./included']
      , (err, wrapper) ->
        done()

  describe '#bundle', ->
    it 'should bundle all dependencies', (done) ->
      console.log()
      requisite.bundle './test/assets/entry',
        exclude: /excluded/
        include: ['./included']
      , (err, bundle) ->
        done()
