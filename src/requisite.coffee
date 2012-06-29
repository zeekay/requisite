module.exports =
  cli: -> require './cli'
  createBundler: require './bundle'
  version: require('../package.json').version
