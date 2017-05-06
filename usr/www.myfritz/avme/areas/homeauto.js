var homeautoJs = homeautoJs || (function() {
"use strict";
var lib = {};
lib.autoDataRefresh = null;
jxl.createStyleTag(' \
/****************** Seiten Inhalt ******************/ \
/* Mobile */ \
@media (max-width: 759px) { \
.homeauto .area_overview { \
background-color: #44e3b1; \
background-size: 72em 4.5em; \
background-image: radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #44e3b1 93%, #44e3b1 100%), \
linear-gradient(42deg, rgba(33, 109, 85, 0.5), rgba(46, 153, 119, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 14.0%, rgba(157, 255, 224, 0.5) 24%); \
background-image: -webkit-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #44e3b1 93%, #44e3b1 100%), \
-webkit-linear-gradient(42deg, rgba(33, 109, 85, 0.5), rgba(46, 153, 119, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 14.0%, rgba(157, 255, 224, 0.5) 24%); \
background-image: -moz-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #44e3b1 93%, #44e3b1 100%), \
-moz-linear-gradient(42deg, rgba(33, 109, 85, 0.5), rgba(46, 153, 119, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 14.0%, rgba(157, 255, 224, 0.5) 24%); \
background-image: -o-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #44e3b1 93%, #44e3b1 100%), \
-o-linear-gradient(42deg, rgba(33, 109, 85, 0.5), rgba(46, 153, 119, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 14.0%, rgba(157, 255, 224, 0.5) 24%); \
background-image: -ms-radial-gradient(-10.15% -1524%, circle farthest-side, transparent 93%, #44e3b1 93%, #44e3b1 100%), \
-ms-linear-gradient(42deg, rgba(33, 109, 85, 0.5), rgba(46, 153, 119, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 12.5%, rgba(103, 206, 173, 0.5) 14.0%, rgba(157, 255, 224, 0.5) 24%); \
} \
.homeauto .area_ov_icon { \
background-image: url("/myfritz/css/default/images/icon_homeauto.png"); \
} \
} \
\
/****************** ENDE Seiten Inhalt ******************/ \
\
/****************** OVERVIEW ******************/ \
.homeauto .area_overview td:nth-child(2) { \
width: 3em; \
} \
\
.area_overview td.switch { \
color: #5b5b5b; \
} \
/****************** ENDE OVERVIEW ******************/ \
\
/****************** Items ******************/ \
#homeautoContent .item div { \
width: 65%; \
} \
\
#homeautoContent .item.ha_device div.head { \
display: table; \
width: 100%; \
} \
\
#homeautoContent .item.ha_device div.head p, \
#homeautoContent .item.ha_device div.head div { \
display: table-cell; \
max-width: 1cm; \
} \
\
#homeautoContent .item.ha_device div.head div.switch { \
background-image: url("/myfritz/css/default/images/switch_off.png"); \
background-position: center; \
background-repeat: no-repeat; \
background-size: 21mm; \
height: 10mm; \
padding: 0; \
min-width: 22mm; \
max-width: none; \
} \
\
#homeautoContent .item.ha_device div.head div.switch_on { \
background-image: url("/myfritz/css/default/images/switch_on.png"); \
} \
\
#homeautoContent .item.ha_device div.head div.switch.disabled { \
background-image: url("/myfritz/css/default/images/switch_disabled.png"); \
} \
\
#homeautoContent .item.mf_share { \
display: table; \
padding: 0.8em 0.4em; \
} \
\
#homeautoContent a.item.mf_share { \
text-decoration: none; \
color: #3F464C; \
} \
\
#homeautoContent .item.emtyItem div { \
width: 100%; \
} \
\
#homeautoContent .item.mf_share p { \
display: table-cell; \
max-width: 1mm; \
} \
\
#homeautoContent .item.mf_share p:nth-child(2) { \
text-align: right; \
padding: 0 0 0 2mm; \
min-width: 1mm; \
max-width: none; \
} \
\
#homeautoContent .item div.details { \
display: none; \
padding: 0.1em 0 0 1em; \
width: auto; \
} \
\
#homeautoContent .item div.details div { \
width: 100%; \
} \
\
#homeautoContent .item div.details.show { \
display: block; \
} \
\
#homeautoContent .item div.details p { \
display: table-cell; \
text-align: right; \
color: #666666; \
padding: 0 0 0 0.5em; \
} \
\
#homeautoContent .item div.details p.tamDetailDesc { \
text-align: left; \
} \
\
#homeautoContent .item div.details p { \
width: 100%; \
font-size: 85%; \
} \
/****************** ENDE Items ******************/');
var lHomeautoId = "homeautoArea";
var lHomeautoArea = null;
var lHomeautoIdx = -1;
var lDataRefreshTimer = null;
var lRetryCnt = 0;
var lSendSwitchCommandTimeout = {};
var lSwitchLock = {};
var lRefreshLock = null;
var lJson = makeJSONParser();
function onHomeautoScroll()
{
var oldWidth = gScreenWidth;
setScreenSize();
if ( oldWidth != gScreenWidth )
{
return;
}
lHomeautoArea.lastScrollPos = responsive.getAktScrollPosElem( lHomeautoIdx ).elem.scrollTop;
}
function autoDataRefreshTimer()
{
if ( lRefreshLock )
{
lib.cancelDataRefresh();
return;
}
var time = 10000;
if ( ( gMediumScreen && gOpenAreaIdx == lHomeautoIdx ) || gBigScreen )
{
time = 5000;
}
if ( null == lDataRefreshTimer )
{
lDataRefreshTimer = setTimeout( lib.refreshData, time );
}
}
lib.setSwitchState = function ( switchStateOn, deviceId )
{
var ovSwitch = jxl.get( "switchState" + deviceId );
if ( switchStateOn )
{
jxl.addClass( deviceId + "_has", "switch_on" );
if ( ovSwitch )
{
ovSwitch.innerHTML = "{?971:925?}";
}
}
else
{
jxl.removeClass( deviceId + "_has", "switch_on" );
if ( ovSwitch )
{
ovSwitch.innerHTML = "{?971:157?}";
}
}
lSwitchLock[deviceId] = false;
lRefreshLock = null;
};
function cbSwitchChanging( response )
{
if ( response && 200 == response.status )
{
var resp = lJson( response.responseText );
if ( resp && resp.ajax_id && resp.deviceId && gAjaxId[resp.deviceId] == resp.ajax_id )
{
gAjaxId[resp.deviceId] = null;
if ( lSendSwitchCommandTimeout )
{
clearTimeout( lSendSwitchCommandTimeout[resp.deviceId] );
}
if ( resp.AuthorizationRequired || resp.error || 10 < lRetryCnt )
{
lRetryCnt = 0;
lib.setSwitchState( !jxl.hasClass( resp.deviceId + "_has", "switch_on" ), resp.deviceId );
}
else if ( "switchStateChangedSend" == resp.status || "switchStateNotChanged" == resp.status )
{
lRetryCnt += 1;
var newSwitchValue = ( jxl.hasClass( resp.deviceId + "_has", "switch_on" ) ) ? "1" : "0";
setTimeout( function() {
lib.sendSwitchCommand( resp.deviceId, 'switchChangeCheck', newSwitchValue )
}, 500 );
}
else if ( "switchStateChanged" == resp.status )
{
lRetryCnt = 0;
lSwitchLock[resp.deviceId] = false;
lRefreshLock = null;
}
}
}
}
lib.sendSwitchCommand = function ( deviceId, command, cmdValue )
{
var url = encodeURI("/myfritz/areas/homeauto.lua");
url = addUrlParam( url, "sid", gSid );
url = addUrlParam( url, "deviceId", deviceId );
url = addUrlParam( url, "cmd", command );
url = addUrlParam( url, "cmdValue", cmdValue );
var ajaxId = getAjaxId();
gAjaxId[deviceId] = ajaxId;
url = addUrlParam( url, "ajax_id", ajaxId );
ajaxGet( url, cbSwitchChanging );
};
lib.onSwitchChange = function( evt, id, touchObj )
{
if ( evt.stopPropagation )
{
evt.stopPropagation();
}
else if ( null != evt.cancelBubble )
{
evt.cancelBubble = true;
}
var button = evt.target;
var deviceId = parseInt( button.id, 10 );
if ( isNaN( deviceId ) || lSwitchLock[deviceId] )
{
return;
}
var newSwitchValue = 0;
var switchStateOn = jxl.hasClass( button, "switch_on" );
if ( null != touchObj && !( ( touchObj.direction=="left" && switchStateOn ) || ( touchObj.direction=="right" && !switchStateOn ) ) )
{
return;
}
if ( !switchStateOn )
{
newSwitchValue = 1;
}
lib.setSwitchState( !switchStateOn, deviceId );
lib.sendSwitchCommand( deviceId, 'switchChange', newSwitchValue );
lSendSwitchCommandTimeout[deviceId] = setTimeout( function() {
lib.setSwitchState( switchStateOn, deviceId )
}, 10000 );
lSwitchLock[deviceId] = true;
lRefreshLock = "switchLock";
};
lib.createHomeautoClick = function( i, elem )
{
var idx = i;
var div = elem;
function onHomeautoClick()
{
if ( jxl.hasClass( div, "show" ) )
{
jxl.removeClass( div, "show" );
}
else
{
jxl.addClass( div, "show" );
}
}
return onHomeautoClick;
};
function createHomeAutoDeviceElem( device, idx, template )
{
var aktElem = template.cloneNode( true );
aktElem.id = device.ID + "_ha_id";
var tmp = document.createElement( "p" );
jxl.setText( tmp, device.Name );
tmp.addEventListener( "click", lib.createHomeautoClick( idx, aktElem.children[1] ), false );
aktElem.children[0].appendChild( tmp );
if ( device["switch"] )
{
var haBtn = document.createElement( "div" );
haBtn.id = device.ID + "_has";
haBtn.setAttribute( 'class', 'switch' );
aktElem.children[0].appendChild( haBtn );
if ( 1 < device.Valid )
{
if ( device["switch"].SwitchOn )
{
haBtn.setAttribute('class', 'switch switch_on');
}
haBtn.addEventListener( "click", lib.onSwitchChange, false );
touch.registerElemForTouch( haBtn.id, "side", lib.onSwitchChange );
lSwitchLock[device.ID] = false;
}
else
{
haBtn.setAttribute('class', 'switch disabled');
lSwitchLock[device.ID] = true;
}
}
if ( device.open )
{
jxl.addClass( aktElem.children[1], "show" );
}
aktElem.children[1].innerHTML = "";
if ( "" != device.ProductName )
{
aktElem.children[1].innerHTML += "<div><p class='tamDetailDesc'>{?971:763?}: </p><p>" + device.ProductName + "</p></div>";
}
aktElem.children[1].innerHTML +="<div><p class='tamDetailDesc'>{?971:861?}: </p><p>" + device.Identifyer + "</p></div>";
if ( "number" == typeof device.temperature && -9999 != device.temperature )
{
var temp = ( ( device.temperature / 10 ) + " &deg;C" ).replace( ".", "," );
aktElem.children[1].innerHTML += "<div><p class='tamDetailDesc'>{?971:394?}: </p><p>" + temp + "</p></div>";
}
if ( 0 <= device.pv_now )
{
aktElem.children[1].innerHTML += "<div><p class='tamDetailDesc'>{?971:662?}: </p><p>" + device.pv_now + " {?971:780?}</p></div>";
}
return aktElem;
}
function createMyfritzShareElem( share )
{
var aktElem = null;
aktElem = document.createElement( "a" );
aktElem.href = share.url;
aktElem.setAttribute( "target", "_blank" );
aktElem.setAttribute( 'class', 'item mf_share' );
aktElem.id = share.uid + "_mfsi";
aktElem.innerHTML = "<p>" + share.name + "</p><p>" + share.service + "</p>";
return aktElem;
}
function drawHomeauto( resp )
{
lHomeautoArea.children[gAreaContentIdx].innerHTML = "";
lHomeautoArea.items = [];
var aktElem = null;
var itemIdx = 0;
var template = createItemTemplate( 2 );
template.setAttribute( 'class', 'item ha_device' );
template.children[0].setAttribute( 'class', 'head' );
template.children[1].setAttribute( 'class', 'details' );
for ( var i = 0; i < resp.devices.length; i++ )
{
aktElem = createHomeAutoDeviceElem( resp.devices[i], i, template );
resp.devices[i].open = null;
lHomeautoArea.children[gAreaContentIdx].appendChild( aktElem );
itemIdx = lHomeautoArea.items.length || 0;
lHomeautoArea.items[itemIdx] = resp.devices[i];
lHomeautoArea.items[itemIdx].itemType = "ha_device";
lHomeautoArea.items[itemIdx].itemGuiId = aktElem.id;
}
aktElem = null;
for ( var i = 0; i < resp.shares.length; i++ )
{
aktElem = createMyfritzShareElem( resp.shares[i] );
lHomeautoArea.children[gAreaContentIdx].appendChild( aktElem );
itemIdx = lHomeautoArea.items.length || 0;
lHomeautoArea.items[itemIdx] = resp.shares[i];
lHomeautoArea.items[itemIdx].itemType = "mf_share";
lHomeautoArea.items[itemIdx].itemGuiId = aktElem.id;
}
if ( !lHomeautoArea.items.length || lHomeautoArea.items.length < 1 )
{
getEmtyItem( lHomeautoArea.children[gAreaContentIdx], "<p>{?971:64?}</p>" );
}
responsive.pageContentAreaSizeCorrection( lHomeautoArea );
}
lib.cbRefreshData = function( response )
{
if ( ( !lRefreshLock || ( lRefreshLock && "switchLock" != lRefreshLock ) ) && response && response.status == 200 )
{
var resp = lJson( response.responseText );
if ( resp && resp.ajax_id && gAjaxId[lHomeautoArea.id] == resp.ajax_id )
{
gAjaxId[lHomeautoArea.id] = null;
var lastScrollPos = responsive.getAktScrollPosElem( lHomeautoIdx ).elem.scrollTop;
for ( var j = 0; j < lHomeautoArea.items.length; j++ )
{
var oldElem = jxl.get( lHomeautoArea.items[j].itemGuiId ) || null;
if ( oldElem && "ha_device" == lHomeautoArea.items[j].itemType && jxl.hasClass( oldElem.children[1], "show" ) )
{
for ( var i = 0; i < resp.devices.length; i++ )
{
if ( lHomeautoArea.items[j].ID == resp.devices[i].ID )
{
resp.devices[i].open = true;
}
}
}
if ( oldElem )
{
lHomeautoArea.children[gAreaContentIdx].removeChild( oldElem );
}
}
drawHomeauto( resp )
if ( ( gSmallScreen || gMediumScreen ) && null != gOpenAreaIdx )
{
scroll( 0, lastScrollPos );
}
else
{
lHomeautoArea.children[gAreaContentIdx].scrollTop = lastScrollPos;
}
}
}
lDataRefreshTimer = null;
};
lib.refreshData = function()
{
if ( lRefreshLock || ( null != gOpenAreaIdx && gOpenAreaIdx != lHomeautoIdx ) )
{
lib.cancelDataRefresh();
return;
}
lib.cancelDataRefresh( true );
lRefreshLock = setTimeout( function() {
if ( lRefreshLock && "switchLock" != lRefreshLock.toString() )
{
lRefreshLock = null;
}
}, 4000 );
getData( lHomeautoArea, lib.cbRefreshData );
};
lib.cancelDataRefresh = function( timerOnly )
{
if ( null != lDataRefreshTimer )
{
clearTimeout( lDataRefreshTimer );
if ( !timerOnly )
{
lDataRefreshTimer = null;
}
}
}
lib.draw = function( resp )
{
drawHomeauto( resp );
responsive.setScrollEventListener( lHomeautoArea );
lib.autoDataRefresh = autoDataRefreshTimer;
};
lib.init = function()
{
lHomeautoIdx = gAreasIdx[lHomeautoId];
lHomeautoArea = gAreas[lHomeautoIdx];
lHomeautoArea.items = [];
lHomeautoArea.onScrollFunc = onHomeautoScroll;
lHomeautoArea.available = true;
lHomeautoArea.luaUrl = "/myfritz/areas/homeauto.lua";
lHomeautoArea.startPos = 0;
lHomeautoArea.lib = lib;
};
return lib;
})();
