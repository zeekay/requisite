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
  -b, --bare                   Do not wrap output in closure
  -e, --export  <name>         Export module as <name>
  -x, --exclude <regex>        Regex to exclude modules from being parsed
  -i, --include [modules...]   Additional modules to parse and include
  -p, --prelude <file>         File to use as prelude, or false to disable
```

Example:
```bash
requisite src/entry.coffee > lib/bundle.js
```
