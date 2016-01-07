detectMinifier = (minifier = 'esmangle') ->
  return 'uglify' if /^uglify/.test minifier

  try
    return 'uglify' if require.resolve 'uglify-js'
  catch err

  try
    require.resolve 'esmangle'
  catch err
    throw new Error 'Unable to determine minifier to use'

  minifier

minifiers =
  esmangle: (ast) ->
    esmangle  = require 'esmangle'

    optimized = esmangle.optimize ast, null
    mangled   = esmangle.mangle optimized
    mangled

  uglify: (ast) ->
    uglify = require 'uglify-js'

    uglified = uglify.AST_Node.from_mozilla_ast ast
    uglified.figure_out_scope()

    compressor = uglify.Compressor
      warnings: false

    compressed = uglified.transform compressor
    compressed.figure_out_scope()
    compressed.compute_char_frequency()
    compressed.mangle_names()
    compressed.to_mozilla_ast()

auto = (ast, opts) ->
  minifier = detectMinifier opts.minifier
  minifiers[minifier] ast, opts

wrapper           = auto
wrapper.auto      = auto
wrapper.minifiers = minifiers

module.exports = wrapper
