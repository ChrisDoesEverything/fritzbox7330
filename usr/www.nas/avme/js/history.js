var privateHistory = privateHistory || (function() {
"use strict";
var lib = {};
var lMfHistory = [];
var lMfHistoryIdx = -1;
function paramsAreNotIdenical(p1, p2)
{
if (p1.length == p2.length)
{
for (var i = 0; i < p1.length; i++)
{
if (p1[i] != p2[i]) return true;
}
return false;
}
return true;
}
lib.addToHistory = function(func, params)
{
var lastIdx = lMfHistoryIdx;
lMfHistoryIdx++;
if (!lMfHistory[lMfHistoryIdx]) lMfHistory[lMfHistoryIdx] = {};
if (lastIdx < 0 || func != lMfHistory[lastIdx].func || paramsAreNotIdenical(params, lMfHistory[lastIdx].params))
{
lMfHistory[lMfHistoryIdx].func = func;
lMfHistory[lMfHistoryIdx].params = params;
if (lastIdx < 0) preventBrowserBackBtn();
}
};
lib.removeLastFuncHistoryEntry = function(func)
{
for (var i = lMfHistoryIdx; i > -1; i--)
{
if(lMfHistory[i].func == func)
{
for (var j = i; j+1 <= lMfHistoryIdx; j++)
{
lMfHistory[j].func = lMfHistory[j+1].func;
lMfHistory[j].params = lMfHistory[j+1].params;
}
removeLastHistoryEntry();
break;
}
}
};
lib.removeAllOfType = function(func)
{
var newHistory = [];
for (var i = 0; i < lMfHistoryIdx; i++)
{
if(lMfHistory[i].func != func)
{
newHistory[newHistory.length] = lMfHistory[i];
}
}
lMfHistory = newHistory;
lMfHistoryIdx = lMfHistory.length -1;
};
function restoreBrowserBackBtn()
{
if (window.onhashchange != null)
{
window.onhashchange = null;
history.back();
}
}
function removeLastHistoryEntry()
{
lMfHistory[lMfHistoryIdx].func = null;
lMfHistory[lMfHistoryIdx].params = null;
lMfHistory[lMfHistoryIdx] = null;
lMfHistoryIdx--;
if (lMfHistoryIdx < 0) restoreBrowserBackBtn();
}
function revertPageToLastState()
{
if (lMfHistoryIdx >= 0 && lMfHistory[lMfHistoryIdx].func != null && lMfHistory[lMfHistoryIdx].params != null)
{
var func = lMfHistory[lMfHistoryIdx].func;
var params = lMfHistory[lMfHistoryIdx].params;
removeLastHistoryEntry();
func.apply(this, params);
}
}
function preventBrowserBackBtn()
{
var historyApi = typeof history.pushState !== 'undefined';
if ( historyApi )
history.pushState(null, '', '#stay');
else
location.hash = '#stay';
window.onhashchange = function(evt)
{
if ("" == location.hash)
{
if (lMfHistoryIdx < 0)
{
history.back();
}
else
{
if ( historyApi )
history.pushState(null, '', '#stay');
else
location.hash = '#stay';
revertPageToLastState();
}
}
};
}
return lib;
})();
