mod =  if parseInt(process.version.substring(3,4), 10) > 6 then 'fs' else 'path'
{existsSync} = require mod

if existsSync __dirname + '/../src'
  require 'coffee-script'
  bundle = require '../src/bundle'
else
  bundle = require './bundle'

bundle.version = require('../package.json').version

module.exports = bundle
