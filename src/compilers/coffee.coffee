module.exports = (options, callback) ->
  coffee = require 'coffee-script'
  if options.sourceMap
    {js, v3SourceMap} = coffee.compile options.source,
      bare: true
      sourceMap: options.sourceMap
      filename: options.filename
      sourceFiles: [options.filename]
    callback null, js, v3SourceMap
  else
    callback null, (coffee.compile options.source, {bare: true})
