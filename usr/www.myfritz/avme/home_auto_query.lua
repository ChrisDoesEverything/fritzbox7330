<?lua
--
-- home_auto_query.lua
--
--
-- Wenn auf der Box kein Passwort gesetzt ist, kann die Session-ID entfallen. Das Skript sorgt dann selbst für
-- eine gültige Session-ID.
--
package.path = "../lua/?.lua;" .. (package.path or "")
require"check_sid"
require"general"
require"ha_func_lib"
box.header("Content-type: application/json\nExpires: -1\n\n")
function request_type_is()
if ( box.post ~= nil) and ( box.post.xhr ~= nil) then
return "POST"
else
if ( box.get ~= nil) and ( box.get.xhr ~= nil) then
return "GET"
else
return "unknown"
end
end
end
function get_switch_timer_values( sz_value_to_compare, t_timer_state)
local l_ret_timer = {}
local l_b_timer_exist = false
if ( t_timer_state and t_timer_state[sz_value_to_compare] and t_timer_state[sz_value_to_compare][1]) then
l_ret_timer = t_timer_state[sz_value_to_compare]
l_b_timer_exist = true
end
return l_b_timer_exist, l_ret_timer
end
function write_stats_of( t_stats, sz_base_name, b_get_means)
local l_ret = "0"
local l_min_value = 3000000000
local l_max_value = 0
local l_average_value = 0
if ( t_stats ~= nil) then
box.out( [[ "EnStats_count" : "]]..tostring( t_stats.anzahl)..[[" ,]] )
box.out( [[ "EnStats_timer_type" : "]]..tostring(t_stats.times_type)..[[" ,]] )
if (t_stats.values ~= nil) then
for i=1, #t_stats.values do
box.out( [[ "]]..sz_base_name..tostring(i)..[[" : "]]..tostring(t_stats.values[i])..[[" ,]] )
if ( tonumber(l_max_value) <= tonumber(t_stats.values[i])) then
l_max_value = tonumber(t_stats.values[i])
end
if ( tonumber(l_min_value) >= tonumber(t_stats.values[i])) then
l_min_value = tonumber(t_stats.values[i])
end
l_average_value = l_average_value + tonumber(t_stats.values[i])
end
l_average_value = math.floor((l_average_value/(#t_stats.values)))
end
if ( b_get_means == true) then
box.out( [[ "EnStats_min_value" : "]]..tostring(l_min_value)..[[" ,]] )
box.out( [[ "EnStats_max_value" : "]]..tostring(l_max_value)..[[" ,]] )
box.out( [[ "EnStats_average_value" : "]]..tostring(l_average_value)..[[" ,]] )
end
l_ret = "1"
end
return l_ret
end
box.out("{\n")
g_requestType = request_type_is()
if ((g_requestType == "POST") or (g_requestType == "GET")) then
require ("libaha")
local l_device = nil
local l_return_value = nil
local l_request_result = "0"
if ( g_requestType == "POST") then
require("cmtable")
local t_saveset = {}
if ( ha_func_lib.is_valid_uleid( box.post.id) == true) then
l_device = aha.GetDevice( tonumber(box.post.id))
if ((l_device ~= nil) and ( tostring(box.post.command) == "SwitchOnOff")) then
aha.SetSwitchOnOff( tonumber(l_device.ID), tonumber( box.post.value_to_set))
l_switch_state = aha.GetSwitch( tonumber(l_device.ID))
l_return_value = l_switch_state.SwitchOn
box.out( [["DeviceID" : "]]..l_device.ID..[[" ,]] )
box.out( [["ValueToSet" : "]]..box.post.value_to_set..[[" ,]] )
box.out( [["Value" : "]]..l_return_value..[[" ,]] )
l_request_result = "1"
elseif ((l_device ~= nil) and ( tostring(box.post.command) == "PushServiceNow")) then
local l_t_push_service_config = aha.GetPushMailConfig(tonumber(l_device.ID))
local l_ps_email = box.query( "emailnotify:settings/To")
if (l_t_push_service_config.email == nil) then
l_t_push_service_config.email = tostring("")
end
l_t_push_service_config.interval = tonumber(box.post.push_service_interval)
l_t_push_service_config.ShowEnergyStat10Min = tonumber(0)
l_t_push_service_config.ShowEnergyStatHour = tonumber(0)
l_t_push_service_config.ShowEnergyStat24h = tonumber(0)
l_t_push_service_config.ShowEnergyStatWeek = tonumber(0)
l_t_push_service_config.ShowEnergyStatMonth = tonumber(0)
l_t_push_service_config.ShowEnergyStatYear = tonumber(0)
if ( tostring(box.post.currentView) == "10") then
l_t_push_service_config.ShowEnergyStat10Min = tonumber(1)
elseif ( tostring(box.post.currentView) == "hour") then
l_t_push_service_config.ShowEnergyStatHour = tonumber(1)
elseif ( tostring(box.post.currentView) == "24h") then
l_t_push_service_config.ShowEnergyStat24h = tonumber(1)
elseif ( tostring(box.post.currentView) == "week") then
l_t_push_service_config.ShowEnergyStatWeek = tonumber(1)
elseif ( tostring(box.post.currentView) == "month") then
l_t_push_service_config.ShowEnergyStatMonth = tonumber(1)
elseif ( tostring(box.post.currentView) == "year" ) then
l_t_push_service_config.ShowEnergyStatYear = tonumber(1)
end
aha.DoSendPushMail( tonumber(l_device.ID), l_t_push_service_config)
l_request_result = "1"
elseif ((l_device ~= nil) and ( tostring(box.post.command) == "SetTimerCalendar")) then
local t_timer_state = aha.GetSwitchTimer( tonumber(l_device.ID))
if ( t_timer_state ~= nil) then
local l_set_timer = {}
l_set_timer.enabled = 1
l_set_timer.Calname = box.post.Calname
if ( tostring(box.post.ResetTimer) == "calendar") then
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(t_timer_state.Calname))
local sz_to_find = tostring(box.post.id)..[[;]]
local l_old_devices, n_how_many = string.gsub( l_devices, sz_to_find, "")
if ( tostring(l_device.GroupHash) ~= "0") and ( l_old_devices ~= [[]] ) then
local l_t_group_member_list = ha_func_lib.get_group_member_IDs_of( aha.GetDeviceList(), l_device.GroupHash)
if (( l_t_group_member_list ~= nil) and ( #l_t_group_member_list > 1 )) then
l_new_devices = ha_func_lib.update_oncal_by_group_member( l_device.ID, l_t_group_member_list, l_newer_devices, false)
end
end
if ( l_old_devices == "") then
cmtable.add_var( t_saveset, [[oncal:settings/]]..l_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( t_saveset, [[oncal:settings/]]..l_node..[[/deviceid]], l_old_devices)
end
aha.SetSwitchTypeTimer( tonumber(box.post.id), "calendar", l_set_timer)
local l_sz_new_devices = tostring(l_device.ID)..[[;]]
cmtable.add_var( t_saveset, [[oncal:settings/]]..tostring(box.post.OncalNode)..[[/deviceid]], l_sz_new_devices)
cmtable.add_var( t_saveset, [[oncal:command/do_sync]], [[1]])
l_request_result = "1"
end
elseif ((l_device ~= nil) and ( tostring(box.post.command) == "ResetTimerCalendar")) then
local t_timer_state = aha.GetSwitchTimer( tonumber(l_device.ID))
if ( t_timer_state ~= nil) then
local l_ret_timer = {}
local l_b_timer_exist = false
local l_reset_timer = tostring(box.post.ResetTimer)
l_b_timer_exit, l_ret_timer = get_switch_timer_values( l_reset_timer, t_timer_state)
if ( l_reset_timer == "") then
l_reset_timer = "calendar"
end
if (( l_ret_timer ~= nil) and (#l_ret_timer ~= 0)) then
l_ret_timer.enabled = 1
if ( box.post.ResetTimer == "calendar") then
l_ret_timer.Calname = t_timer_state.Calname
end
else
l_ret_timer.enabled = 0
end
aha.SetSwitchTypeTimer( tonumber(l_device.ID), l_reset_timer, l_ret_timer)
cmtable.add_var( t_saveset, [[oncal:command/]]..tostring(box.post.OncalNode), [[delete]])
cmtable.add_var( t_saveset, [[oncal:command/do_sync]], [[1]])
l_request_result = "1"
end
elseif ((l_device ~= nil) and ( tostring(box.post.command) == "ResetEnergyDatas")) then
l_request_result = "0"
local l_retcode = aha.ResetSwitchEnergyStat( tonumber(l_device.ID))
if ( l_retcode ~= nil) then
l_request_result = tostring( l_retcode)
end
l_request_result = l_request_result
else
l_request_result = "0"
end
else
if ( tostring(box.post.command) == "CreateNewGroup") then
if ( not( ha_func_lib.group_name_always_exists( tostring( box.post.group_name)))) then
for i=1, tonumber( box.post.selected_devices) do
local l_selected_dev = box.post["group_device_"..i]
l_selected_dev_2, n_count =string.gsub( l_selected_dev, [["]], [[ ]])
aha.EditDeviceGroup( tonumber( l_selected_dev_2), tostring( box.post.group_name))
end
box.out( [["GroupName" : "]]..tostring( box.post.group_name)..[[" ,]] )
l_request_result = "1"
else
l_request_result = "0"
box.out( [["Error_Code" : "1" ,]] )
end
else
l_request_result = "0"
box.out( [["Error_Code : "-1" ,]] )
end
end
if (( l_request_result == "1") and
( ( tostring(box.post.command) == "SetTimerCalendar") or
( tostring(box.post.command) == "ResetTimerCalendar"))) then
local l_errcode, l_errmsg = box.set_config( t_saveset)
if l_errcode ~= 0 then
l_request_result = "0"
end
end
else
if ( tostring(box.get.command) == "AllOutletStates") then
local l_device_list = aha.GetDeviceList()
if ((l_device_list ~= nil) and ( tonumber(#l_device_list) > 0)) then
local l_count = 0
for i=1, #l_device_list do
box.out( [["DeviceID_]]..tostring(i)..[[" : "]]..tostring( l_device_list[i].ID)..[[" ,]] )
box.out( [["DeviceConnectState_]]..tostring(i)..[[" : "]]..tostring( l_device_list[i].Valid)..[[" ,]] )
if ( ha_func_lib.is_outlet( tonumber(l_device_list[i].FunctionBitMask))) then
local l_switch = ha_func_lib.get_switch(l_device_list[i].ID)
box.out( [["DeviceSwitchState_]]..tostring(i)..[[" : "]]..tostring( l_switch.SwitchOn)..[[" ,]] )
box.out( [["DeviceSwitchLock_]]..tostring(i)..[[" : "]]..tostring( l_switch.SwitchLock)..[[" ,]] )
else
box.out( [["DeviceSwitchState_]]..tostring(i)..[[" : "" ,]] )
box.out( [["DeviceSwitchLock_]]..tostring(i)..[[" : "" ,]] )
end
if ( ha_func_lib.can_temperature( tonumber(l_device_list[i].FunctionBitMask))) then
local l_temperature = aha.GetTemperature( tonumber(l_device_list[i].ID))
if(l_temperature.Celsius == -9999) then
box.out( [["DeviceTemp_]]..tostring(i)..[[" : "" ,]] )
else
box.out( [["DeviceTemp_]]..tostring(i)..[[" : "]]..tostring( l_temperature.Celsius)..[[" ,]] )
end
else
box.out( [["DeviceTemp_]]..tostring(i)..[[" : "" ,]] )
end
if (( ha_func_lib.is_outlet( tonumber(l_device_list[i].FunctionBitMask))) or
( ha_func_lib.can_temperature( tonumber(l_device_list[i].FunctionBitMask)))) then
l_count = l_count + 1
end
end
box.out( [[ "Outlet_count" : "]]..tostring( l_count)..[[" ,]] )
l_request_result = "1"
else
box.out( [[ "Outlet_count" : "0" ,]] )
l_request_result = "0"
end
elseif ( tostring(box.get.command) == "GetGroupId") then
local l_new_group_id = ha_func_lib.get_group_id_by_name( tostring( box.get.group_name))
if ( l_new_group_id == tonumber(0) ) then
l_request_result = "0"
box.out( [["Error_Code" : "2" ,]] )
else
l_request_result = "1"
box.out( [["GroupID" : "]]..tostring(l_new_group_id)..[[" ,]] )
box.out( [["GroupHash" : "]]..tostring(l_new_group_hash)..[[" ,]] )
end
else
local device_ID = box.get.id
local tabType = box.get.tabType or ""
local device_connect = "0"
if ( ha_func_lib.is_valid_uleid( device_ID) == true) then
l_device = aha.GetDevice( tonumber(device_ID))
if ( l_device ~= nil) then
device_connect = l_device.Valid
l_switch_state = aha.GetSwitch( tonumber(device_ID))
if ((l_switch_state ~= nil) and ( tostring(box.get.command) == "SwitchOnOff")) then
l_return_value = l_switch_state.SwitchOn
box.out( [["ValueToSet" : "]]..box.get.value_to_set..[[" ,]] )
box.out( [["Value" : "]]..l_switch_state.SwitchOn..[[" ,]] )
l_request_result = "1"
elseif ( tostring(box.get.command) == "CheckRegistering") then
if ( ha_func_lib.is_repeater_only( l_device.FunctionBitMask) ) then
box.out( [["repeaterOnly" : "1" ,]] )
else
box.out( [["repeaterOnly" : "0" ,]] )
end
l_request_result = "1"
elseif ((l_switch_state ~= nil) and ( tostring(box.get.command) == "OutletStates")) then
box.out( [["DeviceSwitchState" : "]]..tostring( l_switch_state.SwitchOn)..[[" ,]] )
l_request_result = "1"
elseif ( tostring(box.get.command) == "EnergyStats_10") then
tabType = [[10]]
local l_energy_stats_watt = aha.GetSwitchEnergyStat10MinValues( tonumber(device_ID))
local l_energy_stats_volt = aha.GetSwitchVoltageStat10MinValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats_watt, "EnStats_watt_value_", true)
write_stats_of( l_energy_stats_volt, "EnStats_volt_value_", false)
local l_switchState = 0
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
local l_multimeter_state = aha.GetMultimeter( tonumber(device_ID))
if ( l_multimeter_state ~= nil) then
box.out( [["MM_Value_Power" : "]]..l_multimeter_state.Power..[[" ,]] )
box.out( [["MM_Value_Volt" : "]]..l_multimeter_state.Voltage..[[" ,]] )
box.out( [["MM_Value_Amp" : "]]..l_multimeter_state.Current..[[" ,]] )
else
box.out( [["MM_Value_Power" : "0" ,]] )
box.out( [["MM_Value_Volt" : "0" ,]] )
box.out( [["MM_Value_Amp" : "0" ,]] )
end
local l_average = aha.GetEnergyAverage( tonumber( device_ID))
if ( l_average ~= nil) then
box.out( [["sum_Day" : "]]..l_average.DayAverage..[[" ,]] )
box.out( [["sum_Month" : "]]..l_average.MonthAverage..[[" ,]] )
box.out( [["sum_Year" : "]]..l_average.YearAverage..[[" ,]] )
else
box.out( [["sum_Say" : "0" ,]] )
box.out( [["sum_Month" : "0" ,]] )
box.out( [["sum_Year" : "0" ,]] )
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "EnergyStats_hour") then
tabType = [[hour]]
local l_energy_stats_watt = aha.GetSwitchEnergyStatHourValues( tonumber(device_ID))
local l_energy_stats_volt = aha.GetSwitchVoltageStatHourValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats_watt, "EnStats_watt_value_", true)
write_stats_of( l_energy_stats_volt, "EnStats_volt_value_", false)
local l_switchState = 0
local l_multimeter_state = aha.GetMultimeter( tonumber(device_ID))
if ( l_multimeter_state ~= nil) then
box.out( [["MM_Value_Power" : "]]..l_multimeter_state.Power..[[" ,]] )
box.out( [["MM_Value_Volt" : "]]..l_multimeter_state.Voltage..[[" ,]] )
box.out( [["MM_Value_Amp" : "]]..l_multimeter_state.Current..[[" ,]] )
else
box.out( [["MM_Value_Power" : "0" ,]] )
box.out( [["MM_Value_Volt" : "0" ,]] )
box.out( [["MM_Value_Amp" : "0" ,]] )
end
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "EnergyStats_24h") then
tabType = [[24h]]
local l_energy_stats = aha.GetSwitchEnergyStat24hValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats, "EnStats_watt_value_", true)
local l_switchState = 0
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
local l_average = aha.GetEnergyAverage( tonumber( device_ID))
if ( l_average ~= nil) then
box.out( [["sum_Day" : "]]..l_average.DayAverage..[[" ,]] )
box.out( [["sum_Month" : "]]..l_average.MonthAverage..[[" ,]] )
box.out( [["sum_Year" : "]]..l_average.YearAverage..[[" ,]] )
else
box.out( [["sum_Say" : "0" ,]] )
box.out( [["sum_Month" : "0" ,]] )
box.out( [["sum_Year" : "0" ,]] )
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "EnergyStats_week") then
tabType = [[week]]
local l_energy_stats = aha.GetSwitchEnergyStatWeekValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats, "EnStats_watt_value_", true)
local l_switchState = 0
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
local l_average = aha.GetEnergyAverage( tonumber( device_ID))
if ( l_average ~= nil) then
box.out( [["sum_Day" : "]]..l_average.DayAverage..[[" ,]] )
box.out( [["sum_Month" : "]]..l_average.MonthAverage..[[" ,]] )
box.out( [["sum_Year" : "]]..l_average.YearAverage..[[" ,]] )
else
box.out( [["sum_Say" : "0" ,]] )
box.out( [["sum_Month" : "0" ,]] )
box.out( [["sum_Year" : "0" ,]] )
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "EnergyStats_month") then
tabType = [[month]]
local l_energy_stats = aha.GetSwitchEnergyStatMonthValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats, "EnStats_watt_value_", true)
local l_switchState = 0
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
local l_average = aha.GetEnergyAverage( tonumber( device_ID))
if ( l_average ~= nil) then
box.out( [["sum_Day" : "]]..l_average.DayAverage..[[" ,]] )
box.out( [["sum_Month" : "]]..l_average.MonthAverage..[[" ,]] )
box.out( [["sum_Year" : "]]..l_average.YearAverage..[[" ,]] )
else
box.out( [["sum_Say" : "0" ,]] )
box.out( [["sum_Month" : "0" ,]] )
box.out( [["sum_Year" : "0" ,]] )
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "EnergyStats_year") then
tabType = [[year]]
local l_energy_stats = aha.GetSwitchEnergyStatYearValues( tonumber(device_ID))
l_request_result = write_stats_of( l_energy_stats, "EnStats_watt_value_", true)
local l_switchState = 0
if ( l_switch_state ~= nil) then
l_switchState = l_switch_state.SwitchOn
end
local l_average = aha.GetEnergyAverage( tonumber( device_ID))
if ( l_average ~= nil) then
box.out( [["sum_Day" : "]]..l_average.DayAverage..[[" ,]] )
box.out( [["sum_Month" : "]]..l_average.MonthAverage..[[" ,]] )
box.out( [["sum_Year" : "]]..l_average.YearAverage..[[" ,]] )
else
box.out( [["sum_Say" : "0" ,]] )
box.out( [["sum_Month" : "0" ,]] )
box.out( [["sum_Year" : "0" ,]] )
end
box.out( [["DeviceSwitchState" : "]]..tostring( l_switchState)..[[" ,]] )
elseif ( tostring(box.get.command) == "MultiMeterState") then
local l_multimeter_state = aha.GetMultimeter( tonumber(device_ID))
if ( l_multimeter_state ~= nil) then
box.out( [["MM_Value_Power" : "]]..l_multimeter_state.Power..[[" ,]] )
box.out( [["MM_Value_Volt" : "]]..l_multimeter_state.Voltage..[[" ,]] )
box.out( [["MM_Value_Amp" : "]]..l_multimeter_state.Current..[[" ,]] )
l_deviceinfo = aha.GetDevice( tonumber(l_device.ID))
box.out( [["Value_Valid" : "]]..l_deviceinfo.Valid..[[" ,]] )
l_request_result = "1"
end
elseif ( tostring(box.get.command) == "CalendarState") then
local l_timer_value = aha.GetSwitchTimer( tonumber(device_ID))
if ( t_timer_values ~= nil) then
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(t_timer_values.Calname))
if ( l_b_exist == true) then
local l_last_state = box.query( [[oncal:settings/]]..tostring( l_node)..[[/laststatus]])
box.out( [["LastStatus" : "]]..tostring(l_last_state)..[[" ,]] )
if ( tostring(l_last_state) == "0") then
l_last_connect = box.query( [[oncal:settings/]]..tostring( l_node)..[[/lastconnect]])
l_timer_values = get_switch_timer_values_of( "calendar", g_device_timer_state)
if ((l_timer_values ~= nil) and (l_timer_values[1] ~= nil) and ( l_timer_values[1].time ~= nil) and (l_timer_values[1].time ~= 0)) then
local l_date_values = aha.GetGlobTimeDate( l_timer_values[1].time)
local l_sz_date = ha_func_lib.get_leading_zero( l_date_values.Day)..[[.]]..ha_func_lib.get_leading_zero( l_date_values.Month)..[[.]]..get_leading_zero( l_date_values.Year)
local l_sz_time = ha_func_lib.get_leading_zero( l_date_values.Hour)..[[:]]..ha_func_lib.get_leading_zero( l_date_values.Minute)
l_sz_last_switch = tostring( l_sz_date..[[ ]]..l_sz_time)
box.out( [["LastSwitch" : "]]..l_sz_last_switch..[[" ,]] )
box.out( [["LastSync" : "]]..ha_func_lib.convert_to_german( l_sz_last_switch)..[[" ,]] )
end
l_request_result = "1"
end
end
end
else
l_request_result = "0"
end
else
l_request_result = "0"
end
else
l_request_result = "0"
end
box.out( [["CurrentDateInSec" : "]]..tostring(os.time())..[[" ,]] )
box.out( [["DeviceID" : "]]..tostring(device_ID)..[[" ,]] )
box.out( [["tabType" : "]]..tostring(tabType)..[[" ,]] )
box.out( [["DeviceConnectState" : "]]..tostring( device_connect)..[[" ,]] )
end
end
box.out( [["RequestResult" : "]]..tostring( l_request_result)..[["]] )
else
box.out( [["RequestResult" : "0"]] )
end
box.out("\n}\n")
?>
