function storeCookie(name, value, days) {
var expires = "";
if (days) {
var date = new Date();
date.setTime(date.getTime() + Math.floor(days*24*60*60*1000));
expires = "; expires=" + date.toGMTString();
}
document.cookie = name + "=" + value + expires + "; path=/";
}
function readCookie(name) {
var result = "";
var cookieStr = document.cookie;
if (cookieStr) {
var start = cookieStr.indexOf(name + '=');
if (start > -1) {
start += name.length + 1;
var end = cookieStr.indexOf(';', start);
if (end == -1) {
end = cookieStr.length;
}
result = cookieStr.substring(start, end);
}
}
return result;
}
function eraseCookie(name) {
storeCookie(name, "", -1);
}
