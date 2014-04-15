path = require 'path'

exports.root = (paths...) ->
  path.join.apply path, [__dirname, '..'].concat paths
