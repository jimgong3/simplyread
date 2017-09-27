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
  logger.info("mongoQuery>> query book by isbn");

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

exports.queryBookByTag = function(db, tag, callback){
  logger.info("mongoQuery>> query book by tag: " + tag);

  var colTags = db.collection('tags');
  var queryTag = {name: tag};
  colTags.find(queryTag).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> find tag result: ");
    logger.info(docs);

	if (docs.length == 0){
		logger.info("Oops, tag not found")
	} else {
		var book_ids = docs[0].book_ids;

		var colBooks = db.collection('books');
		var queryBooks = {_id: {$in: book_ids}};
		colBooks.find(queryBooks).toArray(function(err, docs){
			logger.info("mongoQuery>> find books by tag result: ")
			logger.info(docs);
			callback(docs);
		});
	}
  });
}

exports.queryBookByCategory = function(db, category, callback){
  logger.info("mongoQuery>> query book by category: " + category);

  var colCategories = db.collection('categories');
  var queryCat = {name: category};
  colCategories.find(queryCat).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> find category result: ");
    logger.info(docs);

	if (docs.length == 0){
		logger.info("Oops, category not found")
	} else {
		var book_ids = docs[0].book_ids;

		var colBooks = db.collection('books');
		var queryBooks = {_id: {$in: book_ids}};
		colBooks.find(queryBooks).toArray(function(err, docs){
			logger.info("mongoQuery>> find books by category result: ")
			logger.info(docs);
			callback(docs);
		});
	}
  });
}

