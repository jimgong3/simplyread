var app = require('express')();
app.set('view engine', 'pug')

var pretty = require('express-prettify');
var assert = require('assert');
var mongoQuery = require('./mongoQuery');
var pricing = require('./pricing');
var multiparty = require('multiparty');
// var multiparty = require('connect-multiparty')
// var multipartMiddleware = multiparty();
var util = require('util')
var fs = require('fs')

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/index.log' })
  ]
});

var port = 3001

var host = "localhost"
// var host = "52.221.212.21"
var httpPort = "8080"

var db
var mongoUtil = require('./mongoUtil');
mongoUtil.connectToServer( function(err){
	logger.info("app>> connected to mongodb server")
	db = mongoUtil.getDb();
})

app.use(pretty({ query: 'pretty' }));

var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.listen(port, function () {
  console.log('app>> server listening on port ' + port);
  logger.info('app>> server listening on port ' + port);
});

app.get('/', function (req, res) {
	logger.info('app>> get /');
  	res.json({ hello: 'world', body: 'This is pretty printed json' });
})

app.get('/user', function (req, res) {
	var date = new Date()
	logger.info("app>> get /user");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var username = req.query.username;
	var password = req.query.password;
	logger.info("app>> username: " + username + ", password: " + password);

	mongoQuery.queryUser(db, username, password, function(docs) {
		logger.info("app>> callback from queryUser");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> user done");
	});
})


app.get('/books', function (req, res) {
	logger.info("app>> get /books");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	mongoQuery.queryBooks(db, function(docs) {
		logger.info("app>> callback from queryBooks");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> books done");
	});
})

app.get('/book', function (req, res) {
	logger.info("app>> get book by isbn");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var isbn = req.query.isbn;
	logger.info("app>> isbn: " + isbn);

	mongoQuery.queryBook(db, isbn, function(docs) {
		logger.info("app>> callback from book by isbn");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> book by isbn done");
	});
})

app.get('/queryBookByTag', function (req, res) {
	logger.info("app>> query book by tag");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var tag = req.query.tag;
	logger.info("app>> tag: " + tag);

	mongoQuery.queryBookByTag(db, tag, function(docs) {
		logger.info("app>> callback from book by tag: " + tag);
		logger.info(docs);
		res.json(docs)
		logger.info("app>> book by tag done");
	});
})

app.get('/queryBookByCategory', function (req, res) {
	logger.info("app>> query book by category");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var category = req.query.category;
	logger.info("app>> category: " + category);

	mongoQuery.queryBookByCategory(db, category, function(docs) {
		logger.info("app>> callback from book by category: " + category);
		logger.info(docs);
		res.json(docs)
		logger.info("app>> book by category done");
	});
})

app.get('/searchAddBook', function (req, res) {
	logger.info("app>> search and add book by isbn");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var isbn = req.query.isbn;
	logger.info("app>> isbn: " + isbn);

	mongoQuery.queryBook(db, isbn, function(docs) {
		logger.info("app>> callback from queryBook");
		// console.log(docs);
		if(!docs.length){
			logger.info("app>> book not found in existing database, query Douban now");
			var request = require('request');
			var urlDouban = 'https://api.douban.com/v2/book/isbn/:' + isbn;
			logger.info("app>> urlDouban: " + urlDouban);

			request(urlDouban, function (error, response, body) {
				logger.info('error:', error); // Print the error if one occurred
				logger.info('statusCode:', response && response.statusCode); // Print the response status code if a response was received
				logger.info('body:', body); // Print the HTML for the Google homepage.

				if(response.statusCode != '200'){
					logger.info("app>> book not found in Douban, return empty")
					res.json([]);
				}
				else{
					logger.info("app>> book found in Douban, insert into database");
					var bookJson = JSON.parse(body);

					//add customized fields
					bookJson["our_price_hkd"] = "0";		// to be revised
					bookJson["deposit"] = pricing.getDeposit(bookJson.price).toString();
					bookJson["shipping_fee"] = "20";		//to be revised
					bookJson["num_total"] = "0"
					bookJson["num_onshelf"] = "0"

					var datetime = new Date()
					bookJson["add_date"] = datetime;

					//add book into bookbase
					mongoQuery.insertBook(db, bookJson, function(docs){
						logger.info("app>> book added into database, return book details in array")
						var result = [];
						result.push(bookJson);
						res.json(result);
						logger.info("app>> return result: " + result);
						logger.info("app>> add book by isbn done");
					});
				}
			});
		}
		else {
			logger.info("app>> book already exist in database, return book details")
			logger.info(docs);
			res.json(docs);
		}
		logger.info("app>> add book by isbn done");
	});
});


