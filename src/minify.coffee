module.exports =
  esmangle: (ast) ->
    esmangle  = require 'esmangle'
    escodegen = require 'escodegen'

    optimized = esmangle.optimize ast, null
    mangled   = esmangle.mangle optimized

    escodegen.generate mangled,
      comment: no
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

  uglifyjs: (ast) ->
    uglify = require 'uglify-js'
    uglified = uglify.AST_Node.from_mozilla_ast ast
    uglified.figure_out_scope()
    compressor = uglify.Compressor
      warnings: false
    compressed = uglified.transform compressor
    compressed.figure_out_scope()
    compressed.compute_char_frequency()
    compressed.mangle_names()
    compressed.print_to_string()
