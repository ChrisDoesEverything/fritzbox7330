<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_security.html"
dofile("../templates/global_lua.lua")
require("html")
require("href")
require("isp")
require("fon_numbers")
require"boxusers"
require"net_devices"
g_data = {}
function read_data_values()
g_data.list_of_known_vcs ={
"internet",
"voip",
"tr069",
"tv",
"voip+tr069",
"voip+tv",
"voip+tr069+tv",
"tr069+tv"
}
g_data.filter_netbios=box.query("connection0:settings/filter_netbios")=="1"
g_data.filter_teredo=box.query("connection0:settings/filter_teredo")=="1"
g_data.openports=general.listquery("openports:settings/openports/list(addrtype,protocol,extern_ip,extern_port,intern_ip,intern_port,intern_name,priority,group,type,exposed_host,ping_allowed,temporary,description,dsliface)")
g_data.dsliface_names = general.listquery("capture:settings/iface/list(name,type)")
g_data.dslifaces = {}
for i,elem in ipairs(g_data.openports) do
local dsliface=string.lower(elem.dsliface)
if not g_data.dslifaces[dsliface] then
g_data.dslifaces[dsliface]={}
end
table.insert(g_data.dslifaces[dsliface],elem)
end
function convert(port)
local res,pos=tonumber(port)
if not res then
res=tonumber((port:gsub("%-.*",""))) or 0
end
return res
end
function compare_ports(d1, d2)
local port1=convert(d1.extern_port)
local port2=convert(d2.extern_port)
return (port1 < port2)
end
for i,dsliface in pairs(g_data.dslifaces) do
table.sort(dsliface,compare_ports)
end
g_data.wlan_ready = box.query("wlan:settings/wlan_config_status") ~= "fail"
g_data.ap_enabled= box.query("wlan:settings/ap_enabled")=="1" and g_data.wlan_ready
g_data.ap_enabled_scnd= box.query("wlan:settings/ap_enabled_scnd")=="1" and g_data.wlan_ready
g_data.ssid= box.query("wlan:settings/ssid")
g_data.ssid_scnd= box.query("wlan:settings/ssid_scnd")
g_data.wps_mode= box.query("wlan:settings/wps_mode")
g_data.wlan_active=false
if (g_data.ap_enabled or g_data.ap_enabled_scnd) then
g_data.wlan_active=true
end
g_data.wlanguest_active = box.query("wlan:settings/guest_ap_enabled")=="1"
g_data.wlanguest_encryt = box.query("wlan:settings/guest_encryption")
g_data.wlanguest_ssid = box.query("wlan:settings/guest_ssid")
g_data.wlanguest_time_remain= box.query("wlan:settings/guest_time_remain")
g_data.encryption = box.query("wlan:settings/encryption")
g_data.bg_mode = box.query("wlan:settings/bg_mode")
g_data.stick_and_surf_enabled = box.query("ctlusb:settings/autoprov_enabled")=="1"
g_data.isolation = box.query("wlan:settings/user_isolation")
g_data.macfilter = box.query("wlan:settings/is_macfilter_active")
g_data.dect_enabled=box.query("dect:settings/enabled")=="1"
if (g_data.dect_enabled) then
g_data.dect_device_list= general.listquery("dect:settings/Handset/list(Subscribed)")
end
g_data.dect_repeater_enabled= box.query("dect:settings/DECTRepeaterEnabled")
g_data.repeater_mode = box.query("dect:settings/RepeaterMode") == "1"
g_RefreshDiversity= box.query("telcfg:settings/RefreshDiversity")
g_data.all_ruls = fon_numbers.get_rul_all()
g_data.rul_list=fon_numbers.get_dialruls()
g_data.isUpdateAvail = box.query("updatecheck:status/update_available_hint")=="1"
end
read_data_values()
function write_usage(which)
if (which=="connection") then
require("connection")
g_coninf_data = connection.get_conn_inf_part()
box.out([[<div>]])
box.out([[<table>]])
box.out([[
<colgroup>
<col width="20px">
<col width="50px">
<col width="auto">
</colgroup>]])
box.out(connection.create_ipv4_row("home"))
box.out(connection.create_ipv6_row("home"))
box.out([[</table>]])
box.out([[</div>]])
end
end
function get_service_name(elem)
local result=elem.description or ""
if elem.type=="FTP" then
result=[[{?8836:795?}]]
elseif elem.type=="HTTP" then
result=[[{?8836:16?}]]
elseif elem.type=="HTTPS" then
result=[[{?8836:1674?}]]
elseif elem.type=="HTTPS_NAS" then
result=[[{?8836:465?}]]
elseif elem.type=="SIP" then
result=[[{?8836:132?}]]
elseif elem.type=="RTP" then
result=[[{?8836:321?}]]
elseif elem.type=="IPERF_C" then
result=[[{?8836:636?}]]
elseif elem.type=="IPERF_S" then
result=[[{?8836:364?}]]
elseif elem.type=="TR069" then
result=[[{?8836:999?}]]
elseif elem.type=="USER_V4" then
result=[[{?8836:547?}]]
if elem.intern_name~="" then
result=elem.intern_name
end
elseif elem.type=="USER_V6" then
result=[[{?8836:1410?}]]
if elem.intern_name~="" then
result=elem.intern_name
end
elseif elem.type=="IKE" then
result=[[{?8836:642?}]]
elseif elem.type=="NAT-T" then
result=[[{?8836:32?}]]
elseif elem.type=="" and elem.exposed_host=="1" then
result=[[{?8836:413?}]]
end
return box.tohtml(result)
end
function get_ip_type(elem)
local ip_type="IPv4"
if elem.addrtype=="v6" then
ip_type="IPv6"
end
return ip_type
end
function get_protocol(elem)
local ip_type=get_ip_type(elem)
return elem.protocol..", "..ip_type
end
function get_help_file(elem)
local result="hilfe_security"
if elem then
--[[ types:
0 = Unknown
1 = FTP
2 = HTTP
3 = HTTPS
4 = HTTPS_NAS
5 = SIP/VOIP
6 = RTP/VOIP
7 = IPERF_Client
8 = IPERF_Server
9 = TR069
10 = USERFW_V4
11 = USERFW_V6
= IKE (Mail von David vom 10.3.2014 gegen 10
= NAT-T
]]
if elem.type=="FTP" then
result="hilfe_port_ftp"
elseif elem.type=="HTTP" then
result="hilfe_port_http"
elseif elem.type=="HTTPS" then
result="hilfe_port_https"
elseif elem.type=="HTTPS_NAS" then
result="hilfe_port_https_nas"
elseif elem.type=="SIP" then
result="hilfe_port_sip"
elseif elem.type=="RTP" then
result="hilfe_port_rtp"
elseif elem.type=="IPERF_C" then
result="hilfe_port_iperf"
elseif elem.type=="IPERF_S" then
result="hilfe_port_iperf"
elseif elem.type=="TR069" then
result="hilfe_port_tr069"
elseif elem.type=="USER_V4" then
result="hilfe_portfreigaben_user"
elseif elem.type=="USER_V6" then
result="hilfe_portfreigaben_user"
elseif elem.type=="IKE" then
result="hilfe_port_ike"
elseif elem.type=="NAT-T" then
result="hilfe_port_ipsec"
elseif elem.type=="" and elem.exposed_host=="1" then
result="hilfe_exposed_host"
end
end
return href.help_get(result)
end
function get_link_file(elem)
local result="/internet/port_fw.lua"
--[[ types:
0 = Unknown
1 = FTP
2 = HTTP
3 = HTTPS
4 = HTTPS_NAS
5 = SIP/VOIP
6 = RTP/VOIP
7 = IPERF_Client
8 = IPERF_Server
9 = TR069
10 = USERFW_V4
11 = USERFW_V6
]]
if elem.type=="FTP" then
result="/internet/remote_https.lua"
elseif elem.type=="HTTP" then
result="/"
elseif elem.type=="HTTPS" then
result="/internet/remote_https.lua"
elseif elem.type=="HTTPS_NAS" then
result="/storage/media_settings.lua"
elseif elem.type=="SIP" then
result="/fon_num/fon_num_list.lua"
elseif elem.type=="RTP" then
result="/fon_num/fon_num_list.lua"
elseif elem.type=="IPERF_C" then
result="/support.lua"
elseif elem.type=="IPERF_S" then
result="/support.lua"
elseif elem.type=="TR069" then
result="/internet/providerservices.lua"
elseif elem.type=="USER_V4" then
result="/internet/port_fw.lua"
elseif elem.type=="USER_V6" then
result="/internet/ipv6_fw.lua"
elseif elem.type=="IKE" or elem.type=="NAT-T" then
result="/internet/vpn.lua"
elseif elem.type=="" and elem.exposed_host=="1" then
result="/internet/port_fw.lua"
end
return href.get(result)
end
function get_link(link,help_link,link_txt,param)
if not param then
param=""
end
if g_print_mode then
return ""
end
if not link_txt then
link_txt=[[{?8836:993?}]]
end
if not help_link then
help_link=get_help_file()
end
link_txt=box.tohtml(link_txt)
return general.sprintf([[<a href="%1" title="%2" onclick="help.popup('%1'); return false;" class="help">&nbsp;</a>&nbsp;<a href="%3">%4</a>]],help_link,box.tohtml([[{?txtHelp?}]]),href.get(link,param),link_txt)
end
function get_sorted_protocols(tab)
local res=""
if tab then
table.sort(tab,function(d1,d2) return (d1 or "") > (d2 or "") end)
res=box.tohtml(table.concat(tab,", "))
end
return res
end
function get_line(elem)
local result=[[<tr><td>]]..box.tohtml(elem.extern_port)..[[</td><td>]]..get_protocol(elem)..[[</td><td>]]..get_service_name(elem)..[[</td><td>]]..get_link(get_link_file(elem),get_help_file(elem))..[[</td></tr>]]
return result
end
function get_line_short(elem)
local result=[[]]
if elem.exposed_host then
result=[[<tr><td title="{?8836:899?}" class="exposed_host">]]..box.tohtml(elem.extern_port)..[[</td><td>]]..get_sorted_protocols(elem.protocols)..[[</td><td>]]..box.tohtml(elem.service).." "..box.tohtml(elem.ip)..[[</td><td>]]..elem.link..[[</td></tr>]]
else
result=[[<tr><td>]]..box.tohtml(elem.extern_port)..[[</td><td>]]..get_sorted_protocols(elem.protocols)..[[</td><td>]]..box.tohtml(elem.service).." "..box.tohtml(elem.ip)..[[</td><td>]]..elem.link..[[</td></tr>]]
end
return result
end
function find_protocol(protocols,elem_type)
local res=false
if (protocols) then
if (string.find(table.concat(protocols,","),elem_type)==nil) then
res=true
end
end
return res
end
function add_portitem(dsliface,dat,idx,elem,no_ip)
local array_idx=elem.extern_port
if (elem.extern_port=="") then
array_idx=elem.intern_ip
end
if elem.exposed_host=="1" then
if (not dat["exposed"]) then
dat["exposed"]={}
if g_data.dslifaces[dsliface] then
idx=#g_data.dslifaces[dsliface]+1
end
dat["exposed"].idx=idx
dat["exposed"].protocols = {}
if elem.addrtype=="v6" then
dat["exposed"].extern_port=[[{?8836:9309?}]]
else
dat["exposed"].extern_port=[[{?8836:155?}]]
end
dat["exposed"].service =get_service_name(elem)
if (dsliface=="internet") then
dat["exposed"].link =get_link(get_link_file(elem),get_help_file(elem))
else
dat["exposed"].link =""
end
dat["exposed"].exposed_host = elem.exposed_host=="1"
dat["exposed"].ip = elem.intern_ip
else
dat["exposed"].ip = dat["exposed"].ip..", "..elem.intern_ip
end
if find_protocol(dat["exposed"].protocols,get_ip_type(elem)) then
table.insert(dat["exposed"].protocols,get_ip_type(elem))
end
return
elseif (not dat[array_idx]) then
dat[array_idx]={}
dat[array_idx].idx=idx
dat[array_idx].protocols = {}
dat[array_idx].extern_port=elem.extern_port
dat[array_idx].service =get_service_name(elem)
if (dsliface=="internet") then
dat[array_idx].link =get_link(get_link_file(elem),get_help_file(elem))
else
dat[array_idx].link =""
end
dat[array_idx].exposed_host = elem.exposed_host=="1"
if (no_ip=="no_ip") then
dat[array_idx].ip = ""
else
dat[array_idx].ip = elem.intern_ip
end
table.insert(dat[array_idx].protocols,elem.protocol)
end
if find_protocol(dat[array_idx].protocols,elem.protocol) then
table.insert(dat[array_idx].protocols,elem.protocol)
end
if find_protocol(dat[array_idx].protocols,get_ip_type(elem)) then
table.insert(dat[array_idx].protocols,get_ip_type(elem))
end
end
function create_sorted_table(dat,no_service_txt)
local services={}
for key, value in pairs(dat) do
table.insert(services,{idx=dat[key].idx,line=get_line_short(dat[key])})
end
if #services==0 then
table.insert(services,{idx=1,line=[[<tr><td colspan="4">]]..no_service_txt..[[</td></tr>]]})
else
table.sort(services,function (d1, d2) return (d1.idx < d2.idx) end)
end
return services
end
function write_sorted_table(services)
local str=""
table.foreach(services, function (i) str=str..services[i].line end)
box.out(str)
end
function write_services(dsliface)
if not g_data.dslifaces[dsliface] then
g_data.dslifaces[dsliface]={}
end
local services={}
local dat={}
box.out([[<table class="ports">]])
box.out([[<colgroup><col width="110px"><col width="190px"><col width="330px"><col width="auto"></colgroup>]])
box.out([[<tr><th>{?8836:839?}</th><th>{?8836:414?}</th><th>{?8836:418?}</th><th>&nbsp</th></tr>]])
for i,elem in ipairs(g_data.dslifaces[dsliface]) do
if not (elem.type == "USER_V4" or elem.type == "USER_V6") and elem.extern_port~="" then
add_portitem(dsliface,dat,i,elem,"no_ip")
end
end
services=create_sorted_table(dat,[[{?8836:408?}]])
write_sorted_table(services)
box.out([[</table>]])
end
function write_ports(dsliface)
local services={}
local dat={}
box.out([[<table class="ports">]])
box.out([[<colgroup><col width="110px"><col width="190px"><col width="330px"><col width="auto"></colgroup>]])
box.out([[<tr><th>{?8836:1070?}</th><th>{?8836:4542?}</th><th>{?8836:918?}</th><th>&nbsp</th></tr>]])
for i,elem in ipairs(g_data.dslifaces[dsliface]) do
if ((elem.type == "USER_V4" or elem.type == "USER_V6") and elem.extern_port~="") or (elem.exposed_host=="1") then
add_portitem(dsliface,dat,i,elem,"with_ip")
end
if ((elem.type == "USER_V4" or elem.type == "USER_V6") and elem.extern_port=="") then
add_portitem(dsliface,dat,i,elem,"with_ip")
end
end
services=create_sorted_table(dat,[[{?8836:447?}]])
write_sorted_table(services)
box.out([[</table>]])
end
function write_filter()
box.out([[<table class="ports">]])
box.out([[<colgroup><col width="110px"><col width="320px"><col width="200px"><col width="auto"></colgroup>]])
box.out(general.sprintf([[<tr><th>{?8836:967?}</td><th>{?8836:543?}</th><th></th><th></th></tr>]]))
box.out(general.sprintf([[<tr><td>{?8836:431?}</td><td>%1</td><td>&nbsp;</td><td>%2</td></tr>]], get_active(g_data.filter_netbios),get_link([[/internet/trafficappl.lua]],href.help_get([[hilfe_sicherheit_filter]],[[anchor=sicherheit_filter_netbios]]))))
box.out(general.sprintf([[<tr><td>{?8836:548?}</td><td>%1</td><td>&nbsp;</td><td>%2</td></tr>]], get_active(g_data.filter_teredo),get_link([[/internet/trafficappl.lua]],href.help_get([[hilfe_sicherheit_filter]],[[anchor=sicherheit_filter_teredo]]))))
box.out([[</table>]])
end
function get_wlan_enc(enc,link,helplink)
g_no_auto_init_net_devices=true
if tonumber(enc) and tonumber(enc) ~= 0 then
return [[{?8836:21?} (]]..box.tohtml(net_devices.get_seclevel(enc))..[[)]]
else
return [[<span class="WlanOpen">]]..box.tohtml(net_devices.get_seclevel(enc))..[[</span>]]..
[[<span class="ShowLinkRight">]]..get_link(link,helplink,[[{?8836:381?}]])..[[</span>]]
end
end
function get_active(active)
if (not active) then
return box.tohtml([[{?8836:283?}]])
end
return box.tohtml([[{?8836:18?}]])
end
function write_wlan_ssid_guest()
box.html(g_data.wlanguest_ssid)
end
function write_wlan_ssid_24()
box.html(g_data.ssid)
end
function write_wlan_ssid_5()
box.html(g_data.ssid_scnd)
end
function write_count(count)
if count==0 then
box.html([[{?8836:714?}]])
elseif count==1 then
box.html([[{?8836:5816?}]])
else
box.html(general.sprintf([[{?8836:502?}]],tostring(count)))
end
end
function write_active_wlan_devices()
local count=net_devices.get_num_of_active_wlan_devs()
write_count(count)
end
function write_active_wlan_guest_devices()
local count=net_devices.get_num_of_active_wlan_guestdevs()
write_count(count)
end
function write_wlan_active_24()
box.out(get_active(g_data.ap_enabled))
end
function write_wlan_active_5()
box.out(get_active(g_data.ap_enabled_scnd))
end
function write_only_helpicon(link,helpfile)
box.out([[<span class="ShowLinkRight">]])
box.out(get_link(link,href.help_get(helpfile),""))
box.out([[</span>]])
end
function write_stick_and_surf()
box.out(get_active(g_data.stick_and_surf_enabled))
end
function write_isolation()
if g_data.isolation=="0" then
box.html([[{?8836:70?}]])
else
box.html([[{?8836:758?}]])
end
end
function write_macfilter()
if g_data.macfilter=="1" then
box.html([[{?8836:705?}]])
else
box.html([[{?8836:655?}]])
end
end
function write_wps_mode()
if g_data.wps_mode=="0" then
box.out([[{?8836:58?}]])
elseif g_data.wps_mode=="1" or g_data.wps_mode=="1001" then
box.out([[{?8836:415?}]])
elseif g_data.wps_mode=="2" or g_data.wps_mode=="1002" then
box.out([[{?8836:5433?}]])
elseif g_data.wps_mode=="3" or g_data.wps_mode=="1003" then
box.out([[{?8836:282?}]])
elseif g_data.wps_mode=="4" or g_data.wps_mode=="1004" then
box.out([[{?8836:272?}]])
end
end
function write_wlan_enc()
box.out(get_wlan_enc(g_data.encryption,[[/wlan/encrypt.lua]],[[hilfe_sicherheit_wlan]]))
end
function write_wlan_guest_active(band)
local active=g_data.ap_enabled
if (band=="5") then
active=g_data.ap_enabled_scnd
end
box.out(get_active(g_data.wlanguest_active and active))
end
function write_wlan_guest_enc()
box.out(get_wlan_enc(g_data.wlanguest_encryt,[[/wlan/guest_access.lua]],[[hilfe_sicherheit_wlan]]))
end
function write_dect()
box.out([[<tr><td>]]) box.html ([[{?8836:95?}]]) box.out([[</td><td>]]) box.out(get_active(g_data.dect_enabled)) box.out([[</td><td>]]) box.out(get_link([[/dect/dect_settings.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_dect]]))) box.out([[</td></tr>]])
if (g_data.dect_enabled) then
box.out([[<tr><td>]]) box.html([[{?8836:553?}]]) box.out([[</td><td>]]) box.out(general.get_txt_dect(g_data)) box.out([[</td><td>]])box.out(get_link([[/dect/dect_list.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_dect]]))) box.out([[</td></tr>]])
box.out([[<tr><td>]]) box.html([[{?8836:165?}]]) box.out([[</td><td>]])
if g_data.repeater_mode then
box.html([[{?8836:205?}]])
else
box.html([[{?8836:371?}]])
end
box.out([[</td><td>]])box.out(get_link([[/dect/dect_settings.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_dect]]))) box.out([[</td></tr>]])
end
end
function write_fritz_os_update()
local nspver = box.query("logic:status/nspver")
nspver = nspver:gsub("^(.-%.)", "")
box.html([[{?8836:715?} ]]) box.html(nspver) box.out([[<br>]])
if (g_data.isUpdateAvail) then
box.out(general.fritz_os_update())
else
box.html([[{?8836:193?}]])
end
end
function get_warning_rul_0900()
local elem=fon_numbers.find_dial_rul(g_data.rul_list,"sonderrufnrn")
if not elem then
return box.tohtml([[{?8836:986?}]])
end
return box.tohtml([[{?8836:594?}]])
end
function get_warning_rul_international()
local elem=fon_numbers.find_dial_rul(g_data.rul_list,"international")
if not elem then
return box.tohtml([[{?8836:9255?}]])
end
return box.tohtml([[{?8836:0?}]])
end
function write_active_ruls()
local count_ruls=fon_numbers.get_num_of_active_ruls(g_data.all_ruls)
box.out([[<tr><td>]]) box.html([[{?8836:1731?}]]) box.out([[</td><td>]])
if (count_ruls==0) then
box.html([[{?8836:540?}]])
elseif (count_ruls==1) then
box.html([[{?8836:697?}]])
else
box.html(general.sprintf([[{?8836:878?}]],tostring(count_ruls)))
end
box.out([[</td><td>]]) box.out(get_link([[/fon_num/rul_list.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_rufumleitungen]]))) box.out([[</td><tr>]])
if (config.country=="049") then
box.out([[<tr><td>]]) box.html([[{?8836:554?}]]) box.out([[</td><td>]]) box.out(get_warning_rul_0900()) box.out([[</td><td>]]) box.out(get_link([[/fon_num/sperre.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_rufnummern_spezial]]))) box.out([[</td><tr>]])
box.out([[<tr><td>]]) box.html([[{?8836:383?}]]) box.out([[</td><td>]]) box.out(get_warning_rul_international()) box.out([[</td><td>]]) box.out(get_link([[/fon_num/sperre.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_rufnummern_ausland]]))) box.out([[</td><tr>]])
end
end
function get_access_from_internet(from_internet)
if from_internet then
return [[{?8836:4965?}]]
end
return [[{?8836:54?}]]
end
function write_ip_phones()
require ("fon_devices")
local count=0
for i,elem in ipairs(fon_devices.read_voip_ext()) do
count=i
box.out([[<tr><td>]]) box.html(elem.name) box.out([[</td><td>]]) box.html(get_access_from_internet(elem.reg_from_outside)) box.out([[</td><td>]]) box.out(get_link([[/fon_devices/fondevices_list.lua]],href.help_get([[hilfe_sicherheit_telefonie]],[[anchor=telefonie_iptelefone]]))) box.out([[</td></tr>]])
end
if (count==0) then
box.out([[<tr><td colspan="3">]]) box.html([[{?8836:941?}]]) box.out([[</td></tr>]])
end
end
function write_pwd_warning()
local auth_mode = boxusers.auth_mode()
local pwInfo = auth_mode=="skip"
if (pwInfo) then
box.out([[<div class="msg_hint WarnMsg">]]) box.html([[{?8836:556?}]]) box.out([[</div>]])
end
end
function write_pwd()
local auth_mode = boxusers.auth_mode()
if auth_mode == 'skip' then
box.out(general.pwd_info())
elseif auth_mode == "user" then
box.html([[{?8836:734?}]])
elseif auth_mode == "compat" then
box.html([[{?8836:101?}]])
end
end
function write_rights(user)
local str_rights={
box_admin_rights=[[{?8836:740?}]],
phone_rights =[[{?8836:996?}]],
nas_rights =[[{?8836:203?}]],
homeauto_rights =[[{?8836:958?}]],
vpn_access =[[{?8836:312?}]]
}
local possible_rights=boxusers.rights()
local rights={}
local right_val=0
for i,right in ipairs(possible_rights) do
right_val = tonumber(user[right]) or 0
if right_val>0 then
table.insert(rights,str_rights[right])
end
end
box.html(table.concat(rights, ", "))
end
function query_logins(user_id)
return general.listquery([[boxusers:settings/]]..user_id..[[/logins0/entry/list(login_time,from_internet,ip)]])
end
function write_user_log(user)
local logins=query_logins(user._node)
if (#logins>0) then
for i,entry in ipairs(logins) do
box.out([[<tr><td>]])box.html(user.name) box.out([[</td><td>]]) write_rights(user) box.out([[</td><td>]]) box.html(entry.login_time) box.out([[</td><td>]])box.html(entry.ip) box.out([[</td><td>]]) box.out(get_link([[/system/boxuser_list.lua]],href.help_get([[hilfe_sicherheit_access]],[[anchor=access_user]]))) box.out([[</td></tr>]])
if i>3 then
break
end
end
else
box.out([[<tr><td>]]) box.html(user.name) box.out([[</td><td>{?8836:589?}<br>]]) write_rights(user) box.out([[</td><td></td><td></td><td>]]) box.out(get_link([[/system/boxuser_list.lua]],href.help_get([[hilfe_sicherheit_access]],[[anchor=access_user]]))) box.out([[</td></tr>]])
end
end
function write_user_rights()
box.out([[<table class="ports">]])
box.out([[<colgroup><col width="110px"><col width="300px"><col width="120px"><col width="auto"><col width="auto"></colgroup>]])
box.out([[<tr><th>{?8836:22?}</th><th>{?8836:5733?}</th><th>{?8836:730?}</th><th>{?8836:612?}</th><th></th></tr>]])
for i, user in ipairs(boxusers.list) do
write_user_log(user)
end
if #boxusers.list==0 then
box.out([[<tr><td colspan="5">]]) box.html([[{?8836:419?}]]) box.out([[</td></tr>]])
end
box.out([[</table>]])
end
function get_permission(count,dir_count,file_count)
if count==0 then
return [[{?8836:80?}]]
elseif count==1 then
if dir_count==1 then
return [[{?8836:102?}]]
end
return [[{?8836:588?}]]
end
if (dir_count==0 and file_count>=1) then
return general.sprintf([[ {?8836:582?}]],file_count)
end
if (dir_count>=1 and file_count==0) then
return general.sprintf([[ {?8836:223?}]],dir_count)
end
if (dir_count>=1 and file_count==1) then
return general.sprintf([[ {?8836:860?}]],dir_count,file_count)
end
return general.sprintf([[ {?8836:1778?}]],dir_count,file_count)
end
function get_nas_access()
local https=box.query("remoteman:settings/enabled")=="1"
local ftp =box.query("ctlusb:settings/storage-ftp-internet") == "1"
local ftps =box.query("ctlusb:settings/internet-secured") == "1"
if not https and not ftp and not ftps then
return box.html([[{?8836:127?}]])
end
local x={}
if https then
table.insert(x,[[HTTPS]])
end
if ftp and not ftps then
table.insert(x,[[FTP, FTPS]])
end
if ftps then
table.insert(x,[[FTPS]])
end
box.html([[{?8836:916?}: ]],table.concat(x,", "))
end
function write_nas_access()
require("store")
--local shares = general.listquery("filelinks:settings/link/list(id,path,is_directory,userid,is_valid,expire,expire_date,access_count_limit,access_count)")
local shares = general.listquery("filelinks:settings/link/list(id,path,is_valid,is_directory,)")
box.out([[<table class="ports">]])
box.out([[<colgroup><col width="110px"><col width="520px"><col width="auto"></colgroup>]])
box.out([[<tr><th>{?8836:396?}</th><th>{?8836:784?}</th><th>&nbsp</th></tr>]])
local display_path=""
for i, user in ipairs(boxusers.list) do
user.frominternet = boxusers.frominternet(user)
local dirs=store.get_nas_user_dirs(user.UID)
table.sort(dirs, function(d1, d2) return (d1.path or "") < (d2.path or "") end)
box.out([[<tr><td>]]) box.html(user.name) box.out([[</td><td>]])
local display_tab={}
local any_access=false
for i, dir in ipairs(dirs) do
local display=""
display_path = (dir.path or ""):gsub("^/", "")
if display_path == "" then
display_path = [[{?8836:597?}]]
end
display=box.tohtml(display_path)..[[&nbsp;]]
local access = boxusers.get_access(user, dir, user.frominternet)
if access then
any_access=true
if access.read then
display=display..[[{?8836:157?}]]
if access.write then
display=display..[[/]]
end
end
if access.write then
display=display..[[{?8836:409?}]]
end
else
display=display..[[--/--]]
end
table.insert(display_tab,display)
end
if user.nas_rights~="0" and any_access then
box.out(table.concat(display_tab,[[,<br>]]))
else
box.out([[{?8836:5558?}]])
end
box.out([[</td><td>]]) box.out(get_link([[/system/boxuser_list.lua]],href.help_get([[hilfe_sicherheit_access]],[[anchor=access_user]]))) box.out([[</td></tr>]])
end
if #boxusers.list==0 then
box.out([[<tr><td colspan="3">{?8836:499?}</td></tr>]])
end
box.out([[</table>]])
local count_active=0
local count_files=0
local count_directories=0
for i,share_item in ipairs(shares) do
if share_item.is_valid=="1" then
count_active=count_active+1
if share_item.is_directory=="1" then
count_directories=count_directories+1
else
count_files=count_files+1
end
end
end
box.out([[<h4>&nbsp</h4>]])
box.out([[<table class="plain">]])
box.out([[<colgroup><col width="110px"><col width="520px"><col width="auto"></colgroup>]])
box.out([[<tr><td>]]) box.html([[{?8836:1779?}: ]]) box.out([[</td><td>]]) box.html(get_permission(count_active,count_directories,count_files)) box.out([[</td><td>]]) box.out(get_link([[/nas/index.lua]],href.help_get([[hilfe_sicherheit_access]],[[anchor=access_nas]]),nil,[[site=share]])) box.out([[</td></tr>]])
box.out([[<tr><td>]]) box.html([[{?8836:275?}: ]]) box.out([[</td><td>]]) box.out(get_nas_access()) box.out([[</td><td>]]) box.out(get_link([[/internet/remote_https.lua]],href.help_get([[hilfe_sicherheit_access]],[[anchor=access_remote]]))) box.out([[</td></tr>]])
box.out([[</table>]])
end
function get_provider()
local prov_name=isp.activename()
if prov_name=="" then
prov_name=isp.providername()
end
return prov_name
end
function write_new_devs()
local result="---"
box.out(result)
end
function write_new_guest_devs()
local result="---"
box.out(result)
end
function write_known_devs()
local result="---"
local tmp={}
for i,elem in ipairs(net_devices.g_list) do
if (elem.type=="wlan" and elem.guest=="0" and elem.wlan_show_in_monitor ~= "0") then
if config.GUI_IS_REPEATER then
if (elem.is_ap~="1") then
table.insert(tmp,net_devices.get_ssid(elem))
end
else
table.insert(tmp,net_devices.get_ssid(elem))
end
end
end
if #tmp>0 then
result=table.concat(tmp,"<br>")
end
box.out(result)
end
function write_known_guest_devs()
local result="---"
local tmp={}
for i,elem in ipairs(net_devices.g_list) do
if (elem.type=="wlan" and elem.guest=="1" and elem.wlan_show_in_monitor ~= "0") then
if config.GUI_IS_REPEATER then
if (elem.is_ap~="1") then
table.insert(tmp,net_devices.get_ssid(elem))
end
else
table.insert(tmp,net_devices.get_ssid(elem))
end
end
end
if #tmp>0 then
result=table.concat(tmp,"<br>")
end
box.out(result)
end
function get_split_dslifaces(dsliface)
local ifaces = {}
local ifaces_associative = {}
for iface in string.gmatch(dsliface, "%w+") do
if not ifaces_associative[iface] then
table.insert(ifaces, iface)
end
ifaces_associative[iface] = true
end
return ifaces
end
function get_name(dsliface)
if string.find(dsliface, "internet") then
return [[{?8836:224?}]]
elseif string.find(dsliface, "tv") then
return [[{?8836:428?}]]
elseif string.find(dsliface, "voip") then
return [[{?8836:719?}]]
elseif string.find(dsliface, "tr069") then
return [[{?8836:672?}]]
end
return dsliface
end
function get_name_dsliface(dsliface)
dsliface=dsliface or ""
local ifacenames = {}
local ifaces = get_split_dslifaces(dsliface)
for i,iface in pairs(ifaces) do
table.insert(ifacenames, get_name(iface))
end
return table.concat(ifacenames, " + ")
end
function get_vc_header(idx,dsliface)
return general.sprintf([[{?8836:658?}]],idx,get_name_dsliface(dsliface))
end
function write_other_vc(idx,dsliface)
box.out([[
<hr>
<div class="subtitle">
<h4>]]) box.html(get_vc_header(idx,dsliface)) box.out([[</h4>
</div>
<table class="struct">
<colgroup>
<col width="120px"><col width="auto">
</colgroup>
<tr>
<td colspan="2">
<div id="uiInetGeneral">
<div id="uiFBoxServices">
<div id="uiOpenPorts" class="formular">
<h4>]]) box.html([[{?8836:368?}]]) box.out([[</h4>
<div>]]) box.html([[{?8836:739?}]]) box.out([[:</div>
<div id="uiServices">
<div>]]) write_services(dsliface) box.out([[</div>
</div><!--uiServices-->
</div><!--uiOpenPorts-->
</div><!--uiFBoxServices-->
</div><!-- uiInetGeneral -->
</td>
</tr>
</table>
]])
end
function is_active_iface(iface)
for i,dsliface in ipairs(g_data.dsliface_names) do
if (dsliface.type=="3" and string.lower(dsliface.name)~="all" and is_equal_iface(iface, dsliface.name)) then
return true
end
end
return false
end
function is_equal_iface(ifacestr1, ifacestr2)
local ifaces1 = get_split_dslifaces(ifacestr1)
for i, iface1 in ipairs(ifaces1) do
if not string.find(ifacestr2, iface1) then
return false
end
end
return true
end
function is_known_iface(iface)
for i,known_dsliface in ipairs(g_data.list_of_known_vcs) do
if is_equal_iface(known_dsliface, iface) then
return true
end
end
return false
end
function write_other_vcs()
local count=2
for i=2,#g_data.list_of_known_vcs,1 do
local iface=g_data.list_of_known_vcs[i]
if is_active_iface(iface) then
write_other_vc(count,iface)
count=count+1
end
end
for i,dsliface in ipairs(g_data.dsliface_names) do
if not is_known_iface(string.lower(dsliface.name)) and dsliface.type=="3" and string.lower(dsliface.name)~="all" then
write_other_vc(count,string.lower(dsliface.name))
count=count+1
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.User {
margin-right:20px;
}
.UserRow {
margin-bottom:10px;
}
.UserHeader {
background-color:#f1f1f1;
padding:5px;
}
.log table {
width:100%;
background:none;
border:none;
}
.connection table {
width:100%;
background:none;
border:none;
overflow:hidden;
border-collapse:separate;
}
.connection td {
vertical-align:top;
white-space:pre;
overflow:hidden;
text-overflow: ellipsis;
-o-text-overflow: ellipsis;
}
.subtitle {
}
.info_block {
padding:10px;
}
.subtitle h4{
margin:0px;
}
table.plain,
table.struct_wlan,
table.struct {
width:100%;
background-color:transparent;
border:none;
table-layout:fixed;
}
table.struct h4 {
padding:0px;
margin:0px;
}
table.struct div {
margin:3px 0px;
}
table.ports td,
table.plain td,
table.struct_wlan td,
table.struct td {
vertical-align:top;
overflow:hidden;
text-overflow: ellipsis;
-o-text-overflow: ellipsis;
padding:3px;
}
table.struct_wlan td,
table.struct_wlan th{
border:3px solid #f8f8f0;
}
table.struct_wlan td.noBorderButRight,
table.struct_wlan td.noBorderButTopRight,
table.struct_wlan td.noBorderButTop,
table.struct_wlan td.noBorder {
border:none;
}
table.struct_wlan td.noBorderButTop {
border-top:3px solid #f8f8f0;
}
table.struct_wlan td.noBorderButTopRight {
border-top:3px solid #f8f8f0;
border-right:3px solid #f8f8f0;
}
table.struct_wlan td.noBorderButRight {
border-right:3px solid #f8f8f0;
}
table.ports {
width:100%;
background-color:#eeeeee;
border:none;
table-layout:fixed;
}
table.struct_wlan th {
vertical-align:top;
background-color:#d8d8d6;
color:#717171;
padding:3px;
}
table.struct_wlan tr td.gray {
background-color:#eeeeee;
}
table.struct_wlan tr td:nth-child(2){
padding-right:20px;
text-align:right;
}
table.struct_wlan tr td.gray {
padding:3px;
text-align :left;
}
table.ports th {
vertical-align:top;
background-color:#d8d8d6;
color:#717171;
padding:3px;
}
.msg_hint {
float:left;
width:333px;
}
.help {
background-image:url("/css/default/images/icon_help.png");
background-repeat: no-repeat;
background-position:center center;
text-decoration: none;
width:16px;
height:16px;
display:inline-block;
}
a.help:hover {
text-decoration: none;
}
table tr td.pwd {
vertical-align:middle;
}
.WlanOpen {
background-image:url("/css/default/images/icon_kennwort.gif");
background-repeat: no-repeat;
background-position:left center;
text-decoration: none;
padding-left:20px;
padding-top:2px;
display:inline-block;
}
table.ports td.exposed_host{
background-image:url("/css/default/images/icon_kennwort.gif");
background-repeat: no-repeat;
background-position:right top;
text-decoration: none;
/*vertical-align:middle;*/
}
#uiServices,
#uiPorts {
margin-bottom:20px;
}
</style>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/system/security.lua" name="mainform" id="uiMainform">
<div id="uiMain">
<div>{?8836:496?}</div>
<hr>
<div class="subtitle">
<h4>{?8836:347?}</h4>
</div>
<div class="formular" id="uiFritzOs">
<div><?lua write_fritz_os_update()?></div>
</div>
<hr>
<div class="subtitle">
<h4><?lua box.html(get_vc_header(1,"internet"))?></h4>
</div>
<div class="formular connection">
<div>
{?8836:870?}'<?lua box.html(get_provider() )?>'
</div>
<?lua write_usage("connection") ?>
</div>
<table class="struct">
<colgroup>
<col width="120px"><col width="auto">
</colgroup>
<tr>
<td colspan="2">
<div id="uiInetGeneral">
<div id="uiFBoxServices">
<div id="uiOpenPorts" class="formular">
<h4>{?8836:568?}</h4>
<div>{?8836:982?}:</div>
<div id="uiServices">
<div><?lua write_services("internet")?></div>
</div><!--uiServices-->
<div id="uiPorts">
<h4>{?8836:566?}</h4>
<div>{?8836:925?}:</div>
<div><?lua write_ports("internet")?></div>
</div><!--uiPorts-->
<div id="uiFilter">
<h4>{?8836:718?}</h4>
<div>{?8836:479?}:</div>
<div><?lua write_filter()?></div>
</div><!--uiFilter-->
</div><!--uiOpenPorts-->
</div><!--uiFBoxServices-->
</div><!-- uiInetGeneral -->
</td>
</tr>
</table>
<?lua
write_other_vcs()
?>
<hr>
<table class="struct">
<tr id="uiWlanRow">
<td>
<div class="subtitle">
<h4>{?8836:211?}</h4>
</div>
</td>
<td>
</td>
</tr><!--uiWlanRow-->
<tr id="uiWlanRowTab">
<td colspan="2">
<div class="formular">
<table class="struct_wlan">
<colgroup>
<col width="105">
<col width="70">
<col width="280">
<col width="280">
</colgroup>
<tr>
<th colspan="2">{?8836:277?}</th><th>{?8836:142?}</th><th>{?8836:319?}</th>
</tr>
<?lua
if config.WLAN.is_double_wlan then
box.out([[
<tr>
<td class="gray noBorderButTop">]]) box.html([[{?8836:929?}]]) box.out([[</td><td class="gray noBorderButTopRight">2,4 GHz</td><td class="gray noBorderButTopRight">]]) write_wlan_active_24() box.out([[</td><td class="gray noBorderButTopRight">]]) write_wlan_guest_active("24") box.out([[</td>
</tr>
<tr>
<td class="gray noBorder"></td><td class="gray noBorderButRight">]]) box.html([[{?8836:954?}]]) box.out([[</td><td class="gray noBorderButRight">]]) write_wlan_ssid_24() box.out([[</td><td class="gray noBorderButRight">]]) write_wlan_ssid_guest() box.out([[</td>
</tr>
<tr>
<td class="gray noBorderButTop">]]) box.html([[{?8836:6021?}]]) box.out([[</td><td class="gray noBorderButTopRight">5 GHz</td><td class="gray noBorderButTopRight">]]) write_wlan_active_5() box.out([[</td><td class="gray noBorderButTopRight">]]) write_wlan_guest_active("5") box.out([[</td>
</tr>
<tr>
<td class="gray noBorder"></td><td class="gray noBorderButRight">]]) box.html([[{?8836:862?}]]) box.out([[</td><td class="gray noBorderButRight">]]) write_wlan_ssid_5() box.out([[</td><td class="gray noBorderButRight">]]) write_wlan_ssid_guest() box.out([[</td>
</tr>
]])
else
box.out([[
<tr>
<td class="gray">]]) box.html([[{?8836:129?}]]) box.out([[</td><td class="gray"></td><td class="gray">]]) write_wlan_active_24() box.out([[</td><td class="gray">]]) write_wlan_guest_active("24") box.out([[</td>
</tr>
<tr>
<td class="gray"></td><td class="gray">]]) box.html([[{?8836:595?}]]) box.out([[</td><td class="gray">]]) write_wlan_ssid_24() box.out([[</td><td class="gray">]]) write_wlan_ssid_guest() box.out([[</td>
</tr>
]])
end
?>
<tr>
<td class="gray" colspan="2">{?8836:382?}</td><td class="gray"><?lua write_active_wlan_devices()?></td><td class="gray"><?lua write_active_wlan_guest_devices()?></td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:722?}</td><td class="gray"><?lua write_wlan_enc()?></td><td class="gray"><?lua write_wlan_guest_enc()?></td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:912?}</td><td class="gray"><?lua write_wps_mode() write_only_helpicon([[/wlan/wps.lua]],[[hilfe_sicherheit_wlan]],[[anchor=wlan_wps]])?></td><td class="gray">---</td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:774?}</td><td class="gray"><?lua write_stick_and_surf() write_only_helpicon([[/wlan/encrypt.lua]],[[hilfe_sicherheit_wlan]])?></td><td class="gray">---</td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:709?}</td><td class="gray"><?lua write_isolation() write_only_helpicon([[/wlan/encrypt.lua]],[[hilfe_sicherheit_wlan]])?></td><td class="gray">---</td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:498?}</td><td class="gray"><?lua write_known_devs() write_only_helpicon([[/wlan/wlan_settings.lua]],[[hilfe_sicherheit_wlan]],[[anchor=wlan_devices]])?></td><td class="gray"><?lua write_known_guest_devs() ?></td>
</tr>
<tr>
<td class="gray" colspan="2">{?8836:2850?}</td><td class="gray"><?lua write_macfilter() write_only_helpicon([[/wlan/encrypt.lua]],[[hilfe_sicherheit_wlan]])?></td><td class="gray">---</td>
</tr>
</table>
</div>
</td>
</tr><!--uiWlanRowTab-->
</table>
<?lua
if not menu.check_page("fon") then
box.out([[<div style="display:none">]])
end
?>
<hr>
<table class="struct">
<tr id="uiTelefon">
<td>
<div class="subtitle">
<h4>{?8836:124?}</h4>
</div>
</td>
<td>
</td>
</tr><!--uiTelefon-->
<tr id="uiTelefonTabDect">
<td colspan="2">
<div id="uiDect" class="formular">
<h4>{?8836:535?}</h4>
<table class="ports">
<colgroup><col width="140px"><col width="495px"><col width="auto"></colgroup>
<tr><th>{?8836:4451?}</th><th>{?8836:41?}</th><th></th></tr>
<?lua write_dect()?>
</table>
</div><!--uiDect-->
</td>
</tr><!--uiTelefonTabDect-->
<tr id="uiTelefonTabRules">
<td colspan="2">
<div id="uiRuls" class="formular">
<h4>{?8836:933?}</h4>
<table class="ports">
<colgroup><col width="140px"><col width="495px"><col width="auto"></colgroup>
<tr><th>{?8836:812?}</th><th>{?8836:276?}</th><th></th></tr>
<?lua write_active_ruls()?>
</table>
</div><!--uiRuls-->
</td>
</tr><!--uiTelefonTabRules-->
<tr id="uiTelefonTabIpPhones">
<td colspan="2">
<div id="uiIpPhones" class="formular">
<h4>{?8836:890?}</h4>
<table class="ports">
<colgroup><col width="140px"><col width="495px"><col width="auto"></colgroup>
<tr><th>{?8836:107?}</th><th>{?8836:724?}</th><th></th></tr>
<?lua write_ip_phones()?>
</table>
</div><!--uiIpPhones-->
</td>
</tr><!--uiTelefonTabIpPhones-->
</table>
<?lua
if not menu.check_page("fon") then
box.out([[</div>]])
end
?>
<hr>
<table class="struct">
<tr id="uiFbUser">
<td>
<div class="subtitle">
<h4>{?8836:404?}</h4>
</div>
</td>
<td>
</td>
</tr><!--uiFbUser-->
<tr><!--uiFbUserTab-->
<td colspan="2">
<div class="formular"><?lua write_user_rights() ?></div>
</td>
</tr><!--uiFbUserTab-->
</table>
<hr>
<table class="struct">
<tr>
<td>
<div class="subtitle">
<h4>{?8836:90?}</h4>
</div>
</td>
</tr>
<tr id="uiPwd">
<td class="pwd">
<div class="formular">
<?lua write_pwd_warning()?>
<div><?lua write_pwd()?></div>
</div>
</td>
</tr><!--uiPwd-->
</table>
<hr>
<table class="struct">
<tr id="uiNas">
<td>
<div class="subtitle">
<h4>{?8836:342?}</h4>
</div>
</td>
<td>
</td>
</tr><!--uiNas-->
<tr><!--uiNasTab-->
<td colspan="2">
<div class="formular"><?lua write_nas_access() ?></div>
</td>
</tr><!--uiNasTab-->
</table>
</div><!--uiMain-->
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="cancel">{?txtRefresh?}</button>
<button type="button" name="print" onclick="uiDoShowPrintView()">{?8836:533?}</button>
</div>
</form>
<script type="text/javascript">
function uiDoShowPrintView() {
var url = "<?lua href.write('/system/security.lua','stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=815,height=600,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
</script>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
