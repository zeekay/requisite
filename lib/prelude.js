var process = {
  title: 'browser',
  browser: true,
  env: {},
  argv: [],
  nextTick: function(fn) { setTimeout(fn, 0); },
  cwd: function() { return '/'; },
  chdir: function() {}
};

// Require module
function require(file, cb) {
  if ({}.hasOwnProperty.call(require.cache, file))
    return require.cache[file];

  // Handle async require
  if (typeof cb == 'function') {
    require.load(file, cb);
    return;
  }

  var resolved = require.resolve(file);
  if (!resolved)
    throw new Error('Failed to resolve module ' + file);

  var module$ = {
    id: file,
    require: require,
    filename: file,
    exports: {},
    loaded: false,
    parent: null,
    children: []
  };

  var dirname = file.slice(0, file.lastIndexOf('/') + 1);

  require.cache[file] = module$.exports;
  resolved.call(module$.exports, module$, module$.exports, dirname, file);
  module$.loaded = true;
  return require.cache[file] = module$.exports;
}

require.modules = {};
require.cache = {};

require.resolve = function(file) {
  return {}.hasOwnProperty.call(require.modules, file) ? require.modules[file] : void 0;
};

// define normal static module
require.define = function(file, fn) {
  require.modules[file] = fn;
};
