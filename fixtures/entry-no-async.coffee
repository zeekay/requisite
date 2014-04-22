# relative require
relative = require './relative'

# relative variable
relativePath = './relative'
require relativePath

# relative require immediately called
relativeCalled = require('./relative-called') 'arg', 'arg2'
require('./relative-called') 'arg', 'arg2'

# relative require with property access
relativeProp = require('./relative-prop').prop

# unqualified require
unqualified = require 'unqualified'

# dir require with nested require
dir = require './dir'

# require jade template
template = require './jade-template'

# test excludes
excluded = require './excluded'

# this include should also be included
# included = require './included'
