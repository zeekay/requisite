convert   = require 'convert-source-map'
escodegen = require 'escodegen'

minify    = require './minify'

convertOpts = (opts) ->
  esopts =
    comment: true
    format:
      indent:
        style: '  '
        base: 0
      compact:     false
      escapeless:  true
      parentheses: false
      quotes:      'auto'
      semicolons:  false

  if opts.minify
    esopts =
      comment: false
      format:
        indent:
          style: ''
          base: 0
        compact:     true
        escapeless:  true
        hexadecimal: true
        parentheses: false
        quotes:      'auto'
        renumber:    true
        semicolons:  false

  # Source maps
  if opts.sourceMap
    esopts.sourceMap         = true
    esopts.sourceMapWithCode = true
    esopts.sourceMapRoot     = opts.sourceMapRoot ? opts.sourceRoot ? ''

  # Custom format options
  if opts.format?
    esopts.format = opts.format

  # Allow comments override
  if opts.comment?
    esopts.comment = opts.comment

  esopts

# Generate source code (and optionally source map) from AST
module.exports = (ast, opts = {}) ->
  # Get options for escodegen
  esopts = convertOpts opts

  # Minify
  if opts.minify
    ast = minify ast, opts

  # Generate code, optionally source map
  if opts.sourceMap
    {code, map} = escodegen.generate ast, esopts
  else
    code = escodegen.generate ast, esopts

  # Strip debug comments
  if opts.stripDebug
    # AST generated by acorn doesn't seem to be compatible with the underlying
    # libraries used by strip-debug, so we pass in the generated code instead
    code = require('strip-debug')(code).toString()

  # Return generated code without source map
  unless opts.sourceMap
    return code

  # Return generated code with source map as comment
  unless opts.externalSourceMap
    return code + convert.fromObject(map).toComment()

  # Return object if external source map requested
  if opts.sourceMapURL?
    code += '\n//# sourceMappingURL=' + opts.sourceMapURL

  # Return code, JSON-stringifed map
  code: code
  map:  convert.fromObject(map).toJSON()
