class Search
  constructor: ( options ) ->
    self = @
    @channel = options.channel
    @view = new window.Poetry.Views['search'] channel: @channel

    @handlers =
      "search" :
        "query" : self.processSearch
        "result" : ( event, query, result ) ->
          for poem in result
            p = new window.Poetry.Poem poem["_source"]
            self.view.collection.add p

          self.view.render()

    $( window ).on "submit", () ->
      q = $( ".search form" ).find( 'input' ).val()
      console.log "submit", q
      self.channel.trigger "search:query", q
      return false

  processSearch: ( event, query ) =>
    dataObj =
      action: "search"
      q: query

    $.get( "/api/poems/", dataObj ).then ( res ) =>
      @channel.trigger "search:result", query, res

window.Poetry.Modules["search"] = Search
