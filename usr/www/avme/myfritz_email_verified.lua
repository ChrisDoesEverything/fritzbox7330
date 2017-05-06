<?lua
--[[
Datei Name: /internet/myfritz_email_verified.lua
Datei Beschreibung: Startet die Boxregistrierung nach erfolgreichem Anmeldem am myfritz AVM Server.
Die Datei wird aus der Ferne aufgerufen und startet die boxregistrierung und redirected danach auf die
myfritz Seite der FRITZ!BOX. Sollte die GUI Passwortgeschützt sein so wird dieses automatisch abgefragt.
]]
g_page_type = "no_menu"
g_page_title = [[]]
dofile("../templates/global_lua.lua")
require("cmtable")
require("http")
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "jasonii:settings/start_register_box", "1")
local err,msg = box.set_config(ctlmgr_save)
http.redirect("/internet/myfritz.lua")
box.end_page()
?>
