--[[Access denied<?lua
box.end_page()
?>]]
local function lazytable(tbl, getter, vars)
local mt = getmetatable(tbl) or {}
local oldindex = mt.__index
local oldindex_isfunc = type(oldindex) == 'function'
mt.__index = function(self, key)
if vars[key] then
local result = getter(unpack(vars[key]))
self[key] = result
return result
end
if oldindex then
if oldindex_isfunc then return oldindex(self, key)
else return oldindex[key]
end
end
end
return setmetatable(tbl, mt)
end
local flags = {}
local function read_wlan_flag(varname)
return box.query("wlan:settings/feature_flags/" .. varname) == "1"
end
flags = lazytable(flags, read_wlan_flag, {
is_double_wlan = {"DBDC"},
has_11ac = {"11AC"},
has_tx_autopower = {"TX_AUTO_POWER"},
has_ht40_channelwidth = {"HT40_CHANNELWIDTH"},
has_5ghz_band = {"BAND_5GHZ"},
has_coexistence = {"COEXISTENCE"},
has_time_control = {"TIME_CONTROL"},
has_wps = {"WPS"},
has_guest_ap = {"GUEST_AP"},
has_night_time_auto_update = {"NIGHT_TIME_AUTO_UPDATE"},
has_auto_chan_12_13 = {"AUTO_CHAN_12_13_EXT"},
has_ata_mode = {"ATA_MODE"},
has_wds_2nd = {"WDS_2ND"},
is_wps_wpa_allowed = {"WPS_WPA_ALLOWED"},
has_repeater_guest_ap = {"REPEATER_GUEST_AP"},
has_security_wep_support = {"SECURITY_WEP_SUPPORT"},
default_wpa_mixed = {"DEFAULT_WPA_MIXED"}
})
return flags
