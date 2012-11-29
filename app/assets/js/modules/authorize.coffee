class Authorize
  constructor: ( options ) ->
    self = @
    @channel = options.channel
    @authorized = false
    @fbReadyDefer = $.Deferred()
    @fbReady = @fbReadyDefer.promise()
    @view = new window.Poetry.Views['authorize'] channel:@channel

    @handlers =
      "authorize" :
        "is" : self.isAuthorized
        "do" : self.authorize
      "fb":
        "init": () -> self.fbReadyDefer.resolve()
      "route":
        "index": () -> self.view.render()

    $.when( @fbReady ).then () =>
      FB.Event.subscribe "auth.login", @authorized
      FB.Event.subscribe "auth.statusChange", @statusChange

  isAuthorized: =>
    if not @authorized
      $.when( @fbReady ).then () =>
        $.when( @facebookAuthorizeIs() ).then (status) =>
          if status is 'connected'
            @facebookAuthorized()
          else
            @channel.trigger "authorize:false"
    else
      @channel.trigger "authorize:true"

  authorize: =>
    @facebookAuthorize()

  authorized: (res) =>
    console.log "authorized", res

  statusChange: (res) =>
    if res.status is "connected"
      @facebookAuthorized()

  facebookAuthorizeIs: =>
    FB.getLoginStatus (res) ->
      res.status

  facebookGetUser: =>
    fbUserDefer = $.Deferred()

    FB.api "/me", ( res ) ->
      fbUserDefer.resolve res

    fbUserDefer.promise()

  facebookAuthorize: =>
    FB.login (res) =>
      if res.status
        @facebookAuthorized()
      else
        @channel.trigger "authorize:false"
    , scope:'email'

  facebookAuthorized: =>
    @authorized = true
    $.when( @facebookGetUser() ).then ( user ) =>
      @channel.trigger "authorize:true", user


window.Poetry.Modules["authorize"] = Authorize
