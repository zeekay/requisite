Object.defineProperties module.exports,
  coffee:     enumerable: true, get: -> require './coffee'
  cson:       enumerable: true, get: -> require './coffee'
  css:        enumerable: true, get: -> require './css'
  html:       enumerable: true, get: -> require './html'
  jade:       enumerable: true, get: -> require './jade'
  jadeClient: enumerable: true, get: -> require './jade-client'
  js:         enumerable: true, get: -> require './js'
  json:       enumerable: true, get: -> require './json'
  map:        enumerable: true, get: -> require './map'
  markdown:   enumerable: true, get: -> require './markdown'
  sass:       enumerable: true, get: -> require './sass'
  stylus:     enumerable: true, get: -> require './stylus'
  pug:        enumerable: true, get: -> require './pug'
  pugClient:  enumerable: true, get: -> require './pug-client'

  # Various aliases for convenience
  md:         enumerable: true, get: -> require './markdown'
  mkd:        enumerable: true, get: -> require './markdown'
  scss:       enumerable: true, get: -> require './sass'
  styl:       enumerable: true, get: -> require './stylus'
  htm:        enumerable: true, get: -> require './html'
  xml:        enumerable: true, get: -> require './xml'
