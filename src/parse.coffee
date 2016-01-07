acorn     = require 'acorn'
escodegen = require 'escodegen'

sourceMapToAst = require './sourcemap-to-ast'

# Parse source into ast
module.exports = (source, opts = {}) ->
  comments = []
  tokens   = []

  _opts =
    # for preserving comments
    ranges:     true
    onComment:  comments
    onToken:    tokens

    # for source maps
    locations:  true
    sourceFile: opts.filename

  try
    ast = acorn.parse source, _opts
  catch err
    throw new Error "Failed to parse '#{opts.filename}': #{err.message}"

  escodegen.attachComments ast, comments, tokens

  if opts.sourceMap?
    sourceMapToAst ast, opts.sourceMap

  ast
