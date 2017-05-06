<?lua
g_page_type = "wizard"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"wizard"
require"tr069"
require"general"
require"newval"
require"first"
require"js"
require"html"
require"isp"
local httpvar = setmetatable({post = box.post, get = box.get}, {
__index = function(self, key) return self.post[key] or self.get[key] end
})
wizard.wiztype = httpvar.wiztype or 'first'
wizard.is_lte_vodafone = wizard.wiztype == 'lte' and isp.is("vodafone", httpvar.provider or '1und1_lte')
wizard.dialogs = {
'dlg_sync',
'dlg_syncagain',
'dlg_startcode',
'dlg_provision',
'dlg_end'
}
wizard.title = setmetatable({
}, {__index = func.const([[{?2545:333?}]])}
)
if wizard.wiztype == 'umts' then
wizard.title.dlg_startcode = [[{?2545:131?}]]
wizard.title.dlg_provision = [[{?2545:388?}]]
wizard.title.dlg_end = [[{?2545:38?}]]
end
wizard.start = function()
if wizard.wiztype == 'first' then
return 'dlg_sync'
end
return 'dlg_startcode'
end
wizard.dlg_sync = {
forward = function()
if httpvar.post.dslcableok then
return 'dlg_syncagain'
end
return 'dlg_sync'
end,
backward = function() end
}
wizard.dlg_syncagain = {
forward = function() end,
backward = function() end
}
wizard.dlg_startcode = {
forward = function() return 'dlg_startcode' end,
backward = function() end
}
wizard.dlg_end = {
forward = function() return 'dlg_end' end,
backward = function() end
}
wizard.dlg_provision = {
forward = function() end,
backward = function() end
}
local function goto_fonwizard()
local page
local params = {}
if tr069.get_servicecenter_url() ~= "" then
table.insert(params, http.url_param("popup_url", "1"))
end
if wizard.wiztype == 'first' or wizard.wiztype == 'umts' then
table.insert(params, http.url_param("first_wizard", "1"))
end
local use_pstn = box.query("telcfg:settings/UsePSTN") == "1"
if wizard.wiztype == 'umts' or not use_pstn then
page = "/assis/assi_fondevices_list.lua"
http.redirect(href.get(page, unpack(params)))
end
-- ab hier gehts zu assi_fon_nums
page = "/assis/assi_fon_nums.lua"
if use_pstn then
table.insert(params, http.url_param("configure", "pstn"))
else
table.insert(params, http.url_param("configure", "inet"))
end
table.insert(params, http.url_param("back_to_page", "/assis/assi_fondevices_list.lua"))
table.insert(params, http.url_param("pagemaster", "/home/home.lua"))
http.redirect(href.get(page, unpack(params)))
end
local function goto_wlanwizard()
local page = "/assis/wlan_first.lua"
local params = {}
table.insert(params, http.url_param("wiztype", wizard.wiztype or ""))
if tr069.get_servicecenter_url() ~= "" then
table.insert(params, http.url_param("popup_url", "1"))
end
http.redirect(href.get(page, unpack(params)))
end
wizard.leave = function()
local dest = href.get("/home/home.lua")
http.redirect(dest)
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
end
function get_servicecenter_url()
local url = ""
if wizard.curr == 'dlg_end' or httpvar.prevdlg == 'dlg_end' then
url = tr069.get_servicecenter_url()
end
return url
end
local function vodafone_puk_validation()
newval.msg.pukerr = {
[newval.ret.wrong] = [[{?2545:582?}]],
[newval.ret.empty] = [[{?2545:24?}]],
[newval.ret.outofrange] = [[{?2545:446?}]]
}
if not newval.radio_check("needprovision", "yes") then
if not newval.radio_check("needprovision", "no") then
newval.const_error("x", "wrong", "pukerr")
end
else
newval.not_empty("puk", "pukerr")
newval.char_range_regex("puk", "decimals", "pukerr")
end
end
local function ui_startcode_validation()
local txt = {
[[{?2545:415?}]],
[[{?2545:930?}]],
[[{?2545:843?}]]
}
local get_txt = function(i)
return txt[i+1] .. "\\n\\n" .. [[{?2545:97?}]]
end
for i = 0, 2 do
newval.msg["startcodeerr" .. i] = {
[newval.ret.tooshort] = get_txt(i),
[newval.ret.toolong] = get_txt(i)
}
newval.length("startcode" .. i, 4, 4, "startcodeerr" .. i)
end
end
local startcode = {}
function startcode.validation()
if wizard.is_lte_vodafone then
vodafone_puk_validation()
else
ui_startcode_validation()
end
end
function startcode.convert(s0, s1, s2)
if s0 and s1 and s2 then
local user = s0 .. s1:sub(1, 1)
local pw = s1:sub(2) .. s2
return user, pw
end
end
function startcode.set_vars()
require"webuicookie"
require"cmtable"
require"isp"
local saveset = {}
local provider = '1und1'
if wizard.wiztype == 'lte' then
provider = httpvar.provider or '1und1_lte'
end
cmtable.add_var(saveset, "providerlist:settings/activeprovider", provider)
local user, pass
if wizard.is_lte_vodafone then
require"lted"
user = lted.imsi or ""
pass = box.post.puk or ""
else
user, pass = startcode.convert(box.post.startcode0, box.post.startcode1, box.post.startcode2)
end
if wizard.wiztype ~= 'lte' then
if wizard.wiztype ~= 'umts' then
local new_opmode = isp.opmode(provider)
if new_opmode then
cmtable.add_var(saveset, "box:settings/opmode", new_opmode)
end
end
cmtable.add_var(saveset, "connection0:settings/username", "1und1/" .. user .. "@online.de")
cmtable.add_var(saveset, "connection0:settings/password", pass)
if wizard.wiztype == 'umts' then
cmtable.add_var(saveset, "connection0:settings/mode", 'lcp')
cmtable.add_var(saveset, "connection0:settings/ProviderDisconnectPrevention/Enabled", "1")
cmtable.add_var(saveset, "connection0:settings/ProviderDisconnectPrevention/Hour", "4")
else
if isp.connmode_needed(provider) then
local connmode = isp.connmode_defaults(provider)
cmtable.add_var(saveset, "connection0:settings/mode", connmode.mode)
if connmode.idle then
cmtable.add_var(saveset, "connection0:settings/idle", connmode.idle)
end
local prevention = isp.prevention_defaults(provider)
if prevention.Enabled then
cmtable.add_var(saveset, "connection0:settings/ProviderDisconnectPrevention/Enabled", prevention.Enabled)
if prevention.Hour then
cmtable.add_var(saveset, "connection0:settings/ProviderDisconnectPrevention/Hour", prevention.Hour)
end
end
end
end
end
cmtable.add_var(saveset, "tr069:settings/username", user)
cmtable.add_var(saveset, "tr069:settings/password", pass)
if wizard.wiztype == 'lte' then
cmtable.add_var(saveset, "tr069:settings/enabled", "1")
webuicookie.set("lteSetupDone", "1")
cmtable.add_var(saveset, webuicookie.vars())
end
local c, e = box.set_config(saveset)
end
wizard.set_validation = function(dlg)
if dlg == 'dlg_startcode' then
return startcode.validation
end
end
local function build_dslsync_url(again)
local toptext = html.fragment()
if again then
toptext.add(
html.p{[[{?2545:515?}]]},
html.p{[[{?2545:632?}]]}
)
else
toptext.add(
html.strong{[[{?2545:281?} ]]},
html.p{[[{?2545:625?}]]}
)
end
local bottomtext = html.p{
[[{?2545:113?}]]
}
local url = "/internet/isp_change.lua"
local params = {
http.url_param("prevdlg", again and "dlg_syncagain" or "dlg_sync"),
http.url_param("query", "dslsync"),
http.url_param("pagetype", "wizard"),
http.url_param("pagemaster", box.glob.script),
http.url_param("title", wizard.title.dlg_sync),
http.url_param("toptext", toptext.get(true)),
http.url_param("bottomtext", bottomtext.get(true)),
http.url_param("poll", "5000"),
}
if wizard.wiztype then
table.insert(params, http.url_param("wiztype", wizard.wiztype))
end
return url .. "?" .. table.concat(params, "&")
end
local function onquery_dslsync()
local state = general.get_dsl_state()
local answer = {}
answer.done = state == "SHOWTIME"
if not answer.done then
local count = tonumber(box.get.addinfo) or 0
if count > 2 then
answer.done = true
answer.error = true
else
answer.addinfo = count + 1
end
end
return answer
end
local function build_provision_url()
local toptext = html.strong{
[[{?2545:344?}]]
}
local bottomtext = html.p{
[[{?2545:941?}]],
html.br{},
[[{?2545:526?}]]
}
local url = "/internet/isp_change.lua"
local provcount = tonumber(httpvar.provcount) or 3
provcount = provcount - 1
local params = {
http.url_param("provcount", provcount),
http.url_param("prevdlg", "dlg_startcode"),
http.url_param("query", "provision"),
http.url_param("pagetype", "wizard"),
http.url_param("pagemaster", box.glob.script),
http.url_param("title", wizard.title.provision),
http.url_param("toptext", toptext.get(true)),
http.url_param("bottomtext", bottomtext.get(true)),
http.url_param("poll", "10000"),
http.url_param("wiztype", wizard.wiztype or "")
}
if wizard.is_lte_vodafone then
table.insert(params, http.url_param("provider", httpvar.provider or ""))
end
return url .. "?" .. table.concat(params, "&")
end
local function ppp_notconnected()
require"opmode"
return opmode.is_ppp() and box.query("connection0:status/connect") == "3"
end
local function onquery_provision()
local answer = {}
local count = tonumber(box.get.addinfo) or 0
if not tr069.unprovisioned() then
answer.done = true
elseif count > 10 then
answer.done = true
answer.error = true
answer.errortype = "timeout"
elseif count > 3 and wizard.wiztype == 'first' then
if ppp_notconnected() then
answer.done = true
answer.error = true
answer.errortype = "configerr"
end
end
if not answer.done then
answer.addinfo = count + 1
end
return answer
end
if box.get.query == 'dslsync' then
local answer = onquery_dslsync()
box.out(js.table(answer))
box.end_page()
elseif box.get.query == 'provision' then
local answer = onquery_provision()
box.out(js.table(answer))
box.end_page()
end
function save_crash_report()
local saveset = {}
local crash_rep = "disabled_by_user"
if box.post.crashreport then
crash_rep = "to_support_only"
end
cmtable.add_var(saveset, "emailnotify:settings/crashreport_mode", crash_rep)
local err, msg = box.set_config(saveset)
end
local function setvars_onleave()
local saveset = {}
cmtable.add_var(saveset, "tr069:settings/suppress_autoFWUpdate_notify", "1")
if config.oem == '1und1' then
cmtable.add_var(saveset, "tr069:settings/FWdownload_enable", "1")
end
local e, m = box.set_config(saveset)
end
require("general")
if box.post.validate == "forward" then
local valprog = wizard.set_validation(box.post.prevdlg)
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
setvars_onleave()
wizard.leave()
elseif httpvar.inetwizard then
setvars_onleave()
http.redirect(href.get(
"/assis/internet_dsl.lua",
http.url_param("wiztype", "first")
))
elseif box.post.forward and httpvar.prevdlg == 'dlg_end' then
setvars_onleave()
save_crash_report()
if box.post.onleave == "fonwizard" then
goto_fonwizard()
elseif box.post.onleave == "wlanwizard" then
goto_wlanwizard()
end
end
wizard.init()
if box.post.provcount then
wizard.curr = 'dlg_startcode'
elseif httpvar.ispchangedone then
local err = httpvar.ispchangedone == "error"
if httpvar.prevdlg == 'dlg_sync' then
wizard.curr = err and 'dlg_sync' or 'dlg_startcode'
elseif httpvar.prevdlg == 'dlg_syncagain' then
wizard.curr = err and 'dlg_syncagain' or 'dlg_startcode'
elseif httpvar.prevdlg == 'dlg_startcode' then
wizard.curr = err and 'dlg_provision' or 'dlg_end'
end
end
if wizard.curr == 'dlg_sync' then
if not httpvar.ispchangedone then
local url = build_dslsync_url()
http.redirect(url)
end
elseif wizard.curr == 'dlg_syncagain' then
if box.post.dslcableok then
local url = build_dslsync_url(true)
http.redirect(url)
else
wizard.override_btntext("cancel", [[{?2545:275?}]])
end
elseif wizard.curr == 'dlg_end' then
if wizard.wiztype == "first" or wizard.wiztype == 'umts' then
wizard.override_btntext("cancel", [[{?2545:404?}]])
wizard.noconfirm_oncancel = true
end
end
if wizard.curr == 'dlg_startcode' then
if box.post.forward and box.post.prevdlg == 'dlg_startcode' then
local valprog = wizard.set_validation('dlg_startcode')
if newval.validate(valprog) ~= newval.ret.ok then
wizard.curr = 'dlg_startcode'
elseif box.post.needprovision == "no" then
require"webuicookie"
local saveset = {}
webuicookie.set("lteSetupDone", "1")
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
http.redirect(href.get("assis/home.lua"))
else
startcode.set_vars()
local url = build_provision_url()
http.redirect(url)
end
end
end
if wizard.title then
g_page_title = wizard.title[wizard.curr]
end
function write_nostartcode_link()
if wizard.wiztype == 'first' then
local link = href.get(box.glob.script, http.url_param("inetwizard", ""))
local txt = general.sprintf(
box.tohtml(
[[{?2545:452?}]]
),
[[<a class="nocancel" href="]] .. link .. [[">]],
[[</a>]]
)
html.br{}.write()
html.p{html.raw(txt)}.write()
end
end
local function write_vodafone_superpin_html()
html.p{
[[{?2545:61?}]]
}.write()
html.div{class="formular",
html.input{type="radio", name="needprovision", value="yes", id="uiNeedprovision:yes"},
html.label{['for']="uiNeedprovision:yes", [[{?2545:950?}]]},
html.div{class="formular enableif_needprovision_yes",
html.label{['for']="uiPuk",
[[{?2545:1402?}]]
},
html.input{type="text", name="puk", id="uiPuk", value=""}
}
}.write()
html.div{class="formular",
html.input{type="radio", name="needprovision", value="no", id="uiNeedprovision:no"},
html.label{['for']="uiNeedprovision:no", [[{?2545:91?}]]}
}.write()
end
local function write_1und1_startcode_html()
if wizard.wiztype == 'first' then
html.h4{
[[{?2545:479?}]]
}.write()
end
if wizard.wiztype == 'umts' then
html.p{
[[{?2545:10?}]]
}.write()
else
html.p{
[[{?2545:710?}]]
}.write()
end
html.div{
html.img{src="/css/default/images/sealer.jpg", width="375", height="150",
title=[[{?2545:839?}]]
}
}.write()
html.p{
[[{?2545:609?}]]
}.write()
html.div{class="formular", id="uiStartcode",
html.label{['for']="uiStartcode0">
[[{?2545:674?}]]
},
html.input{
type="text", name="startcode0", id="uiStartcode0", size="5", maxlength="4", autocomplete="off",
value=box.post.startcode0 or ""
},
html.span{[[ - ]]},
html.input{
type="text", name="startcode1", id="uiStartcode1", size="5", maxlength="4", autocomplete="off",
value=box.post.startcode1 or ""
},
html.span{[[ - ]]},
html.input{
type="text", name="startcode2", id="uiStartcode2", size="5", maxlength="4", autocomplete="off",
value=box.post.startcode2 or ""
}
}.write()
write_nostartcode_link()
end
function write_dlg_startcode()
if wizard.is_lte_vodafone then
write_vodafone_superpin_html()
else
write_1und1_startcode_html()
end
end
local function sipnumbers_table()
local tbl = html.table{id="uiSipnumbers"}
local sip = general.listquery("sip:settings/sip/list(username,displayname)")
for i, elem in ipairs(sip) do
local username = elem.username or ""
local displayname = elem.displayname or ""
local idx = username:find(displayname)
local okz = username:sub(1, idx and (idx - 1))
idx = okz:find("49")
if idx then
okz = okz:sub(idx + 2)
if okz:at(1) ~= "0" then
okz = "0" .. okz
end
tbl.add(html.tr{
html.td{class="okz", okz},
html.td{class="sep", [[ / ]]},
html.td{class="num", displayname}
})
end
end
return tbl
end
local function write_end_numbers()
if wizard.wiztype ~= 'umts' then
html.div{
html.p{
wizard.wiztype == 'lte' and
[[{?2545:783?}]]
or [[{?2545:521?}]]
},
sipnumbers_table(),
html.p{
[[{?2545:549?}]]
}
}.write()
end
end
function write_end()
if wizard.wiztype == 'umts' then
html.div{class="wait",
html.h4{[[{?2545:785?}]]},
html.p{class="waitimg", html.img{src="/css/default/images/finished_ok_green.gif"}}
}.write()
else
html.h4{[[{?2545:890?}]]}.write()
end
if wizard.wiztype == 'first' then
html.p{
[[{?2545:51?}]]
}.write()
end
write_end_numbers()
html.hr{}.write()
html.h4{[[{?2545:247?}]]}.write()
html.input{type="radio", name="onleave", id="uiOnleave:fonwizard", value="fonwizard"}.write()
html.label{['for']="uiOnleave:fonwizard",
[[{?2545:8?}]]
}.write()
html.br{}.write()
html.input{type="radio", name="onleave", id="uiOnleave:wlanwizard", value="wlanwizard"}.write()
html.label{['for']="uiOnleave:wlanwizard",
[[{?2545:767?}]]
}.write()
local checked = box.query("emailnotify:settings/crashreport_mode") ~= "disabled_by_user"
html.div{
html.hr{},
html.h4{[[{?2545:538?}]]},
html.p{
html.input{type="checkbox", id="uiCrashreport", name="crashreport", checked=checked},
html.label{['for']="uiCrashreport",
[[{?2545:366?}]]
}
},
html.p{
[[{?2545:634?}]]
},
}.write()
end
function write_servicecard()
html.p{
[[{?2545:108?}]]
}.write()
html.div{
html.img{src="/css/default/images/servicecard.jpg", width="180", height="90", title="{?2545:261?}"}
}.write()
end
function write_dsltest_link()
html.p{
html.a{class="nocancel",
href = href.get("/internet/dsl_test.lua", http.url_param("back_to_page", "/home/home.lua")),
[[{?2545:224?}]]
}
}.write()
end
function write_provision_error()
local reason = [[{?2545:87?}]]
if ppp_notconnected() then
reason = box.query("connection0:pppoe:status/detail")
end
html.p{
[[{?2545:507?}]],
html.div{class="formular", html.em{reason}}
}.write()
local provcount = tonumber(httpvar.provcount) or 0
if provcount > 0 then
html.p{
[[{?2545:763?}]]
}.write()
html.div{class="btn_form",
html.button{id="uiProvcount", type="submit", name="provcount", value=tostring(provcount),
[[{?2545:827?}]]
}
}.write()
end
if wizard.wiztype == 'first' then
html.p{
provcount > 0 and
[[{?2545:897?}]]
or [[{?2545:530?}]]
}.write()
html.div{class="btn_form",
html.button{id="uiInetwizard", type="submit", name="inetwizard",
[[{?2545:109?}]]
}
}.write()
end
if wizard.wiztype ~= 'lte' then
html.p{
wizard.wiztype == 'umts' and
[[{?2545:92?}]]
or [[{?2545:628?}]]
}.write()
write_servicecard()
end
end
function write_hidden_params()
if wizard.wiztype == 'lte' then
html.input{type="hidden", name="provider", value=tostring(httpvar.provider or '1und1_lte')}.write()
end
if wizard.curr == 'dlg_startcode' then
local provcount = tonumber(httpvar.provcount)
if provcount then
html.input{type="hidden", name="provcount", value=tostring(provcount)}.write()
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
<?lua wizard.write_css() ?>
table#uiSipnumbers {margin: 10px 50px;}
table#uiSipnumbers td.okz {width: 50px; text-align: right;}
table#uiSipnumbers td.sep {width: 10px; text-align: center;}
table#uiSipnumbers td.num {width: 150px; text-align: left;}
div.btn_form button {
width: 300px;
}
</style>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/dialog.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
function initForwardEnable() {
wizard.disable("forward");
var radios = jxl.getFormElements("onleave");
function onRadio(evt) {
wizard.enable("forward");
var i = radios.length || 0;
while (i--) {
jxl.removeEventHandler(radios[i], "click", onRadio);
}
}
var i = radios.length || 0;
while (i--) {
jxl.addEventHandler(radios[i], "click", onRadio);
}
}
function onLeave() {
openServiceCenter("<?lua box.js(get_servicecenter_url()) ?>");
}
function initLeave() {
var cancel = jxl.getFormElements('cancel');
if (cancel) {
var i = cancel.length || 0;
while (i--) {
if (cancel[i].type == "submit") {
jxl.addEventHandler(cancel[i], 'click', onLeave);
}
}
}
jxl.addEventHandler("uiFinish", 'click', onLeave);
}
function onDslcableok(evt) {
var checkbox = jxl.evtTarget(evt);
if (checkbox) {
wizard.setEnabled("forward", checkbox.checked);
}
}
function initDslsync() {
wizard.disable("forward");
jxl.addEventHandler("uiDslcableok", "click", onDslcableok);
enableOnClick({
inputName: "dslcableok",
classString: "enableif_dslcableok"
});
}
function initStartcode() {
fc.init("uiStartcode", 4, "", "uiForward");
enableOnClick({
inputName: "needprovision",
classString: "enableif_needprovision_%1"
});
}
<?lua
if wizard.curr == 'dlg_startcode' then
box.out("\n", [[ready.onReady(initStartcode);]])
elseif wizard.curr == 'dlg_sync' then
box.out("\n", [[ready.onReady(initDslsync);]])
elseif wizard.curr == 'dlg_end' then
box.out("\n", [[ready.onReady(initLeave);]])
box.out("\n", [[ready.onReady(initForwardEnable);]])
end
?>
ready.onReady(ajaxValidation({
applyNames: "forward"
}));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.out(box.glob.script) ?>"
class="narrow <?lua wizard.write_class() ?>">
<?lua href.default_submit('forward') ?>
<input type="hidden" name="sid" value="<?lua box.out(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<?lua write_hidden_params() ?>
<?lua wizard.write_1und1_logo() ?>
<div id="dlg_sync">
<h4>
{?2545:250?}
</h4>
<p>
{?2545:189?}
</p>
<div class="formular">
<input type="checkbox" name="dslcableok" id="uiDslcableok">
<label for="uiDslcableok">{?2545:605?}</label>
<p class="form_input_explain enableif_dslcableok">
{?2545:543?}
</p>
</div>
</div>
<div id="dlg_syncagain">
<h4>
{?2545:715?}
</h4>
<p>{?2545:57?}</p>
<p>{?2545:328?}</p>
<p>{?2545:957?}</p>
<?lua write_servicecard() ?>
<p>{?2545:591?}
</p>
<?lua write_dsltest_link() ?>
</div>
<div id="dlg_startcode">
<?lua write_dlg_startcode() ?>
</div>
<div id="dlg_end">
<?lua write_end() ?>
</div>
<div id="dlg_provision">
<h4>
{?2545:280?}
</h4>
<?lua write_provision_error() ?>
</div>
<div id="btn_form_foot">
<?lua wizard.write_buttons() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
