var audioPlayer = audioPlayer || (function() {
"use strict";
var lib = {};
var pathStart = "/myfritz";
if (("nas" == window.location.pathname.split("/")[1]) || ("fritz.nas" == window.location.hostname)) pathStart = "/nas";
jxl.loadCss( pathStart + "/css/default/audio.css" );
var iosDevices = { 'iPad':true, 'iPhone':true, 'iPod':true };
var isIosDevice = iosDevices[navigator.platform] || false;
var playerBox = null;
var player = null;
var playerHideShow = null;
var playerClose = null;
var playPauseBtn = null;
var muteBtn = null;
var nextBtn = null;
var prevBtn = null;
var replayBtn = null;
var replayModes = { "list":"song", "song":"none", "none":"list"};
var aktReplayMode = "none";
var audioInfo = null;
var audioAktTime = null;
var audioDuration = null;
var aktTimeMode = "normal";
var timeModes = { "normal":"rest", "rest":"normal" };
var progressBar = null;
var volumeBar = null;
var playlist = null;
var aktAudioIdx = null;
var codec = { aac:"aac", mp1:"mp3", mp2:"mp3", mp3:"mp3", mpg:"mp3", mpeg:"mp3", mp4:"mp4", m4a:"mp4", ogg:"ogg", oga:"ogg", wav:"wav", wave:"wave", xwav:"xwav", webm:"webm" };
var codecSupport = { aac:false, mp3:false, mp4:false, ogg:false, other:true, wav:false, wave:false, xwav:false, webm:false };
var audioObjSupport = false;
var basicAudioSupport = false;
var audioSupport = false;
var delim = "";
var sid = null;
var imgArray = [pathStart + "/css/default/images/ico_close.png",
pathStart + "/css/default/images/ico_speaker_of.png",
pathStart + "/css/default/images/ico_next.png",
pathStart + "/css/default/images/ico_pause.png",
pathStart + "/css/default/images/ico_play.png",
pathStart + "/css/default/images/ico_previous.png",
pathStart + "/css/default/images/ico_speaker_on.png"];
var imgPreload = new Array();
for(var i=0; i < imgArray.length; i++)
{
imgPreload[i] = new Image();
imgPreload[i].src = imgArray[i];
}
function showAudioPlayer()
{
jxl.removeClass(playerHideShow, "closed");
jxl.removeClass(playerClose, "closed");
jxl.removeClass(playerBox, "closed");
}
function setProgressBackground(barElem)
{
if (barElem)
{
var tmp = 5;
if (barElem.max > 0)
{
tmp = (barElem.value * 100) / barElem.max;
if (tmp < 10) tmp += 5;
if (tmp > 90) tmp -= 5;
}
barElem.style.backgroundImage = "linear-gradient(90deg, #47bbff "+tmp+"%, #2f6390 "+tmp+"%, #2f6390 100%)";
}
}
lib.setAudioPosition = function (evt)
{
player.currentTime = progressBar.value;
setProgressBackground(progressBar);
};
lib.rangeChangeStart = function (evt)
{
if (player && !player.paused)
{
progressBar.addEventListener("touchend", lib.rangeChangeEnd, false);
player.pause();
}
};
lib.rangeChangeEnd = function rangeChangeEnd(evt)
{
progressBar.removeEventListener("touchend", lib.rangeChangeEnd, false);
player.play();
};
function showAsPlayerTime(timeInSek)
{
if (isNaN(timeInSek) || !isFinite(timeInSek) || "number" != typeof timeInSek) return "-:-";
timeInSek = Math.floor(timeInSek);
if (0 == timeInSek) return "0:00";
var sign = "";
if (0 > timeInSek)
{
sign = "-";
timeInSek *= -1;
}
var date = new Date(0, 0, 0, 0, 0, timeInSek, 0);
var hours = date.getHours();
var mins = date.getMinutes();
var secs = date.getSeconds()
secs = ('0'+secs).slice(-2);
if ("0" == hours)
{
date = mins + ':' + secs;
}
else
{
mins = ('0'+mins).slice(-2);
date = hours + ':' + mins + ':' + secs;
}
return sign + date;
}
lib.setReplayMode = function (evt)
{
aktReplayMode = replayModes[aktReplayMode];
replayBtn.innerHTML = aktReplayMode;
};
lib.setTimeMode = function (evt)
{
aktTimeMode = timeModes[aktTimeMode];
refreshPlayerTime();
};
function refreshPlayerTime()
{
if (audioAktTime)
{
var time = player.currentTime;
if (!isNaN(player.currentTime) && !isNaN(player.duration) && isFinite(player.currentTime) && isFinite(player.duration) && "rest" == aktTimeMode) time = player.currentTime - player.duration;
audioAktTime.innerHTML = showAsPlayerTime(time);
}
}
function refreshDuration()
{
if (audioDuration && "number" == typeof player.duration && player.duration > 0) audioDuration.innerHTML = showAsPlayerTime(player.duration);
}
function refreshProgressBar(evt)
{
if (progressBar && !isNaN(player.currentTime))
{
progressBar.value = player.currentTime;
setProgressBackground(progressBar);
}
}
lib.audioEnded = function (evt)
{
if (!player.paused) player.pause();
if ("number" != typeof playlist[aktAudioIdx].tam) lib.playNextSong(evt);
};
lib.onPause = function (evt)
{
playPauseBtn.setAttribute('class', 'playerBtn play');
};
lib.onPlay = function (evt)
{
playPauseBtn.setAttribute('class', 'playerBtn pause');
};
lib.playerTimeUpdate = function ()
{
refreshPlayerTime();
refreshProgressBar();
refreshDuration();
if (progressBar && progressBar.max <= 0) lib.durationChange();
};
lib.playNextSong = function (evt)
{
var tamElem = null;
if ("number" == typeof playlist[aktAudioIdx].tam)
{
tamElem = jxl.get("tamDetail" + aktAudioIdx);
if (tamElem && jxl.hasClass(tamElem, "show")) jxl.removeClass(tamElem, "show");
}
var nextIdx = aktAudioIdx;
if ("list" == aktReplayMode)
nextIdx = (playlist[aktAudioIdx + 1]) ? aktAudioIdx + 1 : 0;
else if ("none" == aktReplayMode)
{
if (playlist[aktAudioIdx + 1])
nextIdx = aktAudioIdx + 1;
else
return;
}
if ("number" == typeof playlist[nextIdx].tam)
{
tamElem = jxl.get("tamDetail" + nextIdx);
if ( tamElem && !jxl.hasClass(tamElem, "show") ) jxl.addClass(tamElem, "show");
if ( tamElem && answerJs ) answerJs.resetNewTamMsg( tamElem );
}
playAudio(nextIdx);
};
lib.playPrevSong = function (evt)
{
var tamElem = null;
if ("number" == typeof playlist[aktAudioIdx].tam)
{
tamElem = jxl.get("tamDetail" + aktAudioIdx);
if (tamElem && jxl.hasClass(tamElem, "show")) jxl.removeClass(tamElem, "show");
}
var prevIdx = aktAudioIdx;
if ("list" == aktReplayMode)
prevIdx = (playlist[aktAudioIdx - 1]) ? aktAudioIdx - 1 : playlist.length - 1;
else if ("none" == aktReplayMode)
{
if (playlist[aktAudioIdx - 1])
prevIdx = aktAudioIdx - 1;
else
return;
}
if ("number" == typeof playlist[prevIdx].tam)
{
tamElem = jxl.get("tamDetail" + prevIdx);
if ( tamElem && !jxl.hasClass(tamElem, "show") ) jxl.addClass(tamElem, "show");
if ( tamElem && answerJs ) answerJs.resetNewTamMsg( tamElem );
}
playAudio(prevIdx);
};
function closeAudioPlayer()
{
document.body.removeChild( playerBox );
player = null;
playerBox = null;
playerHideShow = null;
playerClose = null;
playlist = null;
aktAudioIdx = null;
}
lib.playPauseAudioPlayback = function ()
{
if ( player.paused )
{
player.play();
}
else
{
player.pause();
}
};
lib.isPlaying = function ()
{
return !player.paused;
};
lib.isOpen = function ()
{
return player;
};
lib.mutePlayback = function ()
{
if(0 >= player.volume)
player.muted = true;
else
player.muted = !player.muted;
if (player.muted)
{
muteBtn.setAttribute('class', 'playerBtn mute');
volumeBar.value = 0;
}
else
{
muteBtn.setAttribute('class', 'playerBtn sound');
volumeBar.value = player.volume;
}
setProgressBackground(volumeBar);
};
lib.setVolume = function (evt)
{
player.volume = volumeBar.value;
setProgressBackground(volumeBar);
if ((0 < player.volume && player.muted) || (0 >= player.volume && !player.muted)) lib.mutePlayback();
};
lib.eventCatch = function (evt)
{
if (evt.stopPropagation)
evt.stopPropagation();
else if(evt.cancelBubble != null)
evt.cancelBubble = true;
return true;
};
lib.volumeChange = function (evt)
{
if (volumeBar && !isNaN(player.volume) && !player.muted)
{
volumeBar.value = player.volume;
setProgressBackground(volumeBar);
}
};
lib.durationChange = function (evt)
{
if (progressBar && !isNaN(player.duration)) progressBar.max = player.duration;
};
function createAudioPlayerControls()
{
//erstellen eigener immer gleicher und somit einheitlicher Kontrolls
var controls = document.createElement("div");
controls.setAttribute('class', 'controls_box');
playerBox.appendChild(controls);
audioInfo = document.createElement( "div" );
audioInfo.setAttribute( 'class', 'audioInfo' );
controls.appendChild( audioInfo );
var timeRow = document.createElement("div");
timeRow.setAttribute('class', 'time_controls');
controls.appendChild(timeRow);
audioAktTime = document.createElement("div");
audioAktTime.addEventListener("click", lib.setTimeMode, false);
timeRow.appendChild(audioAktTime);
progressBar = document.createElement("input");
progressBar.type = "range";
progressBar.step = "any";
progressBar.id = "progressBar";
progressBar.min = 0;
progressBar.max = 0;
progressBar.value = 0;
progressBar.setAttribute('class', 'progressBar');
progressBar.addEventListener("change", lib.setAudioPosition, false);
progressBar.addEventListener("touchstart", lib.rangeChangeStart, false);
timeRow.appendChild(progressBar);
audioDuration = document.createElement("div");
timeRow.appendChild(audioDuration);
var controlsRow = document.createElement("div");
controlsRow.setAttribute('class', 'audio_controls');
controls.appendChild(controlsRow);
prevBtn = document.createElement("div");
prevBtn.setAttribute('class', 'playerBtn prev');
prevBtn.addEventListener("click", lib.playPrevSong, false);
controlsRow.appendChild(prevBtn);
playPauseBtn = document.createElement("div");
playPauseBtn.setAttribute('class', 'playerBtn play');
playPauseBtn.addEventListener("click", lib.playPauseAudioPlayback, false);
controlsRow.appendChild(playPauseBtn);
nextBtn = document.createElement("div");
nextBtn.setAttribute('class', 'playerBtn next');
nextBtn.addEventListener("click", lib.playNextSong, false);
controlsRow.appendChild(nextBtn);
replayBtn = document.createElement("div");
replayBtn.setAttribute('class', 'playerBtn replay hidden');
replayBtn.addEventListener("click", lib.setReplayMode, false);
replayBtn.innerHTML = "none";
controlsRow.appendChild(replayBtn);
var iosHidden = "";
if (isIosDevice) iosHidden = " hidden";
muteBtn = document.createElement("div");
muteBtn.setAttribute('class', 'playerBtn sound'+iosHidden);
muteBtn.addEventListener("click", lib.mutePlayback, false);
controlsRow.appendChild(muteBtn);
volumeBar = document.createElement("input");
volumeBar.id = "volumeBar";
volumeBar.type = "range";
volumeBar.step = "any";
volumeBar.min = 0;
volumeBar.max = 1;
volumeBar.setAttribute('class', 'volumeBar'+iosHidden);
volumeBar.addEventListener("change", lib.setVolume, false);
controlsRow.appendChild(volumeBar);
}
function createAudioPlayerBox()
{
playerBox = document.createElement("div");
playerBox.setAttribute('class', 'player_box closed');
playerBox.addEventListener('click', lib.eventCatch, false);
document.body.appendChild(playerBox);
playerHideShow = document.createElement("div");
playerHideShow.setAttribute('class', 'player_show closed');
playerHideShow.addEventListener("click", lib.hideShowPlayer, false);
playerHideShow.innerHTML = "<div></div>";
playerBox.appendChild(playerHideShow);
playerClose = document.createElement( "div" );
playerClose.setAttribute( 'class', 'player_close closed' );
playerClose.addEventListener( "click", lib.close, false );
playerClose.innerHTML = "<img src='" + pathStart + "/css/default/images/ico_close.png' alt=''/>";
playerBox.appendChild( playerClose );
try
{
player = document.createElement("audio");
audioObjSupport = !!(player.canPlayType);
basicAudioSupport = !!(player.play);
audioSupport = audioObjSupport && basicAudioSupport;
if (player.canPlayType) {
var tmpAAC = player.canPlayType("audio/aac");
var tmpMP3 = player.canPlayType("audio/mpeg");
var tmpMP4 = player.canPlayType("audio/mpeg");
var tmpOGG = player.canPlayType("audio/ogg");
var tmpWAV = player.canPlayType("audio/wav");
var tmpXWAV = player.canPlayType("audio/x-wav");
var tmpWAVE = player.canPlayType("audio/wave");
var tmpWEBM = player.canPlayType("audio/webm");
codecSupport.aac = ("no" != tmpAAC) && ("" != tmpAAC);
codecSupport.mp3 = ("no" != tmpMP3) && ("" != tmpMP3);
codecSupport.mp4 = ("no" != tmpMP4) && ("" != tmpMP4);
codecSupport.ogg = ("no" != tmpOGG) && ("" != tmpOGG);
codecSupport.wav = ("no" != tmpWAV) && ("" != tmpWAV);
codecSupport.xwav = ("no" != tmpXWAV) && ("" != tmpXWAV);
codecSupport.wave = ("no" != tmpWAVE) && ("" != tmpWAVE);
codecSupport.webm = ("no" != tmpWEBM) && ("" != tmpWEBM);
}
player.addEventListener('timeupdate', lib.playerTimeUpdate,false);
player.addEventListener('durationchange', lib.durationChange,false);
player.addEventListener('volumechange', lib.volumeChange,false);
player.addEventListener('ended', lib.audioEnded,false);
player.addEventListener('pause', lib.onPause,false);
player.addEventListener('play', lib.onPlay,false);
player.setAttribute('class', 'audio_player');
player.controls = false;
player.preload = "auto";
createAudioPlayerControls();
}
catch (e)
{
player = document.createElement("p");
player.setAttribute('class', 'audio_player no_support');
player.innerHTML = "{?2531:252?}";
audioObjSupport = false;
basicAudioSupport = false;
audioSupport = false;
}
playerBox.appendChild(player);
setTimeout( showAudioPlayer, 50);
}
function playAudio(audioIdx)
{
var urlPrefix = encodeURI(pathStart+"/cgi-bin/luacgi_notimeout");
var tamfile = ("number" == typeof playlist[audioIdx].tam);
urlPrefix = addUrlParam(urlPrefix, "sid", sid);
if (tamfile)
{
urlPrefix = addUrlParam(urlPrefix, "cmd", "tam");
urlPrefix = addUrlParam(urlPrefix, "tam", playlist[audioIdx].tam);
urlPrefix = addUrlParam(urlPrefix, "msg", playlist[audioIdx].index);
urlPrefix = addUrlParam(urlPrefix, "td", playlist[audioIdx].date || "");
}
else
{
urlPrefix = addUrlParam(urlPrefix, "cmd", "audio");
}
urlPrefix = addUrlParam(urlPrefix, "cmd_files", playlist[audioIdx].path + delim);
urlPrefix = addUrlParam(urlPrefix, "script", "/http_file_download.lua");
player.pause();
player.src = "";
player.src = urlPrefix;
var tmpEnd = playlist[audioIdx].path.substr(playlist[audioIdx].path.lastIndexOf(".") + 1);
tmpEnd = tmpEnd.toLowerCase();
if (tamfile) tmpEnd = "xwav";
if (codec[tmpEnd] && codecSupport[codec[tmpEnd]])
{
aktAudioIdx = audioIdx;
if (audioInfo) audioInfo.innerHTML = ( playlist[audioIdx].filename ) ? playlist[audioIdx].filename : "";
if (audioDuration) audioDuration.innerHTML = "0:00";
if (audioAktTime) audioAktTime.innerHTML = "0:00";
if (progressBar)
{
progressBar.value = 0;
progressBar.max = 0;
setProgressBackground(progressBar);
}
if (volumeBar && !player.muted)
{
volumeBar.value = player.volume;
setProgressBackground(volumeBar);
}
player.play();
}
else
alert("{?2531:113?}");
}
lib.hideShowPlayer = function ()
{
if (playerBox)
{
if (jxl.hasClass(playerBox, "hide"))
{
jxl.removeClass(playerBox, "hide");
jxl.removeClass(playerHideShow, "hide");
jxl.removeClass(playerClose, "hide");
}
else
{
jxl.addClass(playerBox, "hide");
jxl.addClass(playerHideShow, "hide");
jxl.addClass(playerClose, "hide");
}
}
};
lib.open = function( pSid, audioFiles, audioToPlayIdx, pDelim )
{
delim = pDelim || "";
sid = pSid;
playlist = null;
playlist = audioFiles;
if ( !playlist || 0 >= playlist.length )
{
return;
}
if ( !playerBox )
{
createAudioPlayerBox();
}
playAudio( audioToPlayIdx );
};
lib.close = function( evt )
{
if ( evt && evt.stopPropagation )
{
evt.stopPropagation();
}
if ( evt && evt.preventDefault )
{
evt.preventDefault();
}
if ( playerBox )
{
jxl.addClass(playerHideShow, "closed");
jxl.addClass(playerClose, "closed");
jxl.addClass(playerBox, "closed");
if ( player && player.pause )
{
player.pause();
player.src = "";
}
setTimeout(closeAudioPlayer, 500);
}
};
lib.tamFilePlaying = function()
{
return (aktAudioIdx != null && playlist[aktAudioIdx] && typeof playlist[aktAudioIdx].tam == "number");
};
return lib;
})();
