var assert = require('assert');

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/pricing.log' })
  ]
});

exports.getDeposit = function(originalPrice, callback){
  logger.info("pricing>> get deposit, original price: " + originalPrice);

  var deposit = "100";  //default deposit
  
  if(originalPrice == null) {
	  logger.error("pricing>> originalPrice is null, return default deposit");
	  return deposit;
  }

  //get original ccy
  var originalCcy = "HKD";  //default HKD
  if(originalPrice.indexOf("NT")>-1){
    logger.info("pricing>>  original ccy: NT")
    originalCcy = "NT";
  }
  else if(originalPrice.indexOf("新台幣")>-1){
    logger.info("pricing>>  original ccy: NT")
    originalCcy = "NT";
  }
  else if(originalPrice.indexOf("元")>-1){
    logger.info("pricing>>  original ccy: CNY")
    originalCcy = "CNY";
  }
  else if(originalPrice.indexOf("TWD")>-1){
    logger.info("pricing>>  original ccy: NT")
    originalCcy = "NT";
  }
  else if(originalPrice.indexOf("NTD")>-1){
    logger.info("pricing>>  original ccy: NT")
    originalCcy = "NT";
  }

  //get original amount
  var originalAmt = originalPrice;
  originalAmt = originalAmt.replace("新台幣","");
  originalAmt = originalAmt.replace("HKD","");
  originalAmt = originalAmt.replace("TWD","");
  originalAmt = originalAmt.replace("HK","");
  originalAmt = originalAmt.replace("NTD","");
  originalAmt = originalAmt.replace("NT","");
  originalAmt = originalAmt.replace("元","");
  originalAmt = originalAmt.replace("$","");

  //calculate deposit
  if (originalCcy == "HKD")
    deposit = originalAmt;
  else if (originalCcy == "NT")
    deposit = Math.trunc(originalAmt / 3);
  else if (originalCcy == "CNY")
    deposit = Math.trunc(originalAmt * 1.5);

  //float to int
  var result = parseInt(deposit, 10);
  if (result == null || isNaN(result)) {
    logger.error("pricing>> original price not found, use default deposit");
    result = 100;     //default deposit 100
  }

  logger.info("get deposit: " + result);
  return result.toString();
}
