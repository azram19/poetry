class AuthorizeView extends Backbone.View
  el: "#poetry"

  authorize: () =>
    @channel.trigger "authorize:do"

  constructor: ( options ) ->
    self = @
    @channel = options.channel
    @template = Handlebars.templates.authorize

  render: () ->
    if not @rendered
      @rendered = true
      @$el = $ @el

      @$el.html @template()

      @$el.on "click", ".fb-button", @authorize


window.Poetry.Views['authorize'] = AuthorizeView
