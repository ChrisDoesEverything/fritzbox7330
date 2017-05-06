<?lua
g_page_type = "all"
g_page_title = ""
g_page_needs_js = true
g_page_help = 'hilfe_online_monitor.html'
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"js"
require"myfritz_access"
g_nqos_cfg = {
num_sgs = tonumber(box.query("nqos:settings/stat/num_sgs")) or 1,
sample_interval = 1000 * (tonumber(box.query("nqos:settings/stat/sample_interval")) or 5),
num_samples = tonumber(box.query("nqos:settings/stat/num_samples")) or 1,
maxDrawWidth = 450, drawWidth = 437, drawHeight = 110, columnWidth = 1, xStep = 1,
ds = {
func = {{
name = 'ds_current_bps', color = "#ffee58"
}, {
name = 'mc_current_bps', color = "#9a7600"
}}
},
us = {
func = {{
name = 'prio_realtime_bps', color = "#8ed3ff"
}, {
name = 'prio_high_bps', color = "#e4b835"
}, {
name = 'prio_default_bps', color = "#45cb55"
}, {
name = 'prio_low_bps', color = "#1aabdd"
}}
}
}
for i = 0, g_nqos_cfg.num_sgs - 1 do
g_nqos_cfg["uiQosDown" .. i] = {
type = "ds", idx = i, maxValue = 1, maxYScale = 0, yStep = 4
}
g_nqos_cfg["uiQosUp" .. i] = {
type = "us", idx = i, maxValue = 1, maxYScale = 0, yStep = 4
}
end
local function add_nqos_maxima(sg)
local mode = sg.mode
local dynamic, us, ds = true, 0, 0
if mode == "DSL" or mode == "VDSL" or mode == "VDSL-Full-Bridge" then
dynamic = false
us = tonumber(box.query("dslstatglobal:status/out")) or 0
ds = tonumber(box.query("dslstatglobal:status/in")) or 0
local shapedrate_in_gui = box.query("connection0:settings/shapedrate_in_gui")
if shapedrate_in_gui == "1" then
local shapedrate_ds = tonumber(box.query("connection0:settings/shapedrate_ds")) or 0
local shapedrate_us = tonumber(box.query("connection0:settings/shapedrate_us")) or 0
ds = math.min(ds, 1000 * shapedrate_ds)
us = math.min(us, 1000 * shapedrate_us)
end
elseif mode == "LTE" then
dynamic = false
us = 1000 * (tonumber(box.query("lted:settings/hw_info/ue/connection/connrate_tx")) or 0)
ds = 1000 * (tonumber(box.query("lted:settings/hw_info/ue/connection/connrate_rx")) or 0)
elseif mode == "CABLE" then
dynamic = true
us = 384000
ds = 3600000
elseif mode == "UMTS" then
dynamic = true
us = 384000
ds = 3600000
elseif mode == "ATA" or mode == "IP-Client" then
dynamic = true
us = 2000000
ds = 30000000
else
dynamic = true
us = 0
ds = 0
end
sg.dynamic = dynamic
sg.upstream = us
sg.downstream = ds
end
function get_nqos_data()
local sgs = general.listquery("nqos:settings/sg/list("
.. "name,mode,max_ds,max_us"
.. ",ds_current_bps,mc_current_bps"
.. ",prio_realtime_bps,prio_high_bps,prio_default_bps,prio_low_bps"
.. ")"
)
for i, sg in ipairs(sgs) do
add_nqos_maxima(sg)
end
return sgs
end
function write_nqos_html(idx)
idx = (tonumber(idx) or 1) - 1
local cfg = {
ds = {
heading = [[{?577:645?}]],
id = "uiQosDown",
legend = {
{ class = "ds_color", text = [[{?txtINet?}]]},
{ class = "mc_color", text = [[{?577:274?}]]}
},
logo = "downstream_logo"
},
us = {
heading = [[{?577:152?}]],
id = "uiQosUp",
legend = {
{ class = "prio_0", text = [[{?577:584?}]]},
{ class = "prio_1", text = [[{?577:18?}]]},
{ class = "prio_2", text = [[{?577:588?}]]},
{ class = "prio_3", text = [[{?577:804?}]]}
},
logo = "upstream_logo"
}
}
if idx > 1 then
html.HR{}.write()
end
for i, which in ipairs{"ds", "us"} do
local curr = cfg[which]
local div = html.DIV{class="qos_back"}
div.add(html.H4{class="qos_title", curr.heading})
div.add(html.DIV{id=curr.id .. idx, class="qos"})
legend_tbl = html.TABLE{class="prio_legend"}
for i, legend in ipairs(curr.legend) do
legend_tbl.add(
html.TR{
html.TD{class="prio_color",
html.DIV{class=legend.class, html.raw([[&nbsp;]])}
},
html.TD{legend.text}
}
)
end
div.add(legend_tbl)
div.add(html.DIV{class=curr.logo})
div.add(
html.DIV{class="x_axis",
html.DIV{class="x_legend", [[{?577:57?}]]}
}
)
div.add(html.DIV{class="y_legend", [[{?577:468?}]]})
div.add(html.DIV{id=curr.id .. idx .. "YScale", class="y_scale"})
div.write()
html.BR{}.write()
end
end
function write_nqos_data()
require("js")
box.out(js.table(get_nqos_data()))
end
g_coninf_data={}
function init_coninf()
g_coninf_data = connection.get_conn_inf_part()
g_coninf_data.hint_dsl_no_cable = box.query("box:status/hint_dsl_no_cable")
g_coninf_data.boxDate = box.query("box:status/localtime")
if config.DOCSIS then
g_coninf_data.initStage = tonumber(box.query("docsis:status/DocsisDbEntry/initStage")) or 0
g_coninf_data.dsMaxTrafficRate = tonumber(box.query("docsis:status/QosMainDb/dsMaxTrafficRate")) or 0
g_coninf_data.usMaxTrafficRate = tonumber(box.query("docsis:status/QosMainDb/usMaxTrafficRate")) or 0
end
g_coninf_data.eth0 = box.query("eth0:status/carrier")
g_coninf_data.akt_provider_id = box.query("providerlist:settings/activeprovider")
g_coninf_data.provider = general.listquery("providerlist:settings/providerlist/list(providername,Id)")
g_coninf_data.dsl_carrier_state = general.get_dsl_state()
end
require("connection")
function State_Led (state)
if (state == "2") then
return "led_red"
end
if (state == "1") then
return "led_green"
end
if (state == "0") then
return "led_gray"
end
return ""
end
function get_row(name,link,led,info)
local str=""
if (link~="") then
str=[[<tr>
<td class="tdName"><a href="]]..link..[[">]]..name..[[</a></td>
<td><div class="]]..State_Led(led)..[[">&nbsp;</div></td>
<td class="tdinfo">]]..info..[[</td>
</tr>
]]
else
str=[[<tr>
<td class="tdName">]]..name..[[</td>
<td><div class="]]..State_Led(led)..[[">&nbsp;</div></td>
<td class="tdinfo">]]..info..[[</td>
</tr>
]]
end
return str
end
function write_row(name,link,led,info)
box.out(get_row(name,link,led,info))
end
function write_tr_connection()
box.out(connection.create_connection_row("inetmon"))
end
function write_inet_ipv4()
box.out(connection.create_ipv4_row("inetmon"))
end
function write_inet_ipv6()
box.out(connection.create_ipv6_row("inetmon"))
end
function write_ipv6_firewall()
require"menu"
if not menu.check_page("internet","/internet/ipv6_fw.lua") then
return
end
local title= [[{?577:557?}]]
local led = ""
local link = href.get("/internet/ipv6_fw.lua")
local info = ""
local count_rules = 0
local ipv6firewall_rules = general.listquery("ipv6firewall:settings/rule/list(enabled)")
for _, r in ipairs(ipv6firewall_rules) do
if r.enabled == "1" then count_rules = count_rules + 1 end
end
if(count_rules>0) then
if(count_rules==1) then
info=general.sprintf([[{?577:285?}]],count_rules)
else
info=general.sprintf([[{?577:30?}]],count_rules)
end
end
if (info~="" and (general.is_router() or g_coninf_data.ipv6_enabled == "1" or count_rules > 0)) then
write_row(title,link,led,info)
end
end
function write_used_dns_server()
if (g_coninf_data.connection_status ~= "5") then
return
end
local dnsserver=general.listquery("dnsserver:status/dnsserver/list(state,addr,domains)")
local title= [[{?577:791?}]]
local led = ""
local link = ""
local info = ""
for _, elem in ipairs(dnsserver) do
if (elem.state=="best") then
info=info..elem.addr..[[ ]]
if (elem.domains=="") then
info=info..[[{?577:226?}]]
else
info=info..general.sprintf([[{?577:556?}]],elem.domains);
end
info=info..[[<br>]]
end
if (elem.state=="enabled") then
info=info..elem.addr..[[ ]]
if (elem.domains~="") then
info=info..general.sprintf([[{?577:124?}]],elem.domains);
end
info=info..[[<br>]]
end
end
if (info~="") then
write_row(title,link,led,info)
end
end
function get_vpn_state(state)
if state=="not active" then
return "{?577:740?}, "
elseif state=="waiting" then
return "{?577:537?}, "
elseif state=="in progress" then
return "{?577:343?}, "
elseif state=="ready" then
return "{?577:7669?}, "
else
return ""
end
end
function write_vpn()
if (config.VPN and general.is_expert() and not general.is_ip_client()) then
local vpnlist=general.listquery("vpn:settings/connection/list(activated,state,name)")
local title=[[{?577:732?}]]
local link=href.get("/internet/vpn.lua")
local led=""
local info=""
for _, elem in ipairs(vpnlist) do
if (elem.activated=="1") then
if elem.state=="ready" then
led="1"
else
led="0"
end
info=get_vpn_state(elem.state)..elem.name
write_row(title,link,led,info)
end
end
end
end
function write_myfritz_shares()
local title=[[{?577:397?}]]
local link=href.get("/internet/myfritz_devicelist.lua")
require"menu"
if not menu.check_page("internet", "/internet/myfritz_devicelist.lua") then
return
end
local led=""
local info=""
local list,nr_of_shares=myfritz_access.read_list()
if (nr_of_shares==0) then
return
end
local tmp=[[{?577:390?}]]
if (not myfritz_access.is_any_share_active(list)) then
tmp=[[{?577:751?}]]
end
if (nr_of_shares==1) then
info=general.sprintf([[{?577:183?}]],tmp)
else
info=general.sprintf([[{?577:480?}]],tmp,nr_of_shares)
end
write_row(title,link,led,info)
end
function write_myfritz()
if (config.MYFRITZ and g_coninf_data.opmode ~= "opmode_eth_ipclient" ) then
local myfritz_enabled = box.query("jasonii:settings/enabled") == "1"
local myfritz_email = box.query("jasonii:settings/user_email")
if (myfritz_email=="" or not myfritz_enabled ) then
return
end
local title=[[{?577:151?}]]
local link=href.get("/internet/myfritz.lua")
local led="0"
local info=""
local state=tonumber(box.query("jasonii:settings/myfritzstate"))
if (state==301) then
led="1"
end
local url=box.query("jasonii:settings/dyndnsname")
if (url~="") then
local https_port = box.query("remoteman:settings/https_port")
if https_port ~= "" and https_port ~= "443" then
url = url..":"..https_port
end
url=[[<a target="_blank" href="https://]]..url..[[">https://]]..url..[[</a>]]..", "
end
info=general.sprintf([[{?577:24?}]],url,box.query("jasonii:settings/user_email"))
if g_coninf_data.opmode == "opmode_usb_modem" then
local tooltip = box.tohtml([[{?577:272?}]])
box.out([[<tr id="trMyFritz">]])
box.out([[<td class="tdName" title=']]..tooltip..[['>MyFRITZ!</td>]])
box.out([[<td title=']]..tooltip..[['><div class="led_gray">&nbsp;</div></td>]])
box.out([[<td class="tdinfo" title=']]..tooltip..[['>]]..info..[[</td>]])
box.out([[</tr>]])
else
write_row(title,link,led,info)
write_myfritz_shares()
end
end
end
function show_remote_https()
local result=false
if (config.REMOTE_HTTPS) then
result=box.query("remoteman:settings/enabled")=="1"
if (g_coninf_data.ata_mode=="0" and g_coninf_data.connection_type=="bridge" and g_coninf_data.encapsulation=="dslencap_pppoe") then
result=false
end
if (config.USB_GSM and g_coninf_data.umts_enabled=="1" and box.query("remoteman:settings/enabled")=="1") then
result=true
end
end
return result
end
function show_portfw()
return (g_coninf_data.connection_type=="pppoe" or
g_coninf_data.encapsulation=="dslencap_ether" or
g_coninf_data.encapsulation=="dslencap_ipnlpid" or
g_coninf_data.encapsulation=="dslencap_ipsnap" or
g_coninf_data.encapsulation=="dslencap_ipraw" or
(config.USB_GSM and g_coninf_data.umts_enabled=="1"))
end
function write_remote_https()
local https = show_remote_https()
local ftp = not general.is_bridged_mode(g_coninf_data) and box.query("ctlusb:settings/storage-ftp-internet") == "1"
if https or ftp then
local title=[[{?577:470?}]]
local link=href.get("/internet/remote_https.lua")
local led=""
local txt = [[{?577:42?} (%s)]]
local addtxt = {}
if https then table.insert(addtxt, "HTTPS") end
if ftp then table.insert(addtxt, "FTP") end
txt = txt:format(table.concat(addtxt, "/"))
write_row(title,link,led,txt)
end
end
function write_dyndns()
if (box.query("ddns:settings/account0/activated")~="1") then
return
end
local url=box.query("ddns:settings/account0/domain")
if(url=="" or url=="" or url=="er") then
url=[[{?577:527?}]]
end
local nState=tonumber(box.query("ddns:settings/account0/state"))
local state_ipv4=[[, IPv4-]]..general.get_dyndns_state(nState)
local title=[[{?577:796?}]]
local link=href.get("/internet/dyn_dns.lua")
local led=""
local state_ipv6=""
if (config.IPV6 and g_coninf_data.ipv6_enabled=="1") then
nState=tonumber(box.query("ddns:settings/account0/ip6state"))
state_ipv6=[[, IPv6-]]..general.get_dyndns_state(nState)
end
local info=general.sprintf([[{?577:686?}]],url)..state_ipv4..state_ipv6
write_row(title,link,led,info)
end
function port_range(startport, endport)
if (startport==endport or endport=="") then
return startport
end
local start=tonumber(startport)
local last =tonumber(endport)
if not start or not last then
return ""
end
return startport.."-"..tostring(start+(last-start))
end
function write_portfw()
if (show_portfw()) then
local title=[[{?577:145?}]]
local link=href.get("/internet/port_fw.lua")
local led=""
local info=""
local info_tab={}
local portfw_list=general.listquery("forwardrules:settings/rule/list(activated)")
local portrulecount=0
for _,elem in ipairs(portfw_list) do
if (elem.activated=="1") then
portrulecount=portrulecount+1
end
end
if(portrulecount>0) then
if(portrulecount==1) then
info=general.sprintf([[{?577:655?}]],portrulecount)
else
info=general.sprintf([[{?577:637?}]],portrulecount)
end
end
if box.query("box:settings/upnp/activated")== "1" and box.query("box:settings/upnp/control_activated")=="1" then
local igdfw_list=general.listquery("igdforwardrules:settings/rule/list(protocol,port)")
info_tab={}
portrulecount=#igdfw_list
for _,elem in ipairs(igdfw_list) do
table.insert(info_tab,elem.protocol.." "..elem.port)
end
if(portrulecount>0) then
if (info~="") then
info=info.."<br>"
end
if(portrulecount==1) then
info=info..general.sprintf([[{?577:951?}]],portrulecount)
else
info=info..general.sprintf([[{?577:896?}]],portrulecount)
end
if(portrulecount<10) then
info=info..[[ ( ]]..table.concat(info_tab,", ")..[[ ).]]
end
end
end
if box.query("forwardrules:settings/use_exposed_host")== "1" and box.query("forwardrules:settings/exposed_host")~="" then
if(info~="") then
info=info.."<br>"
end
info=info..general.sprintf([[{?577:566?}]],box.query("forwardrules:settings/exposed_host"))
end
if (info~="") then
write_row(title,link,led,info)
end
end
end
function write_online_cnt()
local show_Btn_and_Diagrams = false
if g_coninf_data.connection_type=='pppoe' then
show_Btn_and_Diagrams = true
end
if g_coninf_data.umts_enabled=='1'then
show_Btn_and_Diagrams = true
end
if (general.is_onlinecounter_active(g_coninf_data)) then
local title=[[{?577:94?}]]
local link=href.get("/internet/inetstat_counter.lua")
local led=""
local retstr, bshow=general.get_onlinecounter_amount()
if bshow then
write_row(title,link,led,retstr)
end
end
end
function write_monitor_visible()
end
function write_reconnection_visible()
if not general.is_expert() or general.is_ip_client() then
box.out("display:none")
end
end
function write_graph_visible()
if general.is_ip_client() then
box.out("display:none")
end
end
function write_reconnect_disabled()
if (g_coninf_data.connection_status ~= "5" or general.is_ip_client()) then
box.out("disabled")
end
end
g_ajax = false
g_action = ""
if box.get.useajax then
g_ajax = true
g_action = box.get.action
end
if box.post.useajax then
g_ajax = true
g_action = box.get.action
end
if g_ajax then
if (g_action=="get_graphic") then
write_nqos_data()
elseif (g_action=="get_table") then
init_coninf()
box.out([[
<table id="tInternetMonitor" class="zebra">
<colgroup>
<col width="140px">
<col width="25px">
<col width="auto">
</colgroup>
]])
write_tr_connection()
write_inet_ipv4()
write_inet_ipv6()
write_used_dns_server()
write_myfritz()
write_vpn()
write_remote_https()
write_dyndns()
write_portfw()
write_ipv6_firewall()
write_online_cnt()
box.out([[
<tr style="display:none">
<td colspan="3"><input type="hidden" id="uiConnectState" value="]]..g_coninf_data.connection_status..[[">
</td>
</tr>
]])
box.out([[
</table>
]])
elseif (g_action=="disconnect") then
require("cmtable")
local saveset = {}
cmtable.add_var(saveset, "connection0:settings/cmd_disconnect", "")
local err=0
err, g_errmsg = box.set_config(saveset)
box.out("done:"..tostring(err))
elseif (g_action=="connect") then
require("cmtable")
local saveset = {}
cmtable.add_var(saveset, "connection0:settings/cmd_connect", "")
local err=0
err, g_errmsg = box.set_config(saveset)
box.out("done:"..tostring(err))
end
box.end_page()
end
init_coninf()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#tInternetMonitor {
margin-top: 5px;
width:100%;
}
#tInternetMonitor td {
vertical-align:top;
}
#tInternetMonitor .led_green, #tInternetMonitor .led_red, #tInternetMonitor .led_gray {
background-position:center top;
height:16px;
}
.qos_back {
height:170px;
width:100%;
position:relative;
margin-top: 40px;
}
.qos_back div.downstream_logo,
.qos_back div.upstream_logo {
position: absolute;
width: 47px;
height: 45px;
top:97px;
left:557px;
}
.qos_back div.downstream_logo {
background-image: url(/css/default/images/pc_downstream.gif);
}
.qos_back div.upstream_logo {
background-image: url(/css/default/images/pc_upstream.gif);
}
.qos {
height: 110px;
width: 451px;
margin: 0;
padding: 0;
position:absolute;
left:61px;
top:28px;
background-color: #ffffff;
border: solid 1px #747674;
}
.qos div.column {
position: relative;
height: 110px;
float: left;
margin: 0;
padding: 0;
}
.qos div.func {
position: absolute;
left: 0px;
bottom: 0px;
width: 0px;
line-height: 0;
border: solid 0px transparent;
}
.qos_back h4.qos_title {
position:absolute;
top:-20px;
left:60px;
text-align: center;
width:437px;
}
.qos_back table.prio_legend {
background-color:transparent;
border-collapse:collapse;
border:none;
table-layout:fixed;
width:180px;
font-size:11px;
position:absolute;
left:515px;
top:28px;
}
.prio_legend td {
padding:0;
padding-left:8px;
}
.prio_legend td.prio_color {
width:20px;
vertical-align:top;
padding-left:0px;
padding-top:2px;
}
.prio_color div {
line-height:10px;
}
.prio_color div.prio_0 {
background-color:#8ed3ff;
}
.prio_color div.prio_1 {
background-color:#e4b835;
}
.prio_color div.prio_2 {
background-color:#45cb55;
}
.prio_color div.prio_3 {
background-color:#1aabdd;
}
.prio_color div.ds_color {
background-color:#ffee58;
}
.prio_color div.mc_color {
background-color:#9a7600;
}
.qos_back div.x_axis {
position:absolute;
left:61px;
top:136px;
}
.x_axis div.x_scale {
width:437px;
height:5px;
padding: 0;
border: solid 0 #747674;
font-size:1px;
}
.x_axis div.x_scale span {
display:inline-block;
border: solid 0 #747674;
border-right-width:1px;
text-align: right;
padding-right:1px;
height:100%;
}
.x_axis div.x_legend {
height:20px;
width:435px;
font-size:11px;
padding: 5px;
text-align:right;
}
.qos_back div.y_legend {
position:absolute;
left:12px;
top:8px;
font-size:11px;
}
.qos_back div.y_scale {
position:absolute;
left:0px;
top:29px;
width:61px;
height:110px;
}
.y_scale div {
position:absolute;
right:0px;
height:0px;
}
.y_scale span.number {
right:7px;
bottom:-8px;
position:absolute;
display:inline-block;
font-size:11px;
}
.y_scale span.scale {
position:absolute;
right:0px;
top:0px;
bottom:-10px;
display:inline-block;
width:5px;
height:0px;
border:solid 0 #747674;
border-top-width:1px;
}
.ReconnectBlock{
text-align:right;
margin-top:5px;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_Timer;
var g_refresh_interval_object = false;
var g_refresh_time = 30000;
var g_cfg = <?lua box.out(js.table(g_nqos_cfg)) ?>;
for (id in g_cfg) {
if (id.indexOf("uiQos") === 0) {
g_cfg[id].lastValue = [];
}
}
var g_nqos = convertNqosValues(<?lua write_nqos_data()?>)
function convertNqosValues(obj) {
obj = obj || [];
var len = Math.min(obj.length, g_cfg.num_sgs);
for (var i = 0; i < len; i++) {
obj[i].prio_realtime_bps = bpsToIntArray(obj[i].prio_realtime_bps || "");
obj[i].prio_high_bps = bpsToIntArray(obj[i].prio_high_bps || "");
obj[i].prio_default_bps = bpsToIntArray(obj[i].prio_default_bps || "");
obj[i].prio_low_bps = bpsToIntArray(obj[i].prio_low_bps || "");
obj[i].ds_current_bps = bpsToIntArray(obj[i].ds_current_bps || "");
obj[i].mc_current_bps = bpsToIntArray(obj[i].mc_current_bps || "");
if (obj[i].dynamic) {
var nMax = parseInt(obj[i].max_us, 10);
if (nMax) {
obj[i].upstream = 8 * nMax;
}
nMax = parseInt(obj[i].max_ds, 10);
if (nMax) {
obj[i].downstream = 8 * nMax;
}
obj[i].upstream = Math.max(10000, Math.floor(11 * obj[i].upstream / 10));
obj[i].downstream = Math.max(10000, Math.floor(11 * obj[i].downstream / 10));
}
}
return obj;
}
function bpsToIntArray(bps) {
bps = bps.split(",");
for (var i = 0, len = bps.length; i < len; i++) {
bps[i] = (parseInt(bps[i],10) || 0) * 8;
}
return bps;
}
function getDsValues(idx, obj) {
var result = [];
var len = g_cfg.ds.func.length;
for (var i = 0; i < len; i++) {
var qName = g_cfg.ds.func[i].name;
result[i] = obj[qName][idx];
}
for (var i = len-1; i > 0; i--) {
result[i-1] += result[i];
}
return result;
}
function getUsValues(idx, obj) {
var result = [];
var len = g_cfg.us.func.length;
for (var i = 0; i < len; i++) {
var qName = g_cfg.us.func[i].name;
result[i] = obj[qName][idx];
}
for (var i = len-1; i > 0; i--) {
result[i-1] += result[i];
}
return result;
}
function getFuncColor(divId, idx) {
return g_cfg[g_cfg[divId].type].func[idx].color || "";
}
function getFuncValues(divId, idx) {
var result = [];
var idType = g_cfg[divId].type;
var idIdx = g_cfg[divId].idx;
if (idType == 'us') {
result = getUsValues(idx, g_nqos[idIdx]);
}
else if (idType == 'ds') {
result = getDsValues(idx, g_nqos[idIdx]);
}
return result;
}
function makeAllValues(divId) {
var result = [];
var len = g_cfg.num_samples;
for (var i = 0; i < len; i++) {
result[i] = getFuncValues(divId, i);
}
return result;
}
function scaleValue(divId, v) {
var maxStream = 0;
var idType = g_cfg[divId].type;
var idIdx = g_cfg[divId].idx;
if (idType == "us") {
maxStream = g_nqos[idIdx].upstream;
}
else if (idType == "ds") {
maxStream = g_nqos[idIdx].downstream;
}
v = Math.min(v, maxStream);
var result = g_cfg.drawHeight*v/g_cfg[divId].maxValue;
return Math.floor(result);
}
function scaleValues(divId, val) {
var result = [];
for (var i = 0; i < val.length; i++ ) {
result[i] = scaleValue(divId, val[i]);
}
return result;
}
function setLastValues(divId, val) {
for (var i = 0; i < val.length; i++ ) {
g_cfg[divId].lastValue[i] = val[i];
}
}
function stopTimer() {
if (g_Timer) {
window.clearTimeout(g_Timer);
g_Timer = null;
}
}
function updateNqosValues() {
var my_url = "/internet/inetstat_monitor.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&action=get_graphic";
var jsonParse = makeJSONParser();
stopTimer();
sendUpdateRequest();
function sendUpdateRequest() {
ajaxGet(my_url, cbUpdateValues);
}
function cbUpdateValues(xhr) {
var txt = xhr.responseText || "null";
if (xhr.status != 200) {
txt = "null";
}
var newNqos = jsonParse(txt);
if (!newNqos) {
return;
}
newNqos = convertNqosValues(newNqos);
for (var i = 0; i < g_cfg.num_sgs; i++) {
var newValueUp = getUsValues(0, newNqos[i]);
var newValueDown = getDsValues(0, newNqos[i]);
if (g_nqos[i].upstream != newNqos[i].upstream || g_nqos[i].downstream != newNqos[i].downstream) {
setLastValues('uiQosUp' + i, newValueUp);
setLastValues('uiQosDown' + i, newValueDown);
g_nqos[i] = newNqos[i];
showAllValues(i);
}
else {
var idUp = "uiQosUp" + i;
var idDown = "uiQosDown" + i;
if (g_cfg[idUp].lastValue.length > 0) {
showValues(idUp, g_cfg[idUp].lastValue, newValueUp);
}
if (g_cfg[idDown].lastValue.length > 0) {
showValues(idDown, g_cfg[idDown].lastValue, newValueDown);
}
setLastValues(idUp, newValueUp);
setLastValues(idDown, newValueDown);
g_nqos[i] = newNqos[i];
}
}
g_Timer = window.setTimeout(sendUpdateRequest, g_cfg.sample_interval);
}
}
function clearValues(divId) {
var divQoS = jxl.get(divId);
if (divQoS) {
divQoS.innerHTML = "";
}
}
function isColumn(el) {
return jxl.hasClass(el, "column");
}
function dropFirstColumns(parentDiv) {
var columns = jxl.walkDom(parentDiv, 'div', isColumn);
if (columns && columns.length) {
var cnt = columns.length - g_cfg.num_samples + 2;
for (var i = 0; i < cnt; i++) {
if (columns[i]) {
parentDiv.removeChild(columns[i]);
}
}
}
}
function showValues(divId, leftValue, rightValue) {
leftValue = scaleValues(divId, leftValue);
rightValue = scaleValues(divId, rightValue);
var divQoS = jxl.get(divId);
dropFirstColumns(divQoS);
var columnDiv = document.createElement('div');
columnDiv.className = "column";
columnDiv.style.width = g_cfg.columnWidth + "px";
var valDiv = [];
for (var i = 0, len = leftValue.length; i < len; i++) {
valDiv[i] = document.createElement('div');
valDiv[i].className = "func";
valDiv[i].style.height = "" + Math.min(rightValue[i], leftValue[i]) + "px";
valDiv[i].style.borderTopWidth = "" + Math.abs(rightValue[i] - leftValue[i]) + "px";
var side = leftValue[i] < rightValue[i] ? "Right" : "Left";
valDiv[i].style["border"+side+"Width"] = g_cfg.columnWidth + "px";
valDiv[i].style["border"+side+"Color"] = getFuncColor(divId, i);
columnDiv.appendChild(valDiv[i]);
}
divQoS.appendChild(columnDiv);
}
function allDivsStr(divId) {
var funcStr;
var idType = g_cfg[divId].type;
if (idType == "us") {
funcStr = upstreamFuncStr;
}
else if (idType == "ds") {
funcStr = downstreamFuncStr;
}
var val = makeAllValues(divId);
var str = [];
for (var i = g_cfg.num_samples-1; i > 0; i--) {
str.push(funcStr(divId, val[i], val[i-1]));
}
return str.join("");;
}
function upstreamFuncStr(divId, leftValue, rightValue) {
var str = [];
leftValue = scaleValues(divId, leftValue);
rightValue = scaleValues(divId, rightValue);
str.push("<div class=\"column\"");
str.push(" style=\"width:" + g_cfg.columnWidth + "px;");
str.push("\">");
for (var i = 0, len = leftValue.length; i < len; i++) {
str.push("<div class=\"func\" style=\"");
str.push("height:" + Math.min(rightValue[i], leftValue[i]) + "px;");
str.push("border-top-width:" + Math.abs(rightValue[i] - leftValue[i]) + "px;");
var side = leftValue[i] < rightValue[i] ? "right" : "left";
str.push("border-" + side + "-width:" + g_cfg.columnWidth + "px;");
str.push("border-" + side + "-color:" + getFuncColor(divId, i) + ";");
str.push("\"></div>");
}
str.push("</div>");
return str.join("");
}
function downstreamFuncStr(divId, leftValue, rightValue) {
var str = [];
leftValue = scaleValues(divId, leftValue);
rightValue = scaleValues(divId, rightValue);
str.push("<div class=\"column\"");
str.push(" style=\"width:" + g_cfg.columnWidth + "px;");
str.push("\">");
for (var i = 0, len = leftValue.length; i < len; i++) {
str.push("<div class=\"func\" style=\"");
str.push("height:" + Math.min(rightValue[i], leftValue[i]) + "px;");
str.push("border-top-width:" + Math.abs(rightValue[i] - leftValue[i]) + "px;");
var side = leftValue[i] < rightValue[i] ? "right" : "left";
str.push("border-" + side + "-width:" + g_cfg.columnWidth + "px;");
str.push("border-" + side + "-color:" + getFuncColor(divId, i) + ";");
str.push("\"></div>");
}
str.push("</div>");
return str.join("");
}
function calcMaxValue(divId) {
var idType = g_cfg[divId].type;
var idIdx = g_cfg[divId].idx;
if (idType == "us") {
g_cfg[divId].maxValue = Math.max(1, g_nqos[idIdx].upstream);
}
else if (idType == "ds") {
g_cfg[divId].maxValue = Math.max(1, g_nqos[idIdx].downstream);
}
if (g_cfg[divId].maxValue == 1) {
g_cfg[divId].maxYScale = 0;
}
var d = 100000;
while (g_cfg[divId].maxValue < d) {
d /= 10;
}
g_cfg[divId].maxYScale = Math.floor(g_cfg[divId].maxValue/d)*d;
while (scaleValue(divId, g_cfg[divId].maxValue) - scaleValue(divId, g_cfg[divId].maxYScale) < 15) {
g_cfg[divId].maxYScale -= d;
}
}
function calcDrawValues() {
var w = g_cfg.maxDrawWidth;
var n = g_cfg.num_samples-1;
var c = Math.floor(Math.max(1, w/n));
while (c > 1 && n * c < w) {
w--;
c = Math.floor(Math.max(1, w/n));
}
g_cfg.drawWidth = w;
g_cfg.columnWidth = c;
}
function numToStr3(num) {
var prefix = "";
if (num < 100) {
prefix += "0";
}
if (num < 10) {
prefix += "0";
}
return prefix + num;
}
function dottedStr(num) {
var result = [];
var z = parseInt(num,10);
while (z > 999) {
result.push(numToStr3(z % 1000));
z = Math.floor(z/1000);
}
result.push(z);
return result.reverse().join(".");
}
function yScaleStr(divId) {
var v = [];
if (g_cfg[divId].maxValue <= 1) {
v[0] = 0;
}
else {
for (var i = g_cfg[divId].yStep; i >= 0; i--) {
v[i] = i*g_cfg[divId].maxYScale/g_cfg[divId].yStep;
}
}
var str = [];
if (g_cfg[divId].maxValue > 1) {
str.push('<div style=\"bottom:' + (g_cfg.drawHeight+1) + 'px;\">');
str.push('<span class=\"number\">' + dottedStr(g_cfg[divId].maxValue/1000) + '</span>');
str.push('<span class=\"scale\"></span>');
str.push('</div>');
}
for (var i = 0; i < v.length; i++) {
var b = Math.floor(g_cfg.drawHeight*v[i]/g_cfg[divId].maxValue);
str.push('<div style=\"bottom:' + b + 'px;\">');
str.push('<span class=\"number\">' + dottedStr(v[i]/1000) + '</span>');
str.push('<span class=\"scale\"></span>');
str.push('</div>');
}
return str.join("");
}
function showYScale(divId) {
var divYScale = jxl.get(divId + "YScale");
var div = [];
var v = [];
if (g_cfg[divId].maxValue <= 1) {
v[0] = 0;
}
else {
for (var i = g_cfg[divId].yStep; i >= 0; i--) {
v[i] = i*g_cfg[divId].maxYScale/g_cfg[divId].yStep;
}
}
var inc = 0;
if (g_cfg[divId].maxValue > 1) {
div[0] = document.createElement('div');
var b = Math.floor(g_cfg.drawHeight);
div[0].style.bottom = b + "px";
var span = document.createElement('span');
span.className = "number";
span.innerHTML = dottedStr(g_cfg[divId].maxValue/1000);
div[0].appendChild(span);
span = document.createElement('span');
span.className = "scale";
div[0].appendChild(span);
inc = 1;
}
for (var i = 0; i < v.length; i++) {
div[i+inc] = document.createElement('div');
var b = Math.floor(g_cfg.drawHeight*v[i]/g_cfg[divId].maxValue);
div[i+inc].style.bottom = b + "px";
var span = document.createElement('span');
span.className = "number";
span.innerHTML = dottedStr(v[i]/1000);
div[i+inc].appendChild(span);
span = document.createElement('span');
span.className = "scale";
div[i+inc].appendChild(span);
}
divYScale.innerHTML = "";
var fragment = document.createDocumentFragment();
for (var i = 0; i < div.length; i++) {
fragment.appendChild(div[i]);
}
divYScale.appendChild(fragment);
}
function showAllValues(idPostfix) {
calcDrawValues();
calcMaxValue("uiQosDown" + idPostfix);
calcMaxValue("uiQosUp" + idPostfix);
var div = jxl.get("uiQosDown" + idPostfix);
div.innerHTML = allDivsStr("uiQosDown" + idPostfix);
jxl.setStyle(div, "width", g_cfg.drawWidth + "px");
div = jxl.get("uiQosDown" + idPostfix + "YScale");
div.innerHTML = yScaleStr('uiQosDown' + idPostfix);
div = jxl.get("uiQosUp" + idPostfix);
div.innerHTML = allDivsStr("uiQosUp" + idPostfix);
jxl.setStyle(div, "width", g_cfg.drawWidth + "px");
div = jxl.get("uiQosUp" + idPostfix + "YScale");
div.innerHTML = yScaleStr('uiQosUp' + idPostfix);
}
function change_time_interval_ajax(refresh_time)
{
if(g_refresh_interval_object) window.clearInterval(g_refresh_interval_object);
g_refresh_interval_object = window.setInterval(RefreshPageContent, refresh_time);
}
function RefreshPageContent(part)
{
var my_url = "/internet/inetstat_monitor.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&action=get_table";
sendUpdateRequest();
function sendUpdateRequest() {
ajaxGet(my_url, cbUpdateTable);
}
function cbUpdateTable(xhr) {
var txt = xhr.responseText || "null";
if (xhr.status != 200) {
return;
}
jxl.setHtml("uiInternetMonitor",txt)
zebra();
var obj=document.getElementById("uiConnectState")
if (obj && obj.value=="5") {
jxl.enable("uiReconnectBtn");
}
}
}
function uiDoRefresh() {
if (g_refresh_interval_object) {
window.clearInterval(g_refresh_interval_object);
}
if (g_Timer) {
window.clearTimeout(g_Timer);
}
location.href=""
}
function connect_again()
{
var my_url = "/internet/inetstat_monitor.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&action=connect";
sendUpdateRequest();
function sendUpdateRequest()
{
ajaxGet(my_url, cbConnected);
}
function cbConnected()
{
jxl.enable("uiReconnectBtn");
jxl.hide("uiWarnDisconnecting");
RefreshPageContent();
change_time_interval_ajax(g_refresh_time);
}
}
function DoDisconnectInternet()
{
var my_url = "/internet/inetstat_monitor.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&action=disconnect";
sendUpdateRequest();
function sendUpdateRequest()
{
change_time_interval_ajax(2000);
jxl.disable("uiReconnectBtn");
jxl.show("uiWarnDisconnecting");
ajaxGet(my_url, cbDisconnected);
}
function cbDisconnected()
{
window.setTimeout("connect_again()",6000);
window.setTimeout(function(){change_time_interval_ajax(g_refresh_time);},60000);
}
return false;
}
function init()
{
for (var i = 0; i < g_cfg.num_sgs; i++) {
showAllValues(i);
}
updateNqosValues();
if(g_refresh_interval_object) window.clearInterval(g_refresh_interval_object);
RefreshPageContent();
g_refresh_interval_object = window.setInterval(RefreshPageContent, g_refresh_time);
window.setTimeout(uiDoRefresh, 60*60*1000);
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="uiMonitor" style="<?lua write_monitor_visible() ?>">
<p>{?577:122?}</p>
<div id="uiInternetMonitor">
<table id="tInternetMonitor" class="zebra">
<colgroup>
<col width="140px">
<col width="25px">
<col width="auto">
</colgroup>
<?lua
write_tr_connection()
write_inet_ipv4()
write_inet_ipv6()
write_used_dns_server()
write_myfritz()
write_vpn()
write_remote_https()
write_dyndns()
write_portfw()
write_ipv6_firewall()
write_online_cnt()
?>
</table>
</div> <!-- uiInternetMontior -->
<!-- früher IC_Btn -->
<div id="uiReconnection_Btn" style="<?lua write_reconnection_visible() ?>">
<hr>
<div>
<?lua
if g_coninf_data.ipv6_enabled == "1" then
box.out([[{?577:263?}</div>]])
else
box.out([[{?577:4570?}</div>]])
end
?>
<div class="ReconnectBlock" >
<span id="uiWarnDisconnecting" style="display:none">
{?577:215?}
</span>
<input type="button" id="uiReconnectBtn" onclick="return DoDisconnectInternet();" value="{?577:11?}" <?lua write_reconnect_disabled()?>>
</div>
</div><!-- uiReconnection_Btn -->
<div id="uiDownUpDiag" style="<?lua write_graph_visible()?>">
<hr>
<h4>{?577:988?}</h4>
<div>
{?577:913?}
</div>
<?lua for i = 1, g_nqos_cfg.num_sgs do write_nqos_html(i) end ?>
</div><!-- uiDownUpDiag -->
</div><!-- uiMontior -->
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="btn_refresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
