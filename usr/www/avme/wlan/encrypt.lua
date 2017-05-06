<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require("http")
require("href")
require("menu")
if not menu.check_page("wlan", [[/wlan/encrypt.lua]]) then
http.redirect(href.get([[/home/home.lua]]))
box.end_page()
end
require("general")
require("config")
require("cmtable")
require("val")
require("ip")
require("net_devices")
g_back_to_page = http.get_back_to_page( "/wlan/encrypt.lua" )
g_expertmode =(box.query("box:settings/expertmode/activated")=="1")
g_is_repeater=false
if config.GUI_IS_REPEATER then
g_is_repeater=true
end
g_rep_mode=general.get_bridge_mode()
g_dev = {}
g_dev.opmode = ""
g_dev.wlan_count = 0
g_err = 0
g_errmsg = nil
g_val_wep={}
if not g_is_repeater or (g_is_repeater and g_rep_mode=="wlan_bridge") then
g_val = {
prog = [[
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
end
]]
}
if config.WLAN.has_security_wep_support then
g_val.prog = g_val.prog..[[
if __radio_check(uiSecLevelWep/SecLevel,wep) then
not_empty(uiViewWepvalue/wepvalue, wep_key_error_txt)
if __value_equal(uiViewWEPType/wep_type,64) then
length(uiViewWepvalue/wepvalue, 5, 5, wep_key_error_txt_64)
end
if __value_equal(uiViewWEPType/wep_type,128) then
length(uiViewWepvalue/wepvalue, 13, 13, wep_key_error_txt_128)
end
char_range(uiViewWepvalue/wepvalue, 32, 126, wep_key_error_txt)
end
]]
end
g_val.prog = g_val.prog..[[
if __radio_check(uiSecLevelNone/SecLevel,none) then
end
]]
else
g_val = {
prog = [[
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
end
if __radio_check(uiSecLevelNone/SecLevel,none) then
end
]]
}
end
if (g_expertmode) then
if not g_is_repeater or (g_is_repeater and g_rep_mode=="wlan_bridge") then
g_val = {
prog = [[
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
end
]]
}
if config.WLAN.has_security_wep_support then
g_val.prog = g_val.prog..[[
if __radio_check(uiSecLevelWep/SecLevel,wep) then
not_all_empty(uiWephexvalue/wephexvalue,5,wep_key_error_txt)
if __value_equal(uiViewWEPType/wep_type,64) then
length(uiWephexvalue1/wephexvalue1, 10, 10, empty_allowed, wep_key_error_txt_64_Exp)
length(uiWephexvalue2/wephexvalue2, 10, 10, empty_allowed, wep_key_error_txt_64_Exp)
length(uiWephexvalue3/wephexvalue3, 10, 10, empty_allowed, wep_key_error_txt_64_Exp)
length(uiWephexvalue4/wephexvalue4, 10, 10, empty_allowed, wep_key_error_txt_64_Exp)
end
if __value_equal(uiViewWEPType/wep_type,128) then
length(uiWephexvalue1/wephexvalue1, 26, 26, empty_allowed, wep_key_error_txt_128_Exp)
length(uiWephexvalue2/wephexvalue2, 26, 26, empty_allowed, wep_key_error_txt_128_Exp)
length(uiWephexvalue3/wephexvalue3, 26, 26, empty_allowed, wep_key_error_txt_128_Exp)
length(uiWephexvalue4/wephexvalue4, 26, 26, empty_allowed, wep_key_error_txt_128_Exp)
end
char_range_regex(uiWephexvalue1/wephexvalue1, hexvalue, wep_key_error_txt)
char_range_regex(uiWephexvalue2/wephexvalue2, hexvalue, wep_key_error_txt)
char_range_regex(uiWephexvalue3/wephexvalue3, hexvalue, wep_key_error_txt)
char_range_regex(uiWephexvalue4/wephexvalue4, hexvalue, wep_key_error_txt)
end
]]
end
g_val.prog = g_val.prog..[[
if __radio_check(uiSecLevelNone/SecLevel,none) then
end
]]
else
g_val = {
prog = [[
if __radio_check(uiSecLevelWpa/SecLevel,wpa) then
not_empty(uiViewpskvalue/pskvalue, wpa_key_error_txt)
length(uiViewpskvalue/pskvalue, 8, 63, wpa_key_error_txt)
char_range(uiViewpskvalue/pskvalue, 32, 126, wpa_key_error_txt)
no_lead_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
no_end_char(uiViewpskvalue/pskvalue,32,wpa_key_error_txt)
end
if __radio_check(uiSecLevelNone/SecLevel,none) then
end
]]
}
end
end
if config.WLAN.has_security_wep_support then
if box.post.calc_hex then
g_val_wep = {
prog = [[
not_empty(uiViewAscii/wepasciivalue, calc_key_error_txt)
if __value_equal(uiViewWEPType/wep_type,64) then
length(uiViewAscii/wepasciivalue, 5, 5, calc_key_error_txt)
end
if __value_equal(uiViewWEPType/wep_type,128) then
length(uiViewAscii/wepasciivalue, 13, 13, calc_key_error_txt)
end
char_range_regex(uiViewAscii/wepasciivalue, wepascii, calc_key_error_txt)
]]
}
end
end
val.msg.wpa_key_error_txt = {
[val.ret.empty] = [[{?1963:387?}]],
[val.ret.toolong] = [[{?1963:731?}]],
[val.ret.tooshort] = [[{?1963:4443?}]],
[val.ret.outofrange] = [[{?1963:131?}]],
[val.ret.leadchar] = [[{?1963:280?}]],
[val.ret.endchar] = [[{?1963:729?}]]
}
val.msg.wep_key_error_txt = {
[val.ret.empty] = [[{?1963:475?}]],
[val.ret.outofrange] = [[{?1963:622?}]]
}
val.msg.wep_key_error_txt_128 = {
[val.ret.toolong] = [[{?1963:311?}]],
[val.ret.tooshort] = [[{?1963:158?}]]
}
val.msg.wep_key_error_txt_64 = {
[val.ret.toolong] = [[{?1963:529?}]],
[val.ret.tooshort] = [[{?1963:956?}]]
}
val.msg.wep_key_error_txt_128_Exp = {
[val.ret.toolong] = [[{?1963:105?}]],
[val.ret.tooshort] = [[{?1963:9157?}]]
}
val.msg.wep_key_error_txt_64_Exp = {
[val.ret.toolong] = [[{?1963:497?}]],
[val.ret.tooshort] = [[{?1963:690?}]]
}
g_pskvalue =""
g_wep_value ={}
g_wep_len ={}
g_wep_type = "128"
g_wep_key_id ="0"
g_wep_share =""
g_wep_auth_type=""
g_wds_enabled =false
g_wds_encrypt ="none"
g_mini_enabled =false
g_CurrentEncrypt = "0"
g_CurrentSecLevel ="none"
g_is_double_wlan = false
g_isolation = "0"
g_macfilter = "0"
if config.WLAN.is_double_wlan then
g_is_double_wlan =true
end
g_stick_and_surf = "0"
function get_wds_encryption()
local encrypt=box.query("wlan:settings/WDS_encryption")
if (encrypt=="2" or encrypt=="3") then
return "wpa"
elseif (encrypt=="1") then
return "wep"
end
return "none"
end
function get_wpa_encryption()
local encrypt=g_CurrentEncrypt
if (encrypt=="2") then
return "wpa"
elseif (encrypt=="3") then
return "wpa2"
elseif (encrypt=="4") then
return "wpamixed"
end
return ""
end
function get_seclevel(CurrentEncrypt)
return net_devices.convert_num_to_enc(CurrentEncrypt)
end
function get_encryption(seclevel)
return net_devices.convert_enc_to_num(seclevel)
end
function read_box_values()
g_CurrentEncrypt = box.query("wlan:settings/encryption")
g_CurrentSecLevel = get_seclevel(g_CurrentEncrypt)
g_pskvalue = box.query("wlan:settings/pskvalue")
g_wpa_type = get_wpa_encryption()
if config.WLAN.has_security_wep_support then
local keylen=""
for i=1,4,1 do
g_wep_value[i]=box.query('wlan:settings/key_value'..(i-1))
g_wep_len[i] =box.query('wlan:settings/key_len'..(i-1))
if (g_wep_len[i]~="" and g_wep_len[i]~="0") then
keylen=g_wep_len[i]
end
end
if (keylen=="") then
keylen="13"
end
g_wep_type="128"
if keylen=="5" then
g_wep_type="64"
end
g_wep_key_id = box.query("wlan:settings/key_id")
g_wep_auth_type = box.query("wlan:settings/wep_auth_type")
g_wep_share = (box.query("wlan:settings/allowSharedKeyAuth")=="1")
end
g_wds_enabled = (box.query("wlan:settings/WDS_enabled")=="1")
g_wds_encrypt = get_wds_encryption()
g_isolation = box.query("wlan:settings/user_isolation")
g_macfilter = box.query("wlan:settings/is_macfilter_active")
if config.MINI then
g_mini_enabled = (box.query("mini:settings/enabled")=="1")
end
g_stick_and_surf = box.query("ctlusb:settings/autoprov_enabled")
g_dev = net_devices.g_list
g_dev.macfilter = box.query("wlan:settings/is_macfilter_active")
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
end
function refill_user_input_from_post()
local seclevel=box.post.SecLevel
if (seclevel=="wpa") then
seclevel=box.post.wpa_type
end
g_CurrentSecLevel = seclevel
g_pskvalue = box.post.pskvalue
g_wpa_type = box.post.wpa_type
if config.WLAN.has_security_wep_support then
if (g_expertmode) then
for i=1,4,1 do
local value="wephexvalue"..i
g_wep_value[i] =box.post[value]
g_wep_len[i] =#box.post[value]/2
end
else
g_wephexkey=calc_hex_key(box.post.wepvalue)
for i=1,4,1 do
g_wep_value[i] =g_wephexkey
g_wep_len[i] =#g_wephexkey/2
end
end
g_wep_type = box.post.wep_type
g_wep_key_id = box.post.WepKey
g_wep_auth_type = box.query("wlan:settings/wep_auth_type")
g_wep_share = box.post.WepShared
end
g_wds_enabled = (box.query("wlan:settings/WDS_enabled")=="1")
g_wds_encrypt = get_wds_encryption()
g_isolation = "1"
if (box.post.isolate) then
g_isolation = "0"
end
g_macfilter = "0"
if (box.post.macfilter and box.post.macfilter=="close") then
g_macfilter = "1"
end
if config.MINI then
g_mini_enabled = (box.query("mini:settings/enabled")=="1")
end
g_stick_and_surf = "0"
if (box.post.stick_and_surf) then
g_stick_and_surf = "1"
end
g_dev = net_devices.g_list
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
end
function refill_user_input_from_get()
end
function calc_hex_key(key)
local res=""
if config.WLAN.has_security_wep_support then
local ascii_key = key or ""
for i=1,#ascii_key,1 do
res=res..string.format("%x",string.byte(ascii_key,i))
end
end
return res
end
function check_param(name)
local s=string.find(name,"_i$")
if (s) then
return false
end
if (name=="add_mac") then
return false
end
if (name=="macstr") then
return false
end
return true
end
if next(box.post) then
if box.post.validate == "apply" then
local valresult, answer = val.ajax_validate(g_val)
box.out(js.table(answer))
box.end_page()
end
if box.post.delete and box.post.delete~="" then
g_dev=net_devices.g_list
g_dev.macfilter = box.query("wlan:settings/is_macfilter_active")
g_dev.opmode = box.query("box:settings/opmode")
g_dev.wlan_count = tonumber(box.query("wlan:settings/wlanlist/count")) or 0
local idx,elem = net_devices.find_dev_by_uid(g_dev, box.post.delete)
if not elem then
idx,elem = net_devices.find_dev_by_node(g_dev, box.post.delete)
end
if not elem then
idx,elem = net_devices.find_dev_by_name(g_dev, box.post.delete)
end
if idx and elem and elem.type~="user" and elem.deleteable ~= "0" and
not (g_dev.macfilter=="1" and elem.wlan=="1" and g_dev.wlan_count<2) and
not (g_dev.macfilter=="0" and elem.wlan=="1" and elem.active=="1") then
local ctlmgr_del={}
cmtable.add_var(ctlmgr_del, "landevice:command/landevice["..elem.UID.."]" , "delete")
if elem.wlan=="1" and elem.wlan_node then
cmtable.add_var(ctlmgr_del, "wlan:command/"..elem.wlan_node , "delete")
end
local err,msg = box.set_config(ctlmgr_del)
if err ~= 0 then
local criterr = general.create_error_div(err,msg,[[{?1963:643?}]])
box.out(criterr)
end
net_devices.InitNetList()
refill_user_input_from_post()
end
elseif box.post.apply then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset = {}
if config.WLAN.has_security_wep_support then
if not g_is_repeater or (g_is_repeater and g_rep_mode=="wlan_bridge") then
if (g_expertmode) then
for i=1,4,1 do
local value="wephexvalue"..i
cmtable.add_var(saveset, "wlan:settings/key_value"..i-1,box.post[value])
cmtable.add_var(saveset, "wlan:settings/key_len"..i-1,#box.post[value]/2)
end
cmtable.add_var(saveset, "wlan:settings/key_id",box.post.WepKey)
else
g_wephexkey=calc_hex_key(box.post.wepvalue)
for i=1,4,1 do
local value="wepvalue"..i
cmtable.add_var(saveset, "wlan:settings/key_value"..i-1,g_wephexkey)
cmtable.add_var(saveset, "wlan:settings/key_len"..i-1,#g_wephexkey/2)
end
cmtable.add_var(saveset, "wlan:settings/key_id",0)
end
local shared="0"
if box.post.WepShared then
shared="1"
end
cmtable.add_var(saveset, "wlan:settings/allowSharedKeyAuth",shared)
end
end
seclevel=box.post.SecLevel
if (seclevel=="wpa") then
seclevel=box.post.wpa_type
end
cmtable.add_var(saveset, "wlan:settings/encryption",get_encryption(seclevel))
cmtable.add_var(saveset, "wlan:settings/pskvalue",box.post.pskvalue)
cmtable.save_checkbox(saveset, "wlan:settings/user_isolation", "isolate", "0", "1")
local macfilter = "0"
if (box.post.macfilter and box.post.macfilter=="close") then
macfilter = "1"
end
cmtable.add_var(saveset, "wlan:settings/is_macfilter_active", macfilter)
cmtable.save_checkbox(saveset, "ctlusb:settings/autoprov_enabled", "stick_and_surf")
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
else
refill_user_input_from_post()
end
else
refill_user_input_from_post()
end
elseif box.post.calc_hex then
refill_user_input_from_post()
if config.WLAN.has_security_wep_support then
local allowed_len=5
if g_wep_type=="128" then
allowed_len=13
end
local msgtxt= general.sprintf("{?1963:53?}",allowed_len)
val.msg.calc_key_error_txt = {
[val.ret.empty] = [[{?1963:340?}]],
[val.ret.toolong] = msgtxt,
[val.ret.tooshort] = msgtxt,
[val.ret.outofrange] = [[{?1963:538?}]]
}
local result=val.validate(g_val_wep)
if ( result== val.ret.ok) then
g_wephexkey=calc_hex_key(box.post.wepasciivalue)
local i=(tonumber(g_wep_key_id) or 0) + 1
g_wep_value[i]=g_wephexkey
g_wep_len[i] =#g_wephexkey/2
else
g_err=result
end
end
elseif box.post.add_mac or box.post.RedirAddMac then
local param = {}
local i=1
for k,v in pairs(box.post) do
if (check_param(k)) then
param[i] = http.url_param(k,v)
i=i+1
end
end
param[i]='back_to_page='..box.glob.script
target = "/wlan/add_by_mac.lua"
local str=href.get(target, unpack(param))
http.redirect(str)
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
elseif box.post.btn_refresh then
http.redirect(href.get(g_back_to_page,"refresh=1"))
else
read_box_values()
end
else
read_box_values()
end
g_page_help = "hilfe_wlan_wpa.html"
if (g_CurrentSecLevel=="none") then
g_page_help = "hilfe_wlan_sicherheit.html"
elseif (g_CurrentSecLevel=="wep") then
g_page_help = "hilfe_wlan_wep.html"
elseif (g_CurrentSecLevel=="wpa" or g_CurrentSecLevel=="wpa2" or g_CurrentSecLevel=="wpamixed") then
g_page_help = "hilfe_wlan_wpa.html"
end
g_new_device_by_mac=""
if box.get then
if box.get.macstr then
g_new_device_by_mac=box.get.macstr
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/wmac_add" , g_new_device_by_mac)
cmtable.add_var(saveset, "wlan:settings/is_macfilter_active" , "1")
local err=0
err, g_errmsg = box.set_config(saveset)
local param = {}
local i=1
for k,v in pairs(box.get) do
if (check_param(k)) then
param[i] = http.url_param(k,v)
i=i+1
end
end
param[i]='back_to_page='..box.glob.script
i=i+1
param[i]='load_again=1'
target = "/wlan/encrypt.lua"
local str=href.get(target, unpack(param))
http.redirect(str)
return
end
if box.get.load_again then
refill_user_input_from_get()
end
end
function get_seclevel_checked(seclevel)
local tmpseclevel=g_CurrentSecLevel
if (g_CurrentSecLevel=="wpa" or g_CurrentSecLevel=="wpa2" or g_CurrentSecLevel=="wpamixed") then
tmpseclevel="wpa"
end
if seclevel==tmpseclevel then
return [[checked="checked"]]
end
return ""
end
function get_pskvalue()
return g_pskvalue
end
function get_wep_shared()
if g_wep_share then
return [[checked="checked"]]
end
return ""
end
function get_wep_key(Id)
if config.WLAN.has_security_wep_support then
local idx=tonumber(Id) or 0
if (idx>0 and idx<5) then
return g_wep_value[idx]
end
end
return ""
end
function get_wep_key_len(Id)
if config.WLAN.has_security_wep_support then
local idx=tonumber(Id) or 0
if (idx>0 and idx<5) then
return (tonumber(g_wep_len[idx]) or 0) * 2
end
end
return ""
end
function write_wep_key_ascii(Id)
if config.WLAN.has_security_wep_support then
local idx=tonumber(Id) or 0
if (idx>0 and idx<5) then
box.html(net_devices.calc_ascii_key(g_wep_value[idx]))
end
end
end
function get_wep_key_checked(radioId)
if radioId==g_wep_key_id then
return [[checked="checked"]]
end
return ""
end
function get_selection_header()
if g_CurrentSecLevel=="wpa" or g_CurrentSecLevel=="wpa2" or g_CurrentSecLevel=="wpamixed" then
return "{?1963:420?}"
elseif g_CurrentSecLevel=="wep" then
return "{?1963:859?}"
end
return "{?1963:128?}"
end
function get_display_str_sec(seclevel)
local tempsec=g_CurrentSecLevel
if g_CurrentSecLevel=="wpa" or g_CurrentSecLevel=="wpa2" or g_CurrentSecLevel=="wpamixed" then
tempsec="wpa"
end
if tempsec==seclevel then
return ""
end
return "display:none;"
end
function get_display_str_wep(expertmode)
if (expertmode and not g_expertmode) then
return "display:none;"
end
if (not expertmode and g_expertmode) then
return "display:none;"
end
return ""
end
function write_err_class(ErrorPosition)
if (g_err==ErrorPosition) then
box.out([[class="error"]])
end
end
function write_max_length()
local allowed_len=5
if g_wep_type=="128" then
allowed_len=13
end
box.out(tostring(allowed_len))
end
function write_error(ErrorPosition)
if (g_err==ErrorPosition) then
box.out([[<p class="form_input_note ErrorMsg">]])
box.out(g_errmsg)
box.out([[</p>]])
end
end
function write_selected(wep_type)
if (g_wep_type==wep_type) then
box.out([[selected="y"]])
end
end
g_ExplainTxt=[[{?1963:755?}]]
function write_explain_length()
local maxDez,maxHex=5,10
if g_wep_type=="128" then
maxDez,maxHex=13,26
end
box.out(general.sprintf(g_ExplainTxt,maxDez,maxHex))
end
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
g_ExplainTxtNormal=[[{?1963:159?}]]
else
g_ExplainTxtNormal=[[{?1963:904?}]]
end
else
g_ExplainTxtNormal=[[{?1963:241?}]]
end
function write_explain_length_normal()
local maxDez=5
if g_wep_type=="128" then
maxDez=13
end
box.out(general.sprintf(g_ExplainTxtNormal,maxDez))
end
function write_wpa_seclevel(wpa_seclevel)
local tmplevel=g_wpa_type
if tmplevel~="wpa" and tmplevel~="wpa2" and tmplevel~="wpamixed" then
tmplevel="wpa2"
if config.WLAN.default_wpa_mixed then
tmplevel="wpamixed"
end
end
if tmplevel==wpa_seclevel then
box.out([[selected="selected"]])
end
end
function write_known_wlandevices()
box.out([[
<hr>
<div>
<h4>]]..box.tohtml([[{?1963:978?}]])..[[</h4>
</div>
<div id="uiKnownDevices">
]], get_Stick_And_Surf(), [[
<p><input type="checkbox" name="isolate" id="uiView_UserIsolation" ]])
write_isolation()
box.out([[>
<label for="uiView_UserIsolation">]])
box.html([[{?1963:670?}]])
box.out([[</label></p>
<h4>]])
box.html([[{?1963:698?}]])
box.out([[</h4>
<p>]])
local del_btn = "del_btn"
if config.GUI_IS_REPEATER then
if g_rep_mode=="wlan_bridge" then
del_btn = nil
end
if config.GUI_IS_POWERLINE then
box.html([[{?1963:693?}]])
else
box.html([[{?1963:733?}]])
end
else
box.html([[{?1963:306?}]])
end box.out([[
</p>]], net_devices.create_known_wlandevices_table("receive", "name", "mac", del_btn), [[
<div id="uiAccessControl" class="rightBtn formular">
<div>
<button type="submit" id="uiAddMac" name="add_mac">{?1963:190?}</button>
<button type="submit" name="btn_refresh" id="btnRefresh">{?txtRefresh?}</button>
</div>
<div class="left_block">
<br>
<br>
<p ><input type="radio" name="macfilter" id="uiViewOpen" value="open" onclick="OnChangeMacFilter(0,this.checked)" ]]) write_macfilter_active(0) box.out([[>&nbsp;<label for="uiViewOpen">{?1963:379?}</label></p>
<p ><input type="radio" name="macfilter" id="uiViewClose" value="close" onclick="OnChangeMacFilter(1,this.checked)" ]]) write_macfilter_active(1) box.out([[>&nbsp;<label for="uiViewClose">{?1963:174?}</label></p>
</div>
</div>
<div class="clear_float"></div>
</div>
]])
end
function get_expert_features()
if config.GUI_IS_REPEATER then
return [[]]
else
if (not general.is_expert()) then
return [[display:none]]
end
return [[]]
end
end
function write_expert_features()
box.out(get_expert_features())
end
function write_isolation()
if g_isolation == "0" then
box.out([[checked]])
end
end
function write_macfilter_active(radioBtn)
if g_macfilter~="1" and radioBtn==0 then
box.out([[checked]])
end
if g_macfilter=="1" and radioBtn==1 then
box.out([[checked]])
end
end
function get_Stick_And_Surf()
local checked = ""
if g_stick_and_surf == "1" then
checked = [[ checked]]
end
return [[
<input type="checkbox" id="uiViewStickandSurf" name="stick_and_surf" ]]..checked..[[>&nbsp;<label for="uiViewStickandSurf">{?1963:235?}</label>
<br>]]
end
function init()
if (g_new_device_by_mac~="") then
net_devices.check_and_add(g_dev, g_new_device_by_mac)
end
if (g_dev) then
table.sort(g_dev, net_devices.compareByQuality)
end
end
init()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiViewpskvalue {
width:180px;
}
.rightBtn input {
width: 190px;
float:right;
}
.formular span.form_input_note {
margin-left:10px;
}
.formular label {
width:200px;
}
.formular input[type="radio"]+label {
width:180px;
}
.rightBtn .left_block {
text-align: left;
float:none;
}
.rightBtn .left_block p{
text-align: left;
}
.formular .left_block input[type="radio"]+label {
width:auto;
}
.rightBtn .left_block input{
width:auto;
float:none;
}
</style>
<!--[if IE]>
<style type="text/css">
.formular input[type="radio"]+label {
width:175px;
}
</style>
<![endif]-->
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<div id="uiViewAll" style="">
<div id="uiWlanSecurity" style="">
<p>{?1963:10?}</p>
<div class="formular grid">
<div>
<input type="radio" onclick="uiDoSecLevel('wpa')" name="SecLevel" value="wpa" id="uiSecLevelWpa" <?lua box.out(get_seclevel_checked('wpa')) ?>>&nbsp;<label for="uiSecLevelWpa">{?1963:770?}</label>
<span >{?1963:196?}</span>
</div>
<?lua
if config.WLAN.has_security_wep_support then
if not g_is_repeater or (g_is_repeater and g_rep_mode=="wlan_bridge") then
box.out([[
<div>
<input type="radio" onclick="uiDoSecLevel('wep')" name="SecLevel" value="wep" id="uiSecLevelWep" ]]..get_seclevel_checked('wep')..[[ >&nbsp;<label for="uiSecLevelWep">{?1963:33?}</label>
<span >{?1963:783?}</span>
</div>
]])
end
end
?>
<div>
<input type="radio" onclick="uiDoSecLevel('none')" name="SecLevel" value="none" id="uiSecLevelNone" <?lua box.out(get_seclevel_checked('none')) ?>>&nbsp;<label for="uiSecLevelNone">{?1963:821?}</label>
<span>{?1963:976?}</span>
</div>
</div>
<div class="blue_separator_back">
<h2 id="uiViewSelectionHeader"><?lua box.out(get_selection_header()) ?></h2>
</div>
<div id="uiSecLevelWpaDiv" style="<?lua box.out(get_display_str_sec('wpa')) ?>">
<p>
{?1963:564?}
</p>
<div class="formular">
<p>
<label for="uiViewWPAType">{?1963:357?}</label>
<select id="uiViewWPAType" name="wpa_type" onchange="OnChangeWpa(this.value)">
<option value="wpa" <?lua write_wpa_seclevel("wpa")?>>{?1963:683?}</option>
<option value="wpa2" <?lua write_wpa_seclevel("wpa2")?>>{?1963:676?}</option>
<option value="wpamixed" <?lua write_wpa_seclevel("wpamixed")?>>{?1963:316?}</option>
</select>
</p>
<p>
<label for="uiViewpskvalue">{?1963:283?}</label>
<input type="text" size="25" maxlength="63" name="pskvalue" id="uiViewpskvalue" value="<?lua box.html(get_pskvalue()) ?>">
<?lua val.write_html_msg(g_val, [[uiViewpskvalue]]) ?>
</p>
</div>
<?lua
if g_mini_enabled and g_CurrentSecLevel=="wpa2" then
box.out([[<div class="ErrorMsg">]])
box.out([[{?1963:881?}]])
box.out([[</div>]])
end
?>
</div>
<div id="uiSecLevelWepDiv" style="<?lua if config.WLAN.has_security_wep_support then box.out(get_display_str_sec('wep')) else box.out('display:none;') end?>">
<p class="WarnMsgBold" style="">{?1963:493?}</p>
<p>{?1963:15?}</p>
<p>{?1963:208?}</p>
<hr>
<p>{?1963:375?}</p>
<p>{?1963:347?}</p>
<div class="formular grid">
<label for="uiViewWEPType">{?1963:138?}</label>
<select id="uiViewWEPType" name="wep_type" onchange="OnChangeWep(this.value)">
<option value="128" <?lua write_selected("128") ?>>{?1963:706?}</option>
<option value="64" <?lua write_selected("64") ?>>{?1963:320?}</option>
</select>
</div>
<div id="uiWepExpert" style="<?lua box.out(get_display_str_wep(true)) ?>">
<p>{?1963:152?}</p>
<p id="uiExplainLength"><?lua write_explain_length()?></p>
<div class="formular grid">
<div class="rightBtn">
<input type="submit" id="uiIdCalc" name="calc_hex" value="{?1963:938?}" >
</div>
<label for="uiViewAscii">{?1963:815?}:</label>
<input type="text" maxlength="<?lua write_max_length()?>" name="wepasciivalue" value="<?lua write_wep_key_ascii((tonumber(g_wep_key_id) or 0)+1)?>" id="uiViewAscii" <?lua val.write_attrs(g_val_wep, 'uiViewAscii')?>>
<div id="uiErrMsg">
<?lua
val.write_html_msg(g_val_wep, "uiViewAscii")
?>
</div>
</div>
<p>{?1963:814?}</p>
<div class="formular grid">
<div>
<input type="radio" onclick="uiDoWepKey('0')" name="WepKey" value="0" id="uiWepKey1" <?lua box.out(get_wep_key_checked('0')) ?>>
<label for="uiWepKey1">{?1963:611?}</label>
<input type="text" maxlength="26" name="wephexvalue1" value="<?lua box.html(get_wep_key('1')) ?>" id="uiWephexvalue1">
</div>
<div>
<input type="radio" onclick="uiDoWepKey('1')" name="WepKey" value="1" id="uiWepKey2" <?lua box.out(get_wep_key_checked('1')) ?>>
<label for="uiWepKey2">{?1963:719?}</label>
<input type="text" maxlength="26" name="wephexvalue2" value="<?lua box.html(get_wep_key('2')) ?>" id="uiWephexvalue2">
</div>
<div>
<input type="radio" onclick="uiDoWepKey('2')" name="WepKey" value="2" id="uiWepKey3" <?lua box.out(get_wep_key_checked('2')) ?>>
<label for="uiWepKey3">{?1963:734?}</label>
<input type="text" maxlength="26" name="wephexvalue3" value="<?lua box.html(get_wep_key('3')) ?>" id="uiWephexvalue3">
</div>
<div>
<input type="radio" onclick="uiDoWepKey('3')" name="WepKey" value="3" id="uiWepKey4" <?lua box.out(get_wep_key_checked('3')) ?>>
<label for="uiWepKey4">{?1963:996?}</label>
<input type="text" maxlength="26" name="wephexvalue4" value="<?lua box.html(get_wep_key('4')) ?>" id="uiWephexvalue4">
</div>
</div>
<p>{?1963:895?}</p>
<div class="formular">
<input type="checkbox" onclick="return uiOnChangeShared(this.checked);" id="uiViewWepShared" name="WepShared" <?lua box.out(get_wep_shared())?>>
<label for="uiViewWepShared">{?1963:251?}</label>
</div>
</div>
<div id="uiWepNonExpert" style="<?lua box.out(get_display_str_wep(false)) ?>">
<p id="uiExplainLengthNormal" >
<?lua write_explain_length_normal() ?>
</p>
<div class="formular">
<label for="uiViewWepvalue">{?1963:605?}</label>
<input type="text" maxlength="<?lua write_max_length()?>" name="wepvalue" value="<?lua write_wep_key_ascii((tonumber(g_wep_key_id) or 0) + 1)?>" id="uiViewWepvalue">
</div>
</div>
<?lua
if g_mini_enabled then
box.out([[<div class="ErrorMsg">]])
box.out([[{?1963:582?}]])
box.out([[</div>]])
end
?>
</div>
<div id="uiSecLevelNoneDiv" style="<?lua box.out(get_display_str_sec('none'))?>">
<p class="WarnMsgBold" style="">{?1963:43?}</p>
<p >{?1963:134?}</p>
<p >{?1963:118?}
<?lua
if g_mini_enabled then
box.out([[<div class="ErrorMsg">]])
box.out([[{?1963:829?}]])
box.out([[</div>]])
end
?>
</div>
</div>
</div>
<?lua
write_known_wlandevices()
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua net_devices.write_printpreview_btn() ?>
<button type="submit" id="uiApply" name="apply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
var g_CurrentMode ="<?lua box.out(g_CurrentMode) ?>";
var g_isDoubleWlan =<?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_seclevel ="<?lua box.js(g_CurrentSecLevel) ?>";
var g_wep_type ="<?lua box.js(g_wep_type) ?>";
var g_expertmode =<?lua box.out(tostring(g_expertmode)) ?>;
var g_wdsEncrypt ="<?lua box.out(get_wds_encryption()) ?>";
var g_wdsActive ="<?lua box.js(box.query('wlan:settings/WDS_enabled')) ?>";
var sort=sorter();
function init()
{
createPasswordChecker( "uiViewpskvalue", 8 );
jxl.disable("uiIdRenewList");
jxl.disable("uiIdShowMac");
jxl.show("uiCountKeyWpa");
jxl.show("uiCountKeyWep");
<?lua
if g_err==1 then
box.out([[val.markError("uiViewAscii");]])
end
if box.query("wlan:settings/ap_enabled") == "1" or box.query("wlan:settings/ap_enabled_scnd") == "1" then
box.out([[jxl.setDisabled("uiAddMac",(!jxl.getChecked("uiViewClose")));]])
end
?>
init_Wep(g_wep_type);
}
function uiDoOnMainFormSubmit()
{
if (g_wdsActive=="1" && g_wdsEncrypt=="wep" && g_seclevel=="wep" && g_wep_type=="64")
{
var wdsMsg="{?1963:488?}\x0d\x0a{?1963:388?}";
alert(wdsMsg);
return false;
}
if (jxl.getChecked("uiViewClose") && "<?lua write_macfilter_active(0) ?>"=="checked")
{
var msg = "{?1963:184?}";
alert(msg);
return true;
}
if (g_seclevel!="none")
{
showPrintView(getPopupParams());
}
return true;
}
function CalcHexKey(ascii_key)
{
var hexString = "";
for (var i = 0; i < ascii_key.length; i += 1) {
var asciiValue = ascii_key.charCodeAt(i);
var hexValue = asciiValue.toString(16);
hexString += hexValue.toUpperCase();
}
return hexString;
}
function OnChangeWpa(mode)
{
g_seclevel=mode;
return true;
}
function init_Wep(wep_type)
{
var obj;
var maxDez;
var maxHex;
maxHex=10;
if (wep_type=="128")
maxHex=26;
if (wep_type!=g_wep_type)
{
g_wep_type=wep_type;
for(var i=1;i<5;i++)
{
jxl.setValue("uiWephexvalue"+i,"");
jxl.setText("uiWephexvalueCount"+i,"0");
}
jxl.setValue("uiViewAscii","");
jxl.setValue("uiViewWepvalue","");
jxl.setText("uiDezKeyAscii","0");
jxl.setText("uiDezKeyWep","0");
}
maxDez=5;
if (g_wep_type=="128")
maxDez=13;
obj=jxl.get("uiViewAscii");
if (obj)
obj.maxLength = maxDez;
obj=jxl.get("uiViewWepvalue");
if (obj)
obj.maxLength = maxDez;
for(var i=1;i<5;i++)
{
obj=jxl.get("uiWephexvalue"+i);
if (obj)
obj.maxLength = maxHex;
}
jxl.setHtml("uiExplainLength",jxl.sprintf("<?lua box.out(g_ExplainTxt)?>",maxDez,maxHex));
jxl.setHtml("uiExplainLengthNormal",jxl.sprintf("<?lua box.out(g_ExplainTxtNormal)?>",maxDez));
uiOnChangeInput(jxl.getValue("uiViewAscii"),'uiDezKeyAscii')
uiOnChangeInput(jxl.getValue("uiViewWepvalue"),'uiDezKeyWep')
return true;
}
function OnChangeWep(wep_type)
{
init_Wep(wep_type);
if (jxl.hasClass("uiViewAscii", "error"))
{
jxl.display("uiErrMsg",false);
jxl.removeClass("uiViewAscii", "error");
}
return true;
}
function uiDoSecLevel(SecLevel)
{
var ViewWpa=false;
var ViewWep=false;
var ViewNone=false;
g_seclevel=SecLevel;
var subtitle="";
switch (SecLevel)
{
case "wpa2":
case "wpamixed":
case "wpa":
g_seclevel=jxl.getValue("uiViewWPAType");
ViewWpa=true;
subtitle="{?1963:74?}";
break;
case "wep":
ViewWep=true;
subtitle="{?1963:370?}";
break;
case "none":
ViewNone=true;
subtitle="{?1963:877?}";
break;
}
jxl.setText("uiViewSelectionHeader",subtitle);
jxl.display("uiSecLevelWpaDiv",ViewWpa);
jxl.display("uiSecLevelWepDiv",ViewWep);
jxl.display("uiSecLevelNoneDiv",ViewNone);
ChangeHelp(SecLevel);
}
function ChangeHelp(SecLevel)
{
var HelpLink=""
if (SecLevel=="none") {
HelpLink='<?lua href.help_write("hilfe_wlan_sicherheit.html")?>';
} else if (SecLevel=="wep") {
HelpLink='<?lua href.help_write("hilfe_wlan_wep.html")?>';
} else if (SecLevel=="wpa" || SecLevel=="wpa2" ||SecLevel=="wpamixed") {
HelpLink='<?lua href.help_write("hilfe_wlan_wpa.html")?>';
} else {
HelpLink='<?lua href.help_write("hilfe_wlan_wpa.html")?>';
}
var HelpBtn=jxl.get("uiHelpBtn")
if (HelpBtn)
{
HelpBtn.onclick=function (){help.popup(HelpLink)};
}
}
var g_wep_key_id = <?lua box.js(tostring(g_wep_key_id)) ?>;
function uiDoWepKey(id)
{
g_wep_key_id = id;
return true;
}
function uiOnChangeInput(value,id)
{
jxl.setText(id,value.length);
}
function OnChangeMacFilter(which,checked)
{
var g_any_wlan =<?lua box.out(net_devices.AnyWlanDevice(net_devices.g_list))?>;
jxl.setDisabled("uiAddMac",!(which==1 && checked));
if (which==1 && checked && !g_any_wlan)
{
var msg="{?1963:297?}";
alert(msg);
jxl.enable("uiAddMac");
jxl.get('uiAddMac').click();
}
return true;
}
function getPopupParams()
{
var encryption = "4";
if (g_seclevel == "wpa2")
encryption = "3";
if (g_seclevel == "wpa")
encryption = "2";
if (g_seclevel == "wep")
encryption = "1";
else if (g_seclevel == "none")
encryption = "0";
var paramObj = {
pskvalue: jxl.getValue("uiViewpskvalue"),
encryption: encryption
}
if (g_expertmode) {
paramObj.key_id = g_wep_key_id;
paramObj.key_value = jxl.getValue("uiWephexvalue" + paramObj.key_id);
}
else {
paramObj.wep_ascii_key = jxl.getValue("uiViewWepvalue");
}
return jxl.getParams(paramObj);
}
function checkWlanDelete(devType, wlan, deleteable, devName, active, wdsRepeater, kisi)
{
if (wdsRepeater=="1" && active=="1")
{
alert('{?1963:23?}');
return false;
}
if (wlan=="1" && <?lua box.out(tostring(g_macfilter=="1")) ?> && <?lua box.out(tostring(g_dev.wlan_count<2)) ?>)
{
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[alert('{?1963:415?}');]])
else
box.out([[alert('{?1963:70?}');]])
end
else
box.out([[alert('{?1963:172?}');]])
end
?>
return false;
}
if (<?lua box.out(tostring(g_macfilter=="0")) ?> && wlan=="1" && active=="1")
{
alert("{?1963:748?}");
return false;
}
if (wlan=="1" && "<?lua box.out(g_macfilter=='1') ?>")
{
if (!confirm("{?1963:407?}"))
return false;
}
if (deleteable=="1")
if(!confirm(jxl.sprintf('{?1963:817?}\n{?1963:763?}',devName)))
return false;
if (deleteable=="0")
{
alert('{?1963:7813?}');
return false;
}
return true;
}
<?lua
local g_ssid,g_ssid_scnd = box.query("wlan:settings/ssid"), ""
if config.WLAN.is_double_wlan then
g_ssid_scnd = box.query("wlan:settings/ssid_scnd")
end
net_devices.write_showPrintView_func("main")
?>
ready.onReady(ajaxValidation({
okCallback: uiDoOnMainFormSubmit
}));
function initTableSorter() {
sort.init("uiWlanDevs");
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
