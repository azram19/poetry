
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , mongoose = require('mongoose')
  , url = require('url');


var Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var ElasticSearchClient = require('elasticsearchclient');
var connectionString = url.parse('http://api.searchbox.io/api-key/<key>');

var serverOptions = {
    host:connectionString.hostname,
    path:connectionString.pathname,
};
var elasticSearchClient = new ElasticSearchClient(serverOptions);

var app = express();
var hbs = require('hbs');

mongoose.connect('<connection_string>');

var User = mongoose.model('User', new mongoose.Schema({
  email: String,
  first_name: String,
  last_name: String,
  id: String,
  username: String,
  poems: [ObjectId],
  friends: [ObjectId]
}));

var Poem = mongoose.model('Poem', new mongoose.Schema({
  author: String,
  title: String,
  content: String
}, { collection: 'poems-poema' }));

var UserPoem = mongoose.model('UserPoem', new mongoose.Schema({
  user: ObjectId,
  poem: ObjectId,
  read: Boolean,
  toRead: Boolean,
  readList: Boolean,
  mark: Number
}, { collection: 'poems-user' }));

var blocks = {};

hbs.registerHelper('extend', function(name, context) {
    var block = blocks[name];
    if (!block) {
        block = blocks[name] = [];
    }

    block.push(context(this));
});

hbs.registerHelper('block', function(name) {
    var val = (blocks[name] || []).join('\n');

    // clear the block
    blocks[name] = [];
    return val;
});

app.configure(function(){
  app.set('port', 80);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'hbs');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('your secret here'));
  app.use(express.session());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get( '/', routes.index );
app.get( '/api/search', function( req, res ){
  return Poem.find({}, function( err, poems ) {
    return res.send( poems );
  });
});
app.get('/api/users', function(req, res){
  return User.find(function(err, users) {
    return res.send(users);
  });
});

app.get('/api/poems', function(req, res){
  return Poem.find(function(err, poems) {
    return res.send(poems);
  });
});

app.get('/api/poems/search', function(req, res){
  return Poem.find(function(err, poems) {
    return elasticSearchClient.search('poems', 'poem',
        {"query" : { "query_string" : {"query" : req.query.q}}}
      )
      .on('data', function(data) {
          console.log(data);
          return res.send(data);
      })
      .on('done', function(){
          return res.send({});
      })
      .on('error', function(error){
          console.log(error)
          return res.send({});
      })
      .exec()
  });
});

app.get('/api/poems/:id', function(req, res){
  return Poem.findById(req.params.id, function(err, poem) {
    if (!err) {
      return res.send(poem);
    }
  });
});

app.get('/api/users/:id', function(req, res){
  return User.findById(req.params.id, function(err, user) {
    if (!err) {
      return res.send(user);
    }
  });
});

app.get('/api/users/:id/poems', function(req, res){
  return UserPoem.find({user: req.params.id}, function(err, poems) {
    if (!err) {
      return res.send(poems);
    }
  });
});

app.get('/api/auth/:id', function(req, res){
  return User.findOne({id: req.params.id}, function(err, user) {
    if (!err) {
      return res.send(user);
    }
  });
});

app.put('/api/users/:id', function(req, res){
  return User.findById(req.params.id, function(err, user) {
    user.email = req.body.email;
    user.first_name = req.body.first_name;
    user.last_name = req.body.last_name;
    user.id = req.body.id;
    user.username = req.body.username;
    user.poems = req.body.poems;
    return user.save(function(err) {
      if (!err) {
        console.log('updated');
      }
      return res.send(user);
    });
  });
});

app.post('/api/users', function(req, res){
  var user;
  user = new User({
    email : req.body.email,
    first_name : req.body.first_name,
    last_name : req.body.last_name,
    id : req.body.id,
    username : req.body.username,
    poems : req.body.poems
  });
  user.save(function(err) {
    if (!err) {
      return console.log('created');
    }
  });
  return res.send(user);
});

app.delete('/api/users/:id', function(req, res){
  return User.findById(req.params.id, function(err, user) {
    return user.remove(function(err) {
      if (!err) {
        console.log('removed');
        return res.send('')
      }
    });
  });
});

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});

/*
elasticSearchClient.search('poems', 'poem', {"query" : { "query_string" : {"query" : "Wojaczek"}}})
  .on('data', function(data) {
      console.log(data);
      results = JSON.parse(data)['hits']
      for(i = 0; i < 10; i++){
        console.log(results['hits'][i])
      }

  })
  .on('done', function(){
      //always returns 0 right now
  })
  .on('error', function(error){
      console.log(error)
  })
  .exec()
*/
