var mongoQuery = require('./mongoQuery');
var pricing = require('./pricing');
var translator = require('./translator');

var HashSet = require('hashset');

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/booksUtil.log' })
  ]
});

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

// Create book json from Web/Douban reply, num of copy is 1,
// used when inserting "new" book
function createBookJsonFromDoubanResponse(body, category, owner, price){
  logger.info("bookUtil>> createBookJsonFromDoubanResponse");

  var bookJson = JSON.parse(body);

  //add customized fields
  bookJson["our_price_hkd"] = "0";		//obsolete
  bookJson["deposit"] = pricing.getDeposit(bookJson.price).toString();
  bookJson["shipping_fee"] = "0";			//obsolete
  bookJson["num_total"] = "0"				//obsolete
  bookJson["num_onshelf"] = "0"			//obsolete
  bookJson["category"] = category;

  bookJson["num_copies"] = 1;
  var bookCopies = [];
  var bookCopy = {};
  bookCopy["owner"] = owner
  bookCopy["price"] = price;		//user chosen price
  bookCopy["hold_by"] = owner;
  bookCopy["status"] = "idle";
  bookCopies.push(bookCopy);
  bookJson["book_copies"] = bookCopies;

  var datetime = new Date()
  bookJson["add_date"] = datetime;

  //translate Simp Chi to Trad Chi
  translate(bookJson);

  return bookJson;
}

// Used when user upload a book, add book info with copies info to database
exports.addBook = function(req, db, callback){
	logger.info("bookUtil>> addBook start...");

	var isbn = req.body.isbn;
	var title = req.body.title;
	var category = req.body.category;
	var owner = req.body.owner;
	var price = req.body.price;
	logger.info("booksUtil>> isbn: " + isbn + ", title: " + title + ", category: " + category + ", owner: " + owner + ", price: " + price);

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
					logger.info("booksUtil>> book found in Douban, create new book...");
          var bookJson = createBookJsonFromDoubanResponse(body, category, owner, price);

          logger.info("booksUtil>> insert book into database...");
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
			logger.info("booksUtil>> book already exist in database, add new copy...")
			// logger.info(docs);

			var newCopy = {};
			newCopy["owner"] = owner;
			newCopy["price"] = price;
			newCopy["hold_by"] = owner;
			newCopy["status"] = "idle";

			var bookJson = docs[0];
			var bookCopies = bookJson["book_copies"];
      if (bookCopies == null)
        bookCopies = [];
			bookCopies.push(newCopy);

			var num_copies = bookJson["num_copies"];
      if (num_copies == null)
        num_copies = 0;
      // else
      //   num_copies = parseInt(num_copies, 10);
			num_copies += 1;

			var query = {$or: [{isbn10: isbn}, {isbn13: isbn}]};
			logger.info("booksUtil>> query: " + JSON.stringify(query));
			// logger.info(query);

			var update = {$set: {num_copies: num_copies, book_copies: bookCopies}}
			logger.info("booksUtil>> update: " + JSON.stringify(update));

			collection.update(query, update, function(err, docs) {
				logger.info("booksUtil>> update complete");
				// logger.info(docs);
        var result = [];
        result.push(bookJson);
				callback(result);
			});
		}
	});
}

// Create book json from Web/Douban reply, without creating any copy,
// shall be used by searchBooks
function createBookJsonFromDoubanResponseNoCopy(body){
  logger.info("bookUtil>> createBookJsonFromDoubanResponseNoCopy");

  var bookJson = JSON.parse(body);

  //add customized fields
  bookJson["our_price_hkd"] = "0";		//obsolete
  bookJson["deposit"] = pricing.getDeposit(bookJson.price).toString();
  bookJson["shipping_fee"] = "0";			//obsolete
  bookJson["num_total"] = "0"				//obsolete
  bookJson["num_onshelf"] = "0"			//obsolete

  var datetime = new Date()
  bookJson["add_date"] = datetime;

  //translate Simp Chi to Trad Chi
  translate(bookJson);

  return bookJson;
}

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

// Find all bookshelves or the bookshelf for specific user
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

// Find idle books from the bookshelf of a specific user
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

	var collection = db.collection('bookshelves');
	collection.find(query).toArray(function(err, docs) {
		logger.info("booksUtil>> result: " + JSON.stringify(docs));
		if (docs.length == 0){
			logger.info("bookUtil>> bookshelf not found for user: " + username);
			var empty = [];
			callback(empty);
		} else {
			var idle_book_ids = new HashSet();
			for(var i=0; i<docs.length; i++){
				var book_ids = docs[i].book_ids_idle;
				for(var j=0; j<book_ids.length; j++){
					if(!idle_book_ids.contains(book_ids[j])){
						logger.info("booksUtil>> add book id: " + book_ids[j]);
						idle_book_ids.add(book_ids[j]);
					} else {
						logger.info("booksUtil>> skip book ids: " + book_ids[j]);
					}
				}
			}
			var idle_book_ids_array = idle_book_ids.toArray();
//			logger.info("booksUtil>> idle book ids: " + JSON.stringify(idle_book_ids_array));
			logger.info("booksUtil>> idle book ids: " + idle_book_ids_array.length);

			var collectionBook = db.collection('books');
			var query_b = {_id: {$in: idle_book_ids_array}};
			collectionBook.find(query_b).toArray(function(err, docs){
//				logger.info("booksUtil>> found books: " + JSON.stringify(docs));
				logger.info("booksUtil>> found books: " + docs.length);
				callback(docs);
			});

		}
	});
}

// Get tags of a book into a hashmap
function getTagsFromBook(book){
    logger.info("booksUtil>> updateTagsFromBook: " + book.title);
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

// Update existing tags collection with the tags info from a map {tag, book ids}
function updateTags(db, map){
  logger.info("booksUtil>> updateTags start...");
  var collection = db.collection('tags');

  map.forEach(function(value, key){
    logger.info("booksUtil>> processing tag: " + key);
    var query = {name: key};

    collection.find(query)
    // logger.info("rebuild documents for tag: " + key)
    var tagJson = {};
    tagJson["name"] = key;
    tagJson["num_books"] = value.length;
    tagJson["book_ids"] = value;

    // logger.info("insert document to tags collection: " + JSON.stringify(tagJson));
    collection.insertOne(tagJson, function(err, res){
      if (err) throw err;
      // logger.info("1 document inserted for tag: " + key);
    })
  });
  logger.info("function buildTags2 complete");
}
