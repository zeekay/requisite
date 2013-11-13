## Introduction
Requisite bundles client-side code and templates. It features asynchronous
module loading for optimal performance of large applications,
[CoffeeScript][coffeescript] and [Jade][jade] language support out of the box
and comes with a [connect][connect]/[express][express] middleware for rapid
development.

## Features
- CommonJS modules in the browser!
- Customizable compiler/preprocessors.
- Simple API for programmatic usage.
- Lazy asset loading.
- Resolves relative as well as npm modules.
- Command line tool for bundling simple projects.

## Install
```bash
npm install -g requisite
```

## Modules
Requiste allows you to structure your code using [CommonJS (Node.js)
modules][commonjs].  From a given starting point or entry module, requisite will
trace your application's dependencies and bundle all `require`'ed modules
together.  Requiste's `require` supports asynchronous loading of assets/modules
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

## Usage
### CLI
```bash
$ bin/requisite --help

Usage: requisite path/to/entry-module [options]

Options:
  -b, --bare                   Compile without a top-level function wrapper
  -e, --export <name>          Export module as <name>
  -i, --include [module, ...]  Additional modules to include, in <require as>:<path to module> format
  -m, --minify                 Minify output
  -o, --output <file>          Write bundle to file instead of stdout
  -p, --prelude <file>         File to use as prelude, or false to disable
      --no-prelude             Exclude prelude from bundle
  -w, --watch                  Write bundle to file and and recompile on file changes
  -x, --exclude <regex>        Regex to exclude modules from being parsed

  -v, --version                Display version
  -h, --help                   Display this help
```

Example:
```bash
requisite entry.js > lib/bundle.js
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

[coffeescript]: http://coffeescript.org
[commonjs]: http://nodejs.org/docs/latest/api/modules.html#modules_modules
[connect]: http://www.senchalabs.org/connect/
[express]: http://expressjs.com/
[jade]: http://jade-lang.com
