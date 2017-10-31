var mongoQuery = require('./mongoQuery');
var pricing = require('./pricing');
var translator = require('./translator');

var HashSet = require('hashset');
var HashMap = require('hashmap')
var ObjectId = require('mongodb').ObjectID

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/booksUtil.log' })
  ]
});

// CLIENT FACING FUNCTION
// Parameter:
//	skip 	# of first results to skip, default is 0
//	limit 	# of results to return
// 	gtid	great than the given object id
//	ltid	less than the given object id
//	owner	owner of book
exports.books = function(req, db, callback){
  logger.info("booksUtil>> books start...");
  var collection = db.collection('books');

  var skip = 0;
  if (req.query.skip != null)
	  skip = parseInt(req.query.skip, 10);
  logger.info("booksUtil>> skip: " + skip);

  var limit = 5;   //default return # books
  if (req.query.limit != null)
	   limit = parseInt(req.query.limit, 10);
  logger.info("booksUtil>> limit: " + limit);

  var gtid = req.query.gtid;
  var ltid = req.query.ltid;

  var isbn = req.query.isbn;

  var owner = req.query.owner;

  var condition = [];
  if (gtid != null){
	  var gtoid = new ObjectId(gtid);
	  condition.push({_id: {$gt: gtoid}});
  }
  if (ltid != null){
	  var ltoid = new ObjectId(ltid);
	  condition.push({_id: {$lt: ltoid}});
  }
  if (isbn != null){
	  condition.push({$or:[{isbn10: isbn}, {isbn13: isbn}]});
  }
  if (owner != null){
	  condition.push({"owner": owner});
  }

  var query = {};
  if (condition.length > 0)
	query = {$and: condition};
  logger.info("booksUtil>> query: " + JSON.stringify(query));

  var order = {_id: -1};
  logger.info("booksUtil>> order: " + JSON.stringify(order));

  collection.find(query).sort(order).skip(skip).limit(limit).toArray(function(err, docs) {
    logger.info("booksUtil>> # of result: " + docs.length);
//    logger.info(docs);
    callback(docs);
  });
}

// CLIENT FACING FUNCTION
// Parameter:
//	q 		search keyword in title and author
exports.search = function(req, db, callback){
  logger.info("booksUtil>> search start...");
  var collection = db.collection('books');

  var keyword = req.query.q;
  keyword = translator.translate2(keyword);
  var regexStr = ".*" + keyword + ".*";

  var condition = [];
  if (keyword != null){
	  condition.push({$or:[
						{"title": {$regex: regexStr}},
						{"author": {$elemMatch: {$regex: regexStr}}}
					]});
  }

  var query = {};
  if (condition.length > 0)
	query = {$and: condition};
  logger.info("booksUtil>> query: " + JSON.stringify(query));

  var order = {_id: -1};
  logger.info("booksUtil>> order: " + JSON.stringify(order));

  collection.find(query).sort(order).toArray(function(err, docs) {
    logger.info("booksUtil>> # of result: " + docs.length);
//    logger.info(docs);
    callback(docs);
  });
}

// CLIENT FACING FUNCTION
// Used when user upload a book, add book info with copies info to database
exports.addBook = function(req, db, callback){
	logger.info("bookUtil>> addBook start...");

	var isbn = req.body.isbn;
	var title = req.body.title;
	var category = req.body.category;
	var owner = req.body.owner;
	var price = req.body.price;
	var deposit = req.body.deposit;
	logger.info("booksUtil>> isbn: " + isbn + ", title: " + title + ", category: " + category + ", owner: " + owner + ", price: " + price + ", deposit: " + deposit);

	var collection = db.collection('books');
	var query = {}
	mongoQuery.queryBook(db, isbn, function(docs) {
		logger.info("booksUtil >> callback from mongoQuery...")
		if(!docs.length){
			logger.info("booksUtil>> book not found in existing database, query Douban now...");
			searchAddBookFromWeb(isbn, category, owner, price, deposit, db, function(result){
				logger.info("booksUtil>> callback from searchAddBookFromWeb...")
				callback(result);
			})
		}
		else {
			logger.info("booksUtil>> book already exist in database, add new copy...")
			addCopyToExistingBook(isbn, category, owner, price, deposit, docs, db, function(result){
			logger.info("booksUtil>> callback from addCopyToExistingBook...")
			callback(result);
      })
		}
	});
}

