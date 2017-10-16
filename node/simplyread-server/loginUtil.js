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
