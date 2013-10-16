define [
  "Log"
  "jade!templates/test"
], (Log, templateTest)->
  log = Log.getLogger "app"
  init:->
    log.info "Hello"
    $("body").append """
    <p>Coffeescript works<p>
    """

    $("body").append templateTest p: items:["One","Two","Three"]