// Sub-function of addBook.
// Search book info for the given isbn, then add the found book (if any)
// into database, update tags as well
function searchAddBookFromWeb(isbn, category, owner, price, deposit, db, callback){
  logger.info("booksUtil>> searchAddBookFromWeb start...");

  var request = require('request');
  var urlDouban = 'https://api.douban.com/v2/book/isbn/:' + isbn;
  logger.info("booksUtil>> urlDouban: " + urlDouban);

  request(urlDouban, function (error, response, body) {
    logger.info('bookUtil>> douban statusCode:', response && response.statusCode);
    logger.info('bookUtil>> douban body:', body);
    logger.info('bookUtil>> douban error:', error);

    if(response.statusCode != '200'){
      logger.info("booksUtil>> book not found in Douban, return empty");
      var result = [];
      callback(result);
    }
    else{
      logger.info("booksUtil>> book found in Douban, create new book...");
      var bookJson = createBookJsonFromDoubanResponse(body, category, owner, price, deposit);

      logger.info("booksUtil>> insert book into database...");
      mongoQuery.insertBook(db, bookJson, function(docs){
        logger.info("booksUtil>> book added into database, return book details in array")
        var result = [];
        result.push(bookJson);
        callback(result);
        logger.info("booksUtil>> return result: " + result);

        logger.info("booksUtil>> update tags from book: " + bookJson.title);
        updateTagsFromBook(bookJson, db);

    		logger.info("booksUtil>> update category from book: " + bookJson.title);
    		updateCategoryFromBook(bookJson, db);

        logger.info("booksUtil>> add new book to owner's bookshelf...");
        var book_id = bookJson["_id"];
        logger.info("booksUtil>> book_id: " + book_id);
        addNewBookToOwnersBookshelf(db, owner, book_id);

        logger.info("booksUtil>> add book done");
      });
    }
  });
}


// Sub-function of addBook.
// Add new copy for an existing book
function addCopyToExistingBook(isbn, category, owner, price, deposit, docs, db, callback){
  logger.info("booksUtil>> addCopyToExistingBook...")

  var bookJson = docs[0];
  logger.info("bookUtil>> existing book_id: " + bookJson["_id"]);
  var newBookJson = JSON.parse(JSON.stringify(bookJson));
  delete newBookJson._id;
  // delete newBookJson.category;
  newBookJson["category"] = category;

  //////////////////////////////////////////////////////////////////
  //below are obsolete, keep it temporary for downward compatible
  // var newCopy = {};
  // newCopy["owner"] = owner;
  // newCopy["price"] = price;
  // newCopy["hold_by"] = owner;
  // newCopy["status"] = "idle";
  // if (deposit != null)
  // 	newCopy["deposit"] = deposit;
  // else
  // 	newCopy["deposit"] = newBookJson["deposit"];
  // var bookCopies = [];
  // bookCopies.push(newCopy);
  // newBookJson["book_copies"] = bookCopies;
  // newBookJson["num_copies"] = 1;
  //////////////////////////////////////////////////////////////////
  newBookJson["owner"] = owner;
  newBookJson["sr_price"] = price;
  newBookJson["hold_by"] = owner;
  newBookJson["status"] = "可借閱";
  if (deposit != null)
    newBookJson["sr_deposit"] = deposit;
  else {
    logger.info("booksUtil>> user does not specify deposit, use existing deposit (shall not happen)");
  }
  //////////////////////////////////////////////////////////////////

  var datetime = new Date()
  newBookJson["add_date"] = datetime;

  var collection = db.collection('books');
	collection.insertOne(newBookJson, function(err, docs) {
		logger.info("booksUtil>> insert book complete, new book_id: " + newBookJson["_id"]);
		// logger.info(docs);
		var result = [];
		result.push(newBookJson);
		callback(result);

		logger.info("booksUtil>> update tags from book: " + newBookJson.title);
		updateTagsFromBook(newBookJson, db);

		logger.info("booksUtil>> update category from book: " + bookJson.title);
		updateCategoryFromBook(newBookJson, db);

    logger.info("booksUtil>> add new book to owner's bookshelf...");
    var book_id = newBookJson["_id"];
    logger.info("booksUtil>> book_id: " + book_id);
    addNewBookToOwnersBookshelf(db, owner, book_id);
	});
}


