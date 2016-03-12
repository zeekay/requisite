require.waiting = {};

// Determine base path for all modules
var scripts = document.getElementsByTagName('script');
var file = scripts[scripts.length - 1];
require.basePath = file.slice(0, file.lastIndexOf('/') + 1)

// Generate URL for module
require.urlFor = function(file) {
  var url = file.replace(/^\.?\//, '');

  if (/\.js$/.test(url))
    url = url + '.js';

  return require.basePath + url;
}

// Load module async module
require.load = function(file, cb) {
  // Immediately return previously loaded modules
  if (require.modules[file] != null)
    return cb(require(file))

  // Build URL to request module at
  var url = require.urlFor(file);

  var script    = document.createElement('script'),
      scripts   = document.getElementsByTagName('script')[0],
      callbacks = require.waiting[file] = require.waiting[file] || [];

  // We'll be called when async module is defined.
  callbacks.push(cb);

  // Load module
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;
  script.file = file;
  scripts.parentNode.insertBefore(script, scripts);
}

// Define async module
require.async = function(file, fn) {
  require.modules[file] = fn;

  var cb;

  while (cb = require.waiting[file].shift())
    cb(require(file));
}
