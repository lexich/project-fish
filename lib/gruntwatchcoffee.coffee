path = require 'path'
coffee = require('coffee-script')

getWritePath = (filepath,cwd, dest, ext) ->
  one = filepath.split path.sep
  two = cwd.split path.sep
  len = if one.length > two.length then two.length else one.length
  pos = 0
  for i in [0..len]
    if one[i] != two[i]
      pos = i
      break
  origArray = one.slice(pos,one.length)      
  orig = path.join.apply this, origArray      
  writePath = path.join dest,orig
  writePath.replace /\.coffee$/, ext

module.exports = 
  init:(grunt, {cwd,dest,ext})->
    (action, filepath, task)->
      return unless task is "coffee"  
      return unless dest?
      cwd = path.normalize cwd or "."
      dest = path.normalize dest
      ext or = ".js"
         
      data = grunt.file.read filepath
      try
        compiled = coffee.compile data      
        writePath = getWritePath filepath, cwd, dest, ext
        grunt.file.write writePath, compiled      
        grunt.log.write("update file #{writePath} ")  
      catch e
        grunt.log.error e            
      false