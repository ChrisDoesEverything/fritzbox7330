<?lua
g_page_type = "all"
g_page_title = [[{?4737:542?}]]
g_page_help = 'hilfe_fon_telefonbuch_neu.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_book")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_edit.lua" )
g_menu_active_page = g_back_to_page
g_val = {
prog = [[
]]
}
g_showError=0
if not config.ONLINEPB then
http.redirect([[/fon_num/fonbook_list.lua]])
end
g_errcode = 0
g_errmsg = [[]]
g_data={}
g_data.online_test ="1"
g_data.online_state=""
function read_data()
fon_book.read_online_book()
g_data.uid="-1"
if box.get and box.get.uid then
g_data.uid = box.get.uid
elseif box.post and box.post.uid then
g_data.uid = box.post.uid
end
g_data.is_new=false
if box.get and box.get.is_new then
g_data.is_new = box.get.is_new
elseif box.post and box.post.is_new then
g_data.is_new = box.post.is_new
end
end
g_ajax = false
if box.get.useajax then
g_ajax = true
end
if box.post.useajax then
g_ajax = true
end
if g_ajax then
local book=fon_book.read_online_book()
box.out(js.table(book))
box.end_page()
end
if (next(box.post) and (box.post.cancel)) then
http.redirect(href.get(g_back_to_page,"online_state=abort"))
end
read_data()
if (next(box.post) and (box.post.apply)) then
if box.post.online_state=="0" or box.post.online_state=="2" then
http.redirect([[/fon_num/fonbook_list.lua]])
else
http.redirect(href.get(g_back_to_page,"uid="..box.post.uid,"online_state="..box.tohtml(box.post.online_state),"is_new="..box.tohtml(g_data.is_new)))
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_Uid =<?lua box.out(tostring(g_data.uid))?>;
var g_txtWaiting = "{?4737:221?}";
var g_txtOK = "{?4737:200?}";
var g_txtFailed = "{?4737:928?}";
var g_txtErrorCode = "{?4737:391?}";
var g_txtSyncGoesOn = "{?4737:92?}";
var g_txtSuccess="{?4737:951?}"
var g_txtFault ="{?4737:919?}"
var g_cbMaxCount=25;
var g_cbCount=0;
var json = makeJSONParser();
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function CheckState(ontelStatus)
{
var obj=jxl.get("uiWaitCtrl");
jxl.setValue("uiOnlineState",ontelStatus);
switch (ontelStatus) {
case -1:
case 2:
if (g_cbCount >= g_cbMaxCount) {
jxl.changeImage("uiImage","/css/default/images/finished_ok_green.gif");
if (obj)
{
obj.title=g_txtSuccess;
}
jxl.setText("uiWaitTop", "{?4737:343?}");
jxl.setText("uiWaitBottom", g_txtSyncGoesOn);
jxl.setDisabled("uiContinue", false);
jxl.disable("uiCancel");
}
else {
jxl.changeImage("uiImage","/css/default/images/wait.gif");
if (obj)
{
obj.title="{?4737:309?}";
}
jxl.setText("uiWaitBottom", g_txtWaiting);
}
break;
case 0:
jxl.changeImage("uiImage","/css/default/images/finished_ok_green.gif");
if (obj)
{
obj.title=g_txtSuccess;
}
jxl.setText( "uiWaitBottom", g_txtOK);
g_cbCount=g_cbMaxCount;
jxl.setDisabled("uiContinue", false);
jxl.disable("uiCancel");
break;
case 1:
case 3:
case 7:
case 8:
case 9:
case 12:
case 15:
case 16:
case 19:
case 20:
case 21:
case 22:
case 23:
case 24:
case 25:
case 26:
case 127:
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=g_txtFault;
}
var errTxt=jxl.sprintf(g_txtErrorCode, ontelStatus);
jxl.setText("uiWaitBottom",errTxt);
jxl.setDisabled("uiContinue", false);
jxl.disable("uiCancel");
break;
case 4:
case 5:
case 6:
case 10:
case 11:
case 13:
case 14:
case 17:
case 18:
default:
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=g_txtFault;
}
var errTxt=jxl.sprintf(g_txtFailed, ontelStatus);
jxl.setText("uiWaitBottom", errTxt);
jxl.setDisabled("uiContinue", false);
jxl.disable("uiCancel");
break;
}
return
}
function cbRefresh(response)
{
if (response && response.status == 200)
{
var ontel = json(response.responseText || "null");
if (ontel)
{
var goOn = false;
for (var i = 0, len = ontel.length; i < len; i++) {
if (ontel[i].enabled == "1") {
if (ontel[i].status == "-1") {
goOn = true;
break;
}
else if (ontel[i].status == "2") {
goOn = true;
break;
}
else {
}
}
}
var currState=32000;
//var cur_idx=g_Uid-240;
var cur_idx=0;
for (var i = 0, len = ontel.length; i < len; i++) {
if (ontel[i].id == g_Uid) {
cur_idx=i;
break;
}
}
if (cur_idx < ontel.length) {
currState = parseInt(ontel[cur_idx].status,10);
}
if (goOn) {
if (g_cbCount >= g_cbMaxCount) {
CheckState(currState);
}
else {
window.setTimeout(GetOntelState, 1000);
}
}
else {
CheckState(currState);
}
}
}
}
function GetOntelState(){
g_cbCount++;
var my_url = "/fon_num/fonbook_edit.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&which=onlinetest";
ajaxGet(my_url, cbRefresh);
}
function init()
{
if (g_Uid>=0 && g_Uid<=255)
{
window.setTimeout(GetOntelState, 500);
}
else
{
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
var errTxt=jxl.sprintf(g_txtFailed, -1);
jxl.setText("uiWaitBottom", errTxt);
}
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<div id="uiWait" class="wait">
<div id="uiWaitTop">{?4737:741?}</div>
<p id="uiWaitCtrl" class="waitimg" title="{?4737:980?}"><img id='uiImage' src='/css/default/images/wait.gif'></p>
<div id="uiWaitBottom">{?4737:234?}</div>
</div>
</div>
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<input type="hidden" name="online_test" value="<?lua box.html(tostring(g_data.online_test)) ?>">
<input type="hidden" id="uiOnlineState" name="online_state" value="<?lua box.html(tostring(g_data.online_state)) ?>">
<input type="hidden" name="is_new" value="<?lua box.html(tostring(g_data.is_new)) ?>">
<input type="hidden" name="uid" value="<?lua box.html(tostring(g_data.uid)) ?>">
<button type="submit" id="uiContinue" name="apply" style="" disabled>{?txtNext?}</button>
<button type="submit" id="uiCancel" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.out(g_back_to_page) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
