http = require('http')
url = require("url")
httpProxy = require('http-proxy')

module.exports = (grunt)->
  grunt.registerMultiTask "proxy", "Run proxy", ->
    proxy = new httpProxy.RoutingProxy()   

    server = http.createServer (req, res)=>      
      pathname = url.parse(req.url).pathname
      bSend = false
      @data.proxies.forEach (opt)=>
        match = new RegExp opt.match
        if match.test(pathname)
          unless bSend
            proxy.proxyRequest req, res, {
              host: opt.host
              port: opt.port
              changeOrigin: true
            }
            bSend = true
      unless bSend
        proxy.proxyRequest req, res, {
          host: @data.default.host
          port: @data.default.port
        }
        bSend = true
        
    server.listen(@data.port);