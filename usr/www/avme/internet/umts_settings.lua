<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_gsm_gsm.html"
dofile("../templates/global_lua.lua")
require"umts"
require"umts_html"
require"html"
require"href"
require"general"
require"val"
require"http"
require"opmode"
require"cmtable"
require"fon_numbers"
g_err, g_errmsg = 0
g_val = {prog=""}
g_val_confirm = {confirm=true, prog=""}
g_data = nil
g_accounts = umts.providerlist()
local function read_data(from_post)
local data = {}
if from_post then
data = {
PIN = box.post.PIN,
PUK = box.post.PUK,
on_demand = box.post.on_demand,
idle = box.post.idle,
AllowRoaming = box.post.AllowRoaming and "1" or "0",
voip_over_mobile = box.post.voip_over_mobile and "1" or "0",
usbtethering_mode = box.post.usbtethering_mode and "1" or "0",
account = box.post.account,
activation = box.post.activation or "disabled"
}
if data.account then
local p = g_accounts[data.account] or {}
data.provider = box.post.provider or p.provider or ""
data.number = box.post.number or p.number or ""
data.username = box.post.username or p.username or ""
data.password = box.post.password or p.password or ""
end
if umts.is_voice_modem() then
data.msnactive = box.post.msnactive and "1" or "0"
data.MSN = box.post.MSN or ""
data.msnname = box.post.msnname or ""
data.OKZ = box.post.OKZ or ""
data.UsePrefix = box.post.UsePrefix and "1" or "0"
end
else
data = {
account = umts.name,
provider = umts.provider,
number = umts.number,
username = umts.username,
password = umts.password,
on_demand = umts.on_demand,
idle = umts.idle or "300",
AllowRoaming = umts.AllowRoaming,
voip_over_mobile = box.query("sipextra:settings/sip/voip_over_mobile"),
usbtethering_mode = box.query("box:settings/usbtethering_mode")
}
if data.idle == "0" then
data.idle = "300"
end
if umts.backup_enable == "1" then
data.activation = "fallback"
elseif umts.enabled == "1" then
data.activation = "enabled"
else
data.activation = "disabled"
end
if umts.is_voice_modem() then
data.MSN = box.query("telcfg:settings/Mobile/MSN")
data.msnactive = data.MSN ~= "" and "1" or "0"
data.msnname = box.query("telcfg:settings/Mobile/Name")
data.OKZ = box.query("telcfg:settings/Location/OKZ")
data.UsePrefix = box.query("telcfg:settings/Mobile/UsePrefix")
end
end
return data
end
g_data = read_data(box.post.apply)
function umts_available()
return not general.is_wdsrepeater() and not general.is_ip_client()
end
function show_usbtethering()
return opmode.value == "opmode_usb_tethering"
or box.query("ctlusb:settings/tethering_device") ~= ""
or g_data.usbtethering_mode == "1"
end
function wlan_ata()
return opmode.value == "opmode_wlan_ip"
and box.query("wlan:settings/bridge_mode") == "bridge-ata"
end
local function count_span(count)
if count then
return html.span{class="form_input_explain postfix",
general.sprintf([[{?2653:31?}]], tostring(count))
}
end
end
function write_pin_input()
local html_id = {PIN="uiPIN", PUK="uiPUK"}
local pininfo = umts_html.get_pininfo()
html.h4{[[{?2653:111?}]]}.write()
html.div{class="formular", html.p{pininfo.msg}}.write()
if umts.pin_needed('PUK') then
html.div{class="formular",
html.label{['for']="uiPUK", [[{?2653:347?}]]},
html.input{type="text", name="PUK", id="uiPUK", autocomplete="off",
value=g_data.PUK or "", class=val.get_error_class(g_val, "uiPUK")
},
count_span(pininfo.pukcount),
html.raw(val.get_html_msg(g_val, "uiPUK"))
}.write()
end
if not umts.pin_ready() then
local disable_class = pininfo.disabled and " disableNode" or ""
html.div{class="formular" .. disable_class,
html.label{['for']="uiPIN", pininfo.pinlabel},
html.input{type="text", name="PIN", id="uiPIN", maxlength="8", autocomplete="off",
value=g_data.PIN or "", class=val.get_error_class(g_val, "uiPIN"), disabled=pininfo.disabled
},
count_span(pininfo.pincount),
html.raw(val.get_html_msg(g_val, "uiPIN"))
}.write()
end
end
function write_roaming()
local disabled = not umts.pin_ready()
local disable_class = disabled and " disableNode" or ""
html.div{class="formular" .. disable_class,
html.input{type="checkbox", id="uiAllowRoaming", name="AllowRoaming",
checked=g_data.AllowRoaming == "1", disabled=disabled,
},
html.label{['for']="uiAllowRoaming",
[[{?2653:815?}]]
}
}.write()
end
local function operator()
local txt = umts.Operator or ""
if txt == "unknown" or txt == "" then
txt = [[{?2653:866?}]]
end
return txt
end
function write_net_table()
html.div{class="formular",
html.br{},
html.h4{[[{?2653:155?}]]},
html.table{class="zebra",
html.tr{
html.th{class="rssi", title=[[{?2653:194?}]],
html.img{src="/css/default/images/umts_antenna.gif", width=11, height=13}
},
html.th{class="homezone"},
html.th{class="status", [[{?2653:669?}]]},
html.th{[[{?2653:68?}]]},
html.th{[[{?2653:366?}]]}
},
html.tr{
html.td{class="rssi", umts_html.quality_img()},
html.td{class="homezone", umts_html.homezone_img()},
html.td{class="status", (umts_html.connect_state())},
html.td{operator()},
html.td{
html.a{href=href.get("/internet/inetstat_monitor.lua"), [[{?2653:271?}]]}
}
}
}
}.write()
end
local function get_progress_img(dowait)
local src
local style
if dowait then
src = "/css/default/images/wait.gif"
else
local netstate = umts.networkstate()
if umts.registered() then
src = "/css/default/images/finished_ok_green.gif"
elseif netstate == "searching" then
src = "/css/default/images/wait.gif"
elseif netstate == "registration_denied" then
src = "/css/default/images/finished_error.gif "
end
if not src then
src = "/css/default/images/wait.gif"
style = "display:none;"
end
end
return html.img{id="uiProgressImg", src=src, style=style}
end
local function get_progress_info()
local info = {}
local continue_polling = false
if umts.pinstate() == "pinchecking" then
continue_polling = true
end
if umts.enabled == "0" and umts.Established == "1" then
continue_polling = true
end
local netstate = umts.networkstate()
local txt = umts_html.state_txt[netstate]
if umts.registered() then
info.bottomtext = (umts_html.connect_state())
elseif netstate == "disabled" then
if umts.ModemPresent ~= "1" or not umts.sim_ok() or umts.pin_ready() then
continue_polling = true
end
if umts.ModemPresent ~= "1" then
info.toptext = txt.nomodem
elseif not umts.sim_ok() then
info.toptext = txt.simproblem
elseif umts.pin_needed('PIN') or umts.pin_needed('PUK') then
info.progress_hide = true
else
info.toptext = txt.default
end
else
info.bottomtext = txt
end
if netstate == "unknown" or netstate == "searching" then
continue_polling = true
end
info.poll = 0
if continue_polling then
info.poll = 2000
end
return info
end
function write_progress()
local info = get_progress_info()
html.div{class="formular",
html.input{type="hidden", id="uiPoll", value=info.poll},
html.div{id="uiProgress", class="wait",
html.div{id="uiWaitTop",
html.p{info.toptext}
},
html.p{class="waitimg", get_progress_img(info.poll > 0)},
html.div{id="uiWaitBottom",
html.p{info.bottomtext}
}
},
html.div{class="btn_form",
html.button{id="uiUpdateButton", type="button",
[[{?txtRefresh?}]]
}
}
}.write()
end
function write_ondemand()
html.h4{[[{?2653:4363?}]]}.write()
html.p{[[{?2653:722?}]]}.write()
local idle_str = general.sprintf(
box.tohtml([[{?2653:170?}]]),
html.input{
type="text", name="idle", id="uiIdle", size="3", maxlength="3",
class="numbers inner enableif_on_demand:1", value=g_data.idle or ""
}.get()
)
html.div{class="formular disableif_umts:disabled",
html.input{type="radio", name="on_demand", id="uiOn_demand:1", value="1", checked=g_data.on_demand == "1"},
html.label{['for']="uiOn_demand:1", html.raw(idle_str)}
}.write()
html.div{class="formular disableif_umts:disabled",
html.input{type="radio", name="on_demand", id="uiOn_demand:0", value="0", checked=g_data.on_demand ~= "1"},
html.label{['for']="uiOn_demand:0", [[{?2653:130?}]]}
}.write()
end
function write_voip_over_mobile()
html.h4{[[{?2653:315?}]]}.write()
html.div{class="formular",
html.input{type="checkbox", id="uiVoip_over_mobile", name="voip_over_mobile", checked=g_data.voip_over_mobile == "1"},
html.label{['for']="uiVoip_over_mobile", [[{?2653:956?}]]},
html.div{class="form_checkbox_explain",
html.p{[[{?2653:809?}]]},
html.br{},
html.strong{[[{?txtHinweis?}]]},
html.p{[[{?2653:556?}]]}
}
}.write()
end
local function okz_display(val)
if val and val:at(1) ~= "0" then
val = "0" .. val
end
return val or ""
end
local function okz_convert(value)
if value:at(1) == "0" then
value = value:sub(2)
end
return value
end
local function msn_convert(value)
value = value:gsub("^%s*%+%s*49", "0")
value = value:gsub("[^%d]", "")
return value
end
function write_msn()
html.h4{[[{?2653:240?}]]}.write()
html.div{class="formular",
html.input{type="checkbox", id="uiMsnactive", name="msnactive", checked = g_data.msnactive == "1"},
html.label{['for']="uiMsnactive", [[{?2653:963?}]]},
html.div{class="enableif_msnactive",
html.p{class="form_checkbox_explain", [[{?2653:367?}]]},
html.div{class="formular",
html.label{['for']="uiMSN", [[{?txtRufnummer?}]]},
html.input{type="text", maxlength="20", id="uiMSN", name="MSN", value=g_data.MSN}
},
general.is_expert() and
html.div{class="formular",
html.label{['for']="uiMsnname", [[{?2653:995?}]]},
html.input{type="text", maxlength="16", id="uiMsnname", name="msnname", value=g_data.msnname}
} or nil,
html.div{class="formular",
html.input{type="checkbox", id="uiUsePrefix", name="UsePrefix",checked=g_data.UsePrefix == "1"},
html.label{['for']="uiUsePrefix", [[{?2653:537?}]]}
},
html.div{class="formular enableif_UsePrefix",
html.label{['for']="uiOKZ", [[{?2653:182?}]]},
html.input{type="text", id="uiOKZ", name="OKZ", value=okz_display(g_data.OKZ)},
html.span{class="form_input_explain postfix", [[{?2653:756?}]]}
}
}
}.write()
end
function write_noumts_explain()
html.p{
[[{?2653:166?}]]
}.write()
local wds = general.is_wdsrepeater()
local ipclient = general.is_ip_client()
if wds then
local wdslink, wdstext
if config.WLAN_WDS2 then
html.p{
[[{?2653:688?}]]
}.write()
wdslink = "/wlan/wds2.lua"
wdstext = [[{?2653:426?}]]
else
html.p{
[[{?2653:534?}]]
}.write()
wdslink = "/wlan/wds.lua"
wdstext = [[{?2653:92?}]]
end
html.p{html.raw(general.sprintf(
box.tohtml([[{?2653:694?}]]),
html.a{href=href.get(wdslink), wdstext}.get(true)
))}.write()
elseif ipclient then
html.p{
[[{?2653:958?}]]
}.write()
html.p{html.raw(general.sprintf(
box.tohtml([[{?2653:422?}]]),
html.a{href=href.get("/internet/internet_settings.lua"), [[{?2653:445?}]]}.get(true)
))}.write()
end
end
local function get_tethering_config_link()
local yes = opmode.value == "opmode_usb_tethering" and g_data.usbtethering_mode == "1"
if yes then
yes = box.query("ctlusb:settings/tethering_device") ~= ""
end
if yes then
local dns = general.listquery("dnsserver:status/dnsserver/list(state,addr)")
local i, srv = array.find(dns, func.eq("best", "state"))
if srv and srv.addr and srv.addr ~= "" then
return html.p{html.raw(general.sprintf(
box.tohtml([[{?2653:119?} ]]),
html.a{href="http://" .. srv.addr, target="_blank", srv.addr}.get(true)
))}
end
end
end
function write_usb_tethering()
html.h4{[[{?2653:267?}]]}.write()
html.div{class="formular",
html.input{
type="checkbox", id="uiUsbtethering_mode", name="usbtethering_mode",
checked=g_data.usbtethering_mode == "1"
},
html.label{['for']="uiUsbtethering_mode",
[[{?2653:509?}]]
},
html.div{class="form_checkbox_explain",
html.p{
[[{?2653:798?}]]
},
get_tethering_config_link(),
html.br{},
html.strong{[[{?2653:385?}]]},
html.ul{class="hintlist",
html.li{[[{?2653:124?}]]},
html.li{html.raw(general.sprintf(
box.tohtml([[{?2653:812?}]]),
[[<a href="]] .. href.get("/system/export.lua") .. [[">]], [[</a>]]
))},
html.li{html.raw(general.sprintf(
box.tohtml([[{?2653:661?}]]),
[[<a href="]] .. href.get("/internet/internet_settings.lua") .. [[">]], [[</a>]]
))}
}
}
}.write()
end
function write_umts_enable()
html.p{
[[{?2653:171?}]]
}.write()
local with_fallback = config.DSL or config.VDSL or ( config.GUI_IS_6490 and config.DOCSIS )
local checked = g_data.activation == "enabled"
html.div{class="formular",
html.input{type="radio", id="uiActivation:enabled", name="activation", value="enabled", checked=checked},
html.label{['for']="uiActivation:enabled", [[{?2653:410?}]]},
html.p{class="form_checkbox_explain",
[[{?2653:760?}]]
}
}.write()
local ignore_fallback = false
if with_fallback then
local label_txt = [[{?2653:921?}]]
local explain_txt1 = [[{?2653:535?}]]
local explain_txt2 = [[{?2653:898?}]]
if config.DOCSIS then
label_txt = [[{?2653:298?}]]
explain_txt1 = [[{?2653:261?}]]
explain_txt2 = [[{?2653:901?}]]
end
ignore_fallback = general.is_atamode()
local disable_class = ignore_fallback and " disableNode" or ""
checked = not ignore_fallback and g_data.activation == "fallback"
html.div{class="formular" .. disable_class,
html.input{type="radio", id="uiActivation:fallback", name="activation", value="fallback", checked=checked, disabled=ignore_fallback},
html.label{['for']="uiActivation:fallback", label_txt},
html.p{class="form_checkbox_explain",
explain_txt1,
html.br{},
explain_txt2
}
}.write()
end
checked = g_data.activation == "disabled" or ignore_fallback and g_data.activation == "fallback"
html.div{class="formular",
html.input{type="radio", id="uiActivation:disabled", name="activation", value="disabled",checked=checked},
html.label{['for']="uiActivation:disabled", [[{?2653:611?}]]}
}.write()
end
function write_hints()
html.div{id="uiVolumeHint", class="hideif_umts:disabled",
html.h4{[[{?2653:532?}]]},
html.div{class="formular",
html.p{html.raw(general.sprintf(
box.tohtml([[{?2653:515?}]]),
[[<a href="]] .. href.get("/internet/inetstat_counter.lua") .. [[">]], [[</a>]]
))},
html.p{style="color:#0066CC;",
[[{?2653:996?}]]
}
}
}.write()
html.hr{class="hideif_umts:disabled"}.write()
html.h4{[[{?txtHinweis?}]]}.write()
html.div{class="formular",
html.p{html.raw(general.sprintf(
box.tohtml([[{?2653:295?}]]),
[[<a href="]] .. href.get("/internet/inetstat_budget.lua") .. [[">]], [[</a>]]
))},
html.p{
[[{?2653:625?}]]
},
html.ul{class="hintlist",
html.li{[[{?2653:729?}]]},
html.li{[[{?2653:207?}]]},
html.li{[[{?2653:804?}]]}
}
}.write()
end
if box.get.update == "uiNetstate" then
write_pin_input()
write_roaming()
write_net_table()
write_progress()
box.end_page()
end
local function pin_validation()
local puk_prog = [[
not_empty(uiPUK/PUK, pukerr)
char_range_regex(uiPUK/PUK, decimals, pukerr)
]]
local pin_prog = [[
length(uiPIN/PIN, 4, 8, pinerr)
char_range_regex(uiPIN/PIN, decimals, pinerr)
]]
val.msg.pinerr = {
[val.ret.tooshort] = [[{?2653:972?}]],
[val.ret.toolong] = [[{?2653:981?}]],
[val.ret.outofrange] = [[{?2653:545?}]]
}
val.msg.pukerr = {
[val.ret.empty] = [[{?2653:352?}]],
[val.ret.outofrange] = [[{?2653:141?}]]
}
if umts.pin_needed('PUK') then
return puk_prog .. pin_prog
elseif umts.pin_needed('PIN') then
return pin_prog
else
return ""
end
end
local function voip_over_mobile_validation()
if fon_numbers.get_number_count("sip") > 0 then
val.msg.voip_over_mobile = {
[val.ret.wrong] = [[{?2653:683?}]]
}
return [[
if __checked(uiVoip_over_mobile/voip_over_mobile) then
if __not_radio_check(uiActivation:disabled/activation,disabled) then
const_error(uiX/x, wrong, voip_over_mobile)
end
end
]]
else
return ""
end
end
local function msn_validation()
if umts.is_voice_modem() then
val.msg.msnerr = {
[val.ret.outofrange] = [[{?2653:705?}]]
}
val.msg.msnerr2 = {
[val.ret.outofrange] = [[{?2653:404?}]],
}
val.msg.numerr = {
[val.ret.outofrange] = [[{?2653:888?}]]
}
val.msg.okzerr = {
[val.ret.outofrange] = [[{?2653:885?}]]
}
return [[
if __checked(uiMsnactive/msnactive) then
char_range_regex(uiMSN/MSN, anynonwhitespace, msnerr2)
char_range_regex(uiMSN/MSN, fonnum, msnerr)
if __checked(uiUsePrefix/UsePrefix) then
char_range_regex(uiOKZ/OKZ, decimals, numerr)
char_range_regex(uiOKZ/OKZ, okz, okzerr)
end
end
]]
else
return ""
end
end
g_val.prog = pin_validation()
.. "\n" .. umts_html.account_validation(val)
.. "\n" .. msn_validation()
g_val_confirm.prog = voip_over_mobile_validation()
if box.post.apply and val.validate(g_val) == val.ret.ok then
local saveset = {}
if show_usbtethering() then
cmtable.add_var(saveset, "box:settings/usbtethering_mode", g_data.usbtethering_mode)
end
if not umts.sim_ok() then
cmtable.add_var(saveset, "umts:settings/enabled", "0")
if config.DSL or config.VDSL or ( config.GUI_IS_6490 and config.DOCSIS ) then
cmtable.add_var(saveset, "umts:settings/backup_enable", "0")
end
else
local pinset = false
local pin_needed = umts.pin_needed('PIN')
local puk_needed = umts.pin_needed('PUK')
if pin_needed or puk_needed then
if puk_needed then
cmtable.add_var(saveset, "gsm:settings/PUK", g_data.PUK)
end
cmtable.add_var(saveset, "gsm:settings/PIN", g_data.PIN)
pinset = true
end
cmtable.add_var(saveset, "gsm:settings/AllowRoaming", g_data.AllowRoaming)
local enabled, backup_enable
if g_data.activation == "fallback" then
if general.is_atamode() then
backup_enable = "0"
elseif umts.backup_enable ~= "1" then
backup_enable = "1"
enabled = "0"
end
elseif g_data.activation == "enabled" then
enabled = "1"
backup_enable = "0"
else
enabled = "0"
backup_enable = "0"
end
if enabled then
cmtable.add_var(saveset, "umts:settings/enabled", enabled)
if wlan_ata() then
cmtable.add_var(saveset, "wlan:settings/bridge_mode", "bridge-none")
end
end
if backup_enable then
cmtable.add_var(saveset, "umts:settings/backup_enable", backup_enable)
end
end
if g_data.account then
cmtable.add_var(saveset, "umts:settings/name", g_data.account)
if g_data.account == "" then
cmtable.add_var(saveset, "umts:settings/provider", g_data.provider)
cmtable.add_var(saveset, "umts:settings/number", g_data.number)
cmtable.add_var(saveset, "umts:settings/username", g_data.username)
cmtable.add_var(saveset, "umts:settings/password", g_data.password)
end
end
if g_data.on_demand then
cmtable.add_var(saveset, "umts:settings/on_demand", g_data.on_demand)
if g_data.on_demand == "1" then
cmtable.add_var(saveset, "umts:settings/idle", g_data.idle)
end
end
cmtable.add_var(saveset, "sipextra:settings/sip/voip_over_mobile", g_data.voip_over_mobile)
if g_data.msnactive == "1" then
cmtable.add_var(saveset, "telcfg:settings/Mobile/MSN", msn_convert(g_data.MSN))
if g_data.msnname then
cmtable.add_var(saveset, "telcfg:settings/Mobile/Name", g_data.msnname)
end
cmtable.add_var(saveset, "telcfg:settings/Mobile/UsePrefix", g_data.UsePrefix)
if g_data.UsePrefix == "1" then
cmtable.add_var(saveset, "telcfg:settings/Location/OKZ", okz_convert(g_data.OKZ))
cmtable.add_var(saveset, "telcfg:settings/Location/OKZPrefix", "0")
end
else
cmtable.add_var(saveset, "telcfg:settings/Mobile/MSN", "")
end
g_err, g_errmsg = box.set_config(saveset)
if g_err == 0 then
local url = box.glob.script
if pinset then
-- um wg. der Pin-Texte zu wissen, ob man vom Pin-Setzen kommt
-- redirect ist hier auch deswegen wichtig, damit die Chance vergössert
-- wird, das das checken der PIN schon fertig ist.
url = url .. "?" .. http.url_param("pinset", "")
end
http.redirect(url)
end
end
function write_error()
if g_err and g_err ~= 0 then
require"general"
box.out(general.create_error_div(g_err, g_errmsg))
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
td.rssi, th.rssi {
text-align: center; width:40px;
}
td.homezone, th.homezone {
text-align: center; width:30px;
}
td.status, th.status {
width:170px;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
function initAccountHandler() {
var account = <?lua umts_html.write_accountlist_js(g_accounts) ?>;
var currAccount = jxl.getValue("uiAccount");
var values = inputValueStore("uiAccountContainer", account);
var hide = {"1&1 Internet": true};
function removeErrorClass() {
jxl.walkDom("uiAccountContainer", "input",
function(el){jxl.removeClass(el, "error");}
);
}
function onAccountChange(evt) {
values.save(currAccount);
currAccount = jxl.getValue("uiAccount");
values.restore(currAccount);
removeErrorClass();
jxl.disableNode("uiAccountContainer", currAccount || !jxl.getEnabled("uiAccount"));
jxl.display("uiAccountContainer", !hide[currAccount]);
}
onAccountChange();
jxl.addEventHandler("uiAccount", "change", onAccountChange);
jxl.addEventHandler("uiActivation:enabled", "click", onAccountChange);
jxl.addEventHandler("uiActivation:fallback", "click", onAccountChange);
jxl.addEventHandler("uiActivation:disabled", "click", onAccountChange);
}
function initUpdateNetstate() {
function checkPoll(uiId, xhr) {
var poll = Number(jxl.getValue("uiPoll")) || 0;
if (poll > 0) {
jxl.setValue("uiPoll", "0");
jxl.disable("uiUpdateButton");
}
else {
jxl.enable("uiUpdateButton");
jxl.addEventHandler("uiUpdateButton", "click", updateNetstate);
}
return poll;
}
function updateNetstate(evt) {
var page = "<?lua box.js(box.glob.script) ?>";
var sid = "<?lua box.js(box.glob.sid) ?>";
jxl.disable("uiUpdateButton");
jxl.changeImage("uiProgressImg", "/css/default/images/wait.gif");
ajaxUpdateHtml("uiNetstate", page, sid, 0, checkPoll);
return jxl.cancelEvent(evt);
}
updateNetstate();
jxl.addEventHandler("uiUpdateButton", "click", updateNetstate);
}
function pageInit() {
disableOnClick({
inputName: "usbtethering_mode",
classString: "disableif_tethering"
});
disableOnClick({
inputName: "activation",
classString: "disableif_umts:%1"
});
hideOnClick({
inputName: "activation",
classString: "hideif_umts:%1"
});
enableOnClick({
inputName: "on_demand",
classString: "enableif_on_demand:%1"
});
enableOnClick({
inputName: "UsePrefix",
classString: "enableif_UsePrefix"
});
enableOnClick({
inputName: "msnactive",
classString: "enableif_msnactive"
});
initUpdateNetstate();
initAccountHandler();
}
ready.onReady(pageInit);
<?lua val.write_js_error_strings() ?>
function onSubmit() {
var doConfirmChecks = val.active;
var valResult = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
if (doConfirmChecks && valResult !== false) {
var confirmResult = (function() {
var ret;
<?lua val.write_js_checks_no_active(g_val_confirm) ?>
})();
if (confirmResult === false) {
return false;
}
}
return valResult;
}
ready.onReady(val.init(onSubmit));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" id="uiMainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_error() ?>
<?lua
if not umts_available() then
write_noumts_explain()
else
if show_usbtethering() then
write_usb_tethering()
box.out([[<hr>]])
end
box.out([[<div class="disableif_tethering">]])
write_umts_enable()
box.out([[<hr>]])
box.out([[<div id="uiNetstate">]])
write_pin_input()
write_roaming()
write_net_table()
write_progress()
box.out([[</div>]])
box.out([[<hr>]])
umts_html.write_account(g_data,g_accounts)
box.out([[<hr>]])
write_ondemand()
box.out([[<hr>]])
write_voip_over_mobile()
if config.USB_GSM_VOICE and umts.is_voice_modem() then
box.out([[<hr>]])
write_msn()
end
box.out([[<hr>]])
write_hints()
box.out([[</div>]])
end
?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
