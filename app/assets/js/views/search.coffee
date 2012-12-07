class SearchView extends Backbone.View
  el: "#poetry .pages"
  events: {}
  initialize: ( options ) ->
    self = @
    @channel = options.channel
    @template = Handlebars.templates.search

    @collection = new window.Poetry.Poems

  render: () =>
    $html = $( @template poems:@collection.toJSON() )
    $html.hide()
    $main = $("#main")
    $main.children().fadeOut()
    $html.appendTo $main

    $html.fadeIn()

    @channel.trigger "render", $html, @

  show: () =>
    console.log "show"
    c = 2
    n = 0.3
    @$el.find("li").each ( i, e) ->
      $(e).css
        "-webkit-animation-duration": "#{c + n * i}s"
        "-moz-animation-duration": "#{c + n * i}s"
        "-ms-animation-duration": "#{c + n * i}s"
        "-o-animation-duration": "#{c + n * i}s"
        "animation-duration": "#{c + n * i}s"
      $(e).addClass("fadeInLeft")


window.Poetry.Views['search'] = SearchView
