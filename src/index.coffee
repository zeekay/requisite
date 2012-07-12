{basename, resolve} = 'path'
{existsSync} = require './utils'

# This is a bit of a hack, if `../src` exists then assume we're being required
# from the git repo. To make development a bit easier we'll require the
# uncompiled version of the project. In normal production use `../src` will
# be missing since it's in `.npmignore`.
if existsSync __dirname + '/../src'
  require 'coffee-script'
  mod = require "../src/wrapper"
else
  mod = require "./wrapper"

module.exports = mod
