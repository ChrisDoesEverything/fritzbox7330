<?lua
g_page_type = "all"
g_page_title = box.tohtml( [[{?8428:861?}]])
g_page_help = "hilfe_smart_home_edit_view.html"
g_page_needs_js=true
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("elem")
require("menu")
require("http")
require("newval")
require("cmtable")
require("general")
require("ha_func_lib")
require("libaha")
require("pushservice")
g_back_to_page = http.get_back_to_page( "/net/home_auto_overview.lua" )
g_current_device = nil
g_device_identifier = nil
g_device_fwversion = nil
g_device_id = nil
g_device_name = nil
g_device_model = nil
g_sub_device_model = nil
g_device_manufacturer = nil
g_device_valid = nil
g_device_update = nil
g_device_func_mask = nil
g_device_group_hash = nil
g_device_is_group_member = nil
g_device_group_name = nil
g_t_group_name_list = {}
g_device_defaults = nil
g_switch = nil
g_device_temperature = nil
g_pushmailcfg = nil
g_device_heater_sheduled = nil
g_device_heater_reduce_temp = nil
g_device_heater_heat_temperature = nil
g_errmsg = nil
<?include "net/home_auto_x_view_tabs.lua" ?>
function init_page_vars( device, bForSelect)
if ( ha_func_lib.is_valid_uleid( device) == false) then
return false
end
g_current_device = aha.GetDevice(tonumber(device))
if ( g_current_device == nil) then
return false
end
g_device_id = g_current_device.ID
g_device_identifier = g_current_device.Identifyer
g_device_fwversion = g_current_device.FWVersion
g_device_name = g_current_device.Name
g_device_model = g_current_device.Model
g_device_sub_model = g_current_device.SubModel
g_device_manufacturer = g_current_device.Manufacturer
g_device_valid = g_current_device.Valid
g_device_update = g_current_device.UpdatePresent
g_device_func_mask = g_current_device.FunctionBitMask
g_device_group_hash = g_current_device.GroupHash
g_t_group_name_list = ha_func_lib.initialize_group_name_list( aha.GetDeviceList(), false)
g_device_is_group_member, g_device_group_name, g_device_group_hash = ha_func_lib.is_group_member( g_t_group_name_list, g_current_device.GroupHash)
g_t_group_name_list = ha_func_lib.initialize_group_name_list( aha.GetDeviceList(), bForSelect)
g_device_defaults = aha.GetEnergyDefaults()
g_switch = ha_func_lib.get_switch( device)
if ha_func_lib.can_temperature( g_device_func_mask) then
g_device_temperature = aha.GetTemperature( tonumber(g_device_id))
end
g_pushmailcfg = aha.GetPushMailConfig(tonumber(device))
g_device_heater_sheduled = "21,5"
g_device_heater_reduce_temp = "3,5"
g_device_heater_heat_temperature = "16,5"
g_local_tabs = {}
if ( ha_func_lib.is_outlet( g_device_func_mask) ) then
table.insert( g_local_tabs, g_tab_2)
end
if ( ha_func_lib.has_energy_monitor( g_device_func_mask) ) then
table.insert( g_local_tabs, g_tab_3)
end
if ( #g_local_tabs > 0) then
table.insert( g_local_tabs, 1, g_tab_1)
menu.add_param_to_local_tabs( g_local_tabs, ([[device=]]..device..[[&sub_tab=watt]]) )
else
g_local_tabs = nil
end
g_page_title = g_page_title..[["]]..tostring(g_device_name)..[["]]
return true
end
function is_valid_switch_default_state( n_state)
if ( (n_state == 0) or (n_state == 1) or (n_state == 2)) then
return true
end
return false
end
local l_device_id = nil
local l_b_for_select = true
if ( next(box.get)) then
l_device_id = box.get.device
end
if ( next(box.post)) then
if (box.post.cancel) then
http.redirect( [[/net/home_auto_overview.lua]])
end
if (box.post.apply) then
l_b_for_select = false
end
l_device_id = box.post.current_ule
end
if ( init_page_vars( l_device_id, l_b_for_select) == false) then
http.redirect( g_back_to_page )
end
function energy_monitor_available()
return ha_func_lib.has_energy_monitor( g_device_func_mask)
end
function outlet_available()
return ha_func_lib.is_outlet( g_device_func_mask)
end
function temperature_available()
return ha_func_lib.can_temperature( g_device_func_mask)
end
local function val_prog()
if energy_monitor_available() then
newval.is_float("ule_device_acdc_rate",2,1000,"euro_float")
newval.is_float("ule_device_co2_emission",3,150,"co2_float")
end
if temperature_available() then
newval.is_float_plus("device_temp_offset",-20,20,"temperature_offset")
end
if pushservice.smarthome_possible(g_current_device) then
pushservice.smarthome_validation()
end
end
newval.msg.euro_float = {
[newval.ret.notfound] = [[{?8428:259?}]],
[newval.ret.empty] = [[{?8428:280?}]],
[newval.ret.wrong] = [[{?8428:528?}]],
[newval.ret.format] = [[{?8428:630?}]],
[newval.ret.toomuch] = [[{?8428:417?}]],
[newval.ret.outofrange] = [[{?8428:943?}]]
}
newval.msg.co2_float = {
[newval.ret.notfound] = [[{?8428:609?}]],
[newval.ret.empty] = [[{?8428:70?}]],
[newval.ret.wrong] = [[{?8428:755?}]],
[newval.ret.format] = [[{?8428:698?}]],
[newval.ret.toomuch] = [[{?8428:45?}]],
[newval.ret.outofrange] = [[{?8428:835?}]]
}
newval.msg.temperature_offset = {
[newval.ret.notfound] = [[{?8428:275?}]],
[newval.ret.empty] = [[{?8428:737?}]],
[newval.ret.wrong] = [[{?8428:993?}]],
[newval.ret.format] = [[{?8428:136?}]],
[newval.ret.toomuch] = [[{?8428:816?}]],
[newval.ret.outofrange] = [[{?8428:720?}]]
}
g_val_result = newval.ret.ok
if ( box.post.validate == "apply") then
require("js")
local valresult, answer = newval.validate(val_prog)
g_val_result = valresult
box.out( js.table( answer))
box.end_page()
end
if ( next(box.post)) then
local saveset = {}
if ((box.post.apply) and ( g_val_result == newval.ret.ok)) then
aha.SetName( tonumber(box.post.current_ule), tostring(box.post.ule_device_name))
if ( ha_func_lib.is_outlet(g_device_func_mask)) then
if ( is_valid_switch_default_state( tonumber(box.post.switch_default_state))) then
aha.SetSwitchOptions( tonumber(box.post.current_ule), tonumber(box.post.switch_default_state))
g_switch.Options = tonumber(box.post.switch_default_state)
end
local l_manuell_switch_active = "7"
if ((box.post.manuell_switch_active ~= nil) and (box.post.manuell_switch_active == "1")) then
l_manuell_switch_active = "0"
end
g_switch.SwitchLock = tonumber(l_manuell_switch_active)
aha.SetSwitchLock( tonumber(box.post.current_ule), tonumber(l_manuell_switch_active))
local l_led_active = "3"
if ((box.post.led_active ~= nil) and (box.post.led_active == "1")) then
l_led_active = "2"
end
g_switch.LEDState = tonumber(l_led_active)
aha.SetSwitchLEDState( tonumber(box.post.current_ule), tonumber(l_led_active))
if ((tostring(box.post.device_group_name) ~= "0") or (tostring(g_device_group_hash) ~= "0")) then
local l_group_name_to_store = tostring(box.post.device_group_name)
if ( l_group_name_to_store == "0") then
l_group_name_to_store = ""
local b_group_exist, sz_group_name = ha_func_lib.is_group_member( g_t_group_name_list, g_device_group_hash)
local l_device_timer_state = aha.GetSwitchTimer( tonumber(g_device_id))
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( l_device_timer_state)
if ((l_b_value == true) and ( l_sz_name == 'calendar')) then
local l_sz_calender = ha_func_lib.get_calendar_name( tonumber(g_device_id))
local l_b_cal_exist, l_sz_node, l_sz_devices = ha_func_lib.calendar_always_exist( tostring(l_sz_calender))
if ( l_b_cal_exist == true) then
local sz_to_find = tostring(g_device_id)..[[;]]
local l_newer_devices, n_how_many = string.gsub( l_sz_devices, sz_to_find, "")
if ( l_newer_devices == "") then
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/deviceid]], l_newer_devices)
cmtable.add_var( saveset, [[oncal:command/do_sync]], [[1]])
end
end
else
local member_id = ha_func_lib.get_id_of_existing_group( g_t_group_name_list, l_group_name_to_store)
if ( tonumber(member_id) ~= 0) then
local l_device_timer_state = aha.GetSwitchTimer( tonumber(member_id))
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( l_device_timer_state)
if ((l_b_value == true) and ( l_sz_name == 'calendar')) then
local l_sz_calender = ha_func_lib.get_calendar_name( tonumber(member_id))
local l_b_cal_exist, l_sz_node, l_sz_devices = ha_func_lib.calendar_always_exist( tostring(l_sz_calender))
if ( l_b_cal_exist == true) then
local l_new_devices = l_sz_devices
local sz_to_find = tostring(g_device_id)..[[;]]
local nBegin = string.find( l_sz_devices, sz_to_find)
if ( tostring(nBegin) == tostring(nil) ) then
l_new_devices = l_sz_devices..tonumber(g_device_id)..[[;]]
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(1))
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/deviceid]], l_new_devices)
end
end
end
end
aha.EditDeviceGroup( tonumber(g_device_id), tostring(l_group_name_to_store))
end
end
if ( ha_func_lib.has_energy_monitor(g_device_func_mask)) then
local sz_euro = box.post.ule_device_acdc_rate
sz_euro, n_count = string.gsub(sz_euro, [[,]], [[.]])
local sz_co2 = box.post.ule_device_co2_emission
sz_co2, n_count = string.gsub(sz_co2, [[,]], [[.]])
g_device_defaults.Tarif = tosigned(sz_euro)*100
g_device_defaults.CO2Emission = tosigned(sz_co2)*1000
aha.SetEnergyDefaults( g_device_defaults)
end
if ( ha_func_lib.can_temperature(g_device_func_mask)) then
local l_sz_offset, n_count = string.gsub(box.post.device_temp_offset, [[,]], [[.]])
local l_n_offset = tosigned( l_sz_offset)*10
aha.SetTemperatureOffset( tonumber(g_device_id), l_n_offset)
end
if pushservice.smarthome_possible(g_current_device) then
pushservice.save_data_smarthome(g_pushmailcfg)
end
end
if ( g_val_result == newval.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode == 0 then
if ( box.post.apply) then
http.redirect( [[/net/home_auto_overview.lua]])
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/kids.css"/> -->
<style type="text/css">
.mt5 {margin-top: 5px;}
.mb0 {margin-bottom: 0px;}
.mb15 {margin-bottom: 15px;}
.pb0 {padding-bottom: 0px;}
.temp_label_1 {margin: 0px 4px 0px 100px; width: 60px;}
.temp_label_2 {padding: 0px 100px 0px 3px;}
.input_real { text-align: right; width: 60px;}
#uiLabel_DeviceTempOffset { width: 60px;}
#ui_ULEDeviceACDCRate,
#ui_ULEDeviceCO2Emission,
#ui_DeviceTempOffset { width: 60px;}
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?8428:418?}</p>
<hr>
<?lua
ha_func_lib.get_device_tab_head( g_device_id, true, true)
if ( ha_func_lib.is_hkr( g_device_func_mask) ) then
box.out( [[<hr>]])
box.out( [[<h4>{?8428:547?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( elem._label( "uiULEDeviceHeaterScheduled", "LabeluiULEDeviceHeaterScheduled", [[{?8428:563?}]]))
box.out( elem._input_plusplus( "text", "ule_device_heater_scheduled", "uiULEDeviceHeaterScheduled", g_device_heater_sheduled, "6", "6", [[text-align:right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiULEDeviceHeaterScheduled", "LabeluiULEDeviceHeaterScheduled2", [[{?8428:470?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular" >]])
box.out( elem._label( "uiULEDeviceHeaterReduceTemp", "LabeluiULEDeviceHeaterReduceTemp", [[{?8428:180?}]]))
box.out( elem._input_plusplus( "text", "ule_device_heater_reduce_temp", "uiULEDeviceHeaterReduceTemp", g_device_heater_reduce_temp, "6", "6", [[text-align:right;]], [[]],[[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiULEDeviceHeaterReduceTemp", "LabeluiULEDeviceHeaterReduceTemp2", [[{?8428:837?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular" >]])
box.out( elem._label( "uiULEDeviceHeaterHeatTemp", "LabeluiULEDeviceHeaterHeatTemp", [[{?8428:125?}]]))
box.out( elem._input_plusplus( "text", "ule_device_heat_temperature", "uiULEDeviceHeaterHeatTemp", g_device_heater_heat_temperature, "6", "6", [[text-align:right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiULEDeviceHeaterHeatTemp", "LabeluiULEDeviceHeaterHeatTemp2", [[{?8428:808?}]]))
box.out( [[</div>]])
end
if ( ( ha_func_lib.is_outlet( g_device_func_mask)) or
( ha_func_lib.can_temperature( g_device_func_mask)) or
( ha_func_lib.has_energy_monitor(g_device_func_mask)) ) then
if ( ha_func_lib.is_outlet(g_device_func_mask)) then
box.out( [[<hr>]])
box.out( [[<h4>{?8428:809?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( [[<p>{?8428:545?}</p>]])
box.out( [[<div class="formular" >]])
box.out( elem._radio( "switch_default_state", "uiView_SwitchDefaultState_Last", "2", (tostring(g_switch.Options) == '2'), [[onclick="OnChange_SwitchDefaultState('2')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchDefaultState_Last", "LabeluiView_SwitchDefaultState_Last", [[{?8428:671?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular" >]])
box.out( elem._radio( "switch_default_state", "uiView_SwitchDefaultState_Off", "0", (tostring(g_switch.Options) == '0'), [[onclick="OnChange_SwitchDefaultState('0')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchDefaultState_Off", "LabeluiView_SwitchDefaultState_Off", [[{?8428:262?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular" >]])
box.out( elem._radio( "switch_default_state", "uiView_SwitchDefaultState_On", "1", (tostring(g_switch.Options) == '1'), [[onclick="OnChange_SwitchDefaultState('1')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchDefaultState_On", "LabeluiView_SwitchDefaultState_On", [[{?8428:321?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
end
if ( ha_func_lib.is_outlet(g_device_func_mask)) then
box.out( [[<hr>]])
box.out( [[<h4>{?8428:817?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( [[<p>{?8428:8373?}</p>]])
box.out( [[<p class="formular" >]])
box.out( [[<p>]])
box.out( elem._label( "uiView_GroupName", "LabeluiView_GroupName", [[{?8428:5010?}]]))
local l_select_value = ha_func_lib.get_groupname_by_hash( g_device_group_hash)
box.out( elem._select( "device_group_name", "uiView_GroupName", g_t_group_name_list, l_select_value))
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_GroupName_Link", "LabeluiView_GroupName_Link", [[{?8428:649?}]]))
box.out( [[<a href="javascript:OnClick_AppendGroupName();" >{?8428:633?}</a>]] )
box.out( [[</p>]])
box.out( [[</p>]])
box.out( [[</div>]])
end
if ( ha_func_lib.has_energy_monitor(g_device_func_mask)) then
box.out( [[<hr>]])
box.out( [[<h4>{?8428:355?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( elem._label( "ui_ULEDeviceACDCRate", "LabeluiULEDeviceACDCRate", [[{?8428:606?}]]))
box.out( elem._input_new( "text", "ule_device_acdc_rate", "ui_ULEDeviceACDCRate", ha_func_lib.value_as_float(tonumber(g_device_defaults.Tarif)/100, 2), "6", [[input_real]], [[]], [[]]))
box.out( [[&nbsp;&nbsp;]])
box.out( elem._label( "ui_ULEDeviceACDCRate", "LabeluiULEDeviceACDCRate2", [[{?8428:191?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular" >]])
box.out( elem._label( "ui_ULEDeviceCO2Emission", "LabeluiULEDeviceCO2Emission", [[{?8428:58?}]]))
box.out( elem._input_new( "text", "ule_device_co2_emission", "ui_ULEDeviceCO2Emission", ha_func_lib.value_as_float(tonumber(g_device_defaults.CO2Emission)/1000, 3), "6", [[input_real]], [[]], [[]]))
box.out( [[&nbsp;&nbsp;]])
box.out( elem._label( "ui_ULEDeviceCO2Emission", "LabeluiULEDeviceCO2Emission2", [[{?8428:881?}]]))
box.out( [[</div>]])
end
if ( ha_func_lib.is_outlet( g_device_func_mask)) then
box.out( [[<hr>]])
box.out( [[<div><a id="uiLink_ShowMore" href="javascript:OnClick_ShowMoreArea();" class="textlink nocancel">]]..[[{?8428:821?}]]..[[<img id="uiLink_ShowMoreArea_Img" src="/css/default/images/link_open.gif" height="12"></a></div>]])
box.out( [[<div id="uiView_ShowMoreArea" style="display: none;">]])
else
box.out( [[<div id="uiView_ShowMoreArea">]])
end
if ( ha_func_lib.is_outlet(g_device_func_mask) and ha_func_lib.is_local(g_device_id)) then
box.out( [[<h4>{?8428:370?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( [[<p>{?8428:616?}</p>]])
box.out([[<div class="formular" id="uiShow_Led_Active">]] )
box.out( elem._checkbox( "led_active", "uiView_LEDActive", "1", (tostring(g_switch.LEDState) == "2"), [[onclick="OnChange_LEDActive(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_LEDActive", "uiView_LabelLEDActive",[[{?8428:38?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<hr>]])
end
if ( ha_func_lib.is_outlet(g_device_func_mask)) then
box.out( [[<h4>{?8428:522?}</h4>]])
box.out( [[<div class="formular" >]])
box.out( [[<p>{?8428:890?}</p>]])
box.out([[<div class="formular" id="uiShow_Led_Active">]] )
box.out( elem._checkbox( "manuell_switch_active", "uiView_ManuellSwitchActive", "1", (tostring(g_switch.SwitchLock) == "0"), [[onclick="OnChange_ManuellSwitchActive(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_ManuellSwitchActive", "uiView_LabelManuellSwitchActive",[[{?8428:820?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
end
if ( ha_func_lib.can_temperature(g_device_func_mask)) then
box.out( [[<hr>]])
box.out( [[<h4>{?8428:352?}</h4>]])
local l_temp = aha.GetTemperature( tonumber(g_device_id))
box.out( [[<div class="formular" >]])
box.out( [[<p>{?8428:739?}</p>]])
box.out( [[<div class="formular" >]])
local l_measured_value = (( tonumber( g_device_temperature.Celsius) + ((-1)*tonumber(g_device_temperature.Offset)) )/10)
local l_temperature_value = ha_func_lib.value_as_float( (tonumber( g_device_temperature.Celsius)/10), 1)
local sz_measured_value = ha_func_lib.value_as_float( l_measured_value, 1)
if(g_device_temperature.Celsius == -9999)then
sz_measured_value = ""
l_temperature_value = ""
end
box.out( [[{?8428:5157?} <nobr><span id="ui_MeasuredTemperature" class="output" style="width:50px; text-align: right;">]]..box.tohtml( sz_measured_value)..[[</span></nobr> °C]] )
box.out( elem._label( "ui_DeviceTempOffset", "uiLabel_DeviceTempOffset", [[{?8428:790?}]], nil, [[temp_label_1]]) )
box.out( elem._input_new( "text", "device_temp_offset", "ui_DeviceTempOffset", ha_func_lib.value_as_float( ( tonumber(g_device_temperature.Offset)/10), 1), "5", [[temp_offset_input]] , [[text-align:right;]], [[onchange="OnChange_TempOffset(this.value)"]]))
box.out( elem._label( "ui_DeviceTempOffset", "uiLabel_DeviceTempOffset2", [[{?8428:372?}]], nil, [[temp_label_2]]) )
box.out( [[{?8428:3424?} <nobr><span id="ui_ShowTemperature" class="output" style="width:50px; text-align: right;">]]..box.tohtml( l_temperature_value )..[[</span></nobr> °C]] )
box.out( [[</div>]])
box.out( [[</div>]])
end
if ( pushservice.smarthome_possible(g_current_device)) then
box.out([[<hr>]])
box.out([[<h4>{?8428:848?}</h4>]])
box.out([[<div class="formular">]])
pushservice.smarthome_write_explain()
if not pushservice.account_configured() then
box.out([[
<strong>{?8428:691?}</strong>
]])
box.out([[
<p>{?8428:375?}</p>
]])
end
box.out( [[</div>]])
box.out( [[<div class="formular" id="uiShow_PushService_Available">]])
pushservice.smarthome_writehtml{pushmailcfg=g_pushmailcfg}
box.out( [[</div>]])
end
box.out( [[</div>]])
end
box.out( [[<div class="formular">]])
if ( g_errmsg and string.len(g_errmsg)>0 ) then
box.out([[<p class="form_input_note ErrorMsg">]])
box.html(g_errmsg)
box.out([[</p>]])
end
box.out( [[</div>]])
?>
<div id="btn_form_foot">
<input type="hidden" name="current_ule" value="<?lua box.html(g_device_id) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?8428:999?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ha_sets.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var g_ShowMoreArea = false;
var g_TO_All_States_Value = 1000 * 37; // alle 37 sec.
var g_device_Name = "<?lua box.js(g_device_name) ?>";
var g_GroupName = "<?lua box.js(g_device_group_name) ?>";
var g_GroupExist_Count = <?lua box.js(#g_t_group_name_list) ?>;
var g_device_GroupName = "<?lua box.js(g_device_group_hash) ?>";
var g_ar_Init_GroupNames = new Array();
var g_device_LockSwitchState = "<?lua box.js(g_switch.SwitchLock) ?>";
var json = makeJSONParser();
var sidParam = buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
if ( g_device_LockSwitchState == "0") {
g_device_LockSwitchState = "1";
} else {
g_device_LockSwitchState = "0";
}
function GroupNameExist( newGroupName, arToSearchIn) {
for ( var i = 0; i < arToSearchIn.length; i++) {
if ( arToSearchIn[i] == newGroupName) {
return true;
}
}
return false;
}
function GetOutletStates( szDeviceID) {
// Ajax get zum Abfragen.
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "OutletStates");
url += "&" + buildUrlParam( "id", szDeviceID);
ajaxGet( url, cb_Receive_Outlet_State_Values)
}
function cb_Receive_Outlet_State_Values(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult != "0")) {
ha_sets.setConnectStateOf( response.DeviceID, response.DeviceConnectState);
ha_sets.setSwitchStateOf( response.DeviceID, response.DeviceSwitchState);
setTimeout( "GetOutletStates("+response.DeviceID+")", g_TO_All_States_Value);
}
}
function onEditDevSubmit() {
}
function OnChange_SwitchDefaultState( szValue) {
}
function OnChange_PushServiceActive( bValue) {
jxl.enableNode( "uiShow_PushServiceOptions", bValue );
if ( bValue ) {
jxl.setValue( "uiView_PushServiveActive", 1);
} else {
jxl.setValue( "uiView_PushServiveActive", 0);
}
}
function OnChange_LEDActive( bValue) {
if ( bValue ) {
jxl.setValue( "uiView_LEDActive", 1);
} else {
jxl.setValue( "uiView_LEDActive", 0);
}
}
function OnChange_ManuellSwitchActive( bValue) {
if ( bValue ) {
jxl.setValue( "uiView_ManuellSwitchActive", 1);
} else {
jxl.setValue( "uiView_ManuellSwitchActive", 0);
}
}
function OnFocus_OfOffset() {
jxl.removeClass( "ui_DeviceTempOffset", "error");
}
function OnChange_TempOffset( szValue) {
var nPos = szValue.indexOf( ",");
if ( nPos!= (-1)) {
szValue = szValue.replace( ",", ".");
}
var szShowValue = jxl.getText( "ui_MeasuredTemperature");
szShowValue = szShowValue.replace( ",", ".");
var nShowValue = Number(szShowValue);
var nValue = Number(szValue);
if ( isNaN( nValue)) {
alert( "{?8428:79?}");
jxl.addClass( "ui_DeviceTempOffset", "error");
elem = jxl.get( "ui_DeviceTempOffset");
elem.addEventListener( 'focus', onFocus_OfOffset, 1);
} else {
var nTemp = Number((nShowValue + nValue)).toFixed(1);
szShowValue_New = String( nTemp).replace( ".", ",");
szValue_New = String( nValue).replace( ".", ",");
jxl.setValue( "ui_DeviceTempOffset", szValue_New);
jxl.setText( "ui_ShowTemperature", szShowValue_New);
}
}
function OnChange_PushService_Intervall( szValue) {
}
function OnChange_PushService_InfoType( szValue) {
}
function OnChange_PushServiceEverySwitch( bValue) {
if ( bValue ) {
jxl.setValue( "uiView_PushServiveEverySwitch", 1);
} else {
jxl.setValue( "uiView_PushServiveEverySwitch", 0);
}
}
function OnClick_AppendGroupName() {
if ( g_GroupExist_Count == 10) {
alert( "{?8428:770?}");
return;
}
var arGroupNames = new Array();
for ( var i = 0; i < jxl.lenSelection("uiView_GroupName"); i++) {
arGroupNames[i] = jxl.getOptionTextOf( "uiView_GroupName", i);
}
var szDefaultValue = jxl.getValue( "uiView_GroupName");
if ( szDefaultValue == "0") {
szDefaultValue = "";
}
var new_GroupName = prompt( "{?8428:863?}",szDefaultValue);
if ( new_GroupName != null ) {
if (new_GroupName == "") {
alert( "{?8428:83?}");
jxl.setSelection( "uiView_GroupName", szDefaultValue);
} else {
if ( GroupNameExist( new_GroupName, arGroupNames)) {
alert( "{?8428:580?}");
jxl.setSelection( "uiView_GroupName", szDefaultValue);
} else {
jxl.addOption( "uiView_GroupName", new_GroupName, new_GroupName);
jxl.setSelection( "uiView_GroupName", new_GroupName);
}
}
}
}
function OnClick_ShowMoreArea() {
g_ShowMoreArea =! g_ShowMoreArea;
jxl.display( "uiView_ShowMoreArea", g_ShowMoreArea);
var img = jxl.get( "uiLink_ShowMoreArea_Img")
if ( img) {
img.src = g_ShowMoreArea ? '/css/default/images/link_closed.gif' : '/css/default/images/link_open.gif';
}
}
function onSubmit_SaveSetting() {
if (( jxl.getValue( "uiView_GroupName") != "0" ) &&
( jxl.getValue( "uiView_GroupName") != g_GroupName ) &&
( GroupNameExist( jxl.getValue( "uiView_GroupName"), g_ar_Init_GroupNames))) {
return confirm('{?8428:237?} ');
}
if ( !(jxl.getChecked("uiView_ManuellSwitchActive"))) {
if ( String( g_device_LockSwitchState) != String( jxl.getValue( "uiView_ManuellSwitchActive"))) {
return confirm('{?8428:732?} ');
}
}
return true;
}
function init() {
<?lua
if pushservice.smarthome_possible(g_current_device) then
box.out([[
enableOnClick({inputName: "enabled", classString: "enableif_enabled"});
enableOnClick({inputName: "periodic", classString: "enableif_periodic"});
]])
if not pushservice.account_configured() then
box.out([[
jxl.disableNode("uiShow_PushService_Available", true);
]])
end
end
if ( ha_func_lib.is_outlet( g_device_func_mask)) then
box.out( [[setTimeout( "GetOutletStates( ]]..tostring( g_device_id)..[[)", 10000);]] )
end
?>
for ( var i = 0; i < jxl.lenSelection("uiView_GroupName"); i++) {
g_ar_Init_GroupNames[i] = jxl.getOptionTextOf( "uiView_GroupName", i);
}
}
ready.onReady(ajaxValidation({
formNameOrIndex: "main_form",
applyNames: "apply"
}));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
