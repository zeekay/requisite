### Introduction

Requisite is a cosmic JavaScript bundler that allows you to develop JavaScript applictions using CommonJS modules in Node.js and in the browser. Requisite traces your applications dependencies and bundles your code up. Requisite supports both asynchronous and synchronous requires, making it ideal for building fast and modular JavaScript applications.

### Features

- CommonJS modules.
- Relative dependency and NPM module resolution.
- Minimal and fast CommonJS module implementation for the browser.
- Asynchronous bundling suitable for use in Node.js applications.
- JavaScript API for programmatic usage.
- Access to the AST allowing custom transformations.

### Usage

    `coffeescript
    requisite = require('requisite').createBundle
      entry: '/path/to/entry.js'
      prepend: ['libs', 'to', 'be', 'prepended']

    requisite.bundle, (err, content) ->
      # use bundled js

That's it!
