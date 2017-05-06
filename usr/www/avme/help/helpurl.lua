--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall)
require"config"
require"lualib"
local set = "set=014"
local url = config.ONLINEHELP_URL
local gui_has_update_led = false
local gui_wlan_doublemonitor = false
if config.WLAN.is_double_wlan then
gui_wlan_doublemonitor = true
end
local gui_only_24_wlan = false
if config.WLAN.has_5ghz_band then
gui_only_24_wlan = true
end
local gui_use_fritz_app_fon = false
local gui_dect_repeater_support = false
local device_features = {}
device_features[1] = config.AURA -- hw_usb_fern
device_features[2] = config.AB_COUNT == 1 -- hw_1fon
device_features[3] = config.AB_COUNT == 2 -- hw_2fon
device_features[4] = config.AB_COUNT == 3 -- hw_3fon
device_features[5] = config.ETH_COUNT == 1 -- hw_1lan
device_features[6] = config.ETH_COUNT == 2 -- hw_2lan
device_features[7] = config.ETH_COUNT == 4 -- hw_4lan
device_features[8] = config.KIDS -- hw_kids
device_features[9] = config.MEDIASRV -- hw_mediasrv
device_features[10] = config.WLAN_WMM -- hw_wlan_wmm
device_features[11] = config.ATA -- hw_atamode
device_features[12] = config.BUTTON -- hw_wlan_taster
device_features[13] = config.DECT -- hw_dect
device_features[14] = not config.LTE and config.DSL -- hw_dsl
device_features[15] = false -- hw_fbox_sl
device_features[16] = config.FON -- hw_fon
device_features[17] = false -- hw_gateway
device_features[18] = config.CAPI_NT -- hw_s0
device_features[19] = config.TAM_MODE > 0 -- hw_ab
device_features[20] = config.USB -- hw_usb_computer
device_features[21] = config.USB_HOST -- hw_usb
device_features[22] = config.USB_PRINT_SERV -- hw_usbdrucker
device_features[23] = config.USB_STORAGE -- hw_usbspeicher
device_features[24] = config.WLAN -- hw_wlan
device_features[25] = config.WLAN_MADWIFI -- hw_wlan_n
device_features[26] = config.VOL_COUNTER -- hw_vol
device_features[27] = false -- hw_mini
device_features[28] = config.DECT2 -- hw_dect2
device_features[29] = config.WLAN_TXPOWER -- hw_txpower
device_features[30] = config.SAMBA -- hw_samba
device_features[31] = config.FAX2MAIL -- hw_faxempfang
device_features[32] = config.IPTV_4THOME -- hw_iptv_4thome
device_features[33] = not config.MAILER and not config.MAILER2 -- hw_no_pushservice
device_features[34] = false -- hw_7113 + hw_5113
device_features[35] = not (config.CAPI_TE or config.CAPI_POTS) and (config.AB_COUNT > 0) -- hw_voiponly
device_features[36] = config.NQOS -- hw_internet_priorisierung
device_features[37] = config.REMOTE_HTTPS -- hw_remote_https
device_features[38] = config.NTFS -- hw_ntfs
device_features[39] = config.WLAN_WPS -- hw_wlan_wps
device_features[40] = config.VPN -- hw_vpn
device_features[41] = config.FON_IPPHONE -- hw_fon_ipphone
device_features[42] = config.TR069 -- hw_tr069
device_features[43] = config.TR064 -- hw_tr064
device_features[44] = config.CAPI_TE or config.CAPI_POTS -- hw_fixedline
device_features[45] = gui_has_update_led -- hw_updateled
device_features[46] = gui_wlan_doublemonitor -- hw_wlan_concurrent
device_features[47] = config.RAMDISK or config.NAND -- hw_internal_storage
device_features[48] = config.DOCSIS -- hw_docsis
device_features[49] = config.ETH_GBIT -- hw_lan_gbit
device_features[50] = gui_only_24_wlan -- hw_wlan_n_24
device_features[51] = config.TIMERCONTROL -- hw_nachtschalt_neu
device_features[52] = config.DSL_MULTI_ANNEX -- hw_multi_annex
device_features[53] = true --hw_no_dsl_performance
device_features[54] = config.VDSL -- hw_vdsl
device_features[55] = config.CHRONY --hw_chrono
device_features[56] = config.LTE --hw_lte
device_features[57] = gui_use_fritz_app_fon --hw_fritzapp_fon
device_features[58] = gui_dect_repeater_support --hw_dect_repeater
device_features[59] = config.WLAN.has_coexistence -- hw_wlan_coexistence
local user_settings = {}
user_settings[1] = box.query("box:settings/ata_mode") == '1' -- dyn_ata
user_settings[2] = box.query("box:settings/expertmode/activated") == '1' -- dyn_expert
user_settings[3] = config.WLAN_WDS and box.query("wlan:settings/WDS_enabled") == '1' -- dyn_repeater
user_settings[4] = config.USB_GSM and box.query("umts:settings/enabled") == '1' -- dyn_umts
local function flag2str(b) return b and "1" or "0" end
function get(topic, anchor)
local result = {url, set, "topic=" .. topic}
table.insert(result, "deviceFeatures=" .. table.concat(array.map(device_features, flag2str)))
table.insert(result, "userSettings=" .. table.concat(array.map(user_settings,flag2str)))
result = table.concat(result, "&")
if anchor then
result = result .. "#" .. anchor
end
return result
end
local help_pages_onbox = array.truth{
"hilfe_syslog.html",
"hilfe_speicher_fritz_nas.html",
"rechtliche_hinweise.html",
"hilfe_dslinfo_einstellungen.html",
"hilfe_dslinfo_ADSL.html",
"hilfe_dslinfo_ATM.html",
"hilfe_dslinfo_Spektrum.html",
"hilfe_dslinfo_uebersicht.html",
"hilfe_internet_dslsnrset.html",
"hilfe_kindersicherung_uebersicht.html",
"hilfe_kindersicherung_neuer_name.html",
"hilfe_kindersicherung_einstellungen.html",
"hilfe_kindersicherung_pc_accounts.html",
"hilfe_kindersicherung_onlinezaehler.html",
"hilfe_internet_filter_blacklist.html",
"hilfe_internet_filter_listen.html",
"hilfe_internet_filter_whitelist.html",
"hilfe_internet.html",
"hilfe_internet_ata.html",
"hilfe_ipsetting.html",
"hilfe_system_export.html",
"hilfe_system_import.html",
"hilfe_system_import_uebernahme.html",
"hilfe_system_user.html",
"hilfe_gsm_gsm.html",
"hilfe_kindersicherung_user_client.html",
"hilfe_kindersicherung_user_SYSTEM.html",
"hilfe_kennwort.html",
"hilfe_status.html",
"hilfe_sitemap.html",
"hilfe_internet_ipv6.html",
"hilfe_internet_ipv6_nativ_settings.html",
"hilfe_internet_ipv6_tunnel_settings.html",
"hilfe_ipv6_introduction.html",
"hilfe_kindersicherung_einstellungen_blocked.html",
"hilfe_ProviderDefaults.html",
"hilfe_internet_docsis_zugang_mit_ata.html",
"hilfe_funknetzauswahl.html",
"hilfe_status_repeater.html",
"hilfe_sitemap_repeater.html",
"hilfe_system_user_repeater.html",
"hilfe_internet_zugangsdaten_LTE.html",
"hilfe_internet_ipv4.html",
"hilfe_ipv4_settings.html",
"hilfe_ipv6_settings.html",
"hilfe_startseite.html",
"hilfe_system_betriebsart.html",
"hilfe_internet_zugangsdaten.html",
"hilfe_internetzugang_anschluss.html",
"hilfe_internetzugang_betriebsart.html",
"hilfe_internetzugang_verbindungseinstellungen.html",
"hilfe_internetzugang_verbindungseinstellungen_ppp.html",
--"hilfe_myfritz_einrichten.html",
"hilfe_internetzugang_zugangsdaten.html"
}
function isonbox(helppage)
if help_pages_onbox[helppage] then return true end
if 1 == helppage:find("hilfe_syslog_%d+%.html") then
return true
end
return false
end
