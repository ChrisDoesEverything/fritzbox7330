<?lua
g_page_type = "all"
g_page_title = box.tohtml( [[{?5086:82?}]])
--g_page_help = "hilfe_smart_home_overview.html"
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("boxvars2")
require("elem")
require("menu")
require("cmtable")
require("val")
require("general")
g_current_device = nil
function init_page_vars( device)
g_current_device = device
end
if ( next(box.get) and box.get.device) then
init_page_vars( box.get.device)
else
if ( next(box.post)) then
init_page_vars( box.post.current_ule)
if (box.post.cancel) then
http.redirect( [[/net/home_auto_overview.lua]])
end
end
end
function get_val_prog()
g_val = {
prog = [[
]]
}
end
get_val_prog()
if ( next(box.post)) then
local l_val_result = val.ret.ok
local saveset = {}
if ( box.post.apply) then
http.redirect( [[/net/home_auto_edit_view.lua?device=]]..g_current_device)
end
if ( box.post.cancel) then
http.redirect( [[/net/home_auto_overview.lua]])
end
end
?>
<?include "templates/html_head.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/kids.css"/> -->
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="uiWait" class="wait">
<div id="uiWaitText">
<p>{?5086:299?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<p>{?5086:601?}</p>
</div>
<div id="uiDone" class="wait" style="display:none;">
<div id="uiDoneText">
<p>{?5086:4?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>
</div>
<div id="uiDoneError" class="wait" style="display:none;">
<div id="uiDoneErrorText">
<p>{?5086:579?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="current_ule" id="uiCurrentUle" value="">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply" style="display:none;">{?5086:852?}</button>
<button type="submit" name="cancel" id="uiCancel" style="display:none;">{?5086:493?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_reg_counter = 0;
var json = makeJSONParser();
var sidParam = buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
<?lua
-- val.write_js_error_strings()
?>
function sendRequest( szValue) {
var url = encodeURI("/query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam("SubscriptionState", "dect:settings/SubscriptionState");
ajaxGet( url, cb_get_response)
}
function cb_get_response(xhr) {
var response = json(xhr.responseText || "null");
if (!response || parseInt(response.SubscriptionState) == 1) {
setTimeout( sendRequest, 2500);
} else {
if ( response.SubscriptionState == 0) {
setTimeout( sendRequest2, 2500);
} else {
jxl.display( "uiWait", false);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
}
}
function sendRequest2( szValue) {
var url = encodeURI("/query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam("DectHandset", "dect:settings/NewHandsets");
url += "&" + buildUrlParam("DectULEDevice", "dect:settings/NewULEs");
ajaxGet( url, cb_get_response_2)
}
function cb_get_response_2(xhr) {
var response = json(xhr.responseText || "null");
if (!response ) {
setTimeout( sendRequest2, 1000);
} else {
if ( response.DectULEDevice >= 16) {
jxl.setValue( "uiCurrentUle", response.DectULEDevice)
setTimeout( "sendRequest3("+response.DectULEDevice+")", 2000);
} else {
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
}
}
function sendRequest3( szUleID) {
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "CheckRegistering");
url += "&" + buildUrlParam( "id", szUleID);
ajaxGet( url, cb_Receive_Existence_Result)
}
function cb_Receive_Existence_Result(xhr) {
var response = json(xhr.responseText || "null");
if (!response ) {
setTimeout( "sendRequest3("+jxl.getValue("uiCurrentUle")+")", 2000);
} else {
if ( response.RequestResult == 1) {
jxl.display( "uiWait", false);
jxl.display( "uiDone", true);
if ( response.repeaterOnly == 1) {
jxl.display( "uiCancel", true);
} else {
jxl.display( "uiApply", true);
}
jxl.setValue( "uiCurrentUle", response.DeviceID)
} else {
if ( g_reg_counter >= 10) {
jxl.display( "uiWait", false);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
} else{
g_reg_counter = g_reg_counter + 1;
setTimeout( "sendRequest3("+jxl.getValue("uiCurrentUle")+")", 2000);
}
}
}
}
function onEditDevSubmit() {
<?lua
-- val.write_js_checks(g_val)
?>
}
function init() {
setTimeout( sendRequest, 5000);
jxl.display( "uiApply", false);
jxl.display( "uiCancel", false);
}
ready.onReady(val.init(onEditDevSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
