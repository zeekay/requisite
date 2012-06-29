        buf.push("<h1>hi!</h1>");
        var interp;
      a: "a",
      a: a,
      alias = aliases[_i];
      attrs = attrs || jade.attrs;
      b: "b"
      b: b,
      c: "c",
      c: c()
      cache[alias] = module;
      delete cache[alias];
      escape = escape || jade.escape;
      exports: {}
      fn(require, module, module.exports);
      foo: "bar"
      foo: require("58c67562d2")
      id: alias,
      merge = merge || jade.merge;
      mod: require("e63313c6a9")
      modules[alias] = fn;
      rethrow = rethrow || jade.rethrow;
      return buf.join("");
      return module.exports;
      return module.exports;
      return require("318af1af20");
      throw err;
      throw new Error("Module " + alias + " not found");
      var buf = [];
      with (locals || {}) {
      x: 42
      }
    a = require("70f886d883");
    alert("hi");
    b = require("8908bb92f8");
    c = function() {
    fn = modules[alias];
    for (_i = 0, _len = aliases.length; _i < _len; _i++) {
    if (!fn) {
    if (module) {
    module = cache[alias];
    module = {
    module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
    module.exports = {
    module.exports = {
    module.exports = {
    module.exports = {
    module.exports = {
    module.exports = {
    template = require("04e021b689");
    try {
    var a, b, c, template;
    var alias, _i, _len;
    var fn, module;
    }
    }
    }
    }
    } catch (err) {
    };
    };
    };
    };
    };
    };
    };
    };
    };
  cache = {};
  modules = {};
  return this.require.define = function(aliases, fn) {
  this.require = function(alias) {
  var cache, modules;
  };
  };
(function() {
jade=function(exports){Array.isArray||(Array.isArray=function(arr){return"[object Array]"==Object.prototype.toString.call(arr)}),Object.keys||(Object.keys=function(obj){var arr=[];for(var key in obj)obj.hasOwnProperty(key)&&arr.push(key);return arr}),exports.merge=function merge(a,b){var ac=a["class"],bc=b["class"];if(ac||bc)ac=ac||[],bc=bc||[],Array.isArray(ac)||(ac=[ac]),Array.isArray(bc)||(bc=[bc]),ac=ac.filter(nulls),bc=bc.filter(nulls),a["class"]=ac.concat(bc).join(" ");for(var key in b)key!="class"&&(a[key]=b[key]);return a};function nulls(val){return val!=null}return exports.attrs=function attrs(obj,escaped){var buf=[],terse=obj.terse;delete obj.terse;var keys=Object.keys(obj),len=keys.length;if(len){buf.push("");for(var i=0;i<len;++i){var key=keys[i],val=obj[key];"boolean"==typeof val||null==val?val&&(terse?buf.push(key):buf.push(key+'="'+key+'"')):0==key.indexOf("data")&&"string"!=typeof val?buf.push(key+"='"+JSON.stringify(val)+"'"):"class"==key&&Array.isArray(val)?buf.push(key+'="'+exports.escape(val.join(" "))+'"'):escaped&&escaped[key]?buf.push(key+'="'+exports.escape(val)+'"'):buf.push(key+'="'+val+'"')}}return buf.join(" ")},exports.escape=function escape(html){return String(html).replace(/&(?!(\w+|\#\d+);)/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")},exports.rethrow=function rethrow(err,filename,lineno){if(!filename)throw err;var context=3,str=require("fs").readFileSync(filename,"utf8"),lines=str.split("\n"),start=Math.max(lineno-context,0),end=Math.min(lines.length,lineno+context),context=lines.slice(start,end).map(function(line,i){var curr=i+start+1;return(curr==lineno?"  > ":"    ")+curr+"| "+line}).join("\n");throw err.path=filename,err.message=(filename||"Jade")+":"+lineno+"\n"+context+"\n\n"+err.message,err},exports}({});
require('21568343a3');
require.define(["/a","70f886d883"], function (require, module, exports) {(function(){
require.define(["/b","8908bb92f8"], function (require, module, exports) {(function(){
require.define(["/c","318af1af20"], function (require, module, exports) {(function(){
require.define(["/entry","21568343a3"], function (require, module, exports) {(function(){
require.define(["/node_modules/mod","e63313c6a9"], function (require, module, exports) {(function(){
require.define(["/test/assets/foo","58c67562d2"], function (require, module, exports) {(function(){
require.define(["/test/assets/template","04e021b689"], function (require, module, exports) {(function(){
})();
}).call(this)});
}).call(this)});
}).call(this)});
}).call(this)});
}).call(this)});
}).call(this)});
}).call(this)});