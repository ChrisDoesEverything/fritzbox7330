var popup = popup || (function() {
var lib = {};
lib.prepareHeader = function() {
var p = document.createElement("p");
p.className = "popuphead";
var printBtn = document.createElement("button");
printBtn.onclick = function() { window.print(); }
jxl.setHtml(printBtn, "{?2747:905?}");
var closeBtn = document.createElement("button");
closeBtn.onclick = function() { window.close(); }
jxl.setHtml(closeBtn, "{?2747:219?}");
jxl.setStyle(closeBtn, "float", "right");
p.appendChild(printBtn);
p.appendChild(closeBtn);
jxl.get("main_page_all").insertBefore(p, jxl.get("main_page_all").firstChild);
var links = document.getElementsByTagName("a");
for (var i=0; i<links.length; i++) {
links[i].onclick = function() { return false; };
}
};
var popupElem;
var popUpBox;
var backgroundBox;
lib.setPopupSize = function() {
var offset = 0;
var width = popupElem.offsetWidth || 4000;
var height = popupElem.offsetHeight || 3000;
var ratio = height / width;
if (width > backgroundBox.offsetWidth)
{
width = backgroundBox.offsetWidth;
height = width * ratio;
}
if (height > backgroundBox.offsetHeight)
{
height = backgroundBox.offsetHeight;
width = height / ratio;
}
popUpBox.style.margin = "auto";
var headFootMargin = (backgroundBox.offsetHeight - height) * 0.5;
var sideMargin = (backgroundBox.offsetWidth - width) * 0.5;
popUpBox.style.margin = headFootMargin+"px " +sideMargin + "px";
popUpBox.style.width = width+"px";
popUpBox.style.height = height+"px";
}
lib.updatePopup = function(popupElem2, width, height, addCloseListener) {
if (!backgroundBox || !popUpBox)
lib.createPopup(popupElem2, width, height, addCloseListener);
if (addCloseListener)
{
backgroundBox.addEventListener("click", lib.close, false);
popUpBox.addEventListener("click", lib.close, false);
}
popUpBox.replaceChild(popupElem2, popupElem);
popupElem = popupElem2;
if (!isNaN(Number(width)))
popupElem.style.width = width+"px";
if (!isNaN(Number(height)))
popupElem.style.height = height+"px";
lib.setPopupSize();
};
lib.createPopup = function(popupElem2, width, height) {
backgroundBox = document.createElement("div");
backgroundBox.id = "backgroundBox";
backgroundBox.setAttribute('class', 'backgroundBox');
document.body.appendChild(backgroundBox);
popUpBox = document.createElement("div");
popUpBox.id = "main_popup_page_all";
popUpBox.setAttribute('class', 'popUpBox');
document.body.appendChild(popUpBox);
window.addEventListener("resize", lib.setPopupSize, false);
popupElem = popupElem2;
popUpBox.appendChild(popupElem);
//if (addCloseListener)
// backgroundBox.addEventListener("click", lib.close, false);
//if (addCloseListener)
// popUpBox.addEventListener("click", lib.close, false);
//if (!isNaN(Number(width)))
// popupElem.style.width = width+"px";
//if (!isNaN(Number(height)))
// popupElem.style.height = height+"px";
//lib.setPopupSize();
};
lib.close = function() {
window.removeEventListener("resize", lib.setPopupSize, false);
popUpBox.removeEventListener("click", close, false);
backgroundBox.removeEventListener("click", close, false);
//popUpBox.removeChild(pics[aktPicIdx].picElem);
document.body.removeChild(popUpBox);
document.body.removeChild(backgroundBox);
backgroundBox = null;
popUpBox = null;
//if (typeof gAreas == "object" && gOpenAreaIdx != null && gAreas[gOpenAreaIdx] != null) scroll(0, gAreas[gOpenAreaIdx].lastScrollPos);
}
return lib;
})();
