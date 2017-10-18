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
//	- details	json format order details, containing below information
//					username
//					email
//					list of "book_copies"
//						book_id, isbn, title, owner, price, hold_by, deposit
//					num of books
//					total price
//					total deposit
//					shipping fee
//					grand total
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
      var orderId = 1;
			callback(orderId);
		}else{
			var lastOrder = docs[0];
			var lastOrderId = lastOrder.orderId;
			var nextOrderId = lastOrderId + 1;
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
  text += "\n\nTotal price: " + orderJson.total_price;
  text += "\n\nTotal deposit: " + orderJson.total_deposit;
  text += "\n\nTotal shipping fee: " + orderJson.total_shipping_fee;
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
function processOrder(orderJson){

}
