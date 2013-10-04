LIVERELOAD_PORT = 35729
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)



# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  
  # show elapsed time at the end
  require("time-grunt") grunt
  
  # load all grunt tasks
  require("load-grunt-tasks") grunt
  
  # configurable paths
  yeomanConfig =
    app: "app"
    dist: "dist"
    
    open:
      server:        
        path:""

    connect:
      options:
        port: 9000

    proxy: 
      port: 9001
      proxies: []
    coffee:
      options:        
        nospawn: true
        runtime: 'inline'

  grunt.initConfig
    yeoman: do ->
      try
        cfg = grunt.file.readJSON('.gruntconfig.json')
      catch e
        cfg = {}
      grunt.util._.extend yeomanConfig, cfg

    swig:
      dist:
        root: "app"
        livereload: true
        files: [
          expand: true
          src: "*.html"
          cwd: "app/templates"
          dest: "app"
          options:
            bare: true
        ]

    watch:
      templates:
        files: ["<%= yeoman.app %>/templates/{,*/}*.html"]
        tasks: ["swig:dist"]

      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee","<%= yeoman.app %>/scripts/**/{,*/}*.coffee"]
        tasks: []

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      compass:
        files: ["<%= yeoman.app %>/styles/{,*/}*.{scss,sass}"]
        tasks: ["compass:server", "autoprefixer"]

      styles:
        files: ["<%= yeoman.app %>/styles/{,*/}*.css"]
        tasks: ["copy:styles", "autoprefixer"]

      livereload:
        options:
          livereload: LIVERELOAD_PORT

        files: ["<%= yeoman.app %>/*.html", ".tmp/styles/main.css", "{.tmp,<%= yeoman.app %>}/scripts/{,*/}*.js", "<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"]

    connect:
      options:
        port: "<%= yeoman.connect.options.port %>"
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      livereload:
        options:
          middleware: (connect) ->
            [lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, yeomanConfig.app), mountFolder(connect, ".")]

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test"), mountFolder(connect, yeomanConfig.app)]

      dist:
        options:
          middleware: (connect) ->
            [mountFolder(connect, yeomanConfig.dist)]

    proxy:
      dist:
        port: "<%= yeoman.proxy.port %>"
        'default':
          host:"localhost"
          port:"<%= connect.options.port %>"
        proxies: "<%= yeoman.proxy.proxies %>"

    open:
      server:
        path: "http://localhost:<%= proxy.dist.port %><%= yeoman.open.server.path %>"

    clean:
      dist:
        files: [
          dot: true
          src: [
            ".tmp"
            "<%= yeoman.dist %>/*"
            "!<%= yeoman.dist %>/.git*"
            "<%= yeoman.app %>/*.html"
          ]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js", "!<%= yeoman.app %>/scripts/vendor/*", "test/spec/{,*/}*.js"]

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ] 
        options: "<%= yeoman.coffee.options %>"      

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    compass:
      options:
        sassDir: "<%= yeoman.app %>/styles"
        cssDir: ".tmp/styles"
        generatedImagesDir: ".tmp/images/generated"
        imagesDir: "<%= yeoman.app %>/images"
        javascriptsDir: "<%= yeoman.app %>/scripts"
        fontsDir: "<%= yeoman.app %>/styles/fonts"
        importPath: "<%= yeoman.app %>/bower_components"
        httpImagesPath: "/images"
        httpGeneratedImagesPath: "/images/generated"
        httpFontsPath: "/styles/fonts"
        relativeAssets: false

      dist:
        options:
          generatedImagesDir: "<%= yeoman.dist %>/images/generated"

      server:
        options:
          debugInfo: true

    autoprefixer:
      options:
        browsers: ["last 1 version","last 1 version", "ie >= 8",  "ff >= 17", "opera >=10"]

      dist:
        files: [
          expand: true
          cwd: ".tmp/styles/"
          src: "{,*/}*.css"
          dest: ".tmp/styles/"
        ]

    
    # not used since Uglify task does concat,
    # but still available if needed
    #concat: {
    #            dist: {}
    #        },
    requirejs:
      dist:
        
        # Options: https://github.com/jrburke/r.js/blob/master/build/example.build.js
        options:
          
          name: "main"          
          mainConfigFile: yeomanConfig.app + "/../.tmp/scripts/main.js"
          out: yeomanConfig.dist + "/scripts/main.js"
          optimize: "uglify"
          
          # TODO: Figure out how to make sourcemaps work with grunt-usemin
          # https://github.com/yeoman/grunt-usemin/issues/30
          #generateSourceMaps: true,
          # required to support SourceMaps
          # http://requirejs.org/docs/errors.html#sourcemapcomments
          preserveLicenseComments: false
          useStrict: true
          wrap: true
    
    replace:
      requirejs:
        src: ".tmp/scripts/main.js"
        overwrite: true
        replacements:[
          from: /VENDOR_PATH[ ]*=[ ]*["']{1}.+["']{1};/
          to: ''
        ,
          from: /var[ ]*VENDOR_PATH[ ]*;/
          to: ''
        ,
          from: "VENDOR_PATH"
          to: '"../../app/bower_components/"'
        ,
          from: /window\.CAPI\.uidstamp.+/
          to: 'window.CAPI.uidstamp=\"' + (+new Date) + "\";"
        ]      

    
    #uglify2: {} // https://github.com/mishoo/UglifyJS2
    rev:
      dist:
        files:
          src: [
            "<%= yeoman.dist %>/scripts/{,*/}*.js"
            "<%= yeoman.dist %>/styles/{,*/}*.css"
            "<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}"
            "<%= yeoman.dist %>/styles/fonts/{,*/}*.*"
          ]

    useminPrepare:
      options:
        dest: "<%= yeoman.dist %>"

      html: "<%= yeoman.app %>/index.html"

    usemin:
      options:
        dirs: ["<%= yeoman.dist %>"]

      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.dist %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin: {}
    
    # This task is pre-configured if you do not wish to use Usemin
    # blocks for your CSS. By default, the Usemin block from your
    # `index.html` will take care of minification, e.g.
    #
    #     <!-- build:css({.tmp,app}) styles/main.css -->
    #
    # dist: {
    #     files: {
    #         '<%= yeoman.dist %>/styles/main.css': [
    #             '.tmp/styles/{,*/}*.css',
    #             '<%= yeoman.app %>/styles/{,*/}*.css'
    #         ]
    #     }
    # }
    htmlmin:
      dist:
        options: {}
        
        #removeCommentsFromCDATA: true,
        #                    // https://github.com/yeoman/grunt-usemin/issues/44
        #                    //collapseWhitespace: true,
        #                    collapseBooleanAttributes: true,
        #                    removeAttributeQuotes: true,
        #                    removeRedundantAttributes: true,
        #                    useShortDoctype: true,
        #                    removeEmptyAttributes: true,
        #                    removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "*.html"
          dest: "<%= yeoman.dist %>"
        ]

    
    # Put files not handled in other tasks here
    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: ["*.{ico,png,txt}", ".htaccess", "images/{,*/}*.{webp,gif}", "styles/fonts/{,*/}*.*"]        
        ,
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>/bower_components/requirejs"
          dest: "<%= yeoman.dist %>/bower_components/requirejs"
          src: "require.js"
        ]
      styles:
        files:[
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>/styles"
          dest: ".tmp/styles/"
          src: "{,*/}*.css"
        ]

    modernizr:
      devFile: "<%= yeoman.app %>/bower_components/modernizr/modernizr.js"
      outputFile: "<%= yeoman.dist %>/bower_components/modernizr/modernizr.js"
      files: [
        "<%= yeoman.dist %>/scripts/{,*/}*.js", 
        "<%= yeoman.dist %>/styles/{,*/}*.css", 
        "!<%= yeoman.dist %>/scripts/vendor/*"
      ]
      uglify: true

    concurrent:
      server: [
        "compass"
        "coffee:dist"        
        "swig:dist"
        "copy:styles"
      ]
      test: [
        "coffee"
        "swig:dist"
        "copy:styles"
      ]
      dist: [
        "coffee"        
        "compass"
        "copy:styles"
        "imagemin"
        "svgmin"
        "htmlmin"
      ]

    bower:
      options:
        exclude: ["modernizr"]

      all:
        rjsConfig: "<%= yeoman.app %>/scripts/main.js"

  grunt.event.on "watch", require("./lib/gruntwatchcoffee").init(grunt, grunt.config.get("coffee.dist.files")[0])

  grunt.registerTask "server", (target) ->
    return grunt.task.run(["build", "open", "proxy", "connect:dist:keepalive"])  if target is "dist"
    grunt.task.run [
      "clean:server"
      "group_vendor"
      "concurrent:server"
      "autoprefixer"
      "connect:livereload"
      "proxy"
      "open"
      "watch"
    ]

  grunt.registerTask "test", [
    "clean:server" 
    "concurrent:test"    
    "autoprefixer" 
    "connect:test"
    "mocha"
  ]

  grunt.registerTask "group_requirejs", ["replace:requirejs","requirejs"]
  grunt.registerTask "group_vendor", []

  grunt.registerTask "build", [
    "clean:dist"
    "swig:dist"
    "useminPrepare"    
    "group_vendor"
    "concurrent:dist"
    "autoprefixer"
    "group_requirejs"                
    "concat"
    "cssmin"
    "uglify"
    "modernizr"
    "copy:dist"
    "rev"
    "usemin"    
  ]
  

  grunt.registerTask "default", ["jshint", "test", "build"]
  grunt.loadTasks "tasks"
