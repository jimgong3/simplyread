var mongoQuery = require('./mongoQuery');

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/shippingUtil.log' })
  ]
});

// CLIENT FACING FUNCTION
exports.addSfShop = function(req, db, callback){
	logger.info("shippingUtil>> addSfShop start...");

	var type = req.body.type;
	var area = req.body.area;
	var sfid = req.body.sfid;
	var address = req.body.address;
	logger.info("shippingUtil>> type: " + type + ", area: " + area + ", sfid: " + sfid + ", address: " + address);

	var collection = db.collection('sfshops');
  var query = {sfid: sfid};
  logger.info("shippingUtil>> query: " + JSON.stringify(query));
	collection.find(query).toArray(function(err, docs) {
		if(!docs.length){
			logger.info("shippingUtil>> shop not found, adding: " + area + "-" + sfid);

      var shopJson = {};
      shopJson["type"] = type;
      shopJson["area"] = area;
      shopJson["sfid"] = sfid;
      shopJson["address"] = address;
      logger.info("shippingUtil>> shopJson: " + JSON.stringify(shopJson));

      collection.insertOne(shopJson, function(err, res){
        logger.info("shippingUtil>> 1 shop inserted");
        callback(shopJson);
      });
		}
		else {
			logger.info("shippingUtil>> shop already exist in database, skip...")
      var result = [];
      callback(result);
		}
	});
}

exports.sfShops = function(req, db, callback){
	logger.info("shippingUtil>> sfShops start...");

	var collection = db.collection('sfshops');
	collection.find().toArray(function(err, docs) {
		logger.info("shippingUtil>> # of result: " + docs.length);
//		logger.info(docs);
		callback(docs);
	});
}
