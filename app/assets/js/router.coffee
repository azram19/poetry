class Router extends Backbone.Router
  routes:
    "" : "homepage"
    ":module" : "handleRoute"
    ":module/" : "handleRoute"
    ":module/*" : "handleRoute"

  homepage: ->
    @channel.trigger "route:index"

  #emits an event to
  handleRoute: ( module, routeArgs ) ->
    if routeArgs?
      args = {}

      for arg in routeArgs.split "/"
        keyValue = arg.split ":"
        args[keyValue[0]] = keyValue[1]

      @channel.trigger "route:#{module}", args
    else
      @channel.trigger "route:#{module}"

  initialize: ( options ) =>
    self = @
    @channel = options.channel

window.Poetry.Router = Router
