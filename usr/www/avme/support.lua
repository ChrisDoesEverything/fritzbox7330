<?lua
--[[
Datei Name: support.lua
Datei Beschreibung: Startseite für Supportfunktionen
Tags: avm@save
]]
g_page_type = "no_menu"
g_homelink_top = true
g_page_title = [[{?713:573?}]]
g_page_help = "hilfe_support.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("http")
require("general")
require("html")
require("href")
g_back_to_page = http.get_back_to_page()
if box.post.cancel then
http.redirect(g_back_to_page)
end
local is_beta = config.gu_type == "private" or config.gu_type == "beta"
g_show_autosupport = is_beta
if box.query("emailnotify:settings/supportdata_incident_enabled") == "1"
or box.query("emailnotify:settings/supportdata_startup_enabled") == "1" then
g_show_autosupport = true
end
g_show_capture = true
if config.DOCSIS then
g_show_capture = config.gu_type ~= 'release'
end
speedtest = {}
local function get_ip()
local dslite_active=false
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
dslite_active = box.query("ipv6:settings/ipv4_active_mode") ~= "ipv4_normal"
if (dslite_active) then
return box.query("ipv6:settings/ip")
end
end
local ip = box.query("connection0:status/ip")
if array.all({"", "-", "er", "0.0.0.0"}, func.neq(ip)) then
return ip
end
end
local function get_ddns()
local ddns
if box.query("ddns:settings/account0/activated") == "1"
and box.query("ddns:settings/account0/password") ~= ""
and box.query("ddns:settings/account0/username") ~= ""
and box.query("ddns:settings/account0/ddnsprovider") ~= "" then
ddns = box.query("ddns:settings/account0/domain")
end
return ddns
end
function speedtest.read_values()
speedtest.enable_server = box.query("speedtest:settings/enable_server") == "1"
speedtest.udp_bidi = box.query("speedtest:settings/bidirect0/state") ~= "off"
speedtest.WANAccess = box.query("speedtest:settings/WANAccess") == "1"
end
speedtest.read_values()
speedtest.show = true
function speedtest.boxip_html()
local ip, ddns = get_ip(), get_ddns()
if ip or ddns then
return html.div{
html.p{
[[{?713:326?}]]
},
html.div{class="formular",
html.span{ddns or ip}
}
}
end
end
function speedtest.checked(which)
if which == 'enable_server' then
return speedtest.enable_server and "" or nil
elseif which == 'udp_bidi' then
return speedtest.udp_bidi and "" or nil
elseif which == 'WANAccess' then
return speedtest.enable_server and speedtest.WANAccess and "" or nil
end
end
function speedtest.WAN_disabled()
return not speedtest.enable_server and "" or nil
end
function speedtest.do_apply()
local saveset = {}
cmtable.add_var(saveset, "speedtest:settings/enable_server", box.post.enable_server and "1" or "0")
if (box.post.enable_server) then
cmtable.add_var(saveset, "speedtest:settings/tcp0/start", "1" )
cmtable.add_var(saveset, "speedtest:settings/udp0/start", "1")
else
cmtable.add_var(saveset, "speedtest:settings/tcp0/stop", "1")
cmtable.add_var(saveset, "speedtest:settings/udp0/stop", "1")
end
if (box.post.udp_bidi) then
cmtable.add_var(saveset, "speedtest:settings/bidirect0/start", "1")
else
cmtable.add_var(saveset, "speedtest:settings/bidirect0/stop", "1")
end
cmtable.add_var(saveset, "speedtest:settings/WANAccess", box.post.WANAccess and "1" or "0")
box.set_config(saveset)
speedtest.read_values()
end
shellinabox = {}
function shellinabox.present()
local f, err = io.open("/sbin/shellinabox_launcher", "rb")
if f then
f:close()
return true
end
return false
end
shellinabox.show = shellinabox.present() and (is_beta or config.CERTWAVE)
function shellinabox.txt_with_link()
local txt = box.tohtml([[{?713:997?}]])
local shref = href.get("/lua/shellinabox.lua")
txt = general.sprintf(txt, [[<a href="]] .. shref .. [[">]], [[</a>]])
return txt
end
require ("val")
g_val = {
prog = [[
if __value_not_empty(uiEmailAddr/emailaddr) then
char_range_regex(uiEmailAddr/emailaddr, email, txt_email)
end
]]
}
val.msg.txt_email = {
[val.ret.empty] = [[{?713:475?}]],
[val.ret.outofrange] = [[{?713:545?}]]
}
crashreport = {}
crashreport.emailaddr=box.query("emailnotify:settings/crashreport_name")
crashreport.show = config.ERR_FEEDBACK
crashreport.show = false
function crashreport.checked(which)
local value = box.query("emailnotify:settings/crashreport_mode")
local checked = value == which
if value == "disable_mail" then
checked = which == "disabled_by_user"
end
if value == "to_user_and_support" then
checked = which == "to_support_only"
end
return checked and "" or nil
end
function crashreport.do_apply()
local res=val.validate(g_val)
crashreport.emailaddr=box.post.emailaddr
if res== val.ret.ok then
local saveset = {}
local new_value = box.post.crashreport_mode
if new_value == "to_support_only" then
local old_value = box.query("emailnotify:settings/crashreport_mode")
-- den hier nicht setzbaren "on"-Wert nicht überschreiben ...
if old_value == "to_user_and_support" then
new_value = old_value
end
end
cmtable.add_var(saveset, "emailnotify:settings/crashreport_mode", new_value)
cmtable.add_var(saveset, "emailnotify:settings/crashreport_name",box.post.emailaddr)
box.set_config(saveset)
end
end
--neue Variable ab DSL_SDK 2.14-r67-trunk-DiagnosticAvail_for_TL7450
g_dsldiag = not config.LTE and (config.DSL or config.VDSL) and box.query("sar:settings/DiagnosticAvail") == "1"
g_data_send_mode="off"
if next(box.post) and box.post.SaveAccess then
local saveset = {}
local val="0"
if box.post.ProviderAccess then
val="1"
end
cmtable.add_var(saveset, "tr069:settings/upload_enable", val)
box.set_config(saveset)
end
if next(box.post) and box.post.SaveDocsis then
local saveset = {}
box.set_config(saveset)
end
if next(box.post) and box.post.start_dsl then
local saveset = {}
cmtable.add_var(saveset, "sar:settings/DslDiagnosticStart", "1")
box.set_config(saveset)
end
if box.post.stop_dsl then
local saveset = {}
cmtable.add_var(saveset, "sar:settings/DslDiagnosticStart", "0")
box.set_config(saveset)
end
if box.post.dsl_resync then
local saveset = {}
cmtable.add_var(saveset, "sar:settings/DslRetrain", "1")
box.set_config(saveset)
end
if next(box.post) and box.post.developer then
http.redirect("/developer.lua")
end
if box.post.crashreport_apply then
crashreport.do_apply()
end
if box.post.speedtest_apply then
speedtest.do_apply()
end
g_data_send=false
if box.post.send_data_now then
local saveset = {}
cmtable.add_var(saveset, "emailnotify:settings/supportdata_send_now", "1")
box.set_config(saveset)
g_data_send=true
end
if box.post.apply then
local saveset = {}
if (box.post.auto_update=="off") then
cmtable.add_var(saveset, "emailnotify:settings/supportdata_incident_enabled", "0")
cmtable.add_var(saveset, "emailnotify:settings/supportdata_startup_enabled", "0")
elseif (box.post.auto_update=="reboot_incident") then
cmtable.add_var(saveset, "emailnotify:settings/supportdata_incident_enabled", "1")
cmtable.add_var(saveset, "emailnotify:settings/supportdata_startup_enabled", "0")
g_data_send_mode="reboot_incident"
elseif (box.post.auto_update=="reboot_only") then
cmtable.add_var(saveset, "emailnotify:settings/supportdata_incident_enabled", "0")
cmtable.add_var(saveset, "emailnotify:settings/supportdata_startup_enabled", "1")
g_data_send_mode="reboot_only"
end
box.set_config(saveset)
end
g_data_send_mode="off"
if (box.query("emailnotify:settings/supportdata_startup_enabled")== "1") then
g_data_send_mode="reboot_only"
elseif (box.query("emailnotify:settings/supportdata_incident_enabled")== "1") then
g_data_send_mode="reboot_incident"
end
function get_autoupdate_checked(cur)
if (g_data_send_mode==cur) then
return "" --"checked"
end
return nil --""
end
function write_ProviderAccess()
local val=box.query("tr069:settings/upload_enable")
if (val=="1") then
box.out("checked")
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript">
function onSpeedtestClick(evt) {
var elem = jxl.evtTarget(evt);
if (elem.id == "uiSpeedtest") {
if (elem.checked) {
jxl.enable("uiSpeedtestWan");
jxl.enable("uiSpeedtestUdpBidi");
}
else {
jxl.setChecked("uiSpeedtestWan", false);
jxl.setChecked("uiSpeedtestUdpBidi", false);
jxl.disable("uiSpeedtestWan");
jxl.disable("uiSpeedtestUdpBidi");
}
}
}
function init() {
<?lua
if speedtest.show then
box.out([[jxl.addEventHandler("uiSpeedtest", "click", onSpeedtestClick);]])
end
if g_dsldiag and box.post.stop_dsl then
box.out([[jxl.submitForm("download_dsl_diag");]])
end
?>
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<h4>{?713:275?}</h4>
<p>{?713:44?}</p>
<p><a href="<?lua box.html(config.SERVICEPORTAL_URL) ?>" target="_blank">{?713:571?}</a></p>
<?lua
if g_show_autosupport then
html.hr{}.write()
html.h4{[[{?713:143?}]]}.write()
html.p{
[[{?713:115?}]]
}.write()
html.form{method="POST", action=href.get(box.glob.script),
html.div{class="formular",
html.div{style="float:left;",
html.input{
type="radio", name="auto_update", value="off", id="uiAutoUpdateOff", checked=get_autoupdate_checked('off')
},
html.label{['for']="uiAutoUpdateOff",
[[{?713:718?}]]
},
html.br{},
html.input{
type="radio", name="auto_update", value="reboot_only", id="uiAutoUpdateRebootOnly", checked=get_autoupdate_checked('reboot_only')
},
html.label{['for']="uiAutoUpdateRebootOnly",
[[{?713:111?}]]
},
html.br{},
html.input{
type="radio", name="auto_update", value="reboot_incident", id="uiAutoUpdateIncident", checked=get_autoupdate_checked('reboot_incident')
},
html.label{['for']="uiAutoUpdateIncident",
[[{?713:624?}]]
},
html.br{}
},
html.div{style="float:right;",
html.button{type="submit", name="apply",
[[{?713:921?}]]
}
},
html.div{class="clear_float"}
}
}.write()
html.div{class="formular",
html.p{id="uiDataAlreadySend",
g_data_send and [[{?713:648?}]] or nil
},
html.form{method="POST", action=href.get(box.glob.script),
html.button{type="submit", name="send_data_now",
[[{?713:464?}]]
}
}
}.write()
-- Ende show_autosupport
end ?>
<hr>
<?lua if not g_show_autosupport then
html.h4{[[{?713:476?}]]}.write()
end ?>
<p>{?713:406?}</p>
<div <?lua if g_show_autosupport then box.out([[class="formular"]]) end ?>>
<form method="POST" action="/cgi-bin/firmwarecfg" enctype="multipart/form-data">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="SupportData" >{?713:704?}</button>
</form>
</div>
<?lua
if g_dsldiag then
local dsldiag_running = box.query("sar:settings/DslDiagnosticStart") == "1"
local btn_name = "start_dsl"
local btn_desc = [[{?713:888?}]]
if dsldiag_running then
btn_name = "stop_dsl"
btn_desc = [[{?713:8931?}]]
end
box.out([[
<hr>
<h4>{?713:582?}</h4>
<p>{?713:198?}</p>]])
if dsldiag_running then
box.out([[<p>{?713:889?}</p>]])
end
box.out([[
<form method="POST" action="/support.lua">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<button type="submit" name="]]..btn_name..[[">]]..btn_desc..[[</button>
</form>
<form name="download_dsl_diag" method="POST" action="/cgi-bin/firmwarecfg" enctype="multipart/form-data">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<input type="hidden" name="DSLData">
</form>
]])
end
if not config.LTE and (config.DSL or config.VDSL) then
box.out([[
<hr>
<h4>{?713:936?}</h4>
<p>{?713:842?}</p>
<form method="POST" action="/support.lua">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<button type="submit" name="dsl_resync">{?713:791?}</button>
</form>
]])
end
if (config.DSL or config.VDSL) and box.query("sar:settings/IsLastReleasedDP") == "0" then
html.hr{}.write()
html.h4{
[[{?713:620?}]]
}.write()
html.p{
[[{?713:286?}]]
}.write()
html.p{
html.a{href=href.get("/internet/dsl_test.lua"),
[[{?713:494?}]]
}
}.write()
end
?>
<?lua if g_show_capture then
html.hr{}.write()
html.h4{[[{?713:575?}]]}.write()
html.p{
[[{?713:118?}]]
}.write()
html.p{html.a{href=href.get('/capture.lua'),
[[{?713:12?}]]
}}.write()
end ?>
<?lua if crashreport.show then
html.hr{}.write()
html.h4{[[{?713:853?}]]}.write()
html.p{
[[{?713:989?}]]
}.write()
html.form{name="crashreport", method="POST", action=href.get(box.glob.script),
html.div{class="formular",
html.input{
type="radio", name="crashreport_mode", value="to_support_only", id="uiCrashreportOn", checked=crashreport.checked("to_support_only")
},
html.label{['for']="uiCrashreportOn", [[{?713:845?}]]},
html.br{},
html.input{
type="radio", name="crashreport_mode", value="disabled_by_user", id="uiCrahsreportOff", checked=crashreport.checked("disabled_by_user")
},
html.label{['for']="uiCrahsreportOff", [[{?713:27?}]]},
html.br{},
html.label{['for']="uiEmailAddr", [[{?713:885?}:]]},
html.input{
type="text", name="emailaddr", value=crashreport.emailaddr, id="uiEmailAddr", size="50", maxlength="128", class=val.get_error_class(g_val, "uiEmailAddr")
},
html.br{},
html.div{html.raw(val.get_html_msg(g_val, "uiEmailAddr"))},
html.p{class="innerbutton",
html.button{type="submit", name="crashreport_apply",[[{?713:365?}]]}
}
}
}.write()
-- Ende crashreport.show
end ?>
<?lua if speedtest.show then
html.hr{}.write()
html.h4{[[{?713:625?}]]}.write()
html.p{
[[{?713:206?}]]
}.write()
html.p{
[[{?713:368?}]]
}.write()
html.p{
[[{?713:912?}]],
html.a{target="_blank", href="http://iperf.sourceforge.net/", [[ http://iperf.sourceforge.net/]]}, [[.]]
}.write()
html.p{
[[{?713:890?}]]
}.write()
html.form{name="speedtest", method="POST", action=href.get(box.glob.script),
html.div{class="formular",
html.input{
type="checkbox", name="enable_server", id="uiSpeedtest", checked=speedtest.checked('enable_server')
},
html.label{['for']="uiSpeedtest", [[{?713:120?}]]},
html.br{},
html.input{
type="checkbox", name="udp_bidi", id="uiSpeedtestUdpBidi", checked=speedtest.checked('udp_bidi')
},
html.label{['for']="uiSpeedtestUdpBidi", [[{?713:906?}]]},
html.br{},
html.input{
type="checkbox", name="WANAccess", id="uiSpeedtestWan",
checked=speedtest.checked('WANAccess'), disabled=speedtest.WAN_disabled()
},
html.label{['for']="uiSpeedtestWan", [[{?713:300?}]]},
speedtest.boxip_html(),
html.p{class="innerbutton",
html.button{type="submit", name="speedtest_apply",[[{?713:905?}]]}
}
}
}.write()
-- Ende Speedtest
end ?>
<?lua if shellinabox.show then
html.hr{}.write()
html.h4{[[{?713:463?}]]}.write()
html.p{html.raw(shellinabox.txt_with_link())}.write()
-- Ende shellinabox
end ?>
<form name="cancelform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<div id="btn_form_foot">
<button type="submit" name="cancel">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
