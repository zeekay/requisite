var process = {
  title: 'browser',
  browser: true,
  env: {},
  argv: [],
  nextTick: function(fn) { setTimeout(fn, 0); },
  cwd: function(){ return '/'; },
  chdir: function(){}
};

// Require module
function require(file, callback) {
  if ({}.hasOwnProperty.call(require.cache, file))
    return require.cache[file];

  // Handle async require
  if (typeof callback == 'function') {
    require.load(file, callback);
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
require.waiting = {};

require.resolve = function(file) {
  return {}.hasOwnProperty.call(require.modules, file) ? require.modules[file] : void 0;
};

// define normal static module
require.define = function(file, fn) {
  require.modules[file] = fn;
};

// define asynchrons module
require.async = function(url, fn) {
  require.modules[url] = fn;

  while (callback = (require.waiting[url] || []).shift())
    callback(require(url));
}

// Load module asynchronously
require.load = function(url, callback) {
  var script = document.createElement('script'),
      existing = document.getElementsByTagName('script')[0],
      callbacks = require.waiting[url] || [];

  // we'll be called when asynchronously defined.
  callbacks.push(callback);

  // load module
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;
  existing.parentNode.insertBefore(script, existing);
}
