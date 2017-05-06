
function ajaxValidation(options) {
options = options || {};
var url = options.url;
var formNameOrIndex = options.formNameOrIndex || 0;
var applyNames = (options.applyNames || "apply").split(/\s*,\s*/g);
var okCallback = options.okCallback;
var aSync = options.aSync;
var showWait = options.showWait;
var openPopup = options.openPopup;
var form, clicked, json;
var directCall = options.directCall;
if (directCall) {
aSync = false;
}
function init() {
form = document.forms[formNameOrIndex || 0];
if (!form) {
return;
}
url = url || form.action;
if (!directCall) {
var n = applyNames.length;
while (n--) {
var applyElements = jxl.getFormElements(applyNames[n], formNameOrIndex);
var i = applyElements.length;
while (i--) {
jxl.addEventHandler(applyElements[i], "click", onClickApply);
}
}
jxl.addEventHandler(form, "submit", aSync ? onSubmit : onSubmitSync);
}
json = makeJSONParser();
}
function postEncode(str, multiline) {
var result = encodeURIComponent(str);
result = result.replace(/%20/g, '+');
if (multiline) {
result = result.replace(/(.{0,3})(%0A)/g,
function(m, s1, s2){return s1 + (s1 == '%0D' ? '' : '%0D') + s2;}
);
result = result.replace(/(%0D)(.{0,3})/g,
function(m, s1, s2){return s1 + (s2 == '%0A' ? '' : '%0A') + s2;}
);
}
return result;
}
function readValue(el) {
switch (el.type || "") {
case 'submit':
break;
case 'file':
break;
case 'checkbox':
if (el.checked) {
return el.value || "on";
}
break;
case 'radio':
if (el.checked) {
return el.value || "";
}
break;
default:
return el.value || "";
break;
}
return null;
}
function serializeForm(validate) {
var elems = form && form.elements || [];
var result = [];
var el, name, value;
for (var i = 0, len = elems.length; i < len; i++) {
el = elems[i];
name = el.name;
if (name && !el.disabled) {
value = readValue(el);
if (value !== null) {
result.push(postEncode(name) + "=" + postEncode(value, el.type == 'textarea'));
}
}
}
if (validate) {
result.push(postEncode("validate") + "=" + postEncode(validate));
}
return result.join('&');
}
function showValidationWait(doShow) {
if (showWait) {
var wait = jxl.get("uiValidationWait");
if (wait) {
jxl.display(form, !doShow);
jxl.display(wait, doShow);
}
}
}
function onClickApply(evt) {
var btn = jxl.evtTarget(evt);
if (btn) {
clicked = btn.name;
showValidationWait(true);
}
}
function removeAllErrors() {
var elems = form && form.elements || [];
var i = elems.length;
while (i--) {
jxl.removeClass(elems[i], "error");
}
}
function onSubmitSync(evt) {
if (clicked) {
removeAllErrors();
var data = serializeForm(clicked);
var xhr = ajaxPostSync(url, data);
var ok = validationCallback(xhr);
if (!ok) {
return jxl.cancelEvent(evt);
}
}
}
function onSubmit(evt) {
if (clicked) {
removeAllErrors();
var data = serializeForm(clicked);
ajaxPost(url, data, validationCallback);
return jxl.cancelEvent(evt);
}
}
function addApplyElement(name) {
var applyElem = document.createElement("input");
applyElem.setAttribute("type", "hidden");
applyElem.name = name;
form.appendChild(applyElem);
}
function onFocus(evt) {
var elem = jxl.evtTarget(evt);
jxl.removeClass(elem, "error");
jxl.removeEventHandler(elem, "focus", onFocus);
}
function onFocusIdx(evt) {
var elem = jxl.evtTarget(evt);
var name = elem.name.replace(/\d$/, "");
var el, idx = 0;
while (el = form.elements[name + idx]) {
jxl.removeClass(el, "error");
jxl.removeEventHandler(el, "focus", onFocusIdx);
idx++;
}
}
function setError(name) {
if (name) {
var els = jxl.getFormElements(name, formNameOrIndex);
var i = els.length;
if (i == 0) {
var el, idx = 0;
while (el = form.elements[name + idx]) {
jxl.addClass(el, "error");
jxl.addEventHandler(el, "focus", onFocusIdx);
idx++;
}
}
else if (i == 1) {
jxl.addClass(els[0], "error");
jxl.addEventHandler(els[0], "focus", onFocus);
}
else if (i > 1) {
while (i--) {
if (els[i].checked) {
jxl.addClass(els[i], "error");
jxl.addEventHandler(els[i], "focus", onFocus);
}
}
}
}
}
function createPopup(answer) {
if (answer.popup && answer.popup.url) {
return function() {
var ppUrl = answer.popup.url;
var opts = answer.popup.opts || "width=450,height=400,resizable=yes,scrollbars=yes,location=no";
var ppWindow = window.open(ppUrl, "Zweitfenster", opts);
if (ppWindow) {
ppWindow.focus();
}
};
}
}
function doPopupAfterClick(popup, validate) {
jxl.addEventHandler("uiValidationDoneOk", "click", function(evt) {
popup();
jxl.disable("uiValidationDoneOk");
addApplyElement(validate);
form.submit();
});
jxl.hide(form);
jxl.hide("uiValidationWait");
jxl.show("uiValidationDone");
}
function validationCallback(xhr) {
var answer = json(xhr.responseText || "{}");
if (answer.ok) {
var confirmed = true;
if (answer.confirm) {
var i = 0, len = answer.confirm.length;
while (i < len && confirmed) {
confirmed = confirm(answer.confirm[i]);
i++;
}
}
if (confirmed && okCallback) {
confirmed = okCallback();
}
if (confirmed !== false) {
var popup = createPopup(answer) || openPopup;
if (aSync) {
if (popup) {
doPopupAfterClick(popup, answer.validate);
}
else {
addApplyElement(answer.validate);
form.submit();
}
}
else {
if (popup) {
popup();
}
}
return true;
}
showValidationWait(false);
}
else {
showValidationWait(false);
var toMark = answer.tomark || [];
if (typeof toMark == 'string') {
toMark = [toMark];
}
var i = toMark.length;
while (i--) {
setError(toMark[i]);
}
if (answer.alert) {
alert(answer.alert);
}
}
clicked = null;
return false;
}
function doDirectCall(validate) {
clicked = validate || "apply";
return onSubmitSync(validate) !== false;
}
if (directCall) {
init();
return doDirectCall;
}
else {
return init;
}
}
