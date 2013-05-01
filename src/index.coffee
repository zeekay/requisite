expose =
  Module:     -> require './module'
  Wrapper:    -> require './wrapper'
  bundle:     -> require './bundle'
  cli:        -> require './cli'
  compilers:  -> require './compilers'
  middleware: -> require './middleware'
  minify:     -> require './minify'
  resolve:    -> require './resolve'
  utils:      -> require './utils'
  watch:      -> require './watch'

for k,v of expose
  Object.defineProperty module.exports, k, enumerable: true, get: v
