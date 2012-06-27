fs = require 'fs'
path = require 'path'
requisite = require '../src'

# make dummy node_module
mod = path.resolve __dirname + '/../node_modules/mod'
if not path.existsSync mod
  fs.mkdirSync mod
  fs.writeFileSync path.join(mod, 'index.js'), "module.exports = {x: 42};"

b = requisite.createBundler
  entry: __dirname + '/assets/entry'
  prepend: []

b.bundle (err, data) ->
  console.log data
