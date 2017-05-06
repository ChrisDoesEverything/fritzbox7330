<?lua
if not gl or not gl.logged_in then
box.end_page()
end
box.out([[<!-- begin files -->]])
box.out([[<div id="sm_address_line"><div class="fixed_inner">]])
box.out([[<div id="sm_address_line_desc">]]..box.tohtml(TXT([[{?1401:395?}]]))..[[:</div>]])
box.out([[<div id="sm_address_line_size_info"></div>]])
box.out([[
<div id="sm_address_line_path_box">
<span id="sm_address_line_path_content"></span>
</div>
</div></div>
]])
box.out([[<div id="head_detail"><div class="fixed_inner">]])
box.out([[<span id="checkbox_detail_head">]])
box.out([[<input type="checkbox" id="file_list_select_all" onClick="selectAllFilesAndDirs()" value="">]])
box.out([[</span>]])
box.out([[<span id="symbol_detail_head">]])
box.out([[</span>]])
box.out([[<span id="filename_detail_head">]])
box.out([[<a href="" onclick="changeSortOrder( this ); return false;" class="marked" id="fu" >]] .. box.tohtml(TXT([[{?1401:567?}]])) .. [[<img alt="" src="/nas/css/]] .. box.tohtml(gl.var.style) .. [[/images/arrow_up.png"></a>]])
box.out([[</span>]])
box.out([[<span id="type_detail_head">]])
box.out([[<a href="" onclick="changeSortOrder( this ); return false;" id="tu" >]] .. box.tohtml(TXT([[{?1401:359?}]])) .. [[<img alt="" src="/nas/css/]] .. box.tohtml(gl.var.style) .. [[/images/arrow_up.png"></a>]])
box.out([[</span>]])
box.out([[<span id="size_detail_head">]])
box.out([[<a href="" onclick="changeSortOrder( this ); return false;" id="su" >]] .. box.tohtml(TXT([[{?1401:457?}]])) .. [[<img alt="" src="/nas/css/]] .. box.tohtml(gl.var.style) .. [[/images/arrow_up.png"></a>]])
box.out([[</span>]])
box.out([[<span id="time_detail_head">]])
box.out([[<a href="" onclick="changeSortOrder( this ); return false;" id="du" >]] .. box.tohtml(TXT([[{?1401:34?}]])) .. [[<img alt="" src="/nas/css/]] .. box.tohtml(gl.var.style) .. [[/images/arrow_up.png"></a>]])
box.out([[</span>]])
box.out([[</div></div>]])
?>
<div id="content_show_files">
</div>
<div class="page_middle_foot"><div></div></div>
<!-- **************** Nötige Javascript Funktionen *************************************************************************** -->
<script type="text/javascript" src="/nas/js/get_checked_files_and_dirs.js"></script>
<script type="text/javascript" src="/nas/js/galery.js"></script>
<script type="text/javascript" src="/nas/js/audio.js"></script>
<script type="text/javascript" src="/nas/js/touch.js"></script>
<script type="text/javascript">
var gUnits = ["Byte", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
var gNasTypeTab = { D: "{?1401:676?}",
directory: "{?1401:140?}",
F: "{?1401:636?}",
document: "{?1401:340?}",
audio: "{?1401:916?}",
video: "{?1401:703?}",
picture: "{?1401:490?}",
playlist: "{?1401:55?}",
other: "{?1401:516?}"
};
var gContentDiv = jxl.get("content_show_files");
var gWaitItem = null;
var gDataView = "list";
var gDataRetryCnt = 0;
var gGetPreviewsTimer = null;
var gDataRetryTimer = null;
var gGetPreviewsAbort = false;
var gXhr = null;
var gIsRoot = false;
var gSearch = "";
var gSearchItems = null;
var gSearchSartEntry = 1;
var gSearchBrowseMode = "type:directory";
var gVisibleItemsCnt = 0;
var gCurNasDir = "/";
var gStartEntry = {};
gStartEntry[gCurNasDir] = 1
var gBrowseMode = {};
gBrowseMode[gCurNasDir] = "type:directory";
var gSizeInfoBox = null;
var gSize = {};
gSize[gCurNasDir] = { "free":-1, "total":0 };
var gCurItems = {};
var gTmpCurItems = null;
var gCgiTimeout = null;
var gNasLongPressTimer = null;
var gNasLongPress = true;
var gNasFirstEvtIdx = null;
var gDelim = "<?lua box.js(gl.delim) ?>";
var gIosDevices = { 'iPad':true, 'iPhone':true, 'iPod':true };
var gIosHttps = ( ("https:" == window.location.protocol || "https:" == document.location.protocol) && gIosDevices[navigator.platform] );
var gDummyItems = [];
var gSort = "fu";
var gSortOrder = { fu:{ "switch":"fd","pic":"up","attr":"filename" },
fd:{ "switch":"fu","pic":"down","attr":"filename" },
tu:{ "switch":"td","pic":"up","attr":"type" },
td:{ "switch":"tu","pic":"down","attr":"type" },
su:{ "switch":"sd","pic":"up","attr":"size" },
sd:{ "switch":"su","pic":"down","attr":"size" },
du:{ "switch":"dd","pic":"up","attr":"mtime" },
dd:{ "switch":"du","pic":"down","attr":"mtime" }};
function getNasIcon( file )
{
if ( "D" == file.type || "directory" == file.type )
{
if ( ".." == file.filename)
{
return "dirup";
}
else if ( "usb" == file.storagetype && ("/" + file.filename) == file.path && gIsRoot )
{
return "dirusb";
}
else if ( "webdav" == file.storagetype && ('/' + file.filename) == file.path && gIsRoot )
{
return "dirwebdav";
}
else if ( "ram" == file.storagetype )
{
return "dirvolatile";
}
else
{
return "dirstd";
}
}
else
{
if ( "ram" == file.storagetype )
{
return "filevolatile";
}
else if ( "video" == file.type )
{
return "filemov";
}
else if ( "audio" == file.type || "playlist" == file.type )
{
return "filemusic";
}
else if ( "document" == file.type )
{
return "filedoc";
}
else if ( "picture" == file.type )
{
return "fileimg";
}
else
{
return "fileother";
}
}
return "";
}
function getNewUnitString(oldUnit, unitDelta)
{
var newIdx = -1;
for (var i=0; i < gUnits.length; i++)
{
if ( gUnits[i].toLowerCase() == oldUnit.toLowerCase() && gUnits[i + unitDelta] != null)
{
newIdx = i + unitDelta;
break;
}
}
if(newIdx > -1) return gUnits[newIdx];
return "";
}
function humanReadable( fileSize, unitOfFileSize, precision, binaer, withUnitString )
{
var divisor = 1000;
if ( binaer )
{
divisor = 1024;
}
var unitDelta = 0;
if ( !unitOfFileSize )
{
unitOfFileSize = "byte";
}
var newUnitStr = unitOfFileSize;
var newFileSize = 0;
if ( fileSize && "string" == typeof fileSize )
{
fileSize = Number( fileSize );
}
if ( !fileSize || 0 > fileSize )
{
fileSize = 0;
}
if ( precision && "string" == typeof precision )
{
precision = Number( precision );
}
if ( !precision || 0 > precision )
{
precision = 0;
}
var tmp = fileSize;
while ( tmp >= divisor && unitDelta < gUnits.length )
{
unitDelta = unitDelta + 1;
tmp = tmp / divisor;
}
if ( binaer && 999 < tmp )
{
unitDelta = unitDelta + 1;
tmp = tmp / divisor;
}
newUnitStr = getNewUnitString(unitOfFileSize, unitDelta);
if ( "byte" == newUnitStr.toLowerCase() )
{
precision = 0;
}
newFileSize = tmp.toFixed( precision ).toString().replace( ".", "," );
if ( withUnitString )
{
return newFileSize + ' ' + newUnitStr;
}
else
{
return newFileSize;
}
}
function getHumanReadableSize(size, type)
{
if (type == "D" || type == "directory") return "";
return humanReadable( size, "byte", 2, true, true );
}
function createDirHandler( pFile )
{
var file = pFile;
var onDirChange = function()
{
changeNasDir( file.path, file );
};
return onDirChange;
}
function refreshPathDisplay( curNasDir )
{
var tmp = jxl.get("sm_address_line_path_content");
var newPath = "";
if ( tmp )
{
tmp.innerHTML = "<a href='' onclick='changeNasDir( \"/\" ); return false;'> / fritz.nas </a>";
var pathElems = curNasDir.split("/");
for ( var idx = 1; idx < pathElems.length; idx++ )
{
if ( 0 < pathElems[idx].length )
{
newPath += "/" + pathElems[idx];
tmp.innerHTML += "<a href='' onclick='changeNasDir( \"" + newPath + "\" ); return false;'> / " + pathElems[idx] + " </a>";
}
}
}
}
function changeNasDir( curNasDir, file, noHistory )
{
if ( file && file.locked ) return;
if ( gXhr ) gXhr.abort();
if ( gSearch && 0 < gSearch.length )
{
del_search_word();
}
if ( 0 < jxl.getValue( "mm_search_word" ).length )
{
jxl.setValue( "mm_search_word", "" );
checkSearchwordSet();
}
gTmpCurItems = null;
if ( gDataRetryTimer )
{
clearTimeout( gDataRetryTimer );
gDataRetryTimer = null;
}
if ( 0 == gDataRetryCnt )
{
gContentDiv.innerHTML = "";
gWaitItem = null;
deleteDummyItems();
}
if ( curNasDir.indexOf( "/.." ) > - 1 )
{
var strParts = curNasDir.split( "/" );
curNasDir = curNasDir.substring( 0, curNasDir.lastIndexOf( strParts[strParts.length - 2] ) - 1 );
if ( curNasDir == "" ) curNasDir = "/";
}
if ( true != noHistory )
{
privateHistory.addToHistory( changeNasDir, [gCurNasDir, null, true] );
}
gCurNasDir = curNasDir;
refreshPathDisplay( curNasDir );
if ( !gSize[curNasDir] )
{
gSize[curNasDir] = { "free":-1, "total":0 };
}
setSizeInfo( gSize[curNasDir].free, gSize[curNasDir].total );
if ( !gStartEntry[curNasDir] || 1 > gStartEntry[curNasDir] )
{
gStartEntry[curNasDir] = 1;
gBrowseMode[curNasDir] = "type:directory";
}
if ( gCurItems[curNasDir] && 0 < gCurItems[curNasDir].length )
{
drawNasDataFromCache( curNasDir );
}
getNasData( curNasDir );
}
function createFileHandler( aktCnt, pCurNasDir, pFile )
{
var idx = aktCnt;
var curNasDir = pCurNasDir;
var file = pFile;
function onFileClick()
{
if ( file && file.locked ) return;
nasFileDownload( file.path );
}
return onFileClick;
}
function checkUncheckSelection( evt, checkBox, curNasDir )
{
if ( evt.stopPropagation )
{
evt.stopPropagation();
}
if ( evt.target.id == checkBox.id || evt.target.id == "img_" + checkBox.id ) return;
checkBox.checked = !checkBox.checked;
markItem( checkBox.value, curNasDir, checkBox );
}
function get_icon( file )
{
var tmp = '/nas/css/' + gl["var"].style + '/images/';
if ( file.type=="D" || file.type == "directory" )
{
if ( ".." == file.filename )
{
tmp += "icon_ordner_nach_oben_xl.png";
}
else if ( "usb" == file.storagetype && '/' + file.filename == file.path && "/" == gl.nas_user_dir )
{
tmp += "ordner_usb_speicher_xl.png";
}
else if ( "webdav" == file.storagetype && '/' + file.filename == file.path && "/" == gl.nas_user_dir )
{
tmp += "ordner_online_speicher_xl.png";
}
else if ( "ram" == file.storagetype )
{
tmp += "icon_ordner_fluechtig.png";
}
else
{
tmp += "ordner_xl.png";
}
}
else
{
if ( "ram" == file.storagetype )
{
tmp += "icon_datei_fluechtig.png";
}
else if ( "video" == file.type )
{
tmp += "icon_film_xl.png";
}
else if ( "audio" == file.type || "playlist" == file.type )
{
tmp += "icon_musik_xl.png";
}
else if ( "picture" == file.type )
{
file.picPreviewUrl = encodeURI( '/nas/pic_download.lua' ) + '?' + encodeURIComponent( "sid" ) + '=' + encodeURIComponent( gl.sid ) + '&' + encodeURIComponent( "picture" ) + '=' + encodeURIComponent( file.path ) + '&' + encodeURIComponent( 'pic_width' ) + '=' + encodeURIComponent( 160 ) + '&' + encodeURIComponent( 'pic_height' ) + '=' + encodeURIComponent( 160 );
return;
}
else if ( "document" == file.type )
{
tmp += "icon_dokument_xl.png";
}
else
{
tmp += "icon_andere_datei_xl.png";
}
}
return encodeURI( tmp );
}
function markItem( itemIdx, curNasDir, checkBox )
{
if ( gSearch && 0 < gSearch.length )
{
gSearchItems[itemIdx].marked = checkBox.checked;
}
else
{
gCurItems[curNasDir][itemIdx].marked = checkBox.checked;
}
checkEnableBtn();
}
function myAppendChild( father, file, itemsCnt, curNasDir )
{
if ( 0 >= file["domItem" + gDataView].children.length )
{
file["domItem" + gDataView] = createItem( file, itemsCnt, curNasDir )
}
father.appendChild( file["domItem" + gDataView] );
}
function createListItem( file, itemsCnt, curNasDir )
{
var filename = file.filename;
var typeStr = gNasTypeTab[file.type] || "";
file.showType = typeStr;
var mtime = file.mtime;
var title = "";
if ( ".." == filename )
{
filename = "";
typeStr = "";
mtime = "";
}
if ( gSearch && 0 < gSearch.length )
{
title = gl.root_dir + file.path;
}
var item = document.createElement("div");
item.id = itemsCnt + "_item";
item.setAttribute( 'class', 'data_row' );
var checked = ( file.marked ) ? "checked" : "";
item.checkBoxBox = document.createElement("span");
item.checkBoxBox.setAttribute( 'class', 'checkbox_detail' );
if ( ".." != file.filename )
{
item.checkBox = document.createElement("input");
item.checkBox.id = "check_box_" + itemsCnt;
item.checkBox.value = itemsCnt;
item.checkBox.setAttribute( 'type', 'checkbox' );
item.checkBox.setAttribute( 'onClick', 'markItem( this.value, "' + curNasDir + '", this )' );
item.checkBox.setAttribute( 'name', 'file_list' );
item.checkBox.checked = file.marked || false;
item.sizeBox = document.createElement("span");
item.sizeBox.setAttribute( 'class', 'size_detail link_content' );
}
item.linkBox = document.createElement("a");
item.linkBox.title = title;
if ( "D" == file.type || "directory" == file.type )
{
item.linkBox.addEventListener( "click", createDirHandler( file ), false );
}
else if ( "audio" == file.type )
{
item.linkBox.addEventListener( "mousedown", createAudioHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createAudioHandler( file, "mu" ), false );
}
else if ( "picture" == file.type )
{
item.linkBox.addEventListener( "mousedown", createPicHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createPicHandler( file, "mu" ), false );
}
else if ( "video" == file.type )
{
item.linkBox.addEventListener( "mousedown", createPicHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createPicHandler( file, "mu" ), false );
}
else
{
item.linkBox.addEventListener( "click", createFileHandler( itemsCnt, curNasDir, file ), false );
}
item.symbolBox = document.createElement("span");
var shared = ( file.shared ) ? " shared" : "";
item.symbolBox.setAttribute( 'class', 'symbol_detail link_content' + shared );
title = typeStr;
if ( "ram" == file.storagetype )
{
title = "{?1401:800?}";
}
item.symbolBox.title = title;
jxl.addClass( item.symbolBox, getNasIcon( file ) );
item.nameBox = document.createElement("span");
item.nameBox.setAttribute( 'class', 'filename_detail_box link_content' );
item.filenameBox = document.createElement("span");
item.filenameBox.setAttribute( 'class', 'filename_detail' );
jxl.setText( item.filenameBox, filename );
item.typeBox = document.createElement("span");
item.typeBox.setAttribute( 'class', 'type_detail link_content' );
item.typeInner = document.createElement("span");
jxl.setText( item.typeInner, typeStr);
item.sizeBox = document.createElement("span");
item.sizeBox.setAttribute( 'class', 'size_detail link_content' );
item.sizeInner = document.createElement("span");
file.showSize = getHumanReadableSize( file.size, file.type );
jxl.setText( item.sizeInner, file.showSize );
item.timeBox = document.createElement("span");
item.timeBox.setAttribute( 'class', 'time_detail link_content' );
item.timeInner = document.createElement("span");
jxl.setText( item.timeInner, mtime );
item.scrollBox = document.createElement("div");
item.scrollBox.setAttribute( 'class', 'scroll_space' );
item.appendChild( item.checkBoxBox );
if ( item.checkBox )
{
item.checkBoxBox.appendChild( item.checkBox );
}
item.appendChild( item.linkBox );
item.linkBox.appendChild( item.symbolBox );
item.linkBox.appendChild( item.nameBox );
item.nameBox.appendChild( item.filenameBox );
item.linkBox.appendChild( item.typeBox );
item.typeBox.appendChild( item.typeInner );
item.linkBox.appendChild( item.sizeBox );
item.sizeBox.appendChild( item.sizeInner );
item.linkBox.appendChild( item.timeBox );
item.timeBox.appendChild( item.timeInner );
item.linkBox.appendChild( item.scrollBox );
return item;
}
function createTileItem( file, itemsCnt, curNasDir )
{
file.showType = gNasTypeTab[file.type] || "";
var item = document.createElement("div");
item.id = "til_box_" + itemsCnt;
item.setAttribute( 'class', 'til_box' );
item.innerDiv = document.createElement( "div" );
item.innerDiv.id = "til_inner_box_" + itemsCnt;
item.innerDiv.setAttribute( 'class', 'til_inner_box' );
item.linkBox = document.createElement( "a" );
var imgClass = "til_icon";
if ( "picture" == file.type || "audio" == file.type )
{
item.linkBox.setAttribute( 'onclick', 'return false;' );
if ( file.type == "picture" ) imgClass = "til_img";
}
if ( gSearch && 0 < gSearch.length )
{
item.linkBox.title = gl.root_dir + file.path;
}
item.linkBox.setAttribute( 'class', imgClass );
item.nasLinkImg = document.createElement( "img" );
item.nasLinkImg.id = "img_" + itemsCnt;
item.nasLinkImg.setAttribute( 'alt', '' );
var src = get_icon( file );
if ( src )
{
item.nasLinkImg.src = src;
}
item.details = document.createElement( "div" );
item.details.id = "til_info_box_" + itemsCnt;
item.details.setAttribute( 'class', 'til_info_box ' + imgClass );
var l_name = file.filename;
var l_size = getHumanReadableSize( file.size, file.type );
file.showSize = l_size;
if ( ".." == file.filename )
{
l_name = "";
l_size = "";
}
if ( "picture" == file.type )
{
item.filenameBox = document.createElement( "p" );
item.filenameBox.title = l_name;
jxl.setText( item.filenameBox, l_name );
item.dimension = document.createElement( "p" );
jxl.setText( item.dimension, file.width + " x " + file.height );
item.size = document.createElement( "p" );
jxl.setText( item.size, l_size );
item.linkBox.addEventListener( "mousedown", createPicHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createPicHandler( file, "mu" ), false );
}
else if ( "audio" == file.type )
{
item.filenameBox = document.createElement( "p" );
item.filenameBox.title = l_name;
jxl.setText( item.filenameBox, l_name );
item.size = document.createElement( "p" );
jxl.setText( item.size, l_size );
item.linkBox.addEventListener( "mousedown", createAudioHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createAudioHandler( file, "mu" ), false );
}
else if ( "directory" == file.type || "D" == file.type )
{
item.filenameBox = document.createElement( "p" );
item.filenameBox.title = l_name;
jxl.setText( item.filenameBox, l_name );
item.linkBox.addEventListener( "click", createDirHandler( file ), false );
}
else if ( "video" == file.type )
{
item.filenameBox = document.createElement( "p" );
item.filenameBox.title = l_name;
jxl.setText( item.filenameBox, l_name );
item.size = document.createElement( "p" );
jxl.setText( item.size, l_size );
item.linkBox.addEventListener( "mousedown", createPicHandler( file, "md" ), false );
item.linkBox.addEventListener( "mouseup", createPicHandler( file, "mu" ), false );
}
else
{
item.filenameBox = document.createElement( "p" );
item.filenameBox.title = l_name;
jxl.setText( item.filenameBox, l_name );
item.size = document.createElement( "p" );
jxl.setText( item.size, l_size );
item.linkBox.addEventListener( "click", createFileHandler( itemsCnt, curNasDir, file ), false );
}
if ( ".." != file.filename )
{
item.checkBoxBox = document.createElement( "div" );
item.checkBoxBox.setAttribute( 'class', 'tile_select_box' );
item.checkBox = document.createElement( "input" );
item.checkBox.id = "check_box_" + itemsCnt;
item.checkBox.value = itemsCnt;
item.checkBox.setAttribute( 'type', 'checkbox' );
item.checkBox.setAttribute( 'onClick', 'markItem( this.value, "' + curNasDir + '", this )' );
item.checkBox.setAttribute( 'name', 'file_list' );
item.checkBox.checked = file.marked || false;
item.checkBoxBox.addEventListener( "click", function( evt ) { checkUncheckSelection( evt, item.checkBox, curNasDir ); }, false );
item.innerDiv.addEventListener( "click", function( evt ) { checkUncheckSelection( evt, item.checkBox, curNasDir ); }, false );
item.sharedBox = document.createElement( "div" );
var shared = ( file.shared ) ? " shared" : "";
item.sharedBox.setAttribute( 'class', 'sharedBox' + shared );
}
item.appendChild( item.innerDiv );
item.innerDiv.appendChild( item.linkBox );
item.linkBox.appendChild( item.nasLinkImg );
if ( item.filenameBox )
{
item.details.appendChild( item.filenameBox );
}
if ( item.dimension )
{
item.details.appendChild( item.dimension );
}
if ( item.size )
{
item.details.appendChild( item.size );
}
item.innerDiv.appendChild( item.details );
if ( item.checkBoxBox )
{
item.innerDiv.appendChild( item.checkBoxBox );
item.checkBoxBox.appendChild( item.checkBox );
}
if ( item.checkBoxBox )
{
item.innerDiv.appendChild( item.sharedBox );
}
return item;
}
function createItem( file, itemsCnt, curNasDir )
{
file.showItem = true;
var item = null;
if ( "list" == gDataView )
{
item = createListItem( file, itemsCnt, curNasDir );
}
else if ( "tile" == gDataView )
{
item = createTileItem( file, itemsCnt, curNasDir );
}
if ( !( gSearch && 0 < gSearch.length ) )
{
file.showItem = localSearch( file );
}
return item;
}
if (<?lua box.js(tostring(gl.var.sort_order == "down" and gl.var.sort_by == "type")) ?>) gBrowseMode = "type:file";
function local_init()
{
resizePage();
}
function resizePage()
{
if ( "tile" == gDataView )
{
var itemsPerRow = Math.floor( ( gContentDiv.clientWidth ) / 124 );
var curItemsCnt = gVisibleItemsCnt;
if ( gSearch && 0 < gSearch.length )
{
curItemsCnt = gSearchItems.length;
}
var dummyItemsCnt = itemsPerRow - ( curItemsCnt % itemsPerRow );
dummyItemsCnt = ( dummyItemsCnt == itemsPerRow ) ? 0 : dummyItemsCnt ;
if ( dummyItemsCnt != gDummyItems.length )
{
deleteDummyItems();
for ( var cnt = 0; cnt < dummyItemsCnt; cnt++)
{
gDummyItems[cnt] = document.createElement( "div" );
gDummyItems[cnt].setAttribute( 'class', 'til_box dummy_item' );
gContentDiv.appendChild( gDummyItems[cnt] );
}
}
}
}
function deleteDummyItems()
{
for ( var cnt = 0; cnt < gDummyItems.length; cnt++)
{
try
{
gContentDiv.removeChild( gDummyItems[cnt] );
}
catch ( evt )
{
break;
}
}
gDummyItems = [];
}
window.onresize = resizePage;
var json_browse = makeJSONParser();
function createAudioHandler( pFile, action )
{
var file = pFile;
if ( "md" == action )
{
var onAudioMouseDown = function( evt )
{
if ( file && file.locked ) return;
gNasFirstEvtIdx = file.path;
gNasLongPressTimer = setTimeout( "onLongPress( '" + file.path + "' )", 500 );
gNasLongPress = false;
return false;
};
return onAudioMouseDown;
}
if ( "mu" == action )
{
var onAudioMouseUp = function( evt )
{
if ( file && file.locked ) return;
gNasLongPressTimer = clearTimeout( gNasLongPressTimer );
gNasLongPressTimer = null;
if ( gNasFirstEvtIdx == file.path && !gNasLongPress )
{
if ( audioPlayer == null || gIosHttps )
onLongPress( file.path );
else
var curAudio = [];
var audioIdx = 0;
var curItems = gCurItems[gCurNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
}
for ( var idx in curItems )
{
if ( "audio" == curItems[idx]["type"] )
{
if ( curItems[idx].path == file.path ) audioIdx = curAudio.length;
curAudio[curAudio.length] = curItems[idx];
}
}
audioPlayer.open( gl.sid, curAudio, audioIdx, gl.delim );
}
};
return onAudioMouseUp;
}
}
function createPicHandler( pFile, action )
{
var file = pFile;
if ( "md" == action )
{
function onPicMouseDown( evt )
{
if ( file && file.locked ) return;
gNasFirstEvtIdx = file.path;
gNasLongPressTimer = setTimeout( "onLongPress( '" + file.path + "' )", 500 );
gNasLongPress = false;
}
return onPicMouseDown;
}
if ( "mu" == action )
{
function onPicMouseUp( evt )
{
if ( file && file.locked )
{
return;
}
gNasLongPressTimer = clearTimeout( gNasLongPressTimer );
gNasLongPressTimer = null;
if ( gNasFirstEvtIdx == file.path && !gNasLongPress )
{
if ( !galery )
{
onLongPress( file.path );
}
else
{
var curPics = [];
var picIdx = 0;
var curItems = gCurItems[gCurNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
}
for ( var idx in curItems )
{
if ( "picture" == curItems[idx]["type"] || "video" == curItems[idx]["type"] )
{
if ( curItems[idx].path == file.path )
{
picIdx = curPics.length;
}
curPics[curPics.length] = curItems[idx];
}
}
galery.open( gl.sid, curPics, picIdx, gl.delim );
}
}
}
return onPicMouseUp;
}
}
function onLongPress( path )
{
gNasLongPress = true;
nasFileDownload( path );
}
window.addEventListener( "scroll", onScroll );
function onScroll( evt )
{
if ( !gNasLongPress )
{
gNasLongPressTimer = clearTimeout( gNasLongPressTimer );
gNasLongPressTimer = null;
}
}
function nasFileDownload( path )
{
var url = encodeURI("/nas/cgi-bin/luacgi_notimeout");
url = addUrlParam(url, "sid", "<?lua box.js(box.glob.sid) ?>");
url = addUrlParam(url, "cmd", "httpdownload");
url = addUrlParam(url, "cmd_files", path + gDelim);
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
function drawNasDataNew( items, curNasDir )
{
var cachedItems = gCurItems[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
cachedItems = gSearchItems;
}
deleteDummyItems();
for (var i = 0; i < items.length; i++)
{
var itemsCnt = cachedItems.length || 0;
var item = createItem( items[i], itemsCnt, curNasDir );
cachedItems[itemsCnt] = items[i];
cachedItems[itemsCnt]["domItem" + gDataView] = item;
}
cachedItems = sortItems( cachedItems, gSort );
gVisibleItemsCnt = 0;
for ( var idx in cachedItems )
{
if ( cachedItems[idx].showItem )
{
myAppendChild( gContentDiv, cachedItems[idx], idx, curNasDir );
gVisibleItemsCnt++;
}
}
if ( gSearch && 0 < gSearch.length )
{
gSearchItems = cachedItems;
}
else
{
gCurItems[curNasDir] = cachedItems;
}
resizePage();
}
function nasDirUpToDate( dir )
{
if ( dir && 0 < dir.length )
{
if ( dir === gCurNasDir ) return dir;
var tmpDir = dir.substring( 0, dir.length - 1 );
if ( tmpDir && tmpDir === gCurNasDir ) return tmpDir;
}
return null;
}
function drawNasData( resp )
{
var curNasDir = nasDirUpToDate( resp.dir );
if ( !curNasDir )
{
return;
}
if ( null != gWaitItem )
{
gContentDiv.removeChild( gWaitItem );
gWaitItem = null;
}
var oldStartEntry = gStartEntry[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
oldStartEntry = gSearchSartEntry;
}
if ( null != resp.start_entry && 0 < parseInt( resp.start_entry, 10 ) )
{
if ( gSearch && 0 < gSearch.length )
{
gSearchSartEntry = parseInt( resp.start_entry, 10 );
gSearchBrowseMode = resp.browse_mode;
}
else
{
gStartEntry[curNasDir] = parseInt( resp.start_entry, 10 );
gBrowseMode[curNasDir] = resp.browse_mode;
}
}
else
{
if ( gSearch && 0 < gSearch.length )
{
gSearchSartEntry = 0;
}
else
{
gStartEntry[curNasDir] = 0;
}
}
gIsRoot = resp.root;
var startEntry = gStartEntry[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
startEntry = gSearchSartEntry;
}
if ( gSearch && 0 < gSearch.length && !gSearchItems )
{
gSearchItems = [];
}
else if ( !gCurItems[curNasDir] )
{
gCurItems[curNasDir] = [];
}
else if ( !gTmpCurItems && 1 == oldStartEntry )
{
gTmpCurItems = [];
}
if ( gTmpCurItems )
{
for ( var i = 0; i < resp.elems.length; i++ )
{
var itemsCnt = gTmpCurItems.length;
gTmpCurItems[itemsCnt] = resp.elems[i];
if ( ( gCurItems[curNasDir] && !gCurItems[curNasDir][itemsCnt] && gTmpCurItems[0] ) ||
resp.elems[i].path != gCurItems[curNasDir][itemsCnt].path ||
resp.elems[i].size != gCurItems[curNasDir][itemsCnt].size )
{
gTmpCurItems[0].redraw = true;
}
}
if ( gTmpCurItems[0] && 0 >= startEntry && gCurItems[curNasDir].length > gTmpCurItems.length )
{
gTmpCurItems[0].redraw = true;
}
}
else
{
drawNasDataNew( resp.elems, curNasDir );
}
resumeGetData( startEntry, curNasDir );
if ( 0 >= startEntry )
{
if ( gTmpCurItems && gTmpCurItems[0] && gTmpCurItems[0].redraw )
{
gContentDiv.innerHTML = "";
gDummyItems = [];
gCurItems[curNasDir] = [];
drawNasDataNew( gTmpCurItems, curNasDir );
}
gTmpCurItems = null;
}
checkEnableBtn();
checkAndDrawNoData( 0 == gVisibleItemsCnt);
}
function getPreviews( pCurNasDir, pIdx, pCurPics )
{
if ( gGetPreviewsAbort )
{
gGetPreviewsAbort = false;
return;
}
var curNasDir = nasDirUpToDate( pCurNasDir );
var curPics = pCurPics || [];
if ( !curNasDir ) return;
var idx = pIdx;
if ( 0 >= curPics.length )
{
var curItems = gCurItems[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
}
for ( var itemCnt in curItems )
{
if ( "picture" == curItems[itemCnt]["type"] )
{
curPics[curPics.length] = curItems[itemCnt];
}
}
}
if ( !idx && curPics && 0 < curPics.length )
{
idx = 0;
}
if ( "number" == typeof( idx ) && curPics && curPics[idx] && "" == curPics[idx]["domItemtile"].nasLinkImg.src )
{
curPics[idx]["domItemtile"].nasLinkImg.src = curPics[idx].picPreviewUrl;
curPics[idx]["domItemtile"].nasLinkImg.addEventListener( "load", function() {
getPreviews( curNasDir, idx + 1, curPics );
}, false );
}
else if ( curPics && idx < curPics.length )
{
getPreviews( curNasDir, idx + 1, curPics );
}
}
function cbGetNasData( response )
{
if ( gCgiTimeout )
{
gCgiTimeout = window.clearTimeout( gCgiTimeout );
gCgiTimeout = null;
}
if ( response && 200 == response.status )
{
try
{
var resp = json_browse( response.responseText );
}
catch( evt )
{
var resp = null;
}
if ( resp )
{
var curNasDir = nasDirUpToDate( resp.dir );
if ( !curNasDir )
{
return;
}
if ( resp.login && "failed" == resp.login )
{
var reloadPageForm = jxl.get( "reloadPage" );
if( reloadPageForm )
{
reloadPageForm.submit();
}
return;
}
if ( "browse_no_data" == resp.err_code && ( !resp.elems.length || 0 <= resp.elems.length ) )
{
gDataRetryCnt++;
if ( 5 < gDataRetryCnt )
{
gDataRetryCnt = 0;
}
else if ( 4 == gDataRetryCnt )
{
privateHistory.removeAllOfType( changeNasDir );
gDataRetryTimer = setTimeout( 'changeNasDir( "/", null, true )', 5000 );
}
else
{
gDataRetryTimer = setTimeout( 'getNasData( "' + curNasDir + '" )', 5000 );
}
showDataError();
return;
}
gDataRetryCnt = 0;
gSize[curNasDir].free = resp.free_space;
gSize[curNasDir].total = resp.total_space;
setSizeInfo( resp.free_space, resp.total_space );
gl.write_rights = resp.writable;
drawNasData( resp );
}
}
}
function showDataError( errCode )
{
if ( null == gWaitItem )
{
gWaitItem = document.createElement( "div" );
gWaitItem.setAttribute( 'class', 'wait_item' );
gContentDiv.appendChild( gWaitItem );
}
gWaitItem.innerHTML = gl.no_data_txt;
if ( "cgi" == errCode )
{
if ( !jxl.hasClass( gWaitItem, "error" ) )
{
jxl.addClass( gWaitItem, "error" );
}
gWaitItem.innerHTML += gl.cgi_error_txt;
}
else if ( 1 <= gDataRetryCnt )
{
gWaitItem.innerHTML += "<p>{?1401:378?}</p>";
}
else if ( 0 == gDataRetryCnt && !jxl.hasClass( gWaitItem, "error" ) )
{
jxl.addClass( gWaitItem, "error" );
}
}
function drawNasDataFromCache( curNasDir )
{
gGetPreviewsAbort = ( "tile" == gDataView );
if ( gXhr ) gXhr.abort();
gWaitItem = null;
var item = null;
gContentDiv.innerHTML = "";
gDummyItems = [];
var curItems = gCurItems[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
}
if ( curItems && 0 < curItems.length && curItems[0].sortOrder != gSort )
{
curItems = sortItems( curItems, gSort );
}
gVisibleItemsCnt = 0;
for ( var i in curItems )
{
if ( curItems[i]["domItem" + gDataView] )
{
item = curItems[i]["domItem" + gDataView];
if ( curItems[i].domItemlist && curItems[i].domItemlist.checkBox )
{
curItems[i].domItemlist.checkBox.checked = curItems[i].marked || false;
if ( curItems[i].locked )
{
jxl.disableNode( curItems[i].domItemlist, true, false);
}
}
if ( curItems[i].domItemtile && curItems[i].domItemtile.checkBox )
{
curItems[i].domItemtile.checkBox.checked = curItems[i].marked || false;
if ( curItems[i].locked ) jxl.disableNode( curItems[i].domItemtile, true, false);
}
if ( curItems[i].shared )
{
if ( curItems[i].domItemlist && curItems[i].domItemlist.symbolBox )
{
jxl.addClass( curItems[i].domItemlist.symbolBox, "shared" );
}
if ( curItems[i].domItemtile && curItems[i].domItemtile.sharedBox )
{
jxl.addClass( curItems[i].domItemtile.sharedBox, "shared" );
}
}
else if ( curItems[i].domItemlist && curItems[i].domItemlist.symbolBox && jxl.hasClass( curItems[i].domItemlist.symbolBox, "shared" ) )
{
jxl.removeClass( curItems[i].domItemlist.symbolBox, "shared");
}
else if ( curItems[i].domItemtile && curItems[i].domItemtile.sharedBox && jxl.hasClass( curItems[i].domItemtile.sharedBox, "shared" ) )
{
jxl.removeClass( curItems[i].domItemtile.sharedBox, "shared");
}
if ( !( gSearch && 0 < gSearch.length ) )
{
curItems[i].showItem = localSearch( curItems[i] );
}
}
else
{
item = createItem( curItems[i], i, curNasDir );
curItems[i]["domItem" + gDataView] = item;
}
if ( curItems[i].showItem )
{
myAppendChild( gContentDiv, curItems[i], i, curNasDir );
gVisibleItemsCnt++;
}
}
if ( gSearch && 0 < gSearch.length )
{
gSearchItems = curItems;
}
else
{
gCurItems[curNasDir] = curItems;
}
checkAndDrawNoData( 0 == gVisibleItemsCnt );
checkEnableBtn();
resizePage();
}
function checkAndDrawNoData( noData )
{
if ( ( gSearch && 0 < gSearch.length && 0 != gSearchSartEntry ) ||
( ( !gSearch || 0 >= gSearch.length ) && 0 != gStartEntry[gCurNasDir] ) )
{
return;
}
if ( ( gSearch && 0 < gSearch.length ) || ( gIndexSearch && 0 < gIndexSearch.length ) )
{
if ( gSearch && 0 < gSearch.length )
{
if ( !gSearchItems || ( gSearchItems && 0 >= gSearchItems.length ) || noData )
{
gContentDiv.innerHTML = "<div class='errMsg'><p class='noData'>" + jxl.sprintf( "{?1401:184?}", gSearch ) + "<br><br>{?1401:642?}</p></div>";
gDummyItems = [];
}
}
else if ( noData )
{
gContentDiv.innerHTML = "<div class='errMsg'><p class='noData'>" + jxl.sprintf( "{?1401:595?}", gIndexSearch ) + jxl.sprintf( "<br>{?1401:11?}", "/fritz.nas" + ( ( "/" == gCurNasDir ) ? "" : gCurNasDir ) ) + "<br><br>{?1401:390?}</p><p>{?1401:889?}</p></div>";
gDummyItems = [];
}
}
else
{
if ( !gCurItems || !gCurItems[gCurNasDir] || ( gCurItems[gCurNasDir] && 0 >= gCurItems[gCurNasDir].length ) || noData )
{
gContentDiv.innerHTML = "<div class='errMsg'><p class='noData'>{?1401:572?}</p></div>";
gDummyItems = [];
}
}
}
function setSizeInfo( free, total )
{
gl.ds_free = free;
gl.ds_total = total;
if ( !gSizeInfoBox )
{
gSizeInfoBox = jxl.get( "sm_address_line_size_info" );
}
if ( gSizeInfoBox )
{
if ( gSearch && 0 < gSearch.length )
{
gSizeInfoBox.innerHTML = "<a onclick='del_search_word(); return false;'>{?1401:459?}</a>";
}
else
{
gSizeInfoBox.innerHTML = "";
if ( "number" == typeof( free ) && "number" == typeof( total ) && -1 < free && 0 < total && free <= total )
{
gSizeInfoBox.innerHTML = jxl.sprintf( "{?1401:5?}", humanReadable( free, "byte", 2, true, true ), humanReadable( total, "byte", 2, true, true ) );
}
}
}
}
function setView( btn, noHistory )
{
if ( btn && btn.value )
{
var tileBtn = jxl.get( "sm_btn_viewTile" );
var listBtn = jxl.get( "sm_btn_viewList" );
tileBtn.disabled = ( "tile" != btn.value ) ? "" : "disabled";
listBtn.disabled = ( "list" != btn.value ) ? "" : "disabled";
if ( gDataView != btn.value && ( "tile" == btn.value || "list" == btn.value ) )
{
gDataView = btn.value;
gContentDiv.setAttribute( "class", gDataView );
deleteDummyItems();
if ( true != noHistory )
{
var historyBtn = ( "list" == btn.value ) ? tileBtn : listBtn;
privateHistory.addToHistory( setView, [historyBtn, true] );
}
var curItems = gCurItems[gCurNasDir];
var startEntry = gStartEntry[gCurNasDir];
if ( gSearch && 0 < gSearch.length )
{
curItems = gSearchItems;
startEntry = gSearchSartEntry;
}
if ( curItems && 0 < curItems.length )
{
drawNasDataFromCache( gCurNasDir );
resumeGetData( startEntry, gCurNasDir );
}
}
}
}
function resumeGetData( startEntry, curNasDir )
{
if ( "tile" == gDataView )
{
gGetPreviewsTimer = setTimeout( function()
{
gGetPreviewsAbort = false;
getPreviews( curNasDir );
}, 500 );
}
if ( 0 < startEntry )
{
getNasData( curNasDir );
}
}
function getNasData( curNasDir )
{
if ( gXhr ) gXhr.abort();
gGetPreviewsAbort = ( "tile" == gDataView );
if ( gGetPreviewsTimer )
{
clearTimeout( gGetPreviewsTimer );
gGetPreviewsTimer = null;
}
if ( gDataRetryTimer )
{
clearTimeout( gDataRetryTimer );
gDataRetryTimer = null;
}
curNasDir = nasDirUpToDate( curNasDir );
if ( !curNasDir ) return;
var startEntry = gStartEntry[curNasDir];
var browseMode = gBrowseMode[curNasDir];
if ( gSearch && 0 < gSearch.length )
{
startEntry = gSearchSartEntry;
browseMode = gSearchBrowseMode;
}
if ( curNasDir && startEntry && browseMode )
{
if ( null == gWaitItem )
{
gWaitItem = document.createElement( "div" );
if ( "tile" == gDataView && gCurItems[curNasDir] && 0 < gCurItems[curNasDir].length )
{
gWaitItem.id = "til_box_wait";
gWaitItem.setAttribute( 'class', 'til_box wait_item' );
}
else
{
gWaitItem.setAttribute( 'class', 'wait_item' );
}
gContentDiv.appendChild( gWaitItem );
}
gCgiTimeout = window.setTimeout( "showDataError('cgi')", 80000 );
var parameter = [];
parameter.push( encodeURIComponent( "sid" ) + "=" + encodeURIComponent( gl.sid ) );
parameter.push( encodeURIComponent( "start_entry" ) + "=" + encodeURIComponent( startEntry ) );
parameter.push( encodeURIComponent( "browse_mode" ) + "=" + encodeURIComponent( browseMode ) );
parameter.push( encodeURIComponent( "dir" ) + "=" + encodeURIComponent( curNasDir ) );
if ( gSearch && 0 < gSearch.length )
{
parameter.push( encodeURIComponent( "search" ) + "=" + encodeURIComponent( gSearch ) );
}
gXhr = ajaxPost( encodeURI( gl.ajax_url ), parameter.join( "&" ), cbGetNasData );
}
}
refreshPathDisplay( gCurNasDir );
getNasData( gCurNasDir );
function sortItems( itemsToSort, sortOrder )
{
if ( itemsToSort && 0 < itemsToSort.length && gSortOrder[sortOrder] )
{
var tmpDirItems = [];
var tmpFileItems = [];
var tmpDirUp = [];
for ( var idxL1 in itemsToSort )
{
if ( ".." == itemsToSort[idxL1].filename )
{
tmpDirUp[0] = itemsToSort[idxL1];
}
else
{
var tmpItems = null;
if ( "D" == itemsToSort[idxL1]["type"] || "directory" == itemsToSort[idxL1]["type"] )
{
tmpItems = tmpDirItems;
}
else
{
tmpItems = tmpFileItems;
}
for ( var idxL2 in tmpItems )
{
var compareValueOfItemsToSort = "";
var compareValueOfNewItems = "";
if ( "filename" == gSortOrder[sortOrder].attr )
{
compareValueOfItemsToSort = itemsToSort[idxL1]["filename"].toLowerCase();
compareValueOfNewItems = tmpItems[idxL2]["filename"].toLowerCase();
}
if ( "type" == gSortOrder[sortOrder].attr )
{
compareValueOfItemsToSort = gNasTypeTab[itemsToSort[idxL1]["type"]];
compareValueOfNewItems = gNasTypeTab[tmpItems[idxL2]["type"]];
}
else if ( "size" == gSortOrder[sortOrder].attr )
{
compareValueOfItemsToSort = parseInt( itemsToSort[idxL1]["size"], 10 );
compareValueOfNewItems = parseInt( tmpItems[idxL2]["size"], 10 );
}
else if ( "mtime" == gSortOrder[sortOrder].attr )
{
var tmpstr = itemsToSort[idxL1]["mtime"].replace( /[\:\ ]/g, "." );
var timeParts = tmpstr.split( "." );
compareValueOfItemsToSort = new Date( timeParts[2], timeParts[1], timeParts[0], timeParts[3], timeParts[4] );
tmpstr = tmpItems[idxL2]["mtime"].replace( /[\:\ ]/g, "." );
timeParts = tmpstr.split( "." );
compareValueOfNewItems = new Date( timeParts[2], timeParts[1], timeParts[0], timeParts[3], timeParts[4] );
}
if ( ( "up" == gSortOrder[sortOrder]["pic"] && compareValueOfItemsToSort < compareValueOfNewItems ) ||
( "down" == gSortOrder[sortOrder]["pic"] && compareValueOfItemsToSort > compareValueOfNewItems ) )
{
tmpItems.splice( idxL2 , 0, itemsToSort[idxL1] );
break;
}
else if ( tmpItems.length - 1 == idxL2 )
{
tmpItems.push( itemsToSort[idxL1] );
}
}
if ( 0 == tmpItems.length ) tmpItems[0] = itemsToSort[idxL1];
if ( "D" == itemsToSort[idxL1]["type"] || "directory" == itemsToSort[idxL1]["type"] )
{
tmpDirItems = tmpItems;
}
else
{
tmpFileItems = tmpItems;
}
}
}
var sortedItems = tmpDirUp.concat( tmpDirItems.concat( tmpFileItems ) );
if ( sortedItems && sortedItems[0] ) sortedItems[0].sortOrder = sortOrder;
for ( var idx in sortedItems )
{
if ( sortedItems[idx].domItemlist && sortedItems[idx].domItemlist.children[0] && sortedItems[idx].domItemlist.children[0].children[0] )
{
sortedItems[idx].domItemlist.children[0].children[0].value = idx;
}
if ( sortedItems[idx].domItemtile && sortedItems[idx].domItemtile.children[0] && sortedItems[idx].domItemtile.children[0].children[2] && sortedItems[idx].domItemtile.children[0].children[2].children[0] )
{
sortedItems[idx].domItemtile.children[0].children[2].children[0].value = idx;
}
}
return sortedItems;
}
}
function changeSortOrder( sortObj )
{
if ( jxl.hasClass( sortObj, "marked" ) )
{
sortObj.id = gSortOrder[sortObj.id]["switch"];
sortObj.children[0].src = '/nas/css/' + gl["var"].style + '/images/arrow_' + gSortOrder[sortObj.id]["pic"] + '.png';
}
else
{
var oldSortObj = jxl.getByClass( "marked", "head_detail", "a" )[0];
jxl.clearClass( oldSortObj );
jxl.addClass( sortObj, "marked" );
}
gSort = sortObj.id;
drawNasDataFromCache( gCurNasDir );
resumeGetData( gStartEntry[gCurNasDir], gCurNasDir );
}
</script>
<!-- end file -->
