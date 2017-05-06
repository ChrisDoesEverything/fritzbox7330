<?lua
g_page_type = "all"
g_page_help = "hilfe_fon_klingelsperre.html"
dofile("../templates/global_lua.lua")
require("bit")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("http")
g_back_to_page = http.get_back_to_page( "/dect/dect_list.lua")
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assi")) then
g_page_type = "wizard"
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
g_ctlmgr = {}
function get_var()
g_ctlmgr.idx = ""
if box.post.idx and box.post.idx ~= "" then
g_ctlmgr.idx = box.post.idx
elseif box.get.idx and box.get.idx ~= "" then
g_ctlmgr.idx = box.get.idx
end
if g_ctlmgr.idx=="" then
redirect_back()
end
g_ctlmgr.name = box.query('telcfg:settings/Foncontrol/User'..g_ctlmgr.idx..'/Name')
g_ctlmgr.data = fon_devices.get_dect_ring_data(g_ctlmgr.idx)
g_page_title = [[{?6254:242?} ]]..g_ctlmgr.name
end
get_var()
g_local_tabs = fon_devices_html.get_edit_dect_tabs(g_ctlmgr.idx, {back_to_page=g_back_to_page, popup_url=popup_url})
g_StartTime_Msg, g_EndTime_Msg, g_StartTime_Attributs, g_EndTime_Attributs = "", "", "", ""
g_val = fon_devices_html.get_ring_block_validation()
val.msg = fon_devices_html.get_ring_block_validation_msg()
if next(box.post) then
if box.post.button_save then
local result = val.validate(g_val)
if result == val.ret.ok then
local saveset = fon_devices_html.get_save_block_data("telcfg:settings/Foncontrol/User"..box.post.idx)
local flags=tonumber(box.query([[telcfg:settings/Foncontrol/User]]..box.post.idx..[[/NoRingTimeFlags]])) or 0
if (box.post.event) then
flags=bit.set(flags, 2)
else
flags=bit.clr(flags, 2)
end
cmtable.add_var(saveset, [[telcfg:settings/Foncontrol/User]]..box.post.idx..[[/NoRingTimeFlags]], flags)
local err, msg = box.set_config(saveset)
if err == 0 then
redirect_back()
else
g_errmsg=general.create_error_div(err,msg)
end
else
g_StartTime_Msg = val.get_html_msg(g_val, "uiStartHH")
g_EndTime_Msg = val.get_html_msg(g_val, "uiEndHH")
g_StartTime_Attributs = val.get_attrs(g_val, "uiStartHH")
g_EndTime_Attributs = val.get_attrs(g_val, "uiEndHH")
end
elseif box.post.button_cancel then
redirect_back()
end
if (g_errmsg~="") then
get_var()
end
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
<?lua box.out(fon_devices_html.get_block_html(g_ctlmgr.data)) ?>
<div class="formular">
<input type="checkbox" id="uiEvent" name="event" <?lua box.out(fon_devices_html.is_checked(bit.isset(g_ctlmgr.data.flags,2))) ?> >
<label for="uiEvent">{?6254:548?}</label>
<div class="form_checkbox_explain">
{?6254:615?}
</div>
</div>
<div class="WarnMsg" >
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
<input type="hidden" name="idx" value="<?lua box.out(g_ctlmgr.idx) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
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
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
function init()
{
jxl.disableNode('uiRingDiv',!jxl.getChecked("uiMyLocking"));
}
ready.onReady(val.init(onNumEditSubmit, "button_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
