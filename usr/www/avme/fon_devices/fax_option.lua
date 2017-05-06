<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("fon_numbers")
require("menu")
require("cmtable")
if not menu.check_page("fon", "/fon_devices/fax_option.lua") then
require"http"
http.redirect("/home/home.lua")
end
g_val = {
prog = [[
not_empty(uiViewHeadline/headline, error_txt_head)
length(uiViewHeadline/headline,1,20,error_txt_head)
not_empty(uiViewHeadline_from/from_headline, error_txt_headline)
length(uiViewHeadline_from/from_headline,1,40,error_txt_headline)
not_empty(uiView_from_name/from_name, error_txt_name)
length(uiView_from_name/from_name,1,200,error_txt_name)
]]
}
val.msg.error_txt_name = {
[val.ret.empty] = [[{?7798:975?}]],
[val.ret.toolong] = [[{?7798:838?}]]
}
val.msg.error_txt_head = {
[val.ret.empty] = [[{?7798:166?}]],
[val.ret.toolong] = [[{?7798:766?}]]
}
val.msg.error_txt_headline = {
[val.ret.empty] = [[{?7798:375?}]],
[val.ret.toolong] = [[{?7798:571?}]]
}
g_data={}
function get_var()
g_data.fax_number=""
g_data.headline=box.query([[telcfg:settings/FaxKennung]])
g_data.mailaddr=box.query([[telcfg:settings/FaxMailAddress0]])
g_data.from_headline=box.query([[telcfg:settings/FaxSenderShort]])
if g_data.from_headline=="" then
g_data.from_headline=[[{?7798:984?}]]
end
g_data.from_name=box.query([[telcfg:settings/FaxSenderLong]])
g_data.active=box.query([[telcfg:settings/FaxMailActive]])
g_data.fax_receive=g_data.active~="0" and g_data.active~=""
g_data.fax_send=g_data.fax_receive
g_data.fax_send_email=g_data.active=="1" or g_data.active=="3" or g_data.active=="5"
g_data.fax_save_usb=(g_data.active=="2" or g_data.active=="3")
g_data.aura_used=config.AURA and (box.query("aura:settings/aura4storage") == "1") and (box.query("aura:settings/enabled") == "1")
g_data.fax_save_intern=g_data.active=="4" or g_data.active=="5"
g_data.save_possible=true
require("fon_devices_html")
g_data.path=[[]]
if g_data.fax_save_intern then
g_data.path=[[{?7798:763?}]]
elseif g_data.fax_save_usb then
g_data.path=fon_devices_html.get_save_path()
end
g_data.info1=""
g_data.info2=""
g_data.callback=""
g_data.pots=fon_numbers.get_pots()
g_data.msnlist=fon_numbers.get_msn()
g_data.siplist=fon_numbers.get_sip_num()
end
get_var()
if next(box.post) then
if box.post.btn_cancel then
http.redirect(href.get('/fon_devices/fax_option.lua'))
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxKennung",box.post.headline)
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxSenderLong",box.post.from_name)
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxSenderShort",box.post.from_headline)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
http.redirect(href.get('/fon_devices/fax_option.lua'))
end
get_var()
end
end
end
function get_numbers(num_to_select,restriction)
local str=""
local list=fon_numbers.get_list_of_numbers(g_data,restriction)
if list then
str=str..[[<option value="tochoose">{?txtPleaseSelect?}</option>]]
for i,elem in ipairs(list) do
str=str..[[<option value="]]..elem.val..[["]]
if (num_to_select==elem.val) then
str=str..[[ selected ]]
end
str=str..[[>]]..box.tohtml(elem.key)..[[</option>]]
end
end
return str
end
function write_nums(num)
local str=get_numbers(num,'all_nums')
box.out(str)
end
function write_active(checkbox)
local is_checked=false
if (checkbox=="receive") then
is_checked=g_data.fax_receive
elseif (checkbox=="send") then
is_checked=g_data.fax_send
elseif (checkbox=="email") then
is_checked=g_data.fax_send_email
elseif (checkbox=="usb") then
is_checked=g_data.save_possible and ((g_data.fax_save_usb and not g_data.aura_used) or g_data.fax_save_intern)
end
if (is_checked) then
box.out([[ checked ]])
end
end
function write_faxblock(is_warning)
if (is_warning==0 and g_data.fax_receive) then
box.out([[display:none;]])
elseif (is_warning==1 and not g_data.fax_receive) then
box.out([[display:none;]])
end
end
function get_link_to_edit_page()
return href.get("/fon_devices/edit_fax_num.lua","back_to_page=/fon_devices/fax_option.lua")
end
function get_link_to_edit_option_page()
return href.get("/fon_devices/edit_fax_option.lua","back_to_page=/fon_devices/fax_option.lua")
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
<style type="text/css">
.row {
padding-top:5px;
padding-bottom:5px;
}
.left {
float:left;
}
.right {
float:right;
}
.left_and_right {
clear:both;
}
.formular select {
width:235px;
}
.formular input,textarea {
width:230px;
}
.formular textarea {
font-family:"MS Shell Dlg";
font-size:13px;
}
.formular label.top {
vertical-align:top;
}
.formular .large label {
width:180px;
}
.formular input[type="checkbox"] {
width:auto;
}
.ShowPath {
width:400px;
color:#888888;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?7798:601?}</p>
<hr>
<div class="formular" style="<?lua write_faxblock(0)?>" >
<p>
<?lua
--local dest=href.get([[/fon/fondevices.lua]])
local dest=href.get([[/assis/assi_fax_intern.lua]],[[New_DeviceTyp=IntFax]],[[HTMLConfigAssiTyp=FonOnly]],[[Submit_Next=]],[[FonAssiFromPage=fax_option]])
box.out(general.sprintf([[{?7798:986?}]],[[<a href="]]..dest..[[">]],[[</a>]]))
?>
</p>
</div>
<div style="<?lua write_faxblock(1)?>" >
<div class="formular">
<label for="uiViewHeadline">{?7798:646?}</label>
<input type="text" size="30" maxlength="40" id="uiViewHeadline" name="headline" value="<?lua box.html(g_data.headline) ?>" <?lua val.write_attrs(g_val, "uiViewHeadline") ?>>
<?lua val.write_html_msg(g_val, "uiViewHeadline") ?>
<br>
<label for="uiViewHeadline_from">{?7798:140?}</label>
<input type="text" size="30" maxlength="40" id="uiViewHeadline_from" name="from_headline" value="<?lua box.html(g_data.from_headline) ?>" <?lua val.write_attrs(g_val, "uiViewHeadline_from") ?>>
<?lua val.write_html_msg(g_val, "uiViewHeadline_from") ?>
<br>
<label class="top" for="uiView_from_name">{?7798:109?}</label>
<textarea cols="22" rows="3" maxlength="200" id="uiView_from_name" name="from_name" <?lua val.write_attrs(g_val, "uiView_from_name") ?>><?lua box.out(g_data.from_name) ?></textarea>
<?lua val.write_html_msg(g_val, "uiView_from_name") ?>
</div>
<hr>
<div class="formular">
<h4>{?7798:370?}</h4>
<p>
<?lua
box.out(general.sprintf([[{?7798:943?}]],[[<a href="]]..get_link_to_edit_page()..[[">]],[[</a>]]))
?>
</p>
<div class="large">
<input type="checkbox" id="uiFaxSendEmail" name="fax_send_email" <?lua write_active('email')?> disabled>&nbsp;<label for="uiFaxSendEmail">{?7798:365?}</label>
<span class="ShowPath"><?lua box.html(g_data.mailaddr)?></span>
<?lua
box.out(general.sprintf([[{?7798:8?}]],[[<a href="]]..get_link_to_edit_option_page()..[[">]],[[</a>]]))
?>
</div>
<div class="large">
<input type="checkbox" id="uiFaxSaveUsb" name="fax_save_usb" <?lua write_active('usb')?> disabled>&nbsp;<label for="uiFaxSaveUsb">{?7798:502?}</label>
<span class="ShowPath"><?lua box.html(g_data.path)?></span>
<?lua
box.out(general.sprintf([[{?7798:719?}]],[[<a href="]]..get_link_to_edit_option_page()..[[">]],[[</a>]]))
?>
</div>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
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
jxl.disable("uiFaxSendEmail");
jxl.disable("uiFaxSaveUsb")
}
ready.onReady(val.init(onNumEditSubmit, "btnSave", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
