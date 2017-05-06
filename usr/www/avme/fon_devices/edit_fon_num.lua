<?lua
g_page_type = "all"
g_page_help = "hilfe_fon_nebenstelle.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("js")
require("newval")
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
local phondata = fon_devices.get_fon123_phonedata(tostring(g_data.id))
g_data.cur_123phon = fon_devices.get_fon123_ring_data("Port"..tostring(g_data.id))
if not phondata then
redirect_back()
end
table.insert(g_data.cur_123phon, phondata)
end
read_data()
g_page_title = [[{?549:986?} ]]..g_data.cur_123phon[1].portname
g_local_tabs = fon_devices_html.get_fon_tabs(g_data.id, {back_to_page=g_back_to_page, popup_url=popup_url})
g_typename = ""
if g_data.cur_123phon[1].type == "fax" then
g_typename = [[{?549:66?}]]
elseif g_data.cur_123phon[1].type == "fon" then
g_typename = [[{?549:173?}]]
elseif g_data.cur_123phon[1].type == "tam" then
g_typename = [[{?549:203?}]]
end
local function val_prog()
newval.msg.out_selection_call_to = {
[newval.ret.wrong] = [[{?549:721?}]]
}
newval.msg.error_txt = {
[newval.ret.empty] = [[{?549:97?}]],
[newval.ret.toolong] = [[{?549:319?}]]
}
newval.msg.double_name = {
[newval.ret.wrong] = [[{?549:608?}]]
}
newval.not_empty("name","error_txt")
newval.length("name",1,30,"error_txt")
if newval.value_equal("out_num","tochoose") then
newval.const_error("out_num", "wrong", "out_selection_call_to")
end
local orig_name = g_data.cur_123phon[1].name or ""
if orig_name ~= box.post.name and fon_devices.exist_fon_device_name(box.post.name) then
newval.const_error("name", "wrong", "double_name")
end
end
if next(box.post) then
if box.post.validate == "button_save" then
require"js"
local valresult, answer = newval.validate(val_prog)
box.out(js.table(answer))
box.end_page()
elseif next(box.post) and box.post.button_save then
if newval.validate(val_prog) == newval.ret.ok then
local result = newval.validate(g_val)
if result == newval.ret.ok then
local ctlmgr_save={}
ctlmgr_save = fon_devices_html.get_num_save_data(g_data.cur_123phon[1])
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg =general.create_error_div(err,msg)
else
redirect_back()
end
end
end
elseif box.post.button_cancel then
redirect_back()
end
end
function write_name()
box.out(fon_devices_html.get_fon123_name(g_data.cur_123phon[1]))
end
function write_numbers_out()
box.out(fon_devices_html.get_outgoing_numbers(g_data.cur_123phon[1].outgoing))
end
function write_numbers_in()
box.out(fon_devices_html.get_avail_numbers(g_data.cur_123phon[1]))
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
<p>{?549:746?}</p>
<hr>
<div class="formular">
<h4><?lua box.out(g_typename) ?>{?549:145?} <?lua box.html(g_data.cur_123phon[1].portname) ?></h4>
<?lua
write_name()
?>
<h4>{?549:599?}</h4>
<?lua
write_numbers_out()
?>
<h4>{?549:907?}</h4>
<?lua
write_numbers_in()
?>
</div>
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
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var g_all_ids=<?lua box.out(js.table(fon_devices_html.g_numbers))?>
<?lua box.out(fon_devices_html.write_fon_js(fon_devices_html.get_num_by_id(g_data.cur_123phon[1].outgoing))) ?>
ready.onReady(ajaxValidation({
applyNames: "button_save"
}));
</script>
<?include "templates/html_end.html" ?>