exports.insertBook = function(db, bookJson, callback){
  logger.info("mongoQuery>> insert book by json");

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

  collection.find().sort({num_books: -1}).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.hotTags = function(db, n, callback){
  logger.info("mongoQuery>> query the hottest " + n + " tags");

  var collection = db.collection('tags');
  var nInt = parseInt(n, 10);

  collection.find().sort({num_books: -1}).limit(nInt).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

function collectTagFromBook(map, book){
    logger.info("mongoQuery>> collectTagFromBook: " + book.title);
    logger.info("book id: " + book._id);
    logger.info("book tags: " + book.tags);

    var bookId = book._id;
    var tags = book.tags;
    if(tags != null){
      logger.info("tags found for this book");
      tags.forEach(function(tag){
        var name = tag.name;
        logger.info("tag name: " + name);
        var curBooks = map.get(name);
        if (curBooks == null){
          logger.info("new tag: " + name + ", add book id: " + bookId);
          var books = [];
          books.push(bookId);
          map.set(name, books);
        } else {
          logger.info("existing tag, find book id: " + bookId)
          var found = false;
          for (var i=0; i<curBooks.length; i++){
            if(curBooks[i] == bookId){
              found = true;
              break;
            }
          }
          if(!found){
            logger.info("bookid not found, add book id: " + bookId)
            curBooks.push(bookId);
            map.set(name, curBooks);
          } else {
            logger.info("boodis found, do nothing: " + bookId)
          }
        }
      })
    } else {
      logger.info("this book has no tag");
    }
}

function buildTags(colTags, map){
  var query = {}
  colTags.deleteMany(query, function(err, obj){
    if (err) throw err;
    logger.info(obj.result.n + " documents from tags deleted.")

    map.forEach(function(value, key){
      logger.info("adding tag and books: " + key)
      var tagJson = {};
      tagJson["name"] = key;
      tagJson["num_books"] = value.length;
      tagJson["book_ids"] = value;

      logger.info("insert document to tags collection: " + tagJson);
      colTags.insertOne(tagJson, function(err, res){
        if (err) throw err;
        logger.info("1 document inserted.")
      })
    })
  });
  logger.info("function buildTags complete");
}

function buildTags2(colTags, map){
  logger.info("buildTags2 start");
  map.forEach(function(value, key){
    logger.info("processing tag: " + key);
    var query = {name: key};
    colTags.deleteOne(query, function(err, obj){
      if (err) throw err;
      logger.info(obj.result.n + " documents deleted for tag: " + key);

      logger.info("rebuild documents for tag: " + key)
      var tagJson = {};
      tagJson["name"] = key;
      tagJson["num_books"] = value.length;
      tagJson["book_ids"] = value;

      logger.info("insert document to tags collection: " + JSON.stringify(tagJson));
      colTags.insertOne(tagJson, function(err, res){
        if (err) throw err;
        logger.info("1 document inserted for tag: " + key);
      })
    });
  });
  logger.info("function buildTags2 complete");
}

exports.collectTags = function(db, callback){
  logger.info("mongoQuery>> collect tags");

  var map = new HashMap();

  var colBooks = db.collection('books');
  var curBooks = colBooks.find()
  curBooks.each(function(err, item){
	  if(item != null){
		  collectTagFromBook(map, item);
	  } else {
      logger.info("all books have been processed.")
      map.forEach(function(value, key){
        logger.info(key + " : " + value);
      })

      logger.info("rebuild tags collection");
      var colTags = db.collection('tags');
      buildTags2(colTags, map);

      logger.info("mongoQuery>> collectTags complete")
      callback("result:done");
    }
  });
}

exports.assignBookCategory = function(db, isbn, category, callback){
  logger.info("mongoQuery>> assign book category, isbn: " + isbn + ", category: " + category);

  var collection = db.collection('books');

  var query = {$or: [{isbn10: isbn}, {isbn13: isbn}]};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.update(query, {$set: {category: category}}, function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

function addBookToCategory(map, book){
    logger.info("mongoQuery>> addBookToCategory: " + book.title);
    logger.info("book id: " + book._id);
    logger.info("book category: " + book.category);

    var bookId = book._id;
    var category = book.category;

    if(category != null){
      logger.info("category found for this book: " + category);
      var curBooks = map.get(category);
      if (curBooks == null)
        curBooks = [];
      curBooks.push(bookId);
      map.set(category, curBooks);
    } else {
      logger.info("this book has no category info");
    }
}

function updateCategories(colCategories, map){
  logger.info("updateCategories start");
  colCategories.deleteMany({}, function(err, obj){
    logger.info("all existing categories data deleted.")
    map.forEach(function(value, key){
      logger.info("processing category: " + key);
      var catJson = {};
      catJson["name"] = key;
      catJson["num_books"] = value.length;
      catJson["book_ids"] = value;

      logger.info("insert document to categories collection: " + JSON.stringify(catJson));
      colCategories.insertOne(catJson, function(err, res){
        if (err) throw err;
        logger.info("1 document inserted for category: " + key);
      })
    });
    logger.info("function updateCategories complete");
  });
}

exports.buildCategories = function(db, callback){
  logger.info("mongoQuery>> build categories");

  var map = new HashMap();

  var colBooks = db.collection('books');
  var curBooks = colBooks.find()
  curBooks.each(function(err, book){
	  if(book != null){
		  addBookToCategory(map, book);
	  } else {
      logger.info("all books have been processed, review categories data:")
      map.forEach(function(value, key){
        logger.info(key + " : " + value);
      })

      logger.info("rebuild tags collection");
      var colCategories = db.collection('categories');
      updateCategories(colCategories, map);

      logger.info("mongoQuery>> buildCategories complete")
      callback("result:done");
    }
  });
}

exports.queryCategories = function(db, callback){
  logger.info("mongoQuery>> query all categories");

  var collection = db.collection('categories');

  var order = {ref: 1};
  logger.info("mongoQuer>> order");
  logger.info(order);

  collection.find().sort(order).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.assignBookCategory = function(db, isbn, category, callback){
  logger.info("mongoQuery>> assign book category, isbn: " + isbn + ", category: " + category);

  var collection = db.collection('books');

  var query = {$or: [{isbn10: isbn}, {isbn13: isbn}]};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.update(query, {$set: {category: category}}, function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}


exports.assignCategoryOrder = function(db, ref, category, callback){
  logger.info("mongoQuery>> assign category order, ref: " + ref + ", category: " + category);

  var collection = db.collection('categories');

  var query = {name: category};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.update(query, {$set: {ref: ref}}, function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

