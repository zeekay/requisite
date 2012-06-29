{uglify, parser} = require 'uglify-js'

class AST
  constructor: (src, exigent_mode = false, embed_tokens = false) ->
    if Array.isArray src
      @ast = src
    else
      @ast = parser.parse src, exigent_mode, embed_tokens

  # Find require calls
  findRequires: ->
    requires = []
    @walk
      call: (expr, args) ->
        # if require is being called
        if expr[1] == 'require'
          # we only care about the first argument, which is our requirement
          requires.push args[0][1]
    requires

  # Update require calls using provided map
  updateRequires: (map) ->
    new_ast = @walk
      call: (expr, args) ->
        if expr[1] == 'require'
          # return updated node
          update = map[args[0][1]]
          ['call',
            ['name', 'require'],
              [['string', update]]]
    new AST new_ast

  # Walk AST non-destructively
  walk: (transforms) ->
    w = uglify.ast_walker()
    w.with_walkers transforms, => w.walk @ast

  # Transform AST destructively
  transform: (transforms) ->
    w = uglify.ast_walker()
    @ast = w.with_walkers transforms, => w.walk @ast

  # Minify AST destructively
  kinify: ->
    @ast = uglify.ast_squeeze uglify.ast_mangle @ast
    @

  # Generate code from AST, optionally minifying
  toString: (opts = {}) ->
    if opts.minify
      uglify.gen_code uglify.ast_squeeze uglify.ast_mangle @ast
    else
      uglify.gen_code @ast,
        beautify: opts.beautify or true
        indent_level: opts.indent_level or 2
        indent_start: opts.indent_start or 4

module.exports =
  AST: AST
  parse: (src, exigent_mode, embed_tokens) ->
    new AST src, exigent_mode, embed_tokens
  minify: (src) ->
    # strips trailing semicolon.
    uglify.gen_code(uglify.ast_squeeze uglify.ast_mangle parser.parse src) + ';'
