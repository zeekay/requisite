{basename, join} = require 'path'
{readdirSync}    = require 'fs'

wrapper = (opts) ->
  require('./bundle') opts

# Lazily export other modules
for mod in readdirSync __dirname
  if not (/prelude|index|wrapper/.test mod)
    do (mod) ->
      name = basename(mod).split('.')[0]
      Object.defineProperty wrapper, name,
        get: -> require join __dirname, mod
        enumerable: true

# Borrow version information from `package.json`.
Object.defineProperty wrapper, 'version',
  get: -> require('../package.json').version
  enumerable: true

module.exports = wrapper
