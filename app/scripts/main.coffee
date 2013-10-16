VENDOR_PATH = "../bower_components"

require.config
  paths:
    jquery: "#{VENDOR_PATH}/jquery/jquery"
    jade: "#{VENDOR_PATH}/require-jade/jade"
    Log:"#{VENDOR_PATH}/log4j-simple-amd/lib/Log"
    underscore: "#{VENDOR_PATH}/underscore/underscore"
    backbone: "#{VENDOR_PATH}/backbone/backbone"
    backboneExtention: "#{VENDOR_PATH}/backbone-extention/build/backbone-extention"
    epoxy: "#{VENDOR_PATH}/backbone.epoxy/backbone.epoxy"

  shim:
    foundation:
      deps: ["jquery"]

    underscore:
      exports:"_"

    backbone:
      exports:"Backbone"
      deps:["jquery","underscore"]

    backboneExtention:
      deps:["backbone"]

    epoxy:
      deps:["backbone"]

require [
  "jquery"
  "backboneExtention"
  "app"
  "Log"
], ($, nope, app, Log) ->
  "use strict"
  {DEBUG,INFO,WARN,ERROR} = Log.LEVEL
  ALL = INFO | DEBUG | WARN | ERROR
  CHECK = WARN | ERROR

  Log.initConfig
    "app": level: INFO
  $(document).ready ->
    app.init()

  Backbone.history.start()

