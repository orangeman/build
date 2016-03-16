exec = require("child_process").exec
fs = require "fs"

module.exports = (what) ->
  tmp = "./tmp_" + Math.floor Math.random()*1000000000
  out = fs.createWriteStream tmp + ".coffee"
  what
    inline: (zeug) ->
      out.write zeug.split("/").pop().replace("\.","") + " = \"\"\"\n" +
        fs.readFileSync("./" + zeug) + "\n\"\"\"\n"
    append: (file) ->
      out.write fs.readFileSync file
    browserify: (f, opt) ->
      exec "./node_modules/coffee-script/bin/coffee -c " + tmp + ".coffee", (e, o) ->
        browserify = require('browserify')
        b = browserify debug: true
        if opt && (opt.mini || opt.minify)
          b.plugin 'minifyify', {map: 'bundle.js.map'}
        if opt && opt.include
          b.add opt.include
        b.add(tmp + ".js") # transpiled tmp coffee
        b.bundle (err, code, map) ->
          console.log err if err
          i = fs.createWriteStream f
          i.write code
          exec "rm " + tmp + ".*"

  #  require("uglify-js").minify("./tmp2.js").code
  #  i.on "finish", () -> exec "rm tmp*.coffee"
