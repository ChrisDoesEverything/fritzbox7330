// de-first -begin
var g_challenge = "";
var gTxtWaitone = "{?3348:454?}";
var gTxtWaitmore = "{?3348:732?}";
function makeDots(str) {
var newStr = "";
for (var i = 0, len = str.length; i < len; i++) {
if (str.charCodeAt(i) > 255) newStr += ".";
else newStr += str.charAt(i);
}
return newStr;
}
function setFocus()
{
var idToFocus = "uiPass";
var username = jxl.get("uiViewUser");
if (username && (jxl.getValue(username) == "" || <?lua box.js(tostring(gl.from_internet)) ?>))
{
idToFocus = "uiViewUser";
}
jxl.focus(idToFocus);
}
function uiDoOnMainFormSubmit()
{
jxl.display("uiLoginError", false);
var username = jxl.get("uiViewUser");
if (username)
{
var name = jxl.getValue("uiViewUser");
if (name.length <= 0)
{
jxl.display("uiSelectUsername", true);
jxl.addClass("uiViewUser", "error");
jxl.focus("uiViewUser");
return false;
}
else
{
jxl.display("uiSelectUsername", false);
jxl.removeClass("uiViewUser", "error");
jxl.setValue("username", name);
}
}
var dot_pass = makeDots(jxl.getValue("uiPass"));
var resp = g_challenge + "-" + dot_pass;
jxl.setValue("uiResp", g_challenge + "-" + hex_md5(resp));
jxl.disable("uiViewUser");
jxl.disable("uiPass");
jxl.disable("uiSubmitLogin");
jxl.setStyle("uiMainForm", "cursor", "wait");
return true;
}
function getWaitStr(mSec)
{
var sec = Math.ceil(mSec/1000);
if (sec === 1)
{
return gTxtWaitone;
}
else
{
return gTxtWaitmore.replace(/%1/,sec);
}
}
function doBlockLogin(time)
{
jxl.disable("uiViewUser");
jxl.disable("username");
jxl.disable("uiPass");
jxl.disable("uiSubmitLogin");
var start = (new Date()).getTime();
var timer = timer || null;
if (timer)
{
window.clearTimeout(timer);
timer = null;
}
function f()
{
var now = (new Date()).getTime();
var wait = time - (now - start);
if (wait > 0)
{
jxl.setHtml("uiWait", getWaitStr(wait));
jxl.show("uiLoginError");
timer = window.setTimeout(f, 500);
}
else
{
jxl.hide("uiLoginError");
jxl.enable("uiViewUser");
jxl.enable("username");
jxl.enable("uiPass");
setFocus();
jxl.enable("uiSubmitLogin");
}
}
f();
}
function login_init(blocktime, showUser)
{
var form = jxl.get("uiMainForm");
if (form)
{
jxl.hide("jswarning");
if (!showUser || jxl.getValue("uiViewUser").length > 0)
{
jxl.enable("uiSubmitLogin");
}
setFocus();
form.onsubmit = uiDoOnMainFormSubmit;
g_challenge = "<?lua box.js(box.query([[security:status/challenge]])) ?>"
if ( blocktime > 0 )
{
doBlockLogin(blocktime*1000);
}
}
}
