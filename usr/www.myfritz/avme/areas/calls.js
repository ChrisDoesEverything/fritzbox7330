var callsJs = callsJs || (function() {
"use strict";
var lib = {};
jxl.createStyleTag(' \
/****************** Seiten Inhalt ******************/ \
/* Mobile */ \
@media (max-width: 759px) { \
.calls .area_overview { \
background-color: #ffd40d; \
background-size: 72em 4.5em; \
background-image: radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffd40d 93%, #ffd40d 100%), \
linear-gradient(42deg, rgba(122, 101, 6, 0.5), rgba(164, 136, 8, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 14.0%, rgba(255, 246, 151, 0.5) 24%); \
background-image: -webkit-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffd40d 93%, #ffd40d 100%), \
-webkit-linear-gradient(42deg, rgba(122, 101, 6, 0.5), rgba(164, 136, 8, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 14.0%, rgba(255, 246, 151, 0.5) 24%); \
background-image: -moz-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffd40d 93%, #ffd40d 100%), \
-moz-linear-gradient(42deg, rgba(122, 101, 6, 0.5), rgba(164, 136, 8, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 14.0%, rgba(255, 246, 151, 0.5) 24%); \
background-image: -o-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffd40d 93%, #ffd40d 100%), \
-o-linear-gradient(42deg, rgba(122, 101, 6, 0.5), rgba(164, 136, 8, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 14.0%, rgba(255, 246, 151, 0.5) 24%); \
background-image: -ms-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffd40d 93%, #ffd40d 100%), \
-ms-linear-gradient(42deg, rgba(122, 101, 6, 0.5), rgba(164, 136, 8, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 12.5%, rgba(204, 196, 138, 0.5) 14.0%, rgba(255, 246, 151, 0.5) 24%); \
} \
\
.calls .area_ov_icon { \
background-image: url("/myfritz/css/default/images/icon_calls.png"); \
} \
} \
/****************** ENDE Seiten Inhalt ******************/ \
\
/****************** OVERVIEW ******************/ \
.calls .area_overview td:nth-child(2) { \
width: 4.4em; \
} \
/****************** ENDE OVERVIEW ******************/ \
\
/****************** Items ******************/ \
.item div.callIcon { \
display: inline-block; \
padding: 0; \
margin: 0; \
height: 6mm; \
width: 6mm; \
background-position: center; \
background-repeat: no-repeat; \
} \
\
.item div.callin { \
background-image: url("/myfritz/css/default/images/callin.gif"); \
} \
\
.item div.callinfailed { \
background-image: url("/myfritz/css/default/images/callinfailed.gif"); \
} \
\
.item div.callrejected { \
background-image: url("/myfritz/css/default/images/callrejected.gif"); \
} \
\
.item div.callout { \
background-image: url("/myfritz/css/default/images/callout.gif"); \
} \
\
.item div.callcurrent { \
background-image: url("/myfritz/css/default/images/call_current.gif"); \
} \
\
.item div.call_date, \
.item div.call_dura, \
.item div.call_desc { \
display: table-cell; \
text-align: right; \
color: #666666; \
padding: 0 0 0 0.5em; \
} \
\
.item div.call_desc { \
min-width: 5.5em; \
text-align: right; \
width: 100%; \
} \
\
.item div.call_date { \
text-align: left; \
} \
\
.item div.call_date p, \
.item div.call_dura p, \
.item div.call_desc p { \
width: 100%; \
font-size: 85%; \
} \
\
@media (max-width: 360px) { \
/*Ultra Mobile*/ \
.calls .item div.call_desc { \
display: none; \
} \
} \
/****************** ENDE Items ******************/');
var lCallsId = "callsArea";
var lCallsArea = null;
var lCallsIdx = -1;
var lClickToDialActiv = false;
var lDataRefreshTimer = null;
var lJson = makeJSONParser();
var lRefreshObj = null;
var lRefreshLock = null;
lib.cbRefreshData = function(response)
{
if (response && response.status == 200)
{
var resp = lJson(response.responseText);
if (resp && resp.ajax_id && gAjaxId[lCallsId] == resp.ajax_id)
{
gAjaxId[lCallsId] = null;
for (var i=0; i < resp.calls.length; i++)
{
lRefreshObj.calls[lRefreshObj.startPos + i] = resp.calls[i];
}
lRefreshObj.clickToDial = resp.clickToDial;
lRefreshObj.startPos = lRefreshObj.calls.length;
if (resp.calls.length > 0 && lRefreshObj.startPos < lRefreshObj.oldStartPos)
sendRefreshDataCmd();
else
{
lCallsArea.startPos = 0;
lCallsArea.items = [];
lCallsArea.children[gAreaContentIdx].innerHTML = "";
lib.draw(lRefreshObj);
lRefreshObj = null;
if ((gSmallScreen || gMediumScreen) && gOpenAreaIdx != null)
scroll(0, responsive.getAktScrollPosElem(lCallsIdx).elem.scrollTop);
else
lCallsArea.children[gAreaContentIdx].scrollTop = responsive.getAktScrollPosElem(lCallsIdx).elem.scrollTop;
lDataRefreshTimer = null;
}
}
else
{
lDataRefreshTimer = null;
lRefreshObj = null;
}
}
else
{
lDataRefreshTimer = null;
lRefreshObj = null;
}
};
function sendRefreshDataCmd()
{
if (lRefreshObj) getData(lRefreshObj, lib.cbRefreshData);
}
lib.refreshData = function()
{
if (lRefreshLock || (null != gOpenAreaIdx && gOpenAreaIdx != lCallsIdx))
{
lib.cancelDataRefresh();
return;
}
lib.cancelDataRefresh(true);
lRefreshObj = { "id":lCallsArea.id, "startPos":0, "calls":[], "luaUrl":lCallsArea.luaUrl, "oldStartPos":lCallsArea.items.length, "clickToDial":false};
lRefreshLock = setTimeout(function() { lRefreshLock = null; }, 10000);
sendRefreshDataCmd();
}
lib.cancelDataRefresh = function(timerOnly)
{
if (null != lDataRefreshTimer )
{
clearTimeout(lDataRefreshTimer);
if(!timerOnly) lDataRefreshTimer = null;
}
}
lib.autoDataRefresh = null;
function autoDataRefreshTimer()
{
if (null == lDataRefreshTimer) lDataRefreshTimer = setTimeout( lib.refreshData, 30000);
}
lib.init = function()
{
lCallsIdx = gAreasIdx[lCallsId];
lCallsArea = gAreas[lCallsIdx];
lCallsArea.startPos = 0;
lCallsArea.items = [];
lCallsArea.waitItem = null;
lCallsArea.onScrollFunc = onCallsScroll;
lCallsArea.available = true;
lCallsArea.luaUrl = "/myfritz/areas/calls.lua";
lCallsArea.lib = lib;
};
lib.getCallDisplayNumber = function(call)
{
if ((typeof call.number != "string" || call.number=="") && (typeof call.name != "string" || call.name=="")) return "{?8002:166?}";
if (typeof call.name == "string" && call.name != "") return call.name;
return call.number;
};
function getCallType(type)
{
switch(type)
{
case 1: return "{?8002:611?}";
break;
case 2: return "{?8002:25?}";
break;
case 3: return "{?8002:897?}";
break;
case 4: return "{?8002:642?}";
break;
case 5: return "{?8002:793?}";
break;
}
return "";
}
function getCallIcon(type)
{
switch(type)
{
case 1: return "<div title='"+getCallType(type)+"' class='callIcon callin'></div>";
break;
case 2: return "<div title='"+getCallType(type)+"' class='callIcon callinfailed'></div>";
break;
case 3: return "<div title='"+getCallType(type)+"' class='callIcon callrejected'></div>";
break;
case 4: return "<div title='"+getCallType(type)+"' class='callIcon callout'></div>";
break;
case 5: return "<div title='"+getCallType(type)+"' class='callIcon callcurrent'></div>";
break;
}
return "";
}
function getDuration(duration,type)
{
if (duration == "0:00" && type == "2")
return "-:-";
else
return duration;
}
lib.draw = function(resp)
{
if (lCallsArea.waitItem != null)
{
lCallsArea.children[gAreaContentIdx].removeChild(lCallsArea.waitItem);
lCallsArea.waitItem = null;
}
if (!lClickToDialActiv) lClickToDialActiv = resp.clickToDial;
if (resp.calls && resp.calls.length > 0)
{
lCallsArea.startPos += resp.calls.length;
responsive.setScrollEventListener(lCallsArea);
lCallsArea.ajaxDataAvail = true;
}
else
{
lCallsArea.startPos = -1;
lCallsArea.ajaxDataAvail = false;
responsive.removeScrollEventListener(lCallsArea);
}
var template = createItemTemplate(4);
template.children[1].setAttribute('class', 'call_date');
template.children[2].setAttribute('class', 'call_dura');
template.children[3].setAttribute('class', 'call_desc');
var curPort = 0;
var deviceType = getDeviceType();
if ( !lClickToDialActiv && "mobile" != deviceType && "aPad" != deviceType )
{
template.setAttribute('class', 'item notClickable');
}
for (var i = 0; i < resp.calls.length; i++)
{
var itemCnt = lCallsArea.items.length || 0;
curPort = parseInt(resp.calls[i].port, 10);
var aktElem = template.cloneNode(true);
aktElem.children[0].innerHTML = getCallIcon(resp.calls[i].call_type) + "<p>" + lib.getCallDisplayNumber(resp.calls[i]) + "</p>";
aktElem.children[1].innerHTML = "<p>" + getDateStr(resp.calls[i].date) + "</p>";
aktElem.children[2].innerHTML = "<p>" + getDuration(resp.calls[i].duration, resp.calls[i].call_type) + "</p>";
aktElem.children[3].innerHTML = "<p>" + getCallType(resp.calls[i].call_type) + "</p>";
lCallsArea.children[gAreaContentIdx].appendChild(aktElem);
if (resp.calls[i].number != "") aktElem.children[0].addEventListener("click", createNumOnClickHandler(itemCnt,deviceType), false);
lCallsArea.items[itemCnt] = resp.calls[i];
}
if (!lCallsArea.items.length || lCallsArea.items.length < 1)
{
getEmtyItem(lCallsArea.children[gAreaContentIdx], "<p>{?8002:456?}</p>");
}
responsive.pageContentAreaSizeCorrection(lCallsArea);
lib.autoDataRefresh = autoDataRefreshTimer;
};
function createNativCallLink(idx)
{
var downLink = document.createElement("a");
downLink.href = "tel:"+lCallsArea.items[idx].number;
downLink.setAttribute('class', 'downloadLink');
document.body.appendChild(downLink);
if (downLink.click) downLink.click();
else if (document.dispatchEvent)
{
var clickEvt = document.createEvent("MouseEvent");
clickEvt.initEvent("click", true, true);
downLink.dispatchEvent(clickEvt);
}
else if (document.fireEvent) downLink.fireEvent('onclick');
document.body.removeChild(downLink);
}
function cbDialNumber(response)
{
if (response && response.status == 200)
{
var resp = lJson(response.responseText || "null");
if (resp && resp.ajax_id && gAjaxId[lCallsId+"Ctd"] == resp.ajax_id)
{
gAjaxId[lCallsId+"Ctd"] = null;
var idx = parseInt(resp.cid, 10);
if (isNaN(idx)) return;
if (idx < 0)
{
alert("{?8002:883?}");
}
else
{
var txtMld1 = "{?8002:593?}";
var txtMld2 = "{?8002:931?}";
var txtMld3 = "{?8002:376?}";
var mld = jxl.sprintf(txtMld1, lCallsArea.items[idx].number)+"\x0A\x0A"+
jxl.sprintf(txtMld2, lCallsArea.items[idx].port_name)+
"\x0A\x0A"+txtMld3;
if (!confirm(mld)) clickToDial('dial','hangup','-1');
}
}
}
}
function clickToDial(action, dialNum, callId)
{
var url = encodeURI("/myfritz/areas/calls.lua");
url = addUrlParam(url, "sid", gSid);
var ajaxId = getAjaxId();
gAjaxId[lCallsId+"Ctd"] = ajaxId;
url = addUrlParam(url, "ajax_id", ajaxId);
url = addUrlParam(url, "cmd", "cn");
url = addUrlParam(url, "cid", callId);
if (action == "dial" && dialNum)
{
if (dialNum == "hangup")
url = addUrlParam(url, "action", dialNum);
else
{
url = addUrlParam(url, "action", "dial");
url = addUrlParam(url, "number", dialNum);
}
}
ajaxGet(url, cbDialNumber);
}
function getDeviceType()
{
var deviceType = "pc";
if (navigator.userAgent.search(/Mobile/) > -1 && navigator.platform.search(/iPad/) < 0)
{
deviceType = "mobile";
}
else if (navigator.userAgent.search(/Android/) > -1)
{
deviceType = "aPad";
}
else if (navigator.userAgent.search(/iPad/) > -1)
{
deviceType = "iPad";
}
return deviceType;
}
function createNumOnClickHandler( aktCnt, deviceTypePar )
{
var idx = aktCnt;
var deviceType = deviceTypePar;
function onNumberClick()
{
if ( "mobile" == deviceType )
{
createNativCallLink(idx);
}
else
{
if (lClickToDialActiv)
clickToDial("dial", lCallsArea.items[idx].number, idx);
else if ( "aPad" == deviceType )
createNativCallLink(idx);
}
}
return onNumberClick;
}
function onCallsScroll()
{
var oldWidth = gScreenWidth;
setScreenSize();
if (oldWidth != gScreenWidth) return;
var obj = responsive.getAktScrollPosElem(lCallsIdx);
if (obj.elem.scrollHeight > obj.offset && obj.elem.scrollTop > 0 && (obj.elem.scrollHeight - obj.offset - obj.elem.scrollTop) < gScrollLoadDelta && lCallsArea.startPos > -1 && gAjaxId[lCallsId] == null)
{
gGetDataTimeout.calls = clearTimeout(gGetDataTimeout.calls);
getDataOfArea(lCallsArea);
lCallsArea.waitItem = getEmtyItem(lCallsArea.children[gAreaContentIdx], "<p></p>");
jxl.addClass(lCallsArea.waitItem, "wait_state");
lCallsArea.children[gAreaContentIdx].appendChild(lCallsArea.waitItem);
responsive.pageContentAreaSizeCorrection(lCallsArea);
}
lCallsArea.lastScrollPos = obj.elem.scrollTop;
}
return lib;
})();
