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
    var alias, _i, _len;
    for (_i = 0, _len = aliases.length; _i < _len; _i++) {
      alias = aliases[_i];
      modules[alias] = fn;
    }
  };
})();


jade=function(exports){Array.isArray||(Array.isArray=function(arr){return"[object Array]"==Object.prototype.toString.call(arr)}),Object.keys||(Object.keys=function(obj){var arr=[];for(var key in obj)obj.hasOwnProperty(key)&&arr.push(key);return arr}),exports.merge=function merge(a,b){var ac=a["class"],bc=b["class"];if(ac||bc)ac=ac||[],bc=bc||[],Array.isArray(ac)||(ac=[ac]),Array.isArray(bc)||(bc=[bc]),ac=ac.filter(nulls),bc=bc.filter(nulls),a["class"]=ac.concat(bc).join(" ");for(var key in b)key!="class"&&(a[key]=b[key]);return a};function nulls(val){return val!=null}return exports.attrs=function attrs(obj,escaped){var buf=[],terse=obj.terse;delete obj.terse;var keys=Object.keys(obj),len=keys.length;if(len){buf.push("");for(var i=0;i<len;++i){var key=keys[i],val=obj[key];"boolean"==typeof val||null==val?val&&(terse?buf.push(key):buf.push(key+'="'+key+'"')):0==key.indexOf("data")&&"string"!=typeof val?buf.push(key+"='"+JSON.stringify(val)+"'"):"class"==key&&Array.isArray(val)?buf.push(key+'="'+exports.escape(val.join(" "))+'"'):escaped&&escaped[key]?buf.push(key+'="'+exports.escape(val)+'"'):buf.push(key+'="'+val+'"')}}return buf.join(" ")},exports.escape=function escape(html){return String(html).replace(/&(?!(\w+|\#\d+);)/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")},exports.rethrow=function rethrow(err,filename,lineno){if(!filename)throw err;var context=3,str=require("fs").readFileSync(filename,"utf8"),lines=str.split("\n"),start=Math.max(lineno-context,0),end=Math.min(lines.length,lineno+context),context=lines.slice(start,end).map(function(line,i){var curr=i+start+1;return(curr==lineno?"  > ":"    ")+curr+"| "+line}).join("\n");throw err.path=filename,err.message=(filename||"Jade")+":"+lineno+"\n"+context+"\n\n"+err.message,err},exports}({});

// source: /Volumes/Data/zk/play/requisite/test/assets/entry.coffee
// modified: Tuesday, June 26, 2012 1:22:56 AM
require.define(["/entry","21568343a3"], function (require, module, exports) {(function(){
    var a, b, c, template;

    a = require("70f886d883");

    b = require("8908bb92f8");

    c = function() {
      return require("318af1af20");
    };

    module.exports = {
      a: a,
      b: b,
      c: c()
    };

    template = require("04e021b689");
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/test/assets/a.coffee
// modified: Tuesday, June 26, 2012 1:22:56 AM
require.define(["/a","70f886d883"], function (require, module, exports) {(function(){
    module.exports = {
      a: "a",
      foo: require("58c67562d2")
    };
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/test/assets/c.coffee
// modified: Friday, June 29, 2012 6:10:29 AM
require.define(["/c","318af1af20"], function (require, module, exports) {(function(){
    module.exports = {
      c: "c",
      mod: require("e63313c6a9")
    };

    alert("hi");
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/test/assets/b.coffee
// modified: Tuesday, June 26, 2012 1:22:56 AM
require.define(["/b","8908bb92f8"], function (require, module, exports) {(function(){
    module.exports = {
      b: "b"
    };
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/node_modules/mod/index.js
// modified: Friday, June 29, 2012 2:07:54 AM
require.define(["/node_modules/mod","e63313c6a9"], function (require, module, exports) {(function(){
    module.exports = {
      x: 42
    };
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/test/assets/foo/index.coffee
// modified: Tuesday, June 26, 2012 1:22:56 AM
require.define(["/test/assets/foo","58c67562d2"], function (require, module, exports) {(function(){
    module.exports = {
      foo: "bar"
    };
}).call(this)});

// source: /Volumes/Data/zk/play/requisite/test/assets/template.jade
// modified: Tuesday, June 26, 2012 1:22:56 AM
require.define(["/test/assets/template","04e021b689"], function (require, module, exports) {(function(){
    module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
      attrs = attrs || jade.attrs;
      escape = escape || jade.escape;
      rethrow = rethrow || jade.rethrow;
      merge = merge || jade.merge;
      var buf = [];
      with (locals || {}) {
        var interp;
        buf.push("<h1>hi!</h1>");
      }
      return buf.join("");
    };
}).call(this)});

require('21568343a3');
