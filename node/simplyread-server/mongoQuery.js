var assert = require('assert');

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



