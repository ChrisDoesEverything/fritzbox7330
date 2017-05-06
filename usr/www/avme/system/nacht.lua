<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_nachtschaltung.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
g_Config_WLAN = config.WLAN
g_Config_BUTTON = config.BUTTON
g_Config_FON = config.FON
g_Config_FonFlags = config.CAPI_TE or config.CAPI_POTS
g_Config_Abcount = config.AB_COUNT
g_Config_MINI = config.MINI
g_HasTime = "box:status/localtime"
g_NightEnabled = "box:settings/night_time_control_enabled"
g_NightStart = "box:settings/night_time_control_off_time"
g_NightEnd = "box:settings/night_time_control_on_time"
g_WlanEnabled = "wlan:settings/night_time_control_enabled"
g_WlanForcedOff = "wlan:settings/night_time_control_no_forced_off"
g_FonEnabled = "box:settings/night_time_control_ring_blocked"
g_HasTime_Value = ( box.query(g_HasTime) ~= "" )
g_NightEnabled_Value =( box.query(g_NightEnabled) == "1")
g_NightStart_Value = box.query(g_NightStart)
g_NightEnd_Value = box.query(g_NightEnd)
g_WlanEnabled_Value = ( box.query(g_WlanEnabled) == "1" )
g_WlanForcedOff_Value = ( box.query(g_WlanForcedOff) == "1" )
g_FonEnabled_Value = ( box.query(g_FonEnabled) == "1" )
g_NightStart_Values = {}
g_NightEnd_Values = {}
function SplitStr( szOrg, szSep)
local n = 1
local ret = { "", "" }
local start = string.find(szOrg, szSep)
if start ~= nil then start = start - 1 end
while (start ~= nil) do
local ende = string.len( szOrg)
local szTmp = string.sub( szOrg, 0, start)
if ( szTmp ~= "") then
ret[n] = szTmp
n = n + 1
end
szOrg = string.sub( szOrg, (start+2), ende)
start = string.find( szOrg, szSep)
if start ~= nil then
start = start - 1
end
end
if ( string.len(szOrg) > 0) then
ret[n] = szOrg
end
return ret
end
function refill_user_input()
g_NightStart_Values[1] = box.post.starthh
g_NightStart_Values[2] = box.post.startmm
g_NightEnd_Values[1] = box.post.endhh
g_NightEnd_Values[2] = box.post.endmm
g_WlanEnabled_Value = ( box.post.wlan_enabled ~= nil )
g_WlanForcedOff_Value = ( box.post.wlan_forced_off ~= nil )
g_FonEnabled_Value = ( box.post.fon_enabled ~=nil )
end
function time_to_device(saveset, node)
if box.query(node.."/NoRingWithNightSetting")=="1" then
cmtable.add_var(saveset, node.."/RingAllowed", "1")
if box.post.fon_enabled then
cmtable.add_var(saveset, node.."/NoRingTime",
string.format("%02d", tonumber(box.post.starthh)) ..
string.format("%02d", tonumber(box.post.startmm)) ..
string.format("%02d", tonumber(box.post.endhh)) ..
string.format("%02d", tonumber(box.post.endmm)))
else
cmtable.add_var(saveset, node.."/NoRingTime", "")
end
end
end
g_val = {
prog = [[
clock_time(uiStartHH/starthh, uiStartMM/startmm, starthh)
clock_time(uiEndHH/endhh, uiEndMM/endmm, endhh)
]]
}
val.msg.starthh = {
[val.ret.notfound] = [[{?915:860?}]],
[val.ret.empty] = [[{?915:403?}]],
[val.ret.format] = [[{?915:677?}]],
[val.ret.outofrange] = [[{?915:798?}]]
}
val.msg.endhh = {
[val.ret.notfound] = [[{?915:805?}]],
[val.ret.empty] = [[{?915:381?}]],
[val.ret.format] = [[{?915:178?}]],
[val.ret.outofrange] = [[{?915:923?}]]
}
g_StartTime_Msg, g_EndTime_Msg, g_StartTime_Attributs, g_EndTime_Attributs = "", "", "", ""
g_NightStart_Values = SplitStr( g_NightStart_Value, ":")
g_NightEnd_Values = SplitStr( g_NightEnd_Value, ":")
if (next(box.post) and (box.post.apply)) then
local errcode, errmsg = "", ""
if val.validate(g_val) == val.ret.ok then
local saveset = {}
if ( g_Config_WLAN) then
cmtable.save_checkbox( saveset, g_WlanEnabled, "wlan_enabled")
if ( box.post.wlan_enabled ~= nil) then
cmtable.save_checkbox( saveset, g_WlanForcedOff, "wlan_forced_off")
end
end
if ( (box.post.wlan_enabled ~= nil) or (box.post.fon_enabled ~= nil)) then
cmtable.add_var( saveset, g_NightEnabled, "1")
else
cmtable.add_var( saveset, g_NightEnabled, "0")
end
cmtable.add_var( saveset, g_NightStart, string.format("%02d", tonumber( box.post.starthh))..":"..
string.format("%02d", tonumber( box.post.startmm)))
cmtable.add_var( saveset, g_NightEnd, string.format("%02d", tonumber( box.post.endhh))..":"..
string.format("%02d", tonumber( box.post.endmm)))
if ( g_Config_FON) then
cmtable.save_checkbox( saveset, g_FonEnabled, "fon_enabled")
for ab=1,tonumber(g_Config_Abcount) do
time_to_device(saveset, "telcfg:settings/MSN/Port"..tostring(ab-1))
end
if config.CAPI_TE then
time_to_device(saveset, "telcfg:settings/MSN/Port3")
end
box.query("telcfg:settings/Foncontrol")
for fc=1,tonumber(box.query("telcfg:settings/Foncontrol/User/count",0)) do
time_to_device(saveset, "telcfg:settings/Foncontrol/User"..tostring(fc-1))
end
end
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_val.errmsg = errmsg
end
else
g_StartTime_Msg = val.get_html_msg(g_val, "uiStartHH")
g_EndTime_Msg = val.get_html_msg(g_val, "uiEndHH")
g_StartTime_Attributs = val.get_attrs(g_val, "uiStartHH")
g_EndTime_Attributs = val.get_attrs(g_val, "uiEndHH")
end
refill_user_input()
end
g_WlanEnabled_Checked = ""
if g_WlanEnabled_Value then
g_WlanEnabled_Checked = "checked"
end
g_WlanForcedOff_Checked = ""
if g_WlanForcedOff_Value then
g_WlanForcedOff_Checked = "checked"
end
g_FonEnabled_Checked = ""
if g_FonEnabled_Value then
g_FonEnabled_Checked = "checked"
end
g_block_noTime = [[
<p>{?915:394?}</p>
]]
if g_NightEnd_Values[1] == "00" and g_NightEnd_Values[2] == "00" then
g_NightEnd_Values[1] = "24"
end
g_block_Time = [[
<div class="formular">
<label for="uiStartHH">{?915:771?}</label>&nbsp;
<input type="text" name="starthh" id="uiStartHH" size="3" maxlength="2" value="]]..box.tohtml(g_NightStart_Values[1])..[[" ]]..g_StartTime_Attributs..[[ /> :
<input type="text" name="startmm" id="uiStartMM" size="3" maxlength="2" value="]]..box.tohtml(g_NightStart_Values[2])..[[" ]]..g_StartTime_Attributs..[[ />
<label for="uiEndHH">&nbsp;{?915:797?}</label>
<input type="text" name="endhh" id="uiEndHH" size="3" maxlength="2" value="]]..box.tohtml(g_NightEnd_Values[1])..[[" ]]..g_EndTime_Attributs..[[ /> :
<input type="text" name="endmm" id="uiEndMM" size="3" maxlength="2" value="]]..box.tohtml(g_NightEnd_Values[2])..[[" ]]..g_EndTime_Attributs..[[ />
]]
if ( g_StartTime_Msg ~= nil) then
g_block_Time = g_block_Time..g_StartTime_Msg
end
if ( g_EndTime_Msg ~= nil) then
g_block_Time = g_block_Time..g_EndTime_Msg
end
l_WlanText = "Das Abschalten des Funknetzes spart Strom. "
if ( g_Config_BUTTON) then
if ( g_Config_FonFlags or ( g_Config_Abcount >= 1)) then
l_WlanText = l_WlanText..[[{?915:314?}]]
else
l_WlanText = l_WlanText..[[{?915:945?}]]
end
else
if ( g_Config_FON) then
l_WlanText = l_WlanText..[[{?915:915?}]]
end
end
g_block_Time = g_block_Time..[[
<div>
<input type="checkbox" name="wlan_enabled" id="uiWlanEnabled" ]]..g_WlanEnabled_Checked..[[ />
<label for="uiWlanEnabled">{?915:491?}</label>
</div>
<div class="formular">
<p>]]..l_WlanText..[[</p>
<div id="uiShow_WlanForcedOff">
<input type="checkbox" name="wlan_forced_off" id="uiWlanForcedOff" ]]..g_WlanForcedOff_Checked..[[ />
<label for="uiWlanForcedOff">{?915:533?}</label>
</div>
</div>
]]
if (( g_Config_FonFlags or ( g_Config_Abcount >= 1)) or ( g_Config_WLAN)) then
g_block_Time = g_block_Time..[[
<div>
<input type="checkbox" name="fon_enabled" id="uiFonEnabled" ]]..g_FonEnabled_Checked..[[ />
<label for="uiFonEnabled">{?915:141?}</label>
</div>
<div class="formular">
<p>{?915:777?}</p>
</div>
]]
end
g_block_Time = g_block_Time..[[
</div>
]]
g_block_TimeButton = [[
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
]]
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_ErrText_NoNumber = "{?915:772?}";
var g_ErrText_NoHour = "{?915:448?}";
function init() {
jxl.addEventHandler( "uiWlanEnabled", "click", OnWlanEnabled);
OnWlanEnabled();
}
function OnWlanEnabled() {
jxl.disableNode( "uiShow_WlanForcedOff", !jxl.getChecked("uiWlanEnabled"));
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
/******* initialize page via js ************/
g_ValPage = false;
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/system/nacht.lua" name="main_form">
<p>{?915:745?}</p>
<?lua
if g_HasTime_Value then
box.out( g_block_Time)
else
box.out( g_block_noTime)
end
?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
if g_HasTime_Value then
box.out([[<div id="btn_form_foot">]])
box.out( g_block_TimeButton)
box.out([[</div>]])
end
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
