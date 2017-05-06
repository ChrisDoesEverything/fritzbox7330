--[[Access denied<?lua
box.end_page()
?>]]
--------------------------------------------------------------------------------
if log then log.disable() end
g_no_auto_init_net_devices = true
require("net_devices")
if log then log.enable() end
require"js"
wlanscan = {}
wlanscan.band24 = {channels = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13},
col_pos = {97,135,173,210,248,286,325,363,401,438,476,514,551},
axis_pos = {99,137,175,212,250,288,327,365,403,440,478,516,553},
freq = {"2,412","2,417","2,422","2,427","2,432","2,437","2,442","2,447","2,452","2,457","2,462","2,467","2,472"}
}
wlanscan.band5 = {channels = {36, 40, 44, 48, 52, 56, 60, 64,100,104,108,112,116,120,124,128,132,136,140},
col_pos = {90,116,141,168,194,220,246,272,298,324,349,375,401,428,453,479,505,531,557},
axis_pos = {90,116,142,168,194,221,246,272,298,324,350,376,402,428,454,480,506,532,558},
freq = {"5,180","5,200","5,220","5,240","5,260","5,280","5,300","5,320","5,500","5,520","5,540","5,560","5,580","5,600","5,620","5,640","5,660","5,680","5,700"}
}
local function compareByRssiAndChecked(dev1, dev2)
if (dev1.checked and dev2.checked) then
return false
end
if (dev1.checked) then
return true
end
if (dev2.checked) then
return false
end
local rssi1 = tonumber(dev1.rssi) or 0;
local rssi2 = tonumber(dev2.rssi) or 0;
if (rssi1 < rssi2) then
return false
elseif (rssi1 > rssi2) then
return true
end
return false
end
local function is_wpa_encrypted(dev)
return (dev.encStr or ""):find("wpa") == 1
end
local function is_24ghz_band(dev)
return dev.radioband == "1"
end
local wlanlist = {}
function wlanscan.gethtml(options)
options = options or {}
require("isp")
local initial = isp.initial_wlanscan('oma_wlan')
if not options.show_scan then
if log then log.disable() end
wlanlist = wlanscan.get_wlan_scan_list()
if log then log.enable() end
wlanlist = array.filter(wlanlist, is_wpa_encrypted)
wlanlist = array.filter(wlanlist, is_24ghz_band)
end
net_devices.check_and_add(wlanlist, options.stamac or initial.stamac or "")
if wlanlist then
table.sort(wlanlist, compareByRssiAndChecked)
end
local show_checkbox = true
local show_encryption = true
local show_scan = nil
if options.show_scan then
show_scan = true
end
return wlanscan.create_wlan_scan_table(wlanlist, false, show_checkbox, show_encryption, show_scan)
end
local apenv_states = {["0"] = 'OK', ["1"] = 'busy', ["2"] = 'error'}
function wlanscan.getstate()
local state = box.query("wlan:settings/APEnvStatus","2")
return js.table({state=apenv_states[state]})
end
function wlanscan.getjson(options)
options = options or {}
local answer = {}
answer.state = apenv_states[box.query("wlan:settings/APEnvStatus","2")]
options.show_scan = options.startscan or answer.state == 'error'
if options.show_scan then
require("cmtable")
local saveset = {}
cmtable.add_var(saveset, "wlan:settings/scan_apenv", "2")
local e, m = box.set_config(saveset)
answer.state = 'busy'
end
answer.html = wlanscan.gethtml(options)
answer.scanlist = wlanlist
return js.table(answer)
end
local g_paramTypes = {
"-",
"ssid",
"rssi",
"mac",
"mode",
"channel",
"time_age",
"time_blocked",
"radioband",
"capabilities",
"frequency",
"quality",
"noise",
"channel_width"
}
local function getParamTypeName(paramType)
local n = tonumber(paramType)+1
if (type(n)~="number" or n > #g_paramTypes) then
return paramType;
end
return g_paramTypes[n];
end
function wlanscan.get_same_ssid_count(ssid)
local same_ssid_count = 0
for i,elem in pairs(wlanscan.get_wlan_scan_list()) do
if (net_devices.get_ssid(elem) == ssid and elem.radiotype=="2") then
same_ssid_count = same_ssid_count + 1
end
end
return same_ssid_count
end
function wlanscan.get_num_of_checked(curList)
local count=0
for i,elem in ipairs(curList) do
if (elem.checked) then
count=count+1
end
end
return count;
end
function wlanscan.is_40Mhz(band)
if (band=="24") then
if (box.query("wlan:settings/channelwidth") ~= "0") then
if (box.query("wlan:settings/bg_mode") == "24") then
return false;
end
end
end
local radioband="1"
if band=="5" then
radioband="2"
end
return wlanscan.is_HT40(radioband)
end
function wlanscan.is_80Mhz(band)
if (band=="24") then
return false
end
if config.WLAN.has_11ac then
if (box.query("wlan:settings/bg_mode_scnd") == "53") then
return true
end
end
return false
end
function wlanscan.get_channelwidth(band, channelwidth)
local radioband="1"
if band=="5" then
radioband="2"
end
local saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","1")
err, g_errmsg = box.set_config(saveset)
local wlanlist = general.listquery("wlan:settings/APEnv/list(radiotype)")
local result=""
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="1") then
local tmp = general.listquery("wlan:settings/"..elem._node.."/paramtype/list(type,value)")
for x,attrib in ipairs(tmp) do
elem[getParamTypeName(attrib.type)]=attrib.value
end
if (not radioband or elem.radioband==radioband) then
if (elem.channel_width~=nil) then
result=elem.channel_width
break
end
end
end
end
saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","0")
err, g_errmsg = box.set_config(saveset)
if result~="" then
return result
end
if not channelwidth then
channelwidth = box.query("wlan:settings/channelwidth")
end
if band == "5" and channelwidth == "1" then
if wlanscan.is_80Mhz(band) then
return "80"
else
return "40"
end
end
return "20"
end
function wlanscan.get_wlan_scan_list()
local saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","1")
err, g_errmsg = box.set_config(saveset)
local scanlist=general.listquery("wlan:settings/APEnv/list(radiotype)")
for i,elem in ipairs(scanlist) do
elem.checked=false
elem.idx=i-1
elem.rssi=-1
elem.ssid=""
elem.mac=""
elem.channel=""
local tmp=general.listquery("wlan:settings/APEnv"..elem.idx.."/paramtype/list(type,value)")
for x,attrib in ipairs(tmp) do
elem[getParamTypeName(attrib.type)]=attrib.value
end
elem.encStr=net_devices.convert_num_to_enc(net_devices.get_encryption(elem))
end
saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","0")
err, g_errmsg = box.set_config(saveset)
return scanlist
end
local function RoundChannelUp(Channel)
if(Channel<20) then
return Channel;
end
if(Channel<=36) then return 36;
elseif(Channel<=40) then return 40;
elseif(Channel<=44) then return 44;
elseif(Channel<=48) then return 48;
elseif(Channel<=52) then return 52;
elseif(Channel<=56) then return 56;
elseif(Channel<=60) then return 60;
elseif(Channel<=64) then return 64;
elseif(Channel<=100) then return 100;
elseif(Channel<=104) then return 104;
elseif(Channel<=108) then return 108;
elseif(Channel<=112) then return 112;
elseif(Channel<=116) then return 116;
elseif(Channel<=120) then return 120;
elseif(Channel<=124) then return 124;
elseif(Channel<=128) then return 128;
elseif(Channel<=132) then return 132;
elseif(Channel<=136) then return 136;
elseif(Channel<=140) then return 140;
else
return Channel;
end
end
local function RoundChannelDown(Channel)
if(Channel<20) then
return Channel;
end
if(Channel>=140) then return 140;
elseif(Channel>=136) then return 136;
elseif(Channel>=132) then return 132;
elseif(Channel>=128) then return 128;
elseif(Channel>=124) then return 124;
elseif(Channel>=120) then return 120;
elseif(Channel>=116) then return 116;
elseif(Channel>=112) then return 112;
elseif(Channel>=108) then return 108;
elseif(Channel>=104) then return 104;
elseif(Channel>=100) then return 100;
elseif(Channel>=64) then return 64;
elseif(Channel>=60) then return 60;
elseif(Channel>=56) then return 56;
elseif(Channel>=52) then return 52;
elseif(Channel>=48) then return 48;
elseif(Channel>=44) then return 44;
elseif(Channel>=40) then return 40;
elseif(Channel>=36) then return 36;
else
return Channel;
end
end
function wlanscan.extract_current_channel(channel)
if (channel and channel ~= "") then
local res
require("string_op")
require("config")
if (config.WLAN_RADIOSENSOR) then
local channels = string_op.split2table(channel,",",0)
res = string.gsub(channels[2]," ","")
else
res = string.gsub(channel," ","")
end
return tonumber(res)
end
return 0;
end
local function extract_start_channel(channel)
if (channel ~= "") then
local res
require("string_op")
require("config")
if (config.WLAN_RADIOSENSOR) then
local channels = string_op.split2table(channel,",",0)
res = string.gsub(channels[1]," ","")
else
res = string.gsub(channel," ","")
end
return RoundChannelUp(tonumber(res))
end
return 0;
end
local function extract_end_channel(channel)
if (channel ~= "") then
local res
require("string_op")
require("config")
if (config.WLAN_RADIOSENSOR) then
local channels = string_op.split2table(channel,",",0)
res = string.gsub(channels[3]," ","")
else
res = string.gsub(channel," ","")
end
return RoundChannelDown(tonumber(res))
end
return 0;
end
function wlanscan.get_time_blocked(wlanlist, channel)
if (channel < 36) then
return 0;
end
for i,elem in ipairs(wlanlist) do
if (elem.channel) then
local ch = wlanscan.extract_current_channel(elem.channel)
if (ch == channel and elem.time_blocked) then
return tonumber(elem.time_blocked, 10) or 0
end
end
end
return 0
end
function wlanscan.zero_used_channels(known_channels, used_channels)
for i,cur_chan in ipairs(known_channels) do
if (cur_chan) then
used_channels[cur_chan]=0
end
end
end
function wlanscan.init_used_channels(wlanlist,used_channels, dont_count_own_ap)
local cur_chan=0
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="2" or not dont_count_own_ap and elem.radiotype=="1") then
cur_chan=wlanscan.extract_current_channel(elem.channel)
if (cur_chan and cur_chan~=0 and used_channels[cur_chan]) then
used_channels[cur_chan] = used_channels[cur_chan] + 1
end
end
end
return 0
end
function wlanscan.init_used_channels_stoer(wlanlist,used_channels)
local cur_chan=0
local _start=0
local _end=0
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="2" or elem.radiotype=="1") then
_start=extract_start_channel(elem.channel)
_end =extract_end_channel(elem.channel)
for k,v in pairs(used_channels) do
if (_start<=k and k<=_end) then
used_channels[k]=used_channels[k]+1
end
end
end
end
return 0
end
function wlanscan.get_current_channel(channel)
if (channel ~= "") then
local res
require("string_op")
require("config")
if (config.WLAN_RADIOSENSOR) then
local channels = string_op.split2table(channel,",",0)
res = string.gsub(channels[2]," ","")
else
res = string.gsub(channel," ","")
end
return res
end
return "0";
end
function wlanscan.get_used_channel(wlanlist,band)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
if config.WLAN_RADIOSENSOR then
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="1" and (radio=="" or elem.radioband==radio)) then
return wlanscan.extract_current_channel(elem.channel)
end
end
return 0
else
return box.query("wlan:settings/used_channel")
end
end
function wlanscan.get_start_channel(wlanlist,band)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
if config.WLAN_RADIOSENSOR then
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="1" and elem.radioband==radio) then
return extract_start_channel(elem.channel)
end
end
return 0
else
return tonumber(box.query("wlan:settings/used_channel"))
end
end
function wlanscan.get_end_channel(wlanlist,band)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
if config.WLAN_RADIOSENSOR then
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="1" and elem.radioband==radio) then
return extract_end_channel(elem.channel)
end
end
return 0
else
return tonumber(box.query("wlan:settings/used_channel"))
end
end
function wlanscan.get_channel_usage(chan_table,chan)
local count=chan_table[chan] or 0
if (count>0)then
return count
end
return 0
end
local function castSigned(z, n)
n = n or 16;
local maxPosSigned = math.pow(2, n-1)
if (z >= 0 and z < maxPosSigned) then
return z
end
local maxUnsigned = 2 * maxPosSigned
if (z < 0) then
return maxUnsigned + z
end
return z - maxUnsigned
end
function wlanscan.get_show_noise(wlanlist, band, channel)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
local noiseLimit = -78;
for i,elem in ipairs(wlanlist) do
if (elem.channel) then
local ch = wlanscan.extract_current_channel(elem.channel)
if (ch == channel and elem.radioband==radio and elem.noise) then
local noise=tonumber(elem.noise, 10) or 0
return castSigned(noise) > noiseLimit
end
end
end
return false;
end
function wlanscan.get_channel_usage_env_count(band)
local chan_table = {}
if (band=="5") then
chan_table = wlanscan.band5.channels
else
chan_table = wlanscan.band24.channels
end
local channel_usage = {}
wlanscan.zero_used_channels(chan_table, channel_usage)
local wlan_scan_list = wlanscan.get_wlan_scan_list()
wlanscan.init_used_channels(wlan_scan_list, channel_usage, true)
local used_channel = wlanscan.get_used_channel(wlan_scan_list, band)
return wlanscan.get_channel_usage(channel_usage, used_channel)
end
function wlanscan.get_num_of_stoer_at_channel(wlanlist,band,channel)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
local count=0
local _start=0
local _end=0
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="2") then
_start=extract_start_channel(elem.channel)
_end =extract_end_channel(elem.channel)
if (elem.radioband==radio and (_start<=channel and channel<=_end)) then
count=count+1
end
end
end
if (count>0)then
return count
end
return 0
end
function wlanscan.is_HT40(radioband, channelwidth)
if not channelwidth then
channelwidth = box.query("wlan:settings/channelwidth")
end
local saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","1")
err, g_errmsg = box.set_config(saveset)
local wlanlist = general.listquery("wlan:settings/APEnv/list(radiotype)")
local result=false
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="1") then
local tmp = general.listquery("wlan:settings/APEnv"..i.."/paramtype/list(type,value)")
for x,attrib in ipairs(tmp) do
elem[getParamTypeName(attrib.type)]=attrib.value
end
if (not radioband or elem.radioband==radioband) then
if (elem.channel_width~=nil) then
result=(elem.channel_width=="40")
break
end
result=(channelwidth~="0")
break
end
end
end
saveset={}
cmtable.add_var(saveset, "wlan:settings/APEnvLock","0")
err, g_errmsg = box.set_config(saveset)
return result
end
function wlanscan.get_wait_animation(reason, text_id)
if text_id then
text_id = [[ id="]]..text_id..[["]]
else
text_id = ""
end
local str=[[<div class='wait'>]]
str=str..[[<p class='waitimg'><img src='/css/default/images/wait.gif'></p><span]]..text_id..[[>]]
str=str..wlanscan.get_wait_text(reason)
str=str..[[</span><br></div>]]
return str
end
function wlanscan.get_wait_text(reason)
if (reason=="init") then
return TXT([[{?548:547?}]])
elseif (reason=="net") then
return TXT([[{?548:929?}]])
elseif (reason=="radar") then
return TXT([[{?548:920?}]])
else
return TXT([[{?548:944?}]])
end
end
local function get_inner_table(id, num_of_col, use_checked, show_encrypt)
local str=[[<tr><td class='scroll_container' colspan=']]..num_of_col..[['>]]
str=str..[[<div class='scroll'>]]
str=str..[[<table id=']]..id..[[' class='zebra_reverse noborder' >]]
if (use_checked) then
if (show_encrypt) then
str=str..[[<colgroup><col width='25px'><col width='40px'><col width='303px'><col width='67px'><col width='182px'><col width='118px'><col width='auto'></colgroup>]]
else
str=str..[[<colgroup><col width='25px'><col width='40px'><col width='323px'><col width='67px'><col width='182px'><col width='auto'></colgroup>]]
end
else
str=str..[[<colgroup><col width='40px'><col width='323px'><col width='67px'><col width='182px'><col width='auto'></colgroup>]]
end
return str
end
function wlanscan.create_wlan_scan_table(wlan_scan_list,force,use_checked,show_encrypt,show_scan, show_wds2, separate_bands)
local str=[[<table id='uiScanResult' class='zebra'>]]
local num_of_col=5
if (use_checked) then
if (show_encrypt) then
str=str..[[<colgroup><col width='25px'><col width='40px'><col width='303px'><col width='67px'><col width='182px'><col width='118px'><col width='auto'></colgroup>]]
num_of_col=7
str=str..[[<tr class='thead'><th title=']]..TXT([[{?548:16?}]])..[['></th><th class='sortable sort_by_class' title=']]..TXT([[{?548:727?}]])..[['><img src='/css/default/images/wlan_antenne.gif' width='11px' height='13px'></th><th class='sortable'>]]..TXT([[{?548:983?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable sort_by_num'>]]..TXT([[{?548:698?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable'>]]..TXT([[{?548:578?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable'>]]..TXT([[{?548:241?}]])..[[<span class='sort_no'>&nbsp;</span></th><th ></th></tr>]]
else
str=str..[[<colgroup><col width='25px'><col width='40px'><col width='323px'><col width='67px'><col width='182px'><col width='auto'></colgroup>]]
num_of_col=6
str=str..[[<tr class='thead'><th title=']]..TXT([[{?548:95?}]])..[['></th><th class='sortable sort_by_class' title=']]..TXT([[{?548:48?}]])..[['><img src='/css/default/images/wlan_antenne.gif' width='11px' height='13px'></th><th class='sortable'>]]..TXT([[{?548:729?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable sort_by_num'>]]..TXT([[{?548:800?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable'>]]..TXT([[{?548:564?}]])..[[<span class='sort_no'>&nbsp;</span></th><th ></th></tr>]]
end
else
str=str..[[<colgroup><col width='40px'><col width='323px'><col width='67px'><col width='182px'><col width='auto'></colgroup>]]
num_of_col=5
str=str..[[<tr class='thead'><th class='sortable sort_by_class' title=']]..TXT([[{?548:352?}]])..[['><img src='/css/default/images/wlan_antenne.gif' width='11px' height='13px'></th><th class='sortable'>]]..TXT([[{?548:624?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable sort_by_num'>]]..TXT([[{?548:459?}]])..[[<span class='sort_no'>&nbsp;</span></th><th class='sortable'>]]..TXT([[{?548:685?}]])..[[<span class='sort_no'>&nbsp;</span></th><th></th></tr>]]
end
local ap_env_state = box.query("wlan:settings/APEnvStatus")
if (not force and ap_env_state ~="0" and ap_env_state ~="3") or show_scan then
str=str..[[<tr><td colspan=']]..num_of_col..[[' class='txt_center'>]]
if (show_scan==true and ap_env_state =="0") then
str=str..wlanscan.get_wait_animation('init')
elseif (show_scan~=nil) then
str=str..wlanscan.get_wait_animation('net')
else
str=str..wlanscan.get_wait_animation()
end
str=str..[[</td></tr></table>]]
return str
end
if (not net_devices.AnyWlanDevice(wlan_scan_list) or force) then
str=str..[[<tr><td colspan=']]..num_of_col..[[' class='txt_center'>]]..TXT([[{?548:86?}]])..[[</td></tr>]]
str=str..[[</table>]]
return str
end
local scnd_ap = ""
local scnd_table = ""
if separate_bands and config.GUI_IS_REPEATER and config.WLAN.is_double_wlan then
scnd_table=str..get_inner_table("uiListOfApsScnd", num_of_col, use_checked, show_encrypt)
scnd_ap = box.query("wlan:settings/STA_mac_master_scnd")
end
str=str..get_inner_table("uiListOfAps", num_of_col, use_checked, show_encrypt)
local create_dev_row=net_devices.create_dev_row_raw
if (use_checked) then
if (show_encrypt) then
if show_wds2 then
create_dev_row=net_devices.create_dev_row_checked_wds2
else
create_dev_row=net_devices.create_dev_row_checked_enc
end
else
create_dev_row=net_devices.create_dev_row_checked
end
end
for i,elem in ipairs(wlan_scan_list) do
if (elem.radiotype=="2" and (not separate_bands or separate_bands and elem.cipher ~= "2")) then
if scnd_table ~= "" then
if tostring(elem.radioband) == "2" or elem.mac == scnd_ap then
elem.radioband = "2"
scnd_table=scnd_table..create_dev_row(i-1,elem)
else
str=str..create_dev_row(i-1,elem)
end
else
str=str..create_dev_row(i-1,elem)
end
end
end
if scnd_table ~= "" then
str=[[<p><h4>]]..TXT([[{?548:310?}]])..[[</h4></p>]]..str
str=str..[[</table></div></td></tr></table>]]
str=str..[[<p><h4>]]..TXT([[{?548:126?}]])..[[</h4></p>]]
str=str..scnd_table..[[</table></div></td></tr></table>]]
else
str=str.."</table></div></td></tr></table>"
end
return str
end
function wlanscan.get_show_stoerer(wlanlist,band, channel)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
local resultStr={}
for i,elem in ipairs(wlanlist) do
if (elem.channel) then
_start=extract_start_channel(elem.channel)
_end =extract_end_channel(elem.channel)
if (elem.radioband==radio and (_start<=channel and channel<=_end)) then
if elem.radiotype=="4" then
table.insert(resultStr,TXT([[{?548:573?}]]))
elseif elem.radiotype=="5" then
table.insert(resultStr,TXT([[{?548:554?}]]))
elseif elem.radiotype=="6" then
table.insert(resultStr,TXT([[{?548:969?}]]))
elseif elem.radiotype=="7" and false then
table.insert(resultStr,TXT([[{?548:355?}]]))
elseif elem.radiotype=="8" then
table.insert(resultStr,TXT([[{?548:163?}]]))
elseif elem.radiotype=="9" then
table.insert(resultStr,TXT([[{?548:175?}]]))
end
end
end
end
return table.concat(resultStr,", "),#resultStr
end
