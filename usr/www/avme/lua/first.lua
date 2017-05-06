--[[Access denied<?lua
box.end_page()
?>]]
------------------------------------------------------------------------------
-- Dieses Modul hilft beim automatischen Starten der Assistenten beim Aufruf
-- der Oberfläche.
-- Immer gemeinsam mit logincheck.lua betrachten.
module(..., package.seeall)
require("config")
require("cmtable")
require("http")
function go_home()
local redirect_page = "/home/home.lua"
http.redirect(redirect_page)
end
function DoRepLotse()
local params = {}
table.insert(params,'HTMLConfigAssiTyp=first')
http.redirect(href.get_paramtable('/system/rep_mode.lua',params))
end
function go()
if config.LTE then
require("lted")
require"dbg"
require"webuicookie"
if webuicookie.get("lteSetupDone") ~= "1" or lted.get_pin_state() == 'factory_default' then
http.redirect("/assis/internet_lte.lua" .. "?" .. http.url_param("wiztype", "first"))
else
go_home()
end
end
if config.DOCSIS and config.WLAN then
require"dbg"
require"webuicookie"
if webuicookie.get("docsisSetupDone") == "0" then
http.redirect("/assis/wlan_first.lua" .. "?" .. http.url_param("wiztype", "first"))
else
go_home()
end
end
local oem = box.query("env:status/OEM")
local umts_assi="/assis/internet_umts_all.lua"
if oem == "1und1" then
umts_assi="/assis/internet_umts.lua"
end
if oem == "1und1" and config.TR069 and not config.ATA_FULL
and box.query("box:settings/ata_mode") == "0" then
local no_gsm = not config.USB_GSM or box.query("umts:settings/enabled") ~= "1"
local guessed_factorydefaults = false
local page = ""
local username = box.query("connection0:settings/username")
local password = box.query("connection0:settings/password")
local conntype = box.query("connection0:settings/type")
if username == "" and password == "" and conntype == "bridge" then
guessed_factorydefaults = true
page = "tr69_sync"
elseif box.query("tr069:settings/suppress_autoFWUpdate_notify") == "0" then
page = "tr69_warning"
end
local start_normal = no_gsm and guessed_factorydefaults and page ~= ""
local gsm_voice = config.USB_GSM_VOICE
local no_dsl_cable = box.query("box:status/hint_dsl_no_cable") == "1"
local provcode = box.query("tr069:settings/provcode")
local startcode_done = #provcode > 0 and provcode ~= "000.000.000.000"
local umts_off = box.query("umts:settings/enabled") ~= "1"
local umts_1und1 = box.query("umts:settings/name") == "1&1 Internet"
-- 1&1-Umts-Assi starten?
local start_umts = gsm_voice and no_dsl_cable and guessed_factorydefaults and umts_off
local start_umts_startcode = not umts_off and umts_1und1 and not startcode_done
if start_umts then
http.redirect("/assis/internet_umts.lua")
elseif start_normal then
if page == "tr69_warning" then
http.redirect("/tr69_autoconfig/tr069warning.lua")
else
http.redirect("/tr69_autoconfig/tr069startcode.lua" .. "?" .. http.url_param("wiztype", "first"))
end
elseif start_umts_startcode then
http.redirect("/tr69_autoconfig/tr069startcode.lua" .. "?" .. http.url_param("wiztype", "umts"))
else
go_home()
end
end
if config.USB_GSM then
local umts_on = (box.query("umts:settings/enabled") == "1")
local gsm_modem = (box.query("gsm:settings/ModemPresent") == "1")
if umts_on or gsm_modem then
local no_dsl_cable = box.query("box:status/hint_dsl_no_cable") == "1"
local guessed_factorydefaults = false
local page = ""
local username = box.query("connection0:settings/username")
local password = box.query("connection0:settings/password")
local conntype = box.query("connection0:settings/type")
local umts_off = box.query("umts:settings/enabled") ~= "1"
if username == "" and password == "" and conntype == "bridge" then
guessed_factorydefaults = true
end
local start_umts = no_dsl_cable and guessed_factorydefaults and umts_off
if start_umts then
http.redirect(umts_assi)
else
go_home()
end
return
end
end
local no_ata = (box.query("box:settings/ata_mode")=="0")
if no_ata then
local username = box.query("connection0:settings/username")
if oem=="otwo" and string.match(username, "^o2@") and box.query("box:settings/BSA_ON")=="1" then
local saveset = {}
cmtable.add_var(saveset, "box:settings/BSA_ON", "0")
box.set_config(saveset)
http.redirect(href.get("/assis/internet_dsl.lua", http.url_param("o2pin", "")))
end
local password = box.query("connection0:settings/password")
local conntype = box.query("connection0:settings/type")
if username=="" and password=="" and conntype=="bridge" then
http.redirect(href.get("/assis/internet_dsl.lua", http.url_param("wiztype", "first")))
end
end
go_home()
end
