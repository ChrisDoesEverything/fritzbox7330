--[[Access denied<?lua
box.end_page()
?>]]
menu.add_item{
page = "/home/home.lua",
text = [[{?menuOverview?}]],
menu = "main"
}
menu.add_item{
submenu = "internet",
text = [[{?menuInternet?}]],
short = [[{?menuInternetShort?}]],
menu = "main",
}
menu.add_item{
submenu = "fon",
text = [[{?menuFon?}]],
short = [[{?menuFonShort?}]],
menu = "main"
}
menu.add_item{
submenu = "net",
text = [[{?menuHomeNetwork?}]],
short = [[{?menuHomeNetworkShort?}]],
menu = "main"
}
local rep_configured = function()
return (box.query("wlan:settings/STA_configured")=="1") or box.query("wlan:settings/STA_configured_scnd")=="1"
end
local get_wlan_default=function ()
end
menu.add_item{
submenu = "wlan",
text = [[{?menuWlan?}]],
short = [[{?menuWlanShort?}]],
menu = "main",
default=get_wlan_default
}
menu.add_item{
submenu = 'audio',
text = [[{?menuAudio?}]],
short = [[{?menuAudioShort?}]],
menu = "main"
}
menu.add_item{
submenu = 'dect',
text = [[{?menuDect?}]],
short = [[{?menuDectShort?}]],
menu = "main"
}
menu.add_item{
submenu = "diagnosis",
text = [[{?menuDiagnosis?}]],
short = [[{?menuDiagnosisShort?}]],
menu = "main"
}
menu.add_item{
submenu = 'system',
text = [[{?menuSystem?}]],
short = [[{?menuSystemShort?}]],
menu = "main"
}
local AssiExplainTxt=[[{?3505:372?}]]
if config.DOCSIS or box.query("tr069:settings/UpgradesManaged") == "1" then
AssiExplainTxt = [[{?3505:80?}]]
end
menu.add_item{
page = "/assis/home.lua",
text = [[{?3505:8577?}]],
explain = AssiExplainTxt,
menu = "wizards"
}
menu.add_item{
page = "/nas/",
text = [[{?3505:7929?}]],
menu = "fritznas",
explain = [[{?3505:4614?}]]
}
local str_explain = [[]]
local fritz_app_active=true
if config.NAS and config.FON then
if (fritz_app_active) then
str_explain = [[{?3505:872?}]]
else
str_explain = [[{?3505:480?}]]
end
elseif config.NAS and not config.FON then
str_explain = [[{?3505:343?}]]
elseif not config.NAS and config.FON then
if (fritz_app_active) then
str_explain = [[{?3505:920?}]]
end
end
menu.add_item{
page = "/myfritz/",
text = [[{?3505:115?}]],
menu = "myfritz",
explain = str_explain
}
menu.add_item{
page = "",
href = box.query("box:settings/iptv_url"),
target = "_blank",
text = [[{?3505:6570?}]],
explain = [[{?3505:65?}]],
menu = "livetv"
}
menu.add_item{
text = [[{?menuOnlinemonitor?}]],
short = [[{?menuOnlinemonitorShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/inetstat_monitor.lua", text = [[{?3505:715?}]]},
{ page = "/internet/inetstat_counter.lua", text = [[{?3505:714?}]]}
}
}
menu.add_item{
text = config.DOCSIS and [[{?menuConnection?}]]
or [[{?menuAccountData?}]],
short = config.DOCSIS and [[{?menuConnectionShort?}]]
or [[{?menuAccountDataShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/internet_settings.lua", text = [[{?3505:739?}]] },
{ page = "/internet/lte_settings.lua", text = [[{?3505:634?}]] },
{ page = "/internet/docsis_settings.lua", text = [[{?3505:202?}]] },
{ page = "/internet/ipv6.lua", text = [[{?3505:844?}]] },
{ page = "/internet/lisp.lua", text = [[{?3505:15?}]] },
{ page = "/internet/lanbridges.lua", text = [[{?3505:690?}]] },
{ page = "/internet/providerservices.lua", text = [[{?3505:888?}]] },
{ page = "/internet/dns_server_enh.lua", text = [[{?3505:4630?}]] }
}
}
menu.add_item{
page = "/internet/umts_settings.lua",
text = [[{?menuMobile?}]],
short = [[{?menuMobileShort?}]],
menu = "internet"
}
menu.add_item{
text = [[{?menuFilter?}]],
short = [[{?menuFilterShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/kids_userlist.lua", text = [[{?3505:5813?}]] },
{ page = "/internet/kids_profilelist.lua", text = [[{?3505:227?}]] },
{ page = "/internet/trafficprio.lua", text = [[{?3505:543?}]] },
{ page = "/internet/trafficappl.lua", text = [[{?3505:793?}]]}
}
}
local store_txt = [[{?3505:582?}]]
if config.RAMDISK or config.NAND then
store_txt = [[{?3505:489?}]]
end
menu.add_item{
text = [[{?menuPermissions?}]],
short = [[{?menuPermissionsShort?}]],
tabs = {
{ page = "/internet/myfritz_devicelist.lua", text = [[{?3505:3103?}]] },
{ page = "/internet/port_fw.lua", text = [[{?3505:941?}]] },
{ page = "/internet/usbdisk_freigabe.lua", text = store_txt },
{ page = "/internet/remote_https.lua" , text = [[{?3505:845?}]] },
{ page = "/internet/dyn_dns.lua", text = [[{?3505:973?}]] },
{ page = "/internet/vpn.lua" , text = [[{?3505:294?}]] },
{ page = "/internet/ipv6_fw.lua", text = [[{?3505:423?}]] }
},
menu = "internet"
}
menu.add_item{
text = [[{?menuMyFritz?}]],
tabs = {
{ page = "/internet/myfritz.lua", text = [[{?3505:139?}]] }
},
menu = "internet"
}
local function get_line_settings_text()
if config.language_is_de then
return [[{?3505:70?}]]
end
return [[{?3505:537?}]]
end
menu.add_item{
text = [[{?menuDslInfo?}]],
short = [[{?menuDslInfoShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/dsl_overview.lua", text = [[{?3505:71?}]]},
{ page = "/internet/dsl_stats_tab.lua", text = [[{?3505:843?}]]},
{ page = "/internet/dsl_spectrum.lua", text = [[{?3505:728?}]]},
{ page = "/internet/vdsl_profile.lua", text = [[{?3505:8435?}]]},
{ page = "/internet/dsl_stats_graph.lua", text = [[{?3505:601?}]]},
{ page = "/internet/dsl_line_settings.lua", text = get_line_settings_text()},
{ page = "/internet/dsl_labor.lua", text = [[{?3505:785?}]]},
{ page = "/internet/dsl_feedback.lua", text = [[{?3505:808?}]]}
}
}
menu.add_item{
text = [[{?menuCableInfo?}]],
short = [[{?menuCableInfoShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/docsis_overview.lua", text = [[{?3505:12?}]]},
{ page = "/internet/docsis_info.lua", text = [[{?3505:2877?}]]},
{ page = "/internet/docsis_stats.lua", text = [[{?3505:327?}]]},
{ page = "/internet/docsis_options.lua", text = [[{?3505:6977?}]]},
{ page = "/internet/docsis_log.lua", text = [[{?3505:274?}]]}
}
}
menu.add_item{
text = [[{?menuLteInfo?}]],
short = [[{?menuLteInfoShort?}]],
menu = "internet",
tabs = {
{ page = "/internet/lte_overview.lua", text = [[{?3505:689?}]]},
{ page = "/internet/lte_info.lua", text = [[{?3505:484?}]]},
{ page = "/internet/lte_scanlist.lua", text = [[{?3505:899?}]]},
{ page = "/internet/lte_sim.lua", text = [[{?3505:127?}]]},
{ page = "/internet/lte_stats.lua", text = [[{?3505:128?}]]},
{ page = "/internet/lte_higher.lua", text = [[{?3505:8481?}]]},
{ page = "/internet/lte_feedback.lua", text = [[{?3505:396?}]]}
}
}
menu.add_item{
text = [[{?menuFoncalls?}]],
short = [[{?menuFoncallsShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_num/foncalls_list.lua", text = [[{?3505:272?}]] },
{ page = "/fon_num/dial_foncalls.lua", text = [[{?3505:380?}]] }
}
}
menu.add_item{
page = "/fon_devices/tam_list.lua",
text = [[{?menuTam?}]],
short = [[{?menuTamShort?}]],
menu = "fon"
}
menu.add_item{
text = [[{?menuPhonebook?}]],
short = [[{?menuPhonebookShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_num/fonbook_list.lua", text = [[{?3505:214?}]] },
{ page = "/fon_num/fonbook_intern.lua", text = [[{?3505:305?}]] },
{ page = "/fon_num/dial_fonbook.lua", text = [[{?3505:723?}]] }
}
}
menu.add_item{
text = [[{?menuAlarm?}]],
short = [[{?menuAlarmShort?}]],
menu = "fon",
page = "/fon_devices/alarm.lua",
tabs = {
{ tab = "0", text = [[{?3505:179?}]] },
{ tab = "1", text = [[{?3505:536?}]] },
{ tab = "2", text = [[{?3505:542?}]] }
}
}
menu.add_item{
text = [[{?menuFax?}]],
short = [[{?menuFaxShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_devices/fax_send.lua", text = [[{?3505:222?}]] },
{ page = "/fon_devices/fax_option.lua", text = [[{?3505:481?}]] }
}
}
menu.add_item{
text = [[{?menuCallHandling?}]],
short = [[{?menuCallHandlingShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_num/sperre.lua", text = [[{?3505:2755?}]] },
{ page = "/fon_num/rul_list.lua", text = [[{?3505:957?}]] },
{ page = "/fon_num/callthrough.lua", text = [[{?3505:324?}]] },
{ page = "/fon_num/dialrul_list.lua", text = [[{?3505:3268?}]] },
{ page = "/fon_num/dialrul_provider.lua", text = [[{?3505:851?}]]}
}
}
menu.add_item{
text = [[{?menuFondevices?}]],
short = [[{?menuFondevicesShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_devices/fondevices_list.lua", text = [[{?3505:731?}]] }
}
}
menu.add_item{
text = [[{?menuOwnNumbers?}]],
short = [[{?menuOwnNumbersShort?}]],
menu = "fon",
tabs = {
{ page = "/fon_num/fon_num_list.lua", text = [[{?3505:60?}]] },
{ page = "/fon_num/sip_option.lua", text = [[{?3505:573?}]] },
{ page = "/fon_num/sip_quality.lua", text = [[{?3505:549?}]] }
}
}
menu.add_item{
text = [[{?menuNetwork?}]],
short = [[{?menuNetworkShort?}]],
menu = "net",
tabs = {
{ page = "/net/network_user_devices.lua", text = [[{?3505:134?}]]},
{ page = "/net/network_settings.lua", text = [[{?3505:557?}]] }
}
}
menu.add_item{
text = [[{?menuUsbdevices?}]],
short = [[{?menuUsbdevicesShort?}]],
menu = "net",
tabs = {
{ page = "/usb/show_usb_devices.lua", text = [[{?3505:341?}]] },
{ page = "/usb/usb_mode.lua", text = [[{?3505:368?}]] },
{ page = "/usb/usb_remote_settings.lua", text = [[{?3505:628?}]] }
}
}
menu.add_item{
text = [[{?menuStorageNas?}]],
short = [[{?menuStorageNasShort?}]],
menu = "net",
tabs = {
{ page = "/storage/settings.lua", text = [[{?3505:218?}]] }
}
}
menu.add_item{
text = [[{?menuHomeInternetmedia?}]],
short = [[{?menuHomeInternetmediaShort?}]],
menu = "net",
tabs = {
{ page = "/storage/media_settings.lua", text = [[{?3505:865?}]]},
{ page = "/dect/internetradio.lua", text = [[{?3505:461?}]]},
{ page = "/dect/podcast.lua", text = [[{?3505:664?}]]}
}
}
menu.add_item{
page = "/net/fritz_name.lua",
text = [[{?menuFritzBoxName?}]],
short = [[{?menuFritzBoxNameShort?}]],
menu = "net"
}
menu.add_item{
page = "/net/home_auto_overview.lua",
text = [[{?menuSmartHome?}]],
short = [[{?menuSmartHomeShort?}]],
menu = "net"
}
menu.add_item{
page = "/audio/audio.lua",
text = [[{?menuAudioOutput?}]],
short = [[{?menuAudioOutputShort?}]],
menu = "audio"
}
menu.add_item{
page = "/audio/radio.lua",
text = [[{?menuInternetRadio?}]],
short = [[{?menuInternetRadioShort?}]],
menu = "audio"
}
menu.add_item{
page = "/wlan/rep_sta.lua",
text = [[{?menuWlanNetSelect?}]],
short = [[{?menuWlanNetSelectShort?}]],
menu = "wlan"
}
if config.GUI_IS_REPEATER and general.get_bridge_mode() == "wlan_bridge" and rep_configured() then
menu.add_item{
page = "/wlan/radiochannel.lua",
text = [[{?menuWlanMonitor?}]],
short = [[{?menuWlanMonitorShort?}]],
menu = "wlan"
}
end
menu.add_item{
page = "/wlan/rep_settings.lua",
text = [[{?menuWlanSettings?}]],
short = [[{?menuWlanSettingsShort?}]],
menu = "wlan"
}
menu.add_item{
page = "/wlan/wlan_settings.lua",
text = [[{?menuWlanNetwork?}]],
short = [[{?menuWlanNetworkShort?}]],
menu = "wlan"
}
if not config.GUI_IS_REPEATER or (config.GUI_IS_REPEATER and not rep_configured()) then
menu.add_item{
page = "/wlan/radiochannel.lua",
text = [[{?menuWlanChannel?}]],
short = [[{?menuWlanChannelShort?}]],
menu = "wlan"
}
end
menu.add_item{
text = [[{?menuWlanSecurity?}]],
short = [[{?menuWlanSecurityShort?}]],
menu = "wlan",
tabs = {
{ page = "/wlan/encrypt.lua", text = [[{?3505:50?}]]},
{ page = "/wlan/wps.lua", text = [[{?3505:288?}]]}
}
}
menu.add_item{
text = [[{?menuWlanNight?}]],
short = [[{?menuWlanNightShort?}]],
menu = "wlan",
page = "/system/wlan_night.lua", text = [[{?3505:840?}]]
}
menu.add_item{
page = "/wlan/guest_access.lua",
text = [[{?menuWlanGuest?}]],
short = [[{?menuWlanGuestShort?}]],
menu = "wlan"
}
menu.add_item{
page = "/wlan/wds.lua",
text = [[{?menuWlanWds?}]],
menu = "wlan"
}
menu.add_item{
page = "/wlan/wds2.lua",
text = [[{?menuWlanRepeating?}]],
short = [[{?menuWlanRepeatingShort?}]],
menu = "wlan"
}
menu.add_item{
page = "/dect/dect_list.lua",
text = [[{?menuDectDevices?}]],
short = [[{?menuDectDevicesShort?}]],
menu = "dect"
}
menu.add_item{
page = "/dect/dect_settings.lua",
text = [[{?menuDectBasis?}]],
short = [[{?menuDectBasisShort?}]],
menu = "dect"
}
menu.add_item{
text = [[{?menuDectMonitor?}]],
short = [[{?menuDectMonitorShort?}]],
menu = "dect",
tabs = {
{ page = "/dect/dect_moni.lua", text = [[{?3505:93?}]]},
{ page = "/dect/dect_moni_ex.lua", text = [[{?3505:449?}]]}
}
}
menu.add_item{
page = "/dect/dect_repeater.lua",
text = [[{?menuDectRepeater?}]],
short = [[{?menuDectRepeaterShort?}]],
menu = "dect"
}
menu.add_item{
text = [[{?menuDectInternetServices?}]],
short = [[{?menuDectInternetServicesShort?}]],
menu = "dect",
tabs = {
{ page = "/dect/show_mail.lua", text = [[{?3505:201?}]]},
{ page = "/dect/rss.lua", text = [[{?3505:614?}]]},
{ page = "/dect/radiopodcast.lua", text = [[{?3505:553?}]]}
}
}
menu.add_item{
text = [[{?menuMaintenance?}]],
short = [[{?menuMaintenanceShort?}]],
menu = "diagnosis",
page = "/system/diagnosis.lua"
}
menu.add_item{
text = [[{?menuSecurity?}]],
short = [[{?menuSecurityShort?}]],
menu = "diagnosis",
page = "/system/security.lua"
}
menu.add_item{
text = [[{?menuSyslog?}]],
short = [[{?menuSyslogShort?}]],
menu = "system",
page = "/system/syslog.lua",
tabs = {
{ tab = "aus", text = [[{?3505:566?}]]},
{ tab = "telefon", text = [[{?3505:277?}]]},
{ tab = "internet", text = [[{?3505:172?}]]},
{ tab = "usb", text = [[{?3505:780?}]] },
{ tab = "wlan", text = [[{?3505:554?}]]},
{ tab = "system", text = [[{?3505:229?}]]}
}
}
menu.add_item{
text = [[{?menuEnergyMonitor?}]],
short = [[{?menuEnergyMonitorShort?}]],
menu = "system",
tabs = {
{ page = "/system/energy.lua", text = [[{?3505:126?}]] },
{ page = "/system/ecostat.lua", text = [[{?3505:7351?}]] }
}
}
menu.add_item{
page = "/system/rep_mode.lua",
text = [[{?menuOperatingMode?}]],
short = [[{?menuOperatingModeShort?}]],
menu = "system"
}
menu.add_item{
page = "/system/touchdisplay.lua",
text = [[{?menuTouchdisplay?}]],
short = [[{?menuTouchdisplayShort?}]],
menu = "system"
}
menu.add_item{
text = [[{?menuPushService?}]],
short = [[{?menuPushServiceShort?}]],
menu = "system",
tabs = {
{ page = "/system/push_list.lua", text = [[{?3505:1048?}]] },
{ page = "/system/push_account.lua", text = [[{?3505:833?}]] },
}
}
menu.add_item{
text = [[{?3505:680?}]],
menu = "system",
tabs = {
{page = "/system/infoled.lua", text = [[{?menuInfoLed?}]]},
{page = "/system/led_display.lua", text = [[{?menuLed?}]]},
{page = "/system/keylock.lua", text = [[{?menuKeyLock?}]]}
}
}
menu.add_item{
text = [[{?menuNight?}]],
short = [[{?menuNightShort?}]],
menu = "system",
page = "/system/nacht.lua"
}
menu.add_item{
text = [[{?menuNight?}]],
short = [[{?menuNightShort?}]],
menu = "system",
tabs = {
{page = "/system/ring_block.lua", text = [[{?3505:867?}]]},
}
}
local boxuser_menutxt = [[{?menuBoxPassword?}]]
local boxuser_menushort = [[{?menuBoxPasswordShort?}]]
local boxuser_listtxt = [[{?3505:326?}]]
menu.add_item{
text = boxuser_menutxt,
short = boxuser_menushort,
menu = "system",
tabs = {
{page = "/system/boxuser_list.lua", text = boxuser_listtxt},
{page = "/system/boxuser_settings.lua", text = [[{?3505:382?}]]}
}
}
menu.add_item{
text = [[{?menuSave?}]],
short = [[{?menuSaveShort?}]],
menu = "system",
tabs = {
{ page = "/system/export.lua", text = [[{?3505:545?}]] },
{ page = "/system/import.lua", text = [[{?3505:156?}]] },
{ page = "/system/reboot.lua", text = [[{?3505:718?}]]},
{ page = "/system/defaults.lua", text = [[{?3505:692?}]]}
}
}
menu.add_item{
text = [[{?menuFirmwareUpdate?}]],
short = [[{?menuFirmwareUpdateShort?}]],
menu = "system",
tabs = {
{ page = "/system/update.lua", text = [[{?3505:260?}]] },
{ page = "/system/update_auto.lua", text = [[{?3505:747?}]] },
{ page = "/system/update_file.lua", text = [[{?3505:529?}]] }
}
}
menu.add_item{
text = [[{?menuRegionLanguage?}]],
short = [[{?menuRegionLanguageShort?}]],
menu = "system",
tabs = {
{ page = "/system/language.lua", text = [[{?menuLanguage?}]] },
{ page = "/fon_num/country_prefix.lua", text = [[{?menuCountries?}]] },
{ page = "/system/timezone.lua", text = [[{?menuTimezone?}]] }
}
}
