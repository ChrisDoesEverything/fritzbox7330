<?lua
g_page_type = "wizard"
g_page_title = ""
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"general"
require"newval"
require"js"
require"html"
require"http"
require"href"
require"cmtable"
g_err = {code=0}
g_mode = ""
g_popup_url = ""
g_wlan = general.lazytable({}, box.query, {
ssid = {"wlan:settings/ssid"},
ssid_scnd = {"wlan:settings/ssid_scnd"},
encryption = {"wlan:settings/encryption"},
pskvalue = {"wlan:settings/pskvalue"},
recommend_ssid_change = {"wlan:settings/recommend_ssid_change"}
})
function init()
g_mode = box.get.mode or box.post.mode or ""
g_popup_url = box.get.popup_url or box.post.popup_url or ""
if box.post.mode == "edit" then
if not box.post.apply then
g_mode = "info"
end
end
if g_mode == "" then
g_mode = "info"
end
if g_mode == "info" then
g_page_title = [[{?432:624?}]]
elseif g_mode == "edit" then
g_page_title = [[{?432:760?}]]
end
end
function default_encryption()
if config.WLAN.default_wpa_mixed then
return "4"
else
return "3"
end
end
local function set_webuicookie(saveset)
if config.DOCSIS then
require"webuicookie"
webuicookie.set("docsisSetupDone", "1")
local save = saveset or {}
cmtable.add_var(save, webuicookie.vars())
if not saveset then
local err = box.set_config(save)
end
end
end
init()
local function valprog()
newval.msg.ssid_error_txt = {
[newval.ret.empty] = [[{?432:740?}]],
[newval.ret.toolong] = [[{?432:106?}]],
[newval.ret.outofrange] = [[{?432:159?}]],
[newval.ret.leadchar] = [[{?432:455?}]],
[newval.ret.endchar] = [[{?432:852?}]]
}
newval.not_empty("ssid", "ssid_error_txt")
newval.char_range("ssid", 32, 126, "ssid_error_txt")
newval.no_lead_char("ssid", 32, "ssid_error_txt")
newval.no_end_char("ssid", 32, "ssid_error_txt")
newval.msg.wpa_key_error_txt = {
[newval.ret.empty] = [[{?432:383?}]],
[newval.ret.toolong] = [[{?432:977?}]],
[newval.ret.tooshort] = [[{?432:160?}]],
[newval.ret.outofrange] = [[{?432:118?}]],
[newval.ret.leadchar] = [[{?432:521?}]],
[newval.ret.endchar] = [[{?432:187?}]]
}
newval.not_empty("pskvalue", "wpa_key_error_txt")
newval.length("pskvalue", 8, 63, "wpa_key_error_txt")
newval.char_range("pskvalue", 32, 126, "wpa_key_error_txt")
newval.no_lead_char("pskvalue", 32, "wpa_key_error_txt")
newval.no_end_char("pskvalue", 32, "wpa_key_error_txt")
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.leave then
set_webuicookie()
http.redirect("/assis/home.lua")
end
if box.post.apply then
if newval.validate(validation) == newval.ret.ok then
local saveset = {}
local ssid = box.post.ssid
if ssid then
cmtable.add_var(saveset, "wlan:settings/ssid", ssid)
if config.WLAN.is_double_wlan then
cmtable.add_var(saveset, "wlan:settings/ssid_scnd", ssid)
end
end
local pskvalue = box.post.pskvalue
if pskvalue then
cmtable.add_var(saveset, "wlan:settings/encryption", default_encryption())
cmtable.add_var(saveset, "wlan:settings/pskvalue", pskvalue)
end
set_webuicookie(saveset)
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(href.get(
box.glob.script, http.url_param("mode", "info"), http.url_param("popup_url", g_popup_url)
))
end
end
end
function write_saveerror()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
function write_buttons()
if g_mode == "info" then
html.button{type="submit", name="leave",
[[{?432:138?}]]
}.write()
html.button{type="submit", name="leave",
[[{?txtCancel?}]]
}.write()
elseif g_mode == "edit" then
html.button{type="submit", name="apply",
[[{?txtApplyOk?}]]
}.write()
html.button{type="submit", name="cancel",
[[{?txtCancel?}]]
}.write()
end
end
function write_info()
if g_mode == "info" then
html.p{
[[{?432:634?}]]
}.write()
html.div{class="formular widetext",
html.p{
[[{?432:850?}]]
},
html.span{class="label", [[{?432:798?}]]},
html.span{class="output", g_wlan.ssid or ""},
html.br{},
html.span{class="label", [[{?432:163?}]]},
html.span{class="output", g_wlan.pskvalue or ""}
}.write()
html.div{class="formular",
html.a{href=" ", id="uiPrintview", class="nocancel textlink",
[[{?432:965?}]]
}
}.write()
html.div{class="formular",
html.p{
[[{?432:861?}]]
},
html.img{src="/css/default/images/wlan_key_gua.png"}
}.write()
if g_wlan.recommend_ssid_change == "1" then
html.div{class="hint",
html.strong{[[{?txtHinweis?}]]},
html.p{
[[{?432:230?}]]
}
}.write()
end
html.div{class="btn_form",
html.a{class="nocancel textlink",
href=href.get(box.glob.script,
http.url_param("mode", "edit"), http.url_param("popup_url", g_popup_url)
),
[[{?432:519?}]]
}
}.write()
end
end
function write_edit()
if g_mode == "edit" then
html.p{
[[{?432:101?}]]
}.write()
html.div{class="formular widetext",
html.label{['for']="uiSsid",
[[{?432:596?}]]
},
html.input{type="text", name="ssid", id="uiSsid", value=g_wlan.ssid or ""},
html.br{},
html.label{['for']="uiPskvalue",
[[{?432:79?}]]
},
html.input{type="text", name="pskvalue", id="uiPskvalue", maxlength=63, value=g_wlan.pskvalue or ""},
html.p{class="form_input_note cnt_char", style="display:none;", id="uiCountKeyWpa",
html.span{id="uiDezKeyWpa", tostring(#(g_wlan.pskvalue or ""))},
[[ {?gNumOfChars?}]]
}
}.write()
html.div{class="formular hint",
html.strong{
[[{?txtHinweis?}]]
},
html.p{
[[{?432:685?}]]
}
}.write()
html.div{class="formular hint",
html.strong{
[[{?432:26?}]]
},
html.p{
[[{?432:916?}]]
}
}.write()
end
end
function write_hidden_inputs()
html.input{type="hidden", name="popup_url", value=g_popup_url}.write()
end
function write_popup_js()
if g_popup_url == "1" then
require("tr069")
local url = tr069.get_servicecenter_url()
box.js(url)
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
}
div.hint {
margin-top: 10px;
}
</style>
<script type="text/javascript" src="/js/dialog.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/password_checker.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
function initLeave() {
function onLeave(evt) {
openServiceCenter("<?lua write_popup_js() ?>");
}
var leave = jxl.getFormElements("leave");
var i = leave.length || 0;
while (i--) {
jxl.addEventHandler(leave[i], "click", onLeave);
}
}
function initPrintView() {
<?lua
g_no_auto_init_net_devices = true
require"net_devices"
net_devices.write_showPrintView_func("main")
?>
function onClick(evt) {
showPrintView();
return jxl.cancelEvent(evt);
}
jxl.addEventHandler("uiPrintview", "click", onClick);
}
function initPasswordChecker() {
createPasswordChecker("uiPskvalue", 8);
}
function initKeyCounter() {
function onKeyup(evt) {
var value = jxl.getValue("uiPskvalue");
jxl.setText("uiDezKeyWpa", value.length || 0);
}
jxl.addEventHandler("uiPskvalue", "keyup", onKeyup);
jxl.show("uiCountKeyWpa");
}
<?lua
if g_mode == "edit" then
box.out([[
ready.onReady(initKeyCounter);
ready.onReady(initPasswordChecker);
ready.onReady(ajaxValidation());
]])
else
box.out([[
ready.onReady(initPrintView);
ready.onReady(initLeave);
]])
end
?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="mode" value="<?lua box.html(g_mode) ?>">
<?lua write_hidden_inputs() ?>
<?lua write_saveerror() ?>
<div id="uiInfo">
<?lua write_info() ?>
</div>
<div id="uiEdit">
<?lua write_edit() ?>
</div>
<div id="btn_form_foot">
<?lua write_buttons() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
