class PoetryView extends Backbone.View
  el: "#poetry"
  events: {}
  initialize: ( options ) ->
    @channel = options.channel
    @templates =
      "main": Handlebars.templates.poetry
    @collection = new window.Poetry.Poems

    args =
      author: 'x. Jan Twardowski'
      title: 'Życie'

    poem = new window.Poetry.Poem()
    poem.set args

    @collection.add poem
    console.debug  @collection.toJSON()

  render: () ->
    @$el.find( "#scroller" ).append( @templates["main"] poems:@collection.toJSON() )

window.Poetry.Views['poetry'] = PoetryView
