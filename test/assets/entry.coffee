a = require './a'
b = require './b'
c = -> require './c'

module.exports =
  a: a
  b: b
  c: c()

template = require './template'
