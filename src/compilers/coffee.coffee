formatErrorMessage = (source, filename, err) ->
      {first_line, last_line, first_column, last_column} = err.location

      # get lines from source
      lines = source.split '\n'

      # insert start of highlighting
      l = lines[first_line]
      lines[first_line] = (l.substring 0, first_column) + '\x1B[91m' + l.substring first_column

      # insert end
      l = lines[last_line]

      if first_line == last_line
        # error only spans one line and overlaps with current cursor
        # skip a bit farther due to insertion of highlighting
        col = last_column + 6
      else
        col = last_column

      # end highlighting
      lines[last_line] = (l.substring 0, col) + '\x1B[39m' + (l.substring col)

      # get subset of lines with error to display
      lines = lines.slice first_line, last_line + 1

      # underline with carets
      carets = Array(first_column+1).join(' ')  + "\x1B[91m#{Array(last_column + 2 - first_column).join('^')}\x1B[39m"

      lines.push carets

      """
       #{filename}:#{first_line+1}:#{first_column+1}: #{err.name}: #{err.message}
       #{lines.join '\n'}\n
       """

module.exports = (options, callback) ->
  coffee = require 'coffee-script'

  coffeeOpts =
    bare: true

  if options.sourceMap
    coffeeOpts.sourceMap   = options.sourceMap
    coffeeOpts.filename    = options.filename
    coffeeOpts.sourceFiles = [options.filename]

  try
    res = coffee.compile options.source, coffeeOpts
  catch err
    if err.location?
      err.formattedMessage = formatErrorMessage options.source, options.filename, err
    return callback err

  if res.v3SourceMap?
    {js, v3SourceMap} = res
  else
    [js, v3SourceMap] = [res, undefined]

  callback null, js, v3SourceMap