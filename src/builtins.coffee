path = require 'path'

builtins =
  _process:             'process/browser.js'
  _stream_duplex:       'readable-stream/duplex.js'
  _stream_passthrough:  'readable-stream/passthrough.js'
  _stream_readable:     'readable-stream/readable.js'
  _stream_transform:    'readable-stream/transform.js'
  _stream_writable:     'readable-stream/writable.js'
  assert:               'assert/assert.js'
  buffer:               'buffer/index.js'
  child_process:        null
  cluster:              null
  console:              'console-browserify/index.js'
  constants:            'constants-browserify/index.js'
  crypto:               'crypto-browserify/index.js'
  dgram:                null
  dns:                  null
  domain:               'domain-browser/index.js'
  events:               'events/events.js'
  fs:                   null
  http:                 'http-browserify/index.js'
  https:                'https-browserify/index.js'
  module:               null
  net:                  null
  os:                   'os-browserify/browser.js'
  path:                 'path-browserify/index.js'
  punycode:             'punycode/punycode.js'
  querystring:          'querystring-es3/index.js'
  readline:             null
  repl:                 null
  request:              'browser-request/index.js'
  stream:               'stream-browserify/index.js'
  string_decoder:       'string_decoder/index.js'
  sys:                  'util/util.js'
  timers:               'timers-browserify/main.js'
  tls:                  null
  tty:                  'tty-browserify/index.js'
  url:                  'url/url.js'
  util:                 'util/util.js'
  vm:                   'vm-browserify/index.js'
  zlib:                 'browserify-zlib/src/index.js'

basePath  = path.join __dirname, '..', 'node_modules'
emptyPath = path.join __dirname, '..', 'lib/empty.js'

for k,v of builtins
  if v?
    builtins[k] = path.join basePath, v
  else
    builtins[k] = emptyPath

module.exports = builtins
