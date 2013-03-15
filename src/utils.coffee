uglify = require 'uglify-js'

module.exports =
  log: ->
    console.log.apply console, arguments

  print: (ast, options = {}) ->
    opts = {}

    unless options.minify
      opts.beautify     = true
      opts.comments     = -> true
      opts.indent_level = 2
      opts.semicolons   = false

    if options.sourceMap
      sourceMap = uglify.SourceMap
        file: options.normalizedPath
        orig: options.sourceMap
      opts.source_map = sourceMap

    if options.minify
      # compress
      compressor = uglify.Compressor()
      ast = ast.transform compressor
      ast.figure_out_scope()

      # mangle
      ast.compute_char_frequency()
      ast.mangle_names()

    stream = uglify.OutputStream opts
    ast.print stream

    if options.sourceMap
      code: stream.toString()
      sourceMap: sourceMap.toString()
    else
      stream.toString()