// Sub-function of searchBook.
// Create book json from Web/Douban reply, num of copy is 1,
// used when inserting "new" book
function createBookJsonFromDoubanResponse(body, category, owner, price, deposit){
  logger.info("bookUtil>> createBookJsonFromDoubanResponse");

  var bookJson = JSON.parse(body);

  //add customized fields
  // bookJson["our_price_hkd"] = "0";		//obsolete
  // bookJson["deposit"] = pricing.getDeposit(bookJson.price).toString();
  // bookJson["shipping_fee"] = "0";			//obsolete
  // bookJson["num_total"] = "0"				//obsolete
  // bookJson["num_onshelf"] = "0"			//obsolete
  bookJson["category"] = category;

  //////////////////////////////////////////////////////////////////
  //below are obsolete, keep it temporary for downward compatible
  // bookJson["num_copies"] = 1;
  // var bookCopies = [];
  // var bookCopy = {};
  // bookCopy["owner"] = owner
  // bookCopy["price"] = price;		//user chosen price
  // bookCopy["hold_by"] = owner;
  // bookCopy["status"] = "idle";
  // if (deposit != null)
  // 	bookCopy["deposit"] = deposit;
  // else
  // 	bookCopy["deposit"] = bookJson["deposit"];
  // bookCopies.push(bookCopy);
  // bookJson["book_copies"] = bookCopies;
  //////////////////////////////////////////////////////////////////
  bookJson["owner"] = owner;
  bookJson["sr_price"] = price;
  bookJson["hold_by"] = owner;
  bookJson["status"] = "idle";
  if (deposit != null)
  	bookJson["sr_deposit"] = deposit;
  else
  	bookJson["sr_deposit"] = pricing.getDeposit(bookJson.price).toString();
  //////////////////////////////////////////////////////////////////

  var datetime = new Date()
  bookJson["add_date"] = datetime;

  //translate Simp Chi to Trad Chi
  translate(bookJson);

  return bookJson;
}

// Sub-function used when creating books, translate various sections of books,
// including: title, summary, catalog, tags, author, publisher, author_intro
function translate(bookJson){
	if(bookJson["title"] != null){
		bookJson["title"] = translator.translate2(bookJson["title"])
	}
	if(bookJson["summary"] != null){
		bookJson["summary"] = translator.translate2(bookJson["summary"])
	}
	if(bookJson["catalog"] != null){
		bookJson["catalog"] = translator.translate2(bookJson["catalog"])
	}
	if(bookJson["tags"] != null){
		var tags = bookJson["tags"];
		for(var i=0; i<tags.length; i++){
			tags[i]["name"] = translator.translate2(tags[i]["name"]);
		}
		bookJson["tags"] = tags;
	}
	if(bookJson["author"] != null){
		var authors = bookJson["author"];
		for(var i=0; i<authors.length; i++){
			authors[i] = translator.translate2(authors[i]);
		}
		bookJson["author"] = authors;
	}
	if(bookJson["publisher"] != null){
		bookJson["publisher"] = translator.translate2(bookJson["publisher"])
	}
	if(bookJson["author_intro"] != null){
		bookJson["author_intro"] = translator.translate2(bookJson["author_intro"])
	}
}

