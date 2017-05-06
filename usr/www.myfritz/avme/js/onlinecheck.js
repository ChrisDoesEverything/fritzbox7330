function getImgLoadHandler(obj,param) {
return (
function(e) {
obj.isOnline = param;
obj.running = false;
return true;
}
);
}
function OnlineCheck(imgUrl) {
this.running=false;
this.isOnline = -1;
this.imgUrl = imgUrl;
this.image = new Image();
this.image.onload = getImgLoadHandler(this,1);
this.image.onerror = getImgLoadHandler(this,0);
this.start = function(nocache) {
if (this.running) {
return;
}
if (!this.imgUrl) {
return;
}
var theUrl = [this.imgUrl];
if (nocache) {
theUrl.push((new Date()).getTime());
}
this.isOnline = -1;
this.running=true;
this.image.src = theUrl.join("?");
};
return this;
}
function onlineTest(timeout, callback, args) {
var timer = timer || null;
if (timer) {
window.clearTimeout(timer);
}
var check = new OnlineCheck("http://help.avm.de/images/connection-test.gif");
check.start(true);
var argsEx = [check.isOnline].concat(args || []);
(function f() {
argsEx[0] = check.isOnline;
callback.apply(null, argsEx);
if (check.isOnline == -1) {
timer = window.setTimeout(f, timeout);
}
})();
}
