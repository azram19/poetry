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

    @view = new window.Poetry.Views['poetry'] channel:@channel

    ((@modules[moduleName] = new moduleClass channel:@channel) for moduleName, moduleClass of window.Poetry.Modules)

    @mediator.start()

    new window.Poetry.Router channel:@channel

    @channel.trigger "authorize:is"

  start: =>
    Backbone.history.start();

window.Poetry.Poetry = Poetry
