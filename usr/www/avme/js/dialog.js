var dialog = dialog ||(function() {
var lib = {};
var xhr = undefined;
var clicked = false;
var body = null;
lib.init = function()
{
body = document.body;
if (!body)
{
body = document.getElementsByTagName("body")[0];
}
}
lib.overlay = function(mode) {
if(document.getElementById("overlay") === null) {
div = document.createElement("div");
div.setAttribute('id', 'overlay');
div.setAttribute('className', 'overlayBG');
div.setAttribute('class', 'overlayBG');
body.appendChild(div);
}
};
/*************************************************************************************************/
lib.closeBox = function(box){
body.removeChild(document.getElementById(box));
body.removeChild(document.getElementById("overlay"));
};
/*************************************************************************************************/
lib.addButton = function(count, txt, contentJson)
{
var button = document.createElement("button");
button.setAttribute("type", 'button');
button.setAttribute("id", 'Button'+count);
button.setAttribute("name", 'button'+count);
jxl.addEventHandler(button, 'click', function() {lib.messagebox(false,contentJson, txt)});
var buttontext = document.createTextNode(txt);
button.appendChild(buttontext);
return button;
};
lib.content = function(elem, contentJson)
{
var span = document.createElement('span');
var horizontal = document.createElement ('hr')
var imageSpan = document.createElement('span');
imageSpan.setAttribute('class', 'imagearea');
var buttonDiv = document.createElement('div');
buttonDiv.setAttribute('class', 'buttonsarea');
var buttonCount = 1;
var idx = 1;
var textVar = "Text" + idx;
while (typeof contentJson[textVar] != "undefined") {
var text = document.createTextNode(contentJson[textVar]);
var divText = document.createElement('div');
divText.setAttribute('class', 'textarea');
var addClassVar = "AddClass" + idx;
if (contentJson[addClassVar]) {
jxl.addClass(divText, contentJson[addClassVar]);
}
divText.setAttribute('id', 'TextArea' + idx);
if (idx == 1 && typeof contentJson.Icon != "undefined")
{
icon = document.createElement('IMG');
icon.src = contentJson.Icon;
divText.appendChild(icon);
}
divText.appendChild(text);
elem.appendChild(divText);
idx++;
textVar = "Text" + idx;
}
if (typeof contentJson.Buttons != "undefined")
{
for (var i=0; i < contentJson.Buttons.length; i++)
{
var button = lib.addButton(buttonCount,contentJson.Buttons[i].txt, contentJson);
buttonDiv.appendChild(button);
buttonCount = ++buttonCount;
}
}
elem.appendChild(imageSpan);
elem.appendChild(horizontal);
elem.appendChild(buttonDiv);
};
/*************************************************************************************************/
lib.messagebox = function(display, contentJson, txt)
{
if (display)
{
lib.overlay()
messagebox = document.createElement('div');
messagebox.setAttribute('id', 'messagebox');
body.appendChild(messagebox);
inbox = document.createElement('div');
inbox.setAttribute('id', 'inbox');
messagebox.appendChild(inbox);
lib.content(inbox, contentJson);
return false;
}
else{
for (var i=0; i < contentJson.Buttons.length; i++)
{
if ((typeof contentJson.Buttons[i].cb != "undefined") && (contentJson.Buttons[i].txt == txt))
{
contentJson.Buttons[i].cb();
}
}
lib.closeBox("messagebox");
}
};
/*************************************************************************************************/
lib.confirm = function(txt1, txt2, callback)
{
var alertJson = {
Text1 : txt1,
Text2 : txt2,
AddClass1 : "subtitle",
"Buttons" : [
{txt:"{?txtOK?}", cb: callback},
{txt:"{?txtCancel?}"},
]
};
lib.messagebox(true, alertJson);
};
/*************************************************************************************************/
lib.alert = function(txt,icon)
{
var alertJson = {
Text1 : txt,
"Buttons" : [
{txt:"{?txtOK?}"},
]
};
if (typeof icon != "undefined")
{
alertJson.Icon = icon;
}
dialog.messagebox(true, alertJson);
};
/*************************************************************************************************/
lib.modalBox = function(){
lib.overlay();
var modalbox = document.createElement('div');
modalbox.setAttribute('id', 'modalbox');
body.appendChild(modalbox);
return modalbox;
};
ready.onReady(lib.init);
return lib;
})();
