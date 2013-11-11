## Introduction

Requisite is an extensible CommonJS bundler for browsers featuring synchronous and
asynchronous module loading, minfication, and customizable file handlers.

## Install
```bash
npm install -g requisite
```

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
requisite src/entry.coffee > lib/bundle.js
```

### Modules
Requisite supports [CommonJS (node modules)][commonjs_modules]. In addition to
the normal synchronous API for requiring modules, it also supports asynchronous
modules, which are required with an additional callback argument which will be
returned the module after it has been loaded:

```javascript
// foo.js
module.exports = 'foo';

// async-bar.js
module.exports = 'bar'

// main.js, entry module
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

### API
If you want more fine-grained control over requisite you can require it in your
own projects and use it directly.

```javascript
    require('requisite').bundle({
        entry: './src/index',
        include: './src/some-module',
        exclude: '',
        export: 'global-name'
    }, function(err, bundles) {
        bundles.forEach(function(bundle, asyncBundles) {
            bundle.write(bundle);
        });
    });
```

### Middleware
For development it can be useful to serve bundles up dynamically, and a connect
middleware is provided for exactly this purpose. Express example:

```javascript
  app.use('/js', require('requisite').middleware({
    entry: __dirname + '/assets/main.js'
  }))
```

Which would make your bundle available as `http://host/js/main.js`.

[commonjs_modules]: http://nodejs.org/docs/latest/api/modules.html#modules_modules
