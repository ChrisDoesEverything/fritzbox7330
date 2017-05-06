function progressBar(options) {
var parent = jxl.get(options.parentId || "");
var width = options.width;
var height = options.height;
if (!parent || !width || !height) {
return false;
}
var style = {
progress: "border:solid 1px; padding:0; margin:0; line-height:0;",
span: "display:inline-block; height:100%; padding:0; margin:0;",
left: "width:0; background-color:#a4c4e7;",
right: "width:100%;",
text: "background:transparent; position:relative; bottom:50%; width:100%; text-align:center;"
};
var p2px = width/100;
var progress;
var left, right, text;
function destroy() {
if (progress) {
parent.removeChild(progress);
progress = null;
}
}
function create() {
destroy();
progress = document.createElement("div");
jxl.setCssText(progress, style.progress);
jxl.setStyle(progress, "width", width + "px");
jxl.setStyle(progress, "height", height + "px");
left = document.createElement("span");
jxl.setCssText(left, style.span + style.left);
if (options.color) {
jxl.setStyle(left, "background-color", options.color);
}
progress.appendChild(left);
right = document.createElement("span");
jxl.setCssText(right, style.span + style.right);
if (options.backColor) {
jxl.setStyle(right, "background-color", options.backColor);
}
progress.appendChild(right);
if (options.text) {
text = document.createElement("span");
jxl.setCssText(text, style.span + style.text);
if (options.fontSize) {
jxl.setStyle(text, "font-size", options.fontSize + "px");
}
progress.appendChild(text);
}
parent.appendChild(progress);
jxl.setHtml(text, String(options.initText));
}
function move(percent) {
percent = Math.min(Math.max(0, percent), 100);
var px = Math.round(p2px * percent);
jxl.setStyle(left, "width", px + "px");
jxl.setStyle(right, "width", (width - px) + "px");
if (options.text) {
jxl.setHtml(text, percent + " %");
}
}
return {
create: create,
destroy: destroy,
move: move
};
}