// Sub-function of adding books
function updateTagsFromBook(book, db){
	var map = getTagsFromBook(book);
	updateTags(db, map);
}

// Sub-function of adding books
// Get tags of a book into a hashmap
function getTagsFromBook(book){
    logger.info("booksUtil>> getTagsFromBook: " + book.title);
    // logger.info("book id: " + book._id);
    // logger.info("book tags: " + book.tags);
    var map = new HashMap();

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
          logger.info("booksUtil>> this case shall not happen - suppose each tag will appear only once for a single book");
        }
      })
    } else {
      logger.info("this book has no tag");
    }

    return map;
}

// Sub-function of adding books
// Update existing tags collection with the tags info from a map {tag, book ids}
function updateTags(db, map){
  logger.info("booksUtil>> updateTags start...");
  var collection = db.collection('tags');

  map.forEach(function(value, key){
    var query = {name: key};
    collection.find(query).toArray(function(err, docs){
  		logger.info("booksUtil>> processing tag: " + key + ", " + value);
  		if (docs.length == 0){
  			logger.info("booksUtil>> tag not found in database, insert now...")
  			var tagJson = {};
  			tagJson["name"] = key;
  			tagJson["num_books"] = 1;
  			tagJson["book_ids"] = value;

  			logger.info("insert document to tags collection: " + JSON.stringify(tagJson));
  			collection.insertOne(tagJson, function(err, res){
  			  if (err) throw err;
  			  logger.info("booksUtil>> new tag inserted.");
  			})
  		} else {
  			// logger.info("booksUtil>> tag found in database, update book id...");
  			var tagJson = docs[0];
  			// logger.info("tagJson - before: " + JSON.stringify(tagJson));
  			// logger.info("value[0]: " + JSON.stringify(value[0]));
        var book_ids = tagJson["book_ids"];

        // logger.info("booksUtil>> check if current book exist, book id: " + value[0]);
        var found = false;
        for(var i=0; i<book_ids.length; i++){
          // logger.info("book id: " + book_ids[i]);
          if((book_ids[i]).equals(value[0])) {
            found = true;
            break;
          }
        }
        if(!found){
          // logger.info("booksUtil>> book id not found, insert now (otherwise skip)...")
          book_ids.push(value[0]);
    			// tagJson["book_ids"] = book_ids;
    			// logger.info("tagJson - after: " + JSON.stringify(tagJson));
          var num_books = tagJson["num_books"];
          num_books += 1;

    			var update = {$set: {num_books: num_books, book_ids: book_ids}};
    			// logger.info("booksUtil>> update: " + JSON.stringify(update));

    			collection.update(query, update, function(err, docs){
    				logger.info("booksUtil>> book id updated for tag: " + key);
    			});
        }
  		}
	});
  });
}

// Sub-function of adding books
function updateCategoryFromBook(book, db){
	logger.info("booksUtil>> updateCategoryFromBook start...");

	var bookId = book._id;
    var category = book.category;

	var collection = db.collection("categories");
	var query = {name: category};
	collection.find(query).toArray(function(err, docs){
		if(docs.length == 0){
			logger.info("booksUtil>> book category not found (this shall not happen), do nothing: " + category);
		} else {
			logger.info("booksUtil>> category found for: " + category);

			var categoryJson = docs[0];
			var book_ids = categoryJson["book_ids"];
			book_ids.push(bookId);

			var update = {$set: {book_ids: book_ids}};
			logger.info("booksUtil>> update: " + JSON.stringify(update));
			collection.update(query, update, function(err2, docs2) {
				logger.info("booksUtil>> category updated")
			});
		}
	});
}

