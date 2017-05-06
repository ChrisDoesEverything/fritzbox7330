<?lua
g_page_type = "all"
g_page_title = [[{?1812:302?}]]
g_page_help = "hilfe_fon_isdn.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("fon_numbers")
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
g_val = {
prog = [[
if __value_equal(uiOutNum/out_num, tochoose) then
const_error(uiOutNum/out_num, wrong, out_selection_call_to)
end
]]
}
val.msg.out_selection_call_to = {
[val.ret.wrong] = [[{?1812:543?}]]
}
g_data={}
function read_data()
g_data.idx=box.get.idx or box.post.idx or 1
if not g_data.idx or not config.CAPI_NT then
redirect_back()
end
local isdn_list = fon_devices.read_nt_hotdiallist(true)
local l, device = fon_devices.find_elem(isdn_list, "nthotdiallist", "idx", tonumber(g_data.idx))
g_data.cur_elem = device
if not g_data.cur_elem or g_data.cur_elem.type == "isdn" then
redirect_back()
end
end
read_data()
g_local_tabs = fon_devices_html.get_isdn_tabs(g_data.cur_elem, {back_to_page=g_back_to_page, popup_url=popup_url})
if(next(box.post)) then
if box.post.btn_cancel then
redirect_back()
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if (g_data.cur_elem.type=="fax") then
local old_num=g_data.cur_elem.number
if old_num~=box.post.out_num then
local old_idx=-1
local num=""
local entry_type=""
for i = 2, 0, -1 do
num=box.query("telcfg:settings/FaxModem"..i.."/Number")
entry_type=box.query("telcfg:settings/FaxModem"..i.."/Type")
if ( entry_type == "0" and num == old_num) then
old_idx=i
break
end
end
if (old_idx==-1) then
old_idx=0
for i = 2, 0, -1 do
num=box.query("telcfg:settings/FaxModem"..i.."/Number")
if ( num == "") then
old_idx=i
break
end
end
end
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxModem"..tostring(old_idx).."/Number", box.post.out_num)
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxModem"..tostring(old_idx).."/Type", "0")
end
end
cmtable.add_var(ctlmgr_save, g_data.cur_elem.number_query, box.post.out_num)
cmtable.add_var(ctlmgr_save, "telcfg:settings/NTHotDialList/Name"..g_data.idx, box.post.name)
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
function write_name()
box.out(fon_devices_html.get_ipphone_name(g_data.cur_elem))
end
function write_numbers_out()
box.out(fon_devices_html.get_outgoing_numbers(g_data.cur_elem.number, g_data.cur_elem.intern_id))
end
function write_numbers_in()
box.out(fon_devices_html.get_avail_numbers(g_data.cur_elem))
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
<div class="formular">
<div>
<label for="uiOutNum">{?1812:765?} </label>
<span><?lua box.html(g_data.cur_elem.intern_id) ?></span>
</div>
<?lua
write_name()
?>
<div class="as_input">
<label for="uiOutNum">{?1812:853?} </label><?lua write_numbers_out()?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" value="<?lua box.html(g_back_to_page)?>" name="back_to_page">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<input type="hidden" value="<?lua box.html(g_data.idx)?>" name="idx">
<button type="submit" name="btn_save" >{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" >{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_all_ids=<?lua box.out(js.table(fon_devices_html.g_numbers))?>;
var g_OutNum="<?lua box.js(g_data.cur_elem.outgoing)?>";
var g_txt_NumForOutCall="{?1812:552?}"
<?lua
val.write_js_error_strings()
?>
function GetIndex(num)
{
for (var i=0;i<g_all_ids.length;i++)
{
if (g_all_ids[i].num==num)
{
return i;
}
}
return 0;
}
function GetIndexForSpan(num)
{
return "uiNumInfo_"+(GetIndex(num)+1);
}
function OnChangeTo (ToNum)
{
if (ToNum!=g_OutNum)
{
jxl.setText(GetIndexForSpan(g_OutNum),"");
g_OutNum=ToNum;
jxl.setText(GetIndexForSpan(ToNum),g_txt_NumForOutCall);
}
}
function init()
{
jxl.setText(GetIndexForSpan(g_OutNum),g_txt_NumForOutCall);
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
ready.onReady(val.init(onNumEditSubmit, "btn_save", "main_form" ));
ready.onReady(init);
<?lua
?>
</script>
<?include "templates/html_end.html" ?>
