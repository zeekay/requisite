
(function() {
  var cache, modules;
  modules = {};
  cache = {};
  this.require = function(alias) {
    var fn, module;
    module = cache[alias];
    if (module) {
      return module.exports;
    }
    fn = modules[alias];
    if (!fn) {
      throw new Error("Module " + alias + " not found");
    }
    module = {
      id: alias,
      exports: {}
    };
    try {
      cache[alias] = module;
      fn(require, module, module.exports);
      return module.exports;
    } catch (err) {
      delete cache[alias];
      throw err;
    }
  };
  return this.require.define = function(aliases, fn) {
    var alias, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = aliases.length; _i < _len; _i++) {
      alias = aliases[_i];
      _results.push(modules[alias] = fn);
    }
    return _results;
  };
})();
