/*
*/
function createTamPlayer(btn) {
var audio;
var src;
var img = {
play: '<img src="/css/default/images/icon_tamplay.png">',
stop: '<img src="/css/default/images/icon_tamstop.png">'
};
function onPlay() {
jxl.setHtml(btn, img.stop);
}
function onStop() {
jxl.setHtml(btn, img.play);
}
if (!audio) {
var a = jxl.findParentByTagName(btn, "a");
var src = (a && a.href) || "";
if (window.Audio) {
audio = new Audio();
}
else {
audio = document.createElement("audio");
}
if (!audio || !src) {
return false;
}
a.appendChild(audio);
jxl.addEventHandler(audio, "play", onPlay);
jxl.addEventHandler(audio, "pause", onStop);
jxl.addEventHandler(audio, "ended", onStop);
jxl.addEventHandler(btn, "click", function(evt) {
if (audio.paused || audio.ended) {
if (!audio.src) {
audio.type = 'audio/wav; codecs="1"';
audio.src = src;
}
audio.load();
audio.play();
}
else {
audio.pause();
}
return false;
});
}
return true;
}
function initAudio(btnName) {
var audio, wav;
if (window.Audio) {
audio = new Audio();
}
else {
audio = document.createElement("audio");
}
if (audio && audio.canPlayType) {
wav = audio.canPlayType('audio/wav; codecs="1"');
}
if (wav && wav != "no") {
var btns = jxl.getByName(btnName || "tam") || [];
var i = btns.length;
while (i--) {
if (createTamPlayer(btns[i])) {
jxl.addClass(btns[i], "audio");
}
}
}
}
