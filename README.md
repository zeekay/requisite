### Introduction

Requisite is a cosmic JavaScript bundler that allows you to develop JavaScript applictions using CommonJS modules in Node.js and in the browser. Requisite traces your applications dependencies and bundles your code up.

### Features

- CommonJS modules.
- Resolve relative modules as well as NPM modules.
- Minimal and fast CommonJS module implementation for the browser.
- Asynchronous bundling suitable for use in Node.js applications.
- Access to the AST allowing custom transformations.
- Flexible JavaScript API allowing easy programmatic usage.
- Command line build-tool for simple projects

### Commandline

```bash
requisite --entry /path/to/app.js --output /path/to/bundle.js --minify
```

### JavaScript API

```coffeescript
requisite = require('requisite').createBundle
    # Entry point of your application
    entry: '/path/to/app.js'
    # Scripts which should be bundled after entry module and dependencies.
    after: []
    # Scripts which should be bundled before entry module and dependencies.
    before: ['/path', '/to', '/jquery', '/etc']

requisite.bundle, (err, content) ->
  # use bundled JavaScript.
```
