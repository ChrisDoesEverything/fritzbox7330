<?lua
g_page_type = "all"
g_page_title = [[{?558:38?}]]
g_page_help = "hilfe_dect_email_kontodaten.html"
g_menu_active_page = "/dect/show_mail.lua"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("general")
require("bit")
require("email_data")
require("http")
require("js")
g_back_to_page = http.get_back_to_page( "/dect/mail.lua" )
g_val = {
prog = [[
not_empty(uiViewEmailAddress/email_address, eaddr)
char_range_regex(uiViewEmailAddress/email_address, email, eaddr)
not_empty(uiViewEmailPassword/email_password, epass)
not_empty(uiViewEmailUserName/email_user_name, eusername)
not_empty(uiViewEmailPop/email_pop, epop)
not_empty(uiViewEmailUpdateIntervalHours/email_update_interval_hours, etime)
char_range_regex(uiViewEmailUpdateIntervalHours/email_update_interval_hours, decimals, etime)
not_empty(uiViewEmailUpdateIntervalMinutes/email_update_interval_minutes, etime)
char_range_regex(uiViewEmailUpdateIntervalMinutes/email_update_interval_minutes, decimals, etime)
if __checked(uiViewSendEmailActiv/email_send_activ) then
not_empty(uiViewEmailSmtpServer/email_smtp_server, esmtpsrv)
not_empty(uiViewEmailSender/email_sender, esmtpsender)
end
if __checked(uiViewEmailPinActive/email_pin_activ) then
if __value_not_equal(uiViewEmailPin/email_pin,****) then
not_empty(uiViewEmailPin/email_pin, epin)
char_range_regex(uiViewEmailPin/email_pin, decimals, epin)
end
end
]]
}
val.msg.eaddr = {
[val.ret.empty] = [[{?558:968?}]],
[val.ret.outofrange] = [[{?558:149?}]]
}
val.msg.epass = {
[val.ret.empty] = [[{?558:494?}]]
}
val.msg.eusername = {
[val.ret.empty] = [[{?558:616?}]]
}
val.msg.epop = {
[val.ret.empty] = [[{?558:208?}]]
}
val.msg.etime = {
[val.ret.empty] = [[{?558:601?}]],
[val.ret.outofrange] = [[{?558:240?}]]
}
val.msg.esmtpsrv = {
[val.ret.empty] = [[{?558:123?}]]
}
val.msg.esmtpsender = {
[val.ret.empty] = [[{?558:658?}]]
}
val.msg.epin = {
[val.ret.empty] = [[{?558:112?}]],
[val.ret.outofrange] = [[{?558:435?}]]
}
function get_phones()
local tmp = general.listquery("dect:settings/Handset/list(Name,Subscribed,Manufacturer,User)")
local phones = {}
local cnt = 0
local cnt_all = 0
for i,v in ipairs(tmp) do
cnt_all = cnt_all + 1
if v.Name ~= "" and v.Subscribed == "1" and v.Manufacturer=="AVM" then
cnt = cnt + 1
phones[cnt] = {}
phones[cnt].name = v.Name
phones[cnt].subscribed = v.Subscribed
phones[cnt].manu = v.Manufacturer
phones[cnt].id = tonumber(v.User) or 0
end
end
return phones, cnt, cnt_all
end
g_ctlmgr = {}
function get_page_var()
if g_ctlmgr.newMailAccount == "1" then
g_ctlmgr.e_pass = ""
g_ctlmgr.e_addr = ""
g_ctlmgr.e_user = ""
g_ctlmgr.e_pop3 = ""
g_ctlmgr.e_pop3_port = email_data.get_default_port("pop3", true) or ""
g_ctlmgr.e_pop_ssl = "1"
g_ctlmgr.e_smtp_activ = "0"
g_ctlmgr.e_smtp_server = ""
g_ctlmgr.e_smtp_port = email_data.get_default_port("smtp", true) or ""
g_ctlmgr.e_smtp_ssl = "1"
g_ctlmgr.e_smtp_user_name = ""
g_ctlmgr.e_pin_active = "0"
g_ctlmgr.e_pin = ""
g_ctlmgr.e_update_inteval = 1200
g_ctlmgr.e_delete_mode = "2"
g_ctlmgr.e_notification = "0"
g_ctlmgr.e_bitmap = 1023
else
g_ctlmgr.e_pass = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/Pass")
g_ctlmgr.e_addr = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/Name")
g_ctlmgr.e_user = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/User")
g_ctlmgr.e_pop3 = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/Server")
g_ctlmgr.e_pop3_port = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/Port")
g_ctlmgr.e_pop_ssl = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/SSL")
g_ctlmgr.e_smtp_activ = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPactive")
if g_ctlmgr.e_smtp_activ == "1" then
g_ctlmgr.e_smtp_ssl = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPSSL")
else
g_ctlmgr.e_smtp_ssl = "1"
end
g_ctlmgr.e_smtp_server, g_ctlmgr.e_smtp_port = email_data.split_server(
box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPServer")
)
if not g_ctlmgr.e_smtp_port then
g_ctlmgr.e_smtp_port = email_data.get_default_port("smtp", g_ctlmgr.e_smtp_ssl == "1")
end
g_ctlmgr.e_smtp_user_name = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/UserName")
g_ctlmgr.e_pin_active = "0"
g_ctlmgr.e_pin = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/UIPin")
if g_ctlmgr.e_pin=="****" then
g_ctlmgr.e_pin_active = "1"
end
g_ctlmgr.e_update_inteval = tonumber(box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/PollInterval")) or 0
g_ctlmgr.e_delete_mode = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/DeleteMode")
g_ctlmgr.e_notification = box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/MWI")
g_ctlmgr.e_bitmap = tonumber(box.query("configd:settings/Mail"..g_ctlmgr.MailId.."/Bitmap")) or 0
end
g_ctlmgr.phones, g_ctlmgr.phones_cnt, g_ctlmgr.phones_cnt_all = get_phones()
end
if box.get.MailId then
g_ctlmgr.newMailAccount = box.get.newMailAccount
g_ctlmgr.MailId = box.get.MailId
end
if box.post.MailId then
g_ctlmgr.newMailAccount = box.post.newMailAccount
g_ctlmgr.MailId = box.post.MailId
end
function get_bitmap()
local bitmask = 0
local bit_set_cnt = 0
local cnt_all = tonumber(box.post.email_fon_cnt_all) or 0
local cnt_fon = tonumber(box.post.email_fon_cnt) or 0
if cnt_fon < 2 then
return 1023
end
for cnt = 0, cnt_all, 1 do
if box.post["email_fon_"..cnt] then
bitmask = bitmask + math.pow(2, cnt)
bit_set_cnt = bit_set_cnt + 1
end
end
if bit_set_cnt == cnt_fon then
bitmask = 1023
end
return bitmask
end
function refill_user_input()
if box.post.email_password then
g_ctlmgr.e_pass = box.post.email_password
end
if box.post.email_address then
g_ctlmgr.e_addr = box.post.email_address
end
if box.post.email_user_name then
g_ctlmgr.e_user = box.post.email_user_name
end
if box.post.email_pop then
g_ctlmgr.e_pop3 = box.post.email_pop
end
if box.post.pop3port then
g_ctlmgr.e_pop3_port = box.post.pop3port
end
if box.post.email_pop_ssl then
g_ctlmgr.e_pop_ssl = "1"
else
g_ctlmgr.e_pop_ssl = "0"
end
if box.post.email_send_activ then
g_ctlmgr.e_smtp_activ = "1"
else
g_ctlmgr.e_smtp_activ = "0"
end
if box.post.email_smtp_server then
g_ctlmgr.e_smtp_server = box.post.email_smtp_server
end
if box.post.smtpport then
g_ctlmgr.e_smtp_port = box.post.smtpport
end
if box.post.email_sender then
g_ctlmgr.e_smtp_user_name = box.post.email_sender
end
if box.post.email_send_ssl then
g_ctlmgr.e_smtp_ssl = "1"
else
g_ctlmgr.e_smtp_ssl = "0"
end
if box.post.email_pin_activ then
g_ctlmgr.e_pin_active = "1"
else
g_ctlmgr.e_pin_active = "0"
end
if box.post.email_pin then
g_ctlmgr.e_pin = box.post.email_pin
end
if box.post.email_update_interval_hours or box.post.email_update_interval_minutes then
g_ctlmgr.e_update_inteval = (tonumber(box.post.email_update_interval_hours) * 3600) + (tonumber(box.post.email_update_interval_minutes) * 60)
end
g_ctlmgr.e_delete_mode = "2"
if box.post.email_delete_activ then
if box.post.email_delete_method then
g_ctlmgr.e_delete_mode = box.post.email_delete_method
end
end
if box.post.email_notification then
g_ctlmgr.e_notification = "1"
else
g_ctlmgr.e_notification = "0"
end
g_ctlmgr.e_bitmap = get_bitmap()
end
if next(box.post) and box.post.btn_cancel then
http.redirect(href.get(g_back_to_page))
end
get_page_var()
g_no_phone_err_txt = [[{?558:572?}]]
function check_local_conditions()
local bitmask = get_bitmap()
if bitmask == 0 then
g_ctlmgr.local_error = "phone"
return false, g_ctlmgr.local_error
end
return true
end
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
if val.validate(g_val) == val.ret.ok and check_local_conditions() then
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/Name", box.post.email_address)
if box.post.email_password ~= g_ctlmgr.e_pass then
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/Pass", box.post.email_password)
end
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/User", box.post.email_user_name)
cmtable.save_checkbox(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/SSL", "email_pop_ssl")
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/Server", box.post.email_pop)
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/Port", box.post.pop3port)
cmtable.save_checkbox(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPactive", "email_send_activ")
if box.post.email_send_activ then
local srv_url = table.concat({box.post.email_smtp_server, box.post.smtpport}, ":")
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPServer", srv_url)
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/UserName", box.post.email_sender)
cmtable.save_checkbox(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/SMTPSSL", "email_send_ssl")
end
if box.post.email_pin_activ then
if box.post.email_pin ~= g_ctlmgr.e_pin then
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/UIPin", box.post.email_pin)
end
else
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/UIPin", "")
end
local interval = (box.post.email_update_interval_hours*3600)+(box.post.email_update_interval_minutes*60)
if interval > 86400 then
interval = 86400
end
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/PollInterval", tostring(interval))
cmtable.save_checkbox(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/MWI", "email_notification")
if box.post.email_delete_activ then
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/DeleteMode", box.post.email_delete_method)
else
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/DeleteMode", "2")
end
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..g_ctlmgr.MailId.."/Bitmap", get_bitmap())
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
http.redirect(href.get(g_back_to_page))
else
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
refill_user_input()
else
refill_user_input()
end
end
function get_time(hours)
local time = g_ctlmgr.e_update_inteval
if time > 0 then
if hours then
time = (time - (time % 3600)) / 3600
else
time = (time % 3600) / 60
end
end
return time
end
function phones_of_email()
local str = ""
local bitmask = bit.issetlist(g_ctlmgr.e_bitmap)
str = str..[[<input type="hidden" name="email_fon_cnt" id="uiViewFonCnt" value="]]..g_ctlmgr.phones_cnt..[[" />]]
str = str..[[<input type="hidden" name="email_fon_cnt_all" id="uiViewFonCntAll" value="]]..g_ctlmgr.phones_cnt_all..[[" />]]
for i,v in ipairs(g_ctlmgr.phones) do
str = str..[[<input type="checkbox" id="uiViewFon]]..v.id..[[" name="email_fon_]]..v.id..[["]]
for j, val in ipairs(bitmask) do
if val == v.id then
str = str..[[ checked ]]
end
end
str = str..[[> <label for="uiViewFon]]..v.id..[[">]]..box.tohtml(v.name)..[[</label><br>]]
end
return str
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var gEmailData = <?lua email_data.write_edata_to_js() ?>;
var gDefaultPorts = <?lua email_data.write_default_ports_js() ?>;
var gProvider;
function onClickPop3ssl() {
if (jxl.getChecked("uiViewEmailPopSsl")) {
if (gProvider.pop3ssl) {
jxl.setValue("uiPop3port", gProvider.pop3port);
}
else {
jxl.setValue("uiPop3port", gDefaultPorts.pop3ssl);
}
}
else {
if (gProvider.pop3ssl) {
jxl.setValue("uiPop3port", gDefaultPorts.pop3);
}
else {
jxl.setValue("uiPop3port", gProvider.pop3port);
}
}
}
function onClickSmtpssl() {
if (jxl.getChecked("uiViewSendSSL")) {
if (gProvider.smtpssl) {
jxl.setValue("uiSmtpport", gProvider.smtpport);
}
else {
jxl.setValue("uiSmtpport", gDefaultPorts.smtpssl);
}
}
else {
if (gProvider.smtpssl) {
jxl.setValue("uiSmtpport", gDefaultPorts.smtp);
}
else {
jxl.setValue("uiSmtpport", gProvider.smtpport);
}
}
}
function checkOldMailServers() {
var txt = [
"{?558:159?}",
"{?558:324?}"
];
if (gProvider.name == "T-Online") {
var popwrong = (jxl.getValue("uiViewEmailPop") == "popmail.t-online.de");
var smtpwrong;
if (jxl.getChecked("uiViewSendEmailActiv")) {
smtpwrong = (jxl.getValue("uiViewEmailSmtpServer") == "smtpmail.t-online.de");
}
if (popwrong || smtpwrong) {
if (confirm(txt.join("\n"))) {
if (popwrong) {
jxl.setValue("uiViewEmailPop", gProvider.pop3srv);
jxl.setValue("uiPop3port", gProvider.pop3port);
jxl.setChecked("uiViewEmailPopSsl", gProvider.pop3ssl);
}
if (smtpwrong && gProvider.smtpsrv != "") {
jxl.setValue("uiViewEmailSmtpServer", gProvider.smtpsrv);
jxl.setValue("uiSmtpport", gProvider.smtpport);
jxl.setChecked("uiViewSendSSL", gProvider.smtpssl);
}
}
}
}
}
function onEmailEditSubmit()
{
if (val.active)
{
checkOldMailServers();
var hour = parseInt(jxl.getValue("uiViewEmailUpdateIntervalHours"));
var minu = parseInt(jxl.getValue("uiViewEmailUpdateIntervalMinutes"));
var phoneCnt = <?lua box.out(g_ctlmgr.phones_cnt) ?>;
var interval = 1;
var intText = "{?558:970?}";
if (gProvider)
{
interval = gProvider.poll;
intText = "{?558:67?} "+interval+" {?558:803?}";
}
if (isNaN(hour) && minu > 0)
{
jxl.setValue("uiViewEmailUpdateIntervalHours", "0");
hour = 0;
}
if (isNaN(minu) && hour > 0)
{
jxl.setValue("uiViewEmailUpdateIntervalMinutes", "0");
minu = 0;
}
if ( interval > ((hour * 60) + minu))
{
if (!confirm(intText))
{
val.markError("uiViewEmailUpdateIntervalMinutes");
val.active = false;
return false;
}
}
if ( ((hour * 60) + minu) > 1440)
{
val.markError("uiViewEmailUpdateIntervalMinutes");
val.markError("uiViewEmailUpdateIntervalHours");
alert("{?558:188?}");
val.active = false;
return false;
}
var akt_cnt = 0;
if (phoneCnt > 1)
{
var nodes = jxl.walkDom("uiViewTelOption", "input", function(elem){ return (elem.type == "checkbox")&&(elem.checked)});
for (var node in nodes)
akt_cnt++;
if (akt_cnt == 0)
{
alert("<?lua box.js(g_no_phone_err_txt) ?>");
val.active = false;
return false;
}
}
}
<?lua
val.write_js_checks(g_val)
?>
}
function InitSmtp()
{
jxl.disableNode("uiViewSendEmailInnerBox", !jxl.getChecked("uiViewSendEmailActiv"));
}
function onSmtp(providerChanged)
{
InitSmtp();
if (jxl.getChecked("uiViewSendEmailActiv"))
{
if (gProvider.smtpuser || isDefaultProvider()) {
jxl.setValue("uiViewEmailSender", jxl.getValue("uiViewEmailUserName"));
}
if (providerChanged) {
if (gProvider.smtpsrv != "") {
jxl.setValue("uiViewEmailSmtpServer", gProvider.smtpsrv);
}
else {
jxl.setValue("uiViewEmailSmtpServer", "");
}
jxl.setChecked("uiViewSendSSL", gProvider.smtpssl);
}
}
onClickSmtpssl();
}
function onEmailDelete()
{
jxl.disableNode("uiViewDeleteEmailInnerBox", !jxl.getChecked("uiViewDeleteEmailActiv"));
}
function onEmailPin()
{
jxl.disableNode("uiViewEmailPinInnerBox", !jxl.getChecked("uiViewEmailPinActive"));
}
function init()
{
getProvider();
//--onChangeEmailAddress(false);
onSmtp(false);
onClickSmtpssl();
onEmailDelete();
onEmailPin();
}
ready.onReady(val.init(onEmailEditSubmit, "btn_save", "main_form" ));
ready.onReady(init);
function changeTab(first)
{
var helpBtn = jxl.get("uiHelpBtn");
var helpLink;
jxl.display("uiViewAccountDataBox", first);
jxl.display("uiViewAdvancedSettingsBox", !first);
if (first)
{
jxl.addClass("uiViewAccount", "active");
jxl.removeClass("uiViewSettings", "active");
helpLink = "<?lua href.help_write('hilfe_dect_email_kontodaten.html')?>";
}
else
{
jxl.addClass("uiViewSettings", "active");
jxl.removeClass("uiViewAccount", "active");
helpLink = "<?lua href.help_write('hilfe_dect_email_einstellungen.html')?>";
}
if (helpBtn && helpLink) {
helpBtn.onclick = function(){help.popup(helpLink)};
}
}
function findProviderByAddr(addr)
{
for (var p in gEmailData)
if (gEmailData[p].pattern && addr.search(gEmailData[p].pattern)>=0)
return gEmailData[p];
return null;
}
function getProvider()
{
var provider = findProviderByAddr(jxl.getValue("uiViewEmailAddress"));
if (provider == null)
provider = gEmailData["default"];
gProvider = provider
return gProvider;
}
function isDefaultProvider(provider) {
provider = provider || gProvider;
return !provider.name;
}
function onChangeEmailAddress(providerChanged)
{
var oldProvider = gProvider;
getProvider();
var providerInListChanged = oldProvider && (oldProvider.name !== gProvider.name);
if (providerInListChanged || isDefaultProvider()) {
var user = jxl.getValue("uiViewEmailAddress");
if (gProvider.pop3user == "user") {
user = user.substring(0, user.indexOf('@'));
}
jxl.setValue("uiViewEmailUserName", user);
if (providerChanged) {
if (gProvider.pop3srv != "" || providerInListChanged) {
jxl.setValue("uiViewEmailPop", gProvider.pop3srv);
}
else
{
jxl.setValue("uiViewEmailPop", "");
}
}
jxl.setChecked("uiViewEmailPopSsl", gProvider.pop3ssl);
onClickPop3ssl();
onSmtp(providerInListChanged);
}
}
</script>
<?include "templates/page_head.html" ?>
<div id="myTabs">
<ul class="tabs">
<li id="uiViewAccount" class="active">
<a href="javascript:changeTab(true)">{?558:814?}</a>
</li>
<li id="uiViewSettings">
<a href="javascript:changeTab(false)">{?558:984?}</a>
</li>
</ul>
<div class='clear_float'></div>
</div>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<div id="uiViewAccountDataBox">
<p>
{?558:894?}
</p>
<hr>
<h4>{?558:27?}</h4>
<div class="formular">
<p>
{?558:3905?}
</p>
<div class="formular">
<label for="uiViewEmailAddress">{?558:156?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailAddress" name="email_address" onchange="onChangeEmailAddress(true)" value="<?lua box.html(g_ctlmgr.e_addr) ?>" <?lua val.write_attrs(g_val, "uiViewEmailAddress") ?>>
<?lua val.write_html_msg(g_val, "uiViewEmailAddress") ?>
<br>
<label for="uiViewEmailPassword">{?558:781?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailPassword" name="email_password" value="<?lua box.html(g_ctlmgr.e_pass) ?>" <?lua val.write_attrs(g_val, "uiViewEmailPassword") ?> autocomplete="off">
<?lua val.write_html_msg(g_val, "uiViewEmailPassword") ?>
</div>
<p>
{?558:6327?}
</p>
<div class="formular" id="uiPop3Settings">
<label for="uiViewEmailUserName">{?558:590?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailUserName" name="email_user_name" value="<?lua box.html(g_ctlmgr.e_user) ?>" <?lua val.write_attrs(g_val, "uiViewEmailUserName") ?>>
<?lua val.write_html_msg(g_val, "uiViewEmailUserName") ?>
<br>
<label for="uiViewEmailPop">{?558:492?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailPop" name="email_pop" value="<?lua box.html(g_ctlmgr.e_pop3) ?>" <?lua val.write_attrs(g_val, "uiViewEmailPop") ?>>
<label class="sameline" for="uiPop3port">{?558:725?}:</label>
<input type="text" size="5" id="uiPop3port" name="pop3port" value="<?lua box.html(g_ctlmgr.e_pop3_port) ?>">
<?lua val.write_html_msg(g_val, "uiViewEmailPop") ?>
<br>
<div id="uiViewPop3SslBox">
<input type="checkbox" name="email_pop_ssl" id="uiViewEmailPopSsl" onclick="onClickPop3ssl()" <?lua if g_ctlmgr.e_pop_ssl == "1" then box.html('checked') end ?>>
<label for="uiViewEmailPopSsl">{?558:253?}</label>
</div>
</div>
</div>
</div>
<div id="uiViewAdvancedSettingsBox" style="display:none;">
<p>
{?558:370?}
</p>
<hr>
<div>
<h4>{?558:93?}</h4>
<div class="formular">
<p>
{?558:5055?}
</p>
<label for="uiViewEmailUpdateIntervalHours">{?558:804?}:</label>
<input type="text" size="1" maxlength="2" id="uiViewEmailUpdateIntervalHours" name="email_update_interval_hours" value="<?lua box.out(get_time(true)) ?>" <?lua val.write_attrs(g_val, "uiViewEmailUpdateIntervalHours") ?>>
<label for="uiViewEmailUpdateIntervalHours">{?558:824?}</label>
<input type="text" size="1" maxlength="2" id="uiViewEmailUpdateIntervalMinutes" name="email_update_interval_minutes" value="<?lua box.out(get_time(false)) ?>" <?lua val.write_attrs(g_val, "uiViewEmailUpdateIntervalMinutes") ?>>
<label for="uiViewEmailUpdateIntervalMinutes">{?558:340?}</label>
<?lua val.write_html_msg(g_val, "uiViewEmailUpdateIntervalHours") ?>
<?lua val.write_html_msg(g_val, "uiViewEmailUpdateIntervalMinutes") ?>
<br>
<input type="checkbox" id="uiViewNotification" name="email_notification" <?lua if g_ctlmgr.e_notification=="1" then box.out('checked') end ?>>
<label for="uiViewNotification">{?558:250?}</label>
</div>
</div>
<hr>
<div>
<h4>{?558:219?}</h4>
<div class="formular">
<input type="checkbox" id="uiViewSendEmailActiv" onclick="onSmtp(true)" name="email_send_activ" <?lua if g_ctlmgr.e_smtp_activ == "1" then box.html('checked') end ?>>
<label for="uiViewSendEmailActiv">{?558:728?}</label>
<div id="uiViewSendEmailInnerBox" class="formular">
<label for="uiViewEmailSmtpServer">{?558:621?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailSmtpServer" name="email_smtp_server" value="<?lua box.html(g_ctlmgr.e_smtp_server) ?>" <?lua val.write_attrs(g_val, "uiViewEmailSmtpServer") ?>>
<label class="sameline" for="uiSmtpport">{?558:129?}:</label>
<input type="text" size="5" id="uiSmtpport" name="smtpport" value="<?lua box.html(g_ctlmgr.e_smtp_port) ?>">
<?lua val.write_html_msg(g_val, "uiViewEmailSmtpServer") ?>
<br>
<label for="uiViewEmailSender">{?558:203?}:</label>
<input type="text" size="30" maxlength="63" id="uiViewEmailSender" name="email_sender" value="<?lua box.html(g_ctlmgr.e_smtp_user_name) ?>" <?lua val.write_attrs(g_val, "uiViewEmailSender") ?>>
<?lua val.write_html_msg(g_val, "uiViewEmailSender") ?>
<br>
<div id="uiViewSendSSLBox">
<input type="checkbox" id="uiViewSendSSL" name="email_send_ssl" onclick="onClickSmtpssl()" <?lua if g_ctlmgr.e_smtp_ssl == "1" then box.out('checked') end ?> <?lua val.write_attrs(g_val, "uiViewSendSSL") ?>>
<label for="uiViewSendSSL">{?558:700?}</label>
<?lua val.write_html_msg(g_val, "uiViewSendSSL") ?>
</div>
</div>
</div>
</div>
<hr>
<div>
<h4>{?558:906?}</h4>
<div class="formular">
<p>
{?558:391?}
</p>
<input type="checkbox" id="uiViewDeleteEmailActiv" onclick="onEmailDelete()" name="email_delete_activ" <?lua if g_ctlmgr.e_delete_mode == "0" or g_ctlmgr.e_delete_mode == "1" then box.out('checked') end ?>>
<label for="uiViewDeleteEmailActiv">{?558:883?}</label>
<div id="uiViewDeleteEmailInnerBox" class="formular">
<br>
<input type="radio" id="uiViewDeleteEmailView" name="email_delete_method" value="0" <?lua if g_ctlmgr.e_delete_mode == "0" or (g_ctlmgr.e_delete_mode ~= "0" and g_ctlmgr.e_delete_mode ~= "1") then box.out('checked') end ?>>
<label for="uiViewDeleteEmailView">{?558:281?}</label>
<br>
<p class="form_input_explain">{?558:48?}</p>
<br>
<input type="radio" id="uiViewDeleteEmailComplete" name="email_delete_method" value="1" <?lua if g_ctlmgr.e_delete_mode == "1" then box.out('checked') end ?>>
<label for="uiViewDeleteEmailComplete">{?558:261?}:</label>
<br>
<p class="form_input_explain">{?558:885?}</p>
</div>
</div>
</div>
<hr>
<div>
<h4>{?558:546?}</h4>
<div class="formular">
<p>
{?558:144?}
</p>
<input type="checkbox" id="uiViewEmailPinActive" onclick="onEmailPin()" name="email_pin_activ" <?lua if g_ctlmgr.e_pin_active == "1" then box.out('checked') end ?>>
<label for="uiViewEmailPinActive">{?558:825?}</label>
<div id="uiViewEmailPinInnerBox" class="formular">
<label for="uiViewEmailPin">{?558:297?}:</label>
<input type="text" size="30" maxlength="16" id="uiViewEmailPin" name="email_pin" value="<?lua box.html(g_ctlmgr.e_pin) ?>" <?lua val.write_attrs(g_val, "uiViewEmailPin") ?>>
<?lua val.write_html_msg(g_val, "uiViewEmailPin") ?>
</div>
</div>
</div>
<div <?lua if g_ctlmgr.phones_cnt < 2 then box.out("style='display:none;'") end?>>
<hr>
<h4>{?558:89?}</h4>
<div id="uiViewTelOption" class="formular">
<p>
{?558:349?}
</p>
<?lua
if g_ctlmgr.local_error and g_ctlmgr.local_error=="phone" then
box.out([[<p class="ErrorMsg">]])
box.html(g_no_phone_err_txt)
box.out([[</p>]])
end
?>
<?lua box.out(phones_of_email()) ?>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="MailId" value="<?lua box.html(g_ctlmgr.MailId)?>" />
<input type="hidden" name="newMailAccount" value="<?lua box.html(g_ctlmgr.newMailAccount)?>" />
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page)?>" />
<button type="submit" name="btn_save" id="btnSave">{?txtOK?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
