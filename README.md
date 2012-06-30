## Introduction

Requisite is a cosmic JavaScript bundler that allows you to develop JavaScript applictions using CommonJS modules in Node.js and in the browser. Requisite traces your applications dependencies and bundles your code up.

## Features

* CommonJS modules.
* Resolve relative modules as well as NPM modules.
* Minimal and fast CommonJS module implementation for the browser.
* Asynchronous bundling suitable for use in Node.js applications.
* Access to the AST allowing custom transformations.
* Flexible JavaScript API allowing easy programmatic usage.
* Command line build-tool for simple projects

## Command-line

```bash
requisite --entry ./app.js --output ./bundle.js --minify
```
Refer to `requisite --help` for additional usage options.

## JavaScript API
The JavaScript API is fully asynchronous, and designed to offer absolute control over Requisite's behavior.

Example:
```javascript
requisite = require('requisite').createBundler({
  entry: '/path/to/app.js'
});

requisite.bundle(function (err, content) {
  // Use bundled JavaScript.
});
```

### createBundler(options)
* `options` {Object}

Creates a bundler which can asynchronously bundle your code. At the very minimum `options` must contain the `entry` property pointing to your application.

#### Options

Several additional options can be passed to `createBundler`:

* `entry` Entry point of your application. Required.
* `after` List of scripts to include after bundled modules.
* `before` List of scripts to include before bundled modules.
* `minify` Whether to minify or not. Defaults to false.
* `requireEntry` Whether to automatically require the entry module. Defaults to true.
* `astTransforms` Transformations to apply to each modules AST.
* `astWalkers` Walkers to apply to each modules AST.
* `astFilters` Filters to apply to each modules AST.
* `wrapper` Hook to replace default module wrapper, which wraps each module in `define` call.
* `prelude` Hook to replace default prelude file, which contains basic client-side CommonJS implementation.
* `compilerHooks` Whether to inject scripts added by compilers. This allows compilers (such as the jade compiler) to automatically inject necessary scripts. Defaults true.

### bundler.bundle([cb])
* `cb` {Function} Called when an error occurs or you application has been bundled
    * `err` {Error | null}
    * `content` {String} Your bundled code.