// Sub-function of searchAddBookFromWeb
// Add an idle book (usually newly uploaded by users) to owner's bookshelf
function addNewBookToOwnersBookshelf(db, username, book_id){
  logger.info("booksUtil>> addNewBookToOwnersBookshelf start, username: "
                + username + ", book_id: " + book_id);

  var collection = db.collection("bookshelves");
  var query = {username: username};
  collection.find(query).toArray(function(err, docs){
    if(docs.length == 0){
      logger.info("booksUtil>> no bookshelf for user, create new bookshelf for: " + username);

      var bookshelfJson = {};
      bookshelfJson["username"] = username;
      bookshelfJson["num_idle_books"] = 1;
      var idle_book_ids = [];
      idle_book_ids.push(book_id);
      bookshelfJson["book_ids_idle"] = idle_book_ids;
      bookshelfJson["num_reading_books"] = 0;
      var reading_book_ids = [];
      bookshelfJson["book_ids_reading"] = reading_book_ids;
      logger.info("booksUtil>> new bookshelf: " + JSON.stringify(bookshelfJson));

      collection.insertOne(bookshelfJson, function(err, result){
        if (err) throw err;
        logger.info("bookUtil>> new bookshelf inserted.")
      });
    } else {
      logger.info("booksUtil>> existing bookshelf found for user: " + username);

      var bookshelfJson = docs[0];  // assume each user has at most one bookshelf
      var book_ids_idle = bookshelfJson["book_ids_idle"];
      var found = false;
      for(var i=0; i<book_ids_idle.length; i++){
        if((book_ids_idle[i]).equals(book_id)){
          found = true;
          break;
        }
      }
      if(!found){
        logger.info("booksUtil>> book id not found, add new...")
        book_ids_idle.push(book_id);
        bookshelfJson["book_ids_idle"] = book_ids_idle;
        var num_idle_books = bookshelfJson["num_idle_books"];
        num_idle_books += 1;
        logger.info("booksUtil>> add into bookshelf idle book id: " + book_id
                    + ", total # idle books: " + num_idle_books);

        var query2 = {username: username};
        logger.info("booksUtil>> query2: " + JSON.stringify(query2));
        var update = {$set: {num_idle_books: num_idle_books, book_ids_idle: book_ids_idle}};
        logger.info("booksUtil>> update: " + JSON.stringify(update));

        collection.update(query, update, function(err, docs){
          logger.info("booksUtil>> update complete.");
        });
      } else{
        logger.info("booksUtil>> book id exist, do nothing...")
      }
    }
  });
}

// CLIENT FACING FUNCTION
// Search book from database by isbn, if not found then search web for
// this book and insert found book info into database, then return book
// details (if any)
exports.searchBook = function(req, db, callback){
	logger.info("bookUtil>> searchBook start...");

	var isbn = req.query.isbn;
	logger.info("booksUtil>> isbn: " + isbn);

	var collection = db.collection('books');
	mongoQuery.queryBook(db, isbn, function(docs) {
		logger.info("booksUtil >> callback from mongoQuery...")
		if(!docs.length){
			logger.info("booksUtil>> book not found in existing database, query Douban now...");
			var request = require('request');
			var urlDouban = 'https://api.douban.com/v2/book/isbn/:' + isbn;
			logger.info("booksUtil>> urlDouban: " + urlDouban);

			request(urlDouban, function (error, response, body) {
				logger.info('bookUtil>> douban statusCode:', response && response.statusCode);
				logger.info('bookUtil>> douban body:', body);
				logger.info('bookUtil>> douban error:', error);

				if(response.statusCode != '200'){
					logger.info("booksUtil>> book not found in Douban, return empty");
					var result = [];
					callback(result);
				}
				else{
					logger.info("booksUtil>> book found in Douban, create new book (no copy)...");
					var bookJson = createBookJsonFromDoubanResponseNoCopy(body);

					logger.info("booksUtil>> insert book into database (no copy)...");
					mongoQuery.insertBook(db, bookJson, function(docs){
						logger.info("booksUtil>> book added into database, return book details in array")
						var result = [];
						result.push(bookJson);
						callback(result);
						logger.info("booksUtil>> return result: " + result);
						logger.info("booksUtil>> add book done");
					});
				}
			});
		}
		else {
			logger.info("booksUtil>> book already exist in database, return book info")
			callback(docs);
		}
	});
}

