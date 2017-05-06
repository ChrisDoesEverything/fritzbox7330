var ip = ip || (function() {
var lib = {};
lib.byteToBitstr = function(bStr) {
var str = "";
var b = parseInt(bStr, 10);
for (var i=7; i>=0; i--)
{
if (((1<<i)&b)!=0) {
str += '1';
} else {
str += '0';
}
}
return str;
};
lib.quadToBitstr = function(ipStr) {
var pattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
var str = '';
pattern.exec(ipStr);
str += lib.byteToBitstr(RegExp.$1);
str += lib.byteToBitstr(RegExp.$2);
str += lib.byteToBitstr(RegExp.$3);
str += lib.byteToBitstr(RegExp.$4);
return str;
};
lib.partsToQuad = function(prefix) {
return jxl.getValue(prefix+"0") + "." +
jxl.getValue(prefix+"1") + "." +
jxl.getValue(prefix+"2") + "." +
jxl.getValue(prefix+"3");
};
lib.analyseNet = function(ip, mask) {
var ipstr = lib.quadToBitstr(ip);
var maskstr = lib.quadToBitstr(mask);
var netpart = ipstr.substr(0, maskstr.indexOf('0'));
return { net: ipstr.substr(0, netpart.length), host: ipstr.substr(netpart.length) };
};
lib.addrInNet = function(net, ip) {
var ipstr = lib.quadToBitstr(ip);
return net.net == ipstr.substr(0, net.net.length);
};
lib.isNetAddr = function(net, ip) {
var ipstr = lib.quadToBitstr(ip);
return (ipstr.substr(net.net.length).search(/^0+$/) != -1);
};
lib.isBroadcast = function(net, ip) {
var ipstr = lib.quadToBitstr(ip);
return (ipstr.substr(net.net.length).search(/^1+$/) != -1);
};
return lib;
})();
