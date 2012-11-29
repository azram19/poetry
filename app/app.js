
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , mongoose = require('mongoose');

var app = express();
var hbs = require('hbs');

mongoose.connect('mongodb://poetry:kotek@ds043447.mongolab.com:43447/heroku_app9514719');

var User = mongoose.model('User', new mongoose.Schema({
  email: String,
  first_name: String,
  last_name: String,
  id: String,
  username: String,
  poems: Array
}));
var Poem = mongoose.model('Poem', new mongoose.Schema({
  author: String,
  title: String,
  content: String
}, { collection: 'poems-poema' }));

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

app.get('/', routes.index);
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
app.get('/api/users/:id', function(req, res){
  return User.findById(req.params.id, function(err, user) {
    if (!err) {
      return res.send(user);
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
