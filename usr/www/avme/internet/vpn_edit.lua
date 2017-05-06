<?lua
g_page_type = "all"
g_page_title = [[{?74:4566?}]]
dofile("../templates/global_lua.lua")
g_page_needs_js=true
require("cmtable")
require("val")
require("general")
require("ip")
require("boxusers")
require("http")
require("href")
g_back_to_page = http.get_back_to_page( "/internet/vpn.lua" )
g_menu_active_page = g_back_to_page
if box.post.btn_cancel or ( not box.get.id and not box.post.id ) then
http.redirect(href.get(g_back_to_page))
end
if box.get.id then
g_id = box.get.id
else
g_id = box.post.id
end
g_select = "4"
if box.post.accesstype then
g_select = box.post.accesstype
if g_select == "2" then
http.redirect(href.get("/system/boxuser_list.lua"))
end
elseif box.post.hidden_accesstype then
g_select = box.post.hidden_accesstype
end
g_data = {
ip4 = {"","","",""},
netmask = {"255","255","255","0"},
access_hostname = "",
access_username = "",
access_psk = "",
dns_domains = "",
xauth_username = "",
xauth_password = "",
keepalive = "",
ipsecbr_enabled = "",
ipsecbr_prefix = {"","","",""},
ipsecbr_netmask = {"255","255","255","0"},
ipsecbr_dns1 = {"","","",""},
ipsecbr_dns2 = {"","","",""},
eth1, eth2, eth3 = false, false, false,
guest_lan_disabled = (box.query("box:settings/ethernet_guest_enabled") == "0")
}
function load_data()
g_data.ip4 =ip.quad2table(box.query("vpn:settings/"..g_id.."/access_net"))
g_data.netmask =ip.quad2table(box.query("vpn:settings/"..g_id.."/access_mask"))
g_data.access_hostname = box.query("vpn:settings/"..g_id.."/access_hostname")
g_data.access_username = box.query("vpn:settings/"..g_id.."/access_username")
g_data.access_psk = box.query("vpn:settings/"..g_id.."/access_psk")
g_data.dns_domains = box.query("vpn:settings/"..g_id.."/dns_domains")
g_data.xauth_username = box.query("vpn:settings/"..g_id.."/xauth_username")
g_data.xauth_password = box.query("vpn:settings/"..g_id.."/xauth_password")
g_data.keepalive = box.query("vpn:settings/"..g_id.."/keepalive")
g_data.ipsecbr_enabled = box.query("vpn:settings/"..g_id.."/ipsecbr_enabled")
g_data.ipsecbr_prefix =ip.quad2table(box.query("vpn:settings/"..g_id.."/ipsecbr_prefix"))
g_data.ipsecbr_netmask = ip.quad2table(box.query("vpn:settings/"..g_id.."/ipsecbr_netmask"))
g_data.ipsecbr_dns1 =ip.quad2table(box.query("vpn:settings/"..g_id.."/ipsecbr_first_dns"))
g_data.ipsecbr_dns2 =ip.quad2table(box.query("vpn:settings/"..g_id.."/ipsecbr_second_dns"))
g_select = box.query("vpn:settings/"..g_id.."/access_type")
local ipsecbr_interfaces = box.query("vpn:settings/"..g_id.."/ipsecbr_interfaces")
g_data.eth1, g_data.eth2, g_data.eth3 = false, false, false
if string.find(ipsecbr_interfaces,"eth1") then
g_data.eth1 = true
end
if string.find(ipsecbr_interfaces,"eth2") then
g_data.eth2 = true
end
if string.find(ipsecbr_interfaces,"eth3") then
g_data.eth3 = true
end
end
function post_data()
g_data.ip4 = {box.post.accessnet0, box.post.accessnet1, box.post.accessnet2, box.post.accessnet3}
g_data.netmask = {box.post.accessmask0, box.post.accessmask1, box.post.accessmask2,box.post.accessmask3}
if box.post.accessip then
g_data.access_hostname = box.post.accessip
end
if box.post.accessusername then
g_data.access_username = box.post.accessusername
end
if box.post.dns_domains then
g_data.dns_domains = box.post.dns_domains
end
if box.post.accesspsk then
g_data.access_psk = box.post.accesspsk
end
if box.post.usexauth then
g_data.access_psk = box.post.accesspsk
end
if box.post.xauthuser then
g_data.xauth_username = box.post.xauthuser
end
if box.post.xauthpw then
g_data.xauth_password = box.post.xauthpw
end
if box.post.keepalive then
g_data.keepalive = "1"
else
g_data.keepalive = "0"
end
if box.post.ipsecbr_enabled then
g_data.ipsecbr_enabled = "1"
if box.post.ipsecbrprefix0 then
g_data.ipsecbr_prefix = {box.post.ipsecbrprefix0,box.post.ipsecbrprefix1,box.post.ipsecbrprefix2,box.post.ipsecbrprefix3}
end
if box.post.ipsecbrdns1_0 then
g_data.ipsecbr_dns1 = {box.post.ipsecbrdns1_0,box.post.ipsecbrdns1_1,box.post.ipsecbrdns1_2,box.post.ipsecbrdns1_3}
end
if box.post.ipsecbrdns2_0 then
g_data.ipsecbr_dns2 = {box.post.ipsecbrdns2_0,box.post.ipsecbrdns2_1,box.post.ipsecbrdns2_2,box.post.ipsecbrdns2_3}
end
if box.post.ipsecbrnetmask0 then
g_data.ipsecbr_netmask = {box.post.ipsecbrnetmask0,box.post.ipsecbrnetmask1,box.post.ipsecbrnetmask2,box.post.ipsecbrnetmask3}
end
if box.post.ipsecbrinterface2 then
g_data.eth1 = true
end
if box.post.ipsecbrinterface3 then
g_data.eth2 = true
end
if box.post.ipsecbrinterface4 then
g_data.eth3 = true
end
else
g_data.ipsecbr_enabled = "0"
end
end
if string.find(g_id,"connection") == 1 then
load_data()
end
if g_select == "2" then
local name = box.query("vpn:settings/"..g_id.."/name")
for i,d in ipairs(boxusers.list) do
if d.name == name then
http.redirect(href.get("/system/boxuser_edit.lua", http.url_param("uid", d.UID)))
end
end
end
function is_checked(check)
if check then
return box.tohtml([[ checked="checked" ]])
end
return [[]]
end
function write_startmenu()
box.out([[<p>{?74:776?}</p>]])
box.out([[<hr>]])
box.out([[<div class="formular" id="uiAccessType" name="selectmenu">]])
box.out([[<p>{?74:60?}</p>]])
box.out([[<p><input type="radio" id="uiAccessType2" name="accesstype" value="2"><label for="uiAccessType2">{?74:14?}</label></p>]])
box.out([[<p class="formular">{?74:498?}</p>]])
box.out([[<p><input type="radio" id="uiAccessType3" checked name="accesstype" value="3"><label for="uiAccessType3">{?74:810?}</label></p>]])
box.out([[<p><input type="radio" id="uiAccessType1" name="accesstype" value="1"><label for="uiAccessType1">{?74:137?} </label></p>]])
box.out([[<p><input type="radio" id="uiAccessType0" name="accesstype" value="5"><label for="uiAccessType0">{?74:446?}</label></p>]])
box.out([[</div>]])
end
function write_vpnlogin(text,is_username)
box.out([[<p>]]..text..[[</p>]])
if is_username then
box.out([[<div class="formular">
<label for="uiAccessUsername">{?74:530?}</label>
<input class="input_lenght" id="uiAccessUsername" type="text" value="]]..g_data.access_username..[[" name="accessusername">
</div>]])
end
box.out([[<div class="formular">
<label for="uiAccess_Psk">{?74:522?}</label>
<input class="input_lenght" id="uiAccess_Psk" type="text" autocomplete="off" value="]]..g_data.access_psk..[[" maxlength="128" name="accesspsk">
</div>]])
end
function write_lanselect()
box.out([[
<div>
<input id="uiIpsecbrEnabled" type="checkbox" name="ipsecbr_enabled" ]]..is_checked(g_data.ipsecbr_enabled == "1")..[[ onclick="is_Ipsecbr(this.checked)" >
<label for="uiIpsecbrEnabled">{?74:6939?}</label>
<div id="Ipsecbr_div">
<div class="formular">
<input id="uiIpsecbrInterface2" type="checkbox" name="ipsecbrinterface2"]]..is_checked(g_data.eth1)..[[>
<label for="uiIpsecbrInterface2">{?74:266?}</label>
</div>
<div class="formular">
<input id="uiIpsecbrInterface3" type="checkbox" name="ipsecbrinterface3"]]..is_checked(g_data.eth2)..[[>
<label for="uiIpsecbrInterface3">{?74:610?}</label>
</div>]])
general.dbg_out("ZEIG DEN SPITTEL RICHTIG AN lan4_disabled: "..tostring(g_data.lan4_disabled).." \n")
if g_data.guest_lan_disabled then
general.dbg_out("DRIN\n")
box.out([[
<div class="formular">
<input id="uiIpsecbrInterface4" type="checkbox" name="ipsecbrinterface4"]]..is_checked(g_data.eth3)..[[>
<label for="uiIpsecbrInterface4">{?74:701?}</label>
</div>]])
end
box.out([[
<div class="formular">
<p>{?74:515?}</p>
</div>
<div class="formular" id="uiIpsecbrPrefix">
<label for="uiIpsecbrPrefix0">{?74:715?}</label>
<input id="uiIpsecbrPrefix0" type="text" value="]]..g_data.ipsecbr_prefix[1]..[[" name="ipsecbrprefix0" maxlength="3" size="3">
.
<input id="uiIpsecbrPrefix1" type="text" value="]]..g_data.ipsecbr_prefix[2]..[[" name="ipsecbrprefix1" maxlength="3" size="3">
.
<input id="uiIpsecbrPrefix2" type="text" value="]]..g_data.ipsecbr_prefix[3]..[[" name="ipsecbrprefix2" maxlength="3" size="3">
.
<input id="uiIpsecbrPrefix3" type="text" value="]]..g_data.ipsecbr_prefix[4]..[[" name="ipsecbrprefix3" maxlength="3" size="3">
</div>
<div class="formular" id="uiIpsecbrNetmask">
<label for="uiIpsecbrNetmask0">{?74:5762?}</label>
<input id="uiIpsecbrNetmask0" type="text" value="]]..g_data.ipsecbr_netmask[1]..[[" name="ipsecbrnetmask0" maxlength="3" size="3">
.
<input id="uiIpsecbrNetmask1" type="text" value="]]..g_data.ipsecbr_netmask[2]..[[" name="ipsecbrnetmask1" maxlength="3" size="3">
.
<input id="uiIpsecbrNetmask2" type="text" value="]]..g_data.ipsecbr_netmask[3]..[[" name="ipsecbrnetmask2" maxlength="3" size="3">
.
<input id="uiIpsecbrNetmask3" type="text" value="]]..g_data.ipsecbr_netmask[4]..[[" name="ipsecbrnetmask3" maxlength="3" size="3">
</div>
<div class="formular" id="uiIpsecbrDns1_">
<label for="uiIpsecbrDns1_0">{?74:444?}</label>
<input id="uiIpsecbrDns1_0" type="text" value="]]..g_data.ipsecbr_dns1[1]..[[" name="ipsecbrdns1_0" maxlength="3" size="3">
.
<input id="uiIpsecbrDns1_1" type="text" value="]]..g_data.ipsecbr_dns1[2]..[[" name="ipsecbrdns1_1" maxlength="3" size="3">
.
<input id="uiIpsecbrDns1_2" type="text" value="]]..g_data.ipsecbr_dns1[3]..[[" name="ipsecbrdns1_2" maxlength="3" size="3">
.
<input id="uiIpsecbrDns1_3" type="text" value="]]..g_data.ipsecbr_dns1[4]..[[" name="ipsecbrdns1_3" maxlength="3" size="3">
</div>
<div class="formular" id="uiIpsecbrDns2_">
<label for="uiIpsecbrDns2_0">{?74:105?}</label>
<input id="uiIpsecbrDns2_0" type="text" value="]]..g_data.ipsecbr_dns2[1]..[[" name="ipsecbrdns2_0" maxlength="3" size="3">
.
<input id="uiIpsecbrDns2_1" type="text" value="]]..g_data.ipsecbr_dns2[2]..[[" name="ipsecbrdns2_1" maxlength="3" size="3">
.
<input id="uiIpsecbrDns2_2" type="text" value="]]..g_data.ipsecbr_dns2[3]..[[" name="ipsecbrdns2_2" maxlength="3" size="3">
.
<input id="uiIpsecbrDns2_3" type="text" value="]]..g_data.ipsecbr_dns2[4]..[[" name="ipsecbrdns2_3" maxlength="3" size="3">
<div>
<span class="hintMsg">{?txtHinweis?}</span>
<p>{?74:927?}</p>
</div>
</div>
</div>
</div>]])
end
function write_ipinput(text, data)
if text ~= "" then
box.out([[<p>]]..text..[[</p>]])
end
box.out([[<div class="formular" id="uiAccessNet">
<label for="uiAccessNet0">{?74:237?}</label>
<input id="uiAccessNet0" type="text" value="]]..g_data.ip4[1]..[[" name="accessnet0" maxlength="3" size="3">
.
<input id="uiAccessNet1" type="text" value="]]..g_data.ip4[2]..[[" name="accessnet1" maxlength="3" size="3">
.
<input id="uiAccessNet2" type="text" value="]]..g_data.ip4[3]..[[" name="accessnet2" maxlength="3" size="3">
.
<input id="uiAccessNet3" type="text" value="]]..g_data.ip4[4]..[[" name="accessnet3" maxlength="3" size="3">
</div>]])
box.out([[<div class="formular" id="uiAccessMask">
<label for="uiAccessMask0">{?74:744?}</label>
<input id="uiAccessMask0" type="text" value="]]..g_data.netmask[1]..[[" name="accessmask0" maxlength="3" size="3">
.
<input id="uiAccessMask1" type="text" value="]]..g_data.netmask[2]..[[" name="accessmask1" maxlength="3" size="3">
.
<input id="uiAccessMask2" type="text" value="]]..g_data.netmask[3]..[[" name="accessmask2" maxlength="3" size="3">
.
<input id="uiAccessMask3" type="text" value="]]..g_data.netmask[4]..[[" name="accessmask3" maxlength="3" size="3">
</div>]])
end
function write_vpn_tube(data)
box.out([[<p>{?74:628?}</p><br>]])
box.out([[<p>{?74:158?}</p>]])
box.out([[<textarea id="uiDns_Domains" rows="5" cols="30" name="dns_domains">]]..g_data.dns_domains..[[</textarea>]])
end
function write_dnsinput(text, data)
box.out([[<p>]]..text..[[</p>]])
box.out([[<div class="formular">]])
box.out([[
<label for="uiAccessIp">{?74:235?}</label>
<input class="input_lenght" id="uiAccessIp" type="text" name="accessip" value="]]..g_data.access_hostname..[[">]])
box.out([[</div>]])
end
function write_cfginput()
box.out([[<div style="display:none;">]])
box.out([[<span class="hintMsg">{?74:25?}</span>]])
box.out([[<p>{?74:966?}</p>]])
box.out([[</div>]])
box.out([[<p>{?74:457?}</p>]])
box.out([[<input type="hidden" value="]]..box.tohtml(box.glob.sid)..[[" name="sid">]])
box.out([[<input id="uiView_VpnImportPassword" type="hidden" value="" name="VpnImportPassword">]])
box.out([[<div class="formular">]])
box.out([[<input id="uiView_VpnImportFile" type="file" value="" maxlength="255" size="40" name="VpnImportFile">]])
box.out([[</div>]])
box.out([[</form>]])
box.out([[<div><input id="uiVpnUsePw" type="checkbox" onclick="OnChangeUseVpnPw(this.checked)" value="0" name="vpnusepw" class="small_shifting"><label id="LabeluiVpnUsePw" for="uiVpnUsePw">{?74:453?}</label></div>]])
box.out([[<div class="formular">]])
box.out([[<label class="disabled" for="uiVpnCodePw">Kennwort</label>]])
box.out([[<input id="uiVpnCodePw" type="text" autocomplete="off" value="" maxlength="128" name="vpncodepw" disabled="">]])
box.out([[</div>]])
end
function write_permanent_connection()
box.out([[<div class="formular">]])
box.out([[<div><input id="uiKeepalive" ]]..is_checked(g_data.keepalive== "1")..[[ type="checkbox" onclick="" name="keepalive"><label id="uiLabelKeepalive" for="uiKeepalive">{?74:883?}</label></div>]])
box.out([[</div>]])
end
function write_xauth()
box.out([[<div class="formular">
<input id="uiUseXauth" ]]..is_checked(string.len(g_data.xauth_username) ~= 0)..[[ type="checkbox" onclick="is_Xauth(this.checked)" name="usexauth">
<label id="uiLabelUseXauth" for="uiUseXauth">{?74:347?}</label>]])
box.out([[<div class="formular">
<label for="uiXauthUser">{?74:41?}</label>
<input class="input_lenght" id="uiXauthUser" type="text" name="xauthuser" value="]]..g_data.xauth_username..[[">]])
box.out([[</div>]])
box.out([[<div class="formular">
<label class="disabled" for="uiXauthPw">{?74:169?}</label>
<input class="input_lenght" id="uiXauthPw" type="text" autocomplete="off" value="]]..g_data.xauth_password..[[" maxlength="128" name="xauthpw" disabled="">]])
box.out([[</div>]])
box.out([[</div>]])
end
function showform(select)
if select == "5" then
box.out([[<form id="ui_SubmitImport" method="POST" enctype="multipart/form-data" action="../cgi-bin/firmwarecfg">]])
write_cfginput()
box.out([[<form id="MainForm" name="main_form" method="POST" action="]]..href.get(box.glob.script)..[[">]])
else
box.out([[<form id="MainForm" name="main_form" method="POST" action="]]..href.get(box.glob.script)..[[">]])
end
if select == "1" then
local vpn_txt = [[{?74:727?}]]
local dns_txt = [[{?74:8?}]]
local ip_txt = [[{?74:832?}]]
write_vpnlogin(vpn_txt, true)
write_xauth()
box.out([[<hr>]])
write_dnsinput(dns_txt)
box.out([[<hr>]])
write_ipinput(ip_txt)
write_permanent_connection()
box.out([[<hr>]])
write_vpn_tube()
elseif select == "3" then
local vpn_txt = [[{?74:398?}]]
local dns_txt = [[{?74:544?}]]
local ip_txt = [[{?74:871?}]]
write_vpnlogin(vpn_txt, false)
box.out([[<hr>]])
write_dnsinput(dns_txt)
box.out([[<hr>]])
write_ipinput(ip_txt)
write_permanent_connection()
box.out([[<hr>]])
write_lanselect()
elseif select == "4" then
write_startmenu()
end
end
g_val = {
prog = [[
if __value_equal(uiHidden_Accesstype/hidden_accesstype, 0) then
if __checked(uiVpnUsePw/vpnusepw) then
not_empty(uiVpnCodePw/vpncodepw, password_equal)
end
not_empty(uiView_VpnImportFile/VpnImportFile, is_filepath)
end
if __value_equal(uiHidden_Accesstype/hidden_accesstype, 1) then
if __value_equal(uiAccess_Psk/accesspsk,****) then
const_error(uiAccess_Psk/accesspsk, wrong, psk_error)
end
if __checked(uiUseXauth/usexauth) then
not_empty(uiXauthUser/xauthuser,xauth_user)
not_empty(uiXauthPw/xauthpw,xauth_pw)
end
not_empty_or_absent(uiAccessUsername/accessusername, vpn_user)
not_empty_or_absent(uiAccess_Psk/accesspsk, vpn_pw)
not_empty_or_absent(uiAccessIp/accessip, vpn_dinsinfo)
ipv4(uiAccessNet/accessnet, ip)
netmask(uiAccessMask/accessmask, mask)
end
if __value_equal(uiHidden_Accesstype/hidden_accesstype, 3) then
if __value_equal(uiAccess_Psk/accesspsk,****) then
const_error(uiAccess_Psk/accesspsk, wrong, psk_error)
end
not_empty_or_absent(uiAccess_Psk/accesspsk, vpn_pw)
not_empty_or_absent(uiAccessIp/accessip, vpn_dinsinfo)
ipv4(uiAccessNet/accessnet, ip)
netmask(uiAccessMask/accessmask, mask)
if __checked(uiIpsecbrEnabled/ipsecbr_enabled) then
ipv4(uiIpsecbrPrefix/ipsecbrprefix, ip)
netmask(uiIpsecbrNetmask/ipsecbrnetmask, mask)
if __value_not_empty(uiIpsecbrDns1_0/ipsecbrdns1_0) then
ipv4(uiIpsecbrDns1_/ipsecbrdns1_, ip)
end
if __value_not_empty(uiIpsecbrDns2_0/ipsecbrdns2_0) then
ipv4(uiIpsecbrDns2_/ipsecbrdns2_, ip)
end
end
end
]]
}
val.msg.is_filepath = {
[val.ret.empty] = [[{?74:524?}]],
[val.ret.notfound] = [[{?74:387?}]],
[val.ret.wrong] = [[{?74:242?}]]
}
val.msg.password_equal = {
[val.ret.empty] = [[{?74:222?}]],
[val.ret.notfound] = [[{?74:265?}]],
[val.ret.different] = [[{?74:138?}]]
}
val.msg.ip = {
[val.ret.empty] = [[{?74:876?}]],
[val.ret.format] = [[{?74:779?}]],
[val.ret.outofrange] = [[{?74:200?}]],
[val.ret.outofnet] = [[{?74:5541?}]],
[val.ret.thenet] = [[{?74:458?}]],
[val.ret.broadcast] = [[{?74:16?}]],
[val.ret.thebox] = [[{?74:336?}]],
[val.ret.unsized] = [[{?74:668?}]]
}
val.msg.mask = {
[val.ret.empty] = [[{?74:207?}]],
[val.ret.format] = [[{?74:993?}]],
[val.ret.outofrange] = [[{?74:223?}]],
[val.ret.nomask] = [[{?74:43?}]]
}
val.msg.vpn_pw = {
[val.ret.empty] = [[{?74:539?}]]
}
val.msg.vpn_user = {
[val.ret.empty] = [[{?74:6056?}]]
}
val.msg.vpn_dinsinfo = {
[val.ret.empty] = [[{?74:520?}]]
}
val.msg.psk_error = {
[val.ret.wrong] = [[{?74:803?}]]
}
val.msg.xauth_user = {
[val.ret.empty] = [[{?74:961?}]],
[val.ret.notfound] =[[{?74:144?}]]
}
val.msg.xauth_pw = {
[val.ret.empty] = [[{?74:89?}]],
[val.ret.notfound] =[[{?74:440?}]]
}
if (box.post.btn_save) then
local result = val.validate(g_val)
if result == val.ret.ok then
local saveset = {}
local ip_net = ""
local ip_mask = ""
if box.post.accessnet0 then
ip_net = ip.read_from_post("accessnet")
end
if box.post.accessmask0 then
ip_mask = ip.read_from_post("accessmask")
end
if g_id == [[new]] then
g_id = [[connection]]..tostring(#general.listquery("vpn:settings/connection/list()"))
end
if box.post.accessnet0 then
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/access_net"), ip_net)
end
if box.post.accessmask0 then
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/access_mask"), ip_mask)
end
if g_select == "1" or g_select == "3" then
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/access_type"), g_select)
end
if box.post.accesspsk and box.post.accesspsk ~="****" then
cmtable.add_var(saveset, ("vpn:settings/"..g_id.."/access_psk"), box.post.accesspsk)
end
if box.post.accessusername then
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/access_username"), box.post.accessusername)
end
if box.post.accessip then
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/access_hostname"), box.post.accessip)
cmtable.add_var( saveset,("vpn:settings/"..g_id.."/name"), box.post.accessip)
end
if box.post.dns_domains then
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/dns_domains"), box.post.dns_domains)
end
if box.post.usexauth then
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/xauth_username"), box.post.xauthuser)
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/xauth_password"), box.post.xauthpw)
else
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/xauth_username"), "")
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/xauth_password"), "")
end
if box.post.keepalive then
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/keepalive"), "1")
else
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/keepalive"), "0")
end
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/activated"), "1")
if box.post.ipsecbr_enabled then
local ipsecbrprefix = ""
local ipsecbrdns1 = ""
local ipsecbrdns2 = ""
local ipsecbrnetmask = ""
local ipsec2, ipsec3 = false, false
local ipsecbr_interfaces = ""
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_enabled"), "1")
if box.post.ipsecbrprefix0 then
ipsecbrprefix = ip.read_from_post("ipsecbrprefix")
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_prefix"), ipsecbrprefix)
end
if box.post.ipsecbrdns1_0 then
ipsecbrdns1 = ip.read_from_post("ipsecbrdns1_")
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_first_dns"), ipsecbrdns1)
end
if box.post.ipsecbrdns2_0 then
ipsecbrdns2 = ip.read_from_post("ipsecbrdns2_")
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_second_dns"), ipsecbrdns2)
end
if box.post.ipsecbrnetmask0 then
ipsecbrnetmask = ip.read_from_post("ipsecbrnetmask")
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_netmask"), ipsecbrnetmask)
end
if box.post.ipsecbrinterface2 then
ipsecbr_interfaces = ipsecbr_interfaces.."eth1"
ipsec2 = true
end
if box.post.ipsecbrinterface3 then
if ipsec2 then
ipsecbr_interfaces = ipsecbr_interfaces..", "
end
ipsecbr_interfaces = ipsecbr_interfaces.."eth2"
ipsec3 = true
end
if box.post.ipsecbrinterface4 then
if ipsec2 or ipsec3 then
ipsecbr_interfaces = ipsecbr_interfaces..", "
end
ipsecbr_interfaces = ipsecbr_interfaces.."eth3"
end
if box.post.ipsecbrinterface2 or box.post.ipsecbrinterface3 or box.post.ipsecbrinterface4 then
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_interfaces"), ipsecbr_interfaces)
end
if string.len(box.query("vpn:settings/"..g_id.."/ipsecbr_netinterface")) == 0 then
local z,k = 0,0
for a, b in ipairs(general.listquery([[vpn:settings/connection/list(ipsecbr_netinterface)]])) do
if string.len(b.ipsecbr_netinterface) > 0 then
k = tonumber(string.sub(b.ipsecbr_netinterface, 8))
if k > z then
z = k
end
end
end
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_netinterface"),"ipsecbr"..tostring(z+1))
end
else
cmtable.add_var(saveset,("vpn:settings/"..g_id.."/ipsecbr_enabled"), "0")
end
local errcode, errmsg = box.set_config( saveset)
if errcode == 0 then
http.redirect(href.get(g_back_to_page))
else
box.out(general.create_error_div(errcode, errmsg))
g_errormsg = errmsg
end
end
post_data()
end
if g_select == "4" then g_page_help = "hilfe_vpn_verbindungstyp_auswahl.html" end
if g_select == "3" then g_page_help = "hilfe_vpn_lanlan.html" end
if g_select == "1" then g_page_help = "hilfe_vpn_fritzbox_als_vpnclient.html" end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.small_shifting {
margin-right: 2px;
}
.input_lenght {
width: 195px;
}
textarea {
width: 90%;
padding: 5px;
font: inherit;
resize: vertical;
}
#uiViewIpv6Pref {
width: 30px;
}
</style>
<?include "templates/page_head.html" ?>
<?lua
showform(g_select)
if g_errormsg ~= nil then
box.out([[<div>]]..tostring(g_errormsg)..[[</div>]])
end
?>
<div id="btn_form_foot">
<input type="hidden" id="uiHidden_Accesstype" name="hidden_accesstype" value="<?lua box.html(g_select) ?>">
<input type="hidden" id="uiId" name="id" value="<?lua box.html(g_id) ?>">
<?lua
if box.post.apply or box.post.btn_save == "ok" or string.find(g_id,"connection") == 1 then
if g_select == "5" then
box.out([[<button name="btn_save" id="btnSave" onclick="val.active = true;uiDoImport(); return false;" value="ok">{?txtOK?}</button>]])
else
box.out([[<button type="submit" name="btn_save" id="btnSave" value="ok">{?txtOK?}</button>]])
end
else
box.out([[<button type="submit" name="apply" value="next">{?g_txt_Weiter?}</button>]])
end
?>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
var AccessNet = jxl.getValue("uiAccessNet0")+"."+jxl.getValue("uiAccessNet1")+"."+jxl.getValue("uiAccessNet2")+"."+jxl.getValue("uiAccessNet3");
if(jxl.getValue("uiAccessIp") == AccessNet)
{
alert("{?74:756?}");
return false;
}
var own_ip = "<?lua box.js(box.query('interfaces:settings/lan0/ipaddr')) ?>";
if( own_ip == AccessNet)
{
alert("{?74:854?}");
return false;
}
}
function is_Xauth(checked)
{
if (checked)
{
jxl.enable("uiXauthUser");
jxl.enable("uiXauthPw");
}
else
{
jxl.disable("uiXauthUser");
jxl.disable("uiXauthPw");
}
}
function is_Ipsecbr(checked)
{
if (checked)
{
jxl.enable("uiIpsecbrInterface2");
jxl.enable("uiIpsecbrInterface3");
jxl.enable("uiIpsecbrInterface4");
jxl.enable("uiIpsecbrPrefix0");
jxl.enable("uiIpsecbrPrefix1");
jxl.enable("uiIpsecbrPrefix2");
jxl.enable("uiIpsecbrPrefix3");
jxl.enable("uiIpsecbrNetmask0");
jxl.enable("uiIpsecbrNetmask1");
jxl.enable("uiIpsecbrNetmask2");
jxl.enable("uiIpsecbrNetmask3");
jxl.enable("uiIpsecbrDns1_0");
jxl.enable("uiIpsecbrDns1_1");
jxl.enable("uiIpsecbrDns1_2");
jxl.enable("uiIpsecbrDns1_3");
jxl.enable("uiIpsecbrDns2_0");
jxl.enable("uiIpsecbrDns2_1");
jxl.enable("uiIpsecbrDns2_2");
jxl.enable("uiIpsecbrDns2_3");
}
else
{
jxl.disable("uiIpsecbrInterface2");
jxl.disable("uiIpsecbrInterface3");
jxl.disable("uiIpsecbrInterface4");
jxl.disable("uiIpsecbrPrefix0");
jxl.disable("uiIpsecbrPrefix1");
jxl.disable("uiIpsecbrPrefix2");
jxl.disable("uiIpsecbrPrefix3");
jxl.disable("uiIpsecbrNetmask0");
jxl.disable("uiIpsecbrNetmask1");
jxl.disable("uiIpsecbrNetmask2");
jxl.disable("uiIpsecbrNetmask3");
jxl.disable("uiIpsecbrDns1_0");
jxl.disable("uiIpsecbrDns1_1");
jxl.disable("uiIpsecbrDns1_2");
jxl.disable("uiIpsecbrDns1_3");
jxl.disable("uiIpsecbrDns2_0");
jxl.disable("uiIpsecbrDns2_1");
jxl.disable("uiIpsecbrDns2_2");
jxl.disable("uiIpsecbrDns2_3");
}
}
function OnChangeUseVpnPw(bChecked) {
jxl.setDisabled("uiVpnCodePw", !bChecked);
if (bChecked) {
jxl.focus("uiVpnCodePw");
}
}
var g_mldImport = "{?74:901?}";
function uiDoImport() {
<?lua
val.write_js_checks( g_val)
?>
if (!confirm(g_mldImport))
return;
var usePw = jxl.getChecked("uiVpnUsePw");
if (usePw) {
jxl.setValue( "uiView_VpnImportPassword", jxl.getValue("uiVpnCodePw"));
} else {
jxl.setDisabled( "uiView_VpnImportPassword", true);
}
jxl.submitForm( "ui_SubmitImport");
}
function init() {
is_Xauth(jxl.getChecked("uiUseXauth"));
is_Ipsecbr(jxl.getChecked("uiIpsecbrEnabled"));
fc.init("uiAccessNet", 3, 'ip');
fc.init("uiAccessMask", 3, 'ip');
fc.init("uiIpsecbrPrefix", 3, 'ip');
fc.init("uiIpsecbrNetmask", 3, 'ip');
fc.init("uiIpsecbrDns1_", 3, 'ip');
fc.init("uiIpsecbrDns2_", 3, 'ip');
}
ready.onReady(val.init(onNumEditSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
