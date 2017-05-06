var help = (function() {
var helpWin = null;
function popup(href) {
var opts = "width=800,height=600,resizable=yes,scrollbars=yes,toolbar=yes,location=yes";
if (!helpWin || typeof(helpWin.closed) == 'undefined' || helpWin.closed) {
helpWin = window.open(href, "HelpWindow", opts);
}
else {
helpWin.location.href = href;
}
if (helpWin) {
helpWin.focus();
}
}
function show() {
jxl.walkDom(document, "", function(elem) {
if (jxl.hasClass(elem, "hidden_help")) {
elem.style.display = "";
}
});
}
function onClickBoxlink(evt) {
evt = evt || window.evt;
var elem = evt.target || evt.srcElement;
window.opener.location.href = elem.href;
jxl.cancelEvent(evt);
window.close();
return false;
}
function convertBoxlinks() {
jxl.walkDom(document, "a", function(a) {
if (jxl.hasClass(a, "boxlink")) {
jxl.addEventHandler(a, 'click', onClickBoxlink);
}
});
}
return {
popup: popup,
show: show,
convertBoxlinks: convertBoxlinks
};
})();
