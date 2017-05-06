<?lua
g_page_type = "all"
g_page_title = [[{?6255:450?}]]
g_page_help = "hilfe_wlan_sicherheit_wps.html"
g_menu_active_page = "/wlan/wps.lua"
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("config")
require("net_devices")
require("cmtable")
require("href")
g_back_to_page = http.get_back_to_page( "/wlan/wps.lua" )
g_menu_active_page = g_back_to_page
function retranslateWpsMode(mode)
mode = tonumber(mode) or 0;
return mode
end
function get_mode_as_str(mode)
return tostring(retranslateWpsMode(mode))
end
if next(box.post) and (box.post.cancel or box.post.next) then
if box.post.cancel then
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/wps_mode", get_mode_as_str(1))
local err, msg = box.set_config(saveset)
end
http.redirect(href.get(g_back_to_page))
end
local g_PicturePath_Success = "/css/default/images/finished_ok_green.gif"
local g_PicturePath_Failed = "/css/default/images/finished_error.gif"
local g_PicturePath_Wait = "/css/default/images/wait.gif"
g_testresult="0"
g_wpsmode=""
g_wpspin=""
if (box.get and box.get.wpsmode) then
g_wpsmode=box.get.wpsmode
if (box.get.wpspin~="nil") then
g_wpspin=box.tohtml(box.get.wpspin)
end
end
function read_box_values()
end
function refill_user_input()
end
g_errmsg = nil
if (box.get) then
local i=1
local tmpParams={}
for k,v in pairs(box.get) do
if (k~="sid") then
tmpParams[i] = k.."="..v
i=i+1
end
end
g_oldparams=table.concat(tmpParams,"&")
end
if next(box.post) and box.post.next then
if val.validate(g_val) == val.ret.ok then
local params = box.post.oldparams..'&result='..g_testresult
target = "/wlan/wps.lua"
local str=href.get(target, params)
http.redirect(str)
return
else
refill_user_input()
end
else
read_box_values()
end
function write_wpsmode_str()
local modestr=[[{?6255:304?}]]
if (g_wpsmode=="pin_intern" or g_wpsmode=="pin_extern") then
modestr=[[{?6255:328?}]]
end
box.out(modestr)
end
function write_wpsmode_explain()
local modestr=""
if (g_wpsmode=="pin_intern") then
modestr=[[{?6255:620?}&nbsp;<span class='CssPin'>]]..g_wpspin..[[</span>]]
elseif (g_wpsmode=="pin_extern") then
modestr=general.sprintf([[{?6255:782?}]],[[<span class='CssPin'>]]..g_wpspin..[[</span>]])
end
box.out(modestr)
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<style type="text/css">
</style>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_QueryVars = {
status: { query: "wlan:settings/wps_pin_status" }
}
var g_AktualTimeout=10000;
function cbState()
{
var g_mld_1 = "{?6255:770?}";
var g_mld_2 = "{?6255:343?}";
var msg="";
var image="";
switch (g_QueryVars.status.value)
{
case "3":
{
msg="{?6255:180?}";
image="success";
break;
}
case "1":
case "5":
{
msg=g_mld_1
image="fail";
break;
}
case "4":
case "7":
{
msg = g_mld_2;
image="fail";
break;
}
}
if (msg!="")
{
jxl.setText("uiView_PinModeState",msg);
if (image=="success")
{
jxl.changeImage("uiImage","/css/default/images/finished_ok_green.gif");
}
else if (image=="fail")
{
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
}
jxl.show("uiNext");
return true;
}
return false;
}
function init()
{
jxl.hide("uiNext");
ajaxWait(g_QueryVars, "<?lua box.js(box.glob.sid) ?>", g_AktualTimeout, cbState);
}
function uiDoOnMainFormSubmit()
{
var ret;
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "next", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div class="formular">
<p id="uiView_PinWaitText"><?lua write_wpsmode_str()?></p>
<p id="uiView_PinWaitRouterMode" ><?lua write_wpsmode_explain()?></p>
<p class="waitimg"><img id="uiImage" src="/css/default/images/wait.gif"></p>
<p id="uiView_PinModeState" >&nbsp;</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="oldparams" value="<?lua box.html(g_oldparams) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="next" id="uiNext">{?txtOk?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
