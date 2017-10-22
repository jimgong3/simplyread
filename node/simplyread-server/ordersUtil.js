var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/ordersUtil.log' })
  ]
});

var nodemailer = require('nodemailer');
var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'simplyreadhk@gmail.com',
    pass: 'hkSimply'
  }
});

// CLIENT FACING FUNCTION
// Parameters:
//	- username
// 	- orderId
exports.orders = function(req, db, callback){
  logger.info("ordersUtil>> orders start...");

  var username = req.query.username;
  var orderId;
  if (req.query.orderId != null)
	  orderId = parseInt(req.query.orderId, 10);
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
//	- details	json format order details, containing below information
//					username
//					email
//					list of "book_copies"
//						book_id, isbn, title, owner, price, hold_by, deposit
//					num_of_books
//					sum_price
//					sum_deposit
//					shipping_fee
//					total
exports.submitOrder = function(req, db, callback){
  logger.info("ordersUtil>> ordersUtil start...");
  var collection = db.collection('orders');

  var details = req.body.details;
  logger.info("ordersUtil>> orderDetails: " + details);

  var orderJson = JSON.parse(details);
//  logger.info("ordersUtil>> parsed order: " + JSON.stringify(orderJson));

  var datetime = new Date()
  orderJson["date"] = datetime;

  orderJson["status"] = "submitted";

  nextOrderId(db, function(orderId){
    orderJson["orderId"] = orderId;

    collection.insertOne(orderJson, function(err, docs) {
  		logger.info("ordersUtil>> 1 order insert complete");
  		callback(orderJson);

      processNewOrder(orderJson, db);

  		if(orderJson.email != null) {
  		  logger.info("ordersUtil>> send email order confirmation to: " + orderJson.email);
  		  sendOrderConfirmation(orderJson.email, orderJson);
  		}
  	});
  });
}

// Sub-function of submitOrder
function nextOrderId(db, callback){
	var collection = db.collection('orders');
	collection.find().sort({_id: -1}).limit(1).toArray(function(err, docs){
		if(docs.length == 0){
			logger.info("ordersUtil>> no order yet, next order id is 1")
      var orderId = "1";
			callback(orderId);
		}else{
			var lastOrder = docs[0];
			var lastOrderId = parseInt(lastOrder.orderId, 10);
			var nextOrderId = (lastOrderId + 1).toString();
			logger.info("ordersUtil>> next order id: " + nextOrderId);
			callback(nextOrderId);
		}
	});
}

// Sub-function of submitOrder
function sendOrderConfirmation(email, orderJson){
  var from = "simplyreadhk@gmail.com";
  var to = email;
  var cc = "simplyreadhk@gmail.com";
  var subject = "SimplyRead: Order Confirmation";
  var text = "";
  text += "Dear Customer, \n\nThanks for submitting your order, below please find order details for your reference: "
  text += "\n\nOrder ID: " + orderJson.orderId;
  text += "\n\nSubmitted by: " + orderJson.username;
  text += "\n\nEmail: " + orderJson.email;
  text += "\n\nBooks: ";
  if (orderJson.books != null){
    for(var book of orderJson.books){
      text += "\n\t";
      text += book.title;
    }
  }
  text += "\n\nTotal number of books: " + orderJson.num_books;
  text += "\n\nTotal price: " + orderJson.sum_price;
  text += "\n\nTotal deposit: " + orderJson.sum_deposit;
  text += "\n\nTotal shipping fee: " + orderJson.shipping_fee;
  text += "\n\nGrand Total: " + orderJson.total;
  text += "\n\nThank you.";
  text += "\n\nSimplyRead";

  var mailOptions = {
    from: from,
    to: to,
    subject: subject,
    text: text
  };

  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      logger.info(error);
    } else {
      logger.info('ordersUtil>> Email sent: ' + info.response);
    }
  });
}

// Sub-function of submitOrder
function processNewOrder(orderJson, db){
	logger.info("ordersUtil>> processOrder start...");

	logger.info("ordersUtil>> 1: generate cash transactions");
  generateCashTxn(orderJson, db, function(transactions){
    logger.info("ordersUtil>> callback from generateCashTxn...");
    saveCashTxn(transactions, db, function(result){
      logger.info("ordersUtil>> callback from saveCashTxn...")
    })

    logger.info("ordersUtil>> 2: update balances");
    updateBalances(transactions, db);
  });

	//AOB
}

function updateBalances(transactions, db){
  logger.info("ordersUtil>> updateBalances start...");

  for(var i=0; i<transactions.length; i++){
    var txn = transactions[i];
    logger.info("ordersUtil>> processing txn: " + JSON.stringify(txn));
    updateBalanceForTxn(txn, db);
  }
}

function updateBalanceForTxn(txn, db){
  logger.info("ordersUtil>> updateBalanceForTxn start...");

  var username = txn["account"];
  var query = {username: username};
  var collection = db.collection("balances");

  collection.find(query).toArray(function(err, docs){
    if(docs.length == 0) {
      logger.error("ordersUtil>> this shall not happen - each user should have a balance a/c in place: " + username);
    } else {
      var balJson = docs[0];  //each user should have only one balance a/c
      // var curUsername = balJson["username"];

      var amount = txn["amount"];
      var flag = amount[0]; //+/-
      var amountInt = parseInt(amount.substring(1), 10);
      // var lastBalance = 0;
      // if (balJson["balance"] != null)
      //   lastBalance = balJson["balance"];
      // var newBalance = lastBalance + amountInt
      // if (flag = '-')
      //   newBalance = lastBalance - amountInt;
      if (flag == '-')
        amountInt = 0 - amountInt;

      var update = {$inc: {balance: amountInt}};
      logger.info("ordersUtil>> txn: " + JSON.stringify(txn));          //for ref
      logger.info("ordersUtil>> update: " + JSON.stringify(update));
      collection.update(query, update, function(err, result){
        logger.info("ordersUtil>> 1 record updated");
      })
    }
  });
}

