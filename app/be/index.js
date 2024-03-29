var http = require("http");
var server = new http.Server();
function getTimeDifference(method, time) {
  var count = time || '100000';
  console.time(method);
  while (count) {
    eval(method);
    count--;
  }
  console.timeEnd(method);
}
/*
getTimeDifference('Date.now()');
getTimeDifference('process.uptime()');
getTimeDifference('new Date().getTime()');
getTimeDifference('+ new Date()');
getTimeDifference('process.hrtime()');
*/
Date.prototype.Format = function (fmt) {
  var o = {
    "M+": this.getMonth() + 1, //月份
    "d+": this.getDate(), //日
    "H+": this.getHours(), //小时
    "m+": this.getMinutes(), //分
    "s+": this.getSeconds(), //秒
    "q+": Math.floor((this.getMonth() + 3) / 3), //季度
    "S": this.getMilliseconds() //毫秒
  };
  if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
  for (var k in o)
    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
  return fmt;
}
server.on("request", function (req, res) {
  var now = new Date().Format("yyyy-MM-dd HH:mm:ss");
  res.writeHead(200, {
    "content-type": "text/plain"
  });
  res.write(`hello nodejs!i am be with nodejs! now is: ${now}`);
  res.end();
  now = null;
});
server.listen(3001);