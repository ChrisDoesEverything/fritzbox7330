<?lua
g_page_type = "wizard"
g_page_title = ""
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"wizard"
require"general"
require"newval"
require"js"
require"fon_devices_html"
require"email_data"
require"http"
require"href"
g_back_to_page = http.get_back_to_page( "/system/push_list.lua" )
local testmsg = {
[0] = [[{?7858:721?}]],
[[{?7858:922?}]],
[[{?7858:446?}]],
[[{?7858:77?}]],
[[{?7858:19?}]],
[[{?7858:201?}]],
[[{?7858:559?}]],
[[{?7858:304?}]],
[[{?7858:468?}]],
[[{?7858:748?}]],
[[{?7858:528?}]],
[[{?7858:811?}]],
[[{?7858:981?}]],
[[{?7858:830?}]],
[[{?7858:881?}]]
}
function get_teststate()
local state = tonumber(box.query("emailnotify:settings/LastMailerStatus")) or 2
return {
done = state ~=2 and state~=1,
success = state == 0,
msg = testmsg[state] or [[{?7858:345?}]]
}
end
if box.get.teststate then
box.out(js.table(get_teststate()))
box.end_page()
end
g_err = {}
function write_saveerror()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
g_data = {}
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
local dontcare, default_sendername = fon_devices_html.extract_addr_name(box.query("emailnotify:settings/From"))
g_data.email = box.post.email
g_data.fboxname = default_sendername
g_data.pass = box.post.pass
g_data.user = box.post.username
g_data.pppuser= box.query("connection0:settings/username")
g_data.server = box.post.server
g_data.port = box.post.port
g_data.is_tonline = email_data.is_tonline_account(box.query("connection0:settings/username"))
g_data.use_ssl = box.post.use_ssl and "checked" or ""
end
function crashreport_checked(which)
local value = box.query("emailnotify:settings/crashreport_mode")
local checked = value == which
if value == "disable_mail" then
checked = which == "disabled_by_user"
end
if value == "to_user_and_support" then
checked = which == "to_support_only"
end
return checked
end
function crashreport_usemail()
return box.query("emailnotify:settings/crashreport_name") ~= ""
end
function save_crashreport(saveset, email)
if config.ERR_FEEDBACK then
local new_value = box.post.crashreport_mode
if new_value == "to_support_only" then
local old_value = box.query("emailnotify:settings/crashreport_mode")
if old_value == "to_user_and_support" then
new_value = old_value
end
end
cmtable.add_var(saveset, "emailnotify:settings/crashreport_mode", new_value)
if box.post.crashreport_usemail then
cmtable.add_var(saveset, "emailnotify:settings/crashreport_name", email)
else
cmtable.add_var(saveset, "emailnotify:settings/crashreport_name", "")
end
end
end
function write_crashreport()
if config.ERR_FEEDBACK then
html.hr{}.write()
html.h4{[[{?7858:195?}]]}.write()
html.p{
[[{?7858:628?}]]
}.write()
html.div{class="formular",
html.input{
type="radio", name="crashreport_mode", id="uiCrashreportOn",
value="to_support_only", checked = crashreport_checked("to_support_only")
},
html.label{['for']="uiCrashreportOn",
[[{?7858:489?}]]
},
html.div{class="formular disableif_crashreport:disabled_by_user",
html.input{type="checkbox", name="crashreport_usemail", id="uiCrashreportUsemail",
checked = crashreport_usemail()
},
html.label{['for']="uiCrashreportUsemail",
[[{?7858:324?}]]
},
html.p{class="form_checkbox_explain",
[[{?7858:646?}]]
}
},
html.input{
type="radio", name="crashreport_mode", id="uiCrashreportOff",
value="disabled_by_user", checked = crashreport_checked("disabled_by_user")
},
html.label{['for']="uiCrashreportOff",
[[{?7858:901?}]]
}
}.write()
html.p{
[[{?7858:782?}]]
}.write()
end
end
wizard.dialogs = {
'dlg_account',
'dlg_test'
}
wizard.title = {
dlg_account = [[{?7858:159?}]],
dlg_test = [[{?7858:946?}]],
}
wizard.start = func.const('dlg_account')
wizard.dlg_account = {
forward = function()
return 'dlg_account'
end,
backward = function()
end
}
wizard.dlg_test = {
forward = function()
return 'dlg_test'
end,
backward = function()
return 'dlg_account'
end
}
wizard.leave = function()
http.redirect(href.get(g_back_to_page))
end
wizard.init = function()
wizard.curr = wizard.start()
if box.post.prevdlg and box.post.prevdlg ~= "" then
if box.post.forward then
wizard.curr = wizard[box.post.prevdlg].forward()
elseif box.post.backward then
wizard.curr = wizard[box.post.prevdlg].backward()
end
end
if box.get.test then
wizard.curr = 'dlg_test'
end
if wizard.curr == 'dlg_test' then
wizard.nocancel = true
end
if wizard.title then
g_page_title = wizard.title[wizard.curr] or ""
end
wizard.wiztype = box.post.wiztype or box.get.wiztype
end
read_box_values()
wizard.init()
local function valprog()
if wizard.curr == 'dlg_account' then
pushservice.account_validation()
end
end
if box.post.validate == "forward" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
wizard.leave()
elseif box.post.forward then
if wizard.curr == 'dlg_test' then
if box.post.prevdlg == 'dlg_test' then
wizard.leave()
end
elseif wizard.curr == 'dlg_account' then
if box.post.prevdlg == 'dlg_account' then
refill_user_input()
if newval.validate(valprog) == newval.ret.ok then
local saveset = {}
box.post.email_send="on"
fon_devices_html.save_email_config(saveset, g_data)
if not pushservice.account_configured() then
pushservice.save_first_defaults(saveset, box.post.email)
end
save_crashreport(saveset, box.post.email)
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(href.get(
box.glob.script,
http.url_param("test", "")
))
end
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
<?lua wizard.write_css() ?>
</style>
<script type="text/javascript" src="/js/dialog.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<?lua
if wizard.curr == 'dlg_account' then
box.out(fon_devices_html.get_email_config_js_include())
end
?>
<script type="text/javascript">
function uiDoOnActivateChecked(){}
function waitForTestResult() {
var json = makeJSONParser();
var url = encodeURI("<?lua box.js(box.glob.script) ?>");
url = addUrlParam(url, "sid", "<?lua box.js(box.glob.sid) ?>");
url = addUrlParam(url, "teststate", "");
function onAnswer(answer) {
answer = answer || {};
if (answer.msg) {
jxl.setHtml("uiWaitMsg", answer.msg);
}
var img = "/css/default/images/wait.gif";
if (answer.done) {
if (answer.success) {
img = "/css/default/images/finished_ok_green.gif";
}
else {
img = "/css/default/images/finished_error.gif";
}
}
jxl.changeImage("uiWaitImg", img);
return answer.done;
}
function sendRequest() {
ajaxGet(url, callback);
}
function callback(xhr) {
var done = false;
if (xhr && xhr.status == 200) {
var answer = json(xhr.responseText || "null");
done = onAnswer(answer);
}
if (!done) {
setTimeout(sendRequest, 3000);
}
}
onAnswer(<?lua box.out(js.table(get_teststate())) ?>);
sendRequest();
}
function initAccount() {
init_email();
if (gProvider.name == g_data.initial_provider) {
jxl.setValue("uiServer", g_data.server);
jxl.setChecked("uiTls", Boolean(g_data.use_ssl));
jxl.setValue("uiPort", g_data.port);
}
}
function onValidationOk() {
var ok = check();
if (ok === false) {
return false;
}
var txt = [
"{?7858:719?}",
"{?7858:440?}"
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
function initCrashreport() {
disableOnClick({
inputName: "crashreport_mode",
classString: "disableif_crashreport:%1"
});
}
<?lua
if wizard.curr == 'dlg_account' then
box.out(fon_devices_html.get_email_config_js(g_data))
box.out([[
ready.onReady(initAccount);
ready.onReady(initCrashreport);
ready.onReady(ajaxValidation({
applyNames: "forward",
okCallback: onValidationOk
}));
]])
elseif wizard.curr == 'dlg_test' then
box.out([[
ready.onReady(waitForTestResult);
]])
end
?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('forward') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<input type="hidden" name="test" value="">
<?lua write_saveerror() ?>
<div id="dlg_account">
<h4>
{?7858:789?}
</h4>
{?7858:923?}
<?lua
box.out(fon_devices_html.get_email_config_html(g_data, {noheading=true}))
?>
<?lua write_crashreport() ?>
</div>
<div id="dlg_test">
<div class="wait">
<div>
{?7858:963?}
</div>
<p class="waitimg">
<img id="uiWaitImg" src="/css/default/images/wait.gif">
</p>
<div id="uiWaitMsg">
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.tohtml(g_back_to_page) ?>">
<?lua wizard.write_buttons() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
