<?lua
package.path = "../lua/?.lua;" .. (package.path or "")
require"check_sid"
require"general"
require("bit")
require("string")
require("cmtable")
box.header("Content-type: application/json\nExpires: -1\n\n")
g_ctlmgr = {}
box.out("{\n")
function is_repeater( n_function_bit_mask)
return bit.isset( tonumber(n_function_bit_mask), tonumber(10))
end
function does_ipui_rfpi_match(rfpi, ipui)
if ( rfpi == nil or ipui == nil or
rfpi == "" or ipui == "") then
return false
end
local iss = string.split(ipui, " ")
local ipui1 = tonumber(iss[1])
local ipui2basic = tonumber(iss[2])
local ipui2 = 0
if ipui2basic >= 1047808 then
ipui2 = bit.maskand(ipui2basic * 8, tonumber("0x07FFFF"))
else
ipui2 = bit.maskand(ipui2basic * 8, tonumber("0x0FFFFF"))
end
local rfpi1 = tonumber("0x" .. string.sub(rfpi, 0,5))
local rfpi2 = tonumber("0x" .. string.sub(rfpi, -5))
return (ipui1 == rfpi1 and ipui2 == rfpi2)
end
require ("libaha")
if box.get.unsubid and box.get.rfpi then
local ctlmgr_save = {}
local g_t_home_automation_list= aha.GetDeviceList()
if ( g_t_home_automation_list~=nil and
#g_t_home_automation_list > 0 ) then
for i=1, #g_t_home_automation_list do
if (is_repeater(g_t_home_automation_list[i].FunctionBitMask) and does_ipui_rfpi_match(box.get.rfpi, g_t_home_automation_list[i].Identifyer) ) then
local unsubnum = tonumber(g_t_home_automation_list[i].ID);
cmtable.add_var(ctlmgr_save, "dect:command/Unsubscribe",unsubnum )
break;
end
end
end
cmtable.add_var(ctlmgr_save, "dect:command/UnsubscribeRepeater", box.get.unsubid)
local err,msg = box.set_config(ctlmgr_save)
end
box.out("\n}\n")
?>
