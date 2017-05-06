--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
if not gl or not gl.logged_in then
box.end_page()
end
--[[checkt ob alle Bedingungen für die jeweiligen Parameter erfüllt sind um diese zu uebertragen.
Wichtig da nicht immer alle Parameter uebergeben werden muessen.
Erster Parameter ist der Parametername des zu Prüfenden Parameters
Zweiter Parameter ist der Wert des zu Prüfenden Parameters
Rueckgabe ist true wenn der parameter uebertragen werden kann, ansonsten false
]]
function check_commit_param(param_name, param_value)
--[[Wichtig:
- Die sid muss immer raus da diese Händisch woanders immer zuerst eingefügt wird.
- Wenn der Value leer ist auch raus.
- Bei einem Paramerter der einen default Wert hat auch raus
- site und dir müssen immer übergeben werden, sollten daher hier nicht in dem if auftauchen.
]]
if(param_name==[[sid]]) or
(param_value==[[]]) or
(param_name==[[style]] and param_value==[[default]]) or
(param_name==[[sort_order]] and param_value==[[up]]) or
(param_name==[[sort_by]] and param_value==[[filename]]) then
return false;
end
return true;
end
--[[Soll die get-Methode zur Uebergabe von Parameter benutzt werden dann muessen die Parameter in der URL uebertragen werden.
Der dazu nötige Parameterstring für einen LINK wird hier erstellt. Dabei werden immer die Alten Parameterwerte benutzt es sei denn man gibt neue an.
Erster Parameter der Funktion ist eine Tabelle welche alle Parameter enthält die ich auf jeden Fall uebertragen
möchte oder welchen ich neue Werte zuordne z.b. 'get_parameter_line({search="irgendetwas",cmd="dir_up"})'.
Rückgabe ist der String der alle nötigen Parameter für eine einwandfreie get-fromatierte Übergabe enthält und nur noch an die URL angehängt werden muss.
]]
function get_parameter_line_for_link(cmd_table)
--zuerst immer die sid mit dem einleitenden Fragezeichen
local tmp=[[?sid=]]..box.tohtml(box.glob.sid)
--Zuerst die parameter anhängen welche ich direkt bekommen habe. Wenn welche da sind.
if cmd_table and type(cmd_table)=="table" then
for param_name, param_value in pairs(cmd_table) do
param_value = box.RFC1630_Escape(tostring(param_value) ,true)
if check_commit_param(param_name, param_value) then
tmp=tmp..[[&]]..param_name..[[=]]..box.tohtml(param_value)
end
end
end
--[[Wenn cmd_table nil ist und somit kein Parameter uebergeben wurde, dann müssen nur die aktuellen werte aus gl.var uebergeben werden.
Wenn cmd_table nicht nil ist, wurden parameter übergeben welche gesetzt werden muessen. Dann gehe alle gl.var
durch und schreibe jene welche nicht in cmd_table enthalten sind.
SOLLTE LOGOUT übergeben worden sein dann nichts weiter anhängen ich will ja eh raus.
]]
if cmd_table and type(cmd_table)=="table" and not cmd_table.logout then
for param_name, param_value in pairs(gl.var) do
param_value = box.RFC1630_Escape(tostring(param_value) ,true)
if (cmd_table==nil or cmd_table[param_name]==nil) and check_commit_param(param_name, param_value) then
tmp=tmp..[[&]]..param_name..[[=]]..box.tohtml(param_value)
end
end
end
return tmp
end
--[[Soll die get-Methode zur Uebergabe von Parameter benutzt werden dann muessen die Parameter in der URL uebertragen werden.
Der dazu nötige Parameterstring für ein FORM wird hier erstellt. Dabei werden alle nötigen Parameter bis auf die expliziet
ausgeschlossenen in den String verarbeite.
Erster Parameter ist eine Tabelle welche alle Parameternamen enthält, welche nicht im String enthalten sein sollen
Rückgabe ist der String der alle nötigen Parameter für eine einwandfreie get-fromatierte Übergabe enthält und
in einem Formular FORM genutzt werden kann.
]]
function get_parameter_line_for_form(name_table)
--Die SID muss immer rein
local tmp=[[<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">]]
for param_name, param_value in pairs(gl.var) do
if (name_table==nil or name_table[param_name]==nil) and check_commit_param(param_name, param_value) then
tmp=tmp..get_single_parameter_line_for_form(param_name, param_value)
end
end
return tmp
end
--[[Die Funktion erstellt einen String der zur Parameter uebergabe für die Methode GET in einer FORM genutzt werden kann.
Erster Parameter ist ein String welcher den Variablennamen enthält, welcher uebergeben werden soll.
Zweiter Parameter ist ein String der den Wert der Variablen enthält die uebergeben werden soll
Rückgabe ist der String der alle nötigen Parameter für eine einwandfreie get-fromatierte Übergabe enthält und
in einem Formular FORM genutzt werden kann.
]]
function get_single_parameter_line_for_form(param_name, param_value)
local tmp = [[<input type="hidden" name="]]..box.tohtml(param_name)..[[" value="]]..box.tohtml(param_value)..[[">]]
return tmp
end
