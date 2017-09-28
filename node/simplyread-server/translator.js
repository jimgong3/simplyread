var chineseConv = require('chinese-conv');

//sify(text) 轉譯成簡體中文 (to Simplified Chinese)
//tify(text) 轉譯成正體中文 (to Traditional Chinese)

var winston = require('winston')
var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File)({ filename: './logs/translate.log' })
  ]
});

exports.translate = function(before, callback){
  logger.info("translator>> translate: " + before);
  var after = chineseConv.tify(before);
  logger.info("converted: " + after);
  callback(after);
}

exports.translate2 = function(before){
  logger.info("translator>> translate: " + before);
  var after = chineseConv.tify(before);
  logger.info("converted: " + after);
  return after;
}
