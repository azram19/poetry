class PoetryView extends Backbone.View
  el: "#poetry .pages"
  events: {}
  initialize: ( options ) ->
    @channel = options.channel
    @templates =
      "main": Handlebars.templates.poetry
      "index": Handlebars.templates.index
    @collection = new window.Poetry.Poems

    args =
      author: 'x. Jan Twardowski'
      title: 'Życie'

    poem = new window.Poetry.Poem()
    poem.set args

    @collection.add poem
    @collection.add poem.clone()
    @collection.add poem.clone()
    @collection.add poem.clone()
    @collection.add poem.clone()
    @collection.add poem.clone()

    console.debug  @collection.toJSON()

  render: () =>
    $index = $ @templates["index"]()
    $html = $( @templates["main"] poems:@collection.toJSON() )
    $html.appendTo $index.find(" #main ")
    $index.appendTo @$el



    @channel.trigger "render", $index, @

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


window.Poetry.Views['poetry'] = PoetryView
