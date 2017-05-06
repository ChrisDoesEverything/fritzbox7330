var nasJs = nasJs || (function() {
"use strict";
var lib = {};
jxl.createStyleTag(' \
/****************** Seiten Inhalt ******************/ \
/* Mobile */ \
@media (max-width: 759px) { \
.nas .area_overview { \
background-color: #90d5ff; \
background-size: 72em 4.5em; \
background-image: radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #90d5ff 93%, #90d5ff 100%), \
linear-gradient(42deg, rgba(28, 89, 128, 0.5), rgba(40, 125, 181, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 14.0%, rgba(241, 250, 255, 0.5) 24%); \
background-image: -webkit-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #90d5ff 93%, #90d5ff 100%), \
-webkit-linear-gradient(42deg, rgba(28, 89, 128, 0.5), rgba(40, 125, 181, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 14.0%, rgba(241, 250, 255, 0.5) 24%); \
background-image: -moz-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #90d5ff 93%, #90d5ff 100%), \
-moz-linear-gradient(42deg, rgba(28, 89, 128, 0.5), rgba(40, 125, 181, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 14.0%, rgba(241, 250, 255, 0.5) 24%); \
background-image: -o-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #90d5ff 93%, #90d5ff 100%), \
-o-linear-gradient(42deg, rgba(28, 89, 128, 0.5), rgba(40, 125, 181, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 14.0%, rgba(241, 250, 255, 0.5) 24%); \
background-image: -ms-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #90d5ff 93%, #90d5ff 100%), \
-ms-linear-gradient(42deg, rgba(28, 89, 128, 0.5), rgba(40, 125, 181, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 12.5%, rgba(134, 198, 241, 0.5) 14.0%, rgba(241, 250, 255, 0.5) 24%); \
} \
\
.nas .area_ov_icon { \
background-image: url("/myfritz/css/default/images/icon_nas.png"); \
} \
} \
/****************** ENDE Seiten Inhalt ******************/ \
\
/****************** Items ******************/ \
.item div.nasIcon { \
display: inline-block; \
padding: 0; \
margin: -0.1em 0.25em 0 0; \
height: 6mm; \
width: 6mm; \
background-position: center; \
background-repeat: no-repeat; \
} \
\
.item div.dirup { \
background-image: url("/myfritz/css/default/images/icon_ordner_nach_oben.png"); \
} \
\
.item div.dirusb { \
background-image: url("/myfritz/css/default/images/ordner_usb_speicher.png"); \
} \
\
.item div.dirwebdav { \
background-image: url("/myfritz/css/default/images/ordner_online_speicher.png"); \
} \
\
.item div.dirvolatile { \
background-image: url("/myfritz/css/default/images/icon_ordner_fluechtig.png"); \
} \
\
.item div.dirstd { \
background-image: url("/myfritz/css/default/images/ordner.png"); \
} \
\
.item div.filevolatile { \
background-image: url("/myfritz/css/default/images/icon_datei_fluechtig.png"); \
} \
\
.item div.filemov { \
background-image: url("/myfritz/css/default/images/icon_film_20x20px.png"); \
} \
\
.item div.filemusic { \
background-image: url("/myfritz/css/default/images/icon_musik_20x20px.png"); \
} \
\
.item div.filedoc { \
background-image: url("/myfritz/css/default/images/icon_dokument_20x20px.png"); \
} \
\
.item div.fileimg { \
background-image: url("/myfritz/css/default/images/icon_bild_20x20px.png"); \
} \
\
.item div.fileother { \
background-image: url("/myfritz/css/default/images/icon_andere_datei_20x20px.png"); \
} \
\
.item div.nas_type, \
.item div.nas_size { \
display: table-cell; \
text-align: right; \
color: #666666; \
padding: 0 0 0 0.5em; \
} \
\
.item div.nas_type { \
text-align: left; \
} \
\
.item div.nas_type p, \
.item div.nas_size p { \
width: 100%; \
font-size: 85%; \
} \
/****************** ENDE Items ******************/');
var lNasId = "nasArea";
var lNasArea = null;
var lNasIdx = -1;
var lUnits = ["Byte", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
var lNasFirstEvtIdx = null;
var lNasLongPressTimer = null;
var lNasLongPress = true;
var lNasTypeTab = { D: "{?471:23?}",
directory: "{?471:145?}",
F: "{?471:671?}",
document: "{?471:904?}",
audio: "{?471:987?}",
video: "{?471:666?}",
picture: "{?471:736?}",
playlist: "{?471:639?}",
other: "{?471:913?}"
};
var lDataRefreshTimer = null;
var lJson = makeJSONParser();
var lRefreshObj = null;
var lRefreshLock = null;
var lFastRetryCnt = 0;
lib.cbRefreshData = function(response)
{
if (response && response.status == 200)
{
var resp = lJson(response.responseText);
if (resp && resp.ajax_id && gAjaxId[lNasId] == resp.ajax_id)
{
gAjaxId[lNasId] = null;
for (var i=0; i < resp.elems.length; i++)
{
lRefreshObj.elems[lRefreshObj.elems.length] = resp.elems[i];
}
lRefreshObj.startPos = resp.startPos;
lRefreshObj.browseMode = resp.browse_mode;
lRefreshObj.root = resp.root;
if (lRefreshObj.oldItemCnt > 0 && lRefreshObj.elems.length < 1 && "/" != lRefreshObj.curNasDir)
{
lDataRefreshTimer = null;
lRefreshObj = null;
privateHistory.removeAllOfType(changeNasDir);
changeNasDir("/", true);
return;
}
if (lRefreshObj.elems.length < lRefreshObj.oldItemCnt && resp.startPos > 0)
sendRefreshDataCmd();
else
{
lNasArea.startPos = 0;
resetNasItems();
lNasArea.waitItem = null;
lNasArea.children[gAreaContentIdx].innerHTML = "";
lib.draw(lRefreshObj);
lRefreshObj = null;
if ((gSmallScreen || gMediumScreen) && gOpenAreaIdx != null)
scroll(0, responsive.getAktScrollPosElem(lNasIdx).elem.scrollTop);
else
lNasArea.children[gAreaContentIdx].scrollTop = responsive.getAktScrollPosElem(lNasIdx).elem.scrollTop;
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
if ( lRefreshObj )
{
getNasData( lRefreshObj, lib.cbRefreshData );
}
}
function setRefreshLock(time)
{
if (!time || "number" != typeof time || 4000 > time) time = 4000;
clearTimeout(lRefreshLock);
lRefreshLock = setTimeout(function() { lRefreshLock = null; }, time);
}
lib.refreshData = function()
{
if ( lRefreshLock || ( null != gOpenAreaIdx && gOpenAreaIdx != lNasIdx ) )
{
lib.cancelDataRefresh();
return;
}
lib.cancelDataRefresh( true );
lRefreshObj = { "id":lNasArea.id, "startPos":1, "browseMode":"type:directory", "curNasDir":lNasArea.curNasDir, "root":false, "elems":[], "luaUrl":lNasArea.luaUrl, "oldItemCnt":lNasArea.items[lNasArea.curNasDir].length};
setRefreshLock();
sendRefreshDataCmd();
};
lib.cancelDataRefresh = function(timerOnly)
{
if (null != lDataRefreshTimer )
{
clearTimeout(lDataRefreshTimer);
if(!timerOnly) lDataRefreshTimer = null;
}
};
lib.autoDataRefresh = null;
function autoDataRefreshTimer()
{
if (null == lDataRefreshTimer)
{
var time = 30000;
var emty = jxl.hasClass(lNasArea.children[gAreaContentIdx].children[0], "emtyItem");
if(emty || lFastRetryCnt < 2)
{
if (emty && lFastRetryCnt < 4)
{
time = 5000;
lFastRetryCnt++;
showWaitState();
}
else
{
time = 10000;
lFastRetryCnt++;
}
}
lDataRefreshTimer = setTimeout( nasJs.refreshData, time);
}
}
lib.init = function()
{
lNasIdx = gAreasIdx[lNasId];
lNasArea = gAreas[lNasIdx];
lNasArea.startPos = 1;
lNasArea.browseMode = "type:directory";
lNasArea.curNasDir = "/";
lNasArea.items = {};
lNasArea.pics = {};
lNasArea.audio = {};
lNasArea.waitItem = null;
lNasArea.onScrollFunc = onNasScroll;
lNasArea.available = true;
lNasArea.luaUrl = "/myfritz/areas/nas.lua";
lNasArea.lib = lib;
};
function getNasIcon(file, isRoot)
{
if (file.type == "D" || file.type == "directory")
{
if (file.filename == "..")
return "<div class='nasIcon dirup'></div>";
else if (file.storagetype == "usb" && file.path == '/'+file.filename && isRoot)
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon dirusb'></div>";
else if (file.storagetype == "webdav" && file.path == '/'+file.filename && isRoot)
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon dirwebdav'></div>";
else if (file.storagetype == "ram")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon dirvolatile'></div>";
else
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon dirstd'></div>";
}
else
{
if (file.storagetype == "ram")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon filevolatile'></div>";
else if (file.type=="video")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon filemov'></div>";
else if (file.type=="audio" || file.type=="playlist")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon filemusic'></div>";
else if (file.type == "document")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon filedoc'></div>";
else if (file.type == "picture")
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon fileimg'></div>";
else
return "<div title="+(lNasTypeTab[file.type] || "")+" class='nasIcon fileother'></div>";
}
return "";
}
function getNewUnitString(oldUnit, unitDelta)
{
var newIdx = -1;
for (var i=0; i < lUnits.length; i++)
{
if ( lUnits[i].toLowerCase() == oldUnit.toLowerCase() && lUnits[i + unitDelta] != null)
{
newIdx = i + unitDelta;
break;
}
}
if(newIdx > -1) return lUnits[newIdx];
return "";
}
function humanReadable(fileSize, unitOfFileSize, precision, binaer, withUnitString)
{
var divisor = 1000;
if (binaer) divisor = 1024;
var unitDelta = 0;
if (!unitOfFileSize) unitOfFileSize = "byte";
var newUnitStr = unitOfFileSize;
var newFileSize = 0;
if (fileSize && typeof(fileSize) == "string") fileSize = Number(fileSize);
if (!fileSize || fileSize < 0) fileSize = 0;
if (precision && typeof(precision) == "string") precision = Number(precision);
if (!precision || precision < 0) precision = 0;
var tmp = fileSize;
while (tmp >= divisor && unitDelta < lUnits.length) {
unitDelta = unitDelta+1;
tmp = tmp / divisor;
}
if (binaer && tmp > 999)
{
unitDelta = unitDelta+1;
tmp = tmp / divisor;
}
newUnitStr = getNewUnitString(unitOfFileSize, unitDelta);
if (newUnitStr.toLowerCase() == "byte") precision = 0;
newFileSize = tmp.toFixed(precision).toString().replace(".", ",");;
if (withUnitString)
return newFileSize+' '+newUnitStr;
else
return newFileSize;
}
function getHumanReadableSize(size, type)
{
if (type == "D" || type == "directory") return "";
return humanReadable(size, "byte", 2, true, true);
}
lib.createDirHandler = function (aktCnt)
{
var idx = aktCnt;
var onDirChange = function()
{
changeNasDir(lNasArea.items[lNasArea.curNasDir][idx].path);
};
return onDirChange;
};
function resetNasItems()
{
lNasArea.items[lNasArea.curNasDir] = [];
lNasArea.pics[lNasArea.curNasDir] = [];
lNasArea.audio[lNasArea.curNasDir] = [];
}
function changeNasDir( dir, noHistory )
{
setRefreshLock( 10000 );
if ( true != noHistory )
{
privateHistory.addToHistory( changeNasDir, [lNasArea.curNasDir, true] );
}
lNasArea.children[gAreaContentIdx].innerHTML = "";
responsive.pageContentAreaSizeCorrection( lNasArea );
jxl.addClass( lNasArea.children[gAreaContentIdx], "wait_state" );
if ( gSmallScreen )
{
jxl.addClass( gPageContentDiv, "wait_state" );
}
lNasArea.startPos = 1;
lNasArea.browseMode = "type:directory";
if ( -1 < dir.indexOf("/..") )
{
var strParts = dir.split( "/" );
dir = dir.substring( 0, dir.lastIndexOf( strParts[strParts.length - 2] ) - 1 );
if ( "" == dir )
{
dir = "/";
}
}
lNasArea.curNasDir = dir;
resetNasItems();
getNasData();
}
lib.createFileHandler = function (aktCnt)
{
var idx = aktCnt;
function onFileClick()
{
nasFileDownload(idx);
}
return onFileClick;
};
lib.createAudioHandler = function (aktCnt, audioCnt, action)
{
var aktIdx = aktCnt;
var audioIdx = audioCnt;
if (action == "md")
{
var onAudioMouseDown = function(evt)
{
lNasFirstEvtIdx = aktIdx;
lNasLongPressTimer = setTimeout( "nasJs.onLongPress("+aktIdx+")", 500);
lNasLongPress = false;
return false;
};
return onAudioMouseDown;
}
if (action == "mu")
{
var onAudioMouseUp = function(evt)
{
lNasLongPressTimer = clearTimeout(lNasLongPressTimer);
lNasLongPressTimer = null;
if (lNasFirstEvtIdx == aktIdx && !lNasLongPress)
{
if (audioPlayer == null || gIosHttps || (gApp && "noaudio" == gAppMode))
lib.onLongPress(aktIdx);
else
audioPlayer.open( gSid, lNasArea.audio[lNasArea.curNasDir], audioIdx );
}
};
return onAudioMouseUp;
}
};
lib.createPicHandler = function (aktCnt, picCnt, action)
{
var aktIdx = aktCnt;
var picIdx = picCnt;
if (action == "md")
{
var onPicMouseDown = function(evt)
{
lNasFirstEvtIdx = aktIdx;
lNasLongPressTimer = setTimeout( "nasJs.onLongPress("+aktIdx+")", 500);
lNasLongPress = false;
return false;
};
return onPicMouseDown;
}
if (action == "mu")
{
var onPicMouseUp = function(evt)
{
lNasLongPressTimer = clearTimeout( lNasLongPressTimer );
lNasLongPressTimer = null;
if ( lNasFirstEvtIdx == aktIdx && !lNasLongPress )
{
if ( galery == null )
lib.onLongPress(aktIdx);
else
galery.open( gSid, lNasArea.pics[lNasArea.curNasDir], picIdx );
}
};
return onPicMouseUp;
}
};
lib.onLongPress = function(idx)
{
lNasLongPress = true;
nasFileDownload(idx);
};
window.addEventListener( "scroll", onScrollCancelLongPress );
function onScrollCancelLongPress( evt )
{
if ( !lNasLongPress )
{
lNasLongPressTimer = clearTimeout( lNasLongPressTimer );
lNasLongPressTimer = null;
}
}
function nasFileDownload(idx)
{
var url = encodeURI("/myfritz/cgi-bin/luacgi_notimeout");
url = addUrlParam(url, "sid", gSid);
url = addUrlParam(url, "command", "httpdownload");
url = addUrlParam(url, "cmd_files", lNasArea.items[lNasArea.curNasDir][idx].path);
url = addUrlParam(url, "script", "/http_file_download.lua");
var downLink = document.createElement("a");
downLink.href = url;
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
lib.draw = function( resp )
{
if ( null != lNasArea.waitItem )
{
lNasArea.children[gAreaContentIdx].removeChild( lNasArea.waitItem );
lNasArea.waitItem = null;
}
if ( null != resp.startPos && 0 < parseInt( resp.startPos, 10 ) )
{
lNasArea.startPos = parseInt( resp.startPos, 10 );
lNasArea.browseMode = resp.browse_mode;
responsive.setScrollEventListener( lNasArea );
lNasArea.ajaxDataAvail = true;
}
else
{
lNasArea.startPos = 0;
lNasArea.ajaxDataAvail = false;
responsive.removeScrollEventListener( lNasArea );
}
var template = createItemTemplate( 3 );
template.children[1].setAttribute( 'class', 'nas_type' );
template.children[2].setAttribute( 'class', 'nas_size' );
if ( !lNasArea.items[lNasArea.curNasDir] )
{
lNasArea.items[lNasArea.curNasDir] = [];
}
if ( !lNasArea.pics[lNasArea.curNasDir] )
{
NasArea.pics[lNasArea.curNasDir] = [];
}
if ( !lNasArea.audio[lNasArea.curNasDir] )
{
lNasArea.audio[lNasArea.curNasDir] = [];
}
for (var i = 0; i < resp.elems.length; i++)
{
var aktElem = template.cloneNode( true );
var itemsCnt = lNasArea.items[lNasArea.curNasDir].length || 0;
var picsCnt = lNasArea.pics[lNasArea.curNasDir].length || 0;
var audioCnt = lNasArea.audio[lNasArea.curNasDir].length || 0;
var filename = resp.elems[i].filename;
if ( ".." == filename )
{
filename = "";
}
var typeStr = lNasTypeTab[resp.elems[i].type] || "";
if ( "D" == resp.elems[i].type || "directory" == resp.elems[i].type )
{
if ( ".." == resp.elems[i].filename )
{
typeStr = "";
}
aktElem.addEventListener( "click", lib.createDirHandler( itemsCnt ), false );
}
else if ( "audio" == resp.elems[i].type )
{
aktElem.addEventListener( "mousedown", lib.createAudioHandler( itemsCnt, audioCnt, "md" ), false );
aktElem.addEventListener( "mouseup", lib.createAudioHandler( itemsCnt, audioCnt, "mu" ), false );
lNasArea.audio[lNasArea.curNasDir][audioCnt] = resp.elems[i];
}
else if ( "picture" == resp.elems[i].type )
{
aktElem.addEventListener( "mousedown", lib.createPicHandler( itemsCnt, picsCnt, "md" ), false );
aktElem.addEventListener( "mouseup", lib.createPicHandler( itemsCnt, picsCnt, "mu" ), false );
lNasArea.pics[lNasArea.curNasDir][picsCnt] = resp.elems[i];
}
else if ( "video" == resp.elems[i].type )
{
aktElem.addEventListener( "mousedown", lib.createPicHandler( itemsCnt, picsCnt, "md" ), false );
aktElem.addEventListener( "mouseup", lib.createPicHandler( itemsCnt, picsCnt, "mu" ), false );
lNasArea.pics[lNasArea.curNasDir][picsCnt] = resp.elems[i];
}
else
{
aktElem.addEventListener( "click", lib.createFileHandler( itemsCnt ), false );
}
aktElem.id = itemsCnt + "nas";
aktElem.children[0].innerHTML = getNasIcon( resp.elems[i], resp.root )
var tmpElem = document.createElement("p");
jxl.setText( tmpElem, filename );
aktElem.children[0].appendChild( tmpElem );
tmpElem = document.createElement("p");
jxl.setText( tmpElem, typeStr );
aktElem.children[1].appendChild( tmpElem );
tmpElem = document.createElement("p");
jxl.setText( tmpElem, getHumanReadableSize( resp.elems[i].size, resp.elems[i].type ) );
aktElem.children[2].appendChild( tmpElem );
lNasArea.children[gAreaContentIdx].appendChild( aktElem );
lNasArea.items[lNasArea.curNasDir][itemsCnt] = resp.elems[i];
}
if ( !lNasArea.items[lNasArea.curNasDir].length || 1 > lNasArea.items[lNasArea.curNasDir].length )
{
getEmtyItem( lNasArea.children[gAreaContentIdx], "<p>{?471:951?}</p>" );
}
responsive.pageContentAreaSizeCorrection( lNasArea );
lib.autoDataRefresh = autoDataRefreshTimer;
};
lib.getData = function()
{
resetNasItems();
setTimeout(getNasData, 50);
};
function getNasData(aktNasAreaObj, cbFunction)
{
if (!aktNasAreaObj || !cbFunction)
{
aktNasAreaObj = lNasArea;
cbFunction = cb_Data;
}
var ajaxId = getAjaxId();
gAjaxId[lNasId] = ajaxId;
var url = encodeURI(aktNasAreaObj.luaUrl);
url = addUrlParam(url, "sid", gSid);
url = addUrlParam(url, "startpos", aktNasAreaObj.startPos.toString());
url = addUrlParam(url, "browse_mode", aktNasAreaObj.browseMode);
url = addUrlParam(url, "dir", aktNasAreaObj.curNasDir);
url = addUrlParam(url, "ajax_id", ajaxId);
ajaxGet(url, cbFunction);
}
function showWaitState()
{
lNasArea.waitItem = getEmtyItem(lNasArea.children[gAreaContentIdx], "<p></p>");
jxl.addClass(lNasArea.waitItem, "wait_state");
lNasArea.children[gAreaContentIdx].appendChild(lNasArea.waitItem);
responsive.pageContentAreaSizeCorrection(lNasArea);
}
function onNasScroll()
{
var oldWidth = gScreenWidth;
setScreenSize();
if (oldWidth != gScreenWidth) return;
var obj = responsive.getAktScrollPosElem(lNasIdx);
if (obj.elem.scrollHeight > obj.offset && obj.elem.scrollTop > 0 && (obj.elem.scrollHeight - obj.offset - obj.elem.scrollTop) < gScrollLoadDelta && lNasArea.startPos > 0 && gAjaxId[lNasId] == null)
{
setRefreshLock(10000);
getNasData();
showWaitState();
}
lNasArea.lastScrollPos = obj.elem.scrollTop;
}
return lib;
})();
