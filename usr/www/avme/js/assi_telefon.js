var assi_telefon = assi_telefon || (function() {
"use strict"
var lib = {};
var doc = window.document;
var head = null;
lib.get = function(idOrElement) {
if (typeof idOrElement == 'string' && idOrElement) {
return doc.getElementById(idOrElement);
}
return idOrElement;
};
lib.find_Double_Notation = function(notation, namelist) {
for (var i in namelist)
{
if (notation == namelist[i])
{
return true;
}
}
return false;
};
return lib;
})();
