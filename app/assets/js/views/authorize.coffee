class AuthorizeView extends Backbone.View
  el: "#poetry .pages"

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

      $html = $ @template()
      $html.appendTo @$el

      @channel.trigger "render", $html
      @$el.on "click", ".fb-button", @authorize


window.Poetry.Views['authorize'] = AuthorizeView
