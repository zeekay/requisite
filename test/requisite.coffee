requisite = require '../lib'

describe 'requisite', ->
  describe '#bundle', ->
    it 'should bundle all dependencies', (done) ->
      requisite.bundle './test/assets/entry',
        exclude: /excluded/
        include: ['./test/assets/included']
        export: 'entry'
      , (err, bundle) ->
        console.log bundle
        done()

  describe '#parse', ->
    it 'should parse all dependencies', (done) ->
      requisite.parse './test/assets/entry',
        exclude: /excluded/
        include: ['./test/assets/included']
      , (err, wrapper) ->
        done()

  describe '#walk', ->
    it 'should properly recognize all dependencies', (done) ->
      module = new requisite.Module './test/assets/entry',
        exclude: /excluded/
      module.parse ->
        # console.log requisite.walk module
        done()
