<?lua
g_page_type = "all"
g_page_title = "{?932:153?}"
g_page_help = 'hilfe_fon_faxintern_2.html'
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
if not (box.get.notabs or box.post.notabs) then
g_local_tabs = fon_devices_html.get_fax_tabs({back_to_page=g_back_to_page,popup_url=popup_url})
end
g_data={}
g_errmsg=[[]]
function read_data()
require("email_data")
require"pushservice"
local faxdevices=fon_devices.read_fax_intern()
g_data.cur_elem=faxdevices[1]
if (not g_data.cur_elem) then
g_data.cur_elem={}
g_data.cur_elem.mode=""
g_data.cur_elem.incoming={}
g_data.cur_elem.mail_addr={"","","","","","","","","",""}
end
g_data.fax_identifier=box.query("telcfg:settings/FaxKennung")
g_data.usb_disk_missing = box.query([[ctlusb:settings/storage-part/count]]) == "0"
g_data.connection_state= box.query('connection0:status/connect')
g_data.has_time = box.query("box:status/localtime") ~= ""
g_data.active = (box.query("emailnotify:settings/enabled") == "1")
g_data.fax_active = g_data.cur_elem.mode=="1" or g_data.cur_elem.mode=="3" or g_data.cur_elem.mode=="5"
g_data.email, g_data.fboxname = fon_devices_html.extract_addr_name(box.query("emailnotify:settings/From"))
g_data.last_mail = g_data.email
g_data.pass = box.query("emailnotify:settings/passwd")
g_data.user = box.query("emailnotify:settings/accountname")
g_data.pppuser = box.query("connection0:settings/username")
g_data.is_tonline = email_data.is_tonline_account(box.query("connection0:settings/username"))
local ssl = box.query("emailnotify:settings/starttls") == "1"
g_data.use_ssl = ssl and "checked" or ""
g_data.server, g_data.port = email_data.split_server(box.query("emailnotify:settings/SMTPServer"))
g_data.port = g_data.port or email_data.get_default_port("smtp", ssl)
g_data.has_test_btn = false
end
read_data()
if (#g_data.cur_elem.incoming <= 1) then
g_val = {
prog = [[
if __checked(uiActivate/email_send) then
not_empty(uiViewAddr/fax_addr,err_email_addr)
email_list(uiViewAddr/fax_addr, err_email_addr)
end
]]
}
else
local check_emailfields=[[]]
for i=1, #g_data.cur_elem.incoming, 1 do
check_emailfields=check_emailfields..
general.sprintf([[
email_list(uiViewAddr%1/fax_addr%1, err_email_addr)
]],i)
end
g_val = {
prog = [[
if __checked(uiActivate/email_send) then ]]..
check_emailfields
..[[ end
]]
}
end
g_val.prog = g_val.prog..[[
if __value_not_empty(uiViewFaxIdentifier/fax_identifier) then
length(uiViewFaxIdentifier/fax_identifier, 0, 20, err_fax_id)
end
]]
if not fon_devices_html.is_mailer_configured() then
g_val.prog = g_val.prog..fon_devices_html.get_email_config_validation([[uiActivate/email_send]])
end
val.msg.err_fax_id = {
[val.ret.toolong] = [[{?932:655?}]]
}
local err_msg_empty=[[{?932:3?}]]
val.msg.err_email_addr= {
[val.ret.empty]=err_msg_empty,
[val.ret.format] = [[{?932:476?}]]
}
if next(box.post) then
if (box.post.apply) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
require("cmtable")
local saveset={}
if not fon_devices_html.is_mailer_configured() then
fon_devices_html.save_email_config(saveset,g_data)
end
if (box.post.email_send) then
local addr=""
if (#g_data.cur_elem.incoming <= 1) then
addr=box.post.fax_addr:gsub(" ","")
cmtable.add_var(saveset,"telcfg:settings/FaxMailAddress0",addr)
else
for i=1,#g_data.cur_elem.incoming,1 do
local addr=box.post["fax_addr"..tostring(i)] or ""
addr=addr:gsub(" ","")
cmtable.add_var(saveset,"telcfg:settings/FaxMailAddress"..tostring(i-1),addr)
end
end
end
cmtable.add_var(saveset,"telcfg:settings/FaxKennung",box.post.fax_identifier or "")
local mode = "0"
if config.RAMDISK or config.NAND then
if (box.post.email_send) then
if (box.post.fax_save=="no") then
mode = "1"
elseif (box.post.fax_save=="intern") then
mode = "5"
elseif (box.post.fax_save=="usb") then
mode = "3"
end
else
if (box.post.fax_save=="no") then
mode = "0"
elseif (box.post.fax_save=="intern") then
mode = "4"
elseif (box.post.fax_save=="usb") then
mode = "2"
end
end
else
if (box.post.fax_save~=nil) then
if (box.post.email_send) then
mode = "3"
else
mode = "2"
end
else
if (box.post.email_send) then
mode = "1"
end
end
end
cmtable.add_var(saveset,"telcfg:settings/FaxMailActive",mode)
local err, msg = box.set_config( saveset)
if err == 0 then
redirect_back()
else
g_errmsg=general.create_error_div(err,msg)
end
end
elseif (box.post.test) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
require("cmtable")
local saveset={}
if not fon_devices_html.is_mailer_configured() then
fon_devices_html.save_email_config(saveset,g_data)
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
g_data.fax_active=true
end
elseif box.post.button_cancel then
redirect_back()
end
end
function write_hidden_notabs()
if box.get.notabs or box.post.notabs then
box.out([[
<input type="hidden" name="notabs" value="">
]])
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
function get_fax_email_data()
local fax_elem=g_data.cur_elem
if (#fax_elem.incoming<=1) then
local emailadr=fax_elem.mail_addr[1]
if (emailadr=="") then
emailadr=box.query("emailnotify:settings/To")
end
return [[
<div id="uiViewTab" class="formular widetext">
<label for="uiViewAddr">{?932:166?}</label><input id="uiViewAddr" type="text" size="100" name="fax_addr" value="]]..emailadr..[[">
</div>
]]
end
local str=[[
<div id="uiViewTab" class="formular widetext">
<div><span id="uiTabHeadCall">{?932:351?}</span><span id="uiTabHeadEmail">{?txtEmailAdr?}</span></div>
]]
for i=1,#fax_elem.incoming,1 do
nr=fax_elem.incoming[i]
if nr=="POTS" then
nr=[[{?932:360?}]]
end
str=str..general.sprintf([[<div><label for="uiViewAddr%1%idx%">%2%nr%</label><input type="text" id="uiViewAddr%1%idx%" size="100" name="fax_addr%1%idx%" value="%3%Addr%" ></div>]],i,nr,box.tohtml(fax_elem.mail_addr[i]))
end
str=str..[[</div>]]
return str
end
function write_fax_email_data()
box.out(get_fax_email_data())
end
function get_checked(save_option)
local result=[[]]
if save_option=='save_no' then
if (g_data.cur_elem.mode=="" or g_data.cur_elem.mode=="0" or g_data.cur_elem.mode=="1" or (g_data.usb_disk_missing and (g_data.cur_elem.mode=="2" or g_data.cur_elem.mode=="3"))) then
result="checked"
end
elseif save_option=='save_intern' then
if (g_data.cur_elem.mode=="4" or g_data.cur_elem.mode=="5") then
result="checked"
end
elseif save_option=='save_usb' then
if (g_data.usb_disk_missing) then
result="disabled"
else
if (g_data.cur_elem.mode=="2" or g_data.cur_elem.mode=="3") then
result="checked"
end
end
elseif save_option=='email' then
if (g_data.fax_active) then
result="checked"
end
end
return result
end
function write_storage()
local str=[[]]
local path=fon_devices_html.get_save_path()
str=[[<div><hr>]]
if config.RAMDISK or config.NAND then
str=str..[[<h4>{?932:290?}</h4>
<p><input name="fax_save" type="radio" value="no" id="uiViewDontSaveFax" ]]..get_checked('save_no')..[[><label for="uiViewDontSaveFax">{?932:807?}</label></p>]]
if config.NAND then
str=str..[[<p><input name="fax_save" type="radio" value="intern" id="uiViewFaxInternalMem" ]]..get_checked('save_intern')..[[><label for="uiViewFaxInternalMem">{?932:42?}</label></p>]]
end
str=str..[[<p id="uiUsbDevice"><input name="fax_save" type="radio" value="usb" id="uiViewSaveFaxOnUsb" ]]..get_checked('save_usb')..[[><label for="uiViewSaveFaxOnUsb">{?932:93?}</label></p>
<div class="formular"><span >]]..path..[[</span></div>]]
else
str=str..[[<p id="uiUsbDevice"><input name="fax_save" type="checkbox" id="uiViewSaveFaxOnUsb" ]]..get_checked('usb')..[[><label for="uiViewSaveFaxOnUsb">{?932:524?}</label></p>
<div class="formular"><span >]]..path..[[</span></div>]]
end
str=str..[[</div>]]
box.out(str)
end
function write_fax_email_config()
if not fon_devices_html.is_mailer_configured() then
box.out(fon_devices_html.get_email_config_html(g_data))
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
#uiTabHeadCall,#uiTabHeadEmail {
width:175px;
display:inline-block;
font-weight:bold;
margin-right:6px;
}
#uiTestArea {
margin-top:5px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua write_hidden_notabs() ?>
<p>{?932:319?}</p>
<div class="formular small_indent widetext">
<div>
<label for="uiViewFaxIdentifier">{?932:553?}</label>
<input type="text" size="25" maxlength="20" id="uiViewFaxIdentifier" name="fax_identifier" value="<?lua box.html(g_data.fax_identifier) ?>">
</div>
<hr>
<div>
<input type="checkbox" id="uiActivate" name="email_send" <?lua box.out(get_checked('email'))?>>
<label for="uiActivate">{?932:668?}</label>
</div>
<div >
<?lua
write_fax_email_data()
write_fax_email_config()
write_storage()
if (g_errmsg) then
box.out(g_errmsg)
end
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="apply" onclick="g_testclicked=false;" style="">{?txtOK?}</button>
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
<?lua
if not fon_devices_html.is_mailer_configured() then
box.out(fon_devices_html.get_email_config_js_include())
end
?>
<script type="text/javascript">
var g_usb_disk_missing=<?lua box.out(tostring(g_data.usb_disk_missing))?>;
var g_testclicked=false;
<?lua
val.write_js_error_strings()
if not fon_devices_html.is_mailer_configured() then
box.out(fon_devices_html.get_email_config_js(g_data))
end
?>
function uiDoOnActivateChecked()
{
var is_checked=jxl.getChecked("uiActivate");
jxl.disableNode("uiViewTab",!is_checked);
if (jxl.get("uiViewEmailConfig"))
{
jxl.display("uiViewEmailConfig",is_checked);
jxl.disableNode("uiViewEmailConfig",!is_checked);
}
}
function check_options()
{
if (jxl.getChecked("uiViewDontSaveFax") && !jxl.getChecked("uiActivate"))
{
return false;
}
return true;
}
function init()
{
jxl.disableNode("uiUsbDevice",g_usb_disk_missing);
if (jxl.get("uiViewEmailConfig"))
{
init_email();
}
else
{
jxl.addEventHandler("uiActivate", "click", uiDoOnActivateChecked);
}
jxl.disableNode("uiViewTab",!jxl.getChecked("uiActivate"));
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
if (g_testclicked)
return true;
var g_mld_Confirm = "{?932:933?}";
if (!(check_options()))
{
alert(g_mld_Confirm);
return false;
}
if (jxl.get("uiViewEmailConfig"))
{
return check();
}
return true;
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
<?lua
if not fon_devices_html.is_mailer_configured() then
box.out([[ready.onReady(val.init(onNumEditSubmit, "test", "main_form" ));]])
end
?>
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
