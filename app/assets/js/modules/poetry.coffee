class Poetry
  constructor: ->
    self = @
    @authDoCalls = 0

    @modules =
      "poetry" : @

    @mediator = new window.Mediator @modules

    @channel = @mediator.getChannel()
    @handlers =
      "authorize" :
        "false" : () ->
          if self.authDoCalls == 0
            self.channel.trigger "route:index"
            self.authDoCalls++
          else
            null
        "true": ( event, user ) ->
          console.log "user authorized"
          self.user = new window.Poetry.User user
          $.when( self.checkUser user.id, self.user ).then ( old ) ->
            console.log "old", old
            if old
              self.user.fetch success: () -> self.view.render()
            else
              self.user.save success: () -> self.view.render()

      "render" : ( event, $html, view ) ->
        $slides = $html.filter( "div.sl-slide" )

        if $slides.length > 0
          window.Poetry.Slider.add $slides, ( args ) ->
            if args.length < 2
              args.first().show()
            else
              window.Poetry.Slider.next()
              if view
                view.show()

    @view = new window.Poetry.Views['poetry'] channel:@channel

    (
      @modules[moduleName] = new moduleClass channel:@channel
    ) for moduleName, moduleClass of window.Poetry.Modules

    @mediator.start()

    new window.Poetry.Router channel:@channel

    @channel.trigger "authorize:is"
  checkUser: (facebookId, user) =>
    fbUserDefer = $.Deferred()
    console.log "check user"
    $.getJSON( "/api/auth/#{ facebookId }").then ( res ) =>
      if res and res.email is user.get("email") and user.get("id") is res.id
        fbUserDefer.resolve true
      else
        fbUserDefer.resolve false

    fbUserDefer.promise()
  start: =>
    Backbone.history.start()

window.Poetry.Poetry = Poetry
