var galery = galery || ( function() {
"use strict";
var lib = {};
var lPathStart = "/myfritz";
if ( ( "nas" == window.location.pathname.split( "/" )[1]) || ( "fritz.nas" == window.location.hostname ) )
{
lPathStart = "/nas";
}
jxl.loadCss( lPathStart + "/css/default/galery.css" );
var lInitialMenuHideTimer = null;
var lPics = null;
var lAktPicIdx = -1;
var lAutoPlay = false;
var lAutoPlayTimer = null;
var lAutoPlayTime = 5000;
var lAutoPlayTimeCangeTimer = null;
var lSid = null;
var lGaleryBox = null;
var lPicBox = null;
var lPicDetails = null;
var lPicName = null;
var lPicProgress = null;
var lPicMenu = null;
var lMenuBox = null;
var lAutoPlayIcon = null;
var lAutoPlayTimeDisplay = null;
var lAutoPlayTimeMinus = null;
var lAutoPlayTimePlus = null;
var lDownloadPic = null;
var lDelim = "";
var lAutoPlayStartTxt = '{?9138:279?}';
var lAutoPlayStopTxt = '{?9138:105?}';
var lLoadErrorBox = null;
var lScrollPos = { left:0, top:0 };
var lFlipForward = true;
var lCachSize = 5;
var lPlayer = null;
var lVideoObjSupport = false;
var lBasicVideoSupport = false;
var lVideoSupport = false;
var lPausedAudio = false;
var lFocusCatcher = null;
lib.cbTouchChangePic = function( evt, id, touchObj )
{
var threshold = 40;
try
{
if ( gSmallScreen )
{
threshold = ( gScreenWidth < gScreenHeight ) ? gScreenWidth / 6 : gScreenHeight / 6;
}
else
{
threshold = ( gScreenWidth < gScreenHeight ) ? gScreenWidth / 8 : gScreenHeight / 8;
}
}
catch ( evt )
{
}
if ( "right" == touchObj.direction && touchObj.direction == touchObj.startDirection && touchObj.lastX > ( touchObj.startX + threshold ) && touchObj.allowed )
{
touchObj.allowed = false;
lib.changePic( null, "prev" );
}
else if ( "left" == touchObj.direction && touchObj.direction == touchObj.startDirection && touchObj.lastX < ( touchObj.startX - threshold ) && touchObj.allowed )
{
touchObj.allowed = false;
lib.changePic( null, "next" );
}
else if ( touchObj.direction == touchObj.startDirection && touchObj.allowed &&
( ( "up" == touchObj.direction && !jxl.hasClass( lMenuBox, "show" ) && touchObj.lastY < ( touchObj.startY - threshold ) ) ||
( "down" == touchObj.direction && jxl.hasClass( lMenuBox, "show" ) && touchObj.lastY > ( touchObj.startY - threshold ) ) ) )
{
touchObj.allowed = false;
lib.changePic( null, "menu" );
}
};
lib.checkKeyUp = function ( evt )
{
if ( "undefined" == typeof gAktDisableBox || !gAktDisableBox )
{
switch( evt.keyCode )
{
case 38:
case 107:
case 40:
case 109:
lib.cancelAutoPlayTimeTimer();
break;
}
}
}
lib.checkKey = function ( evt )
{
if ( "undefined" == typeof gAktDisableBox || !gAktDisableBox )
{
preventPropagationDefault( evt );
switch( evt.keyCode )
{
case 13:
lib.changePic( null, "menu" );
break;
case 27:
if ( !( document.fullscreenElement || document.webkitFullscreenElement ||
document.mozFullScreenElement || document.msFullscreenElement ) )
{
lib.close();
}
break;
case 32:
if ( lPlayer && lPlayer.play && lPlayer.pause )
{
if ( lPlayer.paused )
{
lPlayer.play();
}
else
{
lPlayer.pause();
}
}
break;
case 37:
lib.changePic( null, "prev" );
break;
case 39:
lib.changePic( null, "next" );
break;
case 46:
if ( lPathStart && "/nas" == lPathStart )
{
lib.deleteAktPic();
}
break;
case 68:
lib.downloadAktPic();
break;
case 80:
lib.setAutoPlay();
break;
case 83:
if ( lPathStart && "/nas" == lPathStart )
{
lib.clearMenuHideTimer;
createFilelink( lPics[lAktPicIdx] );
}
break;
}
}
lib.catchFocus( evt );
};
lib.setAutoPlay = function ()
{
lib.clearMenuHideTimer();
if ( lAutoPlay )
{
lAutoPlay = false;
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = null;
jxl.removeClass( lAutoPlayIcon, "stop" );
jxl.addClass( lAutoPlayIcon, "play" );
lAutoPlayIcon.title = lAutoPlayStartTxt;
}
else
{
lAutoPlay = true;
if ( ( lPics[lAktPicIdx].picElem && lPics[lAktPicIdx].picElem.complete ) || lLoadErrorBox )
{
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = null;
if ( lLoadErrorBox )
{
lAutoPlayTimer = setTimeout( 'galery.changePic( null, "next" )', 1000 );
}
else
{
lAutoPlayTimer = setTimeout( 'galery.changePic( null, "next" )', lAutoPlayTime );
}
}
jxl.removeClass( lAutoPlayIcon, "play" );
jxl.addClass( lAutoPlayIcon, "stop" );
lAutoPlayIcon.title = lAutoPlayStopTxt;
}
};
function resetAutoPlayTimer( pTime )
{
if ( lAutoPlay )
{
if ( pTime )
{
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = setTimeout( 'galery.changePic( null, "next" )', pTime );
}
else
{
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = setTimeout( 'galery.changePic( null, "next" )', lAutoPlayTime );
}
}
}
lib.setPicSize = function ()
{
if ( !lPics || !lPics[lAktPicIdx] || !lPics[lAktPicIdx].picElem )
{
return;
}
var offset = 0;
var width = ( lPics[lAktPicIdx].width && 0 < parseInt( lPics[lAktPicIdx].width, 10 ) ) ? parseInt( lPics[lAktPicIdx].width, 10 ) : 4000;
var height = ( lPics[lAktPicIdx].height && 0 < parseInt( lPics[lAktPicIdx].height, 10 ) ) ? parseInt( lPics[lAktPicIdx].height, 10 ) : 3000;
var ratio = height / width;
if ( width > lGaleryBox.offsetWidth )
{
width = lGaleryBox.offsetWidth;
height = width * ratio;
}
if ( height > lGaleryBox.offsetHeight )
{
height = lGaleryBox.offsetHeight;
width = height / ratio;
}
lPics[lAktPicIdx].picElem.style.margin = "auto";
var headFootMargin = ( lGaleryBox.offsetHeight - height ) * 0.5;
lPics[lAktPicIdx].picElem.style.margin = headFootMargin + "px auto";
lPics[lAktPicIdx].picElem.style.width = width + "px";
lPics[lAktPicIdx].picElem.style.height = height + "px";
return { w:width, h:height };
};
lib.changePic = function( evt, type )
{
var dividend = 0;
var oldPicIdx = lAktPicIdx;
if ( evt != null )
{
dividend = lPicBox.offsetWidth / evt.clientX;
}
else if ( type != null )
{
switch( type )
{
case "next": dividend = 1
break;
case "prev": dividend = 5
break;
case "menu": dividend = 3
lib.clearMenuHideTimer();
break;
}
}
else
{
return;
}
if ( 4 < dividend )
{
if ( 0 >= lAktPicIdx )
{
lAktPicIdx = lPics.length - 1;
}
else
{
lAktPicIdx--;
}
lFlipForward = false;
}
else if ( 1.33 > dividend )
{
if ( lAktPicIdx >= ( lPics.length - 1 ) )
{
lAktPicIdx = 0;
}
else
{
lAktPicIdx++;
}
lFlipForward = true;
}
else
{
if ( jxl.hasClass( lMenuBox, "show" ) )
{
jxl.removeClass( lMenuBox, "show" );
}
else
{
jxl.addClass( lMenuBox, "show" );
}
return;
}
lPicName.innerHTML = lPics[lAktPicIdx].filename;
createPicProgress();
createAktPic( oldPicIdx );
};
lib.picLoadError = function ( evt )
{
if ( lDownloadPic )
{
lDownloadPic.addEventListener( "click", lib.downloadAktPic, false );
}
if ( lPics && lPics[lAktPicIdx] && lPics[lAktPicIdx].picElem && lPics[lAktPicIdx].picElem.src &&
evt.target.src && evt.target.src == lPics[lAktPicIdx].picElem.src )
{
if ( "undefined" == typeof lLoadErrorBox || !lLoadErrorBox )
{
lLoadErrorBox = document.createElement( "div" );
lLoadErrorBox.innerHTML = "{?9138:508?}";
lLoadErrorBox.setAttribute( "class", "load_error" );
lPicBox.appendChild( lLoadErrorBox );
}
resetAutoPlayTimer( 1000 );
}
for ( var idx in lPics )
{
if ( lPics[idx] && lPics[idx].picElem && lPics[idx].picElem.src &&
evt.target.src && evt.target.src == lPics[idx].picElem.src )
{
delCachedPic( idx );
break;
}
}
};
lib.picLoaded = function ( evt )
{
if ( lDownloadPic )
{
lDownloadPic.addEventListener( "click", lib.downloadAktPic, false );
}
if ( lPics && evt.target.src == lPics[lAktPicIdx].picElem.src )
{
resetAutoPlayTimer();
}
};
function playVideo()
{
var urlPrefix = encodeURI( lPathStart + "/cgi-bin/luacgi_notimeout" );
urlPrefix = addUrlParam( urlPrefix, "sid", lSid );
urlPrefix = addUrlParam( urlPrefix, "cmd", "video" );
urlPrefix = addUrlParam( urlPrefix, "cmd_files", lPics[lAktPicIdx].path + lDelim );
urlPrefix = addUrlParam( urlPrefix, "script", "/http_file_download.lua" );
lPlayer.pause();
lPicName.innerHTML = lPics[lAktPicIdx].filename;
lPlayer.src = "";
lPlayer.src = urlPrefix;
if ( audioPlayer && audioPlayer.isOpen() && audioPlayer.isPlaying() )
{
audioPlayer.playPauseAudioPlayback();
lPausedAudio = true;
}
jxl.display( lPlayer, true );
lPlayer.play();
if ( lDownloadPic )
{
lDownloadPic.addEventListener( "click", lib.downloadAktPic, false );
}
}
function delCachedPic( idx )
{
if ( lPics[idx].picElem )
{
lPics[idx].picElem.src = "";
lPicBox.removeChild( lPics[idx].picElem );
delete lPics[idx].picElem;
lPics[idx].picElem = null;
}
}
function delAllCachedPics()
{
for ( var idx in lPics )
{
delCachedPic( idx );
}
}
function checkCachedPics()
{
if ( lPics.length <= lCachSize )
{
return;
}
var delIdx = 0;
if ( lFlipForward )
{
delIdx = lAktPicIdx - lCachSize;
if ( delIdx < 0 )
{
delIdx = lPics.length + delIdx;
}
}
else
{
delIdx = lAktPicIdx + lCachSize;
if ( delIdx > ( lPics.length - 1 ) )
{
delIdx = delIdx - ( lPics.length );
}
}
delCachedPic( delIdx );
}
function createAktPic( oldPicIdx )
{
var srcStr = null;
if ( lLoadErrorBox )
{
lPicBox.removeChild( lLoadErrorBox );
lLoadErrorBox = null;
}
else if ( null != oldPicIdx && null != lPics[oldPicIdx].picElem )
{
jxl.display( lPics[oldPicIdx].picElem, false );
}
lPlayer.pause();
jxl.display( lPlayer, false );
if ( lPausedAudio )
{
lPausedAudio = false;
if ( audioPlayer && audioPlayer.isOpen() && !audioPlayer.isPlaying() )
{
audioPlayer.playPauseAudioPlayback();
}
}
if ( lDownloadPic )
{
lDownloadPic.removeEventListener( "click", lib.downloadAktPic, false );
}
if ( "picture" == lPics[lAktPicIdx].type )
{
if ( !lPics[lAktPicIdx].picElem || ( lPics[lAktPicIdx].picElem && !lPics[lAktPicIdx].picElem.complete ) )
{
lPics[lAktPicIdx].picElem = document.createElement( "img" );
lPics[lAktPicIdx].picElem.alt = "";
lib.setPicSize();
srcStr = encodeURI( lPathStart + "/http_file_download.lua" );
srcStr = addUrlParam( srcStr, "sid", lSid );
srcStr = addUrlParam( srcStr, "cmd", "httpdownload" );
srcStr = addUrlParam( srcStr, "cmd_files", lPics[lAktPicIdx].path + lDelim );
lPics[lAktPicIdx].picElem.src = srcStr;
lPics[lAktPicIdx].picElem.addEventListener( "load", lib.picLoaded, false );
lPics[lAktPicIdx].picElem.addEventListener( "error", lib.picLoadError, false );
lPicBox.appendChild( lPics[lAktPicIdx].picElem );
checkCachedPics();
}
else
{
if ( lDownloadPic )
{
lDownloadPic.addEventListener( "click", lib.downloadAktPic, false );
}
lib.setPicSize();
jxl.display( lPics[lAktPicIdx].picElem, true );
resetAutoPlayTimer();
}
}
else
{
checkCachedPics();
playVideo();
}
}
function createPicProgress()
{
lPicProgress.innerHTML = ( lAktPicIdx + 1 ) + ' von ' + lPics.length;
}
lib.cancelAutoPlayTimeTimer = function()
{
if ( lAutoPlayTimeCangeTimer )
{
clearTimeout( lAutoPlayTimeCangeTimer );
}
lAutoPlayTimeCangeTimer = null;
}
function increaseAutoPlayTime()
{
lib.cancelAutoPlayTimeTimer();
var tmp = lAutoPlayTime + 1000;
if ( 600000 < tmp )
{
tmp = 600000;
jxl.addClass( lPicMenu, "signal" );
setTimeout( function() {
jxl.removeClass( lPicMenu, "signal" );
}, 100 );
}
lAutoPlayTime = tmp;
lAutoPlayTimeDisplay.innerHTML = ( tmp / 1000 ) + " s";
resetAutoPlayTimer();
};
lib.increaseAutoPlayTimeFast = function ( evt )
{
preventPropagationDefault( evt );
lib.clearMenuHideTimer();
var time = ( evt && null == lAutoPlayTimeCangeTimer ) ? 500 : 50;
increaseAutoPlayTime();
lAutoPlayTimeCangeTimer = setTimeout( lib.increaseAutoPlayTimeFast , time );
};
lib.preventScroll = function ( evt )
{
preventPropagationDefault( evt );
document.body.scrollLeft = lScrollPos.left;
document.body.scrollTop = lScrollPos.top;
};
function preventPropagationDefault( evt )
{
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
if ( evt && evt.preventDefault )
{
evt.preventDefault();
}
}
function decreaseAutoPlayTime()
{
lib.cancelAutoPlayTimeTimer();
var tmp = lAutoPlayTime - 1000;
if ( 1000 > tmp )
{
tmp = 1000;
jxl.addClass( lPicMenu, "signal" );
setTimeout( function() {
jxl.removeClass( lPicMenu, "signal" );
}, 100 );
}
lAutoPlayTime = tmp;
lAutoPlayTimeDisplay.innerHTML = ( tmp / 1000 ) + " s";
resetAutoPlayTimer();
};
lib.decreaseAutoPlayTimeFast = function ( evt )
{
preventPropagationDefault( evt );
lib.clearMenuHideTimer();
var time = ( evt && null == lAutoPlayTimeCangeTimer ) ? 500 : 50;
decreaseAutoPlayTime();
lAutoPlayTimeCangeTimer = setTimeout( lib.decreaseAutoPlayTimeFast , time );
};
lib.downloadAktPic = function ( evt )
{
lib.clearMenuHideTimer;
var tmpForm = document.createElement( "form" );
tmpForm.method = "post";
tmpForm.action = lPathStart + "/cgi-bin/luacgi_notimeout";
tmpForm.innerHTML = "<input type='hidden' name='sid' value='" + lSid + "'>";
tmpForm.innerHTML += "<input type='hidden' name='script' value='/http_file_download.lua'>";
tmpForm.innerHTML += "<input type='hidden' name='cmd' value='httpdownload'>";
tmpForm.innerHTML += "<input type='hidden' name='cmd_files' value='" + lPics[lAktPicIdx].path + lDelim + "'>";
lDownloadPic.appendChild( tmpForm );
tmpForm.submit();
setTimeout( function () {
lDownloadPic.removeChild( tmpForm );
}, 1000 );
};
lib.deleteAktPic = function ( evt )
{
lib.clearMenuHideTimer;
if ( "cancel" != getFilesAndDirsToDelete( lPics[lAktPicIdx] ) )
{
if ( 1 >= lPics.length )
{
setTimeout( lib.close, 1000 );
}
else
{
var newPics = [];
if ( lPics[lAktPicIdx].picElem )
{
delCachedPic( lAktPicIdx );
}
for ( var idx in lPics )
{
if ( idx != lAktPicIdx )
{
newPics[newPics.length] = lPics[idx];
}
}
lPics = newPics;
lAktPicIdx--;
if ( 0 > lAktPicIdx )
{
lAktPicIdx = 0;
}
lPicName.innerHTML = lPics[lAktPicIdx].filename;
createPicProgress();
createAktPic();
}
}
};
function createPicMenu()
{
lPicMenu.innerHTML = "";
if ( 1 < lPics.length )
{
lAutoPlayIcon = document.createElement( "div" );
if ( lAutoPlay )
{
lAutoPlayIcon.setAttribute( 'class', 'galeryIcon stop' );
lAutoPlayIcon.title = lAutoPlayStopTxt;
}
else
{
lAutoPlayIcon.setAttribute( 'class', 'galeryIcon play' );
lAutoPlayIcon.title = lAutoPlayStartTxt;
}
lAutoPlayIcon.addEventListener( "click", lib.setAutoPlay, false );
lPicMenu.appendChild( lAutoPlayIcon );
var timerBox = document.createElement( "div" );
timerBox.setAttribute( 'class', 'timer_box' );
lAutoPlayTimeMinus = document.createElement( "div" );
lAutoPlayTimeMinus.setAttribute( 'class', 'galeryIcon minus' );
lAutoPlayTimeMinus.addEventListener( "touchstart", lib.decreaseAutoPlayTimeFast, false );
lAutoPlayTimeMinus.addEventListener( "mousedown", lib.decreaseAutoPlayTimeFast, false );
lAutoPlayTimeMinus.addEventListener( "mouseup", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimeMinus.addEventListener( "mouseout", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimeMinus.addEventListener( "touchend", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimeMinus.addEventListener( "touchcancel", lib.cancelAutoPlayTimeTimer, false );
timerBox.appendChild( lAutoPlayTimeMinus );
lAutoPlayTimeDisplay = document.createElement( "div" );
lAutoPlayTimeDisplay.innerHTML = ( lAutoPlayTime / 1000 ) + " s";
timerBox.appendChild( lAutoPlayTimeDisplay );
lAutoPlayTimePlus = document.createElement( "div" );
lAutoPlayTimePlus.setAttribute( 'class', 'galeryIcon plus' );
lAutoPlayTimePlus.addEventListener( "touchstart", lib.increaseAutoPlayTimeFast, false );
lAutoPlayTimePlus.addEventListener( "mousedown", lib.increaseAutoPlayTimeFast, false );
lAutoPlayTimePlus.addEventListener( "mouseup", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimePlus.addEventListener( "mouseout", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimePlus.addEventListener( "touchend", lib.cancelAutoPlayTimeTimer, false );
lAutoPlayTimePlus.addEventListener( "touchcancel", lib.cancelAutoPlayTimeTimer, false );
timerBox.appendChild( lAutoPlayTimePlus );
lPicMenu.appendChild( timerBox );
}
lDownloadPic = document.createElement( "div" );
lDownloadPic.setAttribute( 'class', 'galeryIcon download' );
lDownloadPic.title = '{?9138:85?}';
lPicMenu.appendChild( lDownloadPic );
var tmp = document.createElement( "div" );
tmp.setAttribute( 'class', 'galeryIcon close' );
tmp.setAttribute( 'title', '{?9138:901?}' );
tmp.addEventListener( "click", lib.close, false );
lPicMenu.appendChild( tmp );
if ( "/nas" == lPathStart )
{
tmp = document.createElement( "div" );
tmp.setAttribute( 'class', 'galeryIcon share' );
tmp.title = '{?9138:753?}';
tmp.addEventListener( "click", function () {
lib.clearMenuHideTimer;
createFilelink( lPics[lAktPicIdx] );
}, false );
lPicMenu.appendChild( tmp );
tmp = document.createElement( "div" );
tmp.setAttribute( 'class', 'galeryIcon delete' );
tmp.title = '{?9138:806?}';
tmp.addEventListener( "click", lib.deleteAktPic, false );
lPicMenu.appendChild( tmp );
}
}
lib.catchFocus = function( evt )
{
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
if ( 9 == evt.keyCode && evt.preventDefault )
{
evt.preventDefault();
}
if ( "undefined" == typeof gAktDisableBox || !gAktDisableBox )
{
switch ( evt.keyCode )
{
case 38:
case 107:
lib.increaseAutoPlayTimeFast();
break;
case 40:
case 109:
lib.decreaseAutoPlayTimeFast();
break;
}
}
lFocusCatcher.focus();
}
lib.videoEnded = function ( evt )
{
if ( lAutoPlay )
{
lAutoPlayTimer = setTimeout( 'galery.changePic( null, "next" )', 200 );
}
};
function createVideoPlayerBox()
{
try
{
lPlayer = document.createElement( "video" );
lVideoObjSupport = !!( lPlayer.canPlayType );
lBasicVideoSupport = !!( lPlayer.play );
lVideoSupport = lVideoObjSupport && lBasicVideoSupport;
lPlayer.setAttribute( 'class', 'video_player' );
lPlayer.controls = true;
lPlayer.preload = "auto";
lPlayer.addEventListener( "ended", lib.videoEnded , false );
lPlayer.addEventListener( "error", lib.videoEnded , false );
lPlayer.addEventListener( "abort", lib.videoEnded , false );
}
catch (e)
{
lPlayer = document.createElement( "p" );
lPlayer.setAttribute( 'class', 'video_player no_support' );
lPlayer.innerHTML = "{?334:594?}";
lVideoObjSupport = false;
lBasicVideoSupport = false;
lVideoSupport = false;
}
lPicBox.appendChild( lPlayer );
jxl.display( lPlayer, false );
lPlayer.addEventListener( "click", function ( evt ) {
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
}, false );
}
function createGalery()
{
lGaleryBox = document.createElement( "div" );
lGaleryBox.id = "galeryBox";
lGaleryBox.setAttribute( 'class', 'galeryBox' );
document.body.appendChild( lGaleryBox );
lGaleryBox.addEventListener( "click", lib.close, false );
lFocusCatcher = document.createElement( "input" );
lFocusCatcher.type = "hidden";
lFocusCatcher.id = "foca";
lFocusCatcher.value = "";
lFocusCatcher.name = "foca";
lFocusCatcher.setAttribute( 'tabindex', '1' );
lFocusCatcher.addEventListener( "blur", lib.catchFocus, false );
lGaleryBox.appendChild( lFocusCatcher );
lFocusCatcher.focus();
lPicBox = document.createElement( "div" );
lPicBox.id = "picBox";
lPicBox.setAttribute( 'class', 'picBox' );
document.body.appendChild( lPicBox );
lPicBox.addEventListener( "click", lib.changePic, false );
createVideoPlayerBox();
lMenuBox = document.createElement( "div" );
lMenuBox.id = "menuBox";
lMenuBox.setAttribute( 'class', 'menuBox show' );
lPicDetails = document.createElement( "div" );
lPicDetails.setAttribute( 'class', 'picDetails' );
lMenuBox.appendChild( lPicDetails );
lPicName = document.createElement( "div" );
lPicName.setAttribute( 'class', 'picDetailsName' );
lPicName.innerHTML = lPics[lAktPicIdx].filename;
lPicDetails.appendChild( lPicName );
lPicProgress = document.createElement( "div" );
lPicProgress.setAttribute( 'class', 'picDetailsProgress' );
createPicProgress();
lPicDetails.appendChild( lPicProgress );
lPicMenu = document.createElement( "div" );
lPicMenu.setAttribute( 'class', 'picMenu' );
createPicMenu();
lMenuBox.appendChild( lPicMenu );
document.body.appendChild( lMenuBox );
lInitialMenuHideTimer = setTimeout( function() {
jxl.removeClass( lMenuBox, "show" );
lib.clearMenuHideTimer();
} , 3000 );
for ( var idx in lPics )
{
if ( lPics[idx] && lPics[idx].picElem && lPics[idx].picElem.src && 0 < lPics[idx].picElem.src.length )
{
lPicBox.appendChild( lPics[idx].picElem );
jxl.display( lPics[idx].picElem, false );
}
}
createAktPic();
}
lib.clearMenuHideTimer = function ()
{
if ( lInitialMenuHideTimer )
{
clearTimeout( lInitialMenuHideTimer );
}
lInitialMenuHideTimer = null;
return true;
}
lib.close = function ( evt, noHistory )
{
preventPropagationDefault( evt );
if ( noHistory != true && "object" == typeof privateHistory && privateHistory )
{
privateHistory.removeLastFuncHistoryEntry( lib.close );
}
if ( lLoadErrorBox )
{
lPicBox.removeChild( lLoadErrorBox );
}
if ( lPlayer && lPlayer.pause )
{
lPlayer.pause();
lPlayer.src = "";
}
if ( lPausedAudio )
{
lPausedAudio = false;
if ( audioPlayer && audioPlayer.isOpen() && !audioPlayer.isPlaying() )
{
audioPlayer.playPauseAudioPlayback();
}
}
delAllCachedPics();
lPlayer = null;
lScrollPos.left = 0;
lScrollPos.top = 0;
window.removeEventListener( "scroll", lib.preventScroll, false );
document.body.removeChild( lMenuBox );
document.body.removeChild( lPicBox );
document.body.removeChild( lGaleryBox );
window.removeEventListener( "resize", lib.setPicSize, false );
window.removeEventListener( "keydown", lib.checkKey, false );
window.removeEventListener( "keyup", lib.checkKeyUp, false );
lGaleryBox = null;
lPicBox = null;
lLoadErrorBox = null;
lPicName = null;
lPicProgress = null;
lAutoPlayIcon = null;
lAutoPlayTimeDisplay = null;
lAutoPlayTimeMinus = null;
lAutoPlayTimePlus = null;
lDownloadPic = null;
lPicMenu = null;
lMenuBox = null;
lAutoPlay = false;
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = null;
lPics = null;
if (typeof gAreas == "object" && gOpenAreaIdx != null && gAreas[gOpenAreaIdx] != null) scroll(0, gAreas[gOpenAreaIdx].lastScrollPos);
};
lib.open = function( pSid, pictures, picToShowIdx, pDelim )
{
lDelim = pDelim || "";
lSid = pSid;
lPics = pictures;
if ( !lPics || 0 >= lPics.length )
{
return;
}
lAktPicIdx = picToShowIdx;
if ( "object" == typeof privateHistory && privateHistory )
{
privateHistory.addToHistory( lib.close, [null,true] );
}
lGaleryBox = null;
lPicBox = null;
lPicName = null;
lPicProgress = null;
lAutoPlayIcon = null;
lAutoPlayTimeDisplay = null;
lAutoPlayTimeMinus = null;
lAutoPlayTimePlus = null;
lDownloadPic = null;
lPicMenu = null;
lMenuBox = null;
lAutoPlay = false;
clearTimeout( lAutoPlayTimer );
lAutoPlayTimer = null;
createGalery();
lScrollPos.left = document.body.scrollLeft;
lScrollPos.top = document.body.scrollTop;
window.addEventListener( "scroll", lib.preventScroll, false );
window.addEventListener( "resize", lib.setPicSize, false );
window.addEventListener( "keydown", lib.checkKey, false );
window.addEventListener( "keyup", lib.checkKeyUp, false );
touch.registerElemForTouch( lPicBox.id, "side", galery.cbTouchChangePic );
touch.registerElemForTouch( lPicBox.id, "updown", galery.cbTouchChangePic );
};
return lib;
} )();
