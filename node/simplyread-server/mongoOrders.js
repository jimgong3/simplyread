var assert = require('assert');
var HashMap = require('hashmap')

var translator = require('./translator');

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/mongoOrders.log' })
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

exports.queryOrders = function(db, callback){
  logger.info("mongoOrders>> queryOrders");

  var collection = db.collection('orders');
  collection.find().toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoOrders>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

exports.queryOrdersByUser = function(db, username, callback){
  logger.info("mongoOrders>> queryOrders");

  var collection = db.collection('orders');
  var query = {username: username};
  collection.find(query).toArray(function(err, docs) {
    assert.equal(err, null);
    logger.info("mongoOrders>> result: ");
    logger.info(docs);
    callback(docs);
  });
}

function sendEmail(email, order){
  var from = "simplyreadhk@gmail.com";
  var to = email;
  var cc = "simplyreadhk@gmail.com";
  var subject = "SimplyRead: Order Confirmation";
  var text = "";
  text += "Dear Customer, \n\nThanks for submitting your order, below please find order details for your reference: "
  text += "\n\nOrder ID: " + order.orderId;
  text += "\n\nSubmitted by: " + order.username;
  text += "\n\nEmail: " + order.email;
  text += "\n\nBooks: ";
  for(var book of order.books){
    text += "\n\t";
    text += book.title;
  }
  text += "\n\nTotal number of books: " + order.num_books;
  text += "\n\nTotal price: " + order.total_price;
  text += "\n\nTotal deposit: " + order.total_deposit;
  text += "\n\nTotal shipping fee: " + order.total_shipping_fee;
  text += "\n\nGrand Total: " + order.total;
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
      logger.info('mongoOrders>> Email sent: ' + info.response);
    }
  });
}

function nextOrderId(db){
	var collection = db.collection('orders');
	collection.find().sort({_id: -1}).limit(1).toArray(function(err, docs){
		if(docs.length == 0){
			logger.info("mongoOrders>> no order yet, next order id is 1")
			return 1;	
		}else{
			var lastOrder = docs[0];
			var lastOrderId = lastOrder.orderId;
			var nextOrderId = lastOrderId + 1;
			logger.info("mongoOrders>> next order id: " + nextOrderId);
			return nextOrderId;
		}
	});
}

exports.addOrder = function(db, details, callback){
  logger.info("mongoOrders>> addOrder");

  var order = JSON.parse(details);
  logger.info("mongoOrders>> parsed order");

  var datetime = new Date()
  order["date"] = datetime;

  order["status"] = "submitted";  //inital order status
  
  var collection = db.collection('orders');
  collection.find().sort({_id: -1}).limit(1).toArray(function(err, docs){
	var orderId;
	if(docs.length == 0){
		logger.info("mongoOrders>> no order yet, next order id is 1")
		orderId = 1;	
	}else{
		var lastOrder = docs[0];
		var lastOrderId = lastOrder.orderId;
		orderId = lastOrderId + 1;
		logger.info("mongoOrders>> next order id: " + nextOrderId);
	}
	order["orderId"] = orderId;
	
	collection.insertOne(order, function(err, docs) {
		assert.equal(err, null);
		logger.info("mongoOrders>> order insert complete");

		if(order.email != null) {
		  logger.info("mongoOrders>> send email order confirmation to: " + order.email);
		  sendEmail(order.email, order);
		}
		callback(order);
	});
  });
}
