<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("check_sid")
if gl.logged_in and box.get.TamNr and tonumber(box.get.TamNr) then
require("fon_devices")
require("cmtable")
local tamlist, tamlist_cnt = fon_devices.read_tam(false,true)
local elem = fon_devices.get_tam_elem(tamlist,tonumber(box.get.TamNr))
local new_val=""
if elem.active then
new_val="0"
box.out([[{"switch_on":false,"cur_idx":]]..box.tojs(box.get.TamNr)..[[,"allin":false,"numbers":""}]])
else
new_val="1"
local numbers = [[]]
for i,num in ipairs(elem.incoming) do
if i > 1 then
numbers = numbers..[[;]]
end
numbers = numbers..box.tojs(num)
end
box.out([[{"switch_on":true,"cur_idx":]]..box.tojs(box.get.TamNr)..[[,"allin":]]..box.tojs(elem.allin)..[[,"numbers":"]]..numbers..[["}]])
end
local saveset={}
cmtable.add_var(saveset,"tam:settings/TAM"..box.get.TamNr.."/Active",new_val)
local err, msg = box.set_config(saveset)
end
?>
