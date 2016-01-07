{SourceMapConsumer} = require 'source-map'
{traverse}          = require 'estraverse'

module.exports = (ast, map) ->
  map = new SourceMapConsumer(map)

  traverse ast, enter: (node) ->
    unless node.type and node.loc
      return

    origStart = map.originalPositionFor node.loc.start

    if !origStart.line
      delete node.loc
      return

    origEnd = map.originalPositionFor node.loc.end

    if origEnd.line and (origEnd.line < origStart.line or origEnd.column < origStart.column)
      origEnd.line = null

    node.loc =
      start:
        line: origStart.line
        column: origStart.column
      source: origStart.source
      name: origStart.name

    if origEnd.line
      node.loc.end =
        line: origEnd.line
        column: origEnd.column

    return
  ast
