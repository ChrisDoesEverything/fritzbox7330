<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_needs_js = true
g_page_help = "hilfe_internet_zugangsdaten.html"
dofile("../templates/global_lua.lua")
require"general"
require"http"
require"cmtable"
require"html"
require"js"
require"newval"
require"isp"
require"authform"
require"isphtml"
require"umts"
require"wlanscan"
local table_insert, table_concat = table.insert, table.concat
if not isp.is_vodafone_bytr069(isp.activeprovider()) then
isp.exclude_providers(isp.is_vodafone_bytr069)
end
function initial_provider()
if config.USB_GSM and umts.enabled == "1" and umts.backup_enable ~= "1" then
return 'mobil'
end
return isp.initial_provider()
end
if box.get.wlanscan then
local json_string = wlanscan.getjson({startscan=box.get.startscan})
box.out(json_string)
box.end_page()
end
local conncheck_txt = {
[0] = [[{?301:427?}]],
[8] = [[{?301:589?}]],
[9] = [[{?301:213?}]],
[10] = [[{?301:195?}]],
[11] = [[{?301:716?}]],
[12] = [[{?301:269?}]],
[13] = [[{?301:456?}]],
[14] = [[{?301:68?}]],
[15] = [[{?301:6037?}]]
}
if box.get.query == 'startconncheck' then
local answer = {}
answer.done = true
answer.showresult = true
local status = box.query("connection0:status/Check/Status")
if status == "1" or status == "8" then
answer.showhtml = html.p{
[[{?301:679?}]]
}.get()
else
answer.dontstop = true
answer.showhtml = html.p{
[[{?301:136?}]]
}.get()
end
box.out(js.table(answer))
box.end_page()
elseif box.get.query == 'conncheck' then
local answer = {}
answer.addinfo = 'running'
answer.pagetitle = [[{?301:803?}]]
if box.get.addinfo ~= 'running' then
box.set_config({{name="connection0:settings/Check/Start", value="1"}})
answer.showhtml = html.p{conncheck_txt[8]}.get()
else
local status = box.query("connection0:status/Check/Status")
status = tonumber(status) or 10
answer.showhtml = html.p{conncheck_txt[status]}.get()
answer.done = status ~= 8
answer.error = status ~= 9
answer.showresult = true
end
box.out(js.table(answer))
box.end_page()
elseif box.get.query == "reboot" then
local answer = {}
answer.done = true
answer.showresult = true
answer.pagetitle = [[{?301:603?}]]
answer.showhtml = html.p{
[[{?301:150?}]]
}.get()
box.out(js.table(answer))
box.end_page()
elseif box.get.query == "poweroff" then
local answer = {}
answer.done = true
answer.showresult = true
answer.pagetitle = [[{?301:808?}]]
answer.showhtml = html.p{
[[{?301:5936?}]]
}.get()
box.out(js.table(answer))
box.end_page()
end
local opmode_check = {
opmode_standard = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoe = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoa = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoa_llc = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_ether = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_eth_pppoe = array.truth{'auth', 'connmode', 'vlan', 'speed'},
opmode_eth_ip = array.truth{'auth', 'speed', 'vlan', 'ipsetting', 'mac'},
opmode_eth_ipclient = array.truth{'auth', 'speed', 'ipsetting'},
opmode_wlan_ip = array.truth{'wlanscan'},
opmode_ipnlpid = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_ipsnap = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_ipraw = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
}
function set_ctlmgr_values(postvars)
local saveset = {}
postvars = postvars or isp.read_all_post_vars()
isphtml.save_provider(saveset, postvars)
local new_opmode = isphtml.save_opmode(saveset, postvars)
isphtml.save_wlanscan(saveset, postvars)
isphtml.save_auth(saveset, postvars)
local nocheck = not isp.is_other(postvars.provider)
if nocheck or opmode_check[new_opmode].connmode then
isphtml.save_connmode(saveset, postvars)
end
if nocheck or opmode_check[new_opmode].vlan then
isphtml.save_vlan(saveset, postvars)
end
if nocheck or opmode_check[new_opmode].atm then
isphtml.save_atm(saveset, postvars)
end
if nocheck or opmode_check[new_opmode].speed then
isphtml.save_speed(saveset, postvars)
end
if nocheck or opmode_check[new_opmode].ipsetting then
isphtml.save_ipsetting(saveset, postvars)
end
if nocheck or opmode_check[new_opmode].mac then
isphtml.save_mac(saveset, postvars)
end
isphtml.save_oma_ipsetting(saveset, postvars)
isphtml.save_guiflag(saveset, postvars)
isphtml.save_specials(saveset, postvars)
if isp.is_other(postvars.provider) or isp.is('oma_wlan', postvars.provider) then
isphtml.disable_guest(saveset, postvars)
end
isphtml.disable_umtsfallback(saveset, postvars)
local e, m = box.set_config(saveset)
end
local function do_conncheck()
local p = isp.read_post_var('provider')
if isp.read_post_var('optype', p) == 'client' then
return false
end
if isp.is_oma(p) then
return false
end
return box.post.conncheck
end
local function do_reboot()
return false
end
local function do_poweroff()
return false
end
local function do_ipchange()
return general.boxip_isdefault()
and isp.is_oma(isp.read_post_var('provider'))
end
local function build_change_isp_url()
local url = "/internet/isp_change.lua"
local params = {
http.url_param("button", "ok"),
http.url_param("pagetype", "all"),
http.url_param("pagemaster", box.glob.script)
}
local query
if do_ipchange() then
url = "/networkchange.lua"
params = {
http.url_param("ifmode", "oma"),
http.url_param("newipaddr", "192.168.188.1"),
}
else
if do_poweroff() then
query = "poweroff"
elseif do_reboot() then
query = "reboot"
elseif do_conncheck() then
query = "startconncheck,conncheck"
end
if query then
table_insert(params, http.url_param("query", query))
end
end
return url .. "?" .. table_concat(params, "&")
end
local function fill_template(template_str, params)
template_str = template_str or ""
params = params or {}
return (template_str:gsub("%$([a-zA-Z%d_]+)%$", function(m) return params[m] or "" end))
end
local provider_ids = isp.provider_ids()
function popup_wanbridge()
local url
local params = {}
local p = isp.read_post_var('provider')
local do_oma = general.boxip_isdefault()
if do_oma and isp.is_oma(p) then
url = href.get('/internet/pp_wanbridge.lua')
params = {
http.url_param("ipaddr", "192.168.188.1"),
http.url_param("netmask", "255.255.255.0"),
http.url_param("dhcp", "1"),
http.url_param("dhcpstart", "192.168.188.20"),
http.url_param("dhcpend", "192.168.188.200"),
http.url_param("oma", "")
}
elseif isp.is_other(p) then
if isp.read_post_var("medium", p) == "extern"
and isp.read_post_var("optype", p) == "client"
and isp.read_post_var("client_dhcp", p) == "0" then
url = href.get('/internet/pp_wanbridge.lua')
params = {
http.url_param("ipaddr", ip.read_from_post("client_ipaddr:" .. p)),
http.url_param("netmask", ip.read_from_post("client_netmask:" .. p))
}
end
end
if url then
return {
url = url .. "&" .. table_concat(params, "&"),
opts="width=450,height=400,resizable=yes,scrollbars=yes,location=no"
}
end
end
local valprog
if box.post.validate == "apply" or box.post.apply then
valprog = function()
isphtml.noprovider_validation()
local provider = isp.read_post_var('provider')
authform.validation(provider)
isphtml.connmode_validation(provider)
isphtml.vlan_validation(provider)
isphtml.atm_validation(provider)
isphtml.ipsetting_validation(provider)
isphtml.speed_validation(provider)
isphtml.mac_validation(provider)
isphtml.wlanscan_validation(provider)
isphtml.wlansecurity_validation(provider)
end
end
function write_speed_confirm_params()
local result = {}
result.needed = {}
for _, p in ipairs(provider_ids) do
if isp.is_other(p) or isp.is_dsl(p) or isp.speed_needed(p) then
result.needed[p] = true
end
end
if next(result.needed) then
result.msg = {
us = [[{?301:896?}]],
ds = [[{?301:770?}]]
}
end
box.out(js.table(result))
end
function write_disable_umtsfallback_confirm_params()
local result = {}
result.needed = {}
if config.USB_GSM and umts.backup_enable == "1" then
local ata_opmode = array.truth{
'opmode_eth_pppoe', 'opmode_eth_ip', 'opmode_eth_ipclient', 'opmode_wlan_ip'
}
if not ata_opmode[box.query("box:settings/opmode")] then
for _, p in ipairs(provider_ids) do
if isp.is_other(p) or ata_opmode[isp.opmode(p)] or isp.is_dsl(p) then
result.needed[p] = true
end
end
end
if next(result.needed) then
result.msg = [[{?301:98?}]]
end
end
box.out(js.table(result))
end
function write_disable_guest_confirm_params()
local result = {needed={}}
local lan_guest = false
local wlan_guest = config.WLAN_GUEST and box.query("wlan:settings/guest_ap_enabled") == "1"
if lan_guest and wlan_guest then
result.guest = "any"
result.needed.oma_wlan = true
result.needed.oma_lan = true
elseif lan_guest then
result.guest = "lan"
result.needed.oma_wlan = true
result.needed.oma_lan = true
elseif wlan_guest then
result.guest = "wlan"
result.needed.oma_wlan = true
end
if wlan_guest and not lan_guest then
for _, p in ipairs(provider_ids) do
if isp.is_other(p) then
result.needed[p] = true
end
end
elseif wlan_guest or lan_guest then
for _, p in ipairs(provider_ids) do
if isp.is_other(p) or isp.is_dsl(p) or isp.is_cable(p) then
result.needed[p] = true
end
end
end
if next(result.needed) then
result.msg = {
wlan = [[{?301:466?}]],
lan = [[{?301:854?}]],
any = [[{?301:846?}]]
}
end
box.out(js.table(result))
end
function write_wan_confirm_params(options)
local result = {needed={}}
local over_lan1 = array.truth{'opmode_eth_pppoe', 'opmode_eth_ip', 'opmode_eth_ipclient'}
if not over_lan1[box.query("box:settings/opmode")] then
for _, p in ipairs(provider_ids) do
if isp.is_other(p) or isp.is_dsl(p) or isp.over_lan1(p) then
result.needed[p] = true
end
end
end
if next(result.needed) then
result.msg = {
wan = isphtml.wan_confirm_txt(),
ipclient = isphtml.ipclient_confirm_txt()
}
end
box.out(js.table(result))
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
if answer.ok then
answer.popup = popup_wanbridge()
end
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
local valresult = newval.validate(valprog)
if valresult == newval.ret.ok then
local postvars = isp.read_all_post_vars()
local url = build_change_isp_url()
set_ctlmgr_values(postvars)
http.redirect(url)
end
end
function write_authforms_css()
for _, p in ipairs(provider_ids) do
authform.write_subprovider_css(p)
end
end
local function get_subprovider_radionames_js()
local names = {}
for _, p in ipairs(provider_ids) do
names[p] = authform.subprovider_radioname(p)
end
return names
end
local function get_super_list_js()
local list = table.clone(isp.get_super_list())
for k, v in pairs(list) do
list[k].txt = nil
list[k].listlevel = nil
end
return list
end
local function get_enablers_js()
local result = {}
local name, class
local is_other
for _, p in ipairs(provider_ids) do
local tbl = {}
is_other = isp.is_other(p)
if isp.is_dsl(p) then
name = isp.html_name("medium", p)
class = "enableif_" .. name .. "::%1"
table_insert(tbl, {inputName=name, classString=class})
end
if is_other or isp.connmode_needed(p) then
name = isp.html_name("connmode", p)
class = "enableif_" .. name .. "::%1"
table_insert(tbl, {inputName=name, classString=class})
name = isp.html_name("useprevention", p)
class = "enableif_" .. name
table_insert(tbl, {inputName=name, classString=class})
end
if is_other then
name = isp.html_name("autodetect", p)
class = "enableif_" .. name .. "::%1"
table_insert(tbl, {inputName=name, classString=class})
end
if is_other then
name = isp.html_name("router_dhcp", p)
class = "enableif_" .. name .. "::%1"
table_insert(tbl, {inputName=name, classString=class})
name = isp.html_name("client_dhcp", p)
class = "enableif_" .. name .. "::%1"
table_insert(tbl, {inputName=name, classString=class})
end
if is_other or isp.vlan_needed(p) then
name = isp.html_name("usevlan", p)
class = "enableif_" .. name
table_insert(tbl, {inputName=name, classString=class})
end
if #tbl > 0 then
result[p] = tbl
end
end
return result
end
function write_data_js()
local data = {}
data.initialIsp = initial_provider()
data.subproviderRadionames = get_subprovider_radionames_js()
data.providerList = table.clone(provider_ids)
table_insert(data.providerList, "tochoose")
table_insert(data.providerList, "tochoose2")
table_insert(data.providerList, "mobil")
data.superList = get_super_list_js()
data.enablerParams = get_enablers_js()
box.out(js.table(data))
end
function write_template()
local t = {}
t.str = [[$TEMPLATE_CONNECTION_HEAD$$TEMPLATE_SPEED$$TEMPLATE_CONNECTION_EX$]]
t.sub = {
TEMPLATE_CONNECTION_HEAD = isphtml.gettemplate_connection_head(),
TEMPLATE_SPEED = isphtml.gettemplate_speed(),
TEMPLATE_CONNECTION_EX = isphtml.gettemplate_connection_ex()
}
box.out(js.table(t))
end
function write_template_params()
local t = {}
for _, p in ipairs(provider_ids) do
if not isp.is_other(p) and not isp.is_oma(p) then
t[p] = {
TEMPLATE_CONNECTION_HEAD = isphtml.getparams_connection_head(p),
TEMPLATE_SPEED = isphtml.getparams_speed(p),
TEMPLATE_CONNECTION_EX = isphtml.getparams_connection_ex(p)
}
end
end
box.out(js.table(t))
end
function write_isps_css()
local selectors = {}
for _, p1 in ipairs(provider_ids) do
box.out(".isp_tochoose .showif_", p1, ",\n")
box.out(".isp_tochoose2 .showif_", p1, ",\n")
box.out(".isp_mobil .showif_", p1, ",\n")
box.out(".isp_", p1, " .showif_mobil", ",\n")
for _, p2 in ipairs(provider_ids) do
if p1 ~= p2 then
box.out(".isp_", p1, " .showif_", p2, ",\n")
end
end
end
box.out(".isp_tochoose .hideif_tochoose", ",\n")
box.out(".isp_tochoose2 .hideif_tochoose", ",\n")
box.out(".isp_mobil .hideif_mobil", ",\n")
box.out(".isp_oma_lan .hideif_oma_lan", ",\n")
box.out(".isp_oma_wlan .hideif_oma_wlan", "\n")
box.out(" {\n display: none;\n}")
end
function write_special_css()
if not general.is_expert() then
local active_p = isp.initial_provider()
local m = isp.initial_medium(active_p)
local s = authform.initial_subprovider()
for i, p in ipairs{'other', 'other_named'} do
if active_p ~= p or (m == 'dsl' and s == 'auth') then
box.out([[
.isp_]], p, [[.dsl .hideif_dslstandard {
display: none;
}
.isp_]], p, [[.dsl div.formular.showif_auth {
padding-left: 0px;
}
]])
end
end
end
end
function write_super_css()
local selectors = {}
local fmt = [[.super_%s .super_%s]]
table.insert(selectors, fmt:format("", "anysuper"))
for _, super1 in ipairs(isp.get_superproviders()) do
if not isp.is_real_super(super1) then
table.insert(selectors, fmt:format(super1, "anysuper"))
end
table.insert(selectors, fmt:format("", super1))
for _, super2 in ipairs(isp.get_superproviders()) do
if tonumber(super1) and super1 ~= super2 then
table.insert(selectors, fmt:format(super2, super1))
end
end
end
box.out("\n",
table.concat(selectors, ",\n"),
" {\n display: none;\n}"
)
end
function write_initial_class()
local classes = isp.initial_classes(initial_provider())
local sub = authform.initial_subprovider()
if sub then
table_insert(classes, "sub_" .. sub)
end
if general.boxip_isdefault() then
table_insert(classes, "ipchange")
end
box.out(table_concat(classes, " "))
end
local function gethtml_connection_ex_other(provider)
if isp.is_other(provider) then
local onclick = string.format([[onConnectionExClicked('%s');return false;]], provider)
return html.div{class="formular showif_" .. provider,
html.a{class="textlink", href=" ", onclick=onclick,
[[{?301:104?}]],
html.img{
id="uiConnectionExLink:" .. provider, src="/css/default/images/link_open.gif", height="12"
}
},
html.div{id="uiConnectionEx:" .. provider, style="display:none;",
isphtml.get_connmode(provider),
isphtml.get_vlan(provider),
isphtml.get_atm(provider),
isphtml.get_ipsetting(provider, 'router'),
isphtml.get_ipsetting(provider, 'client'),
isphtml.get_mac(provider)
}
}
end
end
function writehtml_settings()
if general.is_wdsrepeater() then
return
end
local html_elem
for _, p in ipairs(provider_ids) do
box.out([[<div id="uiSettings:]], p, [[">]])
if isp.is_other(p) then
html_elem = isphtml.get_medium(p)
if html_elem then html_elem.write() end
html_elem = isphtml.get_optype(p)
if html_elem then html_elem.write() end
html_elem = isphtml.get_auth(p)
if html_elem then html_elem.write() end
html_elem = isphtml.get_connection_head(p)
if html_elem then html_elem.write() end
html_elem = isphtml.get_speed(p)
if html_elem then html_elem.write() end
html_elem = gethtml_connection_ex_other(p)
if html_elem then html_elem.write() end
elseif isp.is_oma(p) then
html_elem = isphtml.get_wlanscan(p)
if html_elem then html_elem.write() end
html_elem = isphtml.get_wlansecurity(p)
if html_elem then html_elem.write() end
else
html_elem = isphtml.get_auth(p)
if html_elem then html_elem.write() end
end
box.out([[</div>]])
end
end
local function get_mobil_explain()
local str = [[{?301:0?}]]
if box.query("gsm:settings/PinEmpty") == '0' or box.query("gsm:settings/ModemPresent") == '1' then
str = general.sprintf(
box.tohtml(
[[{?301:567?}]]
),
html.a{href=href.get("/internet/umts_settings.lua"),
[[{?301:285?}]]
}.get('nonewline')
)
str = html.raw(str)
end
return html.p{str}
end
function write_provider_explain()
for _, p in ipairs(provider_ids) do
html.div{class="showif_" .. p,
isphtml.get_provider_explain(p)
}.write()
end
html.div{class="showif_mobil", get_mobil_explain()}.write()
end
function write_wdsrepeater_div()
if general.is_wdsrepeater() then
local div = html.div{}
if config.WLAN_WDS2 then
div.add(html.p{[[{?301:987?}]]})
local txt = [[{?301:385?}]]
local link = html.a{href=href.get("/wlan/wds2.lua"), [[{?301:807?}]]}.get('nonewline')
div.add(html.p{
html.raw(general.sprintf(box.tohtml(txt), link))
})
else
div.add(html.p{[[{?301:167?}]]})
local txt = [[{?301:426?}]]
local link = html.a{href=href.get("/wlan/wds.lua"), [[{?301:934?}]]}.get('nonewline')
div.add(html.p{
html.raw(general.sprintf(box.tohtml(txt), link))
})
end
div.write()
end
end
function write_display(what)
if what == 'all' then
if general.is_wdsrepeater() then
box.out([[ style="display: none;"]])
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<style type="text/css">
div.doubleselect select {
width: 250px;
}
div.doubleselect select.secondselect {
margin-top: 5px;
}
div.doubleselect select.secondselect.invisible {
visibility: hidden;
}
<?lua write_isps_css() ?>
<?lua write_super_css() ?>
.isp_other.dsl .hideif_dsl,
.isp_other.cable .hideif_cable,
.isp_other.extern .hideif_extern,
.isp_other.extern.router .hideif_router,
.isp_other.extern.router.sub_auth .hideif_auth,
.isp_other.extern.router.sub_noauth .hideif_noauth,
.isp_other.dsl.sub_auth .hideif_auth,
.isp_other.dsl.sub_noauth .hideif_noauth,
.isp_other.cable .hideif_router,
.isp_other.extern.client .hideif_client,
.isp_other_named.dsl .hideif_dsl,
.isp_other_named.cable .hideif_cable,
.isp_other_named.extern .hideif_extern,
.isp_other_named.extern.router .hideif_router,
.isp_other_named.extern.router.sub_auth .hideif_auth,
.isp_other_named.extern.router.sub_noauth .hideif_noauth,
.isp_other_named.cable .hideif_router,
.isp_other_named.dsl.sub_auth .hideif_auth,
.isp_other_named.dsl.sub_noauth .hideif_noauth,
.isp_other_named.extern.client .hideif_client {
display: none;
}
<?lua write_authforms_css() ?>
<?lua write_special_css() ?>
.isp_oma_lan.ipchange .hideif_ipchange,
.isp_oma_wlan.ipchange .hideif_ipchange {
display: none;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/wlanscan.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var sort = sorter();
function initOnClickNoauthdsl(isp) {
isp = isp || "other";
function onClickNoauthdsl(evt) {
var target = jxl.evtTarget(evt);
if (target.name == 'noauthdsl_encap:' + isp) {
switch (target.value) {
case 'dslencap_ether':
jxl.enable("uiNoauthdsl_dhcp:" + isp);
jxl.setDisabled("uiNoauthdsl_hostname:" + isp, !jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
jxl.disableNode("uiBlock_noauthdsl_ips:" + isp, jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
break;
case 'dslencap_ipnlpid':
case 'dslencap_ipsnap':
case 'dslencap_ipraw':
jxl.disable("uiNoauthdsl_hostname:" + isp);
jxl.disable("uiNoauthdsl_dhcp:" + isp);
jxl.disableNode("uiBlock_noauthdsl_ips:" + isp, false);
break;
}
}
if (target.id == "uiNoauthdsl_dhcp:" + isp) {
jxl.setDisabled("uiNoauthdsl_hostname:" + isp, !jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
jxl.disableNode("uiBlock_noauthdsl_ips:" + isp, jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
}
}
if (jxl.getChecked("uiNoauthdsl_encap:" + isp + "::dslencap_ether")) {
jxl.enable("uiNoauthdsl_dhcp:" + isp);
jxl.setDisabled("uiNoauthdsl_hostname:" + isp, !jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
jxl.disableNode("uiBlock_noauthdsl_ips:" + isp, jxl.getChecked("uiNoauthdsl_dhcp:" + isp));
}
else {
jxl.disable("uiNoauthdsl_hostname:" + isp);
jxl.disable("uiNoauthdsl_dhcp:" + isp);
jxl.disableNode("uiBlock_noauthdsl_ips:" + isp, false);
}
jxl.addEventHandler("uiBlock_noauthdslencap:" + isp, 'click', onClickNoauthdsl);
}
function setDisabledApply(disable) {
var els = jxl.getFormElements("apply");
var i = els.length;
while (i--) {
jxl.setDisabled(els[i], disable);
}
}
function initFocusChanger(provider) {
fc.init("uiNoauthdsl_ipaddr:" + provider, 3, 'ip');
fc.init("uiNoauthdsl_netmask:" + provider, 3, 'ip');
fc.init("uiNoauthdsl_gateway:" + provider, 3, 'ip');
fc.init("uiNoauthdsl_dns1:" + provider, 3, 'ip');
fc.init("uiNoauthdsl_dns2:" + provider, 3, 'ip');
fc.init("uiRouter_ipaddr:" + provider, 3, 'ip');
fc.init("uiRouter_netmask:" + provider, 3, 'ip');
fc.init("uiRouter_gateway:" + provider, 3, 'ip');
fc.init("uiRouter_dns1:" + provider, 3, 'ip');
fc.init("uiRouter_dns2:" + provider, 3, 'ip');
fc.init("uiClient_ipaddr:" + provider, 3, 'ip');
fc.init("uiClient_netmask:" + provider, 3, 'ip');
fc.init("uiClient_gateway:" + provider, 3, 'ip');
fc.init("uiClient_dns1:" + provider, 3, 'ip');
fc.init("uiClient_dns2:" + provider, 3, 'ip');
fc.init("uiMac:" + provider, 2, 'mac');
}
function disableIfIPv6DsLite() {
var isIPv6DsLite = <?lua box.js(tostring(general.is_ipv6_dslite())) ?>;
if (isIPv6DsLite) {
var toDisable = [
"uiSubprovider:other::noauth",
"uiOptype:other::client",
"uiRouter_dhcp:other::0",
"uiRouter_dhcp:other::1",
"uiRouter_ipaddr:other",
"uiRouter_netmask:other",
"uiRouter_gateway:other",
"uiRouter_dns1:other",
"uiRouter_dns2:other",
"uiClient_dhcp:other::0",
"uiClient_dhcp:other::1",
"uiClient_ipaddr:other",
"uiClient_netmask:other",
"uiClient_gateway:other",
"uiClient_dns1:other",
"uiClient_dns2:other",
"uiSubprovider:other_named::noauth",
"uiOptype:other_named::client",
"uiRouter_dhcp:other_named::0",
"uiRouter_dhcp:other_named::1",
"uiRouter_ipaddr:other_named",
"uiRouter_netmask:other_named",
"uiRouter_gateway:other_named",
"uiRouter_dns1:other_named",
"uiRouter_dns2:other_named",
"uiClient_dhcp:other_named::0",
"uiClient_dhcp:other_named::1",
"uiClient_ipaddr:other_named",
"uiClient_netmask:other_named",
"uiClient_gateway:other_named",
"uiClient_dns1:other_named",
"uiClient_dns2:other_named",
];
var i = toDisable.length;
while (i--) {
var el = jxl.get(toDisable[i]);
if (el) {
jxl.disableNode(el.parentNode, true);
}
}
}
}
function buildAllIspClasses(providerList) {
var allIspClasses = "";
var i = providerList.length;
while (i--) {
allIspClasses += " isp_" + providerList[i];
}
return allIspClasses;
}
function buildAllSuperClasses(superList) {
var allSuperClasses = "super_";
for (var sup in superList) {
if (Number(sup)) {
allSuperClasses += " super_" + sup;
}
}
return allSuperClasses;
}
function pageInit() {
var data = <?lua write_data_js() ?>;
var initialIsp = data.initialIsp;
var subproviderHandlers = initSubproviderHandlers("uiMainform", data.subproviderRadionames);
var superList = data.superList;
var allSuperClasses = buildAllSuperClasses(superList);
var providerList = data.providerList;
var allIspClasses = buildAllIspClasses(providerList);
var enablerParams = data.enablerParams;
var template = <?lua write_template() ?>;
var templateParams = <?lua write_template_params() ?>;
function fillTemplate(tmp, params, provider) {
if (!params) {
return "";
}
var str = tmp.str || "";
var sub = tmp.sub || {};
for (var s in sub) {
if (sub.hasOwnProperty(s)) {
str = str.replace("$" + s + "$", fillTemplate(sub[s], params[s], provider));
}
}
params.provider = provider;
return str.replace(/\$([a-zA-Z_\d]+)\$/g, function(m, k) {return params[k] || "";});
}
function addTemplate(provider) {
var str = fillTemplate(template, templateParams[provider], provider);
if (str) {
var div = document.createElement("div");
jxl.setHtml(div, str);
var parent = jxl.get("uiSettings:" + provider);
if (parent) {
parent.appendChild(div);
}
templateParams[provider] = null;
if (enablerParams[provider]) {
for (var i = 0; i < enablerParams[provider].length; i++) {
enableOnClick(enablerParams[provider][i]);
}
}
}
}
function onProvider(isp) {
addTemplate(isp);
jxl.removeClass("uiMainform", allIspClasses);
jxl.addClass("uiMainform", "isp_" + isp);
for (var name in subproviderHandlers) {
if (subproviderHandlers.hasOwnProperty(name)) {
if (name == isp) {
subproviderHandlers[name].start();
}
else {
subproviderHandlers[name].stop();
}
}
}
setDisabledApply(isp == 'mobil');
}
function onProviderClick(evt) {
var radio = jxl.evtTarget(evt);
onProvider(radio.value);
}
function onSuperprovider(sup) {
var newClass = "super_";
var provider = sup;
if (Number(sup)) {
newClass += sup;
provider = superList[sup][0].id;
}
jxl.removeClass("uiMainform", allSuperClasses);
jxl.addClass("uiMainform", newClass);
jxl.setChecked("uiProvider:" + provider);
onProvider(provider);
}
function initTableSorter() {
if (jxl.get("uiScanResult")) {
sort.init("uiScanResult");
if (jxl.get("uiListOfAps")) {
sort.addTbl("uiListOfAps");
}
sort.sort_table(0);
}
}
initTableSorter();
initDoubleSelect('superprovider', 'more', onSuperprovider);
onProvider(initialIsp);
var radios = jxl.getFormElements("provider");
var i = radios.length || 0;
while (i--) {
jxl.addEventHandler(radios[i], "click", onProviderClick);
}
classChangeOnRadio({
radioName: "medium:other",
destId: "uiMainform",
classes: "dsl cable extern"
});
classChangeOnRadio({
radioName: "medium:other_named",
destId: "uiMainform",
classes: "dsl cable extern"
});
classChangeOnRadio({
radioName: "optype:other",
destId: "uiMainform",
classes: "router client"
});
classChangeOnRadio({
radioName: "optype:other_named",
destId: "uiMainform",
classes: "router client"
});
for (var p in enablerParams) {
if (enablerParams.hasOwnProperty(p)) {
if (p.indexOf("other") == 0 || p.indexOf("oma_") == 0) {
var params = enablerParams[p];
for (var i = 0; i < params.length; i++) {
enableOnClick(params[i]);
}
}
}
}
initFocusChanger('other');
initFocusChanger('other_named');
initOnClickNoauthdsl('other');
initOnClickNoauthdsl('other_named');
disableIfIPv6DsLite();
wlanscanOnload({
sid: "<?lua box.js(box.glob.sid) ?>",
scan: <?lua box.out(wlanscan.getstate()) ?>
});
}
function onConnectionExClicked(provider) {
var div = jxl.get("uiConnectionEx:" + provider);
var img = jxl.get("uiConnectionExLink:" + provider);
if (div) {
var isOpen = div.style.display != "none";
jxl.display(div, !isOpen);
if (img) {
img.src = isOpen ? "/css/default/images/link_open.gif" : "/css/default/images/link_closed.gif";
}
}
}
function doWanConfirm() {
var params = <?lua write_wan_confirm_params() ?>;
var isp = jxl.getRadioValue("provider");
if (params.needed[isp]) {
var medium = jxl.getRadioValue("medium:" + isp);
var optype = jxl.getRadioValue("optype:" + isp);
var msg;
if (medium != "dsl") {
msg = params.msg.wan;
if (optype == "client") {
msg = params.msg.ipclient;
}
}
if (msg && !confirm(msg)) {
return false;
}
}
}
function doDisableGuestConfirm() {
var params = <?lua write_disable_guest_confirm_params() ?>;
var isp = jxl.getRadioValue("provider");
if (params.needed[isp]) {
var medium = jxl.getRadioValue("medium:" + isp);
var optype = jxl.getRadioValue("optype:" + isp);
var msg;
switch (params.guest) {
case "any":
if (medium != "dsl") {
msg = params.msg.lan;
if (isp == "oma_wlan" || optype == "client") {
msg = params.msg.any;
}
}
break;
case "lan":
if (medium != "dsl") {
msg = params.msg.lan;
}
break;
case "wlan":
if (isp == "oma_wlan" || (medium != "dsl" && optype == "client")) {
msg = params.msg.wlan;
}
break;
}
if (msg) {
if (!confirm(msg)) {
return false;
}
}
}
}
function doDisableUmtsfallbackConfirm() {
var params = <?lua write_disable_umtsfallback_confirm_params() ?>;
var isp = jxl.getRadioValue("provider");
if (params.needed[isp]) {
var medium = jxl.getRadioValue("medium:" + isp);
if (medium != "dsl") {
if (!confirm(params.msg)) {
return false;
}
}
}
}
function doSpeedConfirm() {
var params = <?lua write_speed_confirm_params() ?>;
var needed = params.needed;
var isp = jxl.getRadioValue("provider");
if (needed[isp]) {
var medium = jxl.getRadioValue("medium:" + isp);
var us = jxl.getValue("uiUpstream:" + isp);
var ds = jxl.getValue("uiDownstream:" + isp);
if (medium != "dsl") {
us = Number(us) || 0;
if (us < 128) {
if (!confirm(params.msg.us)) {
return false;
}
}
ds = Number(ds) || 0;
if (ds < 128) {
if (!confirm(params.msg.ds)) {
return false;
}
}
}
}
}
function doConfirms() {
var confirmResult;
if (confirmResult !== false) {
confirmResult = doSpeedConfirm();
}
if (confirmResult !== false) {
confirmResult = doWanConfirm();
}
if (confirmResult !== false) {
confirmResult = doDisableGuestConfirm()
}
if (confirmResult !== false) {
confirmResult = doDisableUmtsfallbackConfirm();
}
if (confirmResult === false) {
return false;
}
}
function initTableSorter() {
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
}
ready.onReady(initTableSorter);
ready.onReady(pageInit);
ready.onReady(ajaxValidation({
okCallback: doConfirms
}));
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainform" name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>"
class="<?lua write_initial_class() ?>">
<?lua href.default_submit('apply') ?>
<?lua write_wdsrepeater_div() ?>
<div <?lua write_display('all') ?>>
<p>
{?301:398?}
</p>
<hr>
<h4>{?301:234?}</h4>
<?lua if isp.count() > 1 then
html.p{[[{?301:922?}]]}.write()
end ?>
<div id="uiProviderSelect">
<div class="formular doubleselect">
<?lua
isp.write_super_select{
id = "uiSuperprovider",
name = "superprovider",
label = [[{?301:518?}]],
curr_provider = initial_provider(),
addoptions = {
config.USB_GSM and {id='mobil', name=[[{?301:259?}]]} or nil
}
}
?>
</div>
<div class="super_anysuper">
<hr>
<h4>
{?301:60?}
</h4>
<p>
{?301:311?}
</p>
<?lua
isp.write_radios{
id = "uiProvider",
name = "provider",
curr_provider = initial_provider()
}
?>
</div>
<div class="formular showif_other" id="uiActivenameContainer">
<label for="uiActivename">{?301:89?}</label>
<input type="text" name="activename" id="uiActivename" maxlength="256">
</div>
</div>
<div class="formular hideif_tochoose">
<?lua write_provider_explain() ?>
</div>
<div id="uiSettingsBlock" class="hideif_tochoose">
<?lua writehtml_settings() ?>
</div>
<div id="uiCheck" class="hideif_tochoose hideif_client hideif_mobil hideif_oma_lan hideif_oma_wlan">
<hr>
<div class="formular">
<input type="checkbox" name="conncheck" id="uiConncheck" checked>
<label for="uiConncheck">
{?301:574?}
</label>
</div>
</div>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
