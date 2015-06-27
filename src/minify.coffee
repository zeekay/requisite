module.exports =
  esmangle: (ast) ->
    esmangle  = require 'esmangle'
    escodegen = require 'escodegen'

    optimized = esmangle.optimize ast, null, destructive: yes
    mangled   = esmangle.mangle optimized,
      destructive: yes

    escodegen.generate mangled,
      comment: no
      format:
        indent:
          style: ''
          base: 0
        compact: yes
        escapeless: yes
        hexadecimal: yes
        parentheses: no
        quotes: 'auto'
        renumber: yes
        semicolons: no

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
    compressed.print_to_string()
