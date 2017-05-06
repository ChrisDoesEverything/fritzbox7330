var responsive = responsive || (function() {
"use strict";
var lib = {};
var lResizeTimer = null;
var lIntroBoxElem = null;
var lNavBoxElem = null;
var lFootBoxElem = null;
var lFakeArea = null;
var lFakeAreaHead = null;
var lPaginationElem = null;
var lLastOpenAreaIdx = null;
var lEmInPixProduct = {};
var lOverviewDataNeeded = true;
function setAreaMediumSizeDetail()
{
var pageContentWidth = gPageContentDiv.offsetWidth;
var marginSide = lEmInPixProduct["2"];
var marginSideTimes2 = lEmInPixProduct["4"];
var marginMiddle = marginSide;
var areaMinWidth = lEmInPixProduct["11"];
var areaMinWidthTimes2 = lEmInPixProduct["22"];
var showAreaMaxWidth = lEmInPixProduct["28"];
var hiddenAreaHeight = lEmInPixProduct["2.6"];
var areaMarginTimes2 = lEmInPixProduct["2"];
var introBoxElemHeight = 0
if (!lIntroBoxElem) lIntroBoxElem = jxl.get("intro_box");
if (lIntroBoxElem && typeof lIntroBoxElem.offsetHeight == "number") introBoxElemHeight = lIntroBoxElem.offsetHeight;
var navBoxElemHeight = 0
if (!lNavBoxElem) lNavBoxElem = jxl.get("nav_box");
if (lNavBoxElem && typeof lNavBoxElem.offsetHeight == "number") navBoxElemHeight = lNavBoxElem.offsetHeight;
var pageUpperOffsetHeight = navBoxElemHeight + introBoxElemHeight;
var pageContentWidthDelta = pageContentWidth - ((marginSideTimes2) + marginMiddle + (areaMinWidthTimes2) + (areaMarginTimes2));
var showAreaWidth = areaMinWidth + pageContentWidthDelta;
if (showAreaWidth > showAreaMaxWidth)
{
pageContentWidthDelta = showAreaWidth - showAreaMaxWidth;
showAreaWidth = showAreaMaxWidth;
}
else
{
pageContentWidthDelta = 0;
}
if (pageContentWidthDelta > 0)
{
marginSide += pageContentWidthDelta / 2;
}
for (var i = 0; i < gAreas.length; i++)
{
if (jxl.hasClass(gAreas[i], "hide"))
{
gAreas[i].style.top = (pageUpperOffsetHeight + (hiddenAreaHeight * i)) + "px";
gAreas[i].style.marginLeft = marginSide + "px";
}
else if (jxl.hasClass(gAreas[i], "show"))
{
if (!lFakeArea)
{
lFakeArea = document.createElement("div");
lFakeArea.id = "fakeArea";
gPageContentDiv.appendChild(lFakeArea);
jxl.addClass(lFakeArea, "area_box");
jxl.addClass(lFakeArea, "hide");
var fakeAreaFakeHead = document.createElement("div");
lFakeArea.appendChild(fakeAreaFakeHead);
jxl.addClass(fakeAreaFakeHead, "area_head");
jxl.addClass(fakeAreaFakeHead, "hide");
jxl.addEventHandler(lFakeArea, "click", scrollToTop);
}
lFakeArea.style.top = (pageUpperOffsetHeight + (hiddenAreaHeight * i)) + "px";
lFakeArea.style.marginLeft = marginSide + "px";
lFakeArea.children[gAreaHeadIdx].innerHTML = gAreas[i].children[gAreaHeadIdx].innerHTML;
jxl.display(lFakeArea, true);
gAreas[i].style.width = showAreaWidth + "px";
gAreas[i].style.marginLeft = (marginSide + areaMinWidth + marginMiddle) + "px";
}
}
}
function setAreaMediumSizeHomeView(pageContentHeight)
{
var marginSide = lEmInPixProduct["1"];
var marginSideTimes2 = lEmInPixProduct["2"];
var areaMinWidth = lEmInPixProduct["18.8"];
var areaMaxWidth = lEmInPixProduct["26"];
var areaContentMinHeight = lEmInPixProduct["10"];
distributeAreasEqualy(marginSide, marginSideTimes2, areaMinWidth, areaMaxWidth, areaContentMinHeight, pageContentHeight);
}
function setAreaBigSize()
{
var marginSide = lEmInPixProduct["1"];
var marginSideTimes2 = lEmInPixProduct["2"];
var areaMinWidth = lEmInPixProduct["20"];
var areaMaxWidth = lEmInPixProduct["26"];
var areaContentMinHeight = lEmInPixProduct["12"];
var pageContentHeight = gPageContentDiv.offsetHeight;
distributeAreasEqualy(marginSide, marginSideTimes2, areaMinWidth, areaMaxWidth, areaContentMinHeight, pageContentHeight);
}
function distributeAreasEqualy(marginSide, marginSideTimes2, areaMinWidth, areaMaxWidth, areaContentMinHeight, pageContentHeight)
{
var pageContentWidth = gPageContentDiv.offsetWidth;
var areaHeadHeight = lEmInPixProduct["1.6"];
var areaBoxPaddingBottom = lEmInPixProduct["0.33"];
var areaMarginFull = lEmInPixProduct["1"];
var areaMargin = lEmInPixProduct["0.5"];
var areaBorder = lEmInPixProduct["0.06"];
var areaBorderFull = lEmInPixProduct["0.12"];
var useMaxwidth = false;
var areaColumnCnt = Math.floor( (pageContentWidth - (marginSideTimes2)) / (areaMinWidth + areaMarginFull + areaBorderFull) );
var areaRowCnt = Math.ceil(gAreas.length / areaColumnCnt);
if (areaColumnCnt > gAreas.length)
{
areaColumnCnt = gAreas.length;
useMaxwidth = true;
}
var areaColumnIdxSmallerAreas = (areaRowCnt * areaColumnCnt) - gAreas.length;
var pageContentWidthDelta = (pageContentWidth - (marginSideTimes2)) - (areaColumnCnt * (areaMinWidth + areaMarginFull + areaBorderFull));
var newAreaWidth = areaMinWidth + Math.floor(pageContentWidthDelta / areaColumnCnt);
var newMarginSide = marginSide;
if (useMaxwidth && (newAreaWidth > areaMaxWidth))
{
newMarginSide = marginSide + Math.floor((areaColumnCnt * (newAreaWidth - areaMaxWidth)) / 2);
newAreaWidth = areaMaxWidth;
}
var newAreaContentHeightSmaller = (pageContentHeight / areaRowCnt) - (areaMarginFull + areaBorderFull + areaHeadHeight + areaBoxPaddingBottom);
if (newAreaContentHeightSmaller < areaContentMinHeight) newAreaContentHeightSmaller = areaContentMinHeight;
var newAreaContentHeightBigger = (((newAreaContentHeightSmaller + areaMarginFull + areaBorderFull + areaHeadHeight + areaBoxPaddingBottom) * areaRowCnt) / (areaRowCnt - 1)) - (areaMarginFull + areaBorderFull + areaHeadHeight + areaBoxPaddingBottom);
var columnPosition = [];
for (var i = 0; i < gAreas.length; i++)
{
var aktColumn = i + 1;
while(aktColumn > areaColumnCnt)
{
aktColumn -= areaColumnCnt;
}
var aktRow = Math.ceil((i + 1) / areaColumnCnt);
gAreas[i].style.width = newAreaWidth + "px";
if (aktRow == 1)
{
columnPosition[aktColumn] = ((aktColumn - 1) * (newAreaWidth + areaBorderFull + areaMarginFull)) + areaBorder + newMarginSide;
gAreas[i].style.left = columnPosition[aktColumn] + "px";
}
else
{
aktColumn = areaColumnCnt - (aktColumn - 1);
gAreas[i].style.left = columnPosition[aktColumn] + "px";
}
if (aktColumn > areaColumnIdxSmallerAreas)
{
gAreas[i].style.top = ((aktRow - 1) * (newAreaContentHeightSmaller + areaMarginFull + areaBorderFull + areaHeadHeight + areaBoxPaddingBottom)) + "px";
}
else
{
gAreas[i].style.top = ((aktRow - 1) * (newAreaContentHeightBigger + areaMarginFull + areaBorderFull + areaHeadHeight + areaBoxPaddingBottom)) + "px";
}
for (var c = 0; c < gAreas[i].children.length; c++)
{
if (jxl.hasClass(gAreas[i].children[c], "area_content"))
{
if (aktColumn > areaColumnIdxSmallerAreas)
gAreas[i].children[c].style.height = newAreaContentHeightSmaller+"px";
else
gAreas[i].children[c].style.height = newAreaContentHeightBigger+"px";
}
}
}
}
function resetAreas()
{
gPageContentDiv.style.padding = "";
jxl.removeClass(gPageContentDiv, "wait_state");
if (lFakeArea) jxl.display(lFakeArea, false);
for (var i = 0; i < gAreas.length; i++)
{
gAreas[i].title = "";
gAreas[i].style.width = "";
gAreas[i].style.height = "";
gAreas[i].style.top = "";
gAreas[i].style.left = "";
gAreas[i].style.margin = "";
jxl.removeEventHandler(gAreas[i].children[gAreaFootIdx], "click", lib.openArea)
if (!gSmallScreen && !jxl.hasClass(gAreas[i].children[gAreaFootIdx], "show")) jxl.addEventHandler(gAreas[i].children[gAreaFootIdx], "click", lib.openArea);
}
}
lib.setScrollEventListener = function(area, noRemovel)
{
if (!noRemovel) lib.removeScrollEventListener(area);
if (gSmallScreen && gOpenAreaIdx != null)
{
window.addEventListener("scroll", gAreas[gOpenAreaIdx].onScrollFunc, false);
}
else if (gMediumScreen && gOpenAreaIdx != null)
{
window.addEventListener("scroll", gAreas[gOpenAreaIdx].onScrollFunc, false);
}
else if (gBigScreen || gMediumScreen)
{
if (area && area.onScrollFunc)
area.children[gAreaContentIdx].addEventListener("scroll", area.onScrollFunc, false);
else
for (var i = 0; i < gAreas.length; i++)
gAreas[i].children[gAreaContentIdx].addEventListener("scroll", gAreas[i].onScrollFunc, false);
}
};
lib.removeScrollEventListener = function(area)
{
if (area != null && area.onScrollFunc)
{
area.children[gAreaContentIdx].removeEventListener("scroll", area.onScrollFunc, false);
window.removeEventListener("scroll", area.onScrollFunc, false);
}
else
{
for (var i = 0; i < gAreas.length; i++)
{
gAreas[i].children[gAreaContentIdx].removeEventListener("scroll", gAreas[i].onScrollFunc, false);
window.removeEventListener("scroll", gAreas[i].onScrollFunc, false);
}
}
};
function resizeProhibitor(evt)
{
if (lResizeTimer == null) lResizeTimer = setTimeout( lib.resizePageContentArea, 60);
}
lib.pageContentAreaSizeCorrection = function(area)
{
if (area && (gSmallScreen || (gMediumScreen && gOpenAreaIdx != null)))
{
lib.removeScrollEventListener(area);
setScreenSize();
if (!lIntroBoxElem) lIntroBoxElem = jxl.get("intro_box");
if (!lFootBoxElem) lFootBoxElem = jxl.get("foot_box");
if (!lPaginationElem) lPaginationElem = jxl.get("areaPagination");
var paginationOffsetHeight = 0;
if (lPaginationElem) paginationOffsetHeight = lPaginationElem.offsetHeight;
var offsetHeight = lIntroBoxElem.offsetHeight;
if (lFootBoxElem && (lFootBoxElem.offsetHeight > -1)) offsetHeight += lFootBoxElem.offsetHeight;
if (gMediumScreen && lNavBoxElem && (lNavBoxElem.offsetHeight > -1)) offsetHeight += lNavBoxElem.offsetHeight;
var newHeight = gScreenHeight - offsetHeight;
if (gSmallScreen)
{
gPageContentDiv.style.height = "";
if ((gPageContentDiv.offsetHeight + paginationOffsetHeight) < newHeight)
gPageContentDiv.style.height = newHeight + "px";
else
gPageContentDiv.style.height = (gPageContentDiv.offsetHeight + paginationOffsetHeight) + "px";
}
else
{
if (gPageContentDiv.scrollHeight < newHeight)
gPageContentDiv.style.height = newHeight + "px";
else
gPageContentDiv.style.height = (gAreas[gOpenAreaIdx].scrollHeight + gEmInPx) + "px";
}
lib.setScrollEventListener(area, true);
}
};
lib.resizePageContentArea = function()
{
lResizeTimer = null;
setScreenSize();
jxl.removeClass("sso_dropdown", "showlist");
jxl.addClass("sso_dropdown", "hidelist");
jxl.display("sso_dropdown_list", false);
jxl.display("sso_logout", !gSmallScreen);
jxl.display("old_logout", gSmallScreen);
if (!lIntroBoxElem) lIntroBoxElem = jxl.get("intro_box");
if (!lNavBoxElem) lNavBoxElem = jxl.get("nav_box");
if (!lFootBoxElem) lFootBoxElem = jxl.get("foot_box");
if (!gPageContentDiv ||
!lIntroBoxElem ||
typeof lIntroBoxElem.offsetHeight != "number" ||
((!lNavBoxElem || typeof lNavBoxElem.offsetHeight != "number") && !gSmallScreen) ||
((!lFootBoxElem || typeof lFootBoxElem.offsetHeight != "number") && !gSmallScreen) ||
gScreenHeight < 0 ) return;
var offsetHeight = lIntroBoxElem.offsetHeight;
if (gSmallScreen && lFootBoxElem && (lFootBoxElem.offsetHeight > -1))
{
offsetHeight += lFootBoxElem.offsetHeight;
}
else if ((gBigScreen || gMediumScreen) && lNavBoxElem && (lNavBoxElem.offsetHeight > -1) && lFootBoxElem && (lFootBoxElem.offsetHeight > -1))
{
offsetHeight += lNavBoxElem.offsetHeight + lFootBoxElem.offsetHeight;
}
var newHeight = gScreenHeight - offsetHeight;
lib.removeScrollEventListener();
resetAreas();
if (gSmallScreen)
{
if (lLastOpenAreaIdx != null)
{
var tmpIdx = lLastOpenAreaIdx;
lLastOpenAreaIdx = null;
lib.openArea(null, tmpIdx);
return;
}
if (gOpenAreaIdx != null && jxl.hasClass(gAreas[gOpenAreaIdx].children[gAreaContentIdx], "wait_state"))
{
getDataOfArea(gAreas[gOpenAreaIdx]);
jxl.addClass(gPageContentDiv, "wait_state");
}
else if(lOverviewDataNeeded)
{
getDataOfOverview();
lOverviewDataNeeded = false;
}
gPageContentDiv.style.height = "";
if (!lPaginationElem) lPaginationElem = jxl.get("areaPagination");
var paginationOffsetHeight = 0;
if (lPaginationElem) paginationOffsetHeight = lPaginationElem.offsetHeight;
if ((gPageContentDiv.offsetHeight + paginationOffsetHeight) < newHeight)
gPageContentDiv.style.height = newHeight + "px";
else
gPageContentDiv.style.height = (gPageContentDiv.offsetHeight + paginationOffsetHeight) + "px";
if (gOpenAreaIdx != null)
{
jxl.display(lFakeAreaHead, true);
scroll(0, gAreas[gOpenAreaIdx].lastScrollPos);
getMoreDataOfAreaIfNeeded(gAreas[gOpenAreaIdx]);
}
}
else if (gMediumScreen)
{
if (lLastOpenAreaIdx != null)
{
var tmpIdx = lLastOpenAreaIdx;
lLastOpenAreaIdx = null;
lib.openArea(null, tmpIdx);
return;
}
getAllAreaData();
jxl.display(lFakeAreaHead, false);
gPageContentDiv.style.height = "";
if (gOpenAreaIdx != null)
{
if (gPageContentDiv.scrollHeight < newHeight)
gPageContentDiv.style.height = newHeight + "px";
else
gPageContentDiv.style.height = (gAreas[gOpenAreaIdx].scrollHeight + gEmInPx) + "px";
if (gAreas.length > 1) setAreaMediumSizeDetail();
scroll(0, gAreas[gOpenAreaIdx].lastScrollPos);
getMoreDataOfAreaIfNeeded(gAreas[gOpenAreaIdx]);
}
else
{
gPageContentDiv.style.height = newHeight + "px";
setAreaMediumSizeHomeView(newHeight);
for (var i = 0; i < gAreas.length; i++)
{
gAreas[i].children[gAreaContentIdx].scrollTop = gAreas[i].lastScrollPos;
getMoreDataOfAreaIfNeeded(gAreas[i]);
}
}
}
else if (gBigScreen)
{
getAllAreaData();
if (gOpenAreaIdx != null) lLastOpenAreaIdx = gOpenAreaIdx;
lib.closeAreas(true);
jxl.display(lFakeAreaHead, false);
gPageContentDiv.style.height = newHeight+"px";
setAreaBigSize();
for (var i = 0; i < gAreas.length; i++)
{
gAreas[i].children[gAreaContentIdx].scrollTop = gAreas[i].lastScrollPos;
getMoreDataOfAreaIfNeeded(gAreas[i]);
}
}
lib.setScrollEventListener(null, true);
};
function cbChangeArea(evt, id, touchObj)
{
if (gScreenWidth != null && gScreenHeight != null && (gSmallScreen || gMediumScreen))
{
var nextAreaIdx = -1;
var aktAreaIdx = (gOpenAreaIdx == null) ? -1 : gOpenAreaIdx;
var threshold = 40;
if (gSmallScreen)
threshold = (gScreenWidth < gScreenHeight) ? gScreenWidth / 5 : gScreenHeight / 5;
else
threshold = (gScreenWidth < gScreenHeight) ? gScreenWidth / 7 : gScreenHeight / 7;
if (touchObj.direction == "right" && touchObj.direction == touchObj.startDirection && touchObj.lastX > (touchObj.startX + threshold) && touchObj.allowed)
{
touchObj.allowed = false;
if (gSmallScreen)
lib.closeSmallScreenMenu(evt);
if (aktAreaIdx < 0)
{
if (gMediumScreen)
nextAreaIdx = gAreas.length - 1;
else
return;
}
else if (aktAreaIdx == 0 )
{
lib.closeAreas();
return;
}
else if (aktAreaIdx > (gAreas.length - 1))
{
nextAreaIdx = gAreas.length - 2;
}
else
{
nextAreaIdx = aktAreaIdx - 1;
}
lib.openArea(null, nextAreaIdx);
}
else if (touchObj.direction == "left" && touchObj.direction == touchObj.startDirection && touchObj.lastX < (touchObj.startX - threshold) && touchObj.allowed)
{
touchObj.allowed = false;
if (gSmallScreen)
lib.closeSmallScreenMenu(evt);
if (aktAreaIdx >= (gAreas.length - 1))
{
if (gMediumScreen) lib.closeAreas();
return;
}
else if (aktAreaIdx < 0)
{
nextAreaIdx = 0;
}
else
{
nextAreaIdx = aktAreaIdx + 1;
}
lib.openArea(null, nextAreaIdx);
}
}
}
function scrollToTop()
{
scroll(0,0);
}
lib.closeAreas = function(doNotResize, nextOpenAreaIdx, noHistory, noCookie)
{
if (noHistory != true)
{
if (doNotResize && nextOpenAreaIdx != null && gOpenAreaIdx != nextOpenAreaIdx)
{
if (gOpenAreaIdx == null)
privateHistory.addToHistory(lib.closeAreas, [null,gOpenAreaIdx,true]);
else
privateHistory.addToHistory(lib.openArea, [null,gOpenAreaIdx,true]);
}
else if(doNotResize != true && nextOpenAreaIdx == null)
{
if (gOpenAreaIdx != null) privateHistory.addToHistory(lib.openArea, [null, gOpenAreaIdx, true]);
}
}
if (gOpenAreaIdx != null && gAreas.length > 1)
{
lib.removeScrollEventListener();
jxl.removeClass(gPageContentDiv, "show");
jxl.removeClass(document.body, "show");
for (var i = 0; i < gAreas.length; i++)
{
if (jxl.hasClass(gAreas[i], "show"))
{
jxl.removeClass(gAreas[i], "show");
jxl.removeClass(gAreas[i].id + "Switch", "show");
}
else if (jxl.hasClass(gAreas[i], "hide"))
jxl.removeClass(gAreas[i], "hide");
}
jxl.removeClass(gAreas[gOpenAreaIdx].children[gAreaHeadIdx], "show");
jxl.removeClass(gAreas[gOpenAreaIdx].children[gAreaContentIdx], "show");
jxl.removeClass(gAreas[gOpenAreaIdx].children[gAreaFootIdx], "show");
gOpenAreaIdx = null;
if (!jxl.hasClass("homeSwitch", "show"))
{
jxl.addClass("homeSwitch", "show");
}
if (!lFakeAreaHead) lFakeAreaHead = jxl.get("fakeAreaHead");
if (lFakeAreaHead) jxl.display(lFakeAreaHead, false);
if(!(doNotResize == true)) lib.resizePageContentArea();
}
if (noCookie != true) cookie.saveLastArea(gUserId, "overview");
};
lib.openArea = function(evt, nextAreaIdx, noHistory)
{
var areaToShow = null;
if (evt && evt.target && jxl.hasClass(evt.target, "switch"))
{
for (var i =0; i < evt.target.attributes.length; i++)
{
if (evt.target.attributes[i].name == "name")
areaToShow = jxl.get( evt.target.attributes[i].value.substr( 0, evt.target.attributes[i].value.length - "Switch".length ) );
}
}
else if (nextAreaIdx != null && nextAreaIdx >= 0 && nextAreaIdx <= (gAreas.length - 1))
{
areaToShow = gAreas[nextAreaIdx];
}
else if (!gBigScreen && evt && evt.target && jxl.hasClass(evt.target, "area_box") && !jxl.hasClass(evt.target, "show"))
{
areaToShow = evt.target;
}
else if (!gBigScreen && evt && evt.target && evt.target.parentNode && jxl.hasClass(evt.target.parentNode, "area_box") && !jxl.hasClass(evt.target.parentNode, "show"))
{
areaToShow = evt.target.parentNode;
}
if (!areaToShow) return;
lib.closeAreas(true, gAreasIdx[areaToShow.id], noHistory, true);
jxl.removeClass("homeSwitch", "show");
for (var i = 0; i < gAreas.length; i++)
{
if (gAreas[i].id != areaToShow.id) jxl.addClass(gAreas[i], "hide");
}
jxl.addClass(document.body, "show");
jxl.addClass(gPageContentDiv, "show");
jxl.addClass(areaToShow, "show");
areaToShow.children[gAreaContentIdx].style.height = "";
jxl.addClass(areaToShow.id + "Switch", "show");
jxl.addClass(areaToShow.children[gAreaHeadIdx], "show");
jxl.addClass(areaToShow.children[gAreaContentIdx], "show");
jxl.addClass(areaToShow.children[gAreaFootIdx], "show");
gOpenAreaIdx = gAreasIdx[areaToShow.id];
if (areaToShow.children[gAreaContentIdx].innerHTML != "" &&
!jxl.hasClass(areaToShow.children[gAreaContentIdx], "wait_state") &&
areaToShow.lib && areaToShow.lib.refreshData) areaToShow.lib.refreshData();
if (!lFakeAreaHead) lFakeAreaHead = jxl.get("fakeAreaHead");
if (lFakeAreaHead) lFakeAreaHead.innerHTML = areaToShow.children[gAreaHeadIdx].innerHTML;
lib.resizePageContentArea();
cookie.saveLastArea(gUserId, areaToShow.id);
};
function setPositionSmallScreenAreaHead()
{
if (gSmallScreen && gOpenAreaIdx != null && gAreas[gOpenAreaIdx].children[gAreaHeadIdx])
{
if (!lIntroBoxElem) lIntroBoxElem = jxl.get("intro_box");
if (!lFakeAreaHead) lFakeAreaHead = jxl.get("fakeAreaHead");
var elem = document.body;
if (elem.scrollTop == 0) elem = document.body.parentNode;
if (!lFakeAreaHead && lIntroBoxElem && elem.scrollTop >= lIntroBoxElem.offsetHeight)
{
lFakeAreaHead = document.createElement("div");
lFakeAreaHead.id = "fakeAreaHead";
lFakeAreaHead.setAttribute('class', 'area_head show');
lFakeAreaHead.innerHTML = gAreas[gOpenAreaIdx].children[gAreaHeadIdx].innerHTML;
document.body.appendChild(lFakeAreaHead);
jxl.addEventHandler(lFakeAreaHead, "click", scrollToTop);
}
else if(lFakeAreaHead && lIntroBoxElem)
{
jxl.display(lFakeAreaHead, (elem.scrollTop >= lIntroBoxElem.offsetHeight));
}
}
}
function fixSmallScreenMenu()
{
if (!gApp)
{
var footLinkBox = jxl.get("foot_link_box");
var navLinkBox = jxl.get("nav_link_box");
if (footLinkBox && navLinkBox && navLinkBox.offsetHeight)
{
footLinkBox.style.top = (((lEmInPixProduct["2.85"]) + navLinkBox.offsetHeight)) + "px";
}
}
}
function openSmallScreenMenu(evt)
{
if (!gApp)
{
if (jxl.hasClass("nav_box", "show"))
lib.closeSmallScreenMenu(evt)
else
{
jxl.addClass("nav_box", "show");
jxl.addClass("foot_box", "show");
if (evt.stopPropagation)
evt.stopPropagation();
else if(window.event)
window.event.cancelBubble=true;
privateHistory.addToHistory(lib.closeSmallScreenMenu, [null, true]);
window.addEventListener("click", lib.closeSmallScreenMenu, false);
fixSmallScreenMenu();
}
}
}
function isOutside(elem)
{
while (elem && "nav_box" != elem.id && "foot_box" != elem.id)
{
elem = elem.parentNode;
}
return !elem;
}
lib.closeSmallScreenMenu = function(evt, doNotChangeHistory)
{
if (!gApp && (!evt || (evt && isOutside(evt.target))))
{
if (jxl.hasClass("nav_box", "show"))
{
if (doNotChangeHistory != true) privateHistory.removeLastFuncHistoryEntry(lib.closeSmallScreenMenu);
jxl.removeClass("nav_box", "show");
jxl.removeClass("foot_box", "show");
window.removeEventListener("click", lib.closeSmallScreenMenu, false);
}
}
};
lib.getAktScrollPosElem = function(areaIdx)
{
var elem = document.body;
var offset = gScreenHeight;
if (elem.scrollTop == 0) elem = document.body.parentNode;
if (gBigScreen || (gMediumScreen && gOpenAreaIdx == null))
{
elem = gAreas[areaIdx].children[gAreaContentIdx];
offset = elem.offsetHeight;
}
return {elem:elem,offset:offset};
};
function createMobilePagination()
{
var pagiDiv = document.createElement("div");
pagiDiv.id = "areaPagination";
pagiDiv.setAttribute('class', 'areaPagination');
if (!lFootBoxElem) lFootBoxElem = jxl.get("foot_box");
lFootBoxElem.appendChild(pagiDiv);
var div = document.createElement("div");
div.setAttribute('name', 'homeSwitch');
div.id = "homeSwitch";
div.title = "{?940:108?}";
div.innerHTML = "<div name='homeSwitch' class='switch'></div>";
div.setAttribute('class', 'show switch');
pagiDiv.appendChild(div);
jxl.addEventHandler(div, "click", lib.closeAreas);
jxl.addEventHandler(div.children[0], "click", lib.closeAreas);
for (var i = 0; i < gAreas.length; i++)
{
jxl.addEventHandler(gAreas[i], "click", lib.openArea);
div = document.createElement("div");
div.setAttribute('name', gAreas[i].id + "Switch");
div.id = gAreas[i].id + "Switch";
div.title = gAreas[i].headline;
div.innerHTML = "<div name='"+gAreas[i].id+"Switch' class='switch'></div>";
div.setAttribute('class', 'switch');
pagiDiv.appendChild(div);
jxl.addEventHandler(div, "click", lib.openArea);
jxl.addEventHandler(div.children[0], "click", lib.openArea);
}
}
function tabletDetailDots()
{
for (var i = 0; i < gAreas.length; i++)
{
var div = document.createElement("div");
div.setAttribute('class', 'details');
gAreas[i].children[gAreaHeadIdx].appendChild(div);
for (var c = 0; c < 3; c++)
{
var udiv = document.createElement("div");
div.appendChild(udiv);
}
}
}
lib.init = function()
{
if (gApp)
{
lIntroBoxElem = {offsetHeight:0};
lNavBoxElem = {offsetHeight:0};
}
lEmInPixProduct = { "0.06" : 0.06 * gEmInPx,
"0.12" : 0.12 * gEmInPx,
"0.33" : 0.33 * gEmInPx,
"0.5" : 0.5 * gEmInPx,
"1" : gEmInPx,
"1.6" : 1.6 * gEmInPx,
"2" : 2 * gEmInPx,
"2.6" : 2.6 * gEmInPx,
"2.85" : 2.85 * gEmInPx,
"4" : 4 * gEmInPx,
"10" : 10 * gEmInPx,
"11" : 11 * gEmInPx,
"12" : 12 * gEmInPx,
"18.8" : 18.8 * gEmInPx,
"20" : 20 * gEmInPx,
"22" : 22 * gEmInPx,
"26" : 26 * gEmInPx,
"28" : 28 * gEmInPx };
if (gAreas.length < 1)
{
gPageContentDiv.innerHTML = "<h3>{?940:801?}</h3>";
}
else if (gAreas.length == 1)
{
lib.openArea(null, 0);
jxl.addClass(gAreas[gOpenAreaIdx], "single_area");
jxl.get("intro_logo").style.cursor = "auto";
}
else
{
createMobilePagination();
tabletDetailDots();
jxl.addEventHandler("intro_logo_link", "click", lib.closeAreas);
touch.registerElemForTouch(gPageContentDiv.id,"side",cbChangeArea);
var lastAreaIdx = gAreasIdx[cookie.getLastArea(gUserId)];
if (typeof lastAreaIdx == "number") lib.openArea(null, lastAreaIdx);
}
lib.resizePageContentArea();
jxl.addEventHandler("intro_menu_box", "click", openSmallScreenMenu);
};
window.addEventListener("scroll", setPositionSmallScreenAreaHead, false);
window.addEventListener("resize", resizeProhibitor, false);
return lib;
})();
