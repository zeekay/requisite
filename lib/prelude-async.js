require.waiting = {};

// define asynchrons module
require.async = function(url, fn) {
  require.modules[url] = fn;

  while (cb = require.waiting[url].shift()) cb(require(url));
}

// Load module asynchronously
require.load = function(url, cb) {
  var script = document.createElement('script'),
      existing = document.getElementsByTagName('script')[0],
      callbacks = require.waiting[url] = require.waiting[url] || [];

  // we'll be called when asynchronously defined.
  callbacks.push(cb);

  // load module
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;
  existing.parentNode.insertBefore(script, existing);
}
