module.exports =
  esmangle: (ast) ->
    esmangle  = require 'esmangle'
    escodegen = require 'escodegen'

    compressed = esmangle.mangle (esmangle.optimize ast),
      destructive: yes

    escodegen.generate compressed,
      comment: no
      format:
        indent:
          style: ''
          base: 0
        renumber: yes
        hexadecimal: yes
        quotes: 'auto'
        escapeless: yes
        compact: yes
        parentheses: no
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
