expose =
  Module:    -> require './module'
  Wrapper:   -> require './wrapper'
  bundle:    -> require './bundle'
  cli:       -> require './cli'
  compilers: -> require './compilers'
  minify:    -> require './minify'
  resolve:   -> require './resolve'
  utils:     -> require './utils'

for k,v of expose
  Object.defineProperty module.exports, k, enumerable: true, get: v
