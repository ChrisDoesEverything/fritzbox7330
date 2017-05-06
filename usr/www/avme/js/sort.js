function sorter() {
"use strict"
var lib = {};
var doc = window.document;
var head = null;
var direction = [];
var cmp_func = [];
var get_func = [];
var post_func = 0;
var tMain=[];
var cur_col=0;
tMain[0]=0
var elem_node=document.ELEMENT_NODE;
var text_node=document.TEXT_NODE;
if (document.ELEMENT_NODE == null) {
elem_node = 1;
text_node = 3;
}
function getClass(obj) {
if (!obj)
{
return "";
}
return obj.className || "";
}
function getNumValue(obj) {
if (!obj)
{
return "";
}
var val=getTextValue(obj);
return parseFloat(val) || 0;
}
function getTextValue(obj) {
if (!obj)
{
return "";
}
var s = "";
for (var i = 0; i < obj.childNodes.length; i++)
{
if (obj.childNodes[i].nodeType == text_node) {
s += obj.childNodes[i].nodeValue;
}
else if (obj.childNodes[i].nodeType == elem_node &&
obj.childNodes[i].tagName == "BR") {
s += " ";
}
else
{
if (obj.childNodes[i].tagName != "TABLE")
{
s += getTextValue(obj.childNodes[i]);
}
}
}
return s;
}
function comp_as_num(v1, v2) {
if (v1 == v2)
return 0;
if (v1 > v2)
return 1
return -1;
}
function comp_as_str_nocase(v1, v2) {
v1=v1.toLowerCase();
v2=v2.toLowerCase();
if (v1 == v2)
return 0;
if (v1 > v2)
return 1
return -1;
}
function comp_as_str(v1, v2) {
if (v1 == v2)
return 0;
if (v1 > v2)
return 1
return -1;
}
lib.init = function(IdOrElement) {
return true;
};
lib.addPostFunc = function (func)
{
if (typeof(func)=="function")
{
post_func=func;
}
return false;
}
lib.addTbl = function (IdOrElement)
{
return true;
};
lib.setDirection = function (col,dir) {
};
lib.get_sortcol = function() {
return cur_col;
}
lib.sort_table_again = function (col) {
return false;
}
lib.sort_table = function (col) {
return false;
};
lib.sort_body = function (TblBody, col) {
return false;
};
return lib;
}
