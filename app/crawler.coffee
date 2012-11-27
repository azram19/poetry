nodeio = require 'node.io'
jquery = require 'jquery'
mongo = require 'mongodb'
Buffer = require('buffer').Buffer;
Iconv  = require('iconv').Iconv;
request = require('request')
url = require('url')
jsdom = require('jsdom')

iconv = new Iconv 'ISO-8859-2', "UTF-8"


Server = mongo.Server
Db = mongo.Db
Connection = mongo.Connection
Collection = mongo.Collection

Db.connect "mongodb://poetry:kotek@ds043447.mongolab.com:43447/heroku_app9514719", ( err, db ) =>
  poems = new Collection db, "poems"

  args =
    method: 'GET'
    encoding: 'binary'
    uri: 'http://www.poezja.org/index.php?akcja=wierszeznanych&ak=lista'

  request args, (err, response, body) ->
    if not err and response.statusCode == 200
      body = new Buffer( body, 'binary' );
      conv = new Iconv('ISO-8859-2', 'utf8');
      data = conv.convert( body ).toString();

      jquery( "li a.znani[href*='pokaz']", data ).each ( i, a ) ->
        author = jquery( a ).text()
        url_author = jquery( a ).attr( "href" )

        args =
          method: 'GET'
          encoding: 'binary'
          uri: 'http://www.poezja.org/' + url_author

        request args, (err, response, body) ->
          if not err and response.statusCode == 200
            body = new Buffer( body, 'binary' );
            conv = new Iconv('ISO-8859-2', 'utf8');
            data = conv.convert( body ).toString();

            jquery( "a[href*='utwor']", data ).each ( i, p ) ->
              url_poem = jquery( p ).attr( "href" )

              args =
                method: 'GET'
                encoding: 'binary'
                uri: 'http://www.poezja.org' + url_poem

              request args, (err, response, body2) ->
                if not err and response.statusCode == 200
                  body2 = new Buffer( body2, 'binary' );

                  conv = new Iconv('ISO-8859-2', 'utf8');
                  data = conv.convert( body2 ).toString();

                  $poem = jquery( data )
                  poem = jquery.trim( $poem.find( "pre > font" ).text() )
                  title = jquery.trim( $poem.find( "title" ).text().split("-")[0] )
                  author = jquery.trim( author )

                  poemDoc =
                    title:  title
                    author: author
                    content:  poem

                  if poem.length > 0
                    if title.length == 0
                      title = poem.split("\n")[0]
                    console.log title, ",", author
                    poems.insert poemDoc

                @
