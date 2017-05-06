<?lua
g_page_type = "all"
g_page_title = [[{?262:701?}]]
g_page_help = "hilfe_ipv4_settings.html"
g_menu_active_page = "/net/network_settings.lua"
dofile("../templates/global_lua.lua")
require("cmtable")
require("newval")
require("http")
require("href")
require("ip")
g_back_to_page = http.get_back_to_page("/net/network_settings.lua")
if next(box.post) and box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
g_my_nat=false
g_isDsl = config.DSL
g_isVdsl = config.VDSL
g_viewmain=(g_isDsl or g_isVdsl) and (config.WLAN or config.ETHCOUNT>1)
g_show_all = true
g_data = {
dhcp ={
all=false,
LanA=false,
LanB=false,
Wlan=false
},
ip={
all={"","","",""},
LanA={"","","",""},
LanB={"","","",""},
Wlan={"","","",""}
},
netmask={
all={"","","",""},
LanA={"","","",""},
LanB={"","","",""},
Wlan={"","","",""}
},
dhcp_start={
all={"","","",""},
LanA={"","","",""},
LanB={"","","",""},
Wlan={"","","",""}
},
dhcp_end={
all={"","","",""},
LanA={"","","",""},
LanB={"","","",""},
Wlan={"","","",""}
}
}
g_errmsg = nil
g_nat = false
local function val_prog()
newval.ipv4("Ip_all", "ip")
newval.netmask("Netmask_all", "mask")
if newval.checked("Dhcp_all") then
local boxip = ip.read_from_post("Ip_all")
local netmask = ip.read_from_post("Netmask_all")
newval.box_client_ip_range("Start_all", "End_all", boxip, netmask, "ip")
newval.num_range("lease_time", 1, 3650, "leasetime")
end
if config.static_net then
newval.ipv4("Ip_static_net", {empty_allowed=true}, "ip")
newval.netmask("Netmask_static_net", {empty_allowed=true}, "mask")
end
end
local leasetime_msg = [[{?262:801?}]]
newval.msg.leasetime = {
[newval.ret.empty] = leasetime_msg,
[newval.ret.format] = leasetime_msg,
[newval.ret.outofrange] = leasetime_msg
}
newval.msg.ip = {
[newval.ret.empty] = [[{?262:806?}]],
[newval.ret.format] = [[{?262:903?}]],
[newval.ret.outofrange] = [[{?262:298?}]],
[newval.ret.outofnet] = [[{?262:102?}]],
[newval.ret.thenet] = [[{?262:780?}]],
[newval.ret.broadcast] = [[{?262:617?}]],
[newval.ret.thebox] = [[{?262:979?}]],
[newval.ret.unsized] = [[{?262:391?}]]
}
newval.msg.mask = {
[newval.ret.empty] = [[{?262:949?}]],
[newval.ret.format] = [[{?262:821?}]],
[newval.ret.outofrange] = [[{?262:235?}]],
[newval.ret.nomask] = [[{?262:583?}]]
}
local function sec2days(s)
s = tonumber(s) or 0
return math.round(s / 60 / 60 / 24)
end
local function days2sec(d)
d = tonumber(d) or 0
return math.round(d * 24 * 60 * 60)
end
local function is_empty_ip(str)
if str and str ~= "" and str ~= "0.0.0.0" then
return false
end
return true
end
function read_box_values()
g_data.dhcp ["all"]=box.query("interfaces:settings/lan0/dhcpserver")=="1"
g_data.ip ["all"]=ip.quad2table(box.query("interfaces:settings/lan0/ipaddr"))
g_data.netmask ["all"]=ip.quad2table(box.query("interfaces:settings/lan0/netmask"))
g_data.dhcp_start["all"]=ip.quad2table(box.query("interfaces:settings/lan0/dhcpstart"))
g_data.dhcp_end ["all"]=ip.quad2table(box.query("interfaces:settings/lan0/dhcpend"))
g_data.lease_time = sec2days(box.query("box:settings/dhcpserver/lease_time"))
if not g_show_all then
g_data.dhcp ["LanA"]=box.query("interfaces:settings/lan0/dhcpserver")=="1"
g_data.ip ["LanA"]=ip.quad2table(box.query("interfaces:settings/lan0/ipaddr"))
g_data.netmask ["LanA"]=ip.quad2table(box.query("interfaces:settings/lan0/netmask"))
g_data.dhcp_start["LanA"]=ip.quad2table(box.query("interfaces:settings/lan0/dhcpstart"))
g_data.dhcp_end ["LanA"]=ip.quad2table(box.query("interfaces:settings/lan0/dhcpend"))
g_data.dhcp ["LanB"]=box.query("interfaces:settings/lan1/dhcpserver")=="1"
g_data.ip ["LanB"]=ip.quad2table(box.query("interfaces:settings/lan1/ipaddr"))
g_data.netmask ["LanB"]=ip.quad2table(box.query("interfaces:settings/lan1/netmask"))
g_data.dhcp_start["LanB"]=ip.quad2table(box.query("interfaces:settings/lan1/dhcpstart"))
g_data.dhcp_end ["LanB"]=ip.quad2table(box.query("interfaces:settings/lan1/dhcpend"))
g_data.dhcp ["Wlan"]=box.query("interfaces:settings/wlan/dhcpserver")=="1"
g_data.ip ["Wlan"]=ip.quad2table(box.query("interfaces:settings/wlan/ipaddr"))
g_data.netmask ["Wlan"]=ip.quad2table(box.query("interfaces:settings/wlan/netmask"))
g_data.dhcp_start["Wlan"]=ip.quad2table(box.query("interfaces:settings/wlan/dhcpstart"))
g_data.dhcp_end ["Wlan"]=ip.quad2table(box.query("interfaces:settings/wlan/dhcpend"))
end
g_data.ip ["guest"]=ip.quad2table(box.query("interfaces:settings/guest_ip"))
g_data.netmask ["guest"]=ip.quad2table(box.query("interfaces:settings/guest_netmask"))
if box.query("box:settings/static_net/enabled") == "1" then
g_data.ip.static_net = ip.quad2table(box.query("box:settings/static_net/prefix"))
else
g_data.ip.static_net = {"", "", "", ""}
end
g_data.netmask.static_net = ip.quad2table(box.query("box:settings/static_net/netmask"))
g_nat = (box.query("connection0:settings/masquerading/enabled")=="0" )
end
function refill_user_input()
local t={"","","",""}
if g_show_all then
if (box.post.Ip_all0==nil) then
g_data.ip["all"]=t
else
g_data.ip["all"]= { box.post.Ip_all0, box.post.Ip_all1, box.post.Ip_all2, box.post.Ip_all3 }
end
if (box.post.Netmask_all0==nil) then
g_data.netmask["all"]=t
else
g_data.netmask["all"]= { box.post.Netmask_all0, box.post.Netmask_all1, box.post.Netmask_all2, box.post.Netmask_all3 }
end
g_data.dhcp["all"]= ( box.post.Dhcp_all ~= nil)
if (box.post.Start_all0==nil) then
g_data.dhcp_start["all"]= t
else
g_data.dhcp_start["all"]= { box.post.Start_all0, box.post.Start_all1, box.post.Start_all2, box.post.Start_all3 }
end
if (box.post.End_all0==nil) then
g_data.dhcp_end["all"]= t
else
g_data.dhcp_end["all"]= { box.post.End_all0, box.post.End_all1, box.post.End_all2, box.post.End_all3 }
end
g_data.lease_time = box.post.lease_time or ""
end
g_nat = ( box.post.nat ~= nil)
g_data.ip.guest = ip.quad2table(box.query("interfaces:settings/guest_ip"))
g_data.netmask.guest = ip.quad2table(box.query("interfaces:settings/guest_netmask"))
g_data.ip.static_net
= array.build(4, function(i) return box.post["Ip_static_net" .. (i-1)] or "" end)
g_data.netmask.static_net
= array.build(4, function(i) return box.post["Netmask_static_net" .. (i-1)] or "" end)
end
if box.post.validate == "apply" then
require"js"
local valresult, answer = newval.validate(val_prog)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
if newval.validate(val_prog) == newval.ret.ok then
local saveset = {}
local NextPageToShow="reload"
if g_show_all then
local oldIp=box.query("interfaces:settings/lan0/ipaddr")
local newIp=ip.read_from_post("Ip_all")
if (newIp~=oldIp) then
cmtable.add_var(saveset, "forwardrules:settings/use_exposed_host", "0")
NextPageToShow="/networkchange.lua"
end
cmtable.add_var(saveset, "interfaces:settings/lan0/ipaddr", newIp)
cmtable.add_var(saveset, "interfaces:settings/lan0/netmask", ip.read_from_post("Netmask_all"))
cmtable.save_checkbox(saveset, "interfaces:settings/lan0/dhcpserver", "Dhcp_all")
if box.post.Dhcp_all then
cmtable.add_var(saveset, "interfaces:settings/lan0/dhcpstart", ip.read_from_post("Start_all"))
cmtable.add_var(saveset, "interfaces:settings/lan0/dhcpend", ip.read_from_post("End_all"))
local lease_time = string.format("%d", days2sec(box.post.lease_time))
cmtable.add_var(saveset, "box:settings/dhcpserver/lease_time", lease_time)
end
else
cmtable.add_var(saveset, "box:settings/lanbridge/activated", ip.read_from_post("LanBridge"))
end
if g_my_nat then
if (box.post.nat) then
cmtable.add_var(saveset, "connection0:settings/masquerading/enabled", "0")
cmtable.add_var(saveset, "connection0:settings/firewall/enabled", "0")
else
cmtable.add_var(saveset, "connection0:settings/masquerading/enabled", "1")
cmtable.add_var(saveset, "connection0:settings/firewall/enabled", "1")
end
end
if config.static_net then
local prefix = ip.read_from_post("Ip_static_net")
if is_empty_ip(prefix) then
cmtable.add_var(saveset, "box:settings/static_net/enabled", "0")
else
cmtable.add_var(saveset, "box:settings/static_net/enabled", "1")
cmtable.add_var(saveset, "box:settings/static_net/prefix", prefix)
cmtable.add_var(saveset, "box:settings/static_net/netmask", ip.read_from_post("Netmask_static_net"))
end
end
local err = 0
err, g_errmsg = box.set_config(saveset)
if err==0 then
if (NextPageToShow~="reload") then
local param = {}
param[1]="ifmode=modem"
http.redirect(href.get(NextPageToShow, unpack(param)))
end
http.redirect(href.get(g_back_to_page))
else
refill_user_input()
end
else
refill_user_input()
end
else
read_box_values()
end
function write_view_dhcp(show)
local str="display:none;"
if (show=='separate') then
if (not g_show_all) then
str=""
end
elseif (show=='all') then
if (g_show_all) then
str=""
end
elseif (show=='separate_main') then
if not g_show_all then
str=""
end
elseif (show=='separate_lan2') then
if (g_viewmain and config.ETH_COUNT==2 and not g_show_all) then
str=""
end
elseif (show=='separate_wlan') then
if (g_viewmain and config.WLAN and not g_show_all) then
str=""
end
end
box.out(str)
end
function write_LanBridge()
if (box.query("box:settings/lanbridge/activated")=="1") then
box.out("checked")
end
end
function get_port_desc(block_Id)
if (block_Id=="LanA") then
return [[{?262:664?}]]
elseif (block_Id=="LanB") then
return [[{?262:667?}]]
elseif (block_Id=="Wlan") then
return[[{?262:35?}]]
elseif (block_Id=="all") then
return[[{?262:329?}]]
end
return ""
end
function get_block_name(block_Id)
if (block_Id=="LanA") then
if config.ETH_COUNT~=2 then
return [[{?262:576?}:]]
else
return [[{?262:65?}:]]
end
elseif (block_Id=="LanB") then
return [[{?262:3016?}:]]
elseif (block_Id=="Wlan") then
return[[{?262:144?}:]]
elseif (block_Id=="all") then
return[[{?262:32?}]]
end
return ""
end
function get_dhcp_checked(block_Id)
if (g_data.dhcp[block_Id]) then
return [[checked]]
end
return ""
end
function is_disabled(block_Id,checkbox_state)
if (block_Id=='all') then
if (not checkbox_state) then
return ""
elseif (checkbox_state~="") then
return ""
end
end
return "disabled"
end
function get_lease_time_input(block_id)
if block_id ~= "all" then
return ""
end
return [[
<div>
<label for="uiLease_time">]]..box.tohtml([[{?262:222?}]])..[[</label>
<input class="numbers" type="text" size="5" maxlength="4" name="lease_time" id="uiLease_time" onkeyup="OnChangeDays(this.value)" value="]]..box.tohtml(g_data.lease_time)..[[">
<span id="uiDays">]]..box.tohtml([[{?262:654?}]])..[[</span>
<p>]].. box.tohtml([[{?262:532?}]]).. [[</p>
</div>
]]
end
function write_input_block(block_Id)
local str=[[
<h4>]]..get_block_name(block_Id)..[[</h4>
<div id="ipbox">
<label for="uiIp_]]..block_Id..[[0">]]..box.tohtml([[{?262:415?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[0" name="Ip_]]..block_Id..[[0" value="]]..box.tohtml(g_data.ip[block_Id][1])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[1" name="Ip_]]..block_Id..[[1" value="]]..box.tohtml(g_data.ip[block_Id][2])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[2" name="Ip_]]..block_Id..[[2" value="]]..box.tohtml(g_data.ip[block_Id][3])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[3" name="Ip_]]..block_Id..[[3" value="]]..box.tohtml(g_data.ip[block_Id][4])..[[" ]]..is_disabled(block_Id)..[[ />
</div>
<div id="netmaskbox">
<label for="uiViewNetMask]]..block_Id..[[">]]..box.tohtml([[{?262:512?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[0" name="Netmask_]]..block_Id..[[0" value="]]..box.tohtml(g_data.netmask[block_Id][1])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[1" name="Netmask_]]..block_Id..[[1" value="]]..box.tohtml(g_data.netmask[block_Id][2])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[2" name="Netmask_]]..block_Id..[[2" value="]]..box.tohtml(g_data.netmask[block_Id][3])..[[" ]]..is_disabled(block_Id)..[[ /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[3" name="Netmask_]]..block_Id..[[3" value="]]..box.tohtml(g_data.netmask[block_Id][4])..[[" ]]..is_disabled(block_Id)..[[ />
</div>]]
if g_my_nat and block_id~='all' then
str=str..[[
<div>
<input type="checkbox" id="uiViewNAT" name="nat" ]]
if g_nat then
str=str..[[checked]]
end
str=str..[[ onclick="OnNAT(this.checked)" ]]..is_disabled(block_Id)..[[>&nbsp;<label for="uiViewNAT">]]..box.tohtml([[{?262:6?}]])..[[</label>
<p>]]..box.tohtml([[{?262:353?}]])..[[</p>
<p>]]..box.tohtml([[{?262:410?}]])..[[</p>
</div>]]
end
str=str..[[
<div class="Dhcpcheck">
<input type="checkbox" id="uiViewDhcp_]]..block_Id..[[" onclick="uiDoOnDhcpClicked(']]..block_Id..[[')" ]]..get_dhcp_checked(block_Id)..[[ name="Dhcp_]]..block_Id..[[" ]]..is_disabled(block_Id)..[[>&nbsp;<label for="uiViewDhcp_]]..block_Id..[[" >]]..get_port_desc(block_Id)..[[</label>
</div>
<div class="formular" id="uiDhcpArea_]]..block_Id..[[">
<p>{?262:346?}</p>
<div class="formular">
<div>
<div id="startipbox">
<label for="uiStart_]]..block_Id..[[0"]]..[[>]]..box.tohtml([[{?262:869?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiStart_]]..block_Id..[[0" name="Start_]]..block_Id..[[0" value="]]..box.tohtml(g_data.dhcp_start[block_Id][1])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ /> .
<input type="text" size="3" maxlength="3" id="uiStart_]]..block_Id..[[1" name="Start_]]..block_Id..[[1" value="]]..box.tohtml(g_data.dhcp_start[block_Id][2])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ /> .
<input type="text" size="3" maxlength="3" id="uiStart_]]..block_Id..[[2" name="Start_]]..block_Id..[[2" value="]]..box.tohtml(g_data.dhcp_start[block_Id][3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiStart_]]..block_Id..[[3" name="Start_]]..block_Id..[[3" value="]]..box.tohtml(g_data.dhcp_start[block_Id][4])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ />
</div>
<div id="endipbox">
<label for="uiEnd_]]..block_Id..[[0"]]..[[>]]..box.tohtml([[{?262:195?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiEnd_]]..block_Id..[[0" name="End_]]..block_Id..[[0" value="]]..box.tohtml(g_data.dhcp_end[block_Id][1])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ /> .
<input type="text" size="3" maxlength="3" id="uiEnd_]]..block_Id..[[1" name="End_]]..block_Id..[[1" value="]]..box.tohtml(g_data.dhcp_end[block_Id][2])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ /> .
<input type="text" size="3" maxlength="3" id="uiEnd_]]..block_Id..[[2" name="End_]]..block_Id..[[2" value="]]..box.tohtml(g_data.dhcp_end[block_Id][3])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ /> .
<input type="text" size="3" maxlength="3" id="uiEnd_]]..block_Id..[[3" name="End_]]..block_Id..[[3" value="]]..box.tohtml(g_data.dhcp_end[block_Id][4])..[[" ]]..is_disabled(block_Id,get_dhcp_checked(block_Id))..[[ />
</div>
</div>
</div>
]]
.. get_lease_time_input(block_Id)
.. [[
</div>
]]
box.out(str)
end
function write_guest_block()
local str=[[
<h4>]]..box.tohtml([[{?262:98?}]])..[[</h4>
<div class="explain">]]..
box.tohtml([[{?262:774?}]])..
[[</div>
<div id="guestipbox">
<label for="uiIp_guest0">]]..box.tohtml([[{?262:522?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiIp_guest0" name="Ip_guest0" value="]]..box.tohtml(g_data.ip["guest"][1])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiIp_guest1" name="Ip_guest1" value="]]..box.tohtml(g_data.ip["guest"][2])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiIp_guest2" name="Ip_guest2" value="]]..box.tohtml(g_data.ip["guest"][3])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiIp_guest3" name="Ip_guest3" value="]]..box.tohtml(g_data.ip["guest"][4])..[[" disabled />
</div>
<div id="guestnetmaskbox">
<label for="uiViewNetMaskguest">]]..box.tohtml([[{?262:60?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiNetmask_guest0" name="Netmask_guest0" value="]]..box.tohtml(g_data.netmask["guest"][1])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_guest1" name="Netmask_guest1" value="]]..box.tohtml(g_data.netmask["guest"][2])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_guest2" name="Netmask_guest2" value="]]..box.tohtml(g_data.netmask["guest"][3])..[[" disabled /> .
<input type="text" size="3" maxlength="3" id="uiNetmask_guest3" name="Netmask_guest3" value="]]..box.tohtml(g_data.netmask["guest"][4])..[[" disabled />
</div>]]
box.out(str)
end
function write_static_net_block()
if not config.static_net then
return
end
box.out([[<div><hr><h4>]])
box.html([[{?262:47?}]])
box.out([[</h4><p>]])
box.html([[{?262:231?}]])
box.out([[</p>]])
local block_Id = "static_net"
box.out([[
<div id="static_net_ipbox">
<label for="uiIp_]]..block_Id..[[0">]]..box.tohtml([[{?262:927?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[0" name="Ip_]]..block_Id..[[0" value="]]..box.tohtml(g_data.ip[block_Id][1])..[["> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[1" name="Ip_]]..block_Id..[[1" value="]]..box.tohtml(g_data.ip[block_Id][2])..[["> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[2" name="Ip_]]..block_Id..[[2" value="]]..box.tohtml(g_data.ip[block_Id][3])..[["> .
<input type="text" size="3" maxlength="3" id="uiIp_]]..block_Id..[[3" name="Ip_]]..block_Id..[[3" value="]]..box.tohtml(g_data.ip[block_Id][4])..[[">
</div>
<div id="static_net_netmaskbox">
<label for="uiViewNetMask]]..block_Id..[[">]]..box.tohtml([[{?262:68?}]])..[[</label>
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[0" name="Netmask_]]..block_Id..[[0" value="]]..box.tohtml(g_data.netmask[block_Id][1])..[["> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[1" name="Netmask_]]..block_Id..[[1" value="]]..box.tohtml(g_data.netmask[block_Id][2])..[["> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[2" name="Netmask_]]..block_Id..[[2" value="]]..box.tohtml(g_data.netmask[block_Id][3])..[["> .
<input type="text" size="3" maxlength="3" id="uiNetmask_]]..block_Id..[[3" name="Netmask_]]..block_Id..[[3" value="]]..box.tohtml(g_data.netmask[block_Id][4])..[[">
</div>
]])
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
g_ip = "<?lua box.js(box.query('interfaces:settings/lan0/ipaddr')) ?>";
g_mask = "<?lua box.js(box.query('interfaces:settings/lan0/netmask')) ?>";
g_dhcp = <?lua box.js(tostring(box.query('interfaces:settings/lan0/dhcpserver') == '1')) ?>;
g_dhcpStart = "<?lua box.js(box.query('interfaces:settings/lan0/dhcpstart')) ?>";
g_dhcpEnd = "<?lua box.js(box.query('interfaces:settings/lan0/dhcpend')) ?>";
g_my_nat = <?lua box.js(tostring(g_my_nat)) ?>;
g_nat = <?lua box.js(tostring(g_nat))?>;
g_show_all = <?lua box.js(tostring(g_show_all))?>;
g_oem = "<?lua box.js(config.oem) ?>";
function init()
{
OnChangeDays("<?lua box.js(g_data.lease_time) ?>");
fc.init("ipbox", 3, 'ip');
fc.init("startipbox", 3, 'ip');
fc.init("endipbox", 3, 'ip');
fc.init("netmaskbox", 3, 'ip');
fc.init("static_net_ipbox", 3, 'ip');
fc.init("static_net_netmaskbox", 3, 'ip');
if (g_show_all)
{
}
else
{
}
if (g_my_nat) {
if(g_nat) {
jxl.setChecked("uiViewDhcp_all",false);
jxl.disableNode("uiDhcpArea_all", true);
jxl.setDisabled("uiViewDhcp_all", true);
}
}
if (g_show_all)
{
uiDoOnDhcpClicked('all');
for (var i=0; i<4; i++) {
jxl.addEventHandler("uiIp_all"+String(i), "blur", uiDoOnNetBlur);
jxl.addEventHandler("uiNetmask_all"+String(i), "blur", uiDoOnNetBlur);
}
jxl.focus("uiIp_all0");
jxl.select("uiIp_all0");
}else{
}
}
function uiDoOnMainFormSubmit() {
var str = "";
var newDhcp = jxl.getChecked("uiViewDhcp_all");
var newDhcpStart = ip.partsToQuad("uiStart_all");
var newDhcpEnd = ip.partsToQuad("uiEnd_all");
g_boxIp = ip.partsToQuad("uiIp_all");
g_boxNetmask = ip.partsToQuad("uiNetmask_all");
var newRange = false;
if (g_boxIp != g_ip ) {
newRange = !ip.addrInNet(ip.analyseNet(g_ip, g_mask), g_boxIp);
if (newRange) {
str += "{?262:833?}";
}
else {
str += "{?262:84?}";
}
}
if (g_boxNetmask != g_mask) {
if (str != "") {
str += ", "
}
str += "{?262:459?}";
}
if (newDhcp != g_dhcp || newDhcpStart != g_dhcpStart || newDhcpEnd != g_dhcpEnd) {
if (str != "") {
str += " {?262:210?} "
}
str += "{?262:452?}";
}
var result=true;
if (str) {
if (newRange) {
result=confirm(jxl.sprintf("{?262:230?}\n\n{?262:683?}",str,"\n\n","\n","\n\n","\n\n"));
}
else{
result=confirm(jxl.sprintf("{?262:863?}",str,"\n\n","\n\n"));
}
}
return result;
}
function uiDoOnDhcpClicked(block_Id) {
jxl.disableNode("uiDhcpArea_"+block_Id, !jxl.getChecked("uiViewDhcp_"+block_Id));
}
function checkValid() {
return true;
}
function uiDoOnNetBlur() {
if (checkValid()) {
var ipstr = ip.partsToQuad("uiIp_all");
var maskstr = ip.partsToQuad("uiNetmask_all");
var net = ip.analyseNet(ipstr, maskstr);
var startBitstr = ip.quadToBitstr(ip.partsToQuad("uiStart_all"));
var endBitstr = ip.quadToBitstr(ip.partsToQuad("uiEnd_all"));
startBitstr = net.net + startBitstr.substr(net.net.length);
endBitstr = net.net + endBitstr.substr(net.net.length);
if (net.host.length < 8) {
var nexthost = (parseInt(net.host, 2) + 1).toString(2);
while (nexthost.length < net.host.length) {
nexthost = "0" + nexthost;
}
if (nexthost.length == net.host.length) {
startBitstr = net.net + nexthost;
endBitstr = net.net + (parseInt(net.host.replace(/0/g,"1"), 2) - 1).toString(2);
}
}
for (var i=0; i<4; i++) {
jxl.setValue("uiStart_all"+String(i), parseInt(startBitstr.substr(i*8, 8), 2));
jxl.setValue("uiEnd_all"+String(i), parseInt(endBitstr.substr(i*8, 8), 2));
}
}
}
function OnChangeDays(value) {
if (value=="1")
jxl.setHtml("uiDays","{?262:614?}");
else
jxl.setHtml("uiDays","{?262:3716?}");
}
function OnChangeLanBridge() {
var b = jxl.getChecked("uiViewLanBridge");
jxl.display("uiViewSeparated", !b);
jxl.display("uiViewAll", b);
}
function GetIp(BaseId)
{
var ip=[];
var str="";
for (i=0;i<4;i++)
{
ip.push(jxl.getValue(BaseId+i));
}
str=ip.join(".");
return str;
}
function doPopupWindow() {
var secondWindow = "Zweitfenster";
var ipaddr = GetIp("uiIp_all");
var netmask = GetIp("uiNetmask_all");
var ip_start= GetIp("uiStart_all");
var ip_end = GetIp("uiEnd_all");
var dhcp = jxl.getChecked("uiViewDhcp_all")?"1":"0";
var my_nat = g_my_nat;
var nat = jxl.getChecked("uiViewNAT")?"1":"0";
var url = encodeURI("<?lua href.write('/net/pp_ipaddr.lua') ?>");
url += "&stylemode="+encodeURIComponent("print");
url += "&ipaddr="+encodeURIComponent(ipaddr);
url += "&netmask="+encodeURIComponent(netmask);
url += "&ip_start="+encodeURIComponent(ip_start);
url += "&ip_end="+encodeURIComponent(ip_end);
url += "&use_dhcp="+encodeURIComponent(dhcp);
url += "&my_nat="+encodeURIComponent(my_nat);
url += "&nat="+encodeURIComponent(nat);
var WinHeight=475;
var ppWindow = window.open(url, secondWindow, "width=520,height="+WinHeight+",statusbar,resizable=yes");
if (ppWindow) {
ppWindow.focus();
}
}
ready.onReady(init);
ready.onReady(ajaxValidation({
formNameOrIndex: "main_form",
okCallback: uiDoOnMainFormSubmit,
openPopup: doPopupWindow
}));
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua box.html(box.glob.script) ?>" name="main_form">
<div class="formular small_indent">
<div style="<?lua write_view_dhcp('separate_main')?>" >
<div class="formular">
<p><input type="checkbox" id="uiViewLanBridge" name="LanBridge" onclick="OnChangeLanBridge()" <?lua write_LanBridge()?>>&nbsp;<label for="uiViewLanBridge" >{?262:5743?}</label></p>
<p>{?262:846?}</p>
</div>
<hr>
</div>
<div>
<p>{?262:924?}</p>
<p>
<span class="WarnMsgBold">{?262:250?}</span><br>
{?262:260?}
</p>
<hr>
</div>
<div id="uiViewAll" style="<?lua write_view_dhcp('all') ?>">
<?lua write_input_block('all') ?>
</div>
<div id="uiViewSeparated" style="<?lua write_view_dhcp('separate')?>">
<div id="uiLAN_A" >
<?lua write_input_block('LanA') ?>
</div>
<div id="uiLAN_B" style="<?lua write_view_dhcp('separate_lan2') ?>" >
<?lua write_input_block('LanB') ?>
</div>
<div id="uiWLAN" style="<?lua write_view_dhcp('separate_wlan') ?>">
<?lua write_input_block('Wlan') ?>
</div>
</div>
<div id="uiViewGuest">
<hr>
<?lua write_guest_block() ?>
</div>
<?lua write_static_net_block() ?>
<div class="formular">
<?lua
if g_errmsg and string.len(g_errmsg)>0 then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>"/>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>"/>
<button type="submit" name="apply" id="uiApply">{?txtApplyOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
