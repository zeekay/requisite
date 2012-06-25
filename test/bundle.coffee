fs = require 'fs'
path = require 'path'
mandala = require '../src'

# make dummy node_module
mod = path.resolve __dirname + '/../node_modules/mod'
if not path.existsSync mod
  fs.mkdirSync mod
  fs.writeFileSync path.join(mod, 'index.js'), "module.exports = {x: 42};"

b = mandala.createBundle
  entry: __dirname + '/app/entry'
  prepend: []

b.bundle (err, data) ->
  console.log data
