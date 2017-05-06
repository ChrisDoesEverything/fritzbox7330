//de-first -begin
function addApplyElement(cancel, form) {
var applyElem = document.createElement("input");
applyElem.setAttribute("type", "hidden");
applyElem.name = cancel.name;
form.appendChild(applyElem);
}
function callbackCancel(cancel, form) {
addApplyElement(cancel, form);
form.submit();
}
function callbackLinkCancel(href) {
location.href = href;
}
function initCancelHandler() {
var jsonAssiAbort = {
"Text1" : "{?8278:573?}"
};
function onCancel(evt) {
var cancel = jxl.evtTarget(evt);
var form = jxl.getForm(cancel);
if (cancel && form) {
jsonAssiAbort.Buttons = [
{txt:"{?8278:383?}", cb: function() {callbackCancel(cancel, form)}},
{txt:"{?8278:254?}"}
];
dialog.messagebox(true, jsonAssiAbort);
jxl.cancelEvent(evt);
}
}
function onLinkCancel(evt) {
var elem = jxl.evtTarget(evt);
if (typeof elem.href == 'undefined') {
elem = jxl.findParentByTagName(elem, "a");
}
var href = ""
if (elem && elem.href) {
href = elem.href;
}
jsonAssiAbort.Buttons = [
{txt:"{?8278:911?}", cb: function() {callbackLinkCancel(href)}},
{txt:"{?8278:234?}"}
];
dialog.messagebox(true, jsonAssiAbort);
jxl.cancelEvent(evt);
}
(function() {
var i = document.forms.length || 0;
while (i--) {
var cancel = document.forms[i].elements.cancel;
if (cancel && cancel.type == "submit" && !jxl.hasClass(cancel, "nocancel")) {
jxl.addEventHandler(cancel, 'click', onCancel);
}
}
var links = document.links;
i = links.length || 0;
while (i--) {
if (!jxl.hasClass(links[i], "nocancel")) {
jxl.addEventHandler(links[i], 'click', onLinkCancel);
}
}
})();
}
ready.onReady(initCancelHandler);
var wizard = wizard || (function() {
var btn = {};
function getWizBtn(name) {
if (!btn[name]) {
btn[name] = jxl.get("ui" + name.charAt(0).toUpperCase() + name.substring(1));
}
return btn[name];
}
function enable(name) {
jxl.enable(getWizBtn(name));
}
function disable(name) {
jxl.disable(getWizBtn(name));
}
function show(name) {
jxl.show(getWizBtn(name));
}
function hide(name) {
jxl.hide(getWizBtn(name));
}
function rename(name, newText) {
jxl.setHtml(getWizBtn(name), newText);
}
function setEnabled(name, doEnable) {
if (doEnable === false) {
disable(name);
}
else {
enable(name);
}
}
return {
enable: enable,
disable: disable,
show: show,
hide: hide,
rename: rename,
setEnabled: setEnabled
};
})();
