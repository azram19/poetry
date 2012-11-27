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

  isAuthorized: =>
    if not @authorized
      $.when(@fbReady).then () =>
        $.when( @facebookAuthorizeIs() ).then (status) =>
          if status is 'connected'
            @authorized = true
            $.when( @facebookGetUser() ).then ( user ) =>
              @channel.trigger "authorize:true", user
          else
            @channel.trigger "authorize:false"
    else
      @channel.trigger "authorize:true"

  authorize: =>
    @facebookAuthorize()

  facebookAuthorizeIs: =>

    FB.getLoginStatus (res) ->
      return res.status

  facebookGetUser: =>
    fbUserDefer = $.Deferred()

    FB.api "/me", ( res ) ->
      console.log res
      fbUserDefer.resolve res

    fbUserDefer.promise()

  facebookAuthorize: =>
    FB.login (res) =>
      if res.status
        @authorized = true
        $.when( @facebookGetUser() ).then ( user ) =>
          @channel.trigger "authorize:true", user
      else
        @channel.trigger "authorize:false"
    , scope:'email'




window.Poetry.Modules["authorize"] = Authorize
