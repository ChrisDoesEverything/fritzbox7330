var globalOnClick = (function() {
function checkElem(elem) {
var tag = (elem.tagName || "").toLowerCase();
var target = (elem.target || "").toLowerCase();
switch (tag) {
case "a":
return target == "";
case "button":
return elem.id == "uiSubmitLogin";
}
return false;
}
function isLinkWithOnclick(elem) {
var tag = (elem.tagName || "").toLowerCase();
return tag == "a" && elem.onclick;
}
function isChrome() {
var s = navigator.userAgent;
return s.indexOf("Chrome") > -1
}
function globalClickHandler(evt) {
evt = evt || window.event;
var elem = evt.target || evt.srcElement;
if (isLinkWithOnclick(elem)) {
return false;
}
if (checkElem(elem)) {
jxl.setStyle(elem, "cursor", "wait");
setTimeout(function() { jxl.setStyle(elem, "cursor", ""); elem = null; }, 3000);
}
return true;
}
function init() {
if (isChrome()) {
return;
}
jxl.addEventHandler(document, "click", globalClickHandler);
}
return {
init: init
};
})();
