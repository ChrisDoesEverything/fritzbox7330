<?lua
g_page_type = "all"
g_page_help = "hilfe_fon_klingelsperre.html"
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
g_data = {}
function read_data()
g_data.id = nil
if (next(box.get)) then
g_data.id = tonumber(box.get["idx"])
elseif(next(box.post)) then
g_data.id = tonumber(box.post["idx"])
end
if not g_data.id then
redirect_back()
end
g_data.cur_123phon = fon_devices.get_fon123_ring_data("Port"..tostring(g_data.id))
if not g_data.cur_123phon then
redirect_back()
end
table.insert(g_data.cur_123phon, fon_devices.get_fon123_phonedata(tostring(g_data.id)))
end
read_data()
g_page_title = [[{?717:101?} ]]..g_data.cur_123phon[1].portname
g_local_tabs = fon_devices_html.get_fon_tabs(g_data.id, {back_to_page=g_back_to_page, popup_url=popup_url})
g_StartTime_Msg, g_EndTime_Msg, g_StartTime_Attributs, g_EndTime_Attributs = "", "", "", ""
g_val_block = fon_devices_html.get_ring_block_validation()
val.msg = fon_devices_html.get_ring_block_validation_msg()
if next(box.post) then
if box.post.button_cancel then
redirect_back()
elseif box.post.button_save then
local result = val.validate(g_val_block)
if result == val.ret.ok then
ctlmgr_save = fon_devices_html.get_save_block_data([[telcfg:settings/MSN/Port]]..box.post.idx)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg =general.create_error_div(err,msg)
else
redirect_back()
end
else
g_StartTime_Msg = val.get_html_msg(g_val_block, "uiStartHH")
g_EndTime_Msg = val.get_html_msg(g_val_block, "uiEndHH")
g_StartTime_Attributs = val.get_attrs(g_val_block, "uiStartHH")
g_EndTime_Attributs = val.get_attrs(g_val_block, "uiEndHH")
end
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
<?lua
box.out(fon_devices_html.get_block_html(g_data.cur_123phon))
?>
<?lua
if g_errormsg ~= nil then
box.out(g_errormsg)
end
?>
<div id="btn_form_foot">
<input type="hidden" value="<?lua box.html(g_back_to_page)?>" name="back_to_page">
<input type="hidden" name="idx" value="<?lua box.html(g_data.id) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel" >{?txtCancel?}</button>
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
val.write_js_checks(g_val_block)
?>
}
function init()
{
jxl.disableNode('uiRingDiv',!jxl.getChecked("uiMyLocking"));
}
ready.onReady(init);
ready.onReady(val.init(onNumEditSubmit, "button_save", "main_form" ));
</script>
<?include "templates/html_end.html" ?>
