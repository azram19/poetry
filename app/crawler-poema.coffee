$ = require 'jquery'
mongo = require 'mongodb'
request = require('request')
url = require('url')


Server = mongo.Server
Db = mongo.Db
Connection = mongo.Connection
Collection = mongo.Collection

authors = []
poems = []

#Retrieve list of all authors
processAuthors = ( body ) ->
  $( "p.title a", body ).each ( i, a ) ->
    author = $( a ).text()
    url_author = $( a ).attr( "href" )
    authors.push
      author: author
      url: 'http://poema.pl' + url_author

#Request list of poems
requestPoems = ( authorObj ) ->
  deferred = $.Deferred();

  args =
    method: 'GET'
    uri: authorObj.url

  request args, (err, response, body) ->
    if not err and response.statusCode == 200
      deferred.resolve body, authorObj.author
    else
      deferred.fail()

  deferred.promise()

#Retrieve list of all poems for an author
processPoems = ( body, author ) ->
  #deferred = $.Deferred();

  $( ".publications_list p.title a", body ).each ( i, p ) ->
    url_poem = $( p ).attr( "href" )
    title = $( p ).text()
    poems.push
      author: author
      title: title
      url: 'http://poema.pl' + url_poem

  #$.when( processContainer body, author ).then () ->
  #deferred.resolve()

  #deferred.promise()

processContainer = ( body, author ) ->
  deferred = $.Deferred();

  $( ".containers_list p.title a", body ).each ( i, p ) ->
    url_container = $( p ).attr( "href" )
    request {uri: url_container}, (err, response, body) ->
      if not err and response.statusCode == 200
        $.when( processPoems body, author ).then () ->
          deferred.resolve()
      else
        deferred.resolve()

  deferred.promise()

#Request Poem
requestPoem = ( poemObj ) ->
  deferred = $.Deferred();

  args =
    method: 'GET'
    uri: poemObj.url

  request args, (err, response, body) ->

    console.log poemObj.author, poemObj.title, response

    if not err and response.statusCode == 200
      deferred.resolve body, poemObj.author, poemObj.title
    else
      deferred.resolve null, null, null

  deferred.promise()

#Retrieve a poem
processPoem = ( body, author, title ) ->
  if body == null
    return null

  content = $.trim( $( "#divPublications .content", body ).html() )

  poemsObj =
    author: author
    title: title
    content: content

Db.connect "mongodb://poetry:kotek@ds043447.mongolab.com:43447/heroku_app9514719", ( err, db ) =>
  poemsCollection = new Collection db, "poems-poema"

  args =
    method: 'GET'
    uri: 'http://poema.pl/kontener/1-poezja-polska'

  request args, (err, response, body) ->
    if not err and response.statusCode == 200
      processAuthors body
      console.log "authors", authors.length

      authorsRequests = []
      authorsRequests.push( requestPoems( author ).pipe( processPoems ) ) for author, index in authors
      $.when.apply($, authorsRequests).then ->
        #console.log "poems", poems.length

        handlePoem = ( o ) ->
          if o != null
            poemsCollection.insert o

        checkPoem = ( poem ) ->
          deferred = $.Deferred();

          author = poem.author
          title = poem.title

          query =
            author: author
            title: title

          poemsCollection.findOne query, ( err, o ) ->
            if o
              deferred.resolve true
            else
              deferred.resolve false

          deferred.promise()

        for poem in poems
          i = 0
          $.when( checkPoem( poem ) ).done ( found ) ->
            console.log i, poems.length
            i++
            if not found
              requestPoem( poem ).pipe( processPoem ).done( handlePoem )
        @

  db.close()
