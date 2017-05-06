function initDoubleSelect(name, switchValue, onProvider) {
onProvider = onProvider || function(){};
var getValue = function(){ return select1.value; };
var onChange = function(){ onProvider(getValue()); };
var select1 = jxl.getFormElements(name);
if (!select1.length) { return; }
select1 = select1[0];
var select2 = jxl.getFormElements(name + "2");
select2 = select2[0];
if (select2) {
getValue = function() {
var val = select1.value;
if (val == switchValue) {
val = select2.value;
}
return val;
};
onChange = function(evt) {
var sel = jxl.evtTarget(evt);
var val = sel && sel.value || "";
if (sel != select1 || val == switchValue) {
jxl.removeClass(select2, "invisible");
}
else {
jxl.addClass(select2, "invisible");
}
onProvider(getValue());
};
jxl.addEventHandler(select2, "change", onChange);
}
jxl.addEventHandler(select1, "change", onChange);
jxl.enable(select1);
jxl.setStyle(select1, "cursor", "");
jxl.enable(select2);
jxl.setStyle(select2, "cursor", "");
}
function initSubproviderHandlers(destId, radioNames) {
var toClass = function(val){return "sub_" + val;};
var handlers = {};
for (var isp in radioNames) {
if (radioNames.hasOwnProperty(isp)) {
handlers[isp] = classChangeOnRadio({
radioName: radioNames[isp],
destId: jxl.sprintf(destId, isp),
toClass: toClass,
callAndRun: false
});
}
}
return handlers;
}
function inputValueStore(destId, startValues) {
var dest = jxl.get(destId);
var values = startValues || {};
function getInputValues(id) {
values[id] = values[id] || {};
jxl.walkDom(dest, "input", function(el) {
if (el.name && el.value) {
if (el.type != 'radio' && el.type != 'checkbox' || el.checked) {
values[id][el.name] = el.value;
}
}
});
}
function setInputValues(id) {
var stored = values[id] || {};
jxl.walkDom(dest, "input", function(el) {
var val = stored[el.name];
if (typeof val != 'undefined') {
if (el.type == 'radio' || el.type == 'checkbox') {
el.checked = (el.value && el.value == val);
}
else {
el.value = val;
}
}
});
}
return {
save: getInputValues,
restore: setInputValues
};
}
function openServiceCenter(url) {
if (url && url.length > 8) {
var sWin = window.open(url, "UIServiceCenter");
}
}
function createAuthformGetter(params) {
var url = encodeURI(params.page);
if (params.sid) {
url += "?" + encodeURIComponent("sid") + "=" + encodeURIComponent(params.sid);
}
url += "&" + encodeURIComponent("authform") + "=";
var dest = jxl.get(params.destId);
var isp = params.isp || "";
var handlers = params.handlers || {};
var values = inputValueStore(params.destId);
if (isp) {
values.save(isp);
if (handlers[isp]) {
handlers[isp].start();
}
}
function callback(xhr) {
if (xhr && xhr.status == 200) {
jxl.setHtml(dest, xhr.responseText);
jxl.disableNode(dest, false);
values.restore(isp);
if (handlers[isp]) {
handlers[isp].start();
}
jxl.setStyle(dest, "cursor", "");
}
}
function getAuthform(newIsp) {
values.save(isp);
if (handlers[isp]) {
handlers[isp].stop();
}
isp = newIsp;
jxl.disableNode(dest, true);
jxl.setStyle(dest, "cursor", "wait");
ajaxGet(url + encodeURIComponent(isp), callback);
}
return getAuthform;
}
