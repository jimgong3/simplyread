var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/loginUtil.log' })
  ]
});

exports.register = function(req, db, callback){
  logger.info("loginUtil>> register ");

  var username = req.body.username;
  var fullname = req.body.fullname;
  var password = req.body.password;
  var email = req.body.email;
  var shipping_address = req.body.shipping_address;
  logger.info("loginUtil>> username: " + username + ", fullname: " + fullname + ", password: " + password
				+ ", email: " + email + ", shipping address: " + shipping_address);
	
  var collection = db.collection('users');
  var query = {username: username};
  logger.info("mongoQuery>> query: ");
  logger.info(query);

  collection.find(query).toArray(function(err, docs) {
	if(docs.length > 0){
		logger.error("loginUtil>> error: username already exist, return empty");
		var result = [];
		callback(result);
	} else {
		var user = {};
		user.username = username;
		user.password = password;
		if(fullname != null){
			user.fullname = fullname;
		}
		if(email != null){
			user.email = email;
		}
		if(shipping_address != null){
			user.shipping_address = shipping_address;
		}
		
    	collection.insertOne(user, function(err, docs) {
		  logger.info("mongoQuery>> 1 user inserted");
		  var result = [];
		  result.push(user);
		  callback(result);
	  });
	}
  });
}