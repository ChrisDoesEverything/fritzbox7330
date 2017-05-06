<?lua
--
-- logincheck.lua
--
-- Dies ist die ultimative Einstiegsseite.
--
dofile("../templates/global_lua.lua")
require("first")
require("http")
require("webuicookie")
g_oem = box.query("env:status/OEM")
-- language/country/annex Assi aufrufen?
if config.MULTI_LANGUAGE or config.MULTI_COUNTRY or config.DSL_MULTI_ANNEX then
local language_ok = true
local country_ok = true
local annex_ok = true
if config.MULTI_LANGUAGE then
language_ok = (box.query("box:settings/IsLanguageSet") ~= "0")
local lang_cnt = tonumber(box.query("language:settings/language/count"))
if not lang_cnt or lang_cnt < 2 then
language_ok = true
end
end
if config.MULTI_COUNTRY then
country_ok = (box.query("box:settings/IsCountrySet") ~= "0")
end
if config.DSL_MULTI_ANNEX then
annex_ok = (box.query("sar:settings/IsAnnexSet") ~= "0")
end
if config.MULTI_COUNTRY and config.DSL_MULTI_ANNEX then
if not country_ok then
annex_ok = false
end
end
if not language_ok or not country_ok or not annex_ok then
local needed = {}
if not language_ok then
table.insert(needed, "language")
end
if not country_ok then
table.insert(needed, "country")
end
if not annex_ok then
table.insert(needed, "annex")
end
needed = table.concat(needed, ",")
http.redirect("/assis/basic_first.lua" .. "?" .. http.url_param("needed", needed))
end
end
local do_crashreport = config.DOCSIS
and box.query("emailnotify:settings/crashreport_mode") == 'disable_mail'
require"boxusers"
if boxusers.show_pwreminder() or do_crashreport then
-- Passwort Erinnerungs Seite anzeigen?
if webuicookie.get("noPwdReminder") ~= "1" or do_crashreport then
http.redirect("/no_password.lua")
end
-- Erinnerungsseite soll nicht angezeigt werden, weiter gehts unten mit first.go()
else
local redirect_page = "/login.lua"
if do_crashreport then
redirect_page = "/login.lua?page=/no_password.lua"
end
-- Passworteingabe anzeigen
http.redirect(redirect_page)
end
-- Internet Assistent oder Startseite
first.go()
?>
