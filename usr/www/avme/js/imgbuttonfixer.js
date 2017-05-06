function createOnClickIe7(oldOnClick, btnName, realBtnValue, btn)
{
return function(evt) {
var hi = jxl.get("ie7BtnFixId");
if (!hi)
{
hi = document.createElement('input');
hi.setAttribute("type", "hidden");
hi.setAttribute("name", btnName);
hi.setAttribute("id", "ie7BtnFixId");
hi.setAttribute("value", realBtnValue);
btn.appendChild(hi);
}
else
{
hi.value = realBtnValue;
hi.name = btnName;
}
if(typeof oldOnClick == "function" )
return oldOnClick(evt);
};
}
function Ie7WorkAround()
{
var btns = document.getElementsByTagName("button");
var realBtnValue = "";
var oldOnClick = "";
if (btns && btns.length)
{
for (var i=0; i < btns.length; i++ )
{
realBtnValue = "";
for(var k=0; k < btns[i].attributes.length; k++)
{
if(btns[i].attributes[k].nodeName == "value")
realBtnValue = btns[i].attributes[k].nodeValue;
}
if(realBtnValue != "")
{
oldOnClick = btns[i].onclick;
btns[i].onclick = createOnClickIe7(oldOnClick, btns[i].name, realBtnValue, btns[i]);
btns[i].name += "_ie7BtnFix";
}
}
}
}
ready.onReady(Ie7WorkAround);
