<?lua
g_page_type = "all"
g_page_title = [[{?7670:508?}]]
g_page_help = "hilfe_fon_ipphone_anmeldedaten.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_devices/fondevices_list.lua" )
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assis")) then
g_page_type ="wizard"
end
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
function redirect_back()
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
end
g_data={}
function read_data()
g_data.ip_idx=nil
if (next(box.get)) then
g_data.ip_idx=tonumber(box.get["ip_idx"])
elseif(next(box.post)) then
g_data.ip_idx=tonumber(box.post["ip_idx"])
end
if not g_data.ip_idx or not config.FON_IPPHONE then
redirect_back()
end
g_data.cur_ipphone=fon_devices.get_ipphone(g_data.ip_idx)
if not g_data.cur_ipphone then
redirect_back()
end
end
read_data()
g_local_tabs = fon_devices_html.get_ipfon_tabs(g_data.ip_idx, {back_to_page=g_back_to_page,popup_url=popup_url})
g_val = {
prog = [[]]
}
if g_data.cur_ipphone.clientid == "" then
g_val = {
prog = [[
not_empty(uiPassword/password,error_txt)
length(uiPassword/password,1,32,error_txt)
]]
}
end
val.msg.error_txt = {
[val.ret.empty] = [[{?7670:252?}]],
[val.ret.toolong] = [[{?7670:874?}]]
}
if(next(box.post)) then
if box.post.btn_cancel then
redirect_back()
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if box.post.password~="****" then
cmtable.add_var(ctlmgr_save, "voipextension:settings/extension"..box.post.ip_idx.."/passwd", box.post.password)
end
cmtable.save_checkbox(ctlmgr_save, "voipextension:settings/extension"..box.post.ip_idx.."/reg_from_outside", "from_inet")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
redirect_back()
end
end
end
end
function write_register_data()
box.out(fon_devices_html.get_other_options(g_data.cur_ipphone))
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
if g_data.cur_ipphone.clientid == "" then
box.out([[<p>{?7670:996?}</p>]])
else
box.out([[<p>{?7670:209?}</p>]])
end
?>
<div class="formular">
<?lua
write_register_data()
?>
</div>
<div id="btn_form_foot">
<input type="hidden" value="<?lua box.html(g_data.ip_idx)?>" name="ip_idx">
<input type="hidden" value="<?lua box.html(g_back_to_page)?>" name="back_to_page">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="btn_save" id="buttonSave">{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" id="buttonCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
var g_Warning = "{?7670:372?}";
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
if (jxl.getChecked("uiFromInet"))
{
if (!confirm(g_Warning))
{
return false;
}
}
}
function init()
{
createPasswordChecker( "uiPassword" );
}
ready.onReady(val.init(onNumEditSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
