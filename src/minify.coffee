detectMinifier = (minifier) ->
  return 'uglify' if /^uglify/.test minifier

  unless minifier?
    try
      return 'uglify' if require.resolve 'uglify-js'
    catch err

    try
      return 'esmangle' if require.resolve 'esmangle'
    catch err
      throw new Error 'Unable to determine minifier to use'

  minifier

minifiers =
  esmangle: (ast, opts = {}) ->
    esmangle  = require 'esmangle'

    # Compress
    ast = esmangle.optimize ast, null

    # Optionally mangle
    if opts.mangle
      ast = esmangle.mangle ast

    ast

  uglify: (ast, opts = {}) ->
    uglify = require 'uglify-js'

    uast = uglify.AST_Node.from_mozilla_ast ast
    uast.figure_out_scope()

    # Compress
    uast = uast.transform uglify.Compressor
      warnings: false

    # Optionally mangle
    if opts.mangle
      uast.figure_out_scope()
      uast.compute_char_frequency()
      uast.mangle_names()

    uast.to_mozilla_ast()

auto = (ast, opts) ->
  minifier = detectMinifier opts.minifier
  console.log minifier
  minifiers[minifier] ast, opts

wrapper           = auto
wrapper.auto      = auto
wrapper.minifiers = minifiers

module.exports = wrapper
