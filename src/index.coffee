Object.defineProperties module.exports,
  Module:     enumerable: true, get: -> require './module'
  Wrapper:    enumerable: true, get: -> require './wrapper'
  bundle:     enumerable: true, get: -> require './bundle'
  cli:        enumerable: true, get: -> require './cli'
  compilers:  enumerable: true, get: -> require './compilers'
  middleware: enumerable: true, get: -> require './middleware'
  minify:     enumerable: true, get: -> require './minify'
  resolve:    enumerable: true, get: -> require './resolve'
  utils:      enumerable: true, get: -> require './utils'
  watch:      enumerable: true, get: -> require './watch'
  version:    enumerable: true, get: -> (require '../package.json').version
