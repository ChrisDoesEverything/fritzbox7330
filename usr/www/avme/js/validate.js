var val = val || (function() {
var lib = {};
var global = this;
var doc = global.document;
var markparts = null;
var errorIds = {};
lib.ok = "ok";
lib.notfound = "notfound";
lib.empty = "empty";
lib.different = "different";
lib.notdifferent = "notdifferent";
lib.outofrange = "outofrange";
lib.wrong = "wrong";
lib.format = "format";
lib.missing = "missing";
lib.tooshort = "tooshort";
lib.toolong = "toolong";
lib.toomuch = "toomuch";
lib.group = "group";
lib.outofnet = "outofnet";
lib.thenet = "thenet";
lib.broadcast = "broadcast";
lib.thebox = "thebox";
lib.nomask = "nomask";
lib.unsized = "unsized";
lib.notempty = "notempty";
lib.zero ="zero";
lib.notzero ="notzero";
lib.allzero = "allzero";
lib.ewemeternet = "ewemeternet";
lib.leadchar = "leadchar";
lib.endchar = "endchar";
lib.reservednet = "reservednet";
lib.greaterthan = "greaterthan";
lib.equalerr = "equalerr";
lib.active = false;
function mark(id) {
if (markparts==null) {
markparts = {};
}
markparts[id] = true;
}
function unmark(id) {
if (markparts && markparts[id]) {
markparts[id] = null;
}
}
lib.constError = function(idOrElement, errname) {
if (errname && lib[errname]) {
return lib[errname];
}
return lib.ok;
};
lib.notEmpty = function(idOrElement) {
var elem = jxl.get(idOrElement);
if (elem) {
if (jxl.getValue(elem).length > 0) {
return lib.ok
}
else {
return lib.empty;
}
}
return lib.notfound;
};
lib.noLeadChar = function(idOrElement,character) {
var elem = jxl.get(idOrElement);
if (elem) {
if (elem.value.charAt(0) == String.fromCharCode(character))
return lib.leadchar
}
return lib.ok;
};
lib.noEndChar = function(idOrElement,character) {
var elem = jxl.get(idOrElement);
if (elem) {
var len=elem.value.length-1;
if (elem.value.charAt(len) == String.fromCharCode(character))
return lib.endchar
}
return lib.ok;
};
lib.notEmptyOrAbsent = function(idOrElement) {
var elem = jxl.get(idOrElement);
if (elem && !elem.disabled && elem.value.length == 0) {
return lib.empty;
}
return lib.ok;
};
lib.equal = function(pass, confirm) {
if (jxl.getValue(pass) != jxl.getValue(confirm))
{
return lib.different;
}
return lib.ok;
};
lib.notEquals = function(elem) {
if (!elem)
{
return lib.notfound;
}
var n = arguments.length;
for (var i = 1; i < n; i++){
if (arguments[i].toLowerCase() == jxl.getValue (elem).toLowerCase() )
return lib.equalerr;
}
return lib.ok;
};
lib.lessThan = function(elem1, elem2) {
var value1 = Number(jxl.getValue (elem1));
var value2 = Number(jxl.getValue (elem2));
if (isNaN(value1) || isNaN(value2))
{
return lib.format;
}
if (value1 == value2)
{
return lib.equalerr;
}
if (value1 > value2)
{
return lib.greaterthan;
}
return lib.ok;
};
lib.notEqualIp = function(ip1, ip2) {
var res = lib.ok;
var ip_1=""
var ip_2=""
unmark(ip1);
unmark(ip2);
for (var i=0; i<4; i++) {
var eid = ip1 + String(i);
ip_1+=jxl.getValue(eid)
eid = ip2 + String(i);
ip_2+=jxl.getValue(eid)
}
if (ip_1 == ip_2)
{
mark(ip2);
return lib.notdifferent;
}
return lib.ok;
};
lib.charRangeRegex = function(idOrElement, regex)
{
var elem = jxl.get(idOrElement);
if (elem)
{
var str = jxl.getValue(elem);
if (!(str.match(regex)))
{
return lib.outofrange;
}
return lib.ok;
}
return lib.notfound;
};
lib.charRange = function(idOrElement, min, max) {
var elem = jxl.get(idOrElement);
if (elem) {
var str = jxl.getValue(elem);
for (var i=0, len=str.length; i<len; i++) {
var code = str.charCodeAt(i);
if (code < min || code > max)
{
return lib.outofrange;
}
}
return lib.ok;
}
return lib.notfound;
};
lib.f6rdPrefixlen = function(idOrElement1, idOrElement2) {
var masklen = parseInt(jxl.get(idOrElement1).value);
var preflen = parseInt(jxl.get(idOrElement2).value);
if ((preflen + (32 - masklen)) > 64) {
return lib.outofrange;
}
return lib.ok;
}
lib.numRange = function(idOrElement, min, max, bNotEmpty) {
var elem = jxl.get(idOrElement);
if (elem) {
var szNum = jxl.getValue(elem);
if (szNum.length == 0) {
if ( bNotEmpty == "true") {
return lib.empty;
} else {
return lib.ok;
}
}
if (szNum.match("[^0-9]") != null) {
return lib.format;
}
var num = Number( szNum);
if (num < Number(min) || num > Number(max)) {
return lib.outofrange;
}
return lib.ok;
}
if ( bNotEmpty == "true") {
return lib.notfound;
} else {
return lib.ok;
}
};
lib.maxNum = function(idOrElement, max, bNotEmpty) {
var elem = jxl.get(idOrElement);
if (elem) {
var szNum = jxl.getValue(elem);
if (szNum.length == 0) {
if ( bNotEmpty == "true") {
return lib.empty;
} else {
return lib.ok;
}
}
if (szNum.match("[^0-9]") != null) {
return lib.format;
}
var num = Number( szNum);
if (num > Number(max)) {
return lib.outofrange;
}
return lib.ok;
}
if ( bNotEmpty == "true") {
return lib.notfound;
} else {
return lib.ok;
}
};
lib.minNum = function(idOrElement, min, bNotEmpty) {
var elem = jxl.get(idOrElement);
if (elem) {
var szNum = jxl.getValue(elem);
if (szNum.length == 0) {
if ( bNotEmpty == "true") {
return lib.empty;
} else {
return lib.ok;
}
}
if (szNum.match("[^0-9]") != null) {
return lib.format;
}
var num = Number( szNum);
if (Number(min) > num) {
return lib.outofrange;
}
return lib.ok;
}
if ( bNotEmpty == "true") {
return lib.notfound;
} else {
return lib.ok;
}
};
lib.fwPortRange = function(idOrElement1, idOrElement2, bNotEmpty) {
var ret1 = lib.ok;
var ret2 = lib.ok;
if ( jxl.getValue(jxl.get(idOrElement1)) == "") {
ret1 = lib.empty;
}
if ( jxl.getValue(jxl.get(idOrElement2)) == "") {
ret2 = lib.empty;
}
if ((ret1 == lib.empty) && ( ret2 == lib.ok)) {
return lib.wrong;
}
if ((ret1 == lib.ok) && ( ret2 == lib.empty)) {
return lib.ok;
}
if ((ret1 == lib.empty) && ( ret2 == lib.empty)) {
if ( bNotEmpty == "true") {
return lib.missing;
} else {
return lib.ok;
}
}
var num1 = Number( jxl.getValue(jxl.get(idOrElement1)));
var num2 = Number( jxl.getValue(jxl.get(idOrElement2)));
if ( num2 < num1) {
return lib.outofrange;
}
if ( ret1 != lib.ok) return ret1;
if ( ret2 != lib.ok) return ret2;
return lib.ok;
}
lib.interfaceId = function( idOrElementPrefix) {
var ret = lib.ok;
var arElemValue = new Array();
for (var i=0; i<4; i++) {
var eid = idOrElementPrefix + String(i+1);
unmark(eid);
var elem = jxl.get(eid);
if (elem) {
arElemValue[i] = jxl.getValue(elem);
} else {
arElemValue[i] = "";
}
}
if (( arElemValue[0] == "" ) && ( arElemValue[1] == "") &&
( arElemValue[2] == "" ) && ( arElemValue[3] == "")) {
mark((idOrElementPrefix + String(1)));
mark((idOrElementPrefix + String(2)));
mark((idOrElementPrefix + String(3)));
mark((idOrElementPrefix + String(4)));
return lib.empty;
}
var bWrong = true;
for (var i=0; i<4; i++) {
var temp = Number(arElemValue[i]);
if ( !(( arElemValue[i] == "" ) || ( Number(arElemValue[i]) == 0))) {
bWrong = false;
}
}
if ( bWrong == true) {
mark((idOrElementPrefix + String(1)));
mark((idOrElementPrefix + String(2)));
mark((idOrElementPrefix + String(3)));
mark((idOrElementPrefix + String(4)));
return lib.wrong;
}
unmark((idOrElementPrefix + String(1)));
unmark((idOrElementPrefix + String(2)));
unmark((idOrElementPrefix + String(3)));
unmark((idOrElementPrefix + String(4)));
return lib.ok;
}
lib.nativePrefix = function(idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var szValue = jxl.getValue(jxl.get(idOrElement));
if ( szValue.match("[^0-9\a-f\A-F\#\:\.]")!= null) {
return lib.format;
}
if ((szValue.substr( 0, 2) == "::") && (szValue.length > 2)) {
return lib.wrong;
}
return lib.ok;
}
lib.nativeInterfaceId = function( idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var szValue = jxl.getValue(jxl.get(idOrElement));
if ( szValue.match("[^0-9\a-f\A-F\#\:]")!= null) {
return lib.format;
}
if ( szValue.substr( 0, 2) != "::") {
return lib.missing;
}
return lib.ok;
}
lib.ipv6 = function( idOrElement) {
function lCountPattern( szValue, szPattern) {
var nRet = 0;
var nPos = 0;
do {
nPos = szValue.indexOf( szPattern, (nPos +1))
if ( nPos != (-1)) {
nRet += 1;
szValue = szValue.substr( nPos);
}
} while ( nPos != (-1));
return nRet;
}
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var szValue = jxl.getValue(jxl.get(idOrElement));
if ( szValue.match("[^0-9\a-f\A-F\#\:.]")!= null) {
return lib.format;
}
var nCount = lCountPattern( szValue, "::");
if ( nCount > 1) {
return lib.toomuch;
}
return lib.ok;
}
lib.length = function(idOrElement, min, max,param1) {
var elem = jxl.get(idOrElement);
if (elem) {
var str = jxl.getValue(elem);
if (param1=="empty_allowed" && str.length==0) return lib.ok;
if (str.length < min) return lib.tooshort;
if (str.length > max) return lib.toolong;
return lib.ok;
}
return lib.notfound;
};
lib.isNumIn = function( idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var elem = jxl.get(idOrElement);
var strValue = jxl.getValue(elem);
if ( strValue.match("[^0-9\#]")!= null) {
return lib.format;
}
return lib.ok;
};
lib.isNumInEnh = function( idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var elem = jxl.get(idOrElement);
var strValue = jxl.getValue(elem);
if ( strValue.match("[^0-9\#*]")!= null) {
return lib.format;
}
return lib.ok;
};
lib.isNumOut = function( idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var elem = jxl.get(idOrElement);
var strValue = jxl.getValue(elem);
if ( strValue.match("[^0-9]")!= null) {
return lib.format;
}
for (var i=1; i<arguments.length; i++) {
if ( strValue == arguments[i])
return lib.wrong;
}
return lib.ok;
}
lib.radioSet = function(idOrElement) {
var opts = doc.getElementsByName(idOrElement);
if (opts.length==0) return lib.notfound;
for (var i=0; i<opts.length; i++) {
if (jxl.getChecked(opts[i]))
{
for (var j=1; j<arguments.length; j++) {
if (jxl.getValue(opts[i]) == arguments[j])
return lib.ok;
}
break;
}
}
return lib.missing;
};
lib.pwdChanged = function(idOrElement) {
var val = jxl.getValue(idOrElement);
if (val == "****") {
return lib.notdifferent;
}
return lib.ok;
};
lib.portFwIpAdr = function(idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var szValue = jxl.getValue(idOrElement);
var ipv4 = (szValue.search(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:?\d{0,5}$/i)!=-1);
if ( ipv4) {
var arIPv4 = szValue.split(".");
for( var i=0; i<arIPv4.length; i++) {
if ( (Number( arIPv4[i]) < 0) || (Number( arIPv4[i]) > 255))
return lib.outofrange;
}
if ((Number( arIPv4[0]) == 0) && (Number( arIPv4[1]) == 0) && (Number( arIPv4[2]) == 0) && (Number( arIPv4[3]) == 0))
return lib.allzero;
//DEFECT 7054 In einem bestimmten Szenario darf die letzte Zahl auch 255 sein.
//if (Number( arIPv4[3] == 0))
// return lib.zero;
//if (Number( arIPv4[3] == 255))
// return lib.broadcast;
return lib.ok;
} else {
var ipv6 = (szValue.search(/^\[?[\da-f:]+\]?:?\d{0,5}$/i)!=-1);
if ( ipv6) {
return lib.ok;
} else {
return lib.format;
}
}
};
lib.portFwPortValues = function(startPort,endPort,fwPort) {
unmark(startPort);
unmark(endPort);
unmark(fwPort);
var ret = lib.notEmpty(startPort);
if (ret != lib.ok) {
mark(startPort);
return ret;
}
var ret = lib.notEmpty(fwPort);
if (ret != lib.ok) {
mark(fwPort);
return ret;
}
var startValue = jxl.getValue(startPort);
var endValue = jxl.getValue(endPort);
var fwValue = jxl.getValue(fwPort);
if ( isNaN(startValue)) {
mark( startPort);
return lib.format;
}
if ( isNaN(endValue)) {
mark( endPort);
return lib.format;
}
if ( isNaN(fwValue)) {
mark( fwPort);
return lib.format;
}
if ((Number(startValue) < 0) || (Number(startValue) > 65535)) {
mark(startPort);
return lib.outofrange;
}
if ((Number(endValue) < 0) || (Number(endValue) > 65535)) {
mark(endPort);
return lib.outofrange;
}
if ((Number(fwValue) < 0) || (Number(fwValue) > 65535)) {
mark(fwPort);
return lib.outofrange;
}
if ( Number(startValue) > Number(endValue)) {
mark(startPort);
mark(endPort);
return lib.wrong;
}
return lib.ok;
}
lib.email = function(idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
if (jxl.getValue(idOrElement).search(/^[\w.%\+\-]+@[\da-z\.\-]+\.[a-z]{2,6}$/i)==-1)
return lib.format;
return lib.ok;
};
lib.fonbookEmails = function(idPrefix) {
var elems = jxl.walkDom(window.document, "input", function(el) {
return (el.type == 'text' && el.id && el.id.indexOf(idPrefix) == 0);
});
var result = lib.ok;
errorIds[idPrefix] = [];
for (var i = 0; i < elems.length; i++) {
var elem = elems[i];
if (lib.notEmpty(elem) == lib.ok) {
var currResult = lib.email(elem);
if (currResult == lib.format) {
errorIds[idPrefix].push(elem.id);
result = lib.format;
}
}
}
return result;
};
lib.emailList = function(idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var addrs = jxl.getValue(idOrElement).split(',');
for (var i=0; i<addrs.length; i++) {
addrs[i] = addrs[i].replace(/^\s+/,"");
addrs[i] = addrs[i].replace(/\s+$/,"");
if (addrs[i].length > 0 && addrs[i].search(/^[\w.%\+\-]+@[\da-z\.\-]+\.[a-z]{2,6}$/i)==-1)
return lib.format;
}
return lib.ok;
};
lib.clockTime = function(hours, minutes) {
var ret = lib.notEmpty(hours);
if (ret == lib.ok) ret = lib.notEmpty(minutes);
if (ret != lib.ok)
return ret;
var nHours = Number(jxl.getValue(hours));
var nMinutes = Number(jxl.getValue(minutes));
if (isNaN(nHours) || isNaN(nMinutes)) {
return lib.format;
}
if ((nHours < 0) || (nHours > 24) || (nMinutes < 0) || (nMinutes > 59) || (nHours == 24 && nMinutes > 0)) {
return lib.outofrange;
}
return lib.ok;
};
lib.clockDuration = function(hours, minutes) {
var res = lib.ok;
var nHours = Number(jxl.getValue(hours));
var nMinutes = Number(jxl.getValue(minutes));
unmark(hours);
unmark(minutes);
if (isNaN(nHours)) {
mark(hours);
res = lib.format;
}
if (isNaN(nMinutes)) {
mark(minutes);
res = lib.format;
}
if (res!=lib.ok) return res;
if ((nHours < 0) || (nHours > 24)) {
mark(hours);
res = lib.outofrange;
}
if ((nMinutes < 0) || (nMinutes > 59)) {
mark(minutes);
res = lib.outofrange;
}
if (res!=lib.ok) return res;
if ((nHours == 24) && (nMinutes != 0)) {
mark(hours);
return lib.outofrange;
}
return lib.ok;
};
lib.server = function(idOrElement) {
var ret = lib.notEmpty(idOrElement);
if (ret != lib.ok)
return ret;
var fqdn = (jxl.getValue(idOrElement).search(/^[\da-z\.\-]+\.[a-z]{2,6}:?\d{0,5}$/i)!=-1);
var ipv4 = (jxl.getValue(idOrElement).search(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:?\d{0,5}$/i)!=-1);
var ipv6 = (jxl.getValue(idOrElement).search(/^\[?[\da-f:]+\]?:?\d{0,5}$/i)!=-1);
return (fqdn || ipv4 || ipv6) ? lib.ok : lib.format;
};
lib.mac = function(prefix) {
var res = lib.ok;
for (var i=0; i<6; i++) {
var eid = prefix + String(i);
unmark(eid);
var val = jxl.getValue(eid);
if (val=="") {
mark(eid);
if (res==lib.ok) res = lib.empty;
}
else if (val.search(/^[0-9a-f]{2}$/i)==-1) {
mark(eid);
if (res==lib.ok) res = lib.format;
} else if (i==0 && parseInt(val,16) & 1 == 1) {
mark(eid);
if (res==lib.ok) res = lib.group;
}
}
return res;
};
lib.ipv4 = function(prefix,param1,param2,param3) {
var res = lib.ok;
function check_empty()
{
for (var i=0; i<4; i++) {
var eid = prefix + String(i);
var val = jxl.getValue(eid);
if (val!="") {return false;}
}
return true
}
function check_zero()
{
for (var i=0; i<4; i++) {
var eid = prefix + String(i);
var val = jxl.getValue(eid);
if (val!="0") {return false;}
}
return true
}
function check_ip()
{
for (var i=0; i<4; i++) {
var eid = prefix + String(i);
unmark(eid);
var val = jxl.getValue(eid);
if (val=="") {
mark(eid);
if (res==lib.ok) res = lib.empty;
}
else if (isNaN(val)) {
mark(eid);
if (res==lib.ok) res = lib.format;
}
else if (parseInt(val, 10) < 0 || parseInt(val, 10) > 255) {
mark(eid);
if (res==lib.ok) res = lib.outofrange;
}
}
}
if (param1=="zero_not_allowed" || param2=="zero_not_allowed" || param3=="zero_not_allowed")
{
if (check_zero())
{
res=lib.allzero;
return res;
}
}
if (param1=="zero_allowed" || param2=="zero_allowed" || param3=="zero_allowed")
{
if (check_zero())
{
res=lib.ok;
return res;
}
}
if (param1=="empty_allowed" || param2=="empty_allowed" || param3=="empty_allowed")
{
if (!check_empty())
{
check_ip()
}
}
else
{
check_ip()
}
return res;
};
lib.notAllEmpty = function (prefix,param1) {
var res = lib.ok
if (param1 && param1!=0)
{
for (var i=1;i < Number(param1);i++)
{
if( jxl.getValue(prefix+String(i))!="") {
return res;
}
}
res = lib.empty
}
else
{
if (jxl.getValue(prefix)=="") {
res = ret.empty
}
}
return res
};
lib.notAllChecked = function (prefix,param1) {
var res = lib.ok
if (param1 && param1!=0)
{
for (var i=1;i <= Number(param1);i++)
{
if( jxl.getChecked(prefix+String(i))) {
return res;
}
}
res = lib.empty
}
else
{
if (!jxl.getChecked(prefix)) {
res = ret.empty
}
}
return res
};
lib.boxClientIp = function(prefix) {
var res = lib.ipv4(prefix);
if (res != lib.ok)
return res;
if (g_boxIp && g_boxNetmask && ip) {
var clientStr = ip.partsToQuad(prefix);
if (clientStr == g_boxIp) {
mark(prefix + "3");
return lib.thebox;
}
var net = ip.analyseNet(g_boxIp, g_boxNetmask);
if (!ip.addrInNet(net, clientStr)) {
for (var b=0; b < Math.ceil(net.net.length / 8); b++) {
var part = net.net.substr(b*8, 8);
if (ip.byteToBitstr(jxl.getValue(prefix+String(b))).substr(0,part.length) != part) {
mark(prefix+String(b));
}
}
return lib.outofnet;
}
if (ip.isNetAddr(net, clientStr)) {
mark(prefix + "3");
return lib.thenet;
}
if (ip.isBroadcast(net, clientStr)) {
mark(prefix + "3");
return lib.broadcast;
}
}
return res;
};
lib.checkIpNet = function(ipPrefix, netmaskPrefix, gatewayPrefix) {
var clientIp = ip.partsToQuad(ipPrefix);
var netmask = ip.partsToQuad(netmaskPrefix);
var gateway = ip.partsToQuad(gatewayPrefix);
var net = ip.analyseNet(clientIp, netmask);
if (ip.isNetAddr(net, clientIp)) {
mark(ipPrefix + "3");
return lib.thenet;
}
if (ip.isBroadcast(net, clientIp)) {
mark(ipPrefix + "3");
return lib.broadcast;
}
if (!ip.addrInNet(net, gateway)) {
for (var b=0; b < Math.ceil(net.net.length / 8); b++) {
var part = net.net.substr(b*8, 8);
if (ip.byteToBitstr(jxl.getValue(gatewayPrefix+String(b))).substr(0,part.length) != part) {
mark(gatewayPrefix+String(b));
}
}
return lib.outofnet;
}
if (ip.isNetAddr(net, gateway)) {
mark(gatewayPrefix + "3");
return lib.thenet;
}
if (ip.isBroadcast(net, gateway)) {
mark(gatewayPrefix + "3");
return lib.broadcast;
}
return lib.ok;
};
lib.checkReservedNet = function(prefix) {
var ipStr = ip.partsToQuad(prefix);
var reserved = ip.analyseNet("192.168.180.0", "255.255.255.0");
if (ip.addrInNet(reserved, ipStr)) {
for (var i = 0; i < 3; i++) {
mark(prefix + i);
}
return lib.reservednet;
}
return lib.ok;
};
lib.checkEweSmartmeterSubnet = function(prefix) {
var ipStr = ip.partsToQuad(prefix);
var eweSmartmeterSubnet = ip.analyseNet("192.168.123.0", "255.255.255.0");
if (ip.addrInNet(eweSmartmeterSubnet, ipStr)) {
for (var i = 0; i < 3; i++) {
mark(prefix + i);
}
return lib.ewemeternet;
}
return lib.ok;
};
lib.boxClientIpRange = function(prefStart, prefEnd) {
var res = lib.boxClientIp(prefStart);
if (res != lib.ok) return res;
res = lib.boxClientIp(prefEnd);
if (res != lib.ok) return res;
if (g_boxIp && g_boxNetmask && ip) {
var hostpos = ip.quadToBitstr(g_boxNetmask).indexOf('0');
var starthost = parseInt(ip.quadToBitstr(ip.partsToQuad(prefStart)).substr(hostpos), 2);
var endhost = parseInt(ip.quadToBitstr(ip.partsToQuad(prefEnd)).substr(hostpos), 2);
var boxhost = parseInt(ip.quadToBitstr(g_boxIp).substr(hostpos), 2);
if (endhost < starthost) {
for (var i=Math.floor(hostpos/8); i<4; i++) {
mark(prefEnd+String(i));
}
return lib.unsized;
}
if (starthost <= boxhost && boxhost<=endhost) {
for (var i=Math.floor(hostpos/8); i<4; i++) {
mark(prefStart+String(i));
}
return lib.thebox;
}
}
return lib.ok;
};
lib.netmask = function(prefix) {
var res = lib.ipv4(prefix);
if (res != lib.ok)
return res;
var str = ip.partsToQuad(prefix);
var bits = ip.quadToBitstr(str);
if (bits.search("^1")==-1) {
mark(prefix + "0");
return lib.nomask;
}
var badpos = bits.search("01");
if (badpos!=-1) {
mark(prefix + String(Math.floor((badpos+2) / 8)));
return lib.nomask;
}
if (bits.search("00$")==-1) {
mark(prefix + "3");
return lib.nomask;
}
return lib.ok;
};
lib.isFloat = function(idOrElement,pattern,maximum) {
var elem = jxl.get(idOrElement);
if (!elem) {
return lib.notfound;
}
var szValue = jxl.getValue(idOrElement);
if ( szValue.length == 0) {
return lib.empty;
}
var rxForbitten = /[a-zA-Z-_;:'#+*~?<>]/;
if ( rxForbitten.test( szValue)) {
return lib.wrong;
}
if ( Number(pattern) == 2) {
rxFloatPattern = /^\d{0,3}[.,]{0,1}\d{0,2}$/;
} else {
rxFloatPattern = /^\d{0,3}[.,]{0,1}\d{0,3}$/;
}
if ( !(rxFloatPattern.test( szValue)) ) {
return lib.format;
}
if ( isNaN( Number( szValue))) {
arTmp = szValue.split( ",");
szValue = arTmp[0]+"."+arTmp[1];
}
if ( Number( szValue) > Number(maximum)) {
return lib.outofrange;
}
return lib.ok;
};
lib.isFloatPlus = function(idOrElement,pattern,maximum,realValue) {
var elem = jxl.get(idOrElement);
if (!elem) {
return lib.notfound;
}
var szValue = jxl.getValue(idOrElement);
if ( realValue != null) {
szValue = realValue;
}
if ( szValue.length == 0) {
return lib.empty;
}
var rxForbitten = /[a-zA-Z_;:'#+*~?<>]/;
if ( rxForbitten.test( szValue)) {
return lib.wrong;
}
if ( Number(pattern) == 2) {
rxFloatPattern = /^[-]{0,1}\d{0,3}[.,]{0,1}\d{0,2}$/;
} else {
if ( Number(pattern) == 3) {
rxFloatPattern = /^[-]{0,1}\d{0,3}[.,]{0,1}\d{0,3}$/;
} else {
rxFloatPattern = /^[-]{0,1}\d{0,3}[.,]{0,1}\d{0,4}$/;
}
}
if ( !(rxFloatPattern.test( szValue)) ) {
return lib.format;
}
if ( isNaN( Number( szValue))) {
arTmp = szValue.split( ",");
szValue = arTmp[0]+"."+arTmp[1];
}
if ( Math.abs( Number( szValue)) > Number(maximum)) {
return lib.outofrange;
}
return lib.ok;
};
lib.isValidTime = function(idOrElement1,idOrElement2) {
var nHour = parseInt(jxl.getValue(idOrElement1));
var nMinutes = parseInt(jxl.getValue(idOrElement2));
unmark(idOrElement1);
unmark(idOrElement2);
if ( nHour == 24) {
if (nMinutes != 0) {
mark(idOrElement2);
return lib.wrong;
}
}
return lib.ok;
};
lib.isValidCountdownTime = function(idOrElement1,idOrElement2) {
var nHours = parseInt(jxl.getValue(idOrElement1));
var nMins = parseInt(jxl.getValue(idOrElement2));
unmark(idOrElement1);
unmark(idOrElement2);
if ((nHours == 0) && (nMins == 0)) {
return lib.wrong;
}
return lib.ok;
};
lib.isValidDate = function(idOrElement1,idOrElement2,idOrElement3) {
var nDay = parseInt(jxl.getValue(idOrElement1));
var nMonth = parseInt(jxl.getValue(idOrElement2));
var nYear = parseInt(jxl.getValue(idOrElement3));
unmark(idOrElement1);
unmark(idOrElement2);
unmark(idOrElement3);
if ((nMonth < 1) || ( nMonth > 12)) {
mark(idOrElement2);
return lib.outofrange;
}
if ( nYear < 2012) {
mark(idOrElement3);
return lib.tooshort;
}
var nDays = 31;
if ( nMonth == 2) {
nDays = 28;
if ( (Math.abs(nYear - 2012)%4) == 0) {
nDays = 29;
}
} else {
if ((nMonth == 4) || (nMonth == 6) || (nMonth == 9) || (nMonth == 11)) {
nDays = 30;
}
}
if ((nDay < 0) || (nDays < nDay)) {
mark(idOrElement1);
return lib.wrong;
}
return lib.ok;
};
lib.isValidDegree = function(idOrElement1,idOrElement2,idOrElement3,compareDegree) {
var nDegree = parseInt(jxl.get(idOrElement1).value);
var nMin = parseInt(jxl.get(idOrElement2).value);
var nSec = parseInt(jxl.get(idOrElement3).value);
unmark( idOrElement1);
unmark( idOrElement2);
unmark( idOrElement3);
if ( nDegree == parseInt(compareDegree)) {
if (( nMin == 0) && (nSec == 0)) {
return lib.ok;
} else {
mark(idOrElement2);
mark(idOrElement3);
return lib.wrong;
}
}
return lib.ok;
};
lib.isValidFloatDegree = function( idOrElement, pattern, maximum) {
unmark( idOrElement);
var nValue = jxl.get(idOrElement).value;
var nPos = nValue.indexOf("°")
if (( nPos > 0) && ( nPos < (nValue.length-1))) {
mark(idOrElement);
return lib.leadchar;
}
var nRealValue = null;
if ( nPos != -1) {
nRealValue = nValue.substr( 0, (nValue.length-1))
}
var res = lib.isFloatPlus( idOrElement, pattern, maximum, nRealValue);
if (res != lib.ok) {
mark(idOrElement);
return res;
}
return lib.ok;
};
lib.valueUnallowable = function(idOrElement1,compareValue) {
var szValue = String(jxl.getValue(idOrElement1));
if ( szValue == String(compareValue)) {
return lib.wrong;
}
return lib.ok;
};
lib.leastOneChecked = function(idOrElement1,idOrElement2) {
var bValue1 = !(jxl.getChecked(idOrElement1));
var bValue2 = !(jxl.getChecked(idOrElement2));
if ((bValue1 == true) && (bValue2 == true)) {
return lib.wrong;
}
return lib.ok;
};
lib.netmaskNull = function(prefix) {
var res = lib.ok;
if (ip.partsToQuad(prefix)!="0.0.0.0")
res = lib.netmask(prefix);
return res;
};
lib.markError = function() {
function getCleanFunction(element) {
var unmarkError = function() {
if (jxl.hasClass(element,"group"))
{
var inputs = jxl.getByClass("error",element,"input");
if (inputs && inputs.length>0)
{
for (var i=0;i<inputs.length;i++)
{
unmark(inputs[i]);
}
}
}
unmark(element);
}
function unmark(element) {
jxl.removeClass(element, "error");
jxl.removeEventHandler(element, "focus", unmarkError);
jxl.removeEventHandler(element, "keydown", unmarkError);
jxl.removeEventHandler(element, "click", unmarkError);
}
return unmarkError;
}
var first = true;
for (var i=0; i<arguments.length; i++) {
var ids = [];
var currId = arguments[i];
if (errorIds[currId]) {
ids = errorIds[currId];
}
else {
ids.push(arguments[i]);
var j=0;
while (jxl.get(arguments[i]+String(j))) {
ids.push(arguments[i]+String(j));
j++;
}
}
for (var idx=0; idx<ids.length; idx++) {
if (markparts==null || markparts[ids[idx]])
{
if (first) {
jxl.focus(ids[idx]);
jxl.addEventHandler(ids[idx], "keydown", getCleanFunction(ids[idx]) );
jxl.addEventHandler(ids[idx], "click", getCleanFunction(ids[idx]) );
first = false;
} else {
jxl.addEventHandler(ids[idx], "focus", getCleanFunction(ids[idx]) );
}
jxl.addClass(ids[idx], "error");
}
}
}
};
lib.callFunc = function(id, funcname) {
var params = Array.prototype.slice.call(arguments, 2);
var fn = global[funcname];
return fn.apply(null, [id].concat(params));
};
lib.init = function(submitFunc, applyNames, formNameOrIndex) {
var activate = function() { lib.active = true; };
return function() {
var f = document.forms[formNameOrIndex || 0];
if (f) {
f.onsubmit = submitFunc;
applyNames = (applyNames || "apply").split(/\s*,\s*/g);
for (var n = 0; n < applyNames.length; n++) {
var applyElements = jxl.getFormElements(applyNames[n], formNameOrIndex);
for (var i = 0; i < applyElements.length; i++) {
jxl.addEventHandler(applyElements[i], "click", activate);
}
}
}
};
};
return lib;
})();
