<?lua
--[[
Datei Name: uleoverview.lua
Datei Beschreibung: Smart Home Overview/Settings
]]
g_page_type = "no_menu"
g_homelink_top = false
g_page_title = [[Smart Home Overview/Settings]]
dofile("../templates/global_lua.lua")
require"general"
require"html"
require("cmtable")
require("capiterm")
require("libaha")
require("bit")
require("string")
------------------------------------------------------------------------------
-- main
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
if box.post.StartULESubscription then
local saveset = {}
cmtable.add_var(saveset, "dect:command/StartULESubscription","1")
box.set_config(saveset)
end
if next(box.post) and box.post.delete and box.post.delete~="" then
local unsubnum = tonumber(box.post.delete);
if (config.DECT2) then
local ctlmgr_save={}
local repeater = general.listquery("dect:settings/Repeater/list(RFPI)")
local device = aha.GetDevice(unsubnum)
if ( device~=nil and repeater~=nil and device.FunctionBitMask and is_repeater(device.FunctionBitMask)) then
for idx, rep in ipairs(repeater) do
rep.id = idx
if (rep.RFPI ~="" and does_ipui_rfpi_match(rep.RFPI, device.Identifyer) ) then
cmtable.add_var(ctlmgr_save, "dect:command/UnsubscribeRepeater", rep.id)
break;
end
end
end
local err,msg = box.set_config(ctlmgr_save)
end
aha.DeleteDevice(unsubnum)
end
if next(box.post) and box.post.update and box.post.update~="" then
local id = tonumber(box.post.update)
aha.DoULEUpdateSearch(id)
end
if next(box.get) and box.get.update and box.get.update~="" then
local id = tonumber(box.get.update)
aha.DoULEUpdateSearch(id)
box.end_page()
end
g_ctlmgr = {}
function get_data()
g_ctlmgr.ules = aha.GetDeviceList()
end
get_data()
g_akt_smarthome_cnt = 0
function show_ules()
local str = ""
if(g_ctlmgr.ules~=nil) then
for idx, ule in ipairs(g_ctlmgr.ules) do
ule.intid = idx - 1
--str = str..[[<td><input type="text" id="uiULEName]] ..ule.ID ..[[" name="ULEName]] ..ule.ID ..[[" class="Eingabefeld" size="21" maxlength="19" value="]]..box.tohtml(ule.Name)..[[" /></td>]]
str = str..[[<td>]]..box.tohtml(ule.Name)..[[</td>]]
str = str..[[<td>]]..box.tohtml(ule.FWVersion)..[[</td>]]
str = str..[[<td>]]..box.tohtml(ule.ID)..[[</td>]]
str = str..[[<td>]]..box.tohtml(ule.Identifyer)..[[</td>]]
str = str..get_buttons(ule)..[[</tr>]]
g_akt_smarthome_cnt = g_akt_smarthome_cnt + 1
end
end
if g_akt_smarthome_cnt == 0 then
str = [[<tr><td colspan="4" class="txt_center">]]..box.tohtml([[No ULEs present]])..[[</td></tr>]]
end
return str
end
function get_buttons(ule)
local onclick = ""
local str = ""
if(ule.ID>=1000 and ule.ID<20000) then
str = str .. [[<td class="buttonrow"></td>]]
else
str = str ..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..ule.ID, "delete", ule.ID, [[delete]], onclick)..[[</td>]]
end
if(ule.ID>=416) then
str = str .. [[<td class="buttonrow"></td>]]
else
str = str ..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/link_closed.gif", "update_"..ule.ID, "update", ule.ID, [[update]], onclick)..[[</td>]]
end
return str
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript">
function InitValues() {
}
ready.onReady(InitValues);
</script>
<?include "templates/page_head_popup.html" ?>
<div id="uiMainDiv">
<!--p>ULE Overview</p-->
<div id="uiSettingsOverview">
<form id="ulemon" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<div style="text-align: right;">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="StartULESubscription">Start ULE Subscription</button>
</div>
<hr>
<div class="formular">
<table id="ule_devices" class="zebra">
<tr>
<th>Name</th>
<th>FW Version</th>
<th>ULE ID</th>
<th>AIN</th>
<!--th class="buttonrow"></th-->
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(show_ules()) ?>
</table>
</div>
</form>
</div>
</div>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
