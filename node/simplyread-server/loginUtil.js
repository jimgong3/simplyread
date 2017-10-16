var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/loginUtil.log' })
  ]
});

// CLIENT FACING FUNCTION
// Return: [user] for success, or [] otherwise
exports.register = function(req, db, callback){
  logger.info("loginUtil>> register ");

  var username = req.body.username;
  var fullname = req.body.fullname;
  var password = req.body.password;
  var email = req.body.email;
  logger.info("loginUtil>> username: " + username + ", fullname: " + fullname + ", password: " + password
				+ ", email: " + email);

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
    		user.password2 = password;  //use password2 for encrypted password
    		if(fullname != null){
    			user.fullname = fullname;
    		}
    		if(email != null){
    			user.email = email;
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