// Sub-function of searchBook
// Create book json from Web/Douban reply, without creating any copy,
// shall be used by searchBooks
function createBookJsonFromDoubanResponseNoCopy(body){
  logger.info("bookUtil>> createBookJsonFromDoubanResponseNoCopy");

  var bookJson = JSON.parse(body);

  //add customized fields
  // bookJson["our_price_hkd"] = "0";		//obsolete
  // bookJson["deposit"] = pricing.getDeposit(bookJson.price).toString();  //obsolete
  // bookJson["shipping_fee"] = "0";			  //obsolete
  // bookJson["num_total"] = "0"				    //obsolete
  // bookJson["num_onshelf"] = "0"			    //obsolete

  var datetime = new Date()
  bookJson["add_date"] = datetime;

  //translate Simp Chi to Trad Chi
  translate(bookJson);

  return bookJson;
}

// Find all bookshelves or the bookshelf for specific user
// For internal usages.
exports.bookshelves = function(req, db, callback){
	logger.info("booksUtil>> bookshelves start...");

	var username = req.query.username;
	logger.info("booksUtil>> username: " + username);

	var query = {};
	if (username != null)
		query = {username: username};
	logger.info("booksUtil>> query: " + JSON.stringify(query));

	var collection = db.collection('bookshelves');
	collection.find(query).toArray(function(err, docs) {
		logger.info("booksUtil>> result: ");
//		logger.info(docs);
		callback(docs);
	});
}

// CLIENT FACING FUNCTION
// Find idle books from the bookshelf of a specific user
// Return all such books without limit result number
exports.idleBooks = function(req, db, callback){
	logger.info("booksUtil>> idleBooks start...");

	var username = req.query.username;
	logger.info("booksUtil>> username: " + username);

	var query = {};
	if (username != null)
		query = {username: username};
	else
		logger.error("booksUtil>> username cannot be empty");
	logger.info("booksUtil>> query: " + JSON.stringify(query));

  var order = {_id: -1};
  logger.info("booksUtil>> order: " + JSON.stringify(order));

	var collection = db.collection('bookshelves');
	collection.find(query).sort(order).toArray(function(err, docs) {
		logger.info("booksUtil>> result: " + JSON.stringify(docs));
		if (docs.length == 0){
			logger.info("bookUtil>> bookshelf not found for user: " + username);
			var empty = [];
			callback(empty);
		} else {
      var bookshelf = docs[0];    // assume each user has at most one bookshelf
			var idle_book_ids = new HashSet();
			var book_ids = bookshelf.book_ids_idle;
			for(var j=0; j<book_ids.length; j++){
				if(!idle_book_ids.contains(book_ids[j])){
					logger.info("booksUtil>> add book id: " + book_ids[j]);
					idle_book_ids.add(book_ids[j]);
				} else {
					logger.info("booksUtil>> skip duplicate (shall not happen) book ids: " + book_ids[j]);
				}
			}

			var idle_book_ids_array = idle_book_ids.toArray();
//			logger.info("booksUtil>> idle book ids: " + JSON.stringify(idle_book_ids_array));
			logger.info("booksUtil>> idle book ids: " + idle_book_ids_array.length);

			var collectionBook = db.collection('books');
			var query_b = {_id: {$in: idle_book_ids_array}};
			logger.info("booksUtil>> query: " + JSON.stringify(query_b));

			var order = {_id: -1};
			logger.info("booksUtil>> order: " + JSON.stringify(order));

			collectionBook.find(query_b).sort(order).toArray(function(err, docs){
//				logger.info("booksUtil>> found books: " + JSON.stringify(docs));
				logger.info("booksUtil>> found books: " + docs.length);
				callback(docs);
			});
		}
	});
}
