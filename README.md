# requisite [![NPM version][npm-img]][npm-url] [![Build Status][travis-img]][travis-url] [![Coverage Status][coveralls-img]][coveralls-url] [![Dependency Status][dependency-img]][dependency-url] [![Gitter chat][gitter-img]][gitter-url]

[![Greenkeeper badge](https://badges.greenkeeper.io/zeekay/requisite.svg)](https://greenkeeper.io/)

## Introduction
Requisite bundles client-side code and templates. It features asynchronous
module loading for optimal performance of large applications,
[CoffeeScript][coffeescript] and [Jade][jade] language support out of the box
and comes with a [connect][connect]/[express][express] middleware for rapid
development.

## Features
- Use CommonJS modules in the browser.
- Customizable compiler/preprocessors.
- Simple API for programmatic usage.
- Lazy asset loading.
- Resolves relative as well as npm modules.
- Command line tool for bundling simple projects.
- Good Source map support.

## Install
```bash
npm install -g requisite
```

## Modules
Requiste allows you to structure your code using [CommonJS (Node.js)
modules][commonjs]. From a given starting point or entry module, requisite will
trace your application's dependencies and bundle all `require`'ed modules
together. Requiste's `require` supports asynchronous loading of assets/modules
when an optional callback argument is provided.

```javascript
// foo.js
module.exports = 'foo';

// async-bar.js
module.exports = 'bar'

// entry.js
console.log(require('./foo'))  // 'foo'
require('./async-bar', function(bar) {
    console.log(bar) // 'bar'
})
```

This compiles down to:

```javascript
// ...prelude, defining require, etc.

require.define('/foo', function (module, exports, __dirname, __filename) {
    module.exports = 'foo';
})

require.define('/main', function (module, exports, __dirname, __filename) {
    console.log(require('/foo'));
    require('/async-bar', function(bar) {
        console.log(bar);
    })
})
```

Note how `async-bar.js` is missing from the bundle, as it's loaded at runtime.

If you are writing a module that can be used both client/server side you can
define the [`browser`](browser-field) field in your package.json and finetune which bits will be
bundled for the client.

## Usage
### CLI
```bash
› requisite

Usage: requisite [options] [files]

Options:

  -h, --help                   display this help
  -v, --version                display version
  -a, --async                  prelude should support async requires
  -b, --bare                   compile without a top-level function wrapper
  -d, --dedupe                 deduplicate modules (when multiple are specified)
  -e, --export <name>          export module as <name>
  -i, --include <module>       additional module to include, in <require as>:<path to module> format
  -g, --global                 global require
  -m, --minify                 minify output
      --minifier               minifier to use
  -o, --output <file>          write bundle to file instead of stdout, {} may be used as a placeholder
  -p, --prelude <file>         file to use as prelude
      --no-prelude             exclude prelude from bundle
      --no-source-map          disable source maps
      --prelude-only           only output prelude
  -s, --strict                 add "use strict" to each bundled module
      --strip-debug            strip `alert`, `console`, `debugger` statements
  -w, --watch                  write bundle to file and and recompile on file changes
  -x, --exclude <regex>        regex to exclude modules from being parsed
      --base                   path all requires should be relative to

Examples:

  # bundle javascript file and all it's dependencies
  $ requisite module.js -o bundle.js

  # bundle several modules, appending .bundle.js to output
  $ requisite *.js -o {}.bundle.js
```

#### Examples
Bundle a javascript file and all it's dependencies:
```
$ requisite module.js -o bundle.js
```

Create several bundles, appending `.bundle.js` to each entry module's name:
```
$ requisite *.js -o {}.bundle.js
```

Create a single shared bundle (to leverage caching in browser) and individual
bundles for each page containing just the additional modules necessary for each:
```
$ requisite --dedupe main.js page1.js page2.js -o {}.bundle.js
```

You'd then use the bundle across the pages of your site like so:
```javascript
// page1.js
<script src="main.bundle.js">
<script src="page1.bundle.js">

// page2.js
<script src="main.bundle.js">
<script src="page2.bundle.js">

// page3.js
<script src="main.bundle.js">
<script src="page3.bundle.js">
```

### API
If you want more fine-grained control over requisite you can require it in your
own projects and use it directly.

```javascript
    require('requisite').bundle({
        entry: __dirname + '/entry.js',
    }, function(err, bundle) {
        fs.writeFileSync('app.js', bundle.toString())
    });
```

### Middleware
For development it can be useful to serve bundles up dynamically, and a connect
middleware is provided for exactly this purpose. Express example:

```javascript
  app.use('/js/app.js', require('requisite').middleware({
    entry: __dirname + '/entry.js'
  }))
```

Which would make your bundle available as `http://host/js/main.js`.

[browser-field]: https://gist.github.com/defunctzombie/4339901
[coffeescript]:  http://coffeescript.org
[commonjs]:      http://nodejs.org/docs/latest/api/modules.html#modules_modules
[connect]:       http://www.senchalabs.org/connect/
[express]:       http://expressjs.com/
[jade]:          http://jade-lang.com

[travis-img]:     https://img.shields.io/travis/zeekay/requisite.svg
[travis-url]:     https://travis-ci.org/zeekay/requisite
[coveralls-img]:  https://coveralls.io/repos/zeekay/requisite/badge.svg?branch=master&service=github
[coveralls-url]:  https://coveralls.io/github/zeekay/requisite?branch=master
[dependency-url]: https://david-dm.org/zeekay/requisite
[dependency-img]: https://david-dm.org/zeekay/requisite.svg
[npm-img]:        https://img.shields.io/npm/v/requisite.svg
[npm-url]:        https://www.npmjs.com/package/requisite
[gitter-img]:     https://badges.gitter.im/join-chat.svg
[gitter-url]:     https://gitter.im/zeekay/hi

<!-- not used -->
[downloads-img]:     https://img.shields.io/npm/dm/requisite.svg
[downloads-url]:     http://badge.fury.io/js/requisite
[devdependency-img]: https://david-dm.org/zeekay/requisite/dev-status.svg
[devdependency-url]: https://david-dm.org/zeekay/requisite#info=devDependencies
