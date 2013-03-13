requisite = require '../lib'

log = ->
  console.log.apply console, arguments

describe 'requisite', ->
  describe '#walk', ->
    it 'should successfully parse all dependencies', (done) ->
      log()

      requisite.walk './test/assets/entry',
        exclude: /excluded/
        include: ['included']
      , (err, bundle, required, async, excluded) ->
        log '\ndependencies:'
        log v.absolutePath for k, v of required

        log '\nasync modules:'
        log v.requireAs for k, v of async

        log '\nexcluded modules:'
        log v.absolutePath for k, v of excluded

        done()
