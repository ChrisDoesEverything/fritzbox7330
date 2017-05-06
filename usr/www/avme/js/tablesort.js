function createSorter(params) {
var tableId = params.tableId;
var sortIdPrefix = params.sortIdPrefix || "uiSort_";
var sortedId = params.sortedId;
var listLength = Number(params.listLength) || 0;
var hideOnStart = (params.hideOnStart || "").split(",");
var showOnStart = (params.showOnStart || "").split(",");
var disableOnStart = (params.disableOnStart || "").split(",");
var beforeSave = params.beforeSave || function(){};
var mover = trMover();
var ask = confirmCancel();
function hideAndDisable(revert) {
var i = hideOnStart.length;
while (i--) {
jxl.display(hideOnStart[i], revert);
}
i = showOnStart.length;
while (i--) {
jxl.display(showOnStart[i], !revert);
}
i = disableOnStart.length;
while (i--) {
jxl.disableNode(disableOnStart[i], !revert);
}
}
function start() {
if (mover.start(tableId)) {
hideAndDisable();
if (ask) {
ask.start();
}
}
}
function cancel(doRevertHideAndDisable) {
mover.stop(!doRevertHideAndDisable);
if (doRevertHideAndDisable) {
hideAndDisable(true);
}
if (ask) {
ask.stop();
}
}
function buildSortString(sorted) {
var usedIds = {};
var result = [], curr;
for (var i = 0; i < sorted.length; i++) {
curr = sorted[i].replace(sortIdPrefix, "");
usedIds[curr] = true;
result.push(curr);
}
var n = -1;
while (result.length < listLength) {
n = n + 1;
while (usedIds[n]) {
n = n + 1;
}
result.push(n);
}
return result.join(",");
}
function save(doRevertHideAndDisable) {
var ret = beforeSave();
if (ret !== false) {
var sorted = mover.stop(!doRevertHideAndDisable);
if (sortedId) {
jxl.setValue(sortedId, buildSortString(sorted));
}
if (doRevertHideAndDisable) {
hideAndDisable(true);
}
if (ask) {
ask.stop();
}
}
return ret;
}
return {
start: start,
save: save,
cancel: cancel
};
}
function trMover() {
var table, tbody, rows, btns;
var moving;
var listen = {
mousedown: true,
mouseup: false,
mouseout: false,
mouseover: false
};
function strSorted() {
var sortIds = [];
for (var i = 1; i < rows.length; i++) {
sortIds.push(rows[i].id || "");
}
return sortIds;
}
function start(tableId) {
table = jxl.get(tableId);
if (!table) return false;
tbody = table.tBodies[0];
rows = tbody.rows;
btns = jxl.walkDom(table, 'button', function(btn) {
return !btn.disabled;
});
listen.mousedown = true;
listen.mouseup = false;
listen.mouseout = false;
listen.mouseover = false;
jxl.addClass(table, "movablerows");
if (btns && btns.length) {
for (var i = 0; i < btns.length; i++) {
jxl.disable(btns[i]);
}
}
jxl.addEventHandler(table, "mousedown", handler);
jxl.addEventHandler(table, "mouseout", handler);
jxl.addEventHandler(table, "mouseup", handler);
jxl.addEventHandler(table, "mouseover", handler);
jxl.addEventHandler(document, "mousedown", jxl.cancelEvent);
jxl.addEventHandler(document, "selectstart", jxl.cancelEvent);
return true;
}
function stop(dontEnableButtons) {
if (!table) return;
jxl.removeEventHandler(table, "mousedown", handler);
jxl.removeEventHandler(table, "mouseout", handler);
jxl.removeEventHandler(table, "mouseup", handler);
jxl.removeEventHandler(table, "mouseover", handler);
jxl.removeEventHandler(document, "mousedown", jxl.cancelEvent);
jxl.removeEventHandler(document, "selectstart", jxl.cancelEvent);
if (!dontEnableButtons && btns && btns.length) {
for (var i = 0; i < btns.length; i++) {
jxl.enable(btns[i]);
}
}
jxl.removeClass(table, "movablerows");
return strSorted();
}
function getEvtTr(evt) {
var tr = jxl.evtTarget(evt);
while (tr && typeof tr.sectionRowIndex != 'number') {
tr = tr.parentNode;
}
return tr;
}
function getEvtRelated(evt) {
var el = evt.relatedTarget || evt.toElement;
while (el && el != table) {
el = el.parentNode;
}
return el;
}
function swapTrs(tr1, tr2) {
if (!tr1 || !tr2) return;
var idx1 = tr1.sectionRowIndex;
var idx2 = tr2.sectionRowIndex;
if (idx1 === 0 || idx2 === 0) return;
if (idx1 < idx2) {
tbody.insertBefore(tr2, tr1);
}
else {
tbody.insertBefore(tr1, tr2);
}
zebra();
}
function handler(evt) {
evt = evt || window.event;
if (listen[evt.type]) {
switch (evt.type) {
case 'mousedown':
if (evt.button != 2) {
moving = getEvtTr(evt);
if (moving && moving.sectionRowIndex === 0) {
moving = null;
}
if (moving) {
jxl.addClass(moving, "moving");
listen.mousedown = false;
listen.mouseup = true;
listen.mouseover = true;
listen.mouseout = true;
}
}
break;
case 'mouseup':
jxl.removeClass(moving, "moving");
moving = null;
listen.mousedown = true;
listen.mouseup = false;
listen.mouseover = false;
listen.mouseout = false;
break;
case 'mouseout':
var out = getEvtRelated(evt);
if (!out) {
jxl.removeClass(moving, "moving");
moving = null;
listen.mousedown = true;
listen.mouseup = false;
listen.mouseover = false;
listen.mouseout = false;
}
break;
case 'mouseover':
var tr = getEvtTr(evt);
if (tr && tr != moving) {
if (tr.sectionRowIndex === 0) {
jxl.removeClass(moving, "moving");
moving = null;
}
else {
swapTrs(moving, tr);
jxl.addClass(table, "operahack");
jxl.removeClass(table, "operahack");
}
}
break;
}
}
}
return {start: start, stop: stop};
}
function confirmCancel(params) {
var txt = "{?785:40?}";
var cancel;
var links;
function onCancel(evt) {
if (!confirm(txt)) {
return jxl.cancelEvent(evt);
}
}
function start() {
cancel = jxl.getFormElements('cancel');
if (cancel) {
var i = cancel.length || 0;
while (i--) {
if (cancel[i].type == "submit") {
jxl.addEventHandler(cancel[i], 'click', onCancel);
}
}
}
links = document.links;
if (links) {
var i = links.length || 0;
while (i--) {
if (!jxl.hasClass(links[i], "nocancel")) {
jxl.addEventHandler(links[i], 'click', onCancel);
}
}
}
}
function stop() {
if (cancel) {
var i = cancel.length || 0;
while (i--) {
if (cancel[i].type == "submit") {
jxl.removeEventHandler(cancel[i], 'click', onCancel);
}
}
}
links = document.links;
if (links) {
var i = links.length || 0;
while (i--) {
if (!jxl.hasClass(links[i], "nocancel")) {
jxl.removeEventHandler(links[i], 'click', onCancel);
}
}
}
}
return {
start: start,
stop: stop
};
}
