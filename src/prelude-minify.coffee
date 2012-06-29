# Prelude required by bundled modules.
do ->
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

  @require.define = (alias, fn) ->
    modules[alias] = fn
