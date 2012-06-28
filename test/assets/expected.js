(function() {
  var cache, modules;
  modules = {};
  cache = {};
  this.require = function(alias) {
    var fn, module;
    module = cache[alias];
    if (module) {
      return module.exports;
    }
    fn = modules[alias];
    if (!fn) {
      throw new Error("Module " + alias + " not found");
    }
    module = {
      id: alias,
      exports: {}
    };
    try {
      cache[alias] = module;
      fn(require, module, module.exports);
      return module.exports;
    } catch (err) {
      delete cache[alias];
      throw err;
    }
  };
  return this.require.define = function(aliases, fn) {
    var alias, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = aliases.length; _i < _len; _i++) {
      alias = aliases[_i];
      _results.push(modules[alias] = fn);
    }
    return _results;
  };
})();
// source: /Users/sferreira/software/requisite/test/assets/entry.coffee
// modified: Thursday, June 28, 2012 3:44:10 AM
require.define(["/entry","21568343a3"], function (require, module, exports) {(function(){
    var a, b, c, template;

    a = require("70f886d883");

    b = require("8908bb92f8");

    c = function() {
      return require("c294c60394");
    };

    module.exports = {
      a: a,
      b: b,
      c: c()
    };

    template = require("04e021b689");
}).call(this)});

// source: /Users/sferreira/software/requisite/test/assets/a.coffee
// modified: Thursday, June 28, 2012 3:44:10 AM
require.define(["/a","70f886d883"], function (require, module, exports) {(function(){
    module.exports = {
      a: "a",
      foo: require("58c67562d2")
    };
}).call(this)});

// source: /Users/sferreira/software/requisite/test/assets/b.coffee
// modified: Thursday, June 28, 2012 3:44:10 AM
require.define(["/b","8908bb92f8"], function (require, module, exports) {(function(){
    module.exports = {
      b: "b"
    };
}).call(this)});

// source: /Users/sferreira/software/requisite/test/assets/c.coffee
// modified: Thursday, June 28, 2012 3:44:10 AM
require.define(["/c","c294c60394"], function (require, module, exports) {(function(){
    module.exports = {
      c: "c",
      mod: require("e63313c6a9")
    };
}).call(this)});

// source: /Users/sferreira/software/requisite/test/assets/template.jade
// modified: Thursday, June 28, 2012 3:58:11 AM
require.define(["/template","04e021b689"], function (require, module, exports) {(function(){
    module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<h1>hi!</h1>');
}
return buf.join("");
}
}).call(this)});

// source: /Users/sferreira/software/requisite/test/assets/foo/index.coffee
// modified: Thursday, June 28, 2012 3:44:10 AM
require.define(["/foo","58c67562d2"], function (require, module, exports) {(function(){
    module.exports = {
      foo: "bar"
    };
}).call(this)});

// source: /Users/sferreira/software/requisite/node_modules/mod/index.js
// modified: Thursday, June 28, 2012 4:02:22 AM
require.define(["/node_modules/mod","e63313c6a9"], function (require, module, exports) {(function(){
    module.exports = {
      x: 42
    };
}).call(this)});
