<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_intercom.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
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
g_ctlmgr = {}
function get_var()
g_ctlmgr.idx = ""
if box.post.idx and box.post.idx ~= "" then
g_ctlmgr.idx = box.post.idx
elseif box.get.idx and box.get.idx ~= "" then
g_ctlmgr.idx = box.get.idx
end
g_ctlmgr.name = box.query("telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/Name")
g_ctlmgr.outdialing = box.query("telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/OutDialing")
if g_ctlmgr.idx == "" or g_ctlmgr.name == "" or g_ctlmgr.outdialing ~= "2" then
http.redirect(href.get(g_back_to_page))
end
g_page_title = general.sprintf([[{?2614:654?}]], g_ctlmgr.name)
end
get_var()
g_val = {
prog = [[
not_empty(uiName/name, name_error)
]]
}
for i = 0, 3, 1 do
g_val.prog = g_val.prog..[[
is_num_in_enh(Id_Num_Org]]..i..[[/Num_Org]]..i..[[, num_err)
if __value_equal(id_Signal]]..i..[[/Signal]]..i..[[, outNum) then
is_num_in_enh(Id_Num_Rep]]..i..[[/Num_Rep]]..i..[[, num_err)
end
]]
end
local name_err = [[{?2614:921?}]]
val.msg.name_error = {
[val.ret.notfound] = name_err,
[val.ret.empty] = name_err
}
val.msg.num_err = {
[val.ret.notfound] = [[{?2614:636?}]],
[val.ret.empty] = [[{?2614:812?}]],
[val.ret.format] = [[{?2614:641?}]]
}
if next(box.post) then
if box.post.button_save and val.validate(g_val) == val.ret.ok then
local saveset = {}
for i = 0, 3, 1 do
local rep = box.post["Signal"..i]
if box.post["Signal"..i] == "outNum" then
rep = box.post["Num_Rep"..i]
end
cmtable.add_var(saveset, "telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/DoorlineNumOriginal"..i, box.post["Num_Org"..i])
cmtable.add_var(saveset, "telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/DoorlineNumReplace"..i, rep)
end
cmtable.add_var(saveset, "telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/Name", box.post.name)
cmtable.add_var(saveset, "telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/Name", box.post.name)
local err, msg = box.set_config(saveset)
if err == 0 then
http.redirect(href.get(g_back_to_page))
else
box.out(general.create_error_div(err,msg))
end
get_var()
elseif box.post.button_cancel then
http.redirect(href.get(g_back_to_page))
end
end
function write_name()
box.out([[<div class="formular">]])
box.out(fon_devices_html.get_ipphone_name(g_ctlmgr))
box.out([[</div>]])
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
<?lua
require("val")
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
require("val")
val.write_js_checks(g_val)
?>
return true;
}
function onSignalChange(elem, replaceInput){
var value = jxl.getValue(elem);
if (value == "outNum"){
jxl.show(replaceInput);
}
else {
jxl.hide(replaceInput);
}
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "button_save", "uiMainForm" ));
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?2614:442?}</p>
<?lua write_name() ?>
<table class='zebra'>
<tr>
<th class="width">{?2614:961?}</th>
<th class="width">{?2614:200?}</th>
<th>{?2614:472?}</th>
</tr>
<?lua
for i = 0, 3, 1 do
local num_org = box.query("telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/DoorlineNumOriginal"..i)
local num_rep = box.query("telcfg:settings/MSN/Port"..g_ctlmgr.idx.."/DoorlineNumReplace"..i)
box.out(fon_devices_html.get_doorline_bell(i, num_org, num_rep))
end
?>
</table>
<div id="btn_form_foot">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
<input type="hidden" name="idx" value="<?lua box.html(g_ctlmgr.idx) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
