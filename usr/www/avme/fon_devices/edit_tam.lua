<?lua
g_page_type = "all"
g_page_title = "{?7344:592?}"
g_page_help = 'hilfe_tam_edit.html'
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("fon_devices")
require("fon_numbers")
if config.TIMERCONTROL then
require("timer")
g_timer_id = "uiTimer"
end
require("fon_devices_html")
require("email_data")
require("config")
g_back_to_page = http.get_back_to_page( "/fon_devices/tam_list.lua" )
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
g_val = {
prog = [[
not_empty(uiTamName/tam_name,tam_err)
if __radio_check(uiOperationModeRecord/operation_mode,rec) then
if __checked(uiUseRemote/use_remote) then
not_empty(uiPin/pin,tam_pin_err)
length(uiPin/pin, 4, 4, tam_pin_err)
end
if __checked(uiEmailSend/email_send) then
not_empty(uiEmailAddr/email_addr,tam_email_err)
email_list(uiEmailAddr/email_addr, tam_email_err)
end
if __value_equal(uiCallDelay1/call_delay, tochoose) then
const_error(uiCallDelay1/call_delay, wrong, out_selection_delay)
end
if __value_equal(uiRecLen/rec_len, tochoose) then
const_error(uiRecLen/rec_len, wrong, out_selection_reclen)
end
end
if __radio_check(uiOperationModeOnlyMsg/operation_mode,only_msg) then
if __value_equal(uiCallDelay2/call_delay, tochoose) then
const_error(uiCallDelay2/call_delay, wrong, out_selection_delay)
end
end
]]
}
if not fon_devices_html.is_mailer_configured() then
g_val.prog = g_val.prog..fon_devices_html.get_email_config_validation([[uiEmailSend/email_send]])
end
val.msg.out_selection_delay = {
[val.ret.wrong] = [[{?7344:802?}]]
}
val.msg.selection_num = {
[val.ret.wrong] = [[{?7344:998?}]]
}
val.msg.out_selection_reclen = {
[val.ret.wrong] = [[{?7344:154?}]]
}
val.msg.tam_err= {
[val.ret.empty]=[[{?7344:964?}]]
}
val.msg.tam_pin_err= {
[val.ret.empty]=[[{?7344:320?}]],
[val.ret.toolong] = [[{?7344:527?}]],
[val.ret.tooshort] = [[{?7344:92?}]]
}
val.msg.tam_email_err= {
[val.ret.empty]=[[{?7344:281?}]],
[val.ret.outofrange] = [[{?7344:315?}]],
[val.ret.format] = [[{?7344:241?}]]
}
local err_msg_format=[[{?7344:921?}]]
local err_msg_empty=[[{?7344:136?}]]
val.msg.err_email_addr= {
[val.ret.empty]=err_msg_empty,
[val.ret.outofrange] = err_msg_format,
[val.ret.format] = [[{?7344:260?}]]
}
val.msg.email = {
[val.ret.empty] = err_msg_empty,
[val.ret.notfound] = err_msg_empty,
[val.ret.format] = err_msg_format
}
g_max_tam_cnt=5
g_data={}
g_errmsg=[[]]
g_hastime=true
local filetype = {fax = "myfaxfile", tam = "myabfile"}
local function get_download_link(which, path)
return href.get([[/lua/photo.lua]], http.url_param(filetype[which], path))
end
function get_var()
fon_devices.create_tam_empty_timeplans()
g_data.tamlist, g_data.cnt=fon_devices.read_tam(true,true)
g_data.cnt_nums=fon_numbers.get_number_count("all")
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
g_data.cur_tam_idx=0
if (next(box.get)) then
g_data.cur_tam_idx=tonumber(box.get["TamNr"])or 0
elseif(next(box.post)) then
g_data.cur_tam_idx=tonumber(box.post["TamNr"])or 0
end
if not fon_devices.is_valid_tam_nr(g_data.tamlist,g_data.cur_tam_idx) then
box.out(general.create_error_div(1,"TamIndex nicht vorhanden"))
box.end_page()
end
if config.TIMERCONTROL then
timer.read_tam(g_timer_id,g_data.cur_tam_idx)
end
g_data.cur_elem=fon_devices.get_tam_elem(g_data.tamlist,g_data.cur_tam_idx)
end
get_var()
if g_data.cur_tam_idx == 0 then
g_val.prog = g_val.prog..[[
if __radio_check(uiSelNums/num_selection,sel_nums) then
if __callfunc(uiSelNums/num_selection, no_nr_configured) then
const_error(uiSelNums/num_selection, wrong, selection_num)
end
end
]]
end
function no_nr_configured()
for i=1, g_data.cnt_nums, 1 do
if box.post["num_"..i] then
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
local idx=tostring(g_data.cur_tam_idx)
local saveset={}
if not fon_devices_html.is_mailer_configured() then
fon_devices_html.save_email_config(saveset,g_data)
end
if (box.post.num_selection) then
if box.post.num_selection=="all_nums" then
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/MSNBitmap","")
else
fon_devices_html.save_active_nums(saveset,g_data.tamlist,g_data.cur_elem,g_data.cnt_nums)
end
else
fon_devices_html.save_active_nums(saveset,g_data.tamlist,g_data.cur_elem,g_data.cnt_nums)
end
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/Name",box.post.tam_name)
local delay="0"
if (box.post.call_delay) then
delay=tostring(tonumber(box.post.call_delay)/5)
end
if (box.post.operation_mode=="rec") then
local rec_len="0"
if (box.post.rec_len) then
rec_len=tostring(box.post.rec_len)
end
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/RecordLength",rec_len)
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/RingCount",delay)
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/Mode","1")
else
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/RingCount",delay)
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/Mode","0")
end
if box.post["email_send"] and (box.post["operation_mode"]=="only_msg") then
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailActive","0")
else
if (box.post.email_send) then
if (box.post.email_send_del_call) then
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailActive","2")
else
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailActive","1")
end
else
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailActive","0")
end
end
if (box.post.email_addr) then
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/MailAddress",general.clear_whitespace(box.post.email_addr))
end
if fon_devices_html.tam_usb_usable() and not fon_devices_html.aura_4_storage() and fon_devices_html.has_internal_mem() then
if box.post.operation_mode=="rec" then
cmtable.save_checkbox(saveset,"tam:settings/UseStick","usb_usage")
end
end
if (box.post.pin) then
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PIN",box.post.pin)
else
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PIN","0000")
end
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailServer","")
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailUser","")
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailPass","")
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/PushmailFrom","")
if config.TIMERCONTROL then
local use_timectrl=box.post.use_timectrl~=nil
cmtable.add_var(saveset, "timer:settings/TamTimerXML"..idx, timer.get_tam_timeplan_xml(g_timer_id, idx, use_timectrl))
end
local err, msg = box.set_config( saveset)
if err == 0 then
http.redirect(href.get(g_back_to_page,"TamNr="..g_data.cur_tam_idx, http.url_param('popup_url', popup_url)))
else
g_errmsg=general.create_error_div(err,msg)
end
end
elseif box.post.edit_hint then
http.redirect(href.get([[/fon_devices/tam_upload.lua]],[[which=hint]],[[TamNr=]]..g_data.cur_tam_idx,[[back_to_page=/fon_devices/edit_tam.lua]]))
elseif box.post.edit_begin then
http.redirect(href.get([[/fon_devices/tam_upload.lua]],[[which=begin]],[[TamNr=]]..g_data.cur_tam_idx,[[back_to_page=/fon_devices/edit_tam.lua]]))
elseif box.post.edit_end then
http.redirect(href.get([[/fon_devices/tam_upload.lua]],[[which=end]],[[TamNr=]]..g_data.cur_tam_idx,[[back_to_page=/fon_devices/edit_tam.lua]]))
elseif box.post.delete then
local err, msg = fon_devices.delete_tam_device(g_data.cur_elem)
if err == 0 then
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
else
g_errmsg=general.create_error_div(err,msg)
end
elseif (box.post.test) then
elseif box.post.button_cancel then
http.redirect(href.get(g_back_to_page,"TamNr="..g_data.cur_tam_idx, http.url_param('popup_url', popup_url)))
end
end
function write_active()
if g_data.cur_elem.active then
box.out("checked=checked")
end
end
function write_tam_content()
local elem=g_data.cur_elem
local str=fon_devices_html.create_tam_html(elem)
box.out(str)
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
.formular .formular .formular label {
width:200px;
}
</style>
<?lua
if config.TIMERCONTROL then
box.out([[
<link rel="stylesheet" type="text/css" href="/css/default/timer.css"/>
<script type="text/javascript" src="/js/timer.js"></script>
]])
end
?>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>{?7344:818?}</div>
<hr>
<div id="uiTamContent">
<?lua
write_tam_content()
?>
</div>
<div class="WarnMsg" >
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="TamNr" value="<?lua box.html(tostring(g_data.cur_tam_idx))?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="apply" onclick="g_testclicked=false;">{?txtOK?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
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
<?lua
fon_devices_html.write_tam_js(g_data.tamlist,g_data.cur_elem)
if config.TIMERCONTROL then
box.out([[
var g_timer = null;
]])
if not timer.has_tam_timeplan(g_timer_id) then
box.out([[
var gTimeData = [ [new Period(new Moment(0,5,0), new Moment(0,23,0))],[new Period(new Moment(1,5,0), new Moment(1,23,0))],[new Period(new Moment(2,5,0), new Moment(2,23,0))],[new Period(new Moment(3,5,0), new Moment(3,23,0))],[new Period(new Moment(4,5,0), new Moment(4,23,0))],[new Period(new Moment(5,5,0), new Moment(5,23,0))],[new Period(new Moment(6,5,0), new Moment(6,23,0))] ];
]])
else
box.out([[
var gTimeData = ]]..timer.get_data_js(g_timer_id)..[[;
]])
end
end
if not fon_devices_html.is_mailer_configured() then
box.out(fon_devices_html.get_email_config_js(g_data))
end
val.write_js_error_strings()
?>
var g_testclicked=false;
function init()
{
<?lua
fon_devices_html.write_js_init()
if config.TIMERCONTROL then
box.out([[
g_timer = new Timer("]]..g_timer_id..[[", gTimeData);
]])
end
?>
if (jxl.get("uiViewEmailConfig"))
{
init_email();
}
else
{
jxl.addEventHandler("uiActivate", "click", uiDoOnActivateChecked);
}
}
function noNrConfigured() {
return !isAnyNumConfigured();
}
function uiDoOnActivateChecked()
{
return OnEmailSend(jxl.getChecked("uiEmailSend"));
}
function onDelete() {
if (!confirm("{?7344:293?}"))
return false;
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
if config.TIMERCONTROL and g_hastime then
box.out([[
if (jxl.getChecked("uiUseTimeCtrl"))
g_timer.save("main_form");
]])
end
?>
if (g_testclicked)
return true;
if (jxl.get("uiViewEmailConfig"))
{
return check();
}
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
