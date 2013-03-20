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
