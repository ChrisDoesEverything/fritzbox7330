/*
*/
/*
*/
function doOnClick(params) {
var callAndRun = true;
if (typeof params.callAndRun == 'boolean') {
callAndRun = params.callAndRun;
}
var inputName = params.inputName || "";
var classString = params.classString || "";
var func = params.func;
var inp, dest = {};
var isInit = false;
function onClick() {
var i = inp.length;
while (i--) {
var d = dest[inp[i].value || "on"];
if (d && d.length) {
for (var k = 0; k < d.length; k++) {
func(d[k], inp[i].checked);
}
}
}
}
function init() {
if (!inputName || !classString || !func) {
return;
}
inp = jxl.getFormElements(inputName);
if (!inp) return;
var i = inp.length;
while (i--) {
var val = inp[i].value || "on";
if (val) {
dest[val] = jxl.getByClass(jxl.sprintf(classString, val));
}
}
}
function start() {
if (!isInit) {
init();
}
if (!inp || !dest) {
return;
}
var i = inp.length;
while (i--) {
jxl.addEventHandler(inp[i], "click", onClick);
}
onClick();
}
function stop() {
if (!inp) {
return;
}
var i = inp.length;
while (i--) {
jxl.removeEventHandler(inp[i], "click", onClick);
}
}
if (callAndRun) {
init();
start();
}
else {
return {start: start, stop: stop};
}
}
function enableOnClick(params) {
params.func = jxl.enableNode;
return doOnClick(params);
}
function disableOnClick(params) {
params.func = jxl.disableNode;
return doOnClick(params);
}
function showOnClick(params) {
params.func = jxl.display;
return doOnClick(params);
}
function hideOnClick(params) {
params.func = function(el, b){return jxl.display(el, !b);};
return doOnClick(params);
}
function classChangeOnSelect(params) {
var callAndRun = true;
if (typeof params.callAndRun == 'boolean') {
callAndRun = params.callAndRun;
}
var toClass = params.toClass || function(val){return val || "";};
var classes = params.classes || "";
var getValue = params.getValue || jxl.getValue;
var sel, dest;
var isInit = false;
function onChange(evt) {
var el = jxl.evtTarget(evt);
if (el) {
jxl.removeClass(dest, classes);
jxl.addClass(dest, toClass(getValue(el)));
}
}
function init() {
if (params.selectId) {
sel = jxl.get(params.selectId);
}
else {
sel = jxl.getFormElements(params.selectName);
sel = sel[0];
}
if (!sel) {
return;
}
dest = jxl.get(params.destId);
if (!dest) {
return;
}
if (!classes) {
var opts = sel.options;
var i = opts.length;
classes = [];
while (i--) {
classes.push(toClass(opts[i].value));
}
classes = classes.join(" ");
}
isInit = true;
}
function start() {
if (!isInit) {
init();
}
if (!sel || !dest) {
return;
}
jxl.removeClass(dest, classes);
jxl.addClass(dest, toClass(getValue(sel)));
jxl.addEventHandler(sel, 'change', onChange);
}
function stop() {
jxl.removeEventHandler(sel, 'change', onChange);
}
if (callAndRun) {
init();
start();
}
else {
return {start: start, stop: stop};
}
}
function classChangeOnRadio(params) {
/*
*/
var callAndRun = true;
if (typeof params.callAndRun == 'boolean') {
callAndRun = params.callAndRun;
}
var toClass = params.toClass || function(val){return val || "";};
var classes = params.classes || "";
var getValue = params.getValue || jxl.getValue;
var radio, dest;
var isInit = false;
function onClick(evt) {
var el = jxl.evtTarget(evt);
if (el) {
jxl.removeClass(dest, classes);
jxl.addClass(dest, toClass(getValue(el)));
}
}
function init() {
radio = jxl.getFormElements(params.radioName);
if (!radio) return;
dest = jxl.get(params.destId);
if (!dest) return;
if (!classes) {
var i = radio.length;
classes = [];
while (i--) {
classes.push(toClass(getValue(radio[i])));
}
classes = classes.join(" ");
}
isInit = true;
}
function start() {
if (!isInit) {
init();
}
if (!radio || !dest) {
return;
}
var i = radio.length;
while (i--) {
if (radio[i].checked) {
jxl.removeClass(dest, classes);
jxl.addClass(dest, toClass(getValue(radio[i])));
}
jxl.addEventHandler(radio[i], 'click', onClick);
}
}
function stop() {
if (!radio) return;
var i = radio.length;
while (i--) {
jxl.removeEventHandler(radio[i], 'click', onClick);
}
}
if (callAndRun) {
init();
start();
}
else {
return {start: start, stop: stop};
}
}
