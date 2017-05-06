--[[Access denied<?lua
box.end_page()
?>]]
local flags = {}
flags.GUI_6360_WLAN_INCOMPLETE = false
flags.GUI_IS_REPEATER = false
flags.GUI_NEW_FAX = false
flags.GUI_NEW_FAX = true
flags.GUI_IS_POWERLINE = false
flags.GUI_SIP_READ_ONLY = false
flags.GUI_SIP_READ_ONLY = true
flags.GUI_LAN_GUEST = false
flags.isDebug = false
flags.is_6360 = false
flags.need_reboot=false
flags.GUI_HAS_11AC=false
flags.GUI_REMOTE_TMP=false
flags.GUI_AUTOUPDATETAB = false
flags.GUI_AUTOUPDATETAB = true
flags.no_number_area = false
flags.no_ir_pc_rss_samples = false
flags.sip_provider_international = false
flags.isp_mac_needed = false
flags.use_nat = false
flags.timezone = false
flags.sip_packetsize = false
if config.oem == "avme" then
flags.no_number_area = true
flags.no_ir_pc_rss_samples = true
flags.sip_provider_international = true
flags.isp_mac_needed = true
flags.use_nat = true
flags.timezone = true
flags.sip_packetsize = true
flags.static_net = true
end
flags.language_is_de = config.language == "de"
local interface = {}
function interface.import(dest)
dest = dest or {}
for flag, value in pairs(flags) do
dest[flag] = value
end
return dest
end
return interface
