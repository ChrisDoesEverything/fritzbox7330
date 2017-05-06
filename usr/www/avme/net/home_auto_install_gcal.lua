<?lua
g_page_type = "all"
g_page_title = box.tohtml( [[{?9648:24?}]])
--g_page_help = "hilfe_home_auto_install_gcal.html"
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("boxvars2")
require("elem")
require("menu")
require("val")
require("cmtable")
require("general")
g_current_device = nil
g_current_node = nil
g_last_timer = nil
g_Calname = nil
function init_page_vars( device, node, last_t)
g_current_device = device
g_current_node = node
g_last_timer = last_t
if ( node ~= nil) then
g_Calname = box.query( [[oncal:settings/]]..node..[[/calname]])
end
end
if ( next(box.get) and box.get.device) then
init_page_vars( box.get.device, box.get.cal_node, box.get.last_timer)
else
if ( next(box.post)) then
init_page_vars( box.post.current_ule)
if ( box.post.apply) then
http.redirect( [[/net/home_auto_overview.lua]])
end
if (box.post.cancel) then
http.redirect( [[/net/home_auto_timer_view.lua?device=]]..g_current_device)
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
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
.link {
color: #0000F0;
font-weight: bold;
text-decoration: underline;
}
.verify_label {
margin-left: 115px;
text-align: left;
font-weight: bold;
}
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="uiWait" class="wait">
<div id="uiWaitText">
<p>{?9648:386?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<p>{?9648:910?}</p>
</div>
<div id="uiShowVerifyData" class="wait" style="display:none;">
<div>
<p id="Label_uiVerifikationUrl" class="verify_label">{?9648:980?}</p>
<p class="output"><a class="link" href="javascript:onClick_VerifyUrl()"><span id="uiVerifikationUrl">&nbsp;</span></a></p>
</div>
<div>
<p id="Label_uiUserCode" class="verify_label">{?9648:701?}</p>
<p class="output"><span id="uiUserCode">&nbsp;</span></p>
</div>
<p class="waitimg" style="margin-top: 20px">{?9648:655?}</p>
</div>
<div id="uiDone" class="wait" style="display:none;">
<div id="uiDoneText">
<p>{?9648:244?}</p>
<p>{?9648:483?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>
</div>
<div id="uiDoneError" class="wait" style="display:none;">
<div id="uiDoneErrorText">
<p>{?9648:947?}</p>
<p>{?9648:463?}</p>
<p><span id="uiShow_AuthErrorText">&nbsp;</span></p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="current_ule" id="uiCurrentUle" value="<?lua box.html(g_current_device) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?9648:287?}</button>
<button type="submit" name="cancel" id="uiCancel">{?9648:272?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript">
var gLastTimer = "<?lua box.js(g_last_timer) ?>";
var gCurrentNode = "<?lua box.js(g_current_node) ?>";
var gCurrentCalname = "<?lua if (g_Calname ~= nil) then box.js(g_Calname) else box.js("") end ?>";
var g_VerificationSuccessful = false;
var g_Last_Auth_State = "0";
var g_szVerificationUrl = "";
var g_szUserCode = "";
var g_reg_counter = 0;
var json = makeJSONParser();
var sidParam = buildUrlParam( "sid", "<?lua box.js(box.glob.sid) ?>");
function SendRequest( szValue) {
var url = encodeURI("/query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam("LastState", "oncal:settings/"+gCurrentNode+"/laststatus");
url += "&" + buildUrlParam("Verification_Url", "oncal:settings/"+gCurrentNode+"/verification_url");
url += "&" + buildUrlParam("User_Code", "oncal:settings/"+gCurrentNode+"/usercode");
ajaxGet( url, cb_GetResponse)
}
function cb_GetResponse(xhr) {
var response = json(xhr.responseText || "null");
if ( !response ) {
setTimeout( SendRequest, 2500);
} else {
if ( response.Verification_Url != "" && response.User_Code != "") {
g_szVerificationUrl = response.Verification_Url;
g_szUserCode = response.User_Code;
jxl.setText( "uiVerifikationUrl", response.Verification_Url);
jxl.setText( "uiUserCode", response.User_Code);
jxl.display( "uiWait", false);
jxl.display( "uiShowVerifyData", true);
setTimeout( SendRequest2, 20000);
g_reg_counter = 0;
} else {
if ((response.LastState == "2") && ( g_reg_counter <= 100)) {
g_reg_counter++;
setTimeout( SendRequest, 2500);
} else {
g_VerificationSuccessful = false;
ComplettCalVerification(false, String(response.LastState));
}
}
}
}
function SendRequest2( szValue) {
var url = encodeURI("/query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam("LastState", "oncal:settings/"+gCurrentNode+"/laststatus");
url += "&" + buildUrlParam("RefreshToken", "oncal:settings/"+gCurrentNode+"/rtok");
ajaxGet( url, cb_GetResponse2)
}
function cb_GetResponse2(xhr) {
var response = json(xhr.responseText || "null");
if (!response ) {
setTimeout( SendRequest2, 2500);
} else {
if ((response.LastState == "0") && ( response.RefreshToken != "")) {
g_VerificationSuccessful = true;
ComplettCalVerification( g_VerificationSuccessful,String(response.LastState));
} else {
if ((response.LastState == "2") && ( g_reg_counter <= 100)) {
setTimeout( SendRequest2, 2500);
g_reg_counter++;
} else{
g_VerificationSuccessful = false;
ComplettCalVerification( false, String(response.LastState));
}
}
}
}
function ComplettCalVerification( bSuccessful, szErrorCode) {
g_Last_Auth_State = szErrorCode;
var url = encodeURI("/net/home_auto_query.lua");
var szData = sidParam;
if ( bSuccessful) {
szData += "&" + buildUrlParam( "command", "SetTimerCalendar");
szData += "&" + buildUrlParam( "id", jxl.getValue( "uiCurrentUle"));
szData += "&" + buildUrlParam( "ResetTimer", gLastTimer);
szData += "&" + buildUrlParam( "Calname", gCurrentCalname);
szData += "&" + buildUrlParam( "OncalNode", gCurrentNode);
} else {
szData += "&" + buildUrlParam( "command", "ResetTimerCalendar");
szData += "&" + buildUrlParam( "id", jxl.getValue( "uiCurrentUle"));
szData += "&" + buildUrlParam( "ResetTimer", gLastTimer);
szData += "&" + buildUrlParam( "OncalNode", gCurrentNode);
}
ajaxPost( url, szData, cb_Finish)
}
function cb_Finish(xhr) {
var response = json(xhr.responseText || "null");
if (!response ) {
complettCalVerication( g_VerificationSuccessful);
} else {
if ( response.RequestResult == "1") {
if ( g_VerificationSuccessful) {
jxl.display( "uiWait", false);
jxl.display( "uiShowVerifyData", false);
jxl.display( "uiDone", true);
jxl.display( "uiApply", true);
} else {
jxl.display( "uiWait", false);
jxl.display( "uiShowVerifyData", false);
var szErrTextToShow = GetttingErrText( g_Last_Auth_State);
jxl.setHtml( "uiShow_AuthErrorText", szErrTextToShow);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
} else {
jxl.display( "uiWait", false);
jxl.display( "uiShowVerifyData", false);
var szErrTextToShow = GetttingErrText( g_Last_Auth_State);
jxl.setHtml( "uiShow_AuthErrorText", szErrTextToShow);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
}
}
function GetttingErrText( szErrCode) {
var szRetCode = "{?9648:448?}"+szErrCode+"{?9648:560?}";
switch( szErrCode) {
case "1":
szRetCode = "{?9648:543?}";
break;
case "2":
szRetCode = "{?9648:403?}";
break;
case "11":
szRetCode = "{?9648:445?}";
break;
case "10":
szRetCode = "{?9648:684?}";
break;
case "8":
case "12":
szRetCode = "{?9648:789?}";
break;
case "16":
case "17":
case "18":
case "19":
case "20":
case "21":
case "22":
szRetCode = "{?9648:149?}"+szErrCode+"{?9648:231?}";
break;
}
return szRetCode;
}
function onClick_VerifyUrl() {
var url = g_szVerificationUrl;
if ( url) {
var opts = "width=500,height=400,resizable=yes,scrollbars=yes,location=no";
var ppWindow = window.open(url, "Google_Fenster", opts);
if ( ppWindow) {
ppWindow.focus();
}
}
}
function onEditDevSubmit() {
}
function init() {
setTimeout( SendRequest, 10000);
jxl.display( "uiApply", false);
jxl.display( "uiCancel", false);
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
