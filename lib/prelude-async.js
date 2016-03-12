require.waiting = {};

// Generate URL for module
require.urlFor = function(file) {
  var url = file.replace(/^\.?\//, '');

  if (/\.js$/.test(url))
    url = url + '.js';

  return url;
}

// Load module async module
require.load = function(file, cb) {
  // Immediately return previously loaded modules
  if (require.modules[file] != null)
    return cb(require(file))

  // Build URL to request module at
  var url = require.urlFor(file);

  var script = document.createElement('script'),
      existing = document.getElementsByTagName('script')[0],
      callbacks = require.waiting[file] = require.waiting[file] || [];

  // We'll be called when async module is defined.
  callbacks.push(cb);

  // Load module
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;
  script.file = file;
  existing.parentNode.insertBefore(script, existing);
}

// Define async module
require.async = function(file, fn) {
  require.modules[file] = fn;

  var cb;

  while (cb = require.waiting[file].shift())
    cb(require(file));
}
