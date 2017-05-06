<?lua
--
-- query.lua
--
-- Liest Werte von Control-Manager Variablen aus und gibt diese in einer JSON Struktur zurück.
--
-- Jeder GET Parameter wird als <name>=<query> gedeutet. <name> kann dabei relativ frei gewählt werden. <query>
-- ist der Querystring für eine Control-Manager Variable.
--
-- Beispiel: http://fritz.box/query.lua?fw=logic:status/nspver&ld=landevice:settings/landevice/list(name,ip,mac)
--
-- Ja, normale Queries können mit Multiqueries gemischt werden.
--
-- Multiqueries werden am Vorhandensein von "list(...)" in der Query erkannt. Da alte emu-Module dieses Kommando
-- nicht kennen, kann alternativ der Präfix "mq_" vor den Namen der Query gesetzt werden. Beispiel:
-- http://fritz.box/query.lua?mq_log=logger:status/log
-- Nur bei einer "mq_" Liste wird der Knotennamen ("landevice0") mit ausgegeben.
--
-- Und nicht die Session-ID vergessen! Wenn die Box mit einem Passwort gesichert ist, sieht ein Request in
-- Wahrheit so aus:
-- http://fritz.box/query.lua?sid=bc0c3998a520f93c&fw=logic:status/nspver
--
-- Wenn auf der Box kein Passwort gesetzt ist, kann die Session-ID entfallen. Das Skript sorgt dann selbst für
-- eine gültige Session-ID.
--
package.path = "../lua/?.lua;" .. (package.path or "")
--require("check_sid")
dofile("../templates/global_lua.lua")
box.header("Content-Type: application/json; charset=utf-8;\nExpires: -1\n\n")
-- Multiqueries erkennen
function parse_rows(qs)
local pos = string.find(qs, "%(")
if pos == nil then
return nil
end
-- landevice:settings/landevice/list(name,ip,mac)
-- params: ^^^^^^^^^^^
local params = string.sub(qs, pos+1, string.len(qs)-1)
local rows = { "_node" }
for p in string.gmatch(params, "[^,]+") do
table.insert(rows, p)
end
return rows
end
-- Kann der Parameter für queries benutzt werden?
local function is_webvar(param_value)
if type(param_value) ~= 'string' then return false end
local webvar_patterns = {
"^.+(:settings/).+$",
"^.+(:status/).+$",
"^.+(:command/).+$"
}
for _, check in ipairs(webvar_patterns) do
if param_value:match(check) then return true end
end
return false
end
-- Queries in der originalen Reihenfolge abarbeiten
function sort_http_data(tab)
local sdata = {}
local last = 0
for name, value in pairs(tab) do
if string.sub(name,-2)=="_i" and type(value)=="number" then
local p = {}
p.name = string.sub(name,1,string.len(name)-2)
p.value = tab[p.name]
if is_webvar(p.value) then
sdata[value] = p
if value > last then
last = value
end
end
end
end
return sdata, last
end
box.out("{\n")
local first_query = true
local sget,count = sort_http_data(box.get)
for i=1,count do
if sget[i] ~= nil then
local name = sget[i].name
local query = sget[i].value
if string.len(query) > 0 and string.sub(name,-2)~="_i" then
if not first_query then
box.out(",\n")
end
first_query = false
local rows = parse_rows(query)
local special_mq = false
if string.sub(name,1,3)=="mq_" or string.sub(query,string.len(query)-4,string.len(query))=="/list" then
special_mq = true
end
if rows==nil and not special_mq then
local val = box.query(query)
box.out(" \""..name.."\": \"")
box.js(val or "")
box.out("\"")
else
local tab = box.multiquery(query) or {}
box.out(" \""..name.."\" : [\n")
-- sicherstellen, dass rows vollständig ist. Bei multiqueries ohne "list(...)" steht dann da eben row_1, row_2
if rows == nil then
rows = { "_node" }
end
if tab[1] ~= nil then
for i=1,table.maxn(tab[1]) do
if rows[i]==nil then
rows[i]="row_"..i
end
end
end
-- jetzt die Werte rausschreiben
for ti,t in ipairs(tab) do
if ti > 1 then
box.out(",\n")
end
box.out(" {\n")
local first_value = true
for ri,v in ipairs(t) do
if ri > 1 or special_mq then
if not first_value then
box.out(",\n")
end
first_value = false
box.out(" \""..rows[ri].."\" : \"")
box.js(v)
box.out("\"")
end
end
box.out("\n }")
end
box.out("\n ]")
end
end
end
end
box.out("\n}\n")
?>
