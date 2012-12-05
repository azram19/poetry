var url = require('url');
var mongoose = require('mongoose');
var connectionString = url.parse('http://api.searchbox.io/api-key/<key>');
mongoose.connect('<connection_string>');

var Poem = mongoose.model('Poem', new mongoose.Schema({
  author: String,
  title: String,
  content: String
}, { collection: 'poems-poema' }));

var ElasticSearchClient = require('elasticsearchclient');

var serverOptions = {
    host:connectionString.hostname,
    path:connectionString.pathname,
};
var elasticSearchClient = new ElasticSearchClient(serverOptions);

Poem.find(function(err, poems){
  if(!err){
    var poem;
    for(i = 0; i < poems.length; i++){
      poem = poems[i];
      console.log(poem.title);
      elasticSearchClient.index('poems', 'poem', poem)
        .on('data', function(data) {
            console.log(data)
        })
        .on('error', function(error) {
            console.log(error)
        })
        .exec()
    }
    return 0;
  }
});
