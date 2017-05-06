function createTableSelectChooser(params) {
var tableId = params.tableId || "";
var selectId = params.selectId || "";
var chosenId = params.chosenId || "";
var displayNames = params.displayNames || {};
var emptyText = params.emptyText || "";
var addTdsCallback = params.addTdsCallback;
var colSpan = params.colSpan || 2;
var maxTableSize = params.maxTableSize;
var sort=params.sort || 0;
var sort_def_col=params.sort_def_col || 0;
var tbl, sel, chosen, buttons, selParent;
function initVars() {
tbl = jxl.get(tableId);
sel = jxl.get(selectId);
chosen = jxl.get(chosenId);
if (tbl) {
buttons = tbl.getElementsByTagName("button");
}
if (sel) {
selParent = sel.parentNode;
}
if (!tbl || !sel || !chosen || !buttons) {
return false;
}
return true;
}
function getBtnValue(btn) {
var value = btn.name || "";
return value.replace("value_", "");
}
var btnTemplate = (function() {
var btn = document.createElement('button');
btn.setAttribute("type", "button");
btn.className = "icon";
var img = document.createElement('img');
img.src = "/css/default/images/loeschen.gif";
btn.appendChild(img);
return function(value) {
var b = btn.cloneNode(true);
b.name = "value_" + value;
return b;
};
})();
function checkTableSize() {
if (maxTableSize && selParent) {
var full = tbl.rows.length > maxTableSize;
jxl.disableNode(selParent, full);
}
}
function addTr(value) {
var tr = tbl.insertRow(tbl.rows.length);
var td = document.createElement('td');
td.innerHTML = displayNames[value];
tr.appendChild(td);
if (typeof addTdsCallback == 'function') {
var add = addTdsCallback(value);
for (var i = 0; i < add.length; i++) {
td = document.createElement('td');
td.innerHTML = add[i] || "";
tr.appendChild(td);
}
}
td = document.createElement('td');
td.className = "buttonrow";
var btn = btnTemplate(value);
td.appendChild(btn);
tr.appendChild(td);
jxl.addEventHandler(btn, "click", onDeleteFromTable);
checkTableSize();
checkEmptyTr();
if (sort)
{
sort.sort_table_again(sort_def_col);
}
zebra();
}
function removeTr(value) {
for (var i = 0; i < buttons.length; i++) {
if (getBtnValue(buttons[i]) == value) {
jxl.removeEventHandler(buttons[i], "click", onDeleteFromTable);
tbl.deleteRow(i + 1);
break;
}
}
checkTableSize();
checkEmptyTr();
if (sort)
{
sort.sort_table_again(sort_def_col);
}
zebra();
}
function checkEmptyTr() {
if (tbl.rows.length == 1) {
var tr = tbl.insertRow(1);
tr.id = "uiEmptyTr";
tr.className="emptylist";
var td = document.createElement('td');
td.colSpan = colSpan;
td.innerHTML = emptyText;
tr.appendChild(td);
}
else if (tbl.rows.length > 1) {
if (tbl.rows[1].id == "uiEmptyTr") {
tbl.deleteRow(1);
}
}
}
function addToChosen(value) {
var str = chosen.value || "";
if (str.length > 0) {
str += ",";
}
str += value;
chosen.value = str;
}
function removeFromChosen(value) {
var str = (chosen.value || "").split(",");
var newStr = [];
for (var i = 0, len = str.length; i < len; i++) {
if (str[i] != value) {
newStr.push(str[i]);
}
}
chosen.value = newStr.join(",");
}
function onChangeSelect(evt) {
if (sel.selectedIndex > 0) {
addToChosen(sel.value);
addTr(sel.value);
sel.removeChild(sel.options[sel.selectedIndex]);
sel.options[0].selected = true;
}
}
function onDeleteFromTable(evt) {
var b = jxl.evtTarget(evt);
if (b && b.tagName.toLowerCase() != "button") {
b = b.parentNode;
}
if (b) {
var value = getBtnValue(b);
removeFromChosen(value);
removeTr(value);
jxl.removeClass(tbl, "operahack");
jxl.addClass(tbl, "operahack");
sel.options[sel.options.length] = new Option(displayNames[value], value);
return jxl.cancelEvent(evt);
}
}
function addDeleteHandlers() {
var i = buttons.length || 0;
while (i--) {
jxl.addEventHandler(buttons[i], "click", onDeleteFromTable);
}
}
if (initVars()) {
addDeleteHandlers();
jxl.addEventHandler(sel, "change", onChangeSelect);
checkTableSize();
checkEmptyTr();
if (sort)
{
sort.sort_table_again(sort_def_col);
}
zebra();
}
}
