<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_pushservice.html"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("cmtable")
require("newval")
require("js")
require("fon_devices_html")
require("email_data")
require("pushservice")
g_data={}
g_data.use_ssl = ""
g_data.email = ""
g_data.last_mail = ""
g_data.pass = ""
g_data.user = ""
g_data.server = ""
g_data.port = ""
g_data.has_test_btn = false
function read_box_values()
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
local p = email_data.get_edata_entry_by_addr(g_data.email)
if p and p ~= 'default' then
g_data.initial_provider = p.name
end
end
function refill_user_input()
local dontcare, default_sendername = fon_devices_html.extract_addr_name("")
g_data.email = box.post.email
local sendername = box.post.sendername
if not sendername or sendername == "" then
g_data.fboxname = default_sendername
else
g_data.fboxname = sendername
end
g_data.pass = box.post.pass
g_data.user = box.post.username
g_data.pppuser = box.query("connection0:settings/username")
g_data.server = box.post.server
g_data.port = box.post.port
g_data.is_tonline = email_data.is_tonline_account(box.query("connection0:settings/username"))
g_data.use_ssl = box.post.use_ssl and "checked" or ""
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(pushservice.account_validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
refill_user_input()
if newval.validate(pushservice.account_validation) == newval.ret.ok then
local saveset = {}
box.post.email_send = "on"
fon_devices_html.save_email_config(saveset, g_data)
if not pushservice.account_configured() then
pushservice.save_first_defaults(saveset, box.post.email)
end
local errcode, errmsg = box.set_config(saveset)
if errcode == 0 then
if box.post.test then
http.redirect(
href.get("/system/push_check.lua", http.url_param("back_to_page", box.glob.script))
)
else
http.redirect(href.get(box.glob.script))
end
end
end
else
read_box_values()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<?lua
box.out(fon_devices_html.get_email_config_js_include())
?>
<script type="text/javascript">
function uiDoOnActivateChecked(){}
<?lua
box.out(fon_devices_html.get_email_config_js(g_data))
?>
var g_testclicked=false;
function init()
{
init_email();
if (gProvider.name == g_data.initial_provider) {
jxl.setValue("uiServer", g_data.server);
jxl.setValue("uiPort", g_data.port);
jxl.setChecked("uiTls", Boolean(g_data.use_ssl));
}
}
function uiDoOnMainFormSubmit() {
var ok = check();
if (ok === false) {
return false;
}
var txt = [
"{?8381:912?}",
"{?8381:262?}"
];
if (gProvider.name == "T-Online") {
if (jxl.getValue("uiServer") == "smtpmail.t-online.de") {
if (confirm(txt.join("\n"))) {
jxl.setValue("uiServer", gProvider.smtpsrv);
jxl.setChecked("uiTls", gProvider.smtpssl);
}
}
}
return ok;
}
ready.onReady(init);
ready.onReady(ajaxValidation({
applyNames: "apply",
okCallback: uiDoOnMainFormSubmit
}));
</script>
<?include "templates/page_head.html" ?>
<form action="<?lua box.html(box.glob.script) ?>" method="POST" id="uiMainForm" name="main_form">
<?lua href.default_submit('apply') ?>
<p>
{?8381:497?}
</p>
<?lua
box.out(fon_devices_html.get_email_config_html(g_data, {noheading=true}))
?>
<hr>
<h4>{?8381:781?}</h4>
<p>{?8381:381?}</p>
<div class="formular widetext">
<label for="uiName">{?8381:881?}</label>
<input type="text" name="sendername" id="uiSendername" value="<?lua box.html(g_data.fboxname) ?>">
</div>
<hr>
<div>
<input type="checkbox" name="test" id="uiTest" checked>
<label for="uiTest">
{?8381:721?}
</label>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" onclick="g_testclicked=false;" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
