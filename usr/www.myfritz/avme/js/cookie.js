var cookie = cookie || (function() {
"use strict";
var lib = {};
lib.saveLastArea = function(userId, area)
{
localStorage.setItem(userId, area);
};
lib.getLastArea = function(userId)
{
var area = localStorage.getItem(userId);
if (area == null) area = "overview";
return area;
};
return lib;
})();
