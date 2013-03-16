codegen = (ast, options = {}) ->
  if options.minify
    options =
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
  else
    options =
      comment: yes
      format:
        indent:
          style: '  '
          base: 0
        quotes: 'auto'
        escapeless: yes
        parentheses: no
        compact: no
        semicolons: no

    require('escodegen').generate ast, options

walk = (node, visitor) ->
  if node? and typeof node == 'object'
    unless visitor node
      for k,v of node
        walk v, visitor

  else if Array.isArray node
    for el in node
      walk el, visitor

module.exports =
  codegen: codegen
  walk: walk
