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
  -i, --include [modules...]   Additional modules to parse and include
  -m, --minify                 Minify output
  -o, --output <file>          Write bundle to file instead of stdout
  -p, --prelude <file>         File to use as prelude, or false to disable
      --no-prelude             Exclude prelude from bundle
  -w, --watch                  Watch for changes, and recompile
  -x, --exclude <regex>        Regex to exclude modules from being parsed

  -v, --version                Display version
  -h, --help                   Display this help
```

Example:
```bash
requisite src/entry.coffee > lib/bundle.js
```
