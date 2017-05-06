<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_wlan_funkkanal.html"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("general")
require("http")
require("cmtable")
require("newval")
require("ip")
require("string")
require("wlanscan")
g_no_auto_init_net_devices = true
require("net_devices")
g_back_to_page = http.get_back_to_page( "/wlan/radiochannel.lua" )
g_graph = {}
g_errmsg = nil
function val_num_range(elem, min, max)
if box.post[elem] then
newval.num_range(elem, min, max, "range_error")
end
end
function valprog()
val_num_range("auto_power_level", 1, 5)
if g_is_double_wlan then
val_num_range("channel", 0, 13)
val_num_range("wlanmode", 23, 25)
val_num_range("channel_scnd", 0, 140)
if config.WLAN.has_11ac then
val_num_range("wlanmode_scnd", 52, 53)
end
else
val_num_range("channel", 0, 140)
val_num_range("wlanmode", 23, 52)
end
end
local range_error_msg = [[{?6447:220?}]]
newval.msg.range_error = {
[newval.ret.empty] = range_error_msg,
[newval.ret.format] = range_error_msg,
[newval.ret.outofrange] = range_error_msg
}
g_channel = "0"
g_current_channelwidth= "40"
g_wlanList = {}
g_ap_env_state = box.query("wlan:settings/APEnvStatus")
g_is_double_wlan = false
g_active = (box.query("wlan:settings/ap_enabled")=="1")
g_active_scnd = false
g_channel_scnd = "-1"
g_channelwidth = ""
g_coexist = ""
g_auto_1213 = ""
g_auto_radar = ""
g_auto_chan_1213_ext = config.WLAN.has_auto_chan_12_13
g_auto_power = ""
g_auto_power_level = ""
g_turbo = ""
g_iptv = ""
g_wmm = ""
g_showradar = false
if config.WLAN.is_double_wlan then
g_is_double_wlan = true
g_active_scnd = box.query("wlan:settings/ap_enabled_scnd")=="1"
g_channel_scnd = ""
end
if not g_active and not g_active_scnd then
http.redirect(href.get("/home/home.lua"))
end
g_wlan_mode = ""
g_wlan_mode_scnd = ""
g_band = ""
is_repeater = false
if config.GUI_IS_REPEATER then
is_repeater = true
end
g_tab={
currtab = 1,
notabs = false,
pages = {{text = [[{?g_txt24Band?}]],
shown = true,
tabid = "uiTab24",
enabled = g_active,
html = "",
html_content = "",
html_content_stoer = ""},
{text = [[{?g_txt5Band?}]],
shown = true,
tabid = "uiTab5",
enabled = g_active_scnd,
html = "",
html_content = "",
html_content_stoer = ""}}
}
function is_wlan_rep_mode()
if config.GUI_IS_REPEATER and general.get_bridge_mode() == "wlan_bridge" then
return true
end
return false
end
function read_box_values()
g_channel = box.query("wlan:settings/channel")
g_channelwidth = box.query("wlan:settings/channelwidth")
g_coexist = box.query("wlan:settings/coexistence")
if (g_coexist=="er") then
g_coexist="0"
end
g_auto_1213 = box.query("wlan:settings/autochannel_plus")
g_auto_radar = box.query("wlan:settings/autochannel_plus_11a")
g_auto_power = box.query("wlan:settings/tx_autopower")
g_auto_power_level = box.query("wlan:settings/power_level")
g_turbo = box.query("wlan:settings/turbomode")
g_iptv = box.query("wlan:settings/IPTVoptimize")
g_wmm = box.query("wlan:settings/wmm_enabled")
net_devices.add_wlan_to_list()
if g_is_double_wlan and config.WLAN.has_11ac then
g_wlan_mode_scnd = net_devices.get_bg_mode(true)
end
g_current_channelwidth = wlanscan.get_channelwidth("5", g_channelwidth)
if g_is_double_wlan then
g_channel_scnd =box.query("wlan:settings/channel_scnd")
end
g_wlan_mode = net_devices.get_bg_mode()
g_band = "24"
if not g_is_double_wlan then
local wds2band = net_devices.get_wds2_uplink_band()
if wds2band == "1" then
g_wlan_mode = "25"
elseif wds2band == "2" then
g_wlan_mode = "52"
end
end
if tonumber(g_wlan_mode)>50 and not g_is_double_wlan then
g_band = "5"
end
end
function refill_user_input_from_post()
if (box.post.ChannelSelect=="auto") then
g_channel ="0"
g_channel_scnd ="0"
g_channelwidth ="1"
g_coexist ="1"
g_current_channelwidth ="40"
g_auto_1213 ="0"
g_auto_radar ="0"
g_auto_power ="0"
g_auto_power_level ="1"
g_turbo ="1"
g_iptv ="0"
g_wmm ="0"
g_wlan_mode ="25"
g_band ="24"
if g_is_double_wlan and config.WLAN.has_11ac then
g_wlan_mode_scnd = "53"
end
return
end
g_channel = box.query("wlan:settings/channel")
if (box.post.channel) then
g_channel = box.post.channel
end
if g_is_double_wlan and config.WLAN.has_11ac then
g_wlan_mode_scnd = "53"
if (box.post.wlanmode_scnd) then
g_wlan_mode_scnd = box.post.wlanmode_scnd
end
end
if not config.WLAN.has_coexistence then
g_channelwidth ="0"
if (box.post.use300Mbit) then
g_channelwidth ="1"
end
else
g_channelwidth ="1"
end
g_auto_1213="0"
if (box.post.use1213) then
g_auto_1213="1"
end
g_auto_radar = "0"
if (box.post.useradar) then
g_auto_radar = "1"
end
g_auto_power="0"
if (box.post.auto_power) then
g_auto_power="1"
end
g_auto_power_level ="0"
if (box.post.auto_power_level) then
g_auto_power_level =box.post.auto_power_level
end
g_turbo="0"
if (box.post.turbo) then
g_turbo="1"
end
g_iptv="0"
if (box.post.iptv) then
g_iptv="1"
end
g_wmm="0"
if (box.post.wmm) then
g_wmm="1"
end
g_coexist="0"
if (box.post.use300MbitCoexist) then
g_coexist="1"
end
if g_is_double_wlan then
g_channel_scnd = box.query("wlan:settings/channel_scnd")
if (box.post.channel_scnd) then
g_channel_scnd = box.post.channel_scnd
end
end
net_devices.add_wlan_to_list()
g_wlan_mode = net_devices.get_bg_mode()
if (box.post.wlanmode) then
g_wlan_mode = box.post.wlanmode
end
g_band = "24"
if tonumber(g_wlan_mode)>50 and not g_is_double_wlan then
g_band = "5"
end
end
function refill_user_input_from_get()
end
if next(box.post) then
local saveset = {}
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
if newval.validate(valprog)==newval.ret.ok then
refill_user_input_from_post()
if (box.post.ChannelSelect=="auto") then
cmtable.add_var(saveset, "wlan:settings/auto_settings" ,"1")
else
cmtable.add_var(saveset, "wlan:settings/auto_settings" ,"0")
end
cmtable.add_var(saveset, "wlan:settings/channel" ,g_channel )
cmtable.add_var(saveset, "wlan:settings/channelwidth" ,g_channelwidth )
if (config.WLAN.has_coexistence and g_channelwidth=="1") then
cmtable.add_var(saveset, "wlan:settings/coexistence" ,g_coexist )
end
cmtable.add_var(saveset, "wlan:settings/autochannel_plus",g_auto_1213 )
cmtable.add_var(saveset, "wlan:settings/autochannel_plus_11a",g_auto_radar )
cmtable.add_var(saveset, "wlan:settings/tx_autopower" ,g_auto_power )
cmtable.add_var(saveset, "wlan:settings/power_level" ,g_auto_power_level)
cmtable.add_var(saveset, "wlan:settings/turbomode" ,g_turbo )
cmtable.add_var(saveset, "wlan:settings/IPTVoptimize" ,g_iptv )
cmtable.add_var(saveset, "wlan:settings/wmm_enabled" ,g_wmm )
cmtable.add_var(saveset, "wlan:settings/bg_mode" ,g_wlan_mode )
if g_is_double_wlan and config.WLAN.has_11ac then
cmtable.add_var(saveset, "wlan:settings/bg_mode_scnd" ,g_wlan_mode_scnd )
end
if (g_is_double_wlan and g_active_scnd) then
cmtable.add_var(saveset, "wlan:settings/channel_scnd" ,g_channel_scnd )
end
local err=0
err, g_errmsg = box.set_config(saveset)
if err==0 then
http.redirect(href.get(g_back_to_page))
end
else
http.redirect(href.get(g_back_to_page))
end
elseif box.post.refresh then
cmtable.add_var(saveset, "wlan:settings/scan_apenv","3")
local err=0
err, g_errmsg = box.set_config(saveset)
http.redirect(href.get(g_back_to_page, "refresh=1"))
return
elseif box.post.cancel or box.post.refresh_list then
http.redirect(href.get(g_back_to_page))
return
end
else
read_box_values()
end
function compareByRssi(dev1, dev2)
local rssi1 = tonumber(dev1.rssi) or 0
local rssi2 = tonumber(dev2.rssi) or 0
if (rssi1 < rssi2) then
return false
elseif (rssi1 > rssi2) then
return true
end
return false
end
function init_channel_usage(band)
local channels = wlanscan["band"..band].channels
wlanscan.zero_used_channels(channels, g_channel_usage)
wlanscan.zero_used_channels(channels, g_channel_usage_stoer)
g_graph[band..'_80'] = get_channels_html(band,'80')
g_graph[band..'_40'] = get_channels_html(band,'40')
g_graph[band..'_20'] = get_channels_html(band,'20')
end
function init()
if (g_wlanList) then
table.sort(g_wlanList, compareByRssi)
end
init_channel_usage("24")
if g_is_double_wlan or config.WLAN.has_5ghz_band then
init_channel_usage("5")
end
wlanscan.init_used_channels(g_wlanList,g_channel_usage)
wlanscan.init_used_channels_stoer(g_wlanList,g_channel_usage_stoer)
end
function get_wlan_active(radiotype)
if g_active and radiotype=="24" then
return [[checked='checked']]
end
if g_active_scnd and radiotype=="5" then
return [[checked='checked']]
end
return ""
end
function write_visible(double_or_single)
if (double_or_single=='single') then
end
if (double_or_single=='double') then
end
end
function get_channels_html(band,bandwidth)
local currentband=band.."_"..bandwidth
local selected=""
local var_name=[[channel]]
local var_id=[[uiChannels]]
if g_is_double_wlan and band=="5" then
var_name=[[channel_scnd]]
var_id=[[uiChannels_scnd]]
end
local str = [[<select class='big' id=']]..var_id..[[' name=']]..var_name..[[' onchange='return OnChannel(]]..band..[[,this.value)'><option value='0'>{?6447:246?}</option>]]
if (band=="24") then
local channel_list_2ghz = box.query("wlan:settings/channel_list_2ghz")
local chan_table_2ghz = string.split(channel_list_2ghz, ",")
local n = #chan_table_2ghz
for i=1,n,1 do
selected=""
local channel = chan_table_2ghz[i]
if (channel==tostring(g_channel)) then
selected=" selected "
end
str=str..[[<option value=']]..channel..[[' ]]..selected..[[ >{?g_txtChannel?} ]]..channel..[[</option>]]
end
elseif (band=="5") then
local channel_list_5ghz = box.query("wlan:settings/channel_list_5ghz")
local chan_table = string.split(channel_list_5ghz, ",")
local chan=g_channel
if (g_is_double_wlan) then
chan=g_channel_scnd
end
local maxtab=#chan_table
local function set_max_tab(add80, add40, add20)
if bandwidth == "80" then
maxtab = maxtab + add80
elseif bandwidth == "40" then
maxtab = maxtab + add40
else
maxtab = maxtab + add20
end
end
if g_current_channelwidth == "80" then
set_max_tab(0, 2, 3)
elseif g_current_channelwidth == "40" then
set_max_tab(-2, 0, 1)
else
set_max_tab(-3, -1, 0)
end
for i=1,maxtab,1 do
local channel = chan_table[i]
if not channel then
channel = wlanscan.band5.channels[i]
end
selected=""
if (tostring(channel)==tostring(chan)) then
selected=" selected "
end
str=str..[[<option value=']]..channel..[[' ]]..selected..[[ >{?g_txtChannel?} ]]..channel..[[</option>]]
end
end
str=str..[[</select>]]
return str
end
function get_channels(band,bandwidth)
return g_graph[band..'_'..bandwidth]
end
function write_channels(band,bandwidth)
box.out(get_channels(band,bandwidth))
return
end
function write_freq_band(band)
if (band=="24") then
box.out([[{?6447:331?}]])
return
end
box.out([[{?6447:21?}]])
end
function write_300MBit()
if (g_channelwidth=="1")then
box.out(" checked ")
end
end
function write_300MBitCoexist()
if (g_coexist=="1")then
box.out(" checked ")
end
end
function write_turbo()
if (g_turbo=="1")then
box.out(" checked ")
end
end
function write_iptv()
if (g_iptv=="1")then
box.out(" checked ")
end
end
function write_wmm()
if (g_wmm=="1")then
box.out(" checked ")
end
end
function write_auto_power()
if (g_auto_power=="1")then
box.out(" checked ")
end
end
function write_auto_power_avail()
if not config.WLAN.has_tx_autopower then
box.out([[display:none]])
end
end
function get_1213_avail()
if not config.WLAN.GUI_IS_REPEATER then
if (not general.is_expert()) then
return [[display:none;]]
end
end
if g_band=="5" then
return [[display:none;]]
end
if (g_channel~="0") then
return [[display:none;]]
end
return ""
end
function write_expert_features()
if (not general.is_expert()) then
box.out([[display:none]])
end
end
function write_coexist_avail()
--local avail=config.WLAN.has_ht40_channelwidth
local avail="1"
if (avail=="0") then
box.out([[display:none]])
end
end
function write_300MBit_avail()
if (not config.WLAN.has_ht40_channelwidth or (g_wlan_mode=="24" and not g_active_scnd)) then
box.out([[display:none]])
end
end
function get_300MBitCoexist_avail()
if not config.WLAN.has_11ac then
if not config.WLAN.has_coexistence then
return [[display:none]]
end
end
return ""
end
function write_300MBitCoexist_enabled()
if not config.WLAN.has_11ac then
if (g_channelwidth=="0")then
box.out("disabled")
end
end
end
function str_my_wlan_mac(mac)
local tmp=mac:split(":")
tmp[1]=[[<font color="blue">]]..tmp[1]..[[</font>]]
return table.concat(tmp,":")
end
function write_300MBit_rate()
local rate=box.query("wlan:settings/max_rate_supported")
if (rate==nil or rate=="err") then
rate="300"
end
box.out(general.sprintf([[{?6447:825?}]],rate))
end
function write_autopower_select(rate)
box.out(get_autopower_select(rate))
end
function get_autopower_select(rate)
if (rate==g_auto_power_level) then
return " selected "
end
return ""
end
function CheckDefaults()
local check=box.query("wlan:settings/auto_settings")
if (check=="" or check=="er") then
if (g_active and g_channel~="0") then return false end
if (g_is_double_wlan and g_channel_scnd~="0" and g_active_scnd) then return false end
if config.GUI_6360_WLAN_INCOMPLETE then
if (g_auto_1213 ~= "0") then return false end
end
if (g_auto_radar~="0") then return false end
if (g_channelwidth~="1") then return false end
if (g_auto_power~= "0") then return false end
if (g_auto_power_level~="1") then return false end
if (g_wlan_mode~="25") then return false end
if (g_turbo~="1") then return false end
if (g_iptv~="0") then return false end
if (g_wmm~="0") then return false end
return true
end
return (check=="1") or (check=="2")
end
function get_selected_wlanmode(mode)
if g_wlan_mode == mode then
return " selected "
end
if g_is_double_wlan and config.WLAN.has_11ac then
if g_wlan_mode_scnd == mode then
return " selected "
end
end
return ""
end
function write_selected_wlanmode(mode)
box.out(get_selected_wlanmode(mode))
end
function get_refresh_txt()
if get_mode("auto") ~= "" or not g_is_double_wlan and g_channel == "0" or
g_is_double_wlan and (g_channel == "0" or g_channel_scnd == "0") then
return [[{?6447:12?}]]
else
return [[{?6447:7621?}]]
end
end
function get_1213()
if (g_auto_1213=="1")then
return " checked "
end
return ""
end
function get_mode(mode)
local defaults=CheckDefaults()
if (mode=="auto" and defaults) or (mode=="manu" and not defaults)then
return " checked "
end
return ""
end
function write_mode(mode)
box.out(get_mode(mode))
end
function get_currChannel()
local str=[[<div class='CssBlueInfoText'>]]
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
str=str..[[{?6447:467?}]]
else
str=str..[[{?6447:233?}]]
end
else
str=str..[[{?6447:105?}]]
end
str=str..[[<span class='CssBlueNumberInfo' id='uiBlueNumberInfo'>...</span></div>]]
return str
end
function get_channelwidth_text(band)
local txt=general.sprintf([[{?6447:442?}]], wlanscan.get_channelwidth(band, g_channelwidth))
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
txt=general.sprintf([[{?6447:586?}]], wlanscan.get_channelwidth(band, g_channelwidth))
else
txt=general.sprintf([[{?6447:111?}]], wlanscan.get_channelwidth(band, g_channelwidth))
end
end
return txt
end
function get_legend(band, withstoer,showradar)
local str = [[
<div class='Legend_Pos'>
<div class='Legend_right'>
<div class='show_interfere'>
<div><img src='/css/default/images/wlan_legend_frame.gif'/>&nbsp;<span id='uiChannelWidth'>]]..get_channelwidth_text(band)..[[</span></div>
<div><img src='/css/default/images/wlan_legend_other_stoer.gif'/>&nbsp;{?6447:594?}</div>
</div>
<div id = 'uiRadarLegend' style = 'display:none;'>
<div class='hide_interfere'>&nbsp;</div>
<div class='hide_interfere'>&nbsp;</div>
<div><img src='/css/default/images/wlan_legend_verbotsschild.gif'/>&nbsp;{?6447:896?}</div>
</div>
</div>
<div class='Legend_left'>]]
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
str = str..[[<div><img src='/css/default/images/wlan_legend_own_ap.gif'/>&nbsp;{?6447:650?}</div>]]
else
str = str..[[<div><img src='/css/default/images/wlan_legend_own_ap.gif'/>&nbsp;{?6447:93?}</div>]]
end
else
str = str..[[<div><img src='/css/default/images/wlan_legend_own_ap.gif'/>&nbsp;{?6447:773?}</div>]]
end
str = str..[[
<div><img src='/css/default/images/wlan_legend_other_ap.gif'/>&nbsp;{?6447:965?}</div>
<div><img src='/css/default/images/wlan_legend_stoer_v2.gif'/>&nbsp;{?6447:803?}</div>
</div>
</div>
<div class='Legend_Pos_switch'>
<div>
<a href="" onclick="return OnClickStoerer();">
<span class = 'show_interfere'>{?6447:8004?}</span>
<span class = 'hide_interfere'>{?6447:290?}</span>
</a>
</div>
</div>]]
return str
end
g_channel_usage = {}
g_channel_usage_stoer ={}
g_global_left=12
function get_col_pos(band, channel)
local channels = wlanscan.band24.channels
local col_pos = wlanscan.band24.col_pos
if (band=="5") then
channels = wlanscan.band5.channels
col_pos = wlanscan.band5.col_pos
end
for i=1,#channels,1 do
if (channels[i]==channel) then
return col_pos[i]-g_global_left
end
end
return col_pos[1]-g_global_left
end
function write_blue_frame()
if config.WLAN_RADIOSENSOR then
box.out([[
<div id='uiBlueFrame' class='blueframe' style='display:none;'>
<div class='blueframe_top'></div>
<div class='blueframe_bottom'></div>
</div>
]])
end
end
function write_col_own_ap()
box.out([[
<div id='uiOwnCol' class='one_col'>
<div></div>
<div class='col_own'><img src='/css/default/images/wlan_col_own_ap.png'></div>
<div></div>
</div>
]])
end
function find_blocked(channel)
local timeBlocked = wlanscan.get_time_blocked(g_wlanList,channel)
if (timeBlocked > 0) then
return true
end
return false
end
function write_col(col_class, img_top, img_mid, img_bottom, index)
box.out([[
<div class=']], col_class, [[ col]], index, [['>
<div class='col_top'><img src=']], img_top, [['></div>
<div class='col_mid'><img src=']], img_mid, [['></div>
<div class='col_bottom'><img src=']], img_bottom, [['></div>
</div>
]])
end
function write_col_interfere()
local col_class="one_col_stoer"
local img_top=[[/css/default/images/wlan_col_top_grey.png]]
local img_mid=[[/css/default/images/wlan_col_mid_grey.png]]
local img_bottom=[[/css/default/images/wlan_col_bottom_grey.png]]
box.out([[<div id='uiColsInterfere'>]])
for i=1, #wlanscan["band5"].channels, 1 do
write_col(col_class, img_top, img_mid, img_bottom, i)
end
box.out([[</div>]])
end
function write_col_normal(index)
local img_top = [[/css/default/images/wlan_col_top.png]]
local img_mid = [[/css/default/images/wlan_col_mid.png]]
local img_bottom = [[/css/default/images/wlan_col_bottom.png]]
local col_class = "one_col"
box.out([[<div id='uiCols'>]])
for i=1, #wlanscan.band5.channels, 1 do
write_col(col_class, img_top, img_mid, img_bottom, i)
end
box.out([[</div>]])
end
function get_axis()
return [[<div id='uiAxis' class='Axis_Pos'>]]
end
function get_axis_explain()
local str=[[
<div class='y_axis'>{?6447:641?}</div>
<div class='x_axis'>{?6447:921?}</div>]]
return str
end
function get_frame_pos(band, channel)
local channels = wlanscan.band24.channels
local axis_pos = wlanscan.band24.axis_pos
if (band=="5") then
channels = wlanscan.band5.channels
axis_pos = wlanscan.band5.axis_pos
end
local pos_idx=1
for i=1,#channels,1 do
if (channels[i]==channel) then
return axis_pos[i]
end
end
return axis_pos[1]
end
function get_blue_frame(cur_band, start_channel, end_channel)
local leftpos = 0
local width = 0
if cur_band == "5" then
leftpos=get_frame_pos(cur_band, start_channel)-8
width=get_frame_pos(cur_band, end_channel)-leftpos+15
else
leftpos=get_frame_pos(cur_band, start_channel)-18
width=get_frame_pos(cur_band, end_channel)-leftpos+18
end
leftpos = leftpos - g_global_left
return leftpos, width
end
function get_noise(band, channel)
local noise = {}
local noisetooltip=""
local stoerer,count_stoerer=wlanscan.get_show_stoerer(g_wlanList,band,channel)
if (count_stoerer>0) then
if (count_stoerer==1) then
noisetooltip=[[{?6447:818?}: ]]..stoerer
else
noisetooltip=[[{?6447:206?}: ]]..stoerer
end
end
if (noisetooltip~="") then
local cor=15
local width=38
if (band=="5") then
cor=6
width=26
end
local col_pos = get_col_pos(band,channel)
noise.width = width
noise.left = col_pos-cor
noise.tooltip = noisetooltip
return noise
end
return nil
end
function get_chan_tab(cur_band)
local chan_tab = {}
local start_channel = wlanscan.get_start_channel(g_wlanList, cur_band)
local end_channel = wlanscan.get_end_channel(g_wlanList, cur_band)
chan_tab.leftpos, chan_tab.width = get_blue_frame(cur_band, start_channel, end_channel)
chan_tab.used_channel = wlanscan.get_used_channel(g_wlanList, cur_band)
chan_tab.blocked_axis_pos = {}
chan_tab.NumOfAps = {}
chan_tab.NumOfAps_stoer = {}
chan_tab.noises = {}
local pos_cor = 6 + g_global_left
if cur_band == "5" then
pos_cor = 5 + g_global_left
end
local channels = wlanscan["band"..cur_band].channels
chan_tab.own_col_pos = 1
for i=1, #channels, 1 do
local chan = channels[i]
chan_tab.NumOfAps[i] = wlanscan.get_channel_usage(g_channel_usage, chan)
chan_tab.NumOfAps_stoer[i] = wlanscan.get_channel_usage(g_channel_usage_stoer, chan)
if chan_tab.used_channel == chan then
chan_tab.own_col_pos = i
chan_tab.axis_pos = wlanscan["band"..cur_band].axis_pos[i] - pos_cor
end
if (find_blocked(channels[i])) then
chan_tab.blocked_axis_pos[i] = wlanscan["band"..cur_band].axis_pos[i] - pos_cor
end
chan_tab.noises[i] = get_noise(cur_band,chan)
end
chan_tab.chanWidthText = get_channelwidth_text(cur_band)
return chan_tab
end
function write_channel_table_new(cur_band)
box.out([[
<div class='GraphBack_Pos'>
<div id='uiGraph' class='GraphBack_]], cur_band, [[ waiting'>]])
box.out(get_currChannel(cur_band))
box.out(get_axis_explain())
box.out(wlanscan.get_wait_animation('init', 'uiWaitText'), [[
<div class = 'GraphElems'>]])
write_blue_frame()
write_col_normal()
write_col_interfere()
write_col_own_ap()
box.out(get_axis(), [[
</div>
</div>]],
get_legend(cur_band, true, true), [[
</div>
</div>]])
end
function get_tabs(tab_idx)
if g_tab.notabs then return "" end
if (not g_tab.pages[tab_idx].enabled) then
for i,p in ipairs(g_tab.pages) do
if (p.enabled) then
g_tab.currtab=i
break;
end
end
end
local str = [[<ul class='tabs' id=']]..g_tab.pages[tab_idx].tabid..[[' ]]
if (g_tab.currtab~=tab_idx) then
str=str..[[ style='display:none;']]
end
str=str..[[>]]
for i,p in ipairs(g_tab.pages) do
if (p.enabled) then
if (i == tab_idx) then
str=str..[[<li class='active'>]]
else
str=str..[[<li>]]
end
str=str..[[<a href='javascript:onChangeView(]]..i..[[)'>]]
str=str..box.tohtml(p.text)
str=str..[[</a></li>]]
else
str=str..[[<li class='deactive'><span>]]
str=str..box.tohtml(p.text)
str=str..[[</span></li>]]
end
end
str=str..[[</ul><div class='clear_float'></div>]]
return str
end
function write_tabs(tab_idx,hide)
box.out(get_tabs(tab_idx))
end
function write_table_css()
local heights = {12,30,49,68,86, 106,124, 144}
for i,height in ipairs(heights) do
box.out([[
#uiGraph .c]], i, [[ .col_mid img{
height: ]], height, [[px;
}]])
end
for i,channel in ipairs(wlanscan.band5.channels) do
box.out([[
.GraphBack_5.interfere .one_col.col]], i, [[ {
left: ]], get_col_pos("5", channel) - 6, [[px;
}]])
box.out([[
.GraphBack_5.interfere .one_col_stoer.col]], i, [[ {
left: ]], get_col_pos("5", channel) + 6, [[px;
}]])
box.out([[
.GraphBack_5 .one_col.col]], i, [[ {
left: ]], get_col_pos("5", channel), [[px;
}]])
end
for i,channel in ipairs(wlanscan.band24.channels) do
box.out([[
.GraphBack_24.interfere .one_col.col]], i, [[ {
left: ]], get_col_pos("24", channel) - 6, [[px;
}]])
box.out([[
.GraphBack_24.interfere .one_col_stoer.col]], i, [[ {
left: ]], get_col_pos("24", channel) + 6, [[px;
}]])
box.out([[
.GraphBack_24 .one_col.col]], i, [[ {
left: ]], get_col_pos("24", channel), [[px;
}]])
end
for i=#wlanscan.band24.channels + 1, #wlanscan.band5.channels, 1 do
box.out([[
.GraphBack_24 .col]], i, [[ {
left: ]], get_col_pos("24", 1), [[px;
display:none;
}]])
end
end
function write_channel_both()
box.out(get_tabs(1))
box.out(get_tabs(2))
if g_active then
write_channel_table_new("24")
else
write_channel_table_new("5")
end
end
function write_channel_table()
if (g_is_double_wlan) then
write_channel_both()
else
write_channel_table_new(g_band)
end
end
function get_class()
if (g_is_double_wlan) then
return [[ class="correct_pos" ]]
end
return ""
end
function get_wait_text(state, cur_band)
if cur_band == "5" then
if state == "3" then
return wlanscan.get_wait_text('radar')
elseif state ~="0" then
return wlanscan.get_wait_text('net')
end
elseif state ~="0" then
return wlanscan.get_wait_text('net')
end
return nil
end
g_ajax = false
if box.get.useajax then
g_ajax = true
end
if box.post.useajax then
g_ajax = true
end
if g_ajax then
local chan_tab = {}
chan_tab[1] = {}
chan_tab[2] = {}
local tab_ind = 1
if g_band == "5" then
tab_ind = 2
end
chan_tab[tab_ind].waitText = get_wait_text(g_ap_env_state, g_band)
if g_is_double_wlan then
chan_tab[2].waitText = get_wait_text(g_ap_env_state, "5")
end
local wlan_sta = net_devices.create_configured_sta(false)
--local wlan_env_list = {}
local wlan_env_list = wlanscan.create_wlan_scan_table({},false,false,false, true)
if g_ap_env_state == "0" or g_is_double_wlan and g_ap_env_state == "3" then
g_wlanList = wlanscan.get_wlan_scan_list()
if (g_wlanList) then
table.sort(g_wlanList, compareByRssi)
end
wlan_env_list = wlanscan.create_wlan_scan_table(g_wlanList,false,false,false, false)
init()
chan_tab[tab_ind] = get_chan_tab(g_band)
if g_is_double_wlan and g_ap_env_state == "0" then
chan_tab[2] = get_chan_tab("5")
end
if is_wlan_rep_mode() then
net_devices.InitNetList()
wlan_sta = net_devices.create_configured_sta(true)
end
end
require"js"
local ajax_table = {
chan_tab = chan_tab,
ScanState = g_ap_env_state,
WlanList = wlan_env_list,
WlanSta = wlan_sta
}
if is_wlan_rep_mode() then
ajax_table.WlanSta = wlan_sta
end
box.out(js.table(ajax_table))
box.end_page()
else
init()
end
function get_auto_radar_avail()
if not g_is_double_wlan and (g_band ~= "5" or g_channel~="0") then
return [[ style="display:none;" ]]
end
if (g_is_double_wlan and g_channel_scnd~="0") then
return [[ style="display:none;" ]]
end
return ""
end
function write_auto_radar()
local checked = ""
if g_auto_radar == "1" then
checked = " checked "
end
if config.WLAN.has_5ghz_band and (config.WLAN.GUI_IS_REPEATER or general.is_expert()) then
box.out([[
<div id="uiViewINCLRadar" class="row"]], get_auto_radar_avail(), [[>
<input type="checkbox" id="uiViewRadar" name="useradar" ]], checked, [[>
<label for="uiViewRadar">{?6447:194?}</label>
</div>]])
end
end
function view1213()
if g_auto_chan_1213_ext then
box.out([[
<div id="uiViewINCL1213" style=" ]], get_1213_avail(), [[" class="row">]]
)
box.out([[
<input type="checkbox" id="uiView1213" name="use1213" ]], get_1213(), [[>
<label for="uiView1213">{?6447:791?}</label>]]
)
box.out([[</div>]])
end
end
function get_wlan24_option_table()
local option_table = {}
table.insert(option_table, {mode="23", name = [[{?6447:234?}]]})
table.insert(option_table, {mode="24", name = [[{?6447:815?}]]})
table.insert(option_table, {mode="25", name = [[{?6447:720?}]]})
return option_table
end
function write_wlan_select(option_table, suffix)
local name = "wlanmode"
local id = "uiView_Mode"
if suffix and suffix ~= "" then
name = name..suffix
id = id..suffix
end
if not option_table then
option_table = get_wlan24_option_table()
end
box.out([[
<label for="]], id, [[">{?g_txtWlanStandard?}</label>
<select class="big" id="]], id, [[" name="]], name, [[" onchange="OnWlanMode(this.value)">]])
for i,option in ipairs(option_table) do
box.out([[<option value="]], option.mode, [["]], get_selected_wlanmode(option.mode), [[>]], option.name, [[</option>]])
end
box.out([[
</select>
]])
end
function write_300MBit_div()
if box.query("wlan:settings/WDS_enabled") == "0" or box.query("wlan:settings/WDS_hop") == "0" then
box.out([[
<div id="ui300MBitProSec" style="]]) write_300MBit_avail() box.out([[" class="row">
<input type="checkbox" onclick="OnChgBandwidth(this.checked)" id="uiView300MBitProSec" ]]) write_300MBit() box.out([[ name="use300Mbit">&nbsp;
<label for="uiView300MBitProSec">]]) write_300MBit_rate() box.out([[</label>
<div id="ui300MbitCoexist" class="formular" style="]], get_300MBitCoexist_avail(), [[">
<input type="checkbox" id="uiView300MBitCoexist" ]]) write_300MBitCoexist() box.out([[ name="use300MbitCoexist" style="" ]]) write_300MBitCoexist_enabled() box.out([[>&nbsp;
<label for="uiView300MBitCoexist">{?6447:27?}</label>
</div>
</div>
]])
end
end
function write_mon(name, band, suffix, option_table, write_freq)
if suffix and suffix ~= "" then
suffix = "_"..suffix
else
suffix = ""
end
if name and name ~= "" then
box.out([[<h4>]], name, [[</h4>]])
end
box.out([[
<div class="row" >]])
write_wlan_select(option_table, suffix)
box.out([[
</div>]])
if write_freq then
box.out([[
<div class="row">
<label>{?6447:284?}</label>
<span id="uiFreqBand">]]) write_freq_band(g_band) box.out([[</span>
</div>]])
end
box.out([[
<div class="row">
<label for="uiChannels]], suffix, [[">{?g_txtWlanChannel?}</label>
<span id="uiChannelsDiv]], suffix, [[">]],
get_channels(band, g_current_channelwidth),
[[</span>
</div>]])
end
function write_mon_double()
box.out([[
<div id="uiDoubleMon">
<div id="uiDoubleMon_24" class="tborder">]])
write_mon([[{?6447:11?}]], "24")
view1213()
if not config.WLAN.has_coexistence then
write_300MBit_div()
end
box.out([[
</div>
<div id="uiDoubleMon_5" class="tborder2">]])
local option_table = {}
table.insert(option_table, {mode="52", name = [[{?6447:454?}]]})
if config.WLAN.has_11ac then
table.insert(option_table, {mode="53", name = [[{?6447:187?}]]})
end
write_mon([[{?6447:509?}]], "5", "scnd", option_table)
write_auto_radar()
box.out([[
</div>
</div>
]])
end
function write_mon_single()
box.out([[
<div id="uiSingleMon">]])
local option_table = get_wlan24_option_table()
if config.WLAN.has_5ghz_band then
table.insert(option_table, {mode="52", name = [[{?6447:210?}]]})
if config.WLAN.has_11ac then
table.insert(option_table, {mode="53", name = [[{?6447:361?}]]})
end
end
write_mon("", g_band, "", option_table, true)
view1213()
write_auto_radar()
box.out([[
</div>]])
end
function write_rep_view()
if not is_wlan_rep_mode() then
return
end
box.out([[
<div id="uiViewAll">
<h4>{?6447:201?}</h4>
<div id="uiWlanConfiguredList">]],
net_devices.create_configured_sta(false), [[
</div>
<h4>{?6447:628?}</h4>
<div>]])
if config.GUI_IS_POWERLINE then
box.out([[<p>{?6447:734?}</p>]])
else
box.out([[<p>{?6447:837?}</p>]])
end
if g_is_double_wlan then
box.out([[
<div class="formular">
<dl class="mywlandata wide">
<dt>
{?6447:632?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_ap")), [[</span>
</dt>
<dt>
{?6447:966?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_ap_scnd")), [[</span>
</dt>
<dd>
{?6447:48?}
</dd>
<dt>
{?6447:604?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_repeater")), [[</span>
</dt>
<dt>
{?6447:922?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_repeater_scnd")), [[</span>
</dt>
<dd>]])
if config.GUI_IS_POWERLINE then
box.out([[{?6447:524?}]])
else
box.out([[{?6447:679?}]])
end box.out([[
</dd>
<dt>
{?6447:3055?} <span>]], box.query("wlan:settings/ipaddress"), [[</span>
</dt>
<dd>]])
if config.GUI_IS_POWERLINE then
box.out([[{?6447:180?}]])
else
box.out([[{?6447:727?}]])
end box.out([[
</dd>
</dl>
</div>
]])
else
box.out([[
<div class="formular">
<dl class="mywlandata">
<dt>
{?6447:661?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_ap")), [[</span>
</dt>
<dd>
{?6447:140?}
</dd>
<dt>
{?6447:38?} <span>]], str_my_wlan_mac(box.query("wlan:settings/wlanmac_repeater")), [[</span>
</dt>
<dd>]])
if config.GUI_IS_POWERLINE then
box.out([[{?6447:543?}]])
else
box.out([[{?6447:574?}]])
end box.out([[
</dd>
<dt>
{?6447:294?} <span>]], box.query("wlan:settings/ipaddress"), [[</span>
</dt>
<dd>]])
if config.GUI_IS_POWERLINE then
box.out([[{?6447:595?}]])
else
box.out([[{?6447:176?}]])
end box.out([[
</dd>
</dl>
</div>]])
end
box.out([[
</div>
</div>
]])
end
function write_box_view()
if is_wlan_rep_mode() then
return
end
box.out([[
<div id="uiViewAll">
<p>]])
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[{?6447:844?}]])
else
box.out([[{?6447:7872?}]])
end
else
box.out([[{?6447:612?}]])
end box.out([[
</p>
<h4>{?6447:795?}</h4>
<p><input type="radio" name="ChannelSelect" value="auto" id="uiAutoChannel" onclick="return OnChgMode('auto')"]], get_mode("auto"), [[>&nbsp;<label for="uiAutoChannel">{?6447:712?}</label></p>
<p><input type="radio" name="ChannelSelect" value="manu" id="uiManuChannel" onclick="return OnChgMode('manu')"]], get_mode("manu"), [[>&nbsp;<label for="uiManuChannel">{?6447:64?}</label></p>
<div id="uiManuData" class="formular">]])
if g_is_double_wlan then
write_mon_double()
else
write_mon_single()
end
local style = ""
if not general.is_expert() then
style = [[ style="display:none"]]
end
box.out([[<div id="uiExpertFeatures"]], style, [[>]])
if not config.WLAN.has_coexistence and not g_is_double_wlan then
write_300MBit_div()
else
box.out([[
<div id="ui300MbitCoexist" class="row" style="]], get_300MBitCoexist_avail(), [[">
<input type="checkbox" id="uiView300MBitCoexist" onclick="OnChgCoexist(this.checked)" ]]) write_300MBitCoexist() box.out([[ name="use300MbitCoexist" style="" ]]) write_300MBitCoexist_enabled() box.out([[>&nbsp;
<label for="uiView300MBitCoexist">{?6447:482?}</label>
<div class="formular">{?6447:98?}</div>
</div>
]])
end
if config.WLAN.has_tx_autopower then
box.out([[
<div style="]]) write_auto_power_avail() box.out([[" class="row">
<input type="checkbox" id="uiViewAutoPower" ]]) write_auto_power() box.out([[ name="auto_power">&nbsp;<label for="uiViewAutoPower">{?6447:86?}</label>
</div>]])
end
box.out([[
<div>
<label for="uiView_PowerLevel">{?6447:61?}</label>
<select ]], get_class(), [[id="uiView_PowerLevel" name="auto_power_level">
<option value="1" ]], get_autopower_select("1"), [[>{?6447:382?}</option>
<option value="2" ]], get_autopower_select("2"), [[>{?6447:264?}</option>
<option value="3" ]], get_autopower_select("3"), [[>{?6447:910?}</option>
<option value="4" ]], get_autopower_select("4"), [[>{?6447:333?}</option>
<option value="5" ]], get_autopower_select("5"), [[>{?6447:947?}</option>
</select>
</div>]])
if not is_wlan_rep_mode() then
box.out([[
<div class="row">
<input type="checkbox" id="uiViewIpTv" ]]) write_iptv() box.out([[ name="iptv">&nbsp;<label for="uiViewIpTv">{?6447:931?}</label>
</div>]])
end
box.out([[
</div>
</div>
</div>
]])
end
if is_wlan_rep_mode() then
g_page_help = "hilfe_monitor.html"
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<style type="text/css">
.Legend_Pos {
position:relative;
padding-left:71px;
padding-right:60px;
top:295px;
font-size:11px;
color:#334C5A;
}
.Legend_Pos_switch {
position:absolute;
left:70px;
top:370px;
width:495px;
border-top:1px solid #cfcfcf;
height:20px;
}
.Legend_Pos_switch div{
margin-top:10px;
}
.Legend_Pos_switch a{
color:#4b8ac4;
}
.Legend_Pos div.Legend_right {
float:right;
width:330px;
}
.Legend_Pos div.Legend_left {
float:left;
width:150px;
}
.interfere .show_interfere {
display:inline;
}
.interfere .hide_interfere {
display:none;
}
.show_interfere {
display:none;
}
.GraphBack_24 #uiRadarLegend {
display:none;
}
.Legend_Pos div {
height:20px;
}
.Legend_Pos img {
height: 16px;
width: 16px;
}
.Legend_Pos div.Legend_Band {
position:absolute;
top:39px;
right:26px;
font-size:18px;
height: 20px;
color: rgb(196, 198, 190);
text-align: right;
float:clear;
}
.Axis_Pos{
position:relative;
text-align:center;
top:231px;
font-size:10px;
}
.Axis_Used_Chan, .Axis_block {
background-position:center center;
background-repeat:no-repeat;
position:absolute;
width:22px;
height:17px;
padding-top:3px;
}
.waiting .Axis_Used_Chan {
display:none;
}
.Axis_Used_Chan {
background-image:url(/css/default/images/wlan_axis_blue.gif);
color:#ffffff;
}
.Axis_block {
background-image:url(/css/default/images/wlan_radar_ani.gif);
}
#uiChannelTable div.wait {
position:absolute;
top:100px;
left:168px;
width:310px;
text-align:center;
}
.ready .wait{
display:none;
}
.ready .GraphElems {
display:inline;
}
.waiting .wait{
display:inline;
}
.waiting .GraphElems {
display:none;
}
.blueframe {
font-size:0px;
position:absolute;
/*top:207px;*/
top:223px;
display:none;
}
.interfere .blueframe {
display:inline;
}
.blueframe_bottom {
width:100%;
font-size:0px;
border:2px solid #90bee7;
border-top:2px solid #a2d3ff;
height:20px;
}
.blueframe_top {
width:100%;
font-size:0px;
height:3px;
background-color:#90b8e0;
border:2px solid #90b8e0;
}
.GraphBack_Pos {
position:relative;
/*height:360px;*/
height:424px;
}
.GraphBack_24,.GraphBack_5 {
position:absolute;
top: 0px;
/*left:74px;*/
left:0px;
/*width:600px;*/
width:622px;
/*height:347px;*/
height:411px;
z-index:0;
background-image:url(/css/default/images/wlan_graph_24_v2.gif);
background-position:center top;
background-repeat:no-repeat;
}
.GraphBack_5 {
background-image:url(/css/default/images/wlan_graph_5_v2.gif);
}
show_noise {
display:none;
}
.interfere .show_noise {
z-index:-1;
background-image: url(/css/default/images/wlan_stoer_back.gif);
background-repeat: no-repeat;
position:absolute;
bottom:8px;
height:152px;
}
.one_col,.one_col_stoer, .col_top, .col_bottom, .col_mid, .col_own {
font-size:0px;
padding:0px;
margin:0px
}
.one_col, .one_col_stoer {
position:absolute;
/*bottom:135px;*/
bottom:183px;
}
.col_top {
}
.col_mid{
}
.col_bottom{
}
.col_top img, .col_mid img {
width:9px;
}
.GraphBack_5 #uiColsInterfere{
display: none;
}
.GraphBack_5.interfere #uiColsInterfere{
display: inline;
}
.GraphBack_24 #uiColsInterfere{
display: none;
}
.GraphBack_24.interfere #uiColsInterfere{
display: inline;
}
.c0 {
display:none;
}
<?lua write_table_css() ?>
.col_top img, .col_mid img {
width:9px;
}
.col_own img,
.col_bottom img {
width:16px;
}
.one_col_stoer .col_bottom img {
width:9px;
}
.x_axis {
position:absolute;
top:275px;
left:345px;
text-align:right;
width:220px;
font-size:11px;
}
.y_axis {
position:absolute;
top:50px;
left:49px;
font-size:11px;
}
.CssBlueInfoText {
color:#334C5A;
font-weight:bold;
font-size:13px;
position:absolute;
width: 350px;
top:20px;
left:160px;
}
.CssBlueNumberInfo {
color:#3880c8;
font-weight:bold;
}
.formular div.row {
padding:2px 0px;
}
.formular div.tborder {
padding:5px;
}
.formular div.tborder2 {
padding:5px;
border-left:1px solid #C6C7BE;
border-right:1px solid #C6C7BE;
border-bottom:1px solid #C6C7BE;
border-top:none;
}
.formular select.big {
width: 120px;
}
.formular select.correct_pos {
margin-left:5px;
}
dl.mywlandata {
margin-top: 5px;
margin-bottom: 3px;
}
dl.mywlandata dt {
position:relative;
}
dl.mywlandata dt span {
font-weight: bold;
position:absolute;
left:150px;
}
dl.mywlandata dd {
margin: 3px 5px 5px 25px;
}
dl.wide dt span {
left:200px;
}
</style>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
var g_active =<?lua box.out(tostring(g_active)) ?>;
var g_active_scnd =<?lua box.out(tostring(g_active_scnd)) ?>;
var g_channel =<?lua box.out(tonumber(g_channel) or 0) ?>;
var g_channelScnd =<?lua box.out(tonumber(g_channel_scnd) or 0) ?>;
var g_isDoubleWlan =<?lua box.out(tostring(g_is_double_wlan)) ?>;
var g_channelWidth = "<?lua box.out(tostring(g_current_channelwidth)) ?>";
var g_band ="<?lua box.out(g_band) ?>";
var g_wlan_mode ="<?lua box.out(tonumber(g_wlan_mode) or 0) ?>";
var g_expertMode =<?lua box.out(tostring(general.is_expert())) ?>;
var g_cur_Tab =<?lua box.out(g_active)?>?"24":"5";
var g_wds_wrong_channel="{?6447:151?}";
var g_wds2_wrong_channel="{?6447:6025?}";
var g_wds_onlyexpert = "{?6447:157?} ";
var g_wds2_onlyexpert = "{?6447:322?} ";;
var g_wds_no_auto ="{?6447:688?}";
var g_WDS ="<?lua box.out(config.WLAN_WDS and box.query('wlan:settings/WDS_enabled','0') or '0') ?>";
var g_isWds2Repeater = <?lua box.js(tostring(config.WLAN_WDS2 and box.query('wlan:settings/WDS_enabled') == '1')) ?>;
var g_wds2UplinkBand = "<?lua net_devices.add_wlan_to_list() box.js(net_devices.get_wds2_uplink_band() or '') ?>";
var g_wlanAta = <?lua box.js(box.query('box:settings/opmode') == 'opmode_wlan_ip') ?>;
var g_QueryVars = {
status: { query: "wlan:settings/APEnvStatus" },
channel: { query: "wlan:settings/channel" },
used_channel: { query: "wlan:settings/used_channel" }
}
var g_ap_env_state ="<?lua box.out(tostring(g_ap_env_state)) ?>";
function updateTable(CurPageIdx)
{
var curTabData = g_tab_data[0];
var tab_class = "GraphBack_24";
if (CurPageIdx==2)
{
tab_class = "GraphBack_5";
curTabData = g_tab_data[1];
}
var graph = jxl.get("uiGraph");
jxl.removeClass(graph, "waiting GraphBack_24 GraphBack_5");
jxl.addClass(graph, tab_class);
if (curTabData.waitText)
{
jxl.setText("uiWaitText", curTabData.waitText);
jxl.addClass(graph, "waiting");
return;
}
else
{
jxl.addClass(graph, "ready");
}
updateCols("uiCols", curTabData.NumOfAps);
updateCols("uiColsInterfere", curTabData.NumOfAps_stoer, true);
<?lua
if config.WLAN_RADIOSENSOR then
box.out([[
jxl.show("uiBlueFrame");
jxl.setStyle("uiBlueFrame", "left", curTabData.leftpos + "px");
jxl.setStyle("uiBlueFrame", "width", curTabData.width + "px");
jxl.removeClassRegExp("uiOwnCol", "col\\d+");
jxl.addClass("uiOwnCol", "col" + curTabData.own_col_pos);
]])
end
?>
var oldAxisRow = jxl.get("uiAxis");
var axisRow = oldAxisRow.cloneNode(false);
if (oldAxisRow.parentNode) {
oldAxisRow.parentNode.replaceChild(axisRow, oldAxisRow);
}
jxl.hide("uiRadarLegend");
jxl.setText("uiChannelWidth", curTabData.chanWidthText);
jxl.setText("uiBlueNumberInfo", curTabData.used_channel || "...");
addAxisElem("Axis_Used_Chan", curTabData.axis_pos, curTabData.used_channel);
for (var i in curTabData.blocked_axis_pos)
{
jxl.show("uiRadarLegend");
addAxisElem( "Axis_block", curTabData.blocked_axis_pos[i]);
}
for (var i in curTabData.noises)
{
addNoise(curTabData.noises[i])
}
}
function addNoise(noiseData)
{
var noise = createDiv("show_noise", "left:" + noiseData.left + "px;width:" + noiseData.width + "px");
noise.title = noiseData.tooltip;
jxl.get("uiAxis").appendChild(noise);
}
function addAxisElem(cssClass, xCoord, text)
{
var axisElem = createDiv(cssClass, "left:" + xCoord + "px;");
jxl.setText(axisElem, text || "");
jxl.get("uiAxis").appendChild(axisElem);
}
function createDiv(cssClass, style)
{
var div = document.createElement("div");
jxl.addClass(div, cssClass);
div.style.cssText = style;
return div;
}
function getColTooltipText(count, isInterfere)
{
var text = ""
if (isInterfere)
{
text = "{?6447:810?}";
if (count == 1)
text = "{?6447:900?}";
else
text = jxl.sprintf("{?6447:888?}", count);
}
else
{
text = "{?6447:165?}";
if (count == 1)
text = "{?6447:291?}";
else if (count > 1)
text = jxl.sprintf("{?6447:4385?}", count);
}
return text;
}
function updateCols(id, apNums, isInterfere)
{
var cols = jxl.get(id).children;
var n = cols.length;
for(i=0; i<n; i++)
{
var count = apNums[i];
var mid = cols[i].children[1];
var mid_img = mid.firstChild;
if (!count || count < 0)
count = 0;
mid.title = getColTooltipText(count, isInterfere);
if (count > 8)
count = 8;
jxl.removeClassRegExp(cols[i], "c\\d+");
jxl.addClass(cols[i], "c" + count);
}
}
var json = makeJSONParser();
function cbRefresh(response)
{
if (response && response.status == 200)
{
if (response.responseText != "")
{
var resp = json(response.responseText || "null");
if (resp)
{
g_tab_data = resp.chan_tab
var view = 1;
if (g_isDoubleWlan)
{
view = g_cur_Tab=="24"?1:2;
}
else
{
//view = (g_band=="5") ? 2 : 1;
view = ("<?lua box.out(g_band) ?>"=="5") ? 2 : 1;
}
updateTable(view);
zebra();
if (resp.ScanState != "0")
{
if (timeOutExceeded) {
jxl.setHtml("uiWlanCurList", "<?lua wlanscan.create_wlan_scan_table(g_wlanList,true,false,false,false) ?>");
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
return;
}
window.setTimeout("doRequestRefreshData()", 3000);
}
if (resp.ScanState == "0" || resp.ScanState == "3")
jxl.setHtml("uiWlanCurList", resp.WlanList || "");
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
jxl.setHtml("uiWlanConfiguredList",resp.WlanSta || "");
return;
}
}
window.setTimeout("doRequestRefreshData()", 2000);
}
else
{
}
}
function doRequestRefreshData()
{
var my_url = "/wlan/radiochannel.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1";
ajaxGet(my_url, cbRefresh);
}
var g_AktualTimeout=1000000;
var timeOutExceeded=false;
function cbTimeOut()
{
timeOutExceeded = true
}
function init()
{
jxl.disable("uiIdRenewList");
var isAutoActive = <?lua box.out(get_mode("auto") ~= "") ?>;
EnableManuBlock(isAutoActive);
window.setTimeout(cbTimeOut, g_AktualTimeout);
<?lua
if box.get.refresh then
box.out([[window.setTimeout(doRequestRefreshData, 6000);]])
else
box.out([[doRequestRefreshData();]])
end
?>
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
function OnDoRefresh()
{
if(!confirm("{?6447:972?}"))
return false;
}
function EnableManuBlock(isAutoActive)
{
jxl.disableNode("uiManuData",isAutoActive);
if (!isAutoActive)
{
var disable24GHz = g_wds2UplinkBand == "1" || g_wlanAta;
var disable5GHz = g_wds2UplinkBand == "2";
if (disable24GHz || disable5GHz) {
jxl.disableNode("ui300MBitProSec", disable24GHz);
jxl.disableNode("ui300MbitCoexist", disable24GHz);
}
else {
if (<?lua box.out(config.WLAN.has_coexistence)?>)
{
var bCoexist=("<?lua write_300MBitCoexist_enabled()?>"=="disabled");
jxl.setDisabled("uiView300MBitCoexist",bCoexist);
}
}
if (g_isDoubleWlan)
{
jxl.disableNode("uiDoubleMon_24",!g_active);
if (g_active && disable24GHz) {
jxl.disableNode("uiDoubleMon_24", true);
}
var bCoexist = jxl.getEnabled("uiView300MBitCoexist");
jxl.disableNode("uiExpertFeatures",false);
jxl.enableNode("uiView300MBitCoexist",bCoexist);
jxl.disableNode("uiDoubleMon_5",!g_active_scnd);
if (g_active_scnd && disable5GHz) {
jxl.disableNode("uiDoubleMon_5", true);
}
}
else {
if (disable24GHz || disable5GHz) {
jxl.disableNode("uiSingleMon", true);
}
}
}
return;
}
function check_wds()
{
if ( g_WDS == "1" && jxl.getChecked("uiAutoChannel"))
{
alert("{?6447:838?}");
jxl.setChecked("uiManuChannel",true);
return false;
}
return true
}
function check_wds_chan()
{
if ((g_WDS == "1" || g_isWds2Repeater) && (g_band=="5" || g_isDoubleWlan))
{
var channel=jxl.getValue("uiChannels");
var active = g_active;
if (g_isDoubleWlan)
{
channel=jxl.getValue("uiChannels_scnd");
active = g_active_scnd;
}
if (g_WDS == "1")
{
if (IsNoValidWdsChannel(channel,"5") && active)
{
alert(g_wds_wrong_channel);
return false;
}
}
if (g_isWds2Repeater && !IsAutoChannel(channel))
{
if (IsNoValidWdsChannel(channel,"5") && active)
{
alert(g_wds2_wrong_channel);
return false;
}
}
}
return true;
}
function check_wds_auto()
{
var err=false;
if ( g_WDS == "1")
{
if (g_isDoubleWlan)
{
if ((jxl.getValue("uiChannels")=="0" && g_active) || (jxl.getValue("uiChannels_scnd")=="0" && g_active_scnd))
{
err=true;
}
}
else
{
if (jxl.getValue("uiChannels")=="0" && g_active)
{
err=true;
}
}
}
if (err)
{
alert(g_wds_no_auto);
return false;
}
return true;
}
function check_for_radar()
{
var channel=jxl.getValue("uiChannels");
<?lua
if config.WLAN.has_coexistence or g_is_double_wlan then
box.out([[var isHT40 = true;]])
else
box.out([[var isHT40 = jxl.getChecked("uiView300MBitProSec");]])
end
?>
if (g_isDoubleWlan)
{
channel=jxl.getValue("uiChannels_scnd");
}
var min_Chan=120;
if (isHT40)
{
min_Chan=116;
}
if (channel>=min_Chan && channel<=128)
{
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[var msg="{?6447:995?}"]])
else
box.out([[var msg="{?6447:3654?}"]])
end
else
box.out([[var msg="{?6447:368?}"]])
end
?>
if (!confirm(msg))
{
return false;
}
}
return true;
}
function uiDoOnMainFormSubmit()
{
if (!check_wds()) return false;
if ((!g_isDoubleWlan || (g_isDoubleWlan && g_active_scnd)) && !check_for_radar()) return false;
return check_wds_chan();
}
function uiOnChangeInput(value,id)
{
jxl.setText(id,value.length);
}
var g_showstoerer=false;
function OnClickStoerer()
{
g_showstoerer=!g_showstoerer
if (g_showstoerer)
jxl.addClass("uiGraph", "interfere");
else
jxl.removeClass("uiGraph", "interfere");
if (g_isDoubleWlan)
{
//onChangeView(g_cur_Tab=="24"?1:2);
return false;
}
if (g_band=="24")
{
//jxl.display("uiGraph24",!g_showstoerer);
//jxl.display("uiGraph24_stoer",g_showstoerer);
//jxl.display("uiColsInterfere",g_showstoerer);
} else {
//jxl.display("uiGraph5",!g_showstoerer);
//jxl.display("uiGraph5_stoer",g_showstoerer);
}
return false;
}
function ResetSettings()
{
jxl.setSelection("uiView_PowerLevel","1");
jxl.setChecked("uiViewAutoPower",false);
jxl.setChecked("uiView1213",false);
jxl.setChecked("uiViewRadar",true);
jxl.setChecked("uiViewIpTv",false);
jxl.setChecked("uiView300MBitProSec",true);
jxl.setChecked("uiViewTurbo",true);
jxl.setChecked("uiViewWmm",false);
if (<?lua box.out(config.WLAN.has_coexistence)?>)
jxl.setChecked("uiView300MBitCoexist",true);
else
jxl.setChecked("uiView300MBitCoexist",false);
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('24', g_current_channelwidth) ?>");
jxl.setSelection("uiChannels", "0");
jxl.setText("uiFreqBand","<?lua write_freq_band('24')?>");
jxl.setSelection("uiChannels_scnd", "0");
g_band="24"
g_wlan_mode="25"
jxl.setSelection("uiView_Mode",g_wlan_mode);
<?lua
if g_is_double_wlan and config.WLAN.has_11ac then
box.out([[jxl.setSelection("uiView_Mode_scnd", "53");]])
end
?>
}
function IsAutoChannel(channel)
{
return channel == "0";
}
function IsNoValidWdsChannel(channel, band)
{
var i_channel = parseInt(channel);
if(band == "5")
return ((i_channel < 36) || (i_channel > 48));
else
return ((i_channel < 1) || (i_channel > 13));
}
function OnChgMode(mode)
{
if (mode=="auto")
{
if (!check_wds()) return false;
ResetSettings();
EnableManuBlock(true);
}
if (mode=="manu")
{
EnableManuBlock(false);
}
return true;
}
function OnWlanMode(mode)
{
var channelWidth = "20";
<?lua
if config.WLAN.has_coexistence then
box.out([[
if (g_channelWidth == "80")
{
channelWidth = "40";
}
else
{
channelWidth = g_channelWidth;
}
]])
else
box.out([[
if (jxl.getChecked("uiView300MBitProSec"))
{
channelWidth = "40";
}
]])
end
?>
var show300MBit=true;
if (mode=="24" && !g_active_scnd) {
show300MBit=false;
}
jxl.display("ui300MBitProSec",show300MBit);
g_wlan_mode=mode;
if (mode=="52" && !g_isDoubleWlan) {
g_band="5";
<?lua
if config.GUI_IS_REPEATER then
if config.GUI_IS_POWERLINE then
box.out([[alert("{?6447:599?}");]])
else
box.out([[alert("{?6447:296?}");]])
end
else
box.out([[alert("{?6447:690?}");]])
end
if g_is_double_wlan then
box.out([[jxl.display("uiViewINCLRadar",IsAutoChannel(jxl.getValue("uiChannels_scnd")));]])
else
box.out([[jxl.display("uiViewINCLRadar",IsAutoChannel(jxl.getValue("uiChannels")));]])
end
?>
ChangeChannellist(channelWidth);
jxl.display("uiViewINCL1213",false);
jxl.setText("uiFreqBand","<?lua write_freq_band('5') ?>");
return true;
}
if (mode=="53")
{
<?lua
if config.WLAN.has_coexistence then
box.out([[ChangeChannellist("80");]])
else
box.out([[
ChangeChannellist(channelWidth);
]])
end
?>
return true;
}
jxl.setText("uiFreqBand","<?lua write_freq_band('24') ?>");
g_band="24";
ChangeChannellist(channelWidth);
if (g_expertMode)
{
jxl.display("uiViewINCL1213",IsAutoChannel(jxl.getValue("uiChannels")));
if (mode!="52" && mode!="53")
jxl.display("uiViewINCLRadar", false);
}
return true;
}
function OnChannel(band,channel)
{
if (g_WDS == "1" && IsNoValidWdsChannel(channel,band) ||
g_isWds2Repeater && band == "5" && IsNoValidWdsChannel(channel,band))
{
var channel_warning="";
if (!g_isWds2Repeater && IsAutoChannel(channel)) {
channel_warning=g_wds_no_auto;
}
if (!IsAutoChannel(channel)) {
if (g_isWds2Repeater) {
channel_warning=g_wds2_wrong_channel;
}
else {
channel_warning=g_wds_wrong_channel;
}
}
if(!g_expertMode && channel_warning) {
if (g_isWds2Repeater) {
channel_warning+=g_wds2_onlyexpert;
}
else {
channel_warning+=g_wds_onlyexpert;
}
}
if (channel_warning) {
if (g_isDoubleWlan)
jxl.setSelection("uiChannels_scnd",g_channelScnd);
jxl.setSelection("uiChannels",g_channel);
alert(channel_warning);
return false;
}
}
if (band=="24" && g_expertMode)
{
jxl.display("uiViewINCL1213",IsAutoChannel(channel));
}
if (band=="5" && g_expertMode)
{
jxl.display("uiViewINCLRadar", IsAutoChannel(channel));
}
return true;
}
function OnChgCoexist(checked)
{
ChangeChannellist(g_channelWidth);
return true
}
function OnChgBandwidth(checked)
{
if (checked)
{
ChangeChannellist("40");
}
else
{
ChangeChannellist("20");
}
jxl.setDisabled("uiView300MBitCoexist",!checked);
return true
}
function ChangeChannellist(bandwidth)
{
if (g_isDoubleWlan)
{
if (bandwidth == "80")
{
<?lua
if config.WLAN.has_11ac then
box.out([[
jxl.setHtml("uiChannelsDiv_scnd", "]], get_channels('5','80'), [[");
jxl.setHtml("uiChannelsDiv", "]], get_channels('24', '40'), [[");
]])
end
?>
}
else if (bandwidth == "40")
{
jxl.setHtml("uiChannelsDiv_scnd", "<?lua write_channels('5','40') ?>");
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('24', '40') ?>");
}
else
{
jxl.setHtml("uiChannelsDiv_scnd", "<?lua write_channels('5','20') ?>");
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('24', '20') ?>");
}
jxl.setDisabled("uiChannels",!g_active);
jxl.setDisabled("uiChannels_scnd",!g_active_scnd);
return true;
}
if (g_band=="24")
{
if (bandwidth == "40")
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('24','40') ?>");
else
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('24','20') ?>");
}
else
{
if (bandwidth == "40")
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('5','40') ?>");
else
jxl.setHtml("uiChannelsDiv", "<?lua write_channels('5','20') ?>");
}
return true;
}
var g_tab_data = <?lua box.out(js.table{
{waitText = wlanscan.get_wait_text("init")},
{waitText = wlanscan.get_wait_text("init")} })?>;
function onChangeView(CurPageIdx)
{
if (CurPageIdx==1)
{
g_cur_Tab="24"
jxl.display("uiTab24",true);
jxl.display("uiTab5",false);
} else {
g_cur_Tab="5"
jxl.display("uiTab5",true);
jxl.display("uiTab24",false);
}
updateTable(CurPageIdx);
}
ready.onReady(ajaxValidation({
formNameOrIndex: "main_form",
okCallback: uiDoOnMainFormSubmit
}));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua href.write(box.glob.script) ?>" name="main_form">
<div id="content">
<?lua write_rep_view() ?>
<?lua write_box_view() ?>
<div>
<hr>
<h4>{?6447:52?}</h4>
<p>{?6447:78?}</p>
<div id="uiChannelTable">
<?lua write_channel_table() ?>
</div>
</div>
<div>
<hr>
<h4>
<?lua
if is_wlan_rep_mode() then
box.out([[{?6447:691?}]])
else
box.out([[{?6447:523?}]])
end
?>
</h4>
<div id="uiWlanListDiv">
<p>{?6447:871?}</p>
<div id="uiWlanCurList">
<?lua box.out(wlanscan.create_wlan_scan_table(g_wlanList,false,false,false, true)) ?>
</div>
<div class="rightBtn" style="display:none;">
<input type="submit" id="uiIdRenewList" name="refresh_list" value="{?6447:782?}" >
</div>
<div class="clear_float"></div>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
if not is_wlan_rep_mode() then
box.out([[<button type="submit" id="uiRefresh" name="refresh" onclick="return OnDoRefresh();">]], box.tohtml(get_refresh_txt()), [[</button>]])
end
?>
<button type="submit" id="uiApply" name="apply" >{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
