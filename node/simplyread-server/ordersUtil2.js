var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/ordersUtil2.log' })
  ]
});

var ObjectId = require('mongodb').ObjectId;

// CLIENT FACING FUNCTION
// Parameters:
//	- username
// 	- orderId
exports.orders = function(req, db, callback){
  logger.info("ordersUtil>> orders start...");

  var username = req.query.username;
  var orderId = req.query.orderId;
  logger.info("ordersUtil>> username: " + username + ", orderId: " + orderId);

  var condition = [];
  if (username != null)
	  condition.push({username: username});
  if (orderId != null)
	  condition.push({orderId: orderId});

  var query = {};
  if (condition.length>0)
	  query = {$and: condition};
  logger.info("ordersUtil>> query: " + JSON.stringify(query));

  var collection = db.collection('orders');
  collection.find(query).toArray(function(err, docs) {
    logger.info("ordersUtil>> # of result: " + docs.length);
//    logger.info(docs);
    callback(docs);
  });
}

// CLIENT FACING FUNCTION
// Parameters:
// 	- orderId
exports.orderDelivered = function(req, db, callback){
  logger.info("ordersUtil>> orderDelivered start...");

  var orderId = req.body.orderId;
  logger.info("ordersUtil>> orderId: " + orderId);

  var collection = db.collection('orders');
  var query = {orderId: orderId};
  logger.info("ordersUtil>> query: " + JSON.stringify(query));
  
  var statusDelivered = "delivered";
  var update = {$set: {status: statusDelivered}};
  logger.info("ordersUtil>> udpate: " + JSON.stringify(update));
  
  collection.update(query, update, function(err, docs) {
    logger.info("ordersUtil>> 1 order status updated" );	
    callback(docs);
	
	removeBooksFromHolderBookshelf(orderId, db)
  });
}

// Sub-function of orderDelivered
// After the order is marked as delivered, remove the book from the holder's bookshelf
// which will be added to the next reader's bookshelf upon he receives 
function removeBooksFromHolderBookshelf(orderId, db){
	logger.info("ordersUtil>> removeBooksFromHolderBookshelf start...");
	
	var collection = db.collection('orders');
	var query = {orderId: orderId};
	collection.find(query).toArray(function(err, docs){
		if(docs.length == 0){
			logger.info("ordersUtil>> this shall not happen, orderId not found: " + orderId);
		} else {
			var order = docs[0];
			logger.info("ordersUtil>> order: " + JSON.stringify(order));
			
			var books = order["books"];
			logger.info("ordersUtil>> # of books in order: " + books.length);

			for(var i=0; i<books.length; i++){
				logger.info("ordersUtil>> found book id: " + books[i]["book_id"]);
				var curBookId = books[i]["book_id"];
				var hold_by = books[i]["hold_by"];
				
				var collectionBooks = db.collection('books');
				var query2 = {_id: ObjectId(curBookId)};
				logger.info("ordersUtil>> query2: " + JSON.stringify(query2));
				
				collectionBooks.find(query2).toArray(function(err, docs){
					var book = docs[0]; 	//should return only one book
					var book_copies = book["book_copies"];
					var statusDelivered = "delivered";
					book_copies[0]["status"] = statusDelivered;
					
					var update = {$set: {book_copies: book_copies}};				
					logger.info("ordersUtil>> update: " + JSON.stringify(update));
					collectionBooks.update(query2, update, function(err, docs){
						logger.info("ordersUtil>> 1 book removed from holder's bookshelf");
						logger.info("ordersUtil>> result: " + JSON.stringify(docs));						
					});
				});				
			}
		}
	});
	
}

