html = require("html")
fs = require("fs")
path = require("path")
swig = require("swig")

module.exports = (grunt)->
  grunt.registerMultiTask "swig", "Run swig", ->
    @files.forEach (filePair) =>
      try
        sw = new swig.Swig
          root: filePair.orig.cwd
          autoescape: true
          allowErrors: true
          encoding: "utf8"

        #src = path.relative filePair.orig.cwd, filePair.src[0]        
        src = filePair.src[0]
        console.log src
        tmpl = sw.compileFile(src)
        
        params = grunt.util._.defaults @data.params,{livereload:false}
        data = tmpl p:params

        prettyData = html.prettyPrint(data, indent_size: 2)
        grunt.file.write(filePair.dest, prettyData)
        grunt.log.writeln "Compile " + filePair.src[0].green + " -> ".yellow + filePair.dest.green
      catch err
        grunt.log.error err