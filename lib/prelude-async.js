require.waiting = {};

// define async module
require.async = function(url, fn) {
  require.modules[url] = fn;

  var cb;

  while (cb = require.waiting[url].shift()) cb(require(url));
}

// Load module async module
require.load = function(url, cb) {
  var script = document.createElement('script'),
      existing = document.getElementsByTagName('script')[0],
      callbacks = require.waiting[url] = require.waiting[url] || [];

  // We'll be called when async module is defined.
  callbacks.push(cb);

  // Load module
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;
  existing.parentNode.insertBefore(script, existing);
}
