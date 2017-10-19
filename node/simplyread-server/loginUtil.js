var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/loginUtil.log' })
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

exports.user = function(req, db, callback){
  logger.info("loginUtil>> user start...");

  var username = req.query.username;
  var password = req.query.password;
  logger.info("loginUtil>> username: " + username + ", password: " + password);

  var collection = db.collection('users');
  var query = {username: username, $or: [{password: password}, {password2: password}]};
  logger.info("loginUtil>> query: " + JSON.stringify(query));

  collection.find(query).toArray(function(err, docs) {
    logger.info("loginUtil>> result: " + JSON.stringify(docs));
    callback(docs);
  });
}

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
  logger.info("loginUtil>> query: " + JSON.stringify(query));

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
  		  logger.info("loginUtil>> 1 user inserted");
  		  var result = [];
  		  result.push(user);
  		  callback(result);

        sendEmailRegisterSuccess(username, fullname, email);
  	  });
  	}
  });
}

function sendEmailRegisterSuccess(username, fullname, email){
  var from = "simplyreadhk@gmail.com";
  var to = email;
  var cc = "simplyreadhk@gmail.com";
  var subject = "SimplyRead: Register Successfully";
  var text = "";
  text += "Dear Customer, \n\nThanks for your registration, below please find the user account details for your reference: "
  text += "\n\nUsername: " + username;
  text += "\n\nFullname: " + fullname;
  text += "\n\nEmail: " + email;
  text += "\n\nThank you.";
  text += "\n\nSimplyRead";

  var mailOptions = {
    from: from,
    to: to,
    cc: cc,
    subject: subject,
    text: text
  };
  logger.info("loginUtil>> mailOptions: " + JSON.stringify(mailOptions));

  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      logger.info(error);
    } else {
      logger.info('loginUtil>> Email sent: ' + info.response);
    }
  });
}


// CLIENT FACING FUNCTION
exports.updateUserProfile = function(req, db, callback){
  logger.info("loginUtil>> updateUserProfile start...");
  var collection = db.collection('users');

  var username = req.body.username;
  var fullname = req.body.fullname;
  var password = req.body.password;
  var email = req.body.email;
  var phone = req.body.phone;
  var settle_f2f_enable = req.body.settle_f2f_enable;
  var settle_f2f_details = req.body.settle_f2f_details;
  var settle_sf_enable = req.body.settle_sf_enable;
  var settle_sf_area = req.body.settle_sf_area;
  var settle_sf_sfid = req.body.settle_sf_sfid;
  var settle_sf_address = req.body.settle_sf_address;

  logger.info("loginUtil>> username: " + username + ", fullname: " + fullname + ", password: " + password
				+ ", email: " + email + ", phone: " + phone
				+ ", settle_f2f_enable: " + settle_f2f_enable + ", settle_f2f_details: " + settle_f2f_details
				+ ", settle_sf_enable: " + settle_sf_enable + ", settle_sf_area: " + settle_sf_area
				+ ", settle_sf_sfid: " + settle_sf_sfid + ", settle_sf_address: " + settle_sf_address);

	var query = {username: username};
	logger.info("loginUtil>> query: " + JSON.stringify(query));

	//verify username & password

	var updateFields = {};
	updateFields["username"] = username;	//for reference
	if (fullname != null)
		updateFields["fullname"] = fullname;
	if (email != null)
		updateFields["email"] = email;
  if (phone != null)
    updateFields["phone"] = phone;

	if (settle_f2f_enable != null)
		updateFields["settle_f2f.enable"] = settle_f2f_enable;
	if (settle_f2f_details != null)
		updateFields["settle_f2f.details"] = settle_f2f_details;

	if (settle_sf_enable != null)
		updateFields["settle_sf.enable"] = settle_sf_enable;
	if (settle_sf_area != null)
		updateFields["settle_sf.area"] = settle_sf_area;
	if (settle_sf_sfid != null)
		updateFields["settle_sf.sfid"] = settle_sf_sfid;
	if (settle_sf_address != null)
		updateFields["settle_sf.address"] = settle_sf_address;

	var update = {$set: updateFields};
    logger.info("loginUtil>> update: " + JSON.stringify(update));

	collection.update(query, update, function(err, docs){
		logger.info("loginUtil>> 1 user profile updated");
		callback(docs);
	});
}
