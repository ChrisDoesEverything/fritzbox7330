--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
if not gl or not gl.logged_in then
box.end_page()
end
--[[ FILEDESCRIPTION
Die Funktionen hier dienen der Ueberprüfung der Übergebenen Kommandos z.B loeschen oder kopieren. Und zum Ausführen der jeweiligen Aktion.
]]
--[[ Die Funktion ruft das Löschen der übergebenen Ordner und oder Dateien auf.
Welche Dateien oder Ordner gelöscht werden sollen steht in der Variable gl.cmd_files.
]]
function delete_data()
local fail = -1
local err_msg = box.tohtml(TXT([[{?780:137?}]]))
--sind dateien oder ordner zum löschen uebergeben worden.
if gl.cmd_files and #gl.cmd_files > 0 then
--die angegebenen Dateien und oder Ordner löschen
for i,data in ipairs(gl.cmd_files) do
--Wenn das File in der Zwischenablage ist dann dort entfernen
check_file_in_clipboard(data)
--senden des Löschen kommandos an den webusb
fail = gl.bib.wu.WebUsb_Delete(
gl.username, -- user name, not yet supported
data -- directory or file to delete
)
if "number" == type( fail ) then
if fail == 0 then
--alles ok
elseif fail == 1 then
err_msg = box.tohtml(TXT([[{?780:53?}]]))
elseif fail == 2 then
err_msg = box.tohtml(TXT([[{?780:176?}]]))
elseif fail == 3 then
err_msg = box.tohtml(TXT([[{?780:923?}]]))
elseif fail == 4 then
err_msg = box.tohtml(TXT([[{?780:970?}]]))
elseif fail == 9 then
err_msg = box.tohtml(TXT([[{?780:655?}]]))
elseif fail == 16 then
err_msg = box.tohtml(TXT([[{?780:273?}]]))
else
require("general")
err_msg = box.tohtml(general.sprintf(TXT([[{?780:647?}]]), fail))
end
end
end
end
--Rückgabe
return_tab = { err_code=fail, err_msg=err_msg, cmd="delete" }
box.out(gl.bib.js.table(return_tab))
box.end_page()
end
--[[ Die Funktion ruft die Erstellung eines neuen Ordners auf Der name des neuen Ordner steht in der Variable "gl.cmd_files"
]]
function create_newdir()
local fail = -1
local err_msg = box.tohtml(TXT([[{?780:409?}]]))
if gl.cmd_files and gl.cmd_files[1] then
fail = gl.bib.wu.WebUsb_Create(gl.username, gl.var.dir, gl.cmd_files[1])
if "number" == type(fail) then
if fail == 0 then
--alles ok
elseif fail == 1 then
err_msg = box.tohtml(TXT([[{?780:140?}]]))
elseif fail == 3 then
err_msg = box.tohtml(TXT([[{?780:755?}]]))
elseif fail == 4 then
err_msg = box.tohtml(TXT([[{?780:398?}]]))
elseif fail == 5 then
require("general")
err_msg = box.tohtml(general.sprintf(TXT([[{?780:700?}]]), gl.cmd_files[1]))
elseif fail == 9 then
err_msg = box.tohtml(TXT([[{?780:744?}]]))
elseif fail == 16 then
err_msg = box.tohtml(TXT([[{?780:580?}]]))
else
require("general")
err_msg = box.tohtml(general.sprintf(TXT([[{?780:328?}]]), fail))
end
end
end
--Rückgabe
return_tab = { err_code=fail, err_msg=err_msg, cmd="newdir" }
box.out(gl.bib.js.table(return_tab))
box.end_page()
end
--[[ Funktion nimmt ruft das Umbenennen einer Datei oder eines Ordner auf.
Die nötigen Daten welche Datei oder Ordner wie umbenannt werden soll, stehen in der Variable gl.cmd_files
]]
function rename_data()
local err_tab = {}
--cmd_files sind vorhanden und mindestens 2 dann kann das umbennen starten.
if gl.cmd_files and gl.cmd_files[1] and gl.cmd_files[2] then
local loops = #gl.cmd_files
for i = 1, loops, 2 do
local errIdx = #err_tab + 1
err_tab[errIdx] = {}
check_file_in_clipboard( gl.cmd_files[i] )
--senden des Umbenennen kommandos an den webusb
err_tab[errIdx].err_code = gl.bib.wu.WebUsb_Rename(gl.username, gl.cmd_files[i], gl.cmd_files[i + 1])
--err_tab[errIdx].err_code auswerten
if "number" == type(err_tab[errIdx].err_code) then
if err_tab[errIdx].err_code == 0 then
--alles ok
elseif err_tab[errIdx].err_code == 1 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:375?}]]))
elseif err_tab[errIdx].err_code == 2 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:177?}]]))
elseif err_tab[errIdx].err_code == 3 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:614?}]]))
elseif err_tab[errIdx].err_code == 4 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:173?}]]))
elseif err_tab[errIdx].err_code == 5 then
require("general")
err_tab[errIdx].err_msg = box.tohtml(general.sprintf(TXT([[{?780:238?}]]), gl.cmd_files[i+1], gl.cmd_files[i]))
elseif err_tab[errIdx].err_code == 6 then
require("general")
err_tab[errIdx].err_msg = box.tohtml(general.sprintf(TXT([[{?780:152?}]]), gl.cmd_files[i+1], gl.cmd_files[i]))
elseif err_tab[errIdx].err_code == 7 then
require("general")
err_tab[errIdx].err_msg = box.tohtml(general.sprintf(TXT([[{?780:160?}]]), gl.cmd_files[i+1], gl.cmd_files[i]))
elseif err_tab[errIdx].err_code == 8 then
require("general")
err_tab[errIdx].err_msg = box.tohtml(general.sprintf(TXT([[{?780:728?}]]), gl.cmd_files[i+1], gl.cmd_files[i]))
elseif err_tab[errIdx].err_code == 9 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:384?}]]))
elseif err_tab[errIdx].err_code == 10 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:789?}]]))
elseif err_tab[errIdx].err_code == 16 then
err_tab[errIdx].err_msg = box.tohtml(TXT([[{?780:182?}]]))
else
require("general")
err_tab[errIdx].err_msg = box.tohtml(general.sprintf(TXT([[{?780:650?}]]), err_tab[errIdx].err_code))
end
end
end
end
--Rückgabe
return_tab = { errors=err_tab, cmd="rename" }
box.out(gl.bib.js.table(return_tab))
box.end_page()
end
--[[ Dient dazu das Clipboard zu löschen wenn eine Änderung an den Dateien, welche im Clipboard sich befinden, stattfindet
]]
function check_file_in_clipboard(bad_file)
local clipboard = io.open(gl.clipboard, "r")
--kein clipboard da dann kein Problem, raus.
if clipboard==nil then return end
local files = clipboard:read()
clipboard:close()
--keine Files im clipboard dann kein Problem, raus.
if files==nil or files=="" then return end
if string.find(files, bad_file, 1, true) ~= nil then
--löschen der Datei.
os.remove(gl.clipboard)
end
end
function copy_to_clipboard()
local fail = 0
local err_msg = [[]]
--Erstellen eins temporären Files um die zu Kopierenden Daten zwischenzuspeichern
local clipboard = io.open(gl.clipboard, "w")
if clipboard==nil then
fail = -1
err_msg = box.tohtml(TXT([[{?780:289?}]]))
return
else
if gl.cmd_files and #gl.cmd_files > 0 then
for i,data in ipairs(gl.cmd_files) do
clipboard:write(data..gl.delim)
end
end
clipboard:close()
end
--Rückgabe
return_tab = { err_code=fail, err_msg=err_msg, cmd="copy" }
box.out( gl.bib.js.table( return_tab ) )
box.end_page()
end
function copy_from_clipboard_to_destination()
local fail = 0
local err_msg = [[]]
local clipboard = io.open(gl.clipboard, "r")
if clipboard==nil then
fail = -1
err_msg = box.tohtml(TXT([[{?780:48?}]]))
else
local files = clipboard:read()
clipboard:close()
if files==nil or files=="" then return end
--löschen der Datei.
os.remove(gl.clipboard)
local data
--die angegebenen Dateien und oder Ordner kopieren
for data in string.gmatch(files, ".-"..gl.delim) do
--der delimiter am Ende muss noch wech.
data = string.sub(data, 1, string.len(data)-string.len(gl.delim))
fail = gl.bib.wu.WebUsb_Move(
gl.username, -- username, not yet supported
data, -- source directory/file
gl.var.dir -- destination dir
)
--fail auswertung
if "number" == type(fail) then
if fail == 0 then
--alles ok
elseif fail == 1 then
err_msg = box.tohtml(TXT([[{?780:982?}]]))
elseif fail == 2 then
err_msg = box.tohtml(TXT([[{?780:189?}]]))
elseif fail == 3 then
err_msg = box.tohtml(TXT([[{?780:145?}]]))
elseif fail == 4 then
err_msg = box.tohtml(TXT([[{?780:562?}]]))
elseif fail == 5 then
err_msg = box.tohtml(TXT([[{?780:869?}]]))
elseif fail == 6 then
err_msg = box.tohtml(TXT([[{?780:996?}]]))
elseif fail == 7 then
err_msg = box.tohtml(TXT([[{?780:4046?}]]))
elseif fail == 8 then
err_msg = box.tohtml(TXT([[{?780:611?}]]))
elseif fail == 9 then
err_msg = box.tohtml(TXT([[{?780:815?}]]))
elseif fail == 16 then
err_msg = box.tohtml(TXT([[{?780:1038?}]]))
else
require("general")
err_msg = box.tohtml(general.sprintf(TXT([[{?780:9?}]]), fail))
end
end
end
end
--Rückgabe
return_tab = { err_code=fail, err_msg=err_msg, cmd="paste" }
box.out(gl.bib.js.table(return_tab))
box.end_page()
end
function delete_filelink()
if gl.cmd_files and gl.cmd_files[1] then
box.set_config({{["name"]="filelinks:command/"..gl.cmd_files[1],["value"]="delete"}})
end
end
function refresh_filelink_restrictions()
local err_msg = ""
local err_code = -1
if gl.fl_node then
local tab = {}
local tab_cnt = 0
local ctlmgr_var = "filelinks:settings/"..gl.fl_node.."/"
if gl.expire and gl.expire >= 0 and gl.expire < 401 then
tab_cnt = tab_cnt + 1
tab[tab_cnt] = {["name"]=ctlmgr_var.."expire",["value"]=tostring(gl.expire)}
end
if gl.limit and gl.limit >= 0 and gl.limit < 10000 then
tab_cnt = tab_cnt + 1
--Werte immer negativ speichern (ausser 0) sonst aktzeptiert der Unterbau die Änderung nicht (wenn der gleiche Wert nochmal gespeichert wird und setzt den Counter nicht zurück)
if gl.limit > 0 then
gl.limit = "-"..tostring(gl.limit)
end
tab[tab_cnt] = {["name"]=ctlmgr_var.."access_count_limit",["value"]=tostring(gl.limit)}
end
err_code,err_msg = box.set_config(tab)
end
box.out([[{"err_msg":"]]..tostring(err_msg)..[[", "err_code":"]]..tostring(err_code)..[["}]])
box.end_page()
end
function create_filelink()
local err = true
local err_code = -1
local err_msg = box.tohtml(TXT([[{?780:4093?}]]))
local link = ""
local https_active = box.query("remoteman:settings/enabled","0")
local filelink_node = ""
if gl.cmd_files and gl.cmd_files[1] then
local real_path = gl.cmd_files[1]
if #gl.nas_user_dir > 1 then
real_path = gl.nas_user_dir..gl.cmd_files[1]
end
filelink_node = box.query("filelinks:settings/link/newid")
local ctlmgr_var = "filelinks:settings/"..filelink_node.."/"
err_code,err_msg = box.set_config({{["name"]=ctlmgr_var.."path",["value"]=real_path},
{["name"]=ctlmgr_var.."expire",["value"]="0"},
{["name"]=ctlmgr_var.."access_count_limit",["value"]="0"}})
if err_code == 0 then
--alles Gut Dann Link erstellen und den Noch mit zurück geben.
err = false
err_msg = ""
link = gl.bib.share.get_link(filelink_node)
if link == "" then
link = box.tohtml(TXT([[{?780:424?}]]))
end
end
else
--Fehler CommandoDatei nicht da
end
--Rückgabe
box.out([[{"err":"]]..tostring(err)..[[", "err_code":"]]..tostring(err_code)..[[", "err_msg":"]]..box.tojs(err_msg)..[[", "fl_name":"]]..box.tojs(gl.flname)..[[", "fl_node":"]]..box.tojs(filelink_node)..[[", "link":"]]..box.tojs(link)..[[", "https_active":"]]..tostring(https_active)..[["}]])
box.end_page()
end
--gl.cmd beinhaltet das aktuelle commando welches auskunft gibt welche aktion ausgeführt werden soll.
local command_tab = {delete=delete_data,newdir=create_newdir,["rename"]=rename_data,copy=copy_to_clipboard,paste=copy_from_clipboard_to_destination,create_share=create_filelink,del_share=delete_filelink,ref_share=refresh_filelink_restrictions}
if gl.logged_in and not gl.filelink_mode then
command_tab[gl.cmd]()
end
