path    = require 'path'
resolve = require '../lib/resolve'
should  = require('chai').should()

entryPath = path.resolve './test/assets/entry.coffee'
entryBase = path.dirname entryPath

tests =
  # test entry module
  entry:
    setup:
      requiredAs:     './test/assets/entry'
      requiredBy:     null
      basePath:       null

    result:
      absolutePath:   entryPath
      extension:      '.coffee'
      normalizedPath: 'entry.coffee'
      requireAs:      'entry'

  # test relative required module
  relative:
    setup:
      requiredAs:     './relative'
      requiredBy:     entryPath
      basePath:       entryBase

    result:
      absolutePath:   path.resolve './test/assets/relative.js'
      extension:      '.js'
      normalizedPath: 'relative.js'
      requireAs:      'relative'
      requiredAs:     './relative'

  # test uqualified require module
  unqualified:
    setup:
      requiredAs:     'unqualified'
      requiredBy:     entryPath
      basePath:       entryBase

    result:
      absolutePath:   path.resolve './test/assets/node_modules/unqualified/index.js'
      extension:      '.js'
      normalizedPath: 'node_modules/unqualified/index.js'
      requireAs:      'node_modules/unqualified/index'

  # test a nested module
  nested:
    setup:
      requiredAs:     './nested'
      requiredBy:     path.resolve './test/assets/dir/index.js'
      basePath:       entryBase

    result:
      absolutePath:   path.resolve './test/assets/dir/nested.js'
      extension:      '.js'
      normalizedPath: 'dir/nested.js'
      requireAs:      'dir/nested'

for k, v of tests
  v.result.basePath = path.dirname v.result.absolutePath

describe 'resolve', ->
  for name, test of tests
    do (name, test) ->
      describe "#{name} module", ->
        res = null
        before ->
          res = resolve test.setup.requiredAs,
            requiredBy: test.setup.requiredBy
            basePath:   test.setup.basePath

        it 'should resolve absolute path', ->
          res.absolutePath.should.be.eq test.result.absolutePath

        it 'should resolve base path', ->
          res.basePath.should.be.eq test.result.basePath

        it 'should resolve extension', ->
          res.extension.should.be.eq test.result.extension

        it 'should resolve normalized path', ->
          res.normalizedPath.should.be.eq test.result.normalizedPath

        it 'should resolve value to require as', ->
          res.requireAs.should.be.eq test.result.requireAs