// Sub-function of processNewOrder
function generateCashTxn(orderJson, db, callback){
	logger.info("ordersUtil>> generateCashTxn start...");
	var transactions = [];

	logger.info("ordersUtil>> 1: debit total price from borrower");
	var txn1 = {};
	txn1["date"] = orderJson["date"];
	txn1["account"] = orderJson["username"];
  txn1["amount"] = "-" + orderJson["sum_price"];
	txn1["description"] = "扣除借閱費，訂單號碼：" + orderJson["orderId"];
	transactions.push(txn1);
  logger.info("ordersUtil>> txn1: " + JSON.stringify(txn1));

	logger.info("ordersUtil>> 2: debit deposit from borrower");
	var txn2 = {};
	txn2["date"] = orderJson["date"];
	txn2["account"] = orderJson["username"];
  txn2["amount"] = "-" + orderJson["sum_deposit"];
	txn2["description"] = "扣除圖書按金， 訂單號碼：" + orderJson["orderId"];
	transactions.push(txn2);
  logger.info("ordersUtil>> txn2: " + JSON.stringify(txn2));

	logger.info("ordersUtil>> 3: debit shipping fee from borrower");
	var txn3 = {};
	txn3["date"] = orderJson["date"];
	txn3["account"] = orderJson["username"];
  txn3["amount"] = "-" + orderJson["shipping_fee"];
	txn3["description"] = "扣除運費， 訂單號碼：" + orderJson["orderId"];
	transactions.push(txn3);
  logger.info("ordersUtil>> txn3: " + JSON.stringify(txn3));

	logger.info("ordersUtil>> 4: credit rent to owner for each book");
	var books = orderJson["books"];
	for (var i=0; i<books.length; i++) {
		var book = books[i];
		var txn4 = {};
		txn4["date"] = orderJson["date"];
		txn4["account"] = book["owner"];
    txn4["amount"] = "+" + book["price"];
		txn4["description"] = "圖書被借出，收取借閱費， 訂單號碼：" + orderJson["orderId"];
		transactions.push(txn4);
    logger.info("ordersUtil>> txn4: " + JSON.stringify(txn4));
	}

	// ASSUMPTION: 	all the books from one order are held by a "single" holder
	// 				(otherwise to split into multiple orders in front-end)
	logger.info("ordersUtil>> 5: credit shipping cash back to holder for each book, $15 every 3 books");
	var txn5 = {};
	var book0 = books[0];
	txn5["date"] = orderJson["date"];
	txn5["account"] = book0["hold_by"];	//any holder
  var amtShippingCashBack = 15 * Math.ceil(books.length / 3);
  txn5["amount"] = "+" + amtShippingCashBack.toString();
	txn5["description"] = "轉借運費回贈，訂單號碼：" + orderJson["orderId"];
	transactions.push(txn5);
  logger.info("ordersUtil>> txn5: " + JSON.stringify(txn5));

  logger.info("ordersUtil>> 6: credit deposit to system deposit reserve account");
  var txn6 = {};
	txn6["date"] = orderJson["date"];
	txn6["account"] = "simplyread-deposit";	//any holder
  txn6["amount"] = "+" + orderJson["sum_deposit"];
	txn6["description"] = "圖書按金暫存到系統按金帳戶，訂單號碼：" + orderJson["orderId"];
	transactions.push(txn6);
  logger.info("ordersUtil>> txn6: " + JSON.stringify(txn6));

  logger.info("ordersUtil>> 7: credit shipping fee delta to system shipping reserve");
  var txn7 = {};
  txn7["date"] = orderJson["date"];
  txn7["account"] = "simplyread-shipping";	//any holder
  var amtShippingDelta = parseInt(orderJson["shipping_fee"], 10) - amtShippingCashBack;
  txn7["amount"] = "+" + amtShippingDelta.toString();
  txn7["description"] = "運費差價存入系統運費帳戶，訂單號碼：" + orderJson["orderId"];
  transactions.push(txn7);
  logger.info("ordersUtil>> txn7: " + JSON.stringify(txn7));

  logger.info("ordersUtil>> # of transactions: " + transactions.length);
  callback(transactions);
}

// Sub-function of processNewOrder
function saveCashTxn(transactions, db, callback){
  var collection = db.collection('cashbook');
  collection.insert(transactions, function(err, result){
    logger.info("ordersUtil>> # of cash txn inserted: " + transactions.length);
    callback(result);
  })
}

// CLIENT FACING FUNCTION
exports.balances = function(req, db, callback){
	logger.info("ordersUtil>> balances start...");

  var username = req.query.username;
	logger.info("ordersUtil>> username: " + username);

	var query = {};
  if(username != null)
    query = {username: username};
	logger.info("ordersUtil>> query: " + JSON.stringify(query));

	var collection = db.collection('balances');
	collection.find(query).toArray(function(err, docs) {
		logger.info("ordersUtil>> # of results: " + docs.length);
//		logger.info(docs);
		callback(docs);
	});
}

// CLIENT FACING FUNCTION
exports.cashbook = function(req, db, callback){
	logger.info("ordersUtil>> cashbook start...");

  var username = req.query.username;
	logger.info("ordersUtil>> username: " + username);

	var query = {};
  if(username != null)
    query = {account: username};
	logger.info("ordersUtil>> query: " + JSON.stringify(query));

	var collection = db.collection('cashbook');
	collection.find(query).toArray(function(err, docs) {
		logger.info("ordersUtil>> # of results: " + docs.length);
//		logger.info(docs);
		callback(docs);
	});
}
