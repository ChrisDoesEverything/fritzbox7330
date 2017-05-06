<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_client_details.html"
dofile("../templates/global_lua.lua")
require("net_devices")
require("http")
require("html")
require("general")
require("cmtable")
require("newval")
require("js")
if config.KIDS then
require("filter")
end
g_back_to_page = http.get_back_to_page( "/net/network_user_devices.lua" )
if (box.glob.script=="/net/edit_plc.lua") then
g_back_to_page = "/net/edit_plc.lua"
box.get.dev = net_devices.find_own_plc()
g_page_help = "hilfe_powerline_einstellungen.html"
end
if box.post.xhr and box.post.plc_firmwareupdate then
local err, msg, result
local webvar = "plc:settings/"..box.post.plc_firmwareupdate.."/firmwareupdate"
if box.post.update_start == "start" then
local saveset = {}
cmtable.add_var(saveset, webvar, "1")
err, msg = box.set_config(saveset)
end
result = box.query(webvar)
box.out(js.table({check_update_aktiv = result, err=err or -1, msg=msg}))
box.end_page()
end
g_last_action=""
if box.get.last_action then
g_last_action = box.get.last_action
elseif box.post.last_action then
g_last_action = box.post.last_action
end
g_menu_active_page = g_back_to_page
if box.get.dev then
dev_node = box.get.dev
elseif box.post.dev then
dev_node = box.post.dev
end
g_html_head = ""
g_page_head = ""
g_page_end = ""
g_html_end = ""
g_no_dev_node = false
if (dev_node==nil or dev_node=="") then
g_no_dev_node = true
g_html_head = "templates/html_head.html"
g_page_head = "templates/page_head.html"
g_page_end = "templates/page_end.html"
g_html_end = "templates/html_end.html"
end
?>
<?include g_html_head ?>
<?include g_page_head ?>
<?lua
if (g_no_dev_node) then
box.out([[
<form name="main_form" method="POST" action="">
<p>
{?1000:688?}
</p>
</form>
]])
end
?>
<?include g_page_end ?>
<?include g_html_end ?>
<?lua
if (g_no_dev_node) then
box.end_page()
end
g_idx_dev, g_dev = net_devices.find_dev_by_uid(net_devices.g_list, dev_node)
if not(g_dev) then
g_idx_dev, g_dev = net_devices.find_dev_by_node(net_devices.g_list, dev_node)
if not(g_dev) then
g_idx_dev, g_dev = net_devices.find_dev_by_id(net_devices.g_list, dev_node)
if not(g_dev) then
g_idx_dev, g_dev = net_devices.find_dev_by_name(net_devices.g_list, dev_node)
if not(g_dev) then
http.redirect(href.get(g_back_to_page))
end
end
end
end
function get_write_status_waitimg(text,state)
local image="wait.gif"
if state=="0" then
image="finished_ok_green.gif"
elseif state=="1" then
image="finished_error.gif"
end
return
[[
<div id="uiWriteWait">
<p>]]..text..[[</p>
<p class="waitimg"><img src="/css/default/images/]]..image..[["></p>
</div>
]]
end
if box.get.ajax and box.get.ajax == "writeStatus" then
box.out(js.table({writeStatus = g_dev.writeStatus}))
box.end_page()
end
if not g_dev.ConnectedDevices then
g_dev.ConnectedDevices={}
end
function dev_is_plc()
return g_dev.type~=nil and g_dev.type=="plc"
end
function write_coupling(direction)
if net_devices.is_mimo(g_dev) then
box.out([[, ]])
if direction=="tx" then
box.html(net_devices.get_coupling_txt(g_dev.couplingTX))
else
box.html(net_devices.get_coupling_txt(g_dev.couplingRX))
end
end
end
function dev_is_plc_bridge()
return box.query("wlan:settings/bridge_mode")== "bridge-plc"
end
if (dev_is_plc()) then
if g_dev.writeStatus ~= "" then
if box.post.plc_desc and box.post.plc_desc ~= "" and g_dev.name~=box.post.plc_desc then
g_dev.name = box.post.plc_desc
elseif box.get.plc_desc and box.get.plc_desc ~= "" and g_dev.name~=box.get.plc_desc then
g_dev.name = box.get.plc_desc
end
end
end
function valprog()
if (dev_is_plc()) then
newval.msg.plc_error_txt = {
[newval.ret.outofrange] = [[{?1000:1789?}]]
}
if not newval.value_equal("plc_desc", g_dev.name) then
if not newval.value_empty("plc_desc") then
newval.char_range_regex("plc_desc", "plcname", "plc_error_txt")
end
end
else
newval.msg.dev_name_error_txt = {
[newval.ret.outofrange] = [[{?1000:932?}]]
}
if not newval.value_equal("dev_name", g_dev.name) then
if not newval.value_empty("dev_name") then
newval.char_range_regex("dev_name", "pcname", "dev_name_error_txt")
end
end
end
end
if next(box.post) and box.post.btn_tonemaps then
local param = {}
if g_dev.mac~=nil and g_dev.mac~="" then
table.insert(param, http.url_param('dev',dev_node))
table.insert(param, http.url_param('back_to_page','/net/edit_device.lua'))
table.insert(param, http.url_param('remote_mac', g_dev.mac))
table.insert(param, http.url_param('remote_name', g_dev.name))
end
http.redirect(href.get("/net/plc_tonemaps.lua", unpack(param)))
end
function set_config(ctlmgr_save, param, redirect)
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
if (redirect) then
http.redirect(href.get(g_back_to_page, unpack(param)))
end
else
local criterr = general.create_error_div(err,msg,[[{?1000:553?}]])
box.out(criterr)
end
end
if next(box.post) and box.post.btn_wake then
local ctlmgr_save={}
if g_dev.mac~=nil and g_dev.mac~="" then
cmtable.add_var(ctlmgr_save, "wakeup:settings/mac" , g_dev.mac)
end
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
http.redirect(href.get(g_back_to_page))
else
local criterr = general.create_error_div(err,msg,[[{?1000:802?}]])
box.out(criterr)
end
end
if next(box.post) and box.post.btn_chancel then
http.redirect(href.get(g_back_to_page))
end
if box.post.validate == "btn_save" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if next(box.post) and box.post.btn_save then
if newval.validate(valprog)==newval.ret.ok then
local ctlmgr_save={}
local param = {}
if dev_is_plc() then
if config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE and box.glob.script == "/net/edit_plc.lua" then
if box.post.plc_active then
cmtable.add_var(ctlmgr_save, "plc:settings/"..g_dev.id.."/status" , "ACTIVE")
g_dev.status="ACTIVE"
else
cmtable.add_var(ctlmgr_save, "plc:settings/"..g_dev.id.."/status" , "INACTIVE")
g_dev.status="INACTIVE"
end
end
if box.post.plc_desc and g_dev.name~=box.post.plc_desc then
table.insert(param, http.url_param('plc_desc', box.post.plc_desc))
cmtable.add_var(ctlmgr_save, "plc:settings/"..g_dev.id.."/usr" , box.post.plc_desc)
g_dev.name=box.post.plc_desc
end
if (g_dev.canSetLEDs) then
if (box.post.led) then
cmtable.add_var(ctlmgr_save,"plc:settings/"..g_dev.id.."/led", "ON")
g_dev.led="ON"
else
cmtable.add_var(ctlmgr_save,"plc:settings/"..g_dev.id.."/led", "OFF")
g_dev.led="OFF"
end
end
if (g_dev.canSetGreenMode) then
if (box.post.greenmode) then
cmtable.add_var(ctlmgr_save,"plc:settings/"..g_dev.id.."/green", "ON")
g_dev.green = "ON"
else
cmtable.add_var(ctlmgr_save,"plc:settings/"..g_dev.id.."/green", "OFF")
g_dev.green = "OFF"
end
end
else
if g_dev.UID and g_dev.UID ~= "" then
if g_dev.type ~= "user" then
cmtable.save_checkbox(ctlmgr_save, "landevice:settings/landevice["..g_dev.UID.."]/auto_wakeup" , "auto_wakeup")
cmtable.save_checkbox(ctlmgr_save, "landevice:settings/landevice["..g_dev.UID.."]/static_dhcp" , "static_dhcp")
if box.post.dev_name and g_dev.name~=box.post.dev_name then
cmtable.add_var(ctlmgr_save, "landevice:settings/landevice["..g_dev.UID.."]/name" , box.post.dev_name)
end
end
end
if config.KIDS then
if box.post.kisi_profile then
g_dev.kisiuser = net_devices.get_kisiuser(g_dev)
if g_dev.kisiuser then
filter.save_profile(ctlmgr_save, g_dev.kisiuser, box.post.kisi_profile)
end
end
end
end
g_last_action="btn_save"
table.insert(param, http.url_param('last_action', 'btn_save'))
set_config(ctlmgr_save, param,box.glob.script ~= "/net/edit_plc.lua")
end
elseif next(box.post) and box.post.add_adapter then
if (config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE) or g_dev.isLocal then
g_last_action="add_adapter"
local ctlmgr_save={}
local plc_pw = box.post.plc_pw0.."-"..box.post.plc_pw1.."-"..box.post.plc_pw2.."-"..box.post.plc_pw3
cmtable.add_var(ctlmgr_save, "plc:settings/"..g_dev.id.."/addAdapter", plc_pw)
local param = {}
table.insert(param, http.url_param('last_action', 'add_adapter'))
if (not g_dev.is_internal) then
set_config(ctlmgr_save, param,false)
else
set_config(ctlmgr_save, param,true)
end
g_dev.writeStatus=box.query("plc:settings/"..g_dev.id.."/writeStatus")
end
elseif next(box.post) and box.post.reset_adapter then
if (config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE) or g_dev.isLocal then
g_last_action="reset_adapter"
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "plc:settings/"..g_dev.id.."/factorydefault", "1")
local param = {}
table.insert(param, http.url_param('last_action', 'reset_adapter'))
if (not g_dev.is_internal) then
set_config(ctlmgr_save, param,false)
else
set_config(ctlmgr_save, param,true)
end
g_dev.writeStatus=box.query("plc:settings/"..g_dev.id.."/writeStatus")
end
end
g_dev.opmode = box.query("box:settings/opmode")
g_dev.forward_rules = general.listquery("forwardrules:settings/rule/list(activated,fwip,description,protocol,port,endport,fwport)")
g_dev.ipv6forwardrules = general.listquery("ipv6firewall:settings/rule/list(enabled,neighbour_name,ifaceid,exposed_host)")
g_dev.igd_forward_rules = general.listquery("igdforwardrules:settings/rule/list(fwip,protocol,port,fwport)")
function check_dev_name()
return g_dev.name~=nil and g_dev.name~=""
end
function check_dev_ip()
return g_dev.ip ~= nil and g_dev.ip ~= "" and g_dev.ip ~= "er" and g_dev.ip ~= "no-emu" and g_dev.ip ~= "-" and g_dev.ip ~= "0.0.0.0"
end
function dev_is_user_check()
return g_dev.type~=nil and g_dev.type=="user"
end
function check_dev_mac()
return g_dev.mac~=nil and g_dev.mac~=""
end
function check_dev_parentname()
return g_dev.parentname~=nil and g_dev.parentname~=""
end
function check_dev_ethernet()
return g_dev.ethernet_port~=nil and g_dev.ethernet_port~="" and g_dev.ethernet_port~="0"
end
function check_dev_vendor()
return g_dev.vendorname~=nil and g_dev.vendorname~=""
end
function check_dev_dhcp()
return g_dev.dhcp~=nil and g_dev.dhcp~="" and g_dev.dhcp=="1"
end
function dev_static_dhcp_activ()
return g_dev.static_dhcp~=nil and g_dev.static_dhcp == "1"
end
function hide_dev_dhcp()
return not(check_dev_dhcp() and check_dev_mac() and check_dev_ip())
end
function show_wake_on_lan_check()
return g_dev.type~=nil and g_dev.type~="user" and g_dev.type~="wlan" and check_dev_mac()
end
function page_editable()
return check_dev_ip() or g_dev.type == "user" or g_dev.type=="plc"
end
function show_wlan_check()
return (not g_dev.parentname or g_dev.parentname == "") and g_dev.type~=nil and g_dev.type~="" and (g_dev.type=="wlan")
end
function dev_is_auto_wakeup()
return g_dev.auto_wakeup=="1"
end
function show_wlan_table()
local str = [[]]
local add_row = function(text, value, tooltip)
if value == "" then
value = "&nbsp;"
else
box.tohtml(value)
end
if not tooltip then
tooltip = ""
else
tooltip = [[ title="]]..tostring(tooltip)..[["]]
end
str = str..[[
<div class="formular">
<span class="ShowPathLabel">]]..box.tohtml(text)..[[</span>
<span class="ShowPathSmall"]]..tooltip..[[>]]..value..[[</span>
</div>
]]
end
if type(g_dev.wlan_idx)=='number' and g_dev.state=="5" then
add_row([[{?1000:6?}]], tostring((tonumber(g_dev.rssi) or 0) - 100)..[[ {?1000:99?}]], general.sprintf([[{?1000:874?}]], tostring(g_dev.quality)))
local turbo_txt = ""
if g_dev.is_turbo == "1" then
turbo_txt = [[ (g++)]]
end
add_row([[{?1000:860?}]], tostring(g_dev.speed).." / "..tostring(g_dev.speed_rx)..[[ {?1000:4705?}]]..turbo_txt)
add_row([[{?1000:634?}]], [[WLAN-]]..tostring(net_devices.get_wlan_mode_str(g_dev.mode)))
local band_txt = "2,4 GHz"
if net_devices.is_5ghz_mode_bit(g_dev.mode) then
band_txt = "5 GHz"
end
add_row([[{?1000:575?}]], tostring(band_txt))
add_row([[{?1000:782?}]], g_dev.channel_width..[[ {?1000:786?}]])
local cipher = tonumber(g_dev.cipher)
local cipher_txt = {[[{?1000:137?}]],[[{?1000:401?}]],[[{?1000:608?}]],[[{?1000:313?}]],[[-]]}
if type(cipher)~="number" then
cipher = 4
end
add_row([[{?1000:7058?}]], cipher_txt[cipher+1])
local streams_table = string.split(g_dev.streams, ",")
add_row([[{?1000:974?}]], tostring(streams_table[1].." x "..streams_table[2]))
local signal_properties = {}
local flags = tonumber(g_dev.flags)
require ("bit")
if (bit.isset(flags,4)) then
table.insert(signal_properties,"STBC")
end
if (bit.isset(flags,5)) then
table.insert(signal_properties,"TxBF")
end
if (bit.isset(flags,6)) then
table.insert(signal_properties,"LDPC")
end
if (bit.isset(flags,10)) then
table.insert(signal_properties,"PMF")
end
add_row([[{?1000:19?}]], table.concat(signal_properties,", "))
local qos_txt = ""
if g_dev.wmm_active=="1" then
qos_txt = [[{?1000:61?}]]
end
add_row([[{?1000:64?}]], qos_txt)
local is_repeater_txt = box.tohtml([[{?1000:437?}]])
if g_dev.is_repeater == "1" then
is_repeater_txt = box.tohtml([[{?1000:684?}]])
end
local repeater_txt = [[{?1000:531?}]]
if config.WLAN_WDS2 then
repeater_txt = [[{?1000:9458?}]]
end
add_row(repeater_txt, is_repeater_txt)
else
add_row([[{?txtWlan?}]], [[{?1000:157?}]])
end
return str
end
function box_is_router()
return g_dev.opmode~='opmode_modem' and opmode~='opmode_eth_ipclient'
end
function get_names_of_connected_devs( t_bridged_devices)
local l_t_lan_devices = general.listquery( [[landevice:settings/landevice/list(name,ip,ipv6addrs,mac)]])
local l_sz_ret = ""
local l_b_not_found = true
local l_fritzbox_maca = box.query( "env:status/maca" )
local l_fritzbox_name = box.query( "box:settings/hostname" )
for i=1, #t_bridged_devices do
local sz_mac = string.lower(t_bridged_devices[i])
if ( l_sz_ret ~= "") then
l_sz_ret = l_sz_ret..[[<br>]]
end
l_b_not_found = true
for j=1, #l_t_lan_devices do
if ( string.lower(l_t_lan_devices[j].mac) == sz_mac ) then
l_b_not_found = false
l_sz_ret = l_sz_ret..box.tohtml(l_t_lan_devices[j].name)
break;
end
end
if ( l_b_not_found == true and not (l_fritzbox_name == "") and sz_mac == string.lower(l_fritzbox_maca)) then
l_b_not_found = false
l_sz_ret = l_sz_ret..box.tohtml(l_fritzbox_name)
end
if ( l_b_not_found == true) then
l_b_not_found = false
l_sz_ret = l_sz_ret..box.tohtml([[{?1000:678?}]]..t_bridged_devices[i]..[[ {?1000:778?}]])
end
end
if ( #t_bridged_devices == 0) then
l_sz_ret = box.tohtml([[{?1000:175?}]])
end
return l_sz_ret
end
function get_dev_info()
local dev_info = ""
if check_dev_mac() then
dev_info = dev_info..tostring(g_dev.mac)
end
if check_dev_vendor() then
if dev_info ~= "" then
dev_info = dev_info..", "
end
dev_info = dev_info..tostring(g_dev.vendorname)
end
return dev_info
end
if config.KIDS then
g_dev.kisiuser = net_devices.get_kisiuser(g_dev)
end
function option_avail_for_device(page)
if (page=="/internet/kids_userlist.lua") then
return g_dev.kisiuser ~= nil
or (g_dev.active == "1" and g_dev.parental_control_abuse == "1")
end
if (page=="/internet/port_fw.lua") then
return g_dev.exposedhost or g_dev.portfw or g_dev.igdportfw
end
return true
end
function option_avail(page)
require"menu"
if ( menu.exists_page(page)) then
if (menu.show_page(page)) then
return option_avail_for_device(page)
end
end
return false
end
function show_kisi_content()
if g_dev.active == "1" and g_dev.parental_control_abuse == "1" then
html.p{class="subtitle",
[[{?1000:890?}]]
}.write()
html.p{
[[{?1000:560?}]]
}.write()
html.p{
[[{?1000:515?}]]
}.write()
return
end
if not config.KIDS or not g_dev.kisiuser or g_dev.kisiuser.guest then
return
end
box.out([[<a href=']]..href.get("/internet/kids_userlist.lua")..[['>]])
box.html([[{?1000:873?}]])
box.out([[</a>]])
box.out([[<table id="kisi_table" class="zebra"><tr><th class="net_edit_first_row">]])
if not g_dev.kisiuser.autouser then
box.html([[{?1000:835?}]])
end
box.out([[</th>]])
box.out([[<th class="net_edit_notfirst_row">]])
if not g_dev.kisiuser.autouser then
box.html([[{?1000:87?}]])
end
box.out([[</th>]])
box.out([[<th class="net_edit_notfirst_row">]])
box.html([[{?1000:68?}]])
box.out([[</th></tr>]])
if g_dev.kisiuser then
local profile_select = filter.profile_select(g_dev.kisiuser, {name="kisi_profile"})
html.tr{
html.td{filter.get_allowed(g_dev.kisiuser)},
html.td{class="bar", filter.get_online_time(g_dev.kisiuser)},
html.td{profile_select or filter.get_profile_display(g_dev.kisiuser)}
}.write()
end
box.out([[</table>]])
end
function port_range(pa,pe,pb)
if pe=='' or pa==pe then
return pb
end
a = tonumber(pa)
e = tonumber(pe)
b = tonumber(pb)
if type(a)~="number" or type(e)~="number" or type(b)~="number" then
return ''
end
return tostring(b).."-"..tostring(b+(e-a))
end
function dev_is_exposedhost()
return g_dev.exposedhost~=nil and g_dev.exposedhost
end
function show_shared_ports()
local any = false
local str = [[<a href=']]..href.get("/internet/port_fw.lua")..[['>]]..box.tohtml([[{?g_txt_Portfreigaben?}]])..[[</a>]]
str = str..[[<table id="shared_ports_table" class="zebra"><tr>]]
str = str..[[<th class="net_edit_first_row">]]..box.tohtml([[{?1000:703?}]])..[[</th>]]
str = str..[[<th class="net_edit_notfirst_row">]]..box.tohtml([[{?1000:674?}]])..[[</th>]]
str = str..[[<th class="net_edit_notfirst_row">]]..box.tohtml([[{?1000:941?}]])..[[</th>]]
str = str..[[<th>]]..box.tohtml([[{?1000:56?}]])..[[</th></tr>]]
if dev_is_exposedhost() then
str = str..[[<tr><td colspan="4" class="hint">]]..box.tohtml([[{?1000:583?}]])..[[</td></tr>]]
else
for i,v in ipairs(g_dev.forward_rules) do
if v.activated=="1" and g_dev.ip==v.fwip then
str = str..[[<tr><td>]]..box.tohtml(v.description)..[[</td><td>]]..box.tohtml(v.protocol)..[[</td><td>]]..box.tohtml(port_range(v.port,v.endport,v.port))..[[</td><td>]]..box.tohtml(port_range(v.port,v.endport,v.fwport))..[[</td></tr>]]
any = true
end
end
for i,v in ipairs(g_dev.igd_forward_rules) do
if g_dev.ip==v.fwip then
str = str..[[<tr><td>UPnP</td><td>]]..v.protocol..[[</td><td>]]..v.port..[[</td><td>]]..v.port..[[</td></tr>]]
any = true
end
end
if not any then
str = str..[[<tr><td colspan="4" class="hint">]]..box.tohtml([[{?1000:589?}]])..[[</td></tr>]]
end
end
return str..[[</table>]]
end
function show_shared_ports_ipv6()
local any = false
local str = [[<a href=']]..href.get("/internet/port_fw.lua")..[['>]]..box.tohtml([[{?1000:292?}]])..[[</a>]]
str = str..[[<table id="shared_ports_table_ipv6" class="zebra"><tr>]]
str = str..[[<th class="net_edit_first_row">]]..box.tohtml([[{?1000:9571?}]])..[[</th>]]
str = str..[[<th class="net_edit_notfirst_row">]]..box.tohtml([[{?1000:627?}]])..[[</th>]]
str = str..[[<th class="net_edit_notfirst_row">]]..box.tohtml([[{?1000:229?}]])..[[</th>]]
str = str..[[<th>]]..box.tohtml([[{?1000:427?}]])..[[</th></tr>]]
local rule = g_dev.ipv6forwardrules[g_dev.rule_id]
if rule then
if rule.exposed_host == "1" then
str = str..[[<tr><td colspan="4" class="hint">]]..box.tohtml([[{?1000:113?}]])..[[</td></tr>]]
any = true
elseif rule.enabled=="1" and g_dev.ipv6_ifid==rule.ifaceid then
local ipv6rules = general.listquery("ipv6firewall:settings/rule"..tostring(g_dev.rule_id-1).."/rules/entry/list(rule)")
for i,v in ipairs(ipv6rules) do
local rule_pos, port_from, port_to = net_devices.get_rule_part(v.rule)
str = str..[[<tr><td>]]..box.tohtml(rule.neighbour_name)..[[</td><td>]]..box.tohtml(rule_pos)..[[</td><td>]]..box.tohtml(port_range(port_from,port_to,port_from))..[[</td><td>]]..box.tohtml(port_range(port_from,port_to,port_from))..[[</td></tr>]]
any = true
end
end
end
if not any then
str = str..[[<tr><td colspan="4" class="hint">]]..box.tohtml([[{?1000:839?}]])..[[</td></tr>]]
end
return str..[[</table>]]
end
function has_shared_ports_ipv6()
local rule = g_dev.ipv6forwardrules[g_dev.rule_id]
if rule then
return option_avail("/internet/ipv6_fw.lua")
end
return false
end
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
ipv6_internet_activ = box.query("ipv6:settings/state") == "5"
else
ipv6_internet_activ = false
end
function get_ipv6_adresses()
local str = ""
local cnt = 0
if ipv6_internet_activ and not dev_is_user_check() and not dev_is_plc() then
local addrs = general.listquery("landevice:settings/"..g_dev._node.."/ipv6addrs0/entry/list(ipv6addr)")
for i, addr in ipairs(addrs) do
if i > 1 then
str = str..[[<span class="ShowPathSmall form_input_note">]]..box.tohtml(addr.ipv6addr)..[[</span>]]
else
str = str..[[<span class="ShowPathSmall">]]..box.tohtml(addr.ipv6addr)..[[</span>]]
end
cnt = cnt + 1
end
end
return str, cnt
end
function hide_options()
local hide=true
if not(not option_avail("/internet/port_fw.lua") or dev_is_user_check()) then hide=false end
if not(not has_shared_ports_ipv6() or dev_is_user_check()) then hide=false end
if option_avail("/internet/kids_userlist.lua") then hide=false end
if show_wlan_check() then hide=false end
return hide
end
g_local_update = false
if g_dev.id then
g_local_update = g_dev.isLocal
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/kids.css"/>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<style type="text/css">
.vert_top {vertical-align: top; margin-top: 8px;}
#uiViewDeviceName.ShowPathSmall{ width: 305px; }
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
href.default_submit('btn_save')
if config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE and dev_is_plc() and box.glob.script == "/net/edit_plc.lua" then
local checked = ""
if g_dev.status ~= "INACTIVE" then
checked = " checked"
end
box.out([[
<p>{?1000:618?}</p>
<div class="formular">
<input type="checkbox" name="plc_active" id="uiViewPlcActive"]],checked,[[ onchange="onChangePlcActive(this);">
<label for="uiViewPlcActive">{?1000:4997?}</label>
</div>
<div class="formular" id="uiPlcSpecs">
]])
else
box.out([[<p>{?1000:832?}</p><hr>]])
end
?>
<div class="formular" <?lua if not dev_is_plc() then box.out("style='display:none;'") end ?>>
<label for="uiViewPlcDesc">{?1000:724?}</label>
<?lua
if g_dev.active =="1" then
box.out([[<input type="text" name="plc_desc" maxlength="64" size="42" id="uiViewPlcDesc" value="]]..box.tohtml(g_dev.name)..[[">]])
else
box.out([[<span class="ShowPathSmall">]]..box.tohtml(g_dev.name)..[[</span>]])
end
?>
</div>
<div class="formular" id="uiDetailsName" <?lua if dev_is_plc() or not(check_dev_name()) or dev_is_user_check() then box.out("style='display:none;'") end ?>>
<label for="uiViewDeviceName" class="ShowPathLabel">{?1000:338?}</label>
<input class="ShowPathSmall" type="text" name="dev_name" maxlength="128" id="uiViewDeviceName" value="<?lua box.html(g_dev.name) ?>" <?lua if not(page_editable()) then box.out("style='display:none;'") end ?>>
<span class="ShowPathSmall" <?lua if page_editable() then box.out("style='display:none;'") end ?>><?lua box.html(g_dev.name) ?></span>
<span <?lua if g_dev.manu_name~="1" then box.out("style='display:none;'") end ?>><button type="button" onclick="resetDevName()" id="uiBtnResetName" name="btn_reset_name">{?1000:900?}</button></span>
</div>
<div class="formular" id="uiDetailsUser" <?lua if not dev_is_user_check() or dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:408?}</span>
<span class="ShowPathSmall" id="uiDetailsUserContent"><?lua box.html(g_dev.name) ?></span>
</div>
<div class="formular" <?lua if not check_dev_ip() or dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:545?}</span>
<span class="ShowPathSmall"><?lua box.html(g_dev.ip) ?></span>
</div>
<div class="formular" id="uiDetailsStaticDhcp" <?lua if hide_dev_dhcp() or dev_is_plc() then box.out("style='display:none;'") end ?>>
<input type="checkbox" class="form_input_note" name="static_dhcp" id="uiViewStaticDhcp" <?lua if dev_static_dhcp_activ() then box.out("checked") end ?>>
<label for="uiViewStaticDhcp">{?1000:275?}</label>
</div>
<div class="formular" <?lua g_ipv6_txt,g_ipv6_cnt = get_ipv6_adresses() if g_ipv6_txt == "" or dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel"><?lua if g_ipv6_cnt==1 then box.html([[{?1000:481?}]]) else box.html([[{?1000:331?}]]) end ?></span>
<?lua box.out(g_ipv6_txt) ?>
</div>
<div class="formular" <?lua if g_dev.manufactor == "" or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:704?}</span>
<span class="ShowPathSmall"><?lua box.html(g_dev.manufactor or "") ?></span>
</div>
<div class="formular" <?lua if g_dev.model == "" or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:57?}</span>
<span class="ShowPathSmall"><?lua box.html(g_dev.model or "") ?></span>
</div>
<div class="formular" id="uiDetailsParent" <?lua if not(check_dev_parentname()) then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:671?}</span>
<span class="ShowPathSmall" id="uiDetailsParentContent" ><?lua box.html(g_dev.parentname) ?></span>
</div>
<div class="formular" id="uiDetailsEthernet" <?lua if not(check_dev_ethernet()) then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:145?}</span>
<span class="ShowPathSmall" id="uiDetailsEthernetContent" >LAN <?lua box.html(g_dev.ethernet_port) ?></span>
</div>
<div class="formular" <?lua if g_dev.firmwareVersion == "" or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:662?}</span>
<span class="ShowPathSmall"><?lua box.html(g_dev.firmwareVersion) ?></span>
</div>
<div class="formular" <?lua if g_dev.class == "UNKNOWN" or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:708?}</span>
<span class="ShowPathSmall"><?lua box.html(net_devices.convert_plc_speed(g_dev.class)) ?></span>
</div>
<div class="formular" <?lua if not dev_is_plc() or (not net_devices.is_mimo(g_dev)) then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:568?}</span>
<span class="ShowPathSmall"><?lua box.html(net_devices.convert_plc_mimo(g_dev.couplingClass)) ?></span>
</div>
<div class="formular" <?lua if g_dev.isDefaultNMK == "UNKNOWN" or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:895?}</span>
<span class="ShowPathSmall"><?lua if (g_dev.isDefaultNMK == "YES") then box.html([[{?1000:297?}]]) else box.html([[{?1000:250?}]]) end ?></span>
</div>
<div class="formular" <?lua if (#g_dev.ConnectedDevices == 0) or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel vert_top"><?lua if (#g_dev.ConnectedDevices == 1) then box.html([[{?1000:757?}]]) else box.html([[{?1000:784?}]]) end ?></span>
<span class="ShowPathSmall"><?lua box.out( get_names_of_connected_devs( g_dev.ConnectedDevices)) ?></span>
</div>
<div class="formular" id="uiDetailsMac" <?lua if not(general.is_expert() and (check_dev_mac() or check_dev_vendor())) then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:280?}</span>
<span class="ShowPathSmall" id="uiDetailsMacContent" ><?lua box.html(get_dev_info()) ?></span>
</div>
<?lua
if dev_is_plc() and ((config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE and box.glob.script == "/net/edit_plc.lua") or g_dev.isLocal) then
local status = ""
local result = box.query("plc:settings/"..g_dev.id.."/resultLastCmd")
if g_dev.writeStatus ~= "" and g_last_action == "add_adapter" then
status = get_write_status_waitimg([[{?1000:981?}]])
elseif g_last_action == "add_adapter" then
if (g_dev.is_internal) then
if result=="0" or result=="" then
status = get_write_status_waitimg([[{?1000:613?}]],"0")
else
status = get_write_status_waitimg([[{?1000:501?}]],"1")
end
else
if result=="0" or result=="" then
status = get_write_status_waitimg([[{?1000:339?}]],"0")
else
status = get_write_status_waitimg([[{?1000:639?}]],"1")
end
end
end
if (g_dev.is_internal) then
box.out([[
</div>
]])
end
box.out([[
<hr>
<h4>{?1000:717?}</h4>
<div class="formular">
<p>{?1000:617?}</p>
<label for="uiPlcPw_0">{?1000:889?}:</label>
<span id="uiViewAddPlc">
<span id="uiPlcPwBox">
<input type="text" size="4" maxlength="4" id="uiPlcPw0" name="plc_pw0"/> -
<input type="text" size="4" maxlength="4" id="uiPlcPw1" name="plc_pw1"/> -
<input type="text" size="4" maxlength="4" id="uiPlcPw2" name="plc_pw2"/> -
<input type="text" size="4" maxlength="4" id="uiPlcPw3" name="plc_pw3"/>
</span>
<button type="submit" name="add_adapter">{?1000:5?}</button>
</span>]], status, [[
<p><strong>{?txtHinweis?}</strong> {?1000:134?}</p>
</div>
]])
end
?>
<div id="uiFirmwareupdate" <?lua if not dev_is_plc() or g_dev.hasFirmwareupdate == "NEVER" then box.out("style='display:none;'") end ?>>
<hr>
<h4>{?1000:240?}</h4>
<div class="formular">
<p <?lua if (g_dev.hasFirmwareupdate == "YES") or (g_dev.hasFirmwareupdate == "YES_IF_LOCAL") then box.out([[style="display:none;"]]) end ?>>
{?1000:405?}
</p>
<div <?lua if not (g_dev.hasFirmwareupdate == "YES_IF_LOCAL" and not g_local_update) then box.out([[style="display:none;"]]) end ?>>
<p><?lua box.html(general.sprintf([[{?1000:416?}]],g_dev.firmwareupdateVersion)) ?></p>
<p>{?1000:77?}</p>
</div>
<div <?lua if g_dev.hasFirmwareupdate == "NO" or (g_dev.hasFirmwareupdate == "YES_IF_LOCAL" and not g_local_update) then box.out([[style="display:none;"]]) end ?>>
<p>
<?lua box.html(general.sprintf([[{?1000:414?}]], g_dev.firmwareupdateVersion))?>
</p>
<p>
{?1000:1468?}
</p>
<div class="btn_form">
<button type="button" id="uiStartPlcFirmwareupdate" onclick="startPlcFirmwareupdate();return false;"
<?lua if g_dev.firmwareupdate then box.out([[ disabled]]) end ?>>
<?lua
if g_dev.firmwareupdate then
box.html([[{?1000:845?}]])
else
box.html([[{?1000:818?}]])
end
?>
</button>
</div>
<p><strong>{?txtHinweis?}</strong></p>
<p>
{?1000:510?}
</p>
</div>
</div>
</div>
<div class="formular" id="uiUpdate" <?lua if not g_dev.firmwareupdate then box.out([[style="display:none;"]]) end ?> >
<p id="uiUpdateText">
{?1000:38?}
</p>
<p class="waitimg"><img id="uiUpdateImage" src="/css/default/images/wait.gif"></p>
<p id="uiUpdateInfo">
{?1000:461?}
</p>
</div>
<?lua
if dev_is_plc() and g_dev.writeStatus ~= "" and g_last_action == "btn_save" then
box.out(get_write_status_waitimg([[{?1000:202?}]]))
end
?>
<div <?lua if ((not tonumber(g_dev.phyRateRX) or tonumber(g_dev.phyRateRX) <= 0) and (not tonumber(g_dev.phyRateTX) or tonumber(g_dev.phyRateTX) <= 0)) or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<hr>
<h4>{?1000:959?}</h4>
<div class="formular">
<p>
{?1000:209?}
<?lua
if (net_devices.is_mimo(g_dev)) then
box.html([[{?1000:1234?}]])
end
?>
</p>
<div <?lua if not tonumber(g_dev.phyRateTX) or tonumber(g_dev.phyRateTX) <= 0 then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:450?}</span>
<span class="ShowPathSmall"><?lua box.html(net_devices.convert_plc_speed(g_dev.phyRateTX)) write_coupling("tx")?></span>
</div>
<div <?lua if not tonumber(g_dev.phyRateRX) or tonumber(g_dev.phyRateRX) <= 0 then box.out("style='display:none;'") end ?>>
<span class="ShowPathLabel">{?1000:180?}</span>
<span class="ShowPathSmall"><?lua box.html(net_devices.convert_plc_speed(g_dev.phyRateRX)) write_coupling("rx")?></span>
</div>
<div style="height:20px;">
<button type="submit" style="float:right;" name="btn_tonemaps">{?1000:771?}</button>
</div>
</div>
</div>
<div <?lua if not g_dev.canSetGreenMode or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<hr>
<h4>{?1000:644?}</h4>
<div class="formular">
<p>{?1000:167?}</p>
<input type="checkbox" id="uiViewGreen" name="greenmode" <?lua if g_dev.green=="ON" then box.out('checked') end?>>
<label for="uiViewGreen">{?1000:834?}</label>
</div>
</div>
<div <?lua if not g_dev.canSetLEDs or not dev_is_plc() then box.out("style='display:none;'") end ?>>
<hr>
<h4>{?1000:861?}</h4>
<div class="formular">
<p>{?1000:187?}</p>
<input type="checkbox" id="uiViewLed" name="led" <?lua if g_dev.led=="ON" then box.out('checked') end?>>
<label for="uiViewLed">{?1000:1448?}</label>
</div>
</div>
<?lua
if dev_is_plc() and ((config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE and box.glob.script == "/net/edit_plc.lua") or g_dev.isLocal) then
local status = ""
if g_dev.writeStatus ~= "" and g_last_action == "reset_adapter" then
if g_dev.is_internal then
status = get_write_status_waitimg([[{?1000:750?}]])
else
status = get_write_status_waitimg([[{?1000:880?}]])
end
end
if g_dev.writeStatus == "" and g_last_action == "reset_adapter" then
local result=box.query("plc:settings/"..g_dev.id.."/resultLastCmd")
local result2=box.query("plc:settings/"..g_dev.id.."/extResultLastCmd")
if g_dev.is_internal then
if result=="0" or result=="" then
status = get_write_status_waitimg([[{?1000:738?}]],"0")
else
status = get_write_status_waitimg([[{?1000:467?}]],"1")
end
else
if result=="0" or result=="" then
status = get_write_status_waitimg([[{?1000:540?}]],"0")
else
status = get_write_status_waitimg([[{?1000:9898?}]],"1")
end
end
end
box.out([[
<hr>
<h4>{?1000:139?}</h4>
<div class="formular">
<p>
{?1000:14?}
</p>
<p>
<button class="ShowBtnRight" type="submit" name="reset_adapter">{?1000:221?}</button>
</p>]], status, [[
</div>
]])
end
?>
<div <?lua if hide_options() then box.out('style="display:none;"') end ?>>
<hr>
<h4>{?1000:136?}</h4>
<div id="uiDetails_wlan" <?lua if not show_wlan_check() then box.out("style='display:none;'") end ?>>
<div class="formular">
<h4>{?1000:100?}</h4>
</div>
<?lua box.out(show_wlan_table())?>
<br>
</div>
<div class="formular" id="uiDetailsPortFw" <?lua if not option_avail("/internet/port_fw.lua") or dev_is_user_check() then box.out('style="display:none;"') end ?>>
<?lua box.out(show_shared_ports())?>
</div>
<div class="formular" id="uiDetailsPortFwIPv6" <?lua if not has_shared_ports_ipv6() or dev_is_user_check() then box.out('style="display:none;"') end ?>>
<?lua box.out(show_shared_ports_ipv6())?>
</div>
<div class="formular" id="uiDetailsKiSi" <?lua if not option_avail("/internet/kids_userlist.lua") then box.out('style="display:none;"') end ?>>
<?lua show_kisi_content() ?>
</div>
</div>
<div id="uiDetailsWake" <?lua if not show_wake_on_lan_check() or dev_is_plc() then box.out("style='display:none;'") end ?>>
<hr>
<h4>{?1000:509?}</h4>
<div class="formular">
<p>{?1000:65?}</p>
<input type="checkbox" id="uiViewAutoWakup" name="auto_wakeup" <?lua if dev_is_auto_wakeup() then box.out('checked') end?>>
<label for="uiViewAutoWakup">{?1000:862?}</label>
<p>
{?1000:479?}
<button class="ShowBtnRight" type="submit" id="uiBtnWake" name="btn_wake">{?1000:172?}</button>
</p>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" id="backToPage" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" id="aktDevice" name="dev" value="<?lua box.html(dev_node) ?>">
<input type="hidden" id="uiLastAction" name="last_action" value="<?lua box.html(g_last_action) ?>">
<button type="submit" <?lua if page_editable() then box.out("name='btn_save' id='btnSave'") else box.out("name='btn_chancel' id='btnChancel'") end ?> >{?txtOk?}</button>
<span <?lua if not(page_editable()) then box.out("style='display:none;'") end ?>><button type="submit" name="btn_chancel" id="btnChancel">{?txtCancel?}</button></span>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var plcFirmwareupdateRunning = false;
function startPlcFirmwareupdate() {
var check_update_aktiv;
var data = [];
function callback(xhr){
var answer = makeJSONParser()(xhr.responseText || "null");
check_update_aktiv = answer.check_update_aktiv;
setUpdate(check_update_aktiv);
}
function getUpdateState()
{
ajaxPost(url, data.join("&"), callback);
}
function setUpdate(value) {
switch(value)
{
case "0":
jxl.changeImage("uiUpdateImage","/css/default/images/finished_error.gif");
jxl.setText("uiUpdateText","{?1000:729?}");
jxl.hide("uiUpdateInfo");
plcFirmwareupdateRunning = true;
break;
case "1":
data = [
buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>"),
buildUrlParam("plc_firmwareupdate", "<?lua box.js(g_dev.id or [[]]) ?>"),
buildUrlParam("update_start", "run")
];
setTimeout(getUpdateState, 10000);
plcFirmwareupdateRunning = true;
break;
case "2":
jxl.changeImage("uiUpdateImage","/css/default/images/finished_ok_green.gif");
jxl.setText("uiUpdateText","{?1000:36?}");
jxl.hide("uiUpdateInfo");
plcFirmwareupdateRunning = true;
break;
}
}
if (!plcFirmwareupdateRunning) {
var url = encodeURI("<?lua box.js(box.glob.script) ?>");
data = [
buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>"),
buildUrlParam("plc_firmwareupdate", "<?lua box.js(g_dev.id or [[]]) ?>"),
buildUrlParam("update_start", "start")
];
plcFirmwareupdateRunning = true;
jxl.show("uiUpdate");
jxl.hide("uiFirmwareupdate");
getUpdateState()
}
jxl.disable("uiStartPlcFirmwareupdate");
jxl.setHtml("uiStartPlcFirmwareupdate", "{?1000:573?}");
}
function onChangePlcActive(checkbox)
{
<?lua
if config.GUI_IS_REPEATER and config.GUI_IS_POWERLINE and dev_is_plc() and box.glob.script == "/net/edit_plc.lua" then
box.out([[
var checked = jxl.getChecked(checkbox);
jxl.disableNode("uiViewPlcDesc", !checked);
jxl.disableNode("uiViewAddPlc", !checked);
]])
end
?>
}
function resetDevName()
{
jxl.setValue("uiViewDeviceName", "");
}
function init()
{
<?lua
if dev_is_plc() then
box.out([[
jxl.setHtml('contentTitle','<h2>]]..box.tojs(box.tohtml([[{?1000:85?} ]]))..box.tojs(box.tohtml(g_dev.name))..[[</h2>');
onChangePlcActive("uiViewPlcActive");
fc.init("uiPlcPwBox", 5, "mac");
]])
if g_dev.writeStatus ~= "" then
box.out([[
function doRequestRefreshData()
{
ajaxGet("]]..href.get(box.glob.script, 'ajax=writeStatus','dev='..g_dev._node)..[[", callback);
}
function callback(xhr){
var answer = makeJSONParser()(xhr.responseText || "null");
if (answer.writeStatus != "")
setTimeout(doRequestRefreshData, 2000);
else
{
//location.reload(true);
jxl.submitForm("main_form");
}
}
doRequestRefreshData();
]])
end
else
box.out([[jxl.setHtml('contentTitle','<h2>]]..box.tojs(box.tohtml([[{?1000:84?} ]]))..box.tojs(box.tohtml(g_dev.name))..[[</h2>');]])
end
?>
}
ready.onReady(init);
ready.onReady(ajaxValidation({
applyNames: "btn_save"
}));
</script>
<?include "templates/html_end.html" ?>
