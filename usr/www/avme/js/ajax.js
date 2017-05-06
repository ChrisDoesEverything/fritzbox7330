function ajaxGet(url, callback, abortAfter) {
return sendXhr("GET", url, null, callback, {abortAfter: abortAfter});
}
function ajaxPost(url, postData, callback) {
return sendXhr("POST", url, postData, callback, {});
}
function ajaxPostSync(url, postData) {
return sendXhr("POST", url, postData, null, {aSync: false});
}
function ajaxUpdateHtml(uiId, page, sid, timeout, addCallback) {
timeout = Number(timeout) || 0;
var url = encodeURI(page);
url = addUrlParam(url, "update", uiId);
if (sid) {
url = addUrlParam(url, "sid", sid);
}
function request() {
ajaxGet(url, callback);
}
function callback(xhr) {
if (xhr && xhr.status == 200) {
jxl.setHtml(uiId, xhr.responseText);
if (addCallback) {
var newTimeout = addCallback(uiId, xhr);
if (typeof newTimeout == 'number') {
timeout = newTimeout;
}
}
zebra();
}
if (timeout > 0) {
setTimeout(request, timeout);
}
}
setTimeout(request, timeout || 0);
}
function ajaxWait(vars, sid, poll, cb) {
var stop = false;
var query = "/query.lua?sid="+sid;
var json = makeJSONParser();
for (var name in vars) {
query = query + "&" + name + "=" + vars[name].query;
}
function request() {
return ajaxGet(query, cbResponse);
}
function cbResponse(xhr) {
var resp = json(xhr.responseText || "null");
if (resp) {
for (var name in vars) {
vars[name]["value"] = resp[name] || "";
}
}
if (!cb(resp ? vars : null)) {
setTimeout(request, poll);
}
}
return request();
}
function ajaxWaitForBox(cbCustom,abort) {
var url = encodeURI("/");
var timer;
var count_retries = 0;
var boxStillOnline = true;
var requestTimeout = 5000;
var finished;
function goToBox() {
top.location.href = "/";
}
if (cbCustom && typeof cbCustom == "function") {
finished = cbCustom;
} else {
finished = goToBox;
}
function callback(response) {
if (response && response.status == 200) {
if (boxStillOnline) {
count_retries++;
if (abort && count_retries>abort)
{
window.setTimeout(finished, 5000);
}
timer = window.setTimeout(doRequest, requestTimeout);
}
else {
window.setTimeout(finished, 30000);
}
}
else {
boxStillOnline = false;
timer = window.setTimeout(doRequest, requestTimeout);
}
}
function doRequest() {
sendXhr("GET", url, null, callback);
}
window.setTimeout(doRequest, requestTimeout);
}
function sendXhr(method, url, postData, callback, options) {
options = options || {};
var abortAfter = options.abortAfter;
var aSync = (options.aSync !== false);
var abortTimeout;
var xhr = newXhr();
if (!xhr) {
return false;
}
method = method.toUpperCase();
if (method == "GET") {
url = addUrlParam(url, "xhr", "1");
url = addUrlParam(url, "t" + String((new Date()).getTime()), "nocache");
}
xhr.open(method, url, aSync);
if (method == "POST") {
postData = [postData || "", "xhr=1"].join("&");
xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
}
xhr.onreadystatechange = function () {
if (xhr.readyState == 4) {
clearTimeout(abortTimeout);
if (checkLoggedin(xhr)) {
if (typeof callback == 'function') {
callback(xhr);
callback = null;
}
}
xhr.onreadystatechange = function (){};
}
};
if (abortAfter) {
abortTimeout = setTimeout(function() {
stopXhr(xhr);
if (typeof callback == 'function') {
callback("aborted");
callback = null;
}
}, abortAfter);
}
xhr.send(postData);
return xhr;
}
function stopXhr(xhr) {
if (xhr && xhr.readyState && xhr.readyState < 4) {
xhr.onreadystatechange = function (){};
xhr.abort();
}
}
function newXhr() {
var createFuncs = [
function() { return new XMLHttpRequest(); },
function() { return new ActiveXObject("Msxml2.XMLHTTP"); },
function() { return new ActiveXObject("Microsoft.XMLHTTP"); }
];
var xhr = null;
for (var i = 0; i < createFuncs.length; i++) {
try {
xhr = createFuncs[i]();
if (xhr) {
newXhr = createFuncs[i];
return xhr;
}
}
catch (err) {
}
}
newXhr = function() { return null; };
return null;
}
function makeJSONParser() {
if (window.JSON && typeof window.JSON.parse == 'function') {
return window.JSON.parse;
}
else {
return function(txt) {
return (new Function('return (' + txt + ')'))();
};
}
}
function buildUrlParam(name, value) {
if (typeof value == 'undefined') {
value = "";
}
return encodeURIComponent(name) + "=" + encodeURIComponent(value);
}
function addUrlParam(url, name, value) {
if (!name) {
return url;
}
var sep = "&";
url = url || "";
if (url.indexOf("?") < 0) {
sep = "?";
}
return url + sep + buildUrlParam(name, value);
}
function addUrlParamTable(params) {
var url=[];
for (var name in params)
{
url.push(buildUrlParam(name,params[name]));
}
return url.join("&");
}
function stripSid(url) {
//return (url || "").replace(/[\?\&]?sid=[a-fA-F0-9]+/g, "")
url = url || "";
url = url.replace(/sid=[a-fA-F0-9]+/g, "")
url = url.replace(/\?&/, "?");
url = url.replace(/&&/g, "&");
url = url.replace(/&$/, "");
url = url.replace(/\?$/, "");
return url;
}
function checkLoggedin(xhr) {
if (xhr.status == 403) {
var url = (location.href || "").split("#");
url[0] = stripSid(url[0]);
if (typeof gAppAutoLogoutHint != 'undefined' && gAppAutoLogoutHint === true) {
url[0] = addUrlParam(url[0], "logout", "2");
}
location.href = url.join("#");
return false;
}
return true;
}
