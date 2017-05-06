var answerJs = answerJs || (function() {
"use strict";
var lib = {};
jxl.createStyleTag(' \
/****************** Seiten Inhalt ******************/ \
/* Mobile */ \
@media (max-width: 759px) { \
.answer .area_overview { \
background-color: #ffeb0d; \
background-size: 72em 4.5em; \
background-image: radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffeb0d 93%, #ffeb0d 100%), \
linear-gradient(42deg, rgba(122, 112, 6, 0.5), rgba(156, 144, 8, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 14.0%, rgba(255, 251, 191, 0.5) 24%); \
background-image: -webkit-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffeb0d 93%, #ffeb0d 100%), \
-webkit-linear-gradient(42deg, rgba(122, 112, 6, 0.5), rgba(156, 144, 8, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 14.0%, rgba(255, 251, 191, 0.5) 24%); \
background-image: -moz-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffeb0d 93%, #ffeb0d 100%), \
-moz-linear-gradient(42deg, rgba(122, 112, 6, 0.5), rgba(156, 144, 8, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 14.0%, rgba(255, 251, 191, 0.5) 24%); \
background-image: -o-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffeb0d 93%, #ffeb0d 100%), \
-o-linear-gradient(42deg, rgba(122, 112, 6, 0.5), rgba(156, 144, 8, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 14.0%, rgba(255, 251, 191, 0.5) 24%); \
background-image: -ms-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #ffeb0d 93%, #ffeb0d 100%), \
-ms-linear-gradient(42deg, rgba(122, 112, 6, 0.5), rgba(156, 144, 8, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 12.5%, rgba(206, 198, 62, 0.5) 14.0%, rgba(255, 251, 191, 0.5) 24%); \
} \
\
.answer .area_ov_icon { \
background-image: url("/myfritz/css/default/images/icon_tam.png"); \
} \
} \
/****************** ENDE Seiten Inhalt ******************/ \
\
/****************** OVERVIEW ******************/ \
.answer .area_overview td:nth-child(2) { \
width: 4.4em; \
} \
/****************** ENDE OVERVIEW ******************/ \
\
/****************** Items ******************/ \
#answerContent .item { \
cursor: auto; \
} \
\
#answerContent .item div:first-child { \
cursor: pointer; \
} \
\
.item div.playBtn { \
width: 5mm; \
height: 5mm; \
padding: 0; \
background-image: url("/myfritz/css/default/images/icon_hear_call.gif"); \
background-position: center; \
background-repeat: no-repeat; \
} \
.item p.newMsg { \
font-weight: bold; \
} \
/****************** ENDE Items ******************/');
var lAnswerId = "answerArea";
var lAnswerArea = null;
var lAnswerIdx = -1;
var lDataRefreshTimer = null;
var lJson = makeJSONParser();
var lRefreshObj = null;
var lRefreshLock = null;
lib.cbRefreshData = function(response)
{
if (response && response.status == 200)
{
var resp = lJson(response.responseText);
if (resp && resp.ajax_id && gAjaxId[lAnswerId] == resp.ajax_id)
{
gAjaxId[lAnswerId] = null;
for (var i=0; i < resp.tamcalls.length; i++)
{
lRefreshObj.tamcalls[lRefreshObj.startPos + i] = resp.tamcalls[i];
}
lRefreshObj.startPos = lRefreshObj.tamcalls.length;
if (resp.tamcalls.length > 0 && lRefreshObj.startPos < lRefreshObj.oldStartPos)
sendRefreshDataCmd();
else
{
for (var j = 0; j < lAnswerArea.items.length; j++)
{
var oldElem = jxl.get("tamDetail" + j) || null;
if (oldElem && jxl.hasClass(oldElem, "show"))
{
for (var i = 0; i < lRefreshObj.tamcalls.length; i++)
{
if (lAnswerArea.items[j].index == lRefreshObj.tamcalls[i].index && lAnswerArea.items[j].date == lRefreshObj.tamcalls[i].date)
{
lRefreshObj.tamcalls[i].open = true;
}
}
}
}
lAnswerArea.startPos = 0;
lAnswerArea.items = [];
lAnswerArea.children[gAreaContentIdx].innerHTML = "";
lib.draw(lRefreshObj);
lRefreshObj = null;
if ((gSmallScreen || gMediumScreen) && gOpenAreaIdx != null)
scroll(0, responsive.getAktScrollPosElem(lAnswerIdx).elem.scrollTop);
else
lAnswerArea.children[gAreaContentIdx].scrollTop = responsive.getAktScrollPosElem(lAnswerIdx).elem.scrollTop;
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
if (lRefreshLock || (null != gOpenAreaIdx && gOpenAreaIdx != lAnswerIdx))
{
lib.cancelDataRefresh();
return;
}
lib.cancelDataRefresh(true);
lRefreshObj = { "id":lAnswerArea.id, "startPos":0, "tamcalls":[], "luaUrl":lAnswerArea.luaUrl, "oldStartPos":lAnswerArea.items.length };
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
lAnswerIdx = gAreasIdx[lAnswerId];
lAnswerArea = gAreas[lAnswerIdx];
lAnswerArea.startPos = 0;
lAnswerArea.items = [];
lAnswerArea.waitItem = null;
lAnswerArea.onScrollFunc = onAnswerScroll;
lAnswerArea.luaUrl = "/myfritz/areas/answer.lua";
lAnswerArea.available = true;
lAnswerArea.lib = lib;
};
lib.getAnswerDisplayNumber = function(tamcall)
{
if ((typeof tamcall.number != "string" || tamcall.number=="") && (typeof tamcall.name != "string" || tamcall.name=="")) return "{?319:198?}";
if (typeof tamcall.name == "string" && tamcall.name != "") return tamcall.name;
return tamcall.number;
};
lib.createOnAudioClick = function (elem, idx)
{
var audioElem = elem;
var tamIdx = idx;
function onAudioClick()
{
if (jxl.hasClass(audioElem, "show"))
{
jxl.removeClass(audioElem, "show");
if (audioPlayer.tamFilePlaying()) audioPlayer.close();
}
else
{
jxl.addClass(audioElem, "show");
if (!gIosHttps)
{
audioPlayer.open( gSid, lAnswerArea.items ,tamIdx );
lib.resetNewTamMsg(audioElem);
}
}
}
return onAudioClick;
};
lib.resetNewTamMsg = function ( tamElemChild )
{
var tamElem = tamElemChild.parentNode;
var elems = jxl.getByClass( "newMsg", tamElemChild.parentNode, "p" );
for ( var idx in elems )
{
if ( elems[idx] ) jxl.removeClass( elems[idx], "newMsg" );
}
return true;
};
function getAudioLink(tamcall, tamcallElemChild3)
{
var url = encodeURI("/myfritz/cgi-bin/luacgi_notimeout");
url = addUrlParam(url, "sid", gSid);
url = addUrlParam(url, "cmd", "tam");
url = addUrlParam(url, "tam", tamcall.tam);
url = addUrlParam(url, "msg", tamcall.index);
url = addUrlParam(url, "td", tamcall.date || "");
url = addUrlParam(url, "cmd_files", tamcall.path);
url = addUrlParam(url, "script", "/http_file_download.lua");
return "<a onclick='answerJs.resetNewTamMsg(this.parentNode)' href='" + url + "'>{?319:749?}</a>";
}
lib.draw = function(resp)
{
if (lAnswerArea.waitItem != null)
{
lAnswerArea.children[gAreaContentIdx].removeChild(lAnswerArea.waitItem);
lAnswerArea.waitItem = null;
}
if (resp.tamcalls && resp.tamcalls.length > 0)
{
lAnswerArea.startPos += resp.tamcalls.length;
responsive.setScrollEventListener(lAnswerArea);
lAnswerArea.ajaxDataAvail = true;
}
else
{
lAnswerArea.startPos = -1;
lAnswerArea.ajaxDataAvail = false;
responsive.removeScrollEventListener(lAnswerArea);
}
var template = createItemTemplate(4);
template.children[1].setAttribute('class', 'call_date');
template.children[2].setAttribute('class', 'call_dura');
template.children[3].setAttribute('class', 'details');
for (var i = 0; i < resp.tamcalls.length; i++)
{
var aktElem = template.cloneNode(true);
var itemCnt = lAnswerArea.items.length || 0;
var newMsg = (resp.tamcalls[i]["new"]) ? "class='newMsg'" : "";
var numberStr = lib.getAnswerDisplayNumber(resp.tamcalls[i]);
aktElem.children[0].innerHTML = "<div class='playBtn' title='{?319:904?}'></div><p " + newMsg + ">" + numberStr + "</p>";
var dateStr = getDateStr(resp.tamcalls[i].date);
aktElem.children[1].innerHTML = "<p>" + dateStr + "</p>";
aktElem.children[2].innerHTML = "<p>" + resp.tamcalls[i].duration + "</p>";
aktElem.children[3].id = "tamDetail" + itemCnt;
aktElem.children[3].innerHTML = getAudioLink(resp.tamcalls[i], aktElem.children[3]);
lAnswerArea.children[gAreaContentIdx].appendChild(aktElem);
if (resp.tamcalls[i].open) jxl.addClass(aktElem.children[3], "show");
resp.tamcalls[i].open = null;
aktElem.children[0].addEventListener("click", lib.createOnAudioClick(aktElem.children[3], itemCnt), false);
lAnswerArea.items[itemCnt] = resp.tamcalls[i];
lAnswerArea.items[itemCnt].filename = numberStr + ", " + dateStr;
}
if (!lAnswerArea.items.length || lAnswerArea.items.length < 1)
{
getEmtyItem(lAnswerArea.children[gAreaContentIdx], "<p>{?319:679?}</p>");
}
responsive.pageContentAreaSizeCorrection(lAnswerArea);
lib.autoDataRefresh = autoDataRefreshTimer;
};
function onAnswerScroll()
{
var oldWidth = gScreenWidth;
setScreenSize();
if (oldWidth != gScreenWidth) return;
var obj = responsive.getAktScrollPosElem(lAnswerIdx);
if (obj.elem.scrollHeight > obj.offset && obj.elem.scrollTop > 0 && (obj.elem.scrollHeight - obj.offset - obj.elem.scrollTop) < gScrollLoadDelta && lAnswerArea.startPos > -1 && gAjaxId[lAnswerId] == null)
{
gGetDataTimeout.answer = clearTimeout(gGetDataTimeout.answer);
getDataOfArea(lAnswerArea);
lAnswerArea.waitItem = getEmtyItem(lAnswerArea.children[gAreaContentIdx], "<p></p>");
jxl.addClass(lAnswerArea.waitItem, "wait_state");
lAnswerArea.children[gAreaContentIdx].appendChild(lAnswerArea.waitItem);
responsive.pageContentAreaSizeCorrection(lAnswerArea);
}
lAnswerArea.lastScrollPos = obj.elem.scrollTop;
}
return lib;
})();
