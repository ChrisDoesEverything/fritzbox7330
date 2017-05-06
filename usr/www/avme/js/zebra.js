/*
*/
var zebra = (function() {
function testZebra() {
var result = true;
var css = document.styleSheets;
if (css && css.length) {
/*
*/
css = css[0];
if (css.addRule) {
try {
css.addRule("div.zebratest div:nth-child(odd)", "color:red");
css.removeRule(css.rules.length - 1);
}
catch (err) {
/*
*/
result = false;
}
}
}
return result;
}
function isZebra(tbl) {
return jxl.hasClass(tbl, "zebra") || jxl.hasClass(tbl, "zebra_reverse");
}
/*
*/
function doZebra() {
var tables = jxl.walkDom(document, "table", isZebra);
var n = tables.length;
for (var i = 0; i < n; i++) {
var trs = tables[i].rows;
var even = true;
for (var j = 0; j < trs.length; j++) {
/*
*/
even = !even;
jxl.removeClass(trs[j], even ? "zebraOdd" : "zebraEven");
jxl.addClass(trs[j], even ? "zebraEven" : "zebraOdd");
/*
*/
}
}
}
if (!testZebra()) {
return doZebra;
}
else {
return function(){};
}
})();