app.get('/addNewBook', function (req, res) {
	logger.info("app>> add new book");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	var title = req.query.title;
	var author = req.query.author;
	var isbn = req.query.isbn;
	logger.info("app>> title: " + title + ", author: " + author + ", isbn: " + isbn);


	var bookJson = {};

	//add customized fields
	bookJson["title"] = title;
	var authors = [];
	authors.push(author);
	bookJson["author"] = authors;
	bookJson["isbn"] = isbn;
	var imageUrl = "http://"+host+":"+httpPort+"/images/"+isbn+".jpeg";
	bookJson["image"] = imageUrl;

	var datetime = new Date()
	bookJson["add_date"] = datetime;

	//add book into bookbase
	mongoQuery.insertBook(db, bookJson, function(docs){
		logger.info("app>> book added into database, return book details in array")
		var result = [];
		result.push(bookJson);
		res.json(result);
		logger.info("app>> return result: " + result);
		logger.info("app>> add new book done");
	});

});

app.post('/upload', function(req, res) {
	logger.info("app>> upload");
  	logger.info("app>> req body: ")
  	logger.info(req.body);
  	logger.info("app>> req files: ")
  	logger.info(req.files);

    var form = new multiparty.Form();
    form.parse(req, function(err, fields, files) {
      var image = files.image;  //hardcode!!! multipartform data key: "image"
      var file = image[0];
      var srcFilePath = file.path;
      var destFilePath = './images/'+file.originalFilename;

      fs.rename(srcFilePath, destFilePath, function (err) {
        if (err) throw err;
        console.log('renamed complete');
      });

      res.writeHead(200, {'content-type': 'text/plain'});
      res.write('received upload:\n\n');
      res.end(util.inspect({fields: fields, files: files}));
    });

});

app.get('/web/pug', function (req, res) {
  res.render('index', {title: 'hey', message: 'hello there from pug'});
});

app.get('/tags', function (req, res) {
	logger.info("app>> get /tags");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	mongoQuery.queryTags(db, function(docs) {
		logger.info("app>> callback from queryTags");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> tags done");
	});
})

app.get('/collectTags', function (req, res) {
	logger.info("app>> get /collectTags");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	mongoQuery.collectTags(db, function(docs) {
		logger.info("app>> callback from collectTags");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> collect tags done");
	});
})

app.get('/hotTags', function (req, res) {
	logger.info("app>> get /hotTags");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

  var n = req.query.n;
  logger.info("num of tags to query: " + n);

	mongoQuery.hotTags(db, n, function(docs) {
		logger.info("app>> callback from hotTags");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> hot tags done");
	});
})

app.get('/assignBookCategory', function (req, res) {
	logger.info("app>> assign book category");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	// var isbn = req.query.isbn;
  // var category = req.query.category;
  var isbn = req.body.isbn;
  var category = req.body.category;
	logger.info("app>> isbn: " + isbn + ", category: " + category);

	mongoQuery.assignBookCategory(db, isbn, category, function(docs){
		logger.info("app>> book category assigned, return book details in array")
		var result = [];
		result.push(docs);
		res.json(result);
		logger.info("app>> return result: " + result);
		logger.info("app>> assign book category done");
	});
});

app.get('/buildCategories', function (req, res) {
	logger.info("app>> get /buildCategories");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	mongoQuery.buildCategories(db, function(docs) {
		logger.info("app>> callback from buildCategories");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> buildCategories done");
	});
})

app.get('/categories', function (req, res) {
	logger.info("app>> get /categories");

	const {headers, method, url} = req;
	logger.info("app>> method: " + method);
	logger.info("app>> url: " + url);

	mongoQuery.queryCategories(db, function(docs) {
		logger.info("app>> callback from queryCategories");
		logger.info(docs);
		res.json(docs)
		logger.info("app>> categories done");
	});
})
