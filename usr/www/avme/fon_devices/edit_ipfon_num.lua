<?lua
g_page_type = "all"
g_page_title = [[{?616:693?}]]
g_page_help = "hilfe_fon_ipphone.html"
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
not_empty(uiName/name,error_txt)
if __value_equal(uiOutNum/out_num, tochoose) then
const_error(uiOutNum/out_num, wrong, out_selection_call_to)
end
]]
}
val.msg.out_selection_call_to = {
[val.ret.wrong] = [[{?616:256?}]]
}
val.msg.error_txt = {
[val.ret.empty] = [[{?616:736?}]],
[val.ret.toolong] = [[{?616:953?}]]
}
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
g_data.cur_ipphone = fon_devices.get_ipphone(g_data.ip_idx)
if not g_data.cur_ipphone then
redirect_back()
end
g_data.cnt_nums=fon_numbers.get_number_count("all")
end
read_data()
g_local_tabs = fon_devices_html.get_ipfon_tabs(g_data.ip_idx, {back_to_page=g_back_to_page,popup_url=popup_url})
if(next(box.post)) then
if box.post.btn_cancel then
redirect_back()
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
local number=""
local out_num_checked=false
cmtable.add_var(ctlmgr_save, "telcfg:settings/VoipExtension"..box.post.ip_idx.."/Name", box.post.name)
if (box.post.num_selection=="all_nums") then
cmtable.add_var(ctlmgr_save, "telcfg:settings/VoipExtension"..box.post.ip_idx.."/RingOnAllMSNs","1")
for i=1,9,1 do
local number=g_data.cur_ipphone.incoming[i] or ""
if (number==box.post.out_num) then
out_num_checked=true
end
end
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/VoipExtension"..box.post.ip_idx.."/RingOnAllMSNs","0")
local save_pos = 1
for i=1,g_data.cnt_nums,1 do
local number=box.post["num_"..tostring(i)] or ""
if number~="" then
if (number~=box.post.out_num) then
cmtable.add_var(ctlmgr_save,"telcfg:settings/VoipExtension"..box.post.ip_idx.."/Number"..tostring(save_pos),number)
save_pos = save_pos + 1
if save_pos>9 then
break
end
else
out_num_checked=true
end
end
end
for j=save_pos,9,1 do
cmtable.add_var(ctlmgr_save,"telcfg:settings/VoipExtension"..box.post.ip_idx.."/Number"..tostring(j), "")
end
end
number=box.post.out_num
if not out_num_checked then
number=number.."#"
end
cmtable.add_var(ctlmgr_save,"telcfg:settings/VoipExtension"..box.post.ip_idx.."/Number0",number)
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
box.out(fon_devices_html.get_ipphone_name(g_data.cur_ipphone))
end
function write_numbers_out()
box.out(fon_devices_html.get_outgoing_numbers(g_data.cur_ipphone.outgoing))
end
function write_numbers_in()
box.out(fon_devices_html.get_avail_numbers(g_data.cur_ipphone))
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
#uiOptionalNums label{
width:175px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?616:605?}</p>
<div class="formular">
<?lua
write_name()
?>
<h4>{?616:920?}</h4>
<?lua
write_numbers_out()
?>
<h4>{?616:309?}</h4>
<?lua
write_numbers_in()
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
<script type="text/javascript">
var g_all_ids=<?lua box.out(js.table(fon_devices_html.g_numbers))?>;
var g_OutNum="<?lua box.js(fon_devices_html.get_num_by_id(g_data.cur_ipphone.outgoing))?>";
var g_txt_NumForOutCall="{?616:921?}"
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
function GetIndexForCheckBox(num)
{
return "uiNum_"+(GetIndex(num)+1);
}
function GetIndexForSpan(num)
{
return "uiNumInfo_"+(GetIndex(num)+1);
}
function NumWasChecked(ToNum)
{
var idx=GetIndex(ToNum);
if (idx>=0 && idx<g_all_ids.length)
{
return g_all_ids[idx].checked;
}
return false;
}
function OnCheckNum (obj)
{
var idx=GetIndex(obj.value);
if (idx>=0 && idx<g_all_ids.length)
{
g_all_ids[idx].checked=obj.checked;
}
}
function OnChangeTo (ToNum)
{
if (ToNum!=g_OutNum)
{
jxl.setText(GetIndexForSpan(g_OutNum),"");
jxl.setChecked(GetIndexForCheckBox(g_OutNum),NumWasChecked(g_OutNum));
g_OutNum=ToNum;
jxl.setText(GetIndexForSpan(ToNum),g_txt_NumForOutCall);
jxl.setChecked(GetIndexForCheckBox(ToNum),true);
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
fon_devices_html.write_sel_handler()
?>
</script>
<?include "templates/html_end.html" ?>
