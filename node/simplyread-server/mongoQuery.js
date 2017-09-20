var assert = require('assert');
var HashMap = require('hashmap')

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/mongoQuery.log' })
  ]
});

exports.queryUser = function(db, username, password, callback){
  console.log("mongoQuery>> query user: " + username);

  var collection = db.collection('users');
  var query = {
                username: username,
                password: password
              };
  console.log("mongoQuery>> query: ");
  console.log(query);

  collection.find(query).toArray(function(err, docs) {
    assert.equal(err, null);
    console.log("mongoQuery>> result: ");
    console.log(docs);
    callback(docs);
  });
}

exports.queryBooks = function(db, callback){
  logger.info("mongoQuery>> query all books");

  var collection = db.collection('books');

  var query = {};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  var order = {add_date: -1};
  logger.info("mongoQuer>> order");
  logger.info(order);

  collection.find(query).sort(order).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.queryBook = function(db, isbn, callback){
  console.log("mongoQuery>> query book by isbn");

  var collection = db.collection('books');
  var query = {
                $or:[
                  {isbn10: isbn},
                  {isbn13: isbn}
                ]
              };
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.find(query).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.insertBook = function(db, bookJson, callback){
  console.log("mongoQuery>> insert book by json");

  var collection = db.collection('books');

  collection.insertOne(bookJson, function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> insert book result: ");
    // logger.info(docs);
    callback(bookJson);
  });
}

exports.queryTags = function(db, callback){
  logger.info("mongoQuery>> query all tags");

  var collection = db.collection('tags');

  collection.find().toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.collectTags = function(db, callback){
  logger.info("mongoQuery>> collect tags");

  var map = new HashMap();

  var colBooks = db.collection('books');
  var curBooks = colBooks.find()
  curBooks.each(function(err, item){
	  if(item != null){
		  logger.info("mongoQuery>> get book: " + item.title);
		  logger.info("book id: " + item._id);
		  logger.info("book tags: " + item.tags);

      var bookId = item._id;
      var tags = item.tags;
      tags.forEach(function(tag){
        var name = tag.name;
        logger.info("tag name: " + name);
        var curBooks = map.get(name);
        if (curBooks == null){  //new tag
          var books = [];
          books.push(bookId);
          map.set(tag, books);
        }
        else {  //tag found
          var found = false;
          for (var i=0; i<curBooks.length; i++){
            if(curBooks[i] == bookId){
              found = true;
              break;
            }
          }
          if(!found){
            curBooks.push(bookId);
            map.set(tag, curBooks);
          }
        }
      })
	  }
  });

  //testing
  map.forEach(function(value, key){
    logger.info(key + " : " + value);
  })

  var colTags = db.collection('tags');
  //...

}
