rqzt.waiting = {};

// Determine base path for all modules
var scripts = document.getElementsByTagName('script');
var file = scripts[scripts.length - 1].src;
rqzt.basePath = file.slice(0, file.lastIndexOf('/') + 1)

// Generate URL for module
rqzt.urlFor = function(file) {
  var url = file.replace(/^\.?\//, '');

  if (!/\.js$/.test(url))
    url = url + '.js';

  return rqzt.basePath + url;
}

// Load module async module
rqzt.load = function(file, cb) {
  // Immediately return previously loaded modules
  if (rqzt.modules[file] != null)
    return cb(rqzt(file))

  // Build URL to request module at
  var url = rqzt.urlFor(file);

  var script    = document.createElement('script'),
      scripts   = document.getElementsByTagName('script')[0],
      callbacks = rqzt.waiting[file] = rqzt.waiting[file] || [];

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
rqzt.async = function(file, fn) {
  rqzt.modules[file] = fn;

  var cb;

  while (cb = rqzt.waiting[file].shift())
    cb(rqzt(file));
}
