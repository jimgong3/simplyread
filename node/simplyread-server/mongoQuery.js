var assert = require('assert');
var HashMap = require('hashmap')

var translator = require('./translator');

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/mongoQuery.log' })
  ]
});

exports.queryUser = function(db, username, password, callback){
  logger.info("mongoQuery>> query user: " + username);

  var collection = db.collection('users');
  var query = {
                username: username,
                $or: [{password: password}, {password2: password}]
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

exports.queryBooks = function(db, callback){
  logger.info("mongoQuery>> queryBooks");

  var collection = db.collection('books');

  var query = {};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  var order = {add_date: -1};
  logger.info("mongoQuer>> order");
  logger.info(order);

  collection.find(query).sort(order).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> # of result: " + docs.length);
    // logger.info(docs);
    callback(docs);
  });
}

exports.queryBook = function(db, isbn, callback){
  logger.info("mongoQuery>> queryBook");

  var collection = db.collection('books');
  var query = {
                $or:[
                  {isbn10: isbn},
                  {isbn13: isbn}
                ]
              };
  logger.info("mongoQuery>> query: " + JSON.stringify(query));
  // logger.info(query);

  collection.find(query).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> # of result: " + docs.length);
    // logger.info(docs.length);
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

    var order = {add_date: -1};
    logger.info("mongoQuer>> order");
    logger.info(order);

		colBooks.find(queryBooks).sort(order).toArray(function(err, docs){
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
		logger.info("Oops, category not found");
		var empty = [];
		callback(empty);
	} else {
		var book_ids = docs[0].book_ids;

		var colBooks = db.collection('books');
		var queryBooks = {_id: {$in: book_ids}};

    var order = {add_date: -1};
    logger.info("mongoQuer>> order");
    logger.info(order);

		colBooks.find(queryBooks).sort(order).toArray(function(err, docs){
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
    logger.info("mongoQuery>> # of tags: " + docs.length);
//    logger.info(docs);
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

// Sub-function of collectTags, add the tags info into map
function collectTagFromBook(map, book){
    logger.info("mongoQuery>> collectTagFromBook: " + book.title);
    // logger.info("book id: " + book._id);
    // logger.info("book tags: " + book.tags);

    var bookId = book._id;
    var tags = book.tags;
    if(tags != null){
      logger.info("tags found for this book");
      tags.forEach(function(tag){
        var name = tag.name;
        // logger.info("tag name: " + name);
        var curBooks = map.get(name);
        if (curBooks == null){
          // logger.info("mongoQuery>> new tag: " + name + ", add book id: " + bookId);
          var books = [];
          books.push(bookId);
          map.set(name, books);
        } else {
          // logger.info("mongoQuery>> existing tag, find book id: " + bookId)
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

// This function is obsolete, replaced by buildTags2
// function buildTags(colTags, map){
//   var query = {}
//   colTags.deleteMany(query, function(err, obj){
//     if (err) throw err;
//     logger.info(obj.result.n + " documents from tags deleted.")
//
//     map.forEach(function(value, key){
//       logger.info("adding tag and books: " + key)
//       var tagJson = {};
//       tagJson["name"] = key;
//       tagJson["num_books"] = value.length;
//       tagJson["book_ids"] = value;
//
//       logger.info("insert document to tags collection: " + tagJson);
//       colTags.insertOne(tagJson, function(err, res){
//         if (err) throw err;
//         logger.info("1 document inserted.")
//       })
//     })
//   });
//   logger.info("function buildTags complete");
// }

// This is the sub-function of collectTags. It rebuilds the entire
// tags collection from "map" which contains {tag name, book_ids}
function buildTags2(colTags, map){
  logger.info("buildTags2 start");
  colTags.deleteMany({}, function(err, obj){
    logger.info("mongoQuery>> all existing tags deleted.");

    map.forEach(function(value, key){
      logger.info("mongoQuery>> processing tag: " + key);
      var query = {name: key};
      colTags.deleteOne(query, function(err, obj){
        if (err) throw err;
        // logger.info(obj.result.n + " documents deleted for tag: " + key);

        // logger.info("rebuild documents for tag: " + key)
        var tagJson = {};
        tagJson["name"] = key;
        tagJson["num_books"] = value.length;
        tagJson["book_ids"] = value;

        // logger.info("insert document to tags collection: " + JSON.stringify(tagJson));
        colTags.insertOne(tagJson, function(err, res){
          if (err) throw err;
          // logger.info("1 document inserted for tag: " + key);
        })
      });
    });
    logger.info("function buildTags2 complete");
});
}

// This function re-build the entire tags collection from
// "all" books, existing tags in the collection will be
// deleted first.
exports.collectTags = function(db, callback){
  logger.info("mongoQuery>> collectTags");

  var map = new HashMap();

  var colBooks = db.collection('books');
  var curBooks = colBooks.find()
  curBooks.each(function(err, item){
	  if(item != null){
		  collectTagFromBook(map, item);
	  } else {
      logger.info("mongoQuery>> all books have been processed, total # of tags:" + map.size)
      // map.forEach(function(value, key){
      //   logger.info(key + " : " + value);
      // })

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
    logger.info("mongoQuery>> all existing categories data deleted.")
    map.forEach(function(value, key){
      logger.info("processing category: " + key);
      var catJson = {};
      catJson["name"] = key;
      catJson["num_books"] = value.length;
      catJson["book_ids"] = value;

      logger.info("insert document to categories collection: " + JSON.stringify(catJson));
      colCategories.insertOne(catJson, function(err, res){
        if (err) throw err;
        // logger.info("1 document inserted for category: " + key);
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
      logger.info("mongoQuery>> all books have been processed, review categories data:")
      map.forEach(function(value, key){
        logger.info(key + " : " + value);
      })

      logger.info("mongoQuery>> rebuild categories");
      var colCategories = db.collection('categories');
      updateCategories(colCategories, map);

      logger.info("mongoQuery>> buildCategories complete")
      callback("result:done");
    }
  });
}

exports.queryCategories = function(db, callback){
  logger.info("mongoQuery>> queryCategories start...");

  var collection = db.collection('categories');

  var order = {ref: 1};
  logger.info("mongoQuer>> order: " + JSON.stringify(order));

  collection.find().sort(order).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> # of result: " + docs.length);
//    logger.info(docs);
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


exports.addPublisher = function(db, publisher, lang, callback){

  logger.info("mongoQuery>> add publisher, publisher: " + publisher + ", lang: " + lang);
  var collection = db.collection('publishers');

  var query = {name: publisher};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.update(query,
	{$set: {name: publisher, lang: lang}},
	{upsert: true},
	function(err, docs) {
		assert.equal(err, null);
		logger.info("mongoQuery>> result: ");
		logger.info(docs);
		callback(docs);
  });
}

exports.queryPublishers = function(db, callback){
  logger.info("mongoQuery>> query all publishers");

  var collection = db.collection('publishers');

  var order = {lang: 1};
  logger.info("mongoQuer>> order");
  logger.info(order);

  collection.find().sort(order).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoQuery>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.updateBookLang = function(db, callback){
  logger.info("mongoQuery>> updateBookLang");

  var map = new HashMap();
  var colPublishers = db.collection('publishers');
  var cursorPublishers = colPublishers.find();
  cursorPublishers.each(function(err, publisher){
    if(publisher != null){
	  var pub2 = translator.translate2(publisher.name);
      logger.info("add publisher into map: " + pub2 + " : " + publisher.lang);
      map.set(pub2, publisher.lang);
    } else {
      logger.info("all publishers have been read, now process books...")

      var colBooks = db.collection('books');
      var cursorBooks = colBooks.find();
      cursorBooks.each(function(err, book){
        if(book != null){
		  var pub2 = translator.translate2(book.publisher);
          var lang = map.get(pub2);
          logger.info("book " + book.title + " published by " + book.publisher + " in language " + lang);
          book.lang = lang;
          colBooks.save(book);
          logger.info("book lang saved into database.")
        }
        else{
          logger.info("all books processed, return.")
          callback("result:done");
        }
      })
    }
  });
}

exports.translateBooks = function(db, callback){
  logger.info("mongoQuery>> translateBooks");

  var colBooks = db.collection('books');
  var cursorBooks = colBooks.find();
  cursorBooks.each(function(err, book){
    if(book != null){
      var title2 = translator.translate2(book.title);
      book.title = title2;
      var summary2 = translator.translate2(book.summary);
      book.summary = summary2;
      var publisher2 = translator.translate2(book.publisher);
      book.publisher = publisher2;
      for (var i=0; i<book.tags.length; i++) {
        var tag = book.tags[i].name;
        var tag2 = translator.translate2(tag);
        book.tags[i].name = tag2;
      }
      colBooks.save(book);
      logger.info("book translated and saved into database.")
    }
    else{
      logger.info("all books processed, return.")
      callback("result:done");
    }
  })
}
