<?lua
g_page_type = "all"
g_page_title = "{?2703:331?}"
g_page_help = 'hilfe_fon_faxintern_1.html'
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("fon_devices")
require("fon_numbers")
require("fon_devices_html")
require("config")
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
g_local_tabs = fon_devices_html.get_fax_tabs({back_to_page=g_back_to_page,popup_url=popup_url})
g_data={}
g_errmsg=[[]]
function read_data()
local faxdevices=fon_devices.read_fax_intern()
g_data.cur_elem=faxdevices[1]
if not g_data.cur_elem then
redirect_back()
end
g_data.cnt_nums=fon_numbers.get_number_count("all")
g_data.fax_switch=(box.query("telcfg:settings/FaxSwitch")=="1")
end
read_data()
g_val = {
prog = [[
]]
}
function is_visible(block_id)
if (block_id=='explain_pots') or (block_id=='fax_switch') then
if not(fon_numbers.use_PSTN()=="1" and fon_numbers.is_pots_configured())then
return false
end
end
return true
end
if next(box.post) then
if (box.post.apply) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
require("cmtable")
local saveset={}
local save_pos = 0
for i=1,g_data.cnt_nums,1 do
local number=box.post["num_"..tostring(i)] or ""
if number ~= "" then
cmtable.add_var(saveset,"telcfg:settings/FaxMSN"..tostring(save_pos),number)
save_pos = save_pos + 1
end
if save_pos>9 then
break
end
end
for j=save_pos,9,1 do
cmtable.add_var(saveset,"telcfg:settings/FaxMSN"..tostring(j), "")
end
if (is_visible('fax_switch')) then
cmtable.save_checkbox(saveset,"telcfg:settings/FaxSwitch","fax_switch")
end
local err, msg = box.set_config( saveset)
if err == 0 then
redirect_back()
else
g_errmsg=general.create_error_div(err,msg)
end
end
elseif box.post.button_cancel then
redirect_back()
end
end
function write_visible(block_id)
if (not is_visible(block_id)) then
box.out([[display:none;]])
end
end
function write_nums()
local str=fon_devices_html.get_avail_numbers_fax(g_data.cur_elem)
box.out(str)
end
function write_checked()
if g_data.fax_switch then
box.out([[checked]])
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
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div >{?2703:321?}</div>
<div style="<?lua write_visible('explain_pots')?>">
<p>{?2703:205?}</p>
<p>{?2703:392?}</p>
<p>{?2703:860?}</p>
</div>
<div class="formular">
<div style="<?lua write_visible('fax_switch')?>" >
<p><input type="checkbox" id="uiViewFaxSwitch" name="fax_switch" onclick="OnFaxSwitch(this.checked)" <?lua write_checked()?>><label for="uiViewFaxSwitch"><?lua box.html(general.sprintf([[{?2703:241?}]], fon_numbers.get_pots_number()))?></label></p>
</div>
<div class="formular">
<?lua
write_nums()
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="apply">{?txtOK?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
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
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_is_pots_configured=<?lua box.out(tostring(fon_numbers.is_pots_configured()))?>;
var g_old_pots_state =<?lua box.out(tostring(fon_devices_html.is_pots_configured_fax()))?>;
var g_all_ids=<?lua box.out(js.table(fon_devices_html.g_numbers))?>;
var g_is_fax_switch=<?lua box.out(tostring(g_data.fax_switch))?>;
var g_checked_nums=<?lua box.out(tostring(fon_devices_html.g_count_checked))?>;
function GetPotsId()
{
for (var i=0;i<g_all_ids.length;i++)
{
if (g_all_ids[i].type=="pots")
{
return g_all_ids[i].id;
}
}
return "";
}
function OnFaxSwitch(is_checked)
{
if (!g_is_pots_configured)
return;
var PotsId=GetPotsId()
jxl.setDisabled(PotsId,is_checked);
if (is_checked)
{
jxl.setChecked(PotsId,false);
}
else
{
jxl.setChecked(PotsId,g_old_pots_state);
}
}
function OnCheckNum(obj)
{
if (obj.checked)
{
if (g_checked_nums>=9){
alert("{?2703:333?}");
return false;
}
g_checked_nums++;
var msg="{?2703:189?}";
if (!confirm(msg))
return false;
}
else
{
g_checked_nums--;
}
return true;
}
function init()
{
if (g_is_pots_configured)
{
var PotsId=GetPotsId()
if (g_is_fax_switch)
{
jxl.setChecked(PotsId,false);
}
jxl.setDisabled(PotsId,g_is_fax_switch);
}
}
function isAnyNumConfigured()
{
if (!g_all_ids.length)
return true;
for (var i=0;i<g_all_ids.length;i++)
{
var obj=jxl.get(g_all_ids[i].id);
if (!obj){
continue;
}
if (obj.checked){
return true;
}
}
return false;
}
function onNumEditSubmit()
{
if (val.active) val.active=false; else return true;
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
