define [
  "Log"  
], (Log)->  
  log = Log.getLogger "app"
  init:->    
    log.info "Hello"
    $("body").append """
    <p>Coffeescript works<p>    
    """