var gDataNeeded = true;
var gGetDataTimeout = {};
var gAjaxId = {};
function checkAreaDataRefresh()
{
if ( !gAreas )
{
return;
}
for ( var i = 0; i < gAreas.length; i++ )
{
if ( gAreas[i].lib.autoDataRefresh && ( ( null != gOpenAreaIdx && gOpenAreaIdx == i ) || ( null == gOpenAreaIdx && gMediumScreen ) || gBigScreen ) )
{
gAreas[i].lib.autoDataRefresh();
}
else if ( gAreas[i].lib.cancelDataRefresh )
{
gAreas[i].lib.cancelDataRefresh();
}
}
}
function setDataNeeded()
{
gDataNeeded = false;
for ( var i = 0; i < gAreas.length; i++ )
{
if ( jxl.hasClass( gAreas[i].children[gAreaContentIdx], "wait_state" ) )
{
gDataNeeded = true;
return;
}
}
}
function getEmtyItem( areaContent, txt )
{
var emtyItem = createItemTemplate( 1 );
emtyItem.setAttribute( 'class', 'item emtyItem' );
emtyItem.children[0].innerHTML = txt;
areaContent.appendChild( emtyItem );
return emtyItem;
}
function createItemTemplate( innerDivCnt )
{
var item = document.createElement( "div" );
item.setAttribute( 'class', 'item' );
for ( var i = 0; i < innerDivCnt; i++ )
{
var div = document.createElement( "div" );
item.appendChild( div );
}
return item;
}
function getDateStr( date, shortVers )
{
var today = new Date();
var monthObj = { "01":"{?8367:256?}", "02":"{?8367:453?}", "03":"{?8367:19?}", "04":"{?8367:845?}", "05":"{?8367:306?}", "06":"{?8367:59?}", "07":"{?8367:343?}", "08":"{?8367:975?}", "09":"{?8367:946?}", "10":"{?8367:218?}", "11":"{?8367:985?}", "12":"{?8367:648?}" };
var dateStr = "";
var noTime = date.substring( 0, date.length - 6 );
var justTime = date.substring( date.length - 5, date.length );
var dateComponents = noTime.split( "." );
if ( shortVers && today.getDate() == parseInt( dateComponents[0], 10 ) &&
today.getMonth() == ( parseInt( dateComponents[1], 10 ) - 1 ) &&
today.getFullYear() == ( parseInt( dateComponents[2], 10 ) + 2000 ) )
{
dateStr = jxl.sprintf( "{?8367:765?}", justTime );
}
else
{
if ( shortVers )
{
dateStr = jxl.sprintf( "{?8367:502?}", parseInt( dateComponents[0], 10 ), monthObj[dateComponents[1]] );
}
else
{
dateStr = jxl.sprintf( "{?8367:246?}", parseInt( dateComponents[0], 10 ), monthObj[dateComponents[1]], dateComponents[2], justTime );
}
}
return dateStr;
}
function refreshOverview( resp )
{
if ( resp.homeauto )
{
var ovContent = jxl.get( "homeautoAreaOvContent" );
if ( ovContent )
{
var str = "<table>";
for ( var i in resp.homeauto.devices )
{
var switchState = "";
var switchStateClass = "";
if ( resp.homeauto.devices[i]["switch"] )
{
switchStateClass = "switch";
if ( 1 == resp.homeauto.devices[i]["switch"].SwitchOn )
{
switchState = "{?8367:353?}";
switchStateClass += " on";
}
else if ( 0 == resp.homeauto.devices[i]["switch"].SwitchOn )
{
switchState = "{?8367:292?}";
}
}
str += "<tr><td>" + resp.homeauto.devices[i].Name + "</td><td id='switchState" + resp.homeauto.devices[i].ID + "' class='" + switchStateClass + "'>" + switchState + "</td></tr>";
}
str += "</table>";
ovContent.innerHTML = str;
}
}
if ( resp.answer )
{
var ovContent = jxl.get( "answerAreaOvContent" );
if ( ovContent )
{
var str = "<table>";
for ( var i in resp.answer.tamcalls )
{
str += "<tr><td>" + answerJs.getAnswerDisplayNumber( resp.answer.tamcalls[i] ) + "</td><td>" + getDateStr( resp.answer.tamcalls[i].date, true ) + "</td></tr>";
}
str += "</table>";
ovContent.innerHTML = str;
}
}
if ( resp.calls )
{
var ovContent = jxl.get("callsAreaOvContent");
if ( ovContent )
{
var str = "<table>";
for ( var i in resp.calls.calls )
{
str += "<tr><td>" + callsJs.getCallDisplayNumber( resp.calls.calls[i] ) + "</td><td>" + getDateStr( resp.calls.calls[i].date, true ) + "</td></tr>";
}
str += "</table>";
ovContent.innerHTML = str;
}
}
if ( resp.nas )
{
}
}
var json = makeJSONParser();
function cb_Data( response )
{
gGetDataTimeout[response] = clearTimeout( gGetDataTimeout[response] );
if ( response && response.status && response.status == 200 )
{
var resp = json( response.responseText );
if ( resp && resp.ajax_id && gAjaxId[resp.area] == resp.ajax_id )
{
gAjaxId[resp.area] = null;
if ( "overview" == resp.area )
{
refreshOverview( resp );
gGetDataTimeout[resp.area] = clearTimeout( gGetDataTimeout[resp.area] );
}
else
{
var akt_Area = gAreas[gAreasIdx[resp.area]];
jxl.removeClass( akt_Area.children[gAreaContentIdx], "wait_state" );
jxl.removeClass( gPageContentDiv, "wait_state" );
if ( akt_Area.available )
{
akt_Area.lib.draw( resp );
gGetDataTimeout[resp.area] = clearTimeout( gGetDataTimeout[resp.area] );
}
setDataNeeded();
getMoreDataOfAreaIfNeeded( akt_Area );
}
}
}
}
function getMoreDataOfAreaIfNeeded( area )
{
if ( area.ajaxDataAvail && !gGetDataTimeout[area.id] )
{
var scrollDelta = 100;
var scrollHeight = gPageContentDiv.scrollHeight;
var offsetHeight = gScreenHeight;
if ( gBigScreen || ( gMediumScreen && null == gOpenAreaIdx ) )
{
scrollHeight = area.children[gAreaContentIdx].scrollHeight;
offsetHeight = area.children[gAreaContentIdx].offsetHeight;
}
if ( scrollHeight < ( offsetHeight + scrollDelta ) )
{
getDataOfArea( area );
if ( !area.waitItem )
{
area.waitItem = getEmtyItem( area.children[gAreaContentIdx], "<p></p>" );
jxl.addClass( area.waitItem, "wait_state" );
area.children[gAreaContentIdx].appendChild( area.waitItem );
responsive.pageContentAreaSizeCorrection( area );
}
}
}
}
function getAjaxId()
{
return ( Math.round( Math.random() * 10000 ) ).toString();
}
function getData( area, cbFunc )
{
url = encodeURI( area.luaUrl );
url = addUrlParam( url, "sid", gSid );
url = addUrlParam( url, "startpos", area.startPos );
url = addUrlParam( url, "cmd", "getData" );
var ajaxId = getAjaxId();
gAjaxId[area.id] = ajaxId;
url = addUrlParam( url, "ajax_id", ajaxId );
ajaxGet( url, cbFunc );
}
function getDataOfArea( area )
{
if ( !gGetDataTimeout[area.id] && area.available )
{
if ( area.lib.getData )
{
area.lib.getData();
}
else
{
var url = encodeURI( area.luaUrl );
getData( area, cb_Data );
}
gGetDataTimeout[area.id] = setTimeout( function (){ cb_Data( area.id ); }, 10000 );
}
}
function getDataOfOverview()
{
var id = "overview";
if ( !gGetDataTimeout[id] && gSmallScreen )
{
area = { "id":id, "startPos":0, "luaUrl":"/myfritz/areas/overview.lua" };
getData( area, cb_Data );
gGetDataTimeout[id] = setTimeout( function (){ cb_Data( id ); }, 10000 );
}
}
function getAllAreaData()
{
if ( gDataNeeded )
{
for ( var i = 0; i < gAreas.length; i++ )
{
if ( jxl.hasClass( gAreas[i].children[gAreaContentIdx], "wait_state" ) )
{
getDataOfArea( gAreas[i] );
}
}
}
}
