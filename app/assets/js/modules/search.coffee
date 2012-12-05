class Search
  constructor: ( options ) ->
    self = @
    @channel = options.channel
    @view = new window.Poetry.Views['search'] channel: @channel

    @handlers =
      "search" :
        "query" : self.processSearch

  processSearch: ( event, query ) =>
    $.get( "/api/search/", query: query ).then ( res ) =>
      @channel.trigger "search:result",
        query: query
        result: res

window.Poetry.Modules["search"] = Search
