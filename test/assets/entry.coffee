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

# async require with lambda
require './async-lambda', (err, module) ->

# async require with named func
callback = (err, module) ->
require './async-named-func', callback

# async require with method
callbacks =
  method: (err, module) ->
require './async-method', callbacks.method

# require jade template
template = require './jade-template'

# test excludes
excluded = require './excluded'

# this include should also be included
 # included = require './included'
