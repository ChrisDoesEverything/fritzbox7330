<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_voiperweitert.html"
dofile("../templates/global_lua.lua")
require("http")
require("newval")
require("fon_numbers")
require("general")
require("js")
require("ip")
require("country")
require("tr069")
require"menu"
if not menu.check_page("fon", "/fon_num/sip_option.lua") then
require"http"
http.redirect("/fon_num/fon_num_list.lua")
end
oem = {"avm", "1und1", "otwo","avme", "ewetel"}
g_ipaddr = {"","","",""}
g_netmask = {"","","",""}
g_gateway = {"","","",""}
g_dns0 = {"","","",""}
g_dns1 = {"","","",""}
g_nt_default= ""
function apnauth_checked()
if box.query("lted:settings/hw_info/ue/ppp_username1") ~= ""
and box.query("lted:settings/hw_info/ue/ppp_password1") ~= "" then
return " checked"
else
return ""
end
end
function refill_user_input()
local t={"","","",""}
if (box.post.ipaddr0==nil) then
g_ipaddr =t
else
g_ipaddr = { box.post.ipaddr0, box.post.ipaddr1, box.post.ipaddr2, box.post.ipaddr3 }
end
if (box.post.netmask0==nil) then
g_netmask =t
else
g_netmask = { box.post.netmask0, box.post.netmask1, box.post.netmask2, box.post.netmask3 }
end
if (box.post.gateway0==nil) then
g_gateway = t
else
g_gateway = { box.post.gateway0, box.post.gateway1, box.post.gateway2, box.post.gateway3 }
end
if (box.post.dns00==nil) then
g_dns0 = t
else
g_dns0 = { box.post.dns00, box.post.dns01, box.post.dns02, box.post.dns03 }
end
if (box.post.dns10==nil) then
g_dns1 = t
else
g_dns1 = { box.post.dns10, box.post.dns11, box.post.dns12, box.post.dns13 }
end
g_nt_default = box.post.nt_default
end
function read_box_values()
g_uiSourcePort = box.query("sipextra:settings/sip/sip_srcport")
g_pppencaps = box.query("connection_voip:settings/encapsulation")
g_sipping_interval = general.listquery("sip:settings/sip/list(sipping_interval)")[1].sipping_interval
g_sipping_enabled = general.listquery("sip:settings/sip/list(sipping_enabled)")[1].sipping_enabled
g_ipaddr = ip.quad2table(box.query("connection_voip:settings/ipaddr"))
g_netmask = ip.quad2table(box.query("connection_voip:settings/netmask"))
g_gateway = ip.quad2table(box.query("connection_voip:settings/gateway"))
g_dns0 = ip.quad2table(box.query("connection_voip:settings/dns_first"))
g_dns1 = ip.quad2table(box.query("connection_voip:settings/dns_second"))
local tmp_num = box.query("telcfg:settings/MSN/NTDefault")
tmp_num=string.gsub(tmp_num ,"SIP","")
local num_tab = fon_numbers.get_all_numbers()
local msn_list=fon_numbers.get_msn()
local elem= fon_numbers.get_elem_by_num(msn_list,tmp_num )
if (not elem) then
elem=fon_numbers.find_elem_in_list_by_telcfgid(num_tab,tmp_num )
end
if elem then
g_nt_default=elem.uid
end
g_errormsg = nil
g_countrytable = {}
end
local function val_prog()
newval.msg.error_lkz_txt = {
[newval.ret.outofrange] = [[{?881:297?}]]
}
newval.msg.error_okz_txt = {
[newval.ret.outofrange] = [[{?881:373?}]]
}
newval.msg.error_vpi_txt = {
[newval.ret.outofrange] = [[{?881:189?}]]
}
newval.msg.error_decimal_txt = {
[newval.ret.outofrange] = [[{?881:777?}]]
}
newval.msg.error_vci_range_txt = {
[newval.ret.outofrange] = [[{?881:560?}]]
}
newval.msg.error_username_txt = {
[newval.ret.empty] = [[{?881:998?}]]
}
newval.msg.error_ip_text = {
[newval.ret.empty] = [[{?881:384?}]],
[newval.ret.format] = [[{?881:2295?}]],
[newval.ret.outofrange] = [[{?881:624?}]]
}
newval.msg.error_mask_text = {
[newval.ret.empty] = [[{?881:232?}]],
[newval.ret.format] = [[{?881:300?}]],
[newval.ret.outofrange] = [[{?881:991?}]],
[newval.ret.nomask] = [[{?881:975?}]],
[newval.ret.thenet] = [[{?881:486?}]],
[newval.ret.broadcast] = [[{?881:946?}]]
}
local error_vlaninput = [[{?881:854?}]]
newval.msg.error_vlaninput_range_txt = {
[newval.ret.outofrange] = error_vlaninput,
[newval.ret.format] = error_vlaninput,
[newval.ret.notfound] = error_vlaninput
}
newval.msg.error_apn_txt = {
[newval.ret.empty] = [[{?881:6?}]]
}
newval.msg.apnautherr = {
[newval.ret.empty] = [[{?1643:554?}]]
}
newval.char_range_regex("lkz_prefix", "decimals", "error_lkz_txt")
newval.char_range_regex("lkz", "decimals", "error_lkz_txt")
newval.char_range_regex("okz_prefix", "decimals", "error_okz_txt")
newval.char_range_regex("okz", "decimals", "error_okz_txt")
if newval.checked("usevcc") then
newval.char_range_regex("vpi", "decimals", "error_decimal_txt")
newval.num_range("vpi",0,255, "error_vpi_range_txt")
newval.char_range_regex("vci", "decimals", "error_decimal_txt")
newval.num_range("vci",32,65535, "error_vci_range_txt")
if newval.radio_check("encmode","isPPP") then
newval.not_empty("username", "error_username_txt")
end
if newval.radio_check("encmode","isIP")then
if not newval.checked("usedhcp") then
newval.ipv4("ipaddr", "error_ip_text")
newval.ipv4("gateway", "error_ip_text")
newval.ipv4("dns0", "error_ip_text")
newval.ipv4("dns1", "error_ip_text")
newval.netmask("netmask", "error_mask_text")
end
end
end
if newval.checked("vlancheck") then
newval.num_range("vlaninput", 0, 4096, "error_vlaninput_range_txt")
end
if newval.checked("usepdn2") then
newval.not_empty("apninput", "error_apn_txt")
if newval.checked("apnauth") then
newval.not_empty("ppp_username1", "apnautherr")
newval.not_empty("ppp_password1", "apnautherr")
end
end
end
function is_fallback()
for a, b in ipairs(general.listquery("telcfg:settings/SIP/list(Fallback)")) do
if b.Fallback == "1" then
return [[ checked="checked" ]]
end
end
return [[ ]]
end
function is_checked(check)
if check then
return [[ checked="checked" ]]
end
return [[ ]]
end
function create_number_options()
local num_tab = fon_numbers.get_all_numbers()
local str = [[ <option value="tochoose">{?1643:471?}</option>]]
if num_tab and num_tab.numbers and num_tab.number_count>0 then
for idx, num in ipairs(num_tab.numbers) do
local selected = ""
if (g_nt_default == num.uid) then
selected = "selected"
end
str = str..[[ <option ]]..selected..[[ value="]]..box.tohtml(num.uid)..[[">]]..box.tohtml(num.msnnum)..[[</option>]]
end
end
return str
end
function ata_or_lte_set__hide()
if general.is_atamode() or config.LTE then
return true
else
return false
end
end
if next(box.post) then
if box.post.validate == "apply" then
require"js"
local valresult, answer = newval.validate(val_prog)
box.out(js.table(answer))
box.end_page()
else if next(box.post) and box.post.apply then
if newval.validate(val_prog) == newval.ret.ok then
require("cmtable")
local result = newval.validate(g_val)
if result == newval.ret.ok then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "telcfg:settings/Location/OKZ",box.post.okz)
cmtable.add_var(ctlmgr_save, "telcfg:settings/Location/LKZ",box.post.lkz)
cmtable.add_var(ctlmgr_save, "telcfg:settings/Location/OKZPrefix",box.post.okz_prefix)
cmtable.add_var(ctlmgr_save, "telcfg:settings/Location/LKZPrefix",box.post.lkz_prefix)
if general.is_expert() then
if config.is_known_oem() then
if box.post.fix_network then
cmtable.add_var(ctlmgr_save, "telcfg:settings/tr069usePSTN", "1")
if box.post.faxswitch then
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxSwitch", "1")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/FaxSwitch", "0")
end
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/tr069usePSTN", "0")
end
end
end
if (box.post.nt_default and box.post.nt_default ~= "" and box.post.nt_default ~= "tochoose") then
local elem=fon_numbers.find_num_by_UID(box.post.nt_default)
if (elem) then
if (elem.type=="sip" or elem.type=="mobile_msn") then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/NTDefault", "SIP"..elem.telcfg_id)
elseif (elem.type=="pots") then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/NTDefault", "POTS")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/NTDefault", elem.msnnum)
end
end
end
if config.is_known_oem() or box.query("box:settings/app_enabled") == "1" then
local set_fallback = "0"
if box.post.fallback then
set_fallback = "1"
end
for i = 0, box.query("telcfg:settings/SIP/count",0)-1 do
cmtable.add_var(ctlmgr_save, "telcfg:settings/SIP"..i.."/Fallback", set_fallback)
end
end
if general.is_atamode() or config.LTE then
for i, k in ipairs(general.listquery("sip:settings/sip/list")) do
if box.post.sipping then
cmtable.add_var(ctlmgr_save, "sip:settings/"..k[1].."/sipping_enabled", "1")
cmtable.add_var(ctlmgr_save, "sip:settings/"..k[1].."/sipping_interval", box.post.sipping_timer)
else
cmtable.add_var(ctlmgr_save, "sip:settings/"..k[1].."/sipping_enabled", "0")
end
end
end
if general.is_expert() and not tr069.provisioned_by_ui() then
if config.is_known_oem() then
local con_data = false;
if box.post.usevcc then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_seperate_vcc", 1)
cmtable.add_var(ctlmgr_save, "connection_voip:settings/VCI", box.post.vci)
cmtable.add_var(ctlmgr_save, "connection_voip:settings/VPI", box.post.vpi)
if box.post.encmode == "isPPP" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/username", box.post.username)
cmtable.add_var(ctlmgr_save, "connection_voip:settings/password", box.post.password)
if box.post.PppEncaps == "dslencap_pppoe" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_pppoe")
elseif box.post.PppEncaps == "dslencap_pppoa_llc" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_pppoa_llc")
elseif box.post.PppEncaps == "dslencap_pppoa" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_pppoa")
end
elseif box.post.encmode == "isIP" then
if box.post.DslIpEncaps == "dslencap_ether" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_ether")
if box.post.usedhcp then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_dhcp", "1")
else
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_dhcp", "0")
con_data = true;
end
elseif box.post.DslIpEncaps == "dslencap_ipnlpid" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_ipnlpid")
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_dhcp", "0")
con_data = true;
elseif box.post.DslIpEncaps == "dslencap_ipsnap" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_ipsnap")
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_dhcp", "0")
con_data = true;
elseif box.post.DslIpEncaps == "dslencap_ipraw" then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/encapsulation", "dslencap_ipraw")
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_dhcp", "0")
con_data = true;
end
if con_data then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/ipaddr", ip.read_from_post("ipaddr"))
cmtable.add_var(ctlmgr_save, "connection_voip:settings/netmask", ip.read_from_post("netmask"))
cmtable.add_var(ctlmgr_save, "connection_voip:settings/gateway", ip.read_from_post("gateway"))
cmtable.add_var(ctlmgr_save, "connection_voip:settings/dns_first", ip.read_from_post("dns0"))
cmtable.add_var(ctlmgr_save, "connection_voip:settings/dns_second", ip.read_from_post("dns1"))
end
end
else
cmtable.add_var(ctlmgr_save, "connection_voip:settings/use_seperate_vcc", 0)
end
end
end
if general.is_expert() then
if (not tr069.provisioned_by_ui()) then
if (box.query("box:settings/voip_2ndPVC_gui_hidden")~="1" ) then
if box.post.vlancheck then
cmtable.add_var(ctlmgr_save, "connection_voip:settings/vlanencap", "vlanencap_fixed_prio")
cmtable.add_var(ctlmgr_save, "connection_voip:settings/vlanid", box.post.vlaninput)
else
cmtable.add_var(ctlmgr_save, "connection_voip:settings/vlanencap", "vlanencap_none")
end
end
end
if box.post.T38 then
cmtable.add_var(ctlmgr_save, "sipextra:settings/sip/t38_support_enabled", "1")
else
cmtable.add_var(ctlmgr_save, "sipextra:settings/sip/t38_support_enabled", "0")
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
end
end
end
end
end
end
read_box_values()
function get_out_html()
local str_html = ""
str_html = [[<p>{?881:1054?}</p>
<hr>
<h4>{?881:1842?}</h4>
<div class="formular">
<span>{?1643:645?}</span>
<select id="uiCountry" name="country" onchange="OnChangeCountry(value)">]]
local selected = ""
if config.MULTI_COUNTRY then
g_countrytable = country.get_countrylist("KNOWN")
else
g_countrytable = country.get_countrylist("GER")
end
local lkz = box.query("telcfg:settings/Location/LKZ")
utf8.sort(g_countrytable, function(c) return c.clearname or c.name end)
for i, country in ipairs(g_countrytable) do
if(lkz == country.code) then
selected = [[ selected = "selected"]]
else
selected = [[ ]]
end
str_html = str_html..[[<option]]..selected..[[ value="]]..box.tohtml(country.code)..[[">]]..box.tohtml(country.clearname or country.name)..[[</option>]]
end
str_html = str_html..[[</select>
</div>
<div class="formular">
<label for="uiLKZPrefix">{?881:756?}</label><input class="input55" type="text" value="]]..box.tohtml(box.query("telcfg:settings/Location/LKZPrefix"))..[[" maxlength="5" id="uiLKZPrefix" name="lkz_prefix">
<input class="input75" type="text" maxlength="5" value="]]..box.tohtml(box.query("telcfg:settings/Location/LKZ"))..[[" id="uiLKZ" name="lkz">
<br>
<label for="uiOKZPrefix">{?881:435?}</label><input class="input55" type="text" value="]]..box.tohtml(box.query("telcfg:settings/Location/OKZPrefix"))..[[" maxlength="5" id="uiOKZPrefix" name="okz_prefix">
<input class="input75" type="text" maxlength="10" value="]]..box.tohtml(box.query("telcfg:settings/Location/OKZ"))..[[" id="uiOKZ" name="okz">
</div>
]]
local fallback_check = [[
<hr>
<h4>{?1643:146?}</h4>
<div class="formular">
<input type="checkbox" id="uiFallback" ]]..is_fallback()..[[ name="fallback">
<label for="uiFallback">{?881:850?}</label>
<p>{?881:129?}</p>
<p><strong>{?txtHinweis?}</strong></p>
<p>{?881:551?}</p>
</div>]]
if config.is_known_oem() then
if general.is_expert() then
str_html = str_html..[[
<hr>
<h4>{?1643:377?}</h4>
<div class="formular">
<input type="checkbox" id="uiFixNetwork" onclick="return OnCheckFixNetwork(this.checked)" name="fix_network"]]..is_checked(fon_numbers.use_PSTN()== "1")..[[>
<label for="uiFixNetwork">{?881:832?}</label>
<p>{?881:823?}</p>]]
if general.is_expert() and fon_numbers.isAnalog() then
str_html = str_html..[[
<div class="formular" id="uiFaxSwitchDiv">
<input type="checkbox" id="uiFaxSwitch"]]..is_checked(box.query("telcfg:settings/FaxSwitch")== "1")..[[name="faxswitch">
<label for="uiFaxSwitch">{?881:197?}</label>
<p>{?881:392?}</p>
</div>]]
end
str_html = str_html..[[</div>]]
end
str_html = str_html..fallback_check
end
str_html = str_html..[[<hr>
<h4>{?1643:996?}</h4>
<div class="formular">
<p>{?1643:647?}</p>
<label for="uiNtDefault">{?1643:205?}</label>
<select id="uiNtDefault" name="nt_default"> ]]
..create_number_options()..
[[</select>
</div>]]
if general.is_expert() then
local moh_text = "{?1643:204?}"
local moh_type = box.query("telcfg:settings/MOHType")
if moh_type == "1" then
moh_text = "{?1643:502?}"
elseif moh_type == "2" then
moh_text = "{?1643:765?}"
end
str_html = str_html..[[
<hr>
<h4>{?1643:774?}</h4>
<div class="formular">
<input type="text" disabled="disabled" value="]]..moh_text..[[">
<a class="textlink popup" href="javascript:onMohUpload()">
{?1643:88?}
</a>
<p>{?1643:293?}</p>
</div>]]
end
if general.is_expert() and (not tr069.provisioned_by_ui() or config.T38 == true) or ata_or_lte_set__hide() then
str_html = str_html..[[<hr>
<h4>{?1643:594?}</h4>
<p>{?1643:107?}</p>
]]
end
if config.T38 == true and general.is_expert() then
str_html = str_html..[[<div class="formular" >
<p>{?881:53?}</p>
<input type="checkbox" id="uiT38" name="T38"]]..is_checked(box.query("sipextra:settings/sip/t38_support_enabled") == "1")
str_html = str_html..[[><label for="uiT38">{?881:4888?}</label>
</div>]]
end
if general.is_expert() and not tr069.provisioned_by_ui() then
if (box.query("box:settings/voip_2ndPVC_gui_hidden")~="1") then
str_html = str_html..[[
<div class="formular">
<p>{?881:690?}</p>
<p>{?881:9297?}</p>
<div>
<input type="checkbox" name="vlancheck" id="uiVlanCheck"]]..is_checked(box.query("connection_voip:settings/vlanencap") == "vlanencap_fixed_prio")..[[onclick="OnClickVlan()">
<label for="uiVlanCheck">{?881:375?}</label>
</div>
<div class="formular" id="uiVlanDiv">
<label for="uiVlanInput">{?881:534?}</label>
<input type="text" name="vlaninput" id="uiVlanInput" maxlength="4" value="]]..box.tohtml(box.query("connection_voip:settings/vlanid"))..[[">
</div>
</div>
<div class="formular">
<input type="checkbox" id="uiUseVcc" name="usevcc" onclick="OnClickUseVcc()"]]..is_checked(box.query("connection_voip:settings/use_seperate_vcc") == "1")..[[>
<label for="uiUseVcc">{?881:393?}</label>
<div class="formular" id="ExpertMode"]]
str_html = str_html..[[>
<p>{?881:824?}</p>
<input type="radio" name="encmode" id="uiPpp" value="isPPP"]]..is_checked(string.sub(g_pppencaps, 10,12) == "ppp")..[[onclick="OnClickPpp()">
<label for="uiPpp"> {?881:557?}</label>
<br>
<input type="radio" name="encmode" id="uiIp" value="isIP"]]..is_checked(string.sub(g_pppencaps, 10,12) ~= "ppp")..[[onclick="OnClickIp()">
<label for="uiIp"> {?881:600?}</label>
<div id="uiPppLogin">
<label for="uiUsername">{?txtUsername?}</label>
<input type="text" id="uiUsername" value="]]..box.tohtml(box.query("connection_voip:settings/username"))..[[" name="username" maxlength="128" >
<br>
<label for="uiPassword">{?txtKennwort?}</label>
<input type="text" id="uiPassword" value="]]..box.tohtml(box.query("connection_voip:settings/password"))..[[" name="password" maxlength="128" onfocus="uiSelect(id);" autocomplete="off">
</div>
<div>
<p>{?881:182?}</p>
<label for="uiVPI" >{?881:6378?}</label><input type="text" maxlength="3" value="]]..box.tohtml(box.query("connection_voip:settings/VPI"))..[[" id="uiVPI" name="vpi">
<br>
<label for="uiVCI">{?881:819?}</label><input type="text" maxlength="5" value="]]..box.tohtml(box.query("connection_voip:settings/VCI"))..[[" id="uiVCI" name="vci">
</div>
<div>
<div><p>{?881:650?}</p>
<div class="formular" id="uiPppEncaps">
<input type="radio" name="PppEncaps" id="uiPPPoE" onclick="setPppTypeNotCheck()" value="dslencap_pppoe" ]]..is_checked(g_pppencaps == "dslencap_pppoe")..[[>
<label for="uiPPPoE">{?881:857?} </label>
<br>
<input type="radio" name="PppEncaps" id="uiPPPoA1" onclick="setPppTypeNotCheck()" value="dslencap_pppoa_llc" ]]..is_checked(g_pppencaps == "dslencap_pppoa_llc")..[[>
<label for="uiPPPoA1">{?881:873?} </label>
<br>
<input type="radio" name="PppEncaps" id="uiPPPoA2" onclick="setPppTypeNotCheck()" value="dslencap_pppoa" ]]..is_checked(g_pppencaps == "dslencap_pppoa")..[[>
<label for="uiPPPoA2">{?881:918?} </label>
</div>
<div class="formular" id="uiIpEncaps">
<input type="radio" onclick="uiDoIpEncaps()" value="dslencap_ether"]]..is_checked(g_pppencaps == "dslencap_ether")..[[ name="DslIpEncaps" id="uiIpEncaps1">
<label for="uiIpEncaps1">{?881:51?}</label>
<div class="formular"><input type="checkbox" onclick="uiDoUseDhcp(this.checked)"]]..is_checked(box.query("connection_voip:settings/use_dhcp") == "1") ..[[ id="uiUseDhcp" name="usedhcp">
<label for="uiUseDhcp">{?881:981?}</label></div>
<input type="radio" onclick="uiDoIpEncaps()" value="dslencap_ipnlpid"]]..is_checked(g_pppencaps == "dslencap_ipnlpid")..[[ name="DslIpEncaps" id="uiIpEncaps2">
<label for="uiIpEncaps2">{?881:353?}</label>
<br>
<input type="radio" onclick="uiDoIpEncaps()" value="dslencap_ipsnap"]]..is_checked(g_pppencaps == "dslencap_ipsnap")..[[name="DslIpEncaps" id="uiIpEncaps3">
<label for="uiIpEncaps3">{?881:884?}</label>
<br>
<input type="radio" onclick="uiDoIpEncaps()" value="dslencap_ipraw"]]..is_checked(g_pppencaps == "dslencap_ipraw")..[[name="DslIpEncaps" id="uiIpEncaps4">
<label for="uiIpEncaps4">{?881:805?}</label>
<br>
<div class="formular" id="dRFC">
<div id="ipbox">
<label for="uiIpaddr0">{?881:556?}</label>
<input type="text" size="3" maxlength="3" id="uiIpaddr1" name="ipaddr1" value="]]..box.tohtml(g_ipaddr[2])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr0" name="ipaddr0" value="]]..box.tohtml(g_ipaddr[1])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr2" name="ipaddr2" value="]]..box.tohtml(g_ipaddr[3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiIpaddr3" name="ipaddr3" value="]]..box.tohtml(g_ipaddr[4])..[[" />
</div>
<div id="netmaskbox">
<label for="uiNetmask0">{?881:365?}</label>
<input type="text" size="3" maxlength="3" id="uiNetmask0" name="netmask0" value="]]..box.tohtml(g_netmask[1])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiNetmask1" name="netmask1" value="]]..box.tohtml(g_netmask[2])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiNetmask2" name="netmask2" value="]]..box.tohtml(g_netmask[3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiNetmask3" name="netmask3" value="]]..box.tohtml(g_netmask[4])..[[" />
</div>
<div id="gatewaybox">
<label for="uiGateway0">{?881:354?}</label>
<input type="text" size="3" maxlength="3" id="uiGateway0" name="gateway0" value="]]..box.tohtml(g_gateway[1])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiGateway1" name="gateway1" value="]]..box.tohtml(g_gateway[2])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiGateway2" name="gateway2" value="]]..box.tohtml(g_gateway[3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiGateway3" name="gateway3" value="]]..box.tohtml(g_gateway[4])..[[" />
</div>
<div id="dns0box">
<label for="uiDns00">{?881:948?}</label>
<input type="text" size="3" maxlength="3" id="uiDns00" name="dns00" value="]]..box.tohtml(g_dns0[1])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns01" name="dns01" value="]]..box.tohtml(g_dns0[2])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns02" name="dns02" value="]]..box.tohtml(g_dns0[3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns03" name="dns03" value="]]..box.tohtml(g_dns0[4])..[[" />
</div>
<div id="dns1box">
<label for="uiDns10">{?881:9463?}</label>
<input type="text" size="3" maxlength="3" id="uiDns10" name="dns10" value="]]..box.tohtml(g_dns1[1])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns11" name="dns11" value="]]..box.tohtml(g_dns1[2])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns12" name="dns12" value="]]..box.tohtml(g_dns1[3])..[[" /> .
<input type="text" size="3" maxlength="3" id="uiDns13" name="dns13" value="]]..box.tohtml(g_dns1[4])..[[" />
</div>
</div>
</div>
</div>
</div>
</div>
</div>
]]
end
end
if ata_or_lte_set__hide() then
str_html = str_html..[[
<div class="formular">
<input type="checkbox" id="uiSipping"]]..is_checked(g_sipping_enabled == "1")..[[name ="sipping" onclick="OnSipping()">
<label for="uiSipping">{?881:906?}</label>
<p>
{?881:109?}
</p>
<div class="formular">
<label for="uiSippingTimer" name="sipping_timer">{?881:390?}</label>
<select id="uiSippingTimer" name="sipping_timer" >
<option value="280"]]
if g_sipping_interval == "280" then
str_html = str_html..[[selected = "selected"]]
end
str_html = str_html..[[> {?881:291?}</option>
<option value="120"]]
if g_sipping_interval == "120" then
str_html = str_html..[[selected = "selected"]]
end
str_html = str_html..[[> {?881:482?}</option>
<option value="60"]]
if g_sipping_interval == "60" then
str_html = str_html..[[selected = "selected"]]
end
str_html = str_html..[[> {?881:685?}</option>
<option value="30"]]
if g_sipping_interval == "30" then
str_html = str_html..[[selected = "selected"]]
end
str_html = str_html..[[> {?881:267?}</option>
</select></p>
</div>
</div>]]
end
if g_errormsg ~= nil then
str_html = str_html..[[<div>]]..g_errormsg..[[</div>]]
end
str_html = str_html..[[<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">]]
return str_html
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<style type="text/css">
.formular span{
width: 200px;
margin-right: 2px;
vertical-align: middle;
display: inline-block;
}
.input55{
width: 55px;
}
.input75{
width: 75px;
}
</style>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua box.out(get_out_html()) ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
var g_pppTypeNotCheck = true;
var g_ipTypeNotCheck = true;
function OnClickUseVcc()
{
jxl.disableNode("ExpertMode", !jxl.getChecked("uiUseVcc"));
jxl.display("ExpertMode", jxl.getChecked("uiUseVcc"));
}
function OnClickPpp()
{
ShowParams(true)
jxl.setChecked("uiPpp","isPPP")
if(<?lua box.out(string.sub(g_pppencaps, 10,12) ~= "ppp")?> && g_pppTypeNotCheck)
{
jxl.setChecked("uiPPPoE","PPPoE");
}
}
function OnClickIp()
{
ShowParams(false)
jxl.setChecked("uiIp","isIP")
if(<?lua box.out(string.sub(g_pppencaps, 10,12) == "ppp")?> && g_ipTypeNotCheck)
{
jxl.setChecked("uiIpEncaps1","IpEncaps1");
}
}
function setPppTypeNotCheck()
{
g_pppTypeNotCheck = false;
}
/* akt-deaktiviert IP-Adresse automatisch über DHCP*/
function uiDoUseDhcp()
{
jxl.disableNode("dRFC", jxl.getChecked("uiUseDhcp"));
}
function uiDoIpEncaps()
{
jxl.setDisabled("uiUseDhcp",!jxl.getChecked("uiIpEncaps1"));
if( jxl.getChecked("uiUseDhcp") && jxl.getChecked("uiIpEncaps1"))
{
uiDoUseDhcp(true);
}
else
{
uiDoUseDhcp(false);
jxl.setChecked("uiUseDhcp",false)
g_ipTypeNotCheck = false;
}
}
function OnChangeSourcePort()
{
jxl.setDisabled(jxl.getChecked("uiSipSourcePort"));
}
function OnSipping()
{
jxl.setDisabled("uiSippingTimer",!jxl.getChecked("uiSipping"));
}
function OnClickUsePdn2()
{
OnClickApnauth();
jxl.disableNode("uiApnInputBox", !jxl.getChecked("uiUsePdn2"));
}
function OnClickApnauth()
{
jxl.disableNode("uiApnauthValues", !jxl.getChecked("uiApnauth"));
}
function ShowParams(ppp)
{
jxl.display("uiPppLogin",ppp);
jxl.display("uiPppEncaps",ppp);
jxl.display("uiIpEncaps",!ppp);
}
function OnClickVlan ()
{
jxl.setDisabled("uiVlanInput",!jxl.getChecked("uiVlanCheck"));
jxl.display("uiVlanDiv", jxl.getChecked("uiVlanCheck"));
}
function OnChangeCountry(n)
{
var Countries = <?lua box.out(js.table(g_countrytable)) ?>;
for (var i = 0; i < Countries.length; i++)
{
if (Countries[i].code == n)
{
jxl.setValue("uiOKZPrefix",Countries[i].areacode_prefix);
jxl.setValue("uiLKZPrefix","00");
jxl.setValue("uiLKZ",Countries[i].code);
break;
}
}
}
function init() {
OnClickUseVcc();
ShowParams("ppp" == "<?lua box.out(g_pppencaps) ?>".substr(9,3));
uiDoIpEncaps();
OnSipping();
OnClickVlan();
jxl.disableNode("uiFaxSwitchDiv", !jxl.getChecked("uiFixNetwork"));
}
function OnCheckFixNetwork(checked)
{
if(!checked)
{
if(!confirm("{?881:356?}"))
{
return false;
}
}
else
{
if(!confirm("{?881:2426?}"))
{
return false;
}
}
jxl.disableNode("uiFaxSwitchDiv", !checked);
return true;
}
function onMohUpload() {
var str = "<?lua box.out(box.js(box.glob.script))?>?back_to_page=/fon_num/sip_option.lua";
storeCookie("backtopage", str, 1);
window.location.href = 'moh_upload.lua?sid=<?lua box.js(box.glob.sid) ?>';
}
ready.onReady(ajaxValidation({
applyNames: "apply"
}));
ready.onReady(init) ;
</script>
<?include "templates/html_end.html" ?>
