var process = {
  title: 'browser',
  browser: true,
  env: {},
  argv: [],
  nextTick: function(fn) { setTimeout(fn, 0); },
  cwd: function() { return '/'; },
  chdir: function() {}
};

// Require a module
function rqzt(file, callback) {
  if ({}.hasOwnProperty.call(rqzt.cache, file))
    return rqzt.cache[file];

  // Handle async require
  if (typeof callback == 'function') {
    rqzt.load(file, callback);
    return;
  }

  var resolved = rqzt.resolve(file);
  if (!resolved)
    throw new Error('Failed to resolve module ' + file);

  var module$ = {
    id: file,
    rqzt: rqzt,
    filename: file,
    exports: {},
    loaded: false,
    parent: null,
    children: []
  };

  var dirname = file.slice(0, file.lastIndexOf('/') + 1);

  rqzt.cache[file] = module$.exports;
  resolved.call(module$.exports, module$, module$.exports, dirname, file);
  module$.loaded = true;
  return rqzt.cache[file] = module$.exports;
}

rqzt.modules = {};
rqzt.cache = {};

rqzt.resolve = function(file) {
  return {}.hasOwnProperty.call(rqzt.modules, file) ? rqzt.modules[file] : void 0;
};

// Define normal static module
rqzt.define = function(file, fn) {
  rqzt.modules[file] = fn;
};
