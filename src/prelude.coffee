# Prelude required by bundled modules.
require = do ->
  modules = {}
  cache = {}

  @require = (alias) ->
    module = cache[alias]
    if module
      return module.exports

    fn = modules[alias]
    if not fn
      throw new Error "Module #{alias} not found"

    module =
      id: alias
      exports: {}

    try
      cache[alias] = module
      fn require, module, module.exports
      module.exports
    catch err
      delete cache[alias]
      throw err

  @require.define = (aliases, fn) ->
    for alias in aliases
      modules[alias] = fn
    return

  @require
