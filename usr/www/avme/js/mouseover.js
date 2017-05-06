var mover = (function() {
var ttId = "uiViewAutoToolTip";
var ttIdShadow = "uiViewAutoToolTipShadow";
var showTimer = null;
var cur = null;
var txt = "";
var tipObj= null;
var tipObjShadow= null;
function show(current, text, e)
{
txt = text;
cur = current;
jxl.addEventHandler(cur, "mouseout", hide);
jxl.addEventHandler(cur, "mousemove", move);
tipObj = jxl.get(ttId);
tipObjShadow = jxl.get(ttIdShadow);
if (!tipObj)
{
var my_head = document.getElementsByTagName("head")[0];
var my_css = document.createElement("link");
my_css.setAttribute("rel", "stylesheet");
my_css.setAttribute("type", "text/css");
my_css.setAttribute("href", "/css/default/mouseover.css");
my_head.appendChild(my_css);
tipObj = document.createElement("div");
if(tipObj)
{
tipObj.id=ttId;
tipObj.setAttribute("class", "mouseover");
tipObj.style.display="none";
cur.appendChild(tipObj);
}
tipObjShadow = document.createElement("div");
if(tipObjShadow)
{
tipObjShadow.id=ttIdShadow;
tipObjShadow.setAttribute("class", "mouseovershadow");
tipObjShadow.style.display="none";
cur.appendChild(tipObjShadow);
}
}
if (showTimer==null)
showTimer = setTimeout(showNow, 1000);
}
function showNow()
{
if (tipObj)
{
tipObj.innerHTML=txt;
tipObj.style.display="";
}
if (tipObjShadow)
{
tipObjShadow.innerHTML=txt;
tipObjShadow.style.display="";
}
return;
}
function move(e)
{
e = (e == null ) ? window.event : e;
if (!e || !tipObj)
return;
tipObj.style.left=(e.pageX?e.pageX:e.clientX)+5+"px";
tipObj.style.top=(e.pageY?e.pageY:e.clientY)+5+"px";
if (tipObjShadow)
{
tipObjShadow.style.left=(e.pageX?e.pageX:e.clientX)+8+"px";
tipObjShadow.style.top=(e.pageY?e.pageY:e.clientY)+8+"px";
}
return;
}
function hide()
{
if (showTimer)
clearTimeout(showTimer);
if (tipObj)
tipObj.style.display="none";
if (tipObjShadow)
tipObjShadow.style.display="none";
jxl.removeEventHandler(cur, "mouseout", hide);
jxl.removeEventHandler(cur, "mousemove", move);
showTimer = null;
tipObj = null;
tipObjShadow = null;
cur = null;
txt = "";
return;
}
return {
show: show
};
})();
