--[[Access denied<?lua
box.end_page()
?>]]
require"general"
local listquery = general.listquery
local expert_mode = box.query("box:settings/expertmode/activated") == "1"
if menu.override_expert ~= nil then expert_mode = menu.override_expert end
local oem = config.oem
menu.exists_submenu['fon'] = function()
return config.FON
end
menu.exists_page["/fon_num/dial_fonbook.lua"] = function()
return (config.CAPI_TE or config.CAPI_POTS or config.AB_COUNT > 0)
end
menu.exists_page["/fon_num/dial_foncalls.lua"] = function()
return (config.CAPI_TE or config.CAPI_POTS or config.AB_COUNT > 0)
end
menu.exists_page["/fon_num/rul_list.lua"] = function()
return not config.LTE or oem ~= 'otwo'
end
menu.exists_page["/fon_num/callthrough.lua"] = function()
return not config.LTE or oem ~= 'otwo'
end
menu.show_page["/fon_num/callthrough.lua"] = function()
return expert_mode or box.query("telcfg:settings/CallThrough/Active") == '1'
end
menu.exists_page["/fon_num/dialrul_list.lua"] = function()
return not config.DOCSIS or oem ~= 'kdg'
end
menu.exists_page["/fon_num/dialrul_provider.lua"] = function ()
return not config.DOCSIS or oem ~= 'kdg'
end
menu.show_page["/fon_num/dialrul_provider.lua"] = function()
return (box.query("telcfg:settings/UsePSTN") == '1'
and (oem == 'freenet' or expert_mode))
or (box.query("telcfg:settings/UsePSTN")
and box.query("providerlist:settings/activeprovider") == 'tonline')
end
menu.exists_page["/fon_num/sip_option.lua"] = function()
if config.DOCSIS and (oem == 'kabelbw' or oem == 'kdg') then
return box.query("sipextra:settings/gui_readonly") ~= '1'
end
return true
end
menu.exists_page["/fon_num/sip_quality.lua"] = function()
return config.FONQUALITY
end
menu.show_page["/fon_num/sip_quality.lua"] = expert_mode
menu.exists_page["/fon_num/country_prefix.lua"] = function()
return config.MULTI_COUNTRY
end
local is_dsl_modem = function()
return box.query("box:settings/opmode") == "opmode_modem"
end
local is_ip_client = function()
return box.query("box:settings/opmode")=="opmode_eth_ipclient"
end
local is_wlan_ata = function()
return box.query("box:settings/opmode") == "opmode_wlan_ip"
and box.query("wlan:settings/bridge_mode") == "bridge-ata"
end
local is_wds_repeater = function()
return box.query("wlan:settings/WDS_enabled") == "1" and box.query("wlan:settings/WDS_hop") == "1"
end
local is_umts_on = function()
return config.USB_GSM and box.query("umts:settings/enabled") == '1'
end
local gsm_on_or_pin_set = function()
return box.query("gsm:settings/PinEmpty") == '0'
or box.query("gsm:settings/ModemPresent") == '1'
end
local tethering_on_or_tethering_connected = function()
return box.query("box:settings/opmode") == "opmode_usb_tethering"
or box.query("ctlusb:settings/tethering_device") ~= ""
or box.query("box:settings/usbtethering_mode") == "1"
end
local gsm_active = function()
return box.query("gsm:settings/Established") =='1' and gsm_on_or_pin_set()
end
menu.exists_page["/internet/lanbridges.lua"] = function()
return config.DOCSIS and config.ETH_COUNT > 1
and box.query("box:settings/lanbridges_gui_hidden") == "0"
end
menu.show_page["/internet/lanbridges.lua"] = function()
return expert_mode
end
menu.exists_page["/internet/lisp.lua"] = function()
require("config")
return config.gu_type == "private" or config.gu_type == "beta" or oem ~= 'kdg'
end
menu.show_page["/internet/lisp.lua"] = function()
return expert_mode
end
menu.exists_page["/internet/ipv6.lua"] = function()
if not config.IPV6 then
return false
elseif config.DOCSIS then
return oem ~= 'kdg'
else
return true
end
end
menu.show_page["/internet/ipv6.lua"] = function()
local show_ipv6 = true
if is_ip_client() then show_ipv6 = false end
if is_dsl_modem() then show_ipv6 = false end
if config.USB_GSM and is_umts_on() then show_ipv6 = true end
if not expert_mode then show_ipv6 = false end
if ( box.query("ipv6:settings/gui_hidden") == "1") then show_ipv6 = false end
return show_ipv6
end
menu.exists_page["/internet/dns_server_enh.lua"] = function()
if config.DOCSIS then
return oem ~= 'kdg'
end
return true
end
menu.show_page["/internet/dns_server_enh.lua"] = function()
return expert_mode
end
menu.exists_page["/internet/providerservices.lua"] = function()
return config.TR069 and not config.LTE and not config.DOCSIS
end
menu.show_page["/internet/providerservices.lua"] = function()
local gui_mode = tonumber(box.query("tr069:settings/gui_mode"))
if gui_mode then
return expert_mode and gui_mode > 0
else
return expert_mode and (oem ~= 'avm' or box.query("tr069:settings/url") ~= "")
end
end
menu.exists_page["/internet/internet_settings.lua"] = function()
return not config.DOCSIS and not config.LTE
end
menu.exists_page["/internet/lte_settings.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_dsl.lua"] = function()
return false
end
menu.exists_page["/internet/docsis_settings.lua"] = function()
if config.DOCSIS then
--return oem ~= 'kdg'
return config.ETH_COUNT > 1 and config.oem == 'avm'
end
end
menu.show_page["/internet/docsis_settings.lua"] = function()
return expert_mode
end
local pppoe_or_umts_on = function()
return box.query("connection0:settings/type") == 'pppoe' or is_umts_on()
end
local dsl_or_docsis_or_lte = function()
return config.DSL or config.VDSL or config.DOCSIS or config.LTE
end
menu.exists_page["/internet/inetstat_monitor.lua"] = function()
return config.USB_GSM or dsl_or_docsis_or_lte()
end
menu.show_page["/internet/inetstat_monitor.lua"] = function()
return dsl_or_docsis_or_lte() or is_umts_on()
end
menu.exists_page["/internet/inetstat_counter.lua"] = function()
return config.USB_GSM or dsl_or_docsis_or_lte()
end
menu.show_page["/internet/inetstat_counter.lua"] = function()
return pppoe_or_umts_on() and not is_ip_client()
end
menu.exists_page["/internet/umts_settings.lua"] = function()
return config.USB_GSM or config.USB_TETHERING
end
menu.show_page["/internet/umts_settings.lua"] = function()
return gsm_on_or_pin_set() or tethering_on_or_tethering_connected()
end
menu.exists_page["/internet/kids_userlist.lua"] = function()
return config.KIDS
end
menu.show_page["/internet/kids_userlist.lua"] = function()
return pppoe_or_umts_on()
end
menu.exists_page["/internet/kids_profilelist.lua"] = function()
return config.KIDS
end
menu.show_page["/internet/kids_profilelist.lua"] = function()
return pppoe_or_umts_on()
end
menu.show_page["/internet/port_fw.lua"] = function()
local show_port_sharing = true
if is_ip_client() then show_port_sharing = false end
if is_dsl_modem() then show_port_sharing = false end
if config.USB_GSM and is_umts_on() then show_port_sharing = true end
return show_port_sharing
end
menu.exists_page["/internet/remote_https.lua"] = function()
return config.REMOTE_HTTPS
end
menu.show_page["/internet/remote_https.lua"] = function()
local show_remote_https = true
if is_dsl_modem() then show_remote_https = false end
if config.USB_GSM and is_umts_on() then show_remote_https = true end
--if not expert_mode then show_remote_https = false end
return show_remote_https
end
menu.exists_page["/internet/myfritz.lua"] = function()
return config.MYFRITZ
end
menu.show_page["/internet/myfritz.lua"] = function()
local show_myfritz = true
if is_ip_client() then show_myfritz = false end
if is_dsl_modem() then show_myfritz = false end
if config.USB_GSM and is_umts_on() then show_myfritz = true end
return show_myfritz
end
menu.exists_page["/internet/myfritz_devicelist.lua"] = function()
return config.MYFRITZ and config.IPV6
end
menu.show_page["/internet/myfritz_devicelist.lua"] = function()
local show_myfritz = true
if is_ip_client() then show_myfritz = false end
if is_dsl_modem() then show_myfritz = false end
if config.USB_GSM and is_umts_on() then show_myfritz = true end
--return expert_mode and show_myfritz
return show_myfritz and box.query("jasonii:settings/user_email")~="" and box.query("jasonii:settings/enabled")=="1"
end
menu.show_page["/internet/dyn_dns.lua"] = function()
local show_dyndns = true
if is_ip_client() then show_dyndns = false end
if is_dsl_modem() then show_dyndns = false end
if config.USB_GSM and is_umts_on() then show_dyndns = true end
if not expert_mode then show_dyndns = false end
if box.query("ddns:settings/account0/activated") == '1' then
show_dyndns = true
end
return show_dyndns
end
menu.exists_page["/internet/vpn.lua"] = function()
return config.VPN
end
menu.show_page["/internet/vpn.lua"] = function()
local show_vpn = true
if is_ip_client() then show_vpn = false end
if is_dsl_modem() then show_vpn = false end
if config.USB_GSM and is_umts_on() then show_vpn = true end
if not expert_mode then show_vpn = false end
return show_vpn
end
menu.exists_page["/internet/usbdisk_freigabe.lua"] = function()
return config.USB_STORAGE
end
menu.show_page["/internet/usbdisk_freigabe.lua"] = function()
local show_usb_sharing = true
if box.query("ctlusb:settings/storage-part/count") == '0' then
show_usb_sharing = false
end
if (config.RAMDISK or config.NAND) and box.query("ctlusb:settings/internalflash_enabled") == '1' then
show_usb_sharing = true
end
if config.USB_GSM and is_umts_on() then show_usb_sharing = false end
if is_wds_repeater() then show_usb_sharing = false end
if is_dsl_modem() then show_usb_sharing = false end
if not expert_mode then show_usb_sharing = false end
return show_usb_sharing
end
menu.exists_page["/internet/ipv6_fw.lua"] = function()
return config.IPV6
end
menu.show_page["/internet/ipv6_fw.lua"] = function()
local show_ipv6tab = true
if is_ip_client() then show_ipv6tab = false end
if is_dsl_modem() then show_ipv6tab = false end
if config.USB_GSM and is_umts_on() then show_ipv6tab = true end
if not expert_mode then show_ipv6tab = false end
if ( box.query("ipv6:settings/ipv6_fw_hidden") == "1") then show_ipv6tab = false end
return show_ipv6tab
end
local exists_dslinfo = function()
return not config.LTE and not config.DOCSIS and (config.DSL or config.VDSL)
end
local show_dslinfo = function()
return not config.ATA or box.query("box:settings/ata_mode") ~= "1"
end
menu.exists_page["/internet/dsl_overview.lua"] = exists_dslinfo
menu.show_page["/internet/dsl_overview.lua"] = show_dslinfo
menu.exists_page["/internet/adsl.lua"] = exists_dslinfo
menu.show_page["/internet/adsl.lua"] = show_dslinfo
menu.exists_page["/internet/dsl_stats_tab.lua"] = exists_dslinfo
menu.show_page["/internet/dsl_stats_tab.lua"] = show_dslinfo
menu.exists_page["/internet/dsl_stats_graph.lua"] = exists_dslinfo
menu.show_page["/internet/dsl_stats_graph.lua"] = show_dslinfo
menu.exists_page["/internet/dsl_spectrum.lua"] = exists_dslinfo
menu.show_page["/internet/dsl_spectrum.lua"] = show_dslinfo
menu.exists_page["/internet/vdsl_profile.lua"] = false
menu.show_page["/internet/vdsl_profile.lua"] = show_dslinfo
menu.exists_page["/internet/dsl_line_settings.lua"] = function()
return not config.LABOR_DSL and exists_dslinfo()
end
menu.show_page["/internet/dsl_line_settings.lua"] = function()
return expert_mode and show_dslinfo()
end
menu.exists_page["/internet/dsl_labor.lua"] = function()
return config.LABOR_DSL and exists_dslinfo()
end
menu.show_page["/internet/dsl_labor.lua"] = show_dslinfo
menu.exists_page["/internet/dsl_feedback.lua"] = function()
return config.BOX_FEEDBACK and exists_dslinfo()
end
menu.show_page["/internet/dsl_feedback.lua"] = show_dslinfo
menu.exists_page["/internet/docsis_overview.lua"] = function()
return config.DOCSIS
end
menu.exists_page["/internet/docsis_info.lua"] = function()
return config.DOCSIS
end
menu.exists_page["/internet/docsis_stats.lua"] = function()
return config.DOCSIS and oem ~= 'kdg'
end
menu.exists_page["/internet/docsis_options.lua"] = function()
return config.DOCSIS
end
menu.exists_page["/internet/docsis_log.lua"] = function()
return config.DOCSIS and oem ~= 'kdg'
end
local cable_on = function()
return box.query("box:settings/opmode") ~= 'opmode_eth_ip'
and not gsm_active()
end
menu.show_page["/internet/docsis_overview.lua"] = cable_on
menu.show_page["/internet/docsis_info.lua"] = cable_on
menu.show_page["/internet/docsis_stats.lua"] = cable_on
menu.show_page["/internet/docsis_options.lua"] = function()
return expert_mode and cable_on()
end
menu.show_page["/internet/docsis_log.lua"] = function()
return expert_mode and cable_on()
end
menu.exists_page["/internet/lte_overview.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_info.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_scanlist.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_sim.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_stats.lua"] = function()
return config.LTE
end
menu.exists_page["/internet/lte_higher.lua"] = function()
return config.LTE
end
menu.show_page["/internet/lte_higher.lua"] = function()
return expert_mode
end
menu.exists_page["/internet/lte_feedback.lua"] = function()
return config.LTE
end
local show_prio = function()
local result = true
if is_ip_client() then result = false end
if is_dsl_modem() then result = false end
if config.USB_GSM and is_umts_on() then result = true end
if not expert_mode then result = false end
return result
end
menu.exists_page["/internet/trafficprio.lua"] = function()
return config.NQOS
end
menu.show_page["/internet/trafficprio.lua"] = show_prio
menu.exists_page["/internet/trafficappl.lua"] = function()
return config.NQOS or config.KIDS
end
menu.show_page["/internet/trafficappl.lua"] = function()
return show_prio() or pppoe_or_umts_on()
end
menu.show_page["/net/network_settings.lua"] = function()
local show_net_sets = false
show_net_sets = show_net_sets or expert_mode
return show_net_sets
end
local is_usb_host = function()
return config.USB_HOST or config.USB_HOST_AVM or config.USB_HOST_TI
end
local aura_on = function()
return config.AURA and box.query("aura:settings/enabled") == '1'
end
local aura4storage_on = function()
return aura_on() and box.query("aura:settings/aura4storage") == '1'
end
menu.exists_page["/storage/settings.lua"] = function()
return config.USB_STORAGE and is_usb_host()
end
menu.exists_page["/usb/show_usb_devices.lua"] = is_usb_host
menu.exists_page["/usb/usb_mode.lua"] = function()
if config.USB_XHCI then
return true
end
if config.USB_STORAGE_SPINDOWN then
local udev = require("usb_devices")
--conv = require("convert_file_size")
return (udev.usb_mem_mount_check())
end
return false
end
menu.exists_page["/usb/usb_diskcut.lua"] = function()
return not config.WEBDAV or config.USB_STORAGE
end
menu.show_page["/usb/usb_diskcut.lua"] = aura4storage_on
menu.exists_page["/usb/usb_remote_settings.lua"] = function()
return config.AURA
end
menu.show_page["/usb/usb_remote_settings.lua"] = expert_mode
local is_repeater = function()
return false
end
local is_not_repeater = function()
return true
end
local g_rep_mode=general.get_bridge_mode()
local is_LanBridge = function ()
return g_rep_mode=="lan_bridge" or g_rep_mode=="plc_bridge"
end
local is_WlanBridge = function ()
return g_rep_mode=="wlan_bridge"
end
local wlan_on = function()
return box.query("wlan:settings/ap_enabled") == '1'
or box.query("wlan:settings/ap_enabled_scnd") == '1'
end
local rep_configured = function()
return (box.query("wlan:settings/STA_configured")=="1") or box.query("wlan:settings/STA_configured_scnd")=="1"
end
local rep_configured_and_wlan_on = function()
return rep_configured() and wlan_on()
end
menu.exists_submenu['wlan'] = function()
return config.WLAN
end
menu.exists_page["/wlan/rep_sta.lua"] = function()
return is_repeater() and is_WlanBridge()
end
menu.exists_page["/wlan/rep_settings.lua"]= function()
return is_repeater() and is_WlanBridge()
end
menu.show_page["/wlan/rep_sta.lua"] = function()
return wlan_on() and is_WlanBridge()
end
menu.show_page["/wlan/rep_settings.lua"] = rep_configured
menu.exists_page["/wlan/wlan_settings.lua"] = function()
return is_not_repeater() or (is_repeater() and is_LanBridge())
end
menu.show_page["/wlan/radiochannel.lua"] = function()
return wlan_on() and (is_not_repeater() or is_repeater() and (is_LanBridge() or rep_configured()))
end
if (is_repeater() and is_WlanBridge()) then
menu.show_page["/wlan/encrypt.lua"] = rep_configured_and_wlan_on
else
menu.show_page["/wlan/encrypt.lua"] = wlan_on
end
menu.exists_page["/wlan/wps.lua"] = function()
if (is_repeater() and is_WlanBridge()) then
return config.WLAN_WPS and rep_configured_and_wlan_on()
end
return config.WLAN_WPS
end
menu.show_page["/wlan/wps.lua"] = function()
local security=box.query("wlan:settings/encryption")
if (security=="2" or security=="3" or security=="4") then
return wlan_on() and not is_wlan_ata()
end
return false
end
menu.exists_page["/wlan/wds.lua"] = function()
return config.WLAN_WDS and not config.WLAN_WDS2
end
menu.show_page["/wlan/wds.lua"] = function()
return expert_mode and wlan_on() and not is_wlan_ata()
end
menu.exists_page["/wlan/wds2.lua"] = function()
return config.WLAN_WDS2
end
menu.show_page["/wlan/wds2.lua"] = function()
if (config.DOCSIS) then
return false
end
return expert_mode and wlan_on() and not is_wlan_ata()
end
menu.exists_page["/wlan/guest_access.lua"] = function()
return config.WLAN_GUEST
end
menu.show_page["/wlan/guest_access.lua"] = function()
local repeater_guest_ap = config.WLAN.has_repeater_guest_ap
if repeater_guest_ap then
return wlan_on() and not is_wlan_ata() and (config.GUI_IS_REPEATER or not (is_ip_client() and not is_wds_repeater()))
else
return wlan_on() and not is_ip_client() and not is_wlan_ata()
end
end
local handsets
local any_avm_handset = function()
if not handsets then
handsets = listquery("dect:settings/Handset/list(Subscribed,Manufacturer)")
end
return array.any(handsets, function(hs) return hs.Subscribed == "1" and hs.Manufacturer == "AVM" end)
end
local any_handset = function()
if not handsets then
handsets = listquery("dect:settings/Handset/list(Subscribed,Manufacturer)")
end
return array.any(handsets, function(hs) return hs.Subscribed == "1" end)
end
local dect_enabled = function()
return box.query('dect:settings/enabled') == "1"
end
local dect_with_mtd = function()
return dect_enabled() and any_avm_handset()
end
local dect_repeater_enabled = function()
return false
end
menu.exists_submenu['dect'] = function()
return config.DECT or config.DECT2
end
menu.show_page["/dect/dect_list.lua"] = dect_enabled
local show_dect_moni = function()
if dect_enabled() then
if config.DECT_MONI_EX or expert_mode then
return true
end
end
return false
end
local show_dect_moni_ex = function()
return expert_mode and show_dect_moni() and any_handset()
end
menu.exists_page["/dect/dect_moni.lua"] = function()
return config.DECT_MONI
end
menu.show_page["/dect/dect_moni.lua"] = show_dect_moni
menu.exists_page["/dect/dect_moni_ex.lua"] = function()
return config.DECT_MONI_EX
end
menu.show_page["/dect/dect_moni_ex.lua"] = show_dect_moni_ex
menu.exists_page["/dect/dect_repeater.lua"] = false
menu.exists_page["/dect/show_mail.lua"] = function()
return config.MTD_MAIL
end
menu.show_page["/dect/show_mail.lua"] = dect_with_mtd
menu.exists_page["/dect/internetradio.lua"] = function()
return config.MEDIASRV or config.DECT_AUDIOD
end
menu.exists_page["/dect/podcast.lua"] = function()
return config.MEDIASRV or config.DECT_AUDIOD
end
menu.exists_page["/dect/radiopodcast.lua"] = function()
return config.MEDIASRV or config.DECT_AUDIOD
end
menu.exists_page["/storage/media_settings.lua"] = function()
return config.MEDIASRV
end
menu.exists_page["/dect/rss.lua"] = function()
return config.MTD_RSS
end
menu.show_page["/dect/rss.lua"] = dect_with_mtd
menu.exists_page["/system/syslog.lua?tab=telefon"] = function()
return config.FON
end
menu.exists_page["/system/syslog.lua?tab=internet"] = function()
return config.DSL or config.VDSL or config.DOCSIS or config.LTE
end
menu.exists_page["/system/syslog.lua?tab=usb"] = is_usb_host
menu.exists_page["/system/syslog.lua?tab=wlan"] = function()
return config.WLAN
end
local dsl_modem = function()
return (config.DSL or config.VDSL) and is_dsl_modem()
end
menu.exists_page["/system/energy.lua"] = function()
return config.ECO
end
menu.exists_page["/system/touchdisplay.lua"] = function()
return false
end
menu.exists_page["/system/rep_mode.lua"] = function()
return false
end
menu.exists_page["/system/led_display.lua"] = function()
return box.query("box:settings/led_display") ~= ""
end
menu.exists_page["/system/led_display.lua"] = function()
return false
end
menu.exists_page["/system/infoled.lua"] = function()
return true
end
menu.exists_submenu['diagnosis'] = function()
return is_not_repeater()
end
menu.exists_page["/system/diagnosis.lua"] = function()
return is_not_repeater()
end
menu.exists_page["/system/security.lua"] = function()
return is_not_repeater()
end
menu.exists_page["/system/ecostat.lua"] = function()
return config.ECO and config.ECO_SYSSTAT
end
menu.exists_page["/system/push_list.lua"] = function()
return config.MAILER or config.MAILER2
end
menu.show_page["/system/push_list.lua"] = function()
return not dsl_modem() or gsm_active()
end
menu.exists_page["/system/push_account.lua"] = function()
return config.MAILER or config.MAILER2
end
menu.show_page["/system/push_account.lua"] = function()
return not dsl_modem() or gsm_active()
end
menu.exists_page["/system/keylock.lua"] = function()
return true
end
menu.exists_page["/system/nacht.lua"] = function()
return (config.WLAN or config.FON) and not config.TIMERCONTROL
end
menu.show_page["/system/nacht.lua"] = function()
return (config.WLAN or config.FON)
end
menu.exists_page["/system/wlan_night.lua"] = function()
return config.WLAN and config.TIMERCONTROL
end
menu.exists_page["/system/ring_block.lua"] = function()
return box.query("box:settings/night_time_control_enabled") == "1" and config.FON and config.TIMERCONTROL
end
menu.show_page["/system/ring_block.lua"] = function()
local result = config.FON
return box.query("box:settings/night_time_control_enabled") == "1" and result
end
menu.exists_page["/system/export.lua"] = function()
return config.STOREUSRCFG
end
menu.exists_page["/system/import.lua"] = function()
return config.STOREUSRCFG
end
menu.exists_page["/system/cfgtakeover.lua"] = function()
return false
end
local manageUpdate=box.query("tr069:settings/UpgradesManaged")
menu.exists_page["/system/update.lua"] = function()
if (manageUpdate=="1") then
return false
end
return not config.DOCSIS
end
menu.exists_page["/system/update_file.lua"] = function()
if (manageUpdate=="1") then
return false
end
return not config.DOCSIS
end
menu.exists_page["/system/update_auto.lua"] = function()
if not config.GUI_AUTOUPDATETAB or "1" == manageUpdate or "1" ~= box.query("box:settings/allow_background_comm_with_manufacturer") then
return false
end
return not config.DOCSIS
end
menu.show_page["/system/update_file.lua"] = expert_mode
menu.exists_page["/system/expert.lua"] = function()
return true
end
menu.exists_page["/system/timezone.lua"] = function()
return config.timezone
end
menu.exists_page["/system/language.lua"] = function()
return config.MULTI_LANGUAGE
end
menu.exists_submenu['audio']=function()
return config.NLR_AUDIO
end
menu.exists_page["/audio/audio.lua"] = function()
return config.NLR_AUDIO
end
menu.exists_page["/audio/radio.lua"] = function()
return config.NLR_AUDIO and config.CONFIGD
end
menu.exists_page["/fon_devices/tam_list.lua"] = function()
return config.FON and config.TAM_MODE > 0
end
menu.exists_page["/fon_devices/fax_send.lua"] = function()
return config.FON and config.FAXSEND
end
menu.exists_page["/fon_devices/fax_option.lua"] = function()
return config.FON and config.FAXSEND
end
menu.show_page["/fon_devices/fax_option.lua"] = function()
require("fon_devices")
local fax_device=fon_devices.read_fax_intern()
local active=box.query([[telcfg:settings/FaxMailActive]])
return (active~="0" and #fax_device>0)
end
