<?lua
g_page_type = "all"
g_page_title = box.tohtml( [[{?477:487?}]])
g_page_help = "hilfe_home_auto_timer_view.html"
g_page_needs_js=true
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("elem")
require("menu")
require("newval")
require("cmtable")
require("general")
require("math")
require("timer")
require("string_op")
require("ha_func_lib")
require("libaha")
require("http")
g_sz_text_userdefined = [[{?477:440?}]]
g_sz_text_timerUse_default = [[]]
g_t_rythmisch_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], [[{?477:844?}]]},
{ [[2]], [[{?477:302?}]]},
{ [[5]], [[{?477:278?}]]},
{ [[10]], [[{?477:113?}]]},
{ [[15]], [[{?477:590?}]]},
{ [[30]], [[{?477:415?}]]},
{ [[45]], [[{?477:958?}]]},
{ [[60]], [[{?477:611?}]]},
{[[120]], [[{?477:587?}]]},
{[[180]], [[{?477:420?}]]},
{[[300]], [[{?477:155?}]]}}
g_t_single_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], [[{?477:251?}]]},
{ [[5]], [[{?477:642?}]]},
{ [[15]], [[{?477:536?}]]},
{ [[30]], [[{?477:5650?}]]},
{ [[60]], [[{?477:4040?}]]},
{[[120]], [[{?477:588?}]]},
{[[180]], [[{?477:241?}]]},
{[[300]], [[{?477:478?}]]},
{[[600]], [[{?477:609?}]]},
{[[1440]], [[{?477:766?}]]},
{[[-1]], [[{?477:483?}]]}}
g_t_zufall_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], [[{?477:710?}]]},
{ [[2]], [[{?477:914?}]]},
{ [[5]], [[{?477:690?}]]},
{[[10]], [[{?477:699?}]]},
{[[15]], [[{?477:99?}]]},
{[[20]], [[{?477:682?}]]},
{[[30]], [[{?477:803?}]]},
{[[40]], [[{?477:862?}]]},
{[[50]], [[{?477:782?}]]},
{[[60]], [[{?477:49?}]]}}
-- Astro-NextGeneration
g_t_sunrise_switch_duration = { { [[u#0]], g_sz_text_userdefined},
{ [[r#5]], [[{?477:583?}]]},
{ [[r#10]], [[{?477:231?}]]},
{ [[r#15]], [[{?477:397?}]]},
{ [[r#30]], [[{?477:941?}]]},
{ [[r#45]], [[{?477:55?}]]},
{ [[r#60]], [[{?477:112?}]]},
{ [[r#90]], [[{?477:759?}]]},
{[[r#120]], [[{?477:257?}]]},
{[[r#180]], [[{?477:991?}]]},
{[[r#240]], [[{?477:677?}]]},
{[[r#300]], [[{?477:66?}]]},
{[[d#480]], [[{?477:815?}]]},
{[[d#600]], [[{?477:745?}]]},
{[[d#720]], [[{?477:8802?}]]},
{ [[r#4095]], [[{?477:337?}]]}}
g_t_sunset_switch_duration = { { [[u#0]], g_sz_text_userdefined},
{ [[r#5]], [[{?477:174?}]]},
{ [[r#10]], [[{?477:938?}]]},
{ [[r#15]], [[{?477:562?}]]},
{ [[r#30]], [[{?477:217?}]]},
{ [[r#45]], [[{?477:537?}]]},
{ [[r#60]], [[{?477:925?}]]},
{ [[r#90]], [[{?477:617?}]]},
{ [[r#120]], [[{?477:680?}]]},
{ [[r#180]], [[{?477:361?}]]},
{ [[r#240]], [[{?477:168?}]]},
{ [[r#300]], [[{?477:790?}]]},
{[[d#1260]], [[{?477:944?}]]},
{[[d#1320]], [[{?477:6527?}]]},
{[[d#1380]], [[{?477:6894?}]]},
{ [[d#0]], [[{?477:773?}]]},
{ [[d#60]], [[{?477:264?}]]},
{[[r#4095]], [[{?477:331?}]]}}
g_t_sunrise_offset = { {[[-120]], [[{?477:967?}]]},
{ [[-60]], [[{?477:455?}]]},
{ [[-45]], [[{?477:783?}]]},
{ [[-30]], [[{?477:336?}]]},
{ [[-15]], [[{?477:952?}]]},
{ [[0]], [[{?477:5690?}]]},
{ [[15]], [[{?477:1640?}]]},
{ [[30]], [[{?477:604?}]]},
{ [[45]], [[{?477:551?}]]},
{ [[60]], [[{?477:279?}]]},
{ [[120]], [[{?477:515?}]]}
}
g_t_sunset_offset = { {[[-120]], [[{?477:776?}]]},
{ [[-60]], [[{?477:2805?}]]},
{ [[-45]], [[{?477:115?}]]},
{ [[-30]], [[{?477:977?}]]},
{ [[-15]], [[{?477:263?}]]},
{ [[0]], [[{?477:8909?}]]},
{ [[15]], [[{?477:384?}]]},
{ [[30]], [[{?477:828?}]]},
{ [[45]], [[{?477:206?}]]},
{ [[60]], [[{?477:3878?}]]},
{ [[120]], [[{?477:794?}]]}
}
g_t_suncalender_latitude = { { [[1]], [[{?477:867?}]] },
{ [[-1]], [[{?477:424?}]] }}
g_t_suncalender_longitude = { { [[1]], [[{?477:633?}]] },
{ [[-1]], [[{?477:406?}]] }}
g_current_device = nil
g_device_identifier = nil
g_device_id = nil
g_device_name = nil
g_device_model = nil
g_device_sub_model = nil
g_device_manufacturer = nil
g_device_valid = nil
g_device_update = nil
g_device_func_mask = nil
g_device_group_hash = nil
g_device_countdown_OnOff = nil
g_last_calender_state = 0
g_hastime = (box.query("box:status/localtime") ~= "")
g_is_default = false
g_device_timer_state = {}
g_timer_id = box.tohtml( [[uiTimerWeekly]])
g_back_to_page = http.get_back_to_page( "/net/home_auto_overview.lua" )
<?include "net/home_auto_x_view_tabs.lua" ?>
function init_page_vars( device)
if ( ha_func_lib.is_valid_uleid( device) == false) then
return false
end
g_current_device = aha.GetDevice(tonumber(device))
if ( g_current_device == nil) then
return false
end
g_device_id = g_current_device.ID
g_device_identifier = g_current_device.Identifyer
g_device_name = g_current_device.Name
g_device_model = g_current_device.Model
g_device_sub_model = g_current_device.SubModel
g_device_manufacturer = g_current_device.Manufacturer
g_device_valid = g_current_device.Valid
g_device_update = g_current_device.UpdatePresent
g_device_func_mask = g_current_device.FunctionBitMask
g_device_group_hash = g_current_device.GroupHash
g_hastime = (box.query("box:status/localtime") ~= "")
if ( ha_func_lib.is_outlet( g_device_func_mask)) then
g_device_timer_state = aha.GetSwitchTimer( tonumber(device))
end
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
function is_valid_timer_item( timer_item)
local l_ret = true
if (( timer_item.action == nil) or
( timer_item.time == nil) or
( timer_item.start == nil) or
( timer_item.loop == nil)) then
l_ret = false
end
return l_ret
end
function get_coord_degree_of( sz_coord_kind, t_coord_value)
local l_ret_code = "000"
if ( t_coord_value ~= nil) then
local n_coord_degree = 0
if ( "latitude" == sz_coord_kind ) then
n_coord_degree = math.abs(t_coord_value.Latitude)
else
n_coord_degree = math.abs(t_coord_value.Longitude)
end
l_ret_code = math.floor(n_coord_degree)
end
return l_ret_code
end
function get_coord_degree_min_of( sz_coord_kind, t_coord_value)
local l_ret_code = "00"
if ( t_coord_value ~= nil) then
if ( "latitude" == sz_coord_kind ) then
n_coord_degree = math.abs(t_coord_value.Latitude)
else
n_coord_degree = math.abs(t_coord_value.Longitude)
end
n_coord_degree = n_coord_degree*3600
n_degree = math.floor(n_coord_degree/3600)
n_degree_min_dec = (n_coord_degree/60) - (n_degree*60)
l_ret_code = math.floor( n_degree_min_dec)
end
return l_ret_code
end
function get_coord_degree_sec_of( sz_coord_kind, t_coord_value)
local l_ret_code = "00"
if ( t_coord_value ~= nil) then
if ( "latitude" == sz_coord_kind ) then
n_coord_degree = math.abs(t_coord_value.Latitude)
else
n_coord_degree = math.abs(t_coord_value.Longitude)
end
n_coord_degree = n_coord_degree*3600
n_degree = math.floor(n_coord_degree/3600)
n_degree_min_dec = (n_coord_degree/60) - (n_degree*60)
n_degree_min = math.floor( n_degree_min_dec)
n_degree_sec = math.floor(( n_degree_min_dec - n_degree_min)*60*1000000)
l_ret_code = math.floor( n_degree_sec/1000000)
end
return l_ret_code
end
function get_coord_direction_of( sz_coord_kind, t_coord_value)
local l_ret_code = 1
if ( t_coord_value ~= nil) then
if ( "latitude" == sz_coord_kind ) then
n_coord_value = t_coord_value.Latitude
else
n_coord_value = t_coord_value.Longitude
end
if ( n_coord_value < 0 ) then
l_ret_code = -1
end
end
return l_ret_code
end
function get_decimal_coord( n_degree, n_degree_min, n_degree_sec, nDirection)
return tonumber( n_degree + ((n_degree_min*60) + n_degree_sec)/3600)*tonumber(nDirection)
end
function get_cal_state_text( n_cal_state)
local sz_retcode = [[{?477:203?}]]..tostring(n_cal_state)..[[{?477:800?}]]
if ( tostring(n_cal_state) == "1") then
sz_retcode = [[{?477:166?}]]
elseif ( tostring(n_cal_state) == "2") then
sz_retcode = [[{?477:378?}]]
elseif ( tostring(n_cal_state) == "11") then
sz_retcode = [[{?477:32?}]]
elseif ( tostring(n_cal_state) == "10") then
sz_retcode = [[{?477:694?}]]
elseif ((tostring(n_cal_state) == "8") or ( tostring(n_cal_state) == "12")) then
sz_retcode = [[{?477:239?}]]
elseif ((tostring(n_cal_state) == "16") or ( tostring(n_cal_state) == "17") or ( tostring(n_cal_state) == "18") or ( tostring(n_cal_state) == "19") or
(tostring(n_cal_state) == "20") or ( tostring(n_cal_state) == "21") or ( tostring(n_cal_state) == "22")) then
sz_retcode = [[{?477:73?}]]..tostring(n_cal_state)..[[{?477:973?}]]
end
return sz_retcode
end
function get_timer_daily( n_start_time, n_end_time)
local l_ret_timer = {}
if ( (n_start_time ~= nil) and (n_end_time ~= nil)) then
l_ret_timer[1] = {}
l_ret_timer[1].action = 1
l_ret_timer[1].time = tonumber( n_start_time)
l_ret_timer[1].start = 0
l_ret_timer[1].loop = 1
l_ret_timer[2] = {}
l_ret_timer[2].action = 0
l_ret_timer[2].time = tonumber( n_end_time)
l_ret_timer[2].start = 0
l_ret_timer[2].loop = 0
elseif ( n_start_time ~= nil) then
l_ret_timer[1] = {}
l_ret_timer[1].action = 1
l_ret_timer[1].time = tonumber( n_start_time)
l_ret_timer[1].start = 0
l_ret_timer[1].loop = 0
elseif ( n_end_time ~= nil ) then
l_ret_timer[1] = {}
l_ret_timer[1].action = 0
l_ret_timer[1].time = tonumber( n_end_time)
l_ret_timer[1].start = 0
l_ret_timer[1].loop = 0
end
return l_ret_timer
end
function is_daily_switch_on( t_timer_setup)
local b_switch on = false
local t_timer = {}
t_timer.hh = "23"
t_timer.mm = "59"
if (( #t_timer_setup == 1) and (tonumber(t_timer_setup[1].action) == 0) ) then
return b_switch_on, t_timer
end
b_switch_on = true
t_timer.hh = tostring( math.floor(t_timer_setup[1].time/60))
t_timer.mm = tostring( math.mod( t_timer_setup[1].time, 60))
return b_switch_on, t_timer
end
function is_daily_switch_off( t_timer_setup)
local b_switch off = false
local t_timer = {}
t_timer.hh = "23"
t_timer.mm = "59"
if (( #t_timer_setup == 1) and (tonumber(t_timer_setup[1].action) == 1) ) then
return b_switch_off, t_timer
elseif ( #t_timer_setup == 1) then
b_switch_off = true
t_timer.hh = tostring( math.floor(t_timer_setup[1].time/60))
t_timer.mm = tostring( math.mod( t_timer_setup[1].time, 60))
return b_switch_off, t_timer
end
b_switch_off = true
t_timer.hh = tostring( math.floor(t_timer_setup[2].time/60))
t_timer.mm = tostring( math.mod( t_timer_setup[2].time, 60))
return b_switch_off, t_timer
end
function get_timer_weekly()
local l_ret_timer = {}
local l_day_time = 1440
for i = 1, 14, 1 do
l_ret_timer[i] = {}
l_ret_timer[i].start = 1
if ( math.mod( i, 2) == 1) then
l_ret_timer[i].action = 1
l_ret_timer[i].time = 450 + tonumber( (l_day_time *(math.floor(i/2))))
else
l_ret_timer[i].action = 0
l_ret_timer[i].time = 1110 + tonumber( (l_day_time *(math.floor((i-1)/2))))
end
if ( i == 14) then
l_ret_timer[i].loop = 0
else
l_ret_timer[i].loop = 1
end
end
return l_ret_timer
end
function get_timer_zufall( n_start_day, n_end_day, n_start_time, n_end_time, n_duration)
local l_ret_timer = {}
l_ret_timer[1] = {}
l_ret_timer[1].start = 4
l_ret_timer[1].action = 2
l_ret_timer[1].time = tonumber( n_start_day)
l_ret_timer[1].loop = 1
l_ret_timer[2] = {}
l_ret_timer[2].start = 0
l_ret_timer[2].action = 4
l_ret_timer[2].time = tonumber( n_start_time)
l_ret_timer[2].loop = 1
l_ret_timer[3] = {}
l_ret_timer[3].start = 0
l_ret_timer[3].action = 5
l_ret_timer[3].time = tonumber( n_end_time)
l_ret_timer[3].loop = 1
l_ret_timer[4] = {}
l_ret_timer[4].start = 4
l_ret_timer[4].action = 3
l_ret_timer[4].time = tonumber( n_end_day)
l_ret_timer[4].loop = 1
l_ret_timer[5] = {}
l_ret_timer[5].start = 6
l_ret_timer[5].action = 1
l_ret_timer[5].time = tonumber( n_duration)
l_ret_timer[5].loop = 1
l_ret_timer[6] = {}
l_ret_timer[6].start = 6
l_ret_timer[6].action = 0
l_ret_timer[6].time = 1
l_ret_timer[6].loop = 2
return l_ret_timer
end
function get_timer_rythmisch( n_off_at, n_on_at)
local l_ret_timer = {}
l_ret_timer[1] = {}
l_ret_timer[1].start = 5
l_ret_timer[1].action = 0
l_ret_timer[1].time = tonumber( n_off_at)
l_ret_timer[1].loop = 1
l_ret_timer[2] = {}
l_ret_timer[2].start = 5
l_ret_timer[2].action = 1
l_ret_timer[2].time = tonumber( n_on_at)
l_ret_timer[2].loop = 2
return l_ret_timer
end
function get_timer_single( n_start_day, n_end_day)
local l_ret_timer = {}
l_ret_timer[1] = {}
l_ret_timer[1].start = 4
l_ret_timer[1].action = 1
l_ret_timer[1].time = tonumber( n_start_day)
l_ret_timer[1].loop = 1
if ( n_end_day ~= 0) then
l_ret_timer[2] = {}
l_ret_timer[2].start = 4
l_ret_timer[2].action = 0
l_ret_timer[2].time = tonumber( n_end_day)
l_ret_timer[2].loop = 0
end
return l_ret_timer
end
function get_timer_sun_calender( sun_calender_timer)
local l_ret_timer = {}
local l_astro_timer = aha.HelperGetAstroTimer( tonumber(g_device_id), sun_calender_timer)
l_ret_timer = aha.HelperSetAstroTimer( tonumber(g_device_id), l_astro_timer)
return l_ret_timer
end
function get_switch_timer_values( sz_value_to_compare, t_timer_state)
local l_ret_timer = {}
local l_b_timer_exist = false
if ( t_timer_state and t_timer_state[sz_value_to_compare] ) then
if ( sz_value_to_compare == "calendar") then
l_ret_timer = t_timer_state[sz_value_to_compare]
l_b_timer_exist = true
elseif ( sz_value_to_compare=="countdown") then
l_ret_timer = t_timer_state[sz_value_to_compare]
l_b_timer_exist = true
else
if (t_timer_state[sz_value_to_compare][1]) then
l_ret_timer = t_timer_state[sz_value_to_compare]
l_b_timer_exist = true
end
end
end
return l_b_timer_exist, l_ret_timer
end
function get_switch_timer_values_of( sz_value_to_compare, t_timer_state)
local l_ret_timer = {}
local l_b_timer_exist = false
l_b_timer_exit, l_ret_timer = get_switch_timer_values( sz_value_to_compare, t_timer_state)
if ( l_b_timer_exit == false) then
local l_startday = nil
local l_endday = nil
local l_starttime = 0
local l_endtime = 0
local l_duration = 0
if ( sz_value_to_compare=="daily") then
l_starttime = 480
l_endtime = 1080
l_ret_timer = get_timer_daily( l_starttime, l_endtime)
elseif ( sz_value_to_compare=="weekly") then
l_ret_timer = get_timer_weekly()
elseif ( sz_value_to_compare=="zufall") then
l_startday = ha_func_lib.get_current_date() -- aktueller Tag + 1
local l_startday_min = aha.GetGlobTimeMinute( l_startday.year, l_startday.month, l_startday.day, 0, 0)
l_startday_min.Minute = l_startday_min.Minute+1440
local l_endday_min = aha.GetGlobTimeMinute( l_startday.year, l_startday.month, l_startday.day, 0, 0)
l_endday_min.Minute = l_endday_min.Minute+(7*1440)+1439
l_starttime = 480
l_endtime = 1080
l_duration = 60
l_ret_timer = get_timer_zufall( l_startday_min.Minute, l_endday_min.Minute, l_starttime, l_endtime, l_duration)
elseif ( sz_value_to_compare=="rythmisch") then
l_starttime = 0
l_endtime = 0
l_ret_timer = get_timer_rythmisch( l_starttime, l_endtime)
elseif ( sz_value_to_compare=="single") then
l_startday = ha_func_lib.get_current_date() -- aktueller Tag + 1
local l_startday_min = aha.GetGlobTimeMinute( l_startday.year, l_startday.month, l_startday.day, l_startday.hour, l_startday.min)
l_startday_min.Minute = l_startday_min.Minute + 1440 -- aktueller Tag + 1
l_endday_min = l_startday_min.Minute + 60
l_ret_timer = get_timer_single( l_startday_min.Minute, l_endday_min)
elseif ( sz_value_to_compare=="sun_calendar") then
l_ret_timer = get_timer_sun_calender( l_ret_timer)
elseif ( sz_value_to_compare=="calender") then
l_ret_timer = get_timer_calendar()
end
end
return l_ret_timer
end
function write_weekly_js_struct( t_timer_state)
local l_t_str_result = {}
for i= 1, 7 do
l_t_str_result[i] = "[]"
end
if ((t_timer_state ~= nil) and (#t_timer_state > 0)) then
local nIdx = 1
local entry_count = 0
local day_id = 0
local last_action = 0
local l_next_day_id = 0
repeat
if ( is_valid_timer_item( t_timer_state[nIdx]) ) then
entry_count, day_id, last_action = get_entries_per_day( nIdx, t_timer_state)
if (day_id > l_next_day_id) then
while ( day_id > l_next_day_id) do
if ( nIdx == 1) and ( t_timer_state[(#t_timer_state)].action == 1 ) then
if ( l_next_day_id == 0) then
l_t_str_result[7] = "[new Period( new Moment(6,0,0), new Moment(6,24,0))]"
else
l_t_str_result[l_next_day_id] = "[new Period( new Moment("..tostring((l_next_day_id-1))..",0,0), new Moment("..tostring((l_next_day_id-1))..",24,0))]"
end
else
if ( nIdx > 1) and ( l_next_day_id > 0) and ( t_timer_state[(nIdx-1)].action == 1 ) then
l_t_str_result[l_next_day_id] = "[new Period( new Moment("..tostring((l_next_day_id-1))..",0,0), new Moment("..tostring((l_next_day_id-1))..",24,0))]"
end
end
l_next_day_id = l_next_day_id + 1
end
end
if ( day_id == l_next_day_id ) then
if ( day_id == 0 ) then
l_t_str_result[7] = build_struct_per_day( nIdx, entry_count, t_timer_state, 6)
else
l_t_str_result[day_id] = build_struct_per_day( nIdx, entry_count, t_timer_state, (day_id-1))
end
end
l_next_day_id = l_next_day_id + 1
nIdx = nIdx + entry_count
end
until ( tonumber(nIdx) > tonumber(#t_timer_state))
if ( tonumber( l_next_day_id) < tonumber(#l_t_str_result)) and (t_timer_state[(#t_timer_state)].action == 1) then
local l_skip_count = 6 - l_next_day_id --{{} - day_id ]]
while ( l_skip_count >= 0) do
l_t_str_result[(l_next_day_id)] = "[new Period( new Moment("..tostring((l_next_day_id-1))..",0,0), new Moment("..tostring((l_next_day_id-1))..",24,0))]"
l_skip_count = l_skip_count - 1
l_next_day_id = l_next_day_id + 1
end
end
end
return l_t_str_result
end
function get_day_id( time_value)
local l_day_id = 0
if ( time_value ~= 0) then
if ( math.mod( time_value, 1440) > 0) then
l_day_id = math.floor(time_value/1440)
elseif ( math.mod( time_value, 1440) == 0) then
l_day_id = math.floor(time_value/1440) - 1
end
end
return l_day_id
end
function get_entries_per_day( start_index, t_timer_state)
local l_ret = 1
local l_b_go_on = true
local l_last_action = t_timer_state[start_index].action
local l_first_day_id = get_day_id( t_timer_state[start_index].time)
local l_idx = start_index + 1
repeat
if (l_idx <= #t_timer_state) then
local l_further_day_id = get_day_id( t_timer_state[l_idx].time)
if ( l_first_day_id == l_further_day_id) then
l_ret = l_ret + 1
else
l_b_go_on = false
end
l_idx = l_idx + 1
else
l_b_go_on = false
end
until (l_b_go_on == false)
l_last_action = t_timer_state[(start_index + l_ret - 1)].action
return l_ret, l_first_day_id, l_last_action
end
function build_struct_per_day( n_start_index, n_entry_count, t_timer_state, n_day_id)
local l_ret ="["
local l_period = [[]]
local i = n_start_index
repeat
local l_moment = [[]]
local b_not_complete = true
local l_time = t_timer_state[i].time
if ( l_time == 0) then
l_moment = [[new Moment(]]..tostring(n_day_id)..[[,0,0)]]
else
local l_day_id = get_day_id( l_time)
local l_day_rest = math.mod( l_time, 1440)
if ( l_day_rest == 0) then
l_moment = [[new Moment(]]..tostring(n_day_id)..[[,24,0)]]
else
l_moment = l_moment..[[new Moment(]]..tostring(n_day_id)..[[, ]]
l_moment = l_moment..tostring(math.floor( l_day_rest/60))..[[, ]]
l_moment = l_moment..tostring(math.mod( l_day_rest, 60))..[[) ]]
end
end
if ( i == n_start_index) and ( t_timer_state[i].action == 0 ) then
l_moment = [[new Period(new Moment( ]]..tostring(n_day_id)..[[, 0, 0),]]..l_moment..[[)]]
b_not_complete = false
end
if ( i == (n_start_index + (n_entry_count - 1))) and ( t_timer_state[i].action == 1) then
l_moment = [[new Period( ]]..l_moment..[[, new Moment( ]]..tostring(n_day_id)..[[, 24, 0))]]
b_not_complete = false
end
if ( b_not_complete == true) then
i = i + 1
l_time = t_timer_state[i].time
local l_day_id = get_day_id( l_time)
local l_day_rest = math.mod( l_time, 1440)
local hours = 24
local mins = 0
if ( l_day_rest ~= 0) then
hours = math.floor( l_day_rest/60)
mins = math.mod( l_day_rest, 60)
end
l_moment = [[new Period(]]..l_moment..[[, new Moment(]]..tostring(n_day_id)..[[, ]]
l_moment = l_moment..tostring(hours)..[[, ]]
l_moment = l_moment..tostring(mins)..[[)) ]]
end
if ( i < (n_start_index+(n_entry_count-1)) ) then
l_moment = l_moment..[[,]]
end
l_period = l_period..l_moment
i = i + 1
until ( i > (n_start_index + (n_entry_count-1)) )
l_ret = l_ret..l_period
l_ret = l_ret.."]"
return l_ret
end
function overwrite_timer_values_of( t_timer_org, t_timer_new)
local l_count = 0
l_count = table.getn(t_timer_org)
for i = l_count, 0, -1 do
table.remove( t_timer_org, i)
end
l_count = table.getn(t_timer_new)
for i = 1, l_count, 1 do
table.insert( t_timer_org, t_timer_new[i])
end
return t_timer_org
end
function read_weekly_timer_data()
local l_ret_timer = {}
local n_i = tonumber(#l_ret_timer)
for name, value in pairs(box.post) do
if string.sub(name, 1, 11)=="timer_item_" and string.sub(name,-2)~="_i" then
local l_time, l_action, l_daybits = string.match( tostring(value),"(%d*);(%d*);(%d*)")
for day=1, 7 do
local day_time = 1440
if math.floor(l_daybits / 2^(day-1)) % 2 == 1 then
n_i = n_i + 1
local day_multiplier = day
if ( day == 7) then
day_multiplier = 0
end
local day_time_value = day_multiplier*day_time
local hour_time_value = (tonumber(string.sub(l_time,1,2))*60)
local min_time_value = tonumber(string.sub(l_time,3,4))
local item = {}
item.time = day_time_value + hour_time_value + min_time_value
item.start = 1
item.action = tonumber(l_action)
item.loop = 1
l_ret_timer[n_i] = item
end
end
end
end
if ( #l_ret_timer > 0) then
table.sort( l_ret_timer, compare_t_item)
end
l_ret_timer[#l_ret_timer].loop = 0
return l_ret_timer
end
function compare_t_item( value_1, value_2)
if ( value_1.time < value_2.time) then
return true
end
return false
end
local l_device_id = nil
if ( next(box.get)) then
l_device_id = box.get.device
else
if ( next(box.post)) then
if (box.post.cancel) then
http.redirect( [[/net/home_auto_overview.lua]])
end
l_device_id = box.post.current_ule
end
end
if ( init_page_vars( l_device_id) == false) then
http.redirect( g_back_to_page )
end
local function val_prog()
if newval.checked("auto_switch_active") then
if newval.radio_check("switch_on_timer","weekly") then
end
if newval.radio_check("switch_on_timer","daily") then
if newval.checked("switch_on_action_daily") then
newval.num_range_integer("daily_from_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("daily_from_mm", 0, 59,"num_range_min")
newval.is_valid_time("daily_from_hh","daily_from_mm","is_valid_time_msg")
end
if newval.checked("switch_off_action_daily") then
newval.num_range_integer("daily_to_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("daily_to_mm", 0, 59,"num_range_min")
newval.is_valid_time("daily_to_hh","daily_to_mm","is_valid_time_msg")
end
if newval.checked("switch_on_action_daily") and newval.checked("switch_off_action_daily") then
newval.time_not_equal("daily_from_hh", "daily_from_mm", "daily_to_hh", "daily_to_mm", "daily_times_are_equal")
end
newval.least_one_checked("switch_on_action_daily","switch_off_action_daily","least_one_check_daily_msg")
end
if newval.radio_check("switch_on_timer","zufall") then
newval.is_num_in("zufall_from_date_day","is_num_in_day")
newval.is_num_in("zufall_from_date_month","is_num_in_month")
newval.is_num_in("zufall_from_date_year","is_num_in_year")
newval.is_num_in("zufall_to_date_day","is_num_in_day")
newval.is_num_in("zufall_to_date_month","is_num_in_month")
newval.is_num_in("zufall_to_date_year","is_num_in_year")
newval.is_valid_date("zufall_from_date_day","zufall_from_date_month","zufall_from_date_year","is_valid_date_msg")
newval.is_valid_date("zufall_to_date_day","zufall_to_date_month","zufall_to_date_year","is_valid_date_msg")
newval.num_range_integer("zufall_from_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("zufall_from_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("zufall_from_time_hh","zufall_from_time_mm","is_valid_time_msg")
newval.num_range_integer("zufall_to_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("zufall_to_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("zufall_to_time_hh","zufall_to_time_mm","is_valid_time_msg")
newval.value_unallowable("zufall_duration_switch",0,"select_not_set")
newval.time_not_equal("zufall_from_time_hh", "zufall_from_time_mm", "zufall_to_time_hh", "zufall_to_time_mm", true, "random_times_are_equal")
end
if newval.radio_check("switch_on_timer","countdown") then
if newval.radio_check("countdown_manuell_on","1") then
newval.num_range_integer("countdown_time_dd_on", 0, 999, "num_range_count_hour")
newval.num_range_integer("countdown_time_mm_on", 0, 59, "num_range_count_min")
newval.is_valid_countdown_time("countdown_time_dd_on","countdown_time_mm_on","is_valid_countdown_time_msg")
end
if newval.radio_check("countdown_manuell_on","0") then
newval.num_range_integer("countdown_time_dd_off", 0, 999,"num_range_count_hour")
newval.num_range_integer("countdown_time_mm_off", 0, 59,"num_range_count_min")
newval.is_valid_countdown_time("countdown_time_dd_off","countdown_time_mm_off","is_valid_countdown_time_msg")
end
end
if newval.radio_check("switch_on_timer","rythmisch") then
newval.value_unallowable("rythmisch_switch_state_on",0,"select_not_set")
newval.value_unallowable("rythmisch_switch_state_off",0,"select_not_set")
end
if newval.radio_check("switch_on_timer","single") then
newval.is_num_in("single_date_day","is_num_in_day")
newval.is_num_in("single_date_month","is_num_in_month")
newval.is_num_in("single_date_year","is_num_in_year")
newval.is_valid_date("single_date_day","single_date_month","single_date_year","is_valid_date_msg")
newval.num_range_integer("single_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("single_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("single_time_hh","single_time_mm","is_valid_time_msg")
newval.value_unallowable("single_switch_duration",0,"select_not_set")
end
if newval.radio_check("switch_on_timer","sun_calendar") then
newval.is_valid_float_degree("sun_latitude_degree",4,90,"lati_90")
newval.is_valid_float_degree("sun_longitude_degree",4,180,"longi_180")
if newval.checked("sun_checkbox_sunrise") then
newval.value_unallowable("sunrise_duration","u#0","select_not_astro")
end
if newval.checked("sun_checkbox_sunset") then
newval.value_unallowable("sunset_duration","u#0","select_not_astro")
end
newval.least_one_checked("sun_checkbox_sunrise","sun_checkbox_sunset","least_one_check_msg_2")
end
if newval.radio_check("switch_on_timer","calendar") then
newval.not_empty("calendar_google_calendarname","calender_empty")
end
end
if newval.checked("stand_by_active") then
newval.num_range_real("stand_by_power",2,1,200,"stand_by_power")
newval.num_range_integer("stand_by_duration",1,99,"stand_by_duration")
end
end
newval.msg.least_one_check_daily_msg= {
[newval.ret.wrong] = [[{?477:167?}]],
}
newval.msg.least_one_check_msg_2= {
[newval.ret.wrong] = [[{?477:63?}]],
}
newval.msg.daily_times_are_equal = {
[newval.ret.equalerr] = [[{?477:33?}]],
}
newval.msg.random_times_are_equal = {
[newval.ret.equalerr] = [[{?477:623?}]],
}
newval.msg.is_valid_time_msg= {
[newval.ret.wrong] = [[{?477:8874?}]],
}
newval.msg.is_valid_date_msg= {
[newval.ret.outofrange] = [[{?477:6092?}]],
[newval.ret.tooshort] = [[{?477:27?}]],
[newval.ret.wrong] = [[{?477:628?}]],
}
newval.msg.is_num_in_day= {
[newval.ret.notfound] = [[{?477:866?}]],
[newval.ret.empty] = [[{?477:193?}]],
[newval.ret.format] = [[{?477:530?}]],
}
newval.msg.is_num_in_month= {
[newval.ret.notfound] = [[{?477:210?}]],
[newval.ret.empty] = [[{?477:983?}]],
[newval.ret.format] = [[{?477:595?}]],
}
newval.msg.is_num_in_Year= {
[newval.ret.notfound] = [[{?477:232?}]],
[newval.ret.empty] = [[{?477:554?}]],
[newval.ret.format] = [[{?477:265?}]],
}
newval.msg.num_range_hour_24= {
[newval.ret.notfound] = [[{?477:3736?}]],
[newval.ret.empty] = [[{?477:466?}]],
[newval.ret.format] = [[{?477:1556?}]],
[newval.ret.outofrange] = [[{?477:532?}]]
}
newval.msg.num_range_min= {
[newval.ret.notfound] = [[{?477:769?}]],
[newval.ret.empty] = [[{?477:267?}]],
[newval.ret.format] = [[{?477:299?}]],
[newval.ret.outofrange] = [[{?477:578?}]]
}
newval.msg.num_range_count_hour= {
[newval.ret.notfound] = [[{?477:8335?}]],
[newval.ret.empty] = [[{?477:943?}]],
[newval.ret.format] = [[{?477:5211?}]],
[newval.ret.outofrange] = [[{?477:510?}]]
}
newval.msg.num_range_count_min= {
[newval.ret.notfound] = [[{?477:1674?}]],
[newval.ret.empty] = [[{?477:236?}]],
[newval.ret.format] = [[{?477:5666?}]],
[newval.ret.outofrange] = [[{?477:881?}]]
}
newval.msg.is_valid_countdown_time_msg= {
[newval.ret.wrong] = [[{?477:571?}]]
}
newval.msg.num_range_lati_degree= {
[newval.ret.notfound] = [[{?477:1107?}]],
[newval.ret.empty] = [[{?477:124?}]],
[newval.ret.format] = [[{?477:197?}]],
[newval.ret.outofrange] = [[{?477:2068?}]]
}
newval.msg.num_range_lati_min= {
[newval.ret.notfound] = [[{?477:781?}]],
[newval.ret.empty] = [[{?477:9504?}]],
[newval.ret.format] = [[{?477:502?}]],
[newval.ret.outofrange] = [[{?477:435?}]]
}
newval.msg.num_range_lati_sec= {
[newval.ret.notfound] = [[{?477:673?}]],
[newval.ret.empty] = [[{?477:443?}]],
[newval.ret.format] = [[{?477:910?}]],
[newval.ret.outofrange] = [[{?477:107?}]]
}
newval.msg.num_range_longi_degree= {
[newval.ret.notfound] = [[{?477:492?}]],
[newval.ret.empty] = [[{?477:981?}]],
[newval.ret.format] = [[{?477:44?}]],
[newval.ret.outofrange] = [[{?477:909?}]]
}
newval.msg.num_range_longi_min= {
[newval.ret.notfound] = [[{?477:238?}]],
[newval.ret.empty] = [[{?477:6304?}]],
[newval.ret.format] = [[{?477:656?}]],
[newval.ret.outofrange] = [[{?477:972?}]]
}
newval.msg.num_range_longi_sec= {
[newval.ret.notfound] = [[{?477:723?}]],
[newval.ret.empty] = [[{?477:564?}]],
[newval.ret.format] = [[{?477:687?}]],
[newval.ret.outofrange] = [[{?477:599?}]]
}
newval.msg.lati_90= {
[newval.ret.notfound] = [[{?477:813?}]],
[newval.ret.empty] = [[{?477:190?}]],
[newval.ret.wrong] = [[{?477:8032?}]],
[newval.ret.format] = [[{?477:2282?}]],
[newval.ret.outofrange] = [[{?477:3079?}]],
[newval.ret.leadchar] = [[{?477:137?}]]
}
newval.msg.longi_180= {
[newval.ret.notfound] = [[{?477:665?}]],
[newval.ret.empty] = [[{?477:91?}]],
[newval.ret.wrong] = [[{?477:627?}]],
[newval.ret.format] = [[{?477:374?}]],
[newval.ret.outofrange] = [[{?477:133?}]],
[newval.ret.leadchar] = [[{?477:756?}]]
}
newval.msg.select_not_set= {
[newval.ret.wrong] = [[{?477:603?}]]
}
newval.msg.select_not_astro= {
[newval.ret.wrong] = [[{?477:3273?}]]
}
newval.msg.calender_empty = {
[newval.ret.notfound] = [[{?477:5444?}]],
[newval.ret.empty] = [[{?477:135?}]]
}
newval.msg.select_not_standby_power= {
[newval.ret.wrong] = [[{?477:832?}]]
}
newval.msg.select_not_standby_duration= {
[newval.ret.wrong] = [[{?477:9413?}]]
}
newval.msg.stand_by_power= {
[newval.ret.notfound] = [[{?477:5885?}]],
[newval.ret.empty] = [[{?477:404?}]],
[newval.ret.format] = [[{?477:726?}]],
[newval.ret.toomuch] = [[{?477:6754?}]],
[newval.ret.outofrange] = [[{?477:355?}]]
}
newval.msg.stand_by_duration= {
[newval.ret.notfound] = [[{?477:408?}]],
[newval.ret.empty] = [[{?477:917?}]],
[newval.ret.format] = [[{?477:122?}]],
[newval.ret.outofrange] = [[{?477:893?}]]
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
local g_call_register = false;
local l_sz_node = ""
local l_sz_last_enabled_timer = ""
if ( box.post.apply) then
local l_val_result = g_val_result
if (( box.post.auto_switch_active) and (tonumber(box.post.auto_switch_active) == 1) and
( box.post.switch_on_timer == "sun_calendar" )) then
l_val_result = newval.ret.ok
end
if ( l_val_result == newval.ret.ok) then
local l_b_cal_was_enabled = false
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( g_device_timer_state)
l_sz_last_enabled_timer = l_sz_name
local l_b_timer, l_timer_daily = get_switch_timer_values( "daily", g_device_timer_state)
local l_b_timer, l_timer_weekly = get_switch_timer_values( "weekly", g_device_timer_state)
local l_b_timer, l_timer_zufall = get_switch_timer_values( "zufall", g_device_timer_state)
local l_b_timer, l_timer_countdown = get_switch_timer_values( "countdown", g_device_timer_state)
local l_b_timer, l_timer_rythmisch = get_switch_timer_values( "rythmisch", g_device_timer_state)
local l_b_timer, l_timer_single = get_switch_timer_values( "single", g_device_timer_state)
local l_b_timer, l_timer_sun_calender = get_switch_timer_values( "sun_calendar", g_device_timer_state)
local l_b_timer, l_timer_calendar = get_switch_timer_values( "calendar", g_device_timer_state)
l_b_cal_was_enabled = ( tostring(l_timer_calendar.enabled) == "1")
l_timer_daily.enabled = 0
l_timer_weekly.enabled = 0
l_timer_zufall.enabled = 0
l_timer_countdown.enabled = 0
l_timer_rythmisch.enabled = 0
l_timer_single.enabled = 0
l_timer_sun_calender.enabled = 0
l_timer_calendar.enabled = 0
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"daily", l_timer_daily)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"weekly", l_timer_weekly)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"zufall", l_timer_zufall)
aha.SetSwitchCountdownRule(tonumber(box.post.current_ule),0, 0)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"rythmisch", l_timer_rythmisch)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"single", l_timer_single)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"sun_calendar", l_timer_sun_calender)
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"calendar", l_timer_calendar)
if ( box.post.auto_switch_active and tonumber(box.post.auto_switch_active) == 1) then
local l_selected_timer_mode = box.post.switch_on_timer
if ( l_selected_timer_mode == "astro") then
l_selected_timer_mode = "sun_calendar"
-- Aus wertung ob moon or sun -Calender
end
if ( l_selected_timer_mode == "daily") then
local l_starttime = nil
local l_endtime = nil
if ( (box.post.switch_on_action_daily) and (box.post.switch_on_action_daily == "1")) then
l_starttime = tonumber( box.post.daily_from_hh)*60 + tonumber( box.post.daily_from_mm)
end
if ( (box.post.switch_off_action_daily) and (box.post.switch_off_action_daily == "1")) then
l_endtime = tonumber( box.post.daily_to_hh)*60 + tonumber( box.post.daily_to_mm)
end
local timer = get_timer_daily( l_starttime, l_endtime)
l_timer_daily = overwrite_timer_values_of( l_timer_daily, timer)
l_timer_daily.enabled = 1
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"daily", l_timer_daily)
end
if ( l_selected_timer_mode == "weekly") then
local l_timer_data = read_weekly_timer_data()
l_timer_weekly = overwrite_timer_values_of( l_timer_weekly, l_timer_data)
l_timer_weekly.enabled = 1
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"weekly", l_timer_weekly)
end
if ( l_selected_timer_mode == "zufall") then
local l_year = tonumber( box.post.zufall_from_date_year)
local l_month = tonumber( box.post.zufall_from_date_month)
local l_day = tonumber( box.post.zufall_from_date_day)
local l_startday = aha.GetGlobTimeMinute( l_year, l_month, l_day, tonumber( box.post.zufall_from_time_hh), tonumber( box.post.zufall_from_time_mm))
l_year = tonumber( box.post.zufall_to_date_year)
l_month = tonumber( box.post.zufall_to_date_month)
l_day = tonumber( box.post.zufall_to_date_day)
local l_endday = aha.GetGlobTimeMinute( l_year, l_month, l_day, tonumber( box.post.zufall_to_time_hh), tonumber( box.post.zufall_to_time_mm))
local l_starttime = tonumber( box.post.zufall_from_time_hh)*60 + tonumber( box.post.zufall_from_time_mm)
local l_endtime = tonumber( box.post.zufall_to_time_hh)*60 + tonumber( box.post.zufall_to_time_mm)
local l_duration = tonumber( box.post.zufall_duration_switch)
timer = get_timer_zufall( l_startday.Minute, l_endday.Minute, l_starttime, l_endtime, l_duration)
l_timer_zufall = overwrite_timer_values_of( l_timer_zufall, timer )
l_timer_zufall.enabled = 1
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"zufall", l_timer_zufall)
end
if ( l_selected_timer_mode == "countdown") then
local t_countdown_rule = aha.GetSwitchCountdownRule( tonumber(box.post.current_ule))
if ( tonumber(box.post.countdown_manuell_on) == 0) then
t_countdown_rule.OnOff = 0
t_countdown_rule.Seconds = ( tonumber( box.post.countdown_time_dd_off)*3600) + (tonumber( box.post.countdown_time_mm_off)*60)
else
t_countdown_rule.OnOff = 1
t_countdown_rule.Seconds = ( tonumber( box.post.countdown_time_dd_on)*3600) + (tonumber( box.post.countdown_time_mm_on)*60)
end
aha.SetSwitchCountdownRule(tonumber(box.post.current_ule),t_countdown_rule.OnOff, t_countdown_rule.Seconds)
l_timer_countdown.enabled = 1
end
if ( l_selected_timer_mode == "rythmisch") then
local l_switch_off_after = tonumber( box.post.rythmisch_switch_state_on)
local l_switch_on_after = tonumber( box.post.rythmisch_switch_state_off)
local timer = get_timer_rythmisch( l_switch_off_after, l_switch_on_after)
l_timer_rythmisch = overwrite_timer_values_of( l_timer_rythmisch, timer)
l_timer_rythmisch.enabled = 1
local l_virtual_member_id = ha_func_lib.get_virtual_id_by_hash( g_device_group_hash)
if ( l_virtual_member_id ~= nil) then
aha.SetSwitchOnOff( tonumber( l_virtual_member_id), 1)
else
aha.SetSwitchOnOff( tonumber( box.post.current_ule), 1)
end
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"rythmisch", l_timer_rythmisch)
end
if ( l_selected_timer_mode == "single") then
local l_year = tonumber( box.post.single_date_year)
local l_month = tonumber( box.post.single_date_month)
local l_day = tonumber( box.post.single_date_day)
local l_hour = tonumber( box.post.single_time_hh)
local l_minute = tonumber( box.post.single_time_mm)
local l_starttime = aha.GetGlobTimeMinute( l_year, l_month, l_day, l_hour, l_minute)
local l_endtime = 0
local timer = {}
if ( tonumber( box.post.single_switch_duration) ~= -1) then
l_endtime = l_starttime.Minute + tonumber( box.post.single_switch_duration)
timer = get_timer_single( l_starttime.Minute, l_endtime)
if ( tonumber(box.post.switch_on_action_single) == 0) then
timer[1].action = 0
timer[2].action = 1
end
else
timer = get_timer_single( l_starttime.Minute, l_endtime)
timer[1].loop = 0
if ( tonumber(box.post.switch_on_action_single) == 0) then
timer[1].action = 0
end
end
l_timer_single = overwrite_timer_values_of( l_timer_single, timer)
l_timer_single.enabled = 1
aha.SetSwitchTypeTimer(tonumber(box.post.current_ule),"single", l_timer_single)
end
if ( l_selected_timer_mode == "sun_calendar") then
l_t_Location = {}
local l_n_degree = tostring( box.post.sun_latitude_degree)
n_result = string.find(l_n_degree, '°')
if ( n_result ~= nil) then
l_n_degree = string.sub(l_n_degree, 1, (tonumber( n_result)-1))
end
local sz_degree, n_count = string.gsub(l_n_degree, [[,]], [[.]])
l_t_Location.Latitude = tonumber(sz_degree)
l_n_degree = tostring(box.post.sun_longitude_degree)
n_result = string.find(l_n_degree, '°')
if ( n_result ~= nil) then
l_n_degree = string.sub(l_n_degree, 1, (tonumber( n_result)-1))
end
sz_degree, n_count = string.gsub(l_n_degree, [[,]], [[.]])
l_t_Location.Longitude = tonumber(sz_degree)
local l_sunrise_time = 0
local l_sunset_time = 0
local l_astro_timer = aha.HelperGetAstroTimer( tonumber(box.post.current_ule), l_timer_sun_calender)
if ( (box.post.sun_checkbox_sunrise) and (box.post.sun_checkbox_sunrise == "1")) then
l_astro_timer.sunrisetime.offset_timetype = [[r]]
l_astro_timer.sunrisetime.offset_minutes = tonumber(box.post.sunrise_offset)
local l_sunrise_duration = box.post.sunrise_duration
local l_pos = string.find( l_sunrise_duration, [[#]])
local l_type = string.sub( l_sunrise_duration, 0, (l_pos-1))
local l_minutes = string.sub( l_sunrise_duration, (l_pos+1), #l_sunrise_duration)
l_astro_timer.sunrisetime.duration_timetype = tostring(l_type)
if (l_type == "d") or ( tonumber(l_minutes) == 4095) then
l_astro_timer.sunrisetime.duration_minutes = tonumber(l_minutes)
else
l_astro_timer.sunrisetime.duration_minutes = tonumber(l_minutes)+tonumber(l_astro_timer.sunrisetime.offset_minutes)
end
else
l_astro_timer.sunrisetime.offset_timetype = [[u]]
l_astro_timer.sunrisetime.offset_minutes = tonumber(0)
l_astro_timer.sunrisetime.duration_timetype = [[u]]
l_astro_timer.sunrisetime.duration_minutes = tonumber(0)
end
if ( (box.post.sun_checkbox_sunset) and (box.post.sun_checkbox_sunset == "1")) then
l_astro_timer.sunsettime.offset_timetype = [[r]]
l_astro_timer.sunsettime.offset_minutes = tonumber(box.post.sunset_offset)
local l_sunset_duration = box.post.sunset_duration
local l_pos = string.find( l_sunset_duration, [[#]])
local l_type = string.sub( l_sunset_duration, 0, (l_pos-1))
local l_minutes = string.sub( l_sunset_duration, (l_pos+1), #l_sunset_duration)
l_astro_timer.sunsettime.duration_timetype = tostring(l_type)
if (l_type == "d") or ( tonumber(l_minutes) == 4095) then
l_astro_timer.sunsettime.duration_minutes = tonumber(l_minutes)
else
l_astro_timer.sunsettime.duration_minutes = tonumber(l_minutes)+tonumber(l_astro_timer.sunsettime.offset_minutes)
end
else
l_astro_timer.sunsettime.offset_timetype = [[u]]
l_astro_timer.sunsettime.offset_minutes = tonumber(0)
l_astro_timer.sunsettime.duration_timetype = [[u]]
l_astro_timer.sunsettime.duration_minutes = tonumber(0)
end
l_timer_sun_calender = aha.HelperSetAstroTimer( tonumber(box.post.current_ule), l_astro_timer)
l_timer_sun_calender.enabled = 1
aha.SetBoxLocation( l_t_Location)
aha.SetSwitchTypeTimer( tonumber(box.post.current_ule), "sun_calendar", l_timer_sun_calender)
end
if ( l_selected_timer_mode == "calendar") then
saveset = {}
local l_b_cal_exist = false
local l_sz_devices = ""
l_timer_calendar.enabled = tonumber(1)
l_timer_calendar.Calname = tostring( box.post.calendar_google_calendarname)
l_b_cal_exist, l_sz_node, l_sz_devices = ha_func_lib.calendar_always_exist( tostring(box.post.calendar_google_calendarname))
if ( l_b_cal_exist == true) then
local l_current_oncal_state = box.query( [[oncal:settings/]]..l_sz_node..[[/laststatus]])
local l_new_devices = l_sz_devices
local sz_to_find = tostring(box.post.current_ule)..[[;]]
local nBegin = string.find( l_sz_devices, sz_to_find)
if ( tostring(nBegin) == tostring(nil) ) then
l_new_devices = l_sz_devices..tonumber(box.post.current_ule)..[[;]]
end
if ( tostring(g_device_group_hash) ~= "0") then
local l_t_group_member_list = ha_func_lib.get_group_member_IDs_of( aha.GetDeviceList(), g_device_group_hash)
if (( l_t_group_member_list ~= nil) and ( #l_t_group_member_list > 1 )) then
l_new_devices = ha_func_lib.update_oncal_by_group_member( box.post.current_ule, l_t_group_member_list, l_new_devices, true)
end
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(1))
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/deviceid]], l_new_devices)
if ( (l_sz_last_enabled_timer == "calendar") and (ha_func_lib.get_calendar_name( g_device_id) ~= l_timer_calendar.Calname) ) then
local l_b_exist, l_old_node, l_old_devices = ha_func_lib.calendar_always_exist( tostring(g_device_timer_state.Calname))
local l_new_old_devices, n_how_many = string.gsub( l_old_devices, sz_to_find, [[]])
if ( tostring(g_device_group_hash) ~= "0") and ( l_new_old_devices ~= [[]] ) then
local l_t_group_member_list = ha_func_lib.get_group_member_IDs_of( aha.GetDeviceList(), g_device_group_hash)
if (( l_t_group_member_list ~= nil) and ( #l_t_group_member_list > 1 )) then
l_new_old_devices = ha_func_lib.update_oncal_by_group_member( box.post.current_ule, l_t_group_member_list, l_new_old_devices, false)
end
end
if ( l_new_old_devices == [[]] ) then
cmtable.add_var( saveset, [[oncal:settings/]]..l_old_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_old_node..[[/deviceid]], l_new_old_devices)
end
aha.SetSwitchTypeTimer( tonumber(box.post.current_ule), "calendar", l_timer_calendar)
cmtable.add_var( saveset, [[oncal:command/do_sync]], [[1]])
else
g_call_register = true;
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(1))
cmtable.add_var( saveset, [[oncal:settings/]]..l_sz_node..[[/calname]], tostring(box.post.calendar_google_calendarname))
end
else
if ( l_b_cal_was_enabled ) then
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(g_device_timer_state.Calname))
local sz_to_find = tostring(box.post.current_ule)..[[;]]
local l_newer_devices, n_how_many = string.gsub( l_devices, sz_to_find, "")
if ( tostring(g_device_group_hash) ~= "0") and ( l_newer_devices ~= [[]] ) then
local l_t_group_member_list = ha_func_lib.get_group_member_IDs_of( aha.GetDeviceList(), g_device_group_hash)
if (( l_t_group_member_list ~= nil) and ( #l_t_group_member_list > 1 )) then
l_new_devices = ha_func_lib.update_oncal_by_group_member( box.post.current_ule, l_t_group_member_list, l_newer_devices, false)
end
end
if ( l_newer_devices == "") then
cmtable.add_var( saveset, [[oncal:settings/]]..l_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( saveset, [[oncal:settings/]]..l_node..[[/deviceid]], l_newer_devices)
cmtable.add_var( saveset, [[oncal:command/do_sync]], [[1]])
end
end
end
if ( box.post.stand_by_active and (tonumber(box.post.stand_by_active) == 1) ) then
-- local l_power = tonumber( box.post.stand_by_power)
local sz_power, n_count = string.gsub( tostring(box.post.stand_by_power), [[,]], [[.]])
local l_seconds = tonumber( box.post.stand_by_duration)*60
aha.SetSwitchStandbyOffRule( g_device_id, (tonumber(sz_power)*100), l_seconds)
else
aha.SetSwitchStandbyOffRule( g_device_id, tonumber(0), tonumber(0))
end
end
elseif ( box.post.reset_google_calender) then
local l_reset_cal_timer = {}
l_reset_cal_timer.enabled = tonumber(0)
l_reset_cal_timer.Calname = tostring( [[]] )
aha.SetSwitchTypeTimer( tonumber(box.post.current_ule), "calendar", l_reset_cal_timer)
aha.ResetSwitchCalTimer()
cmtable.add_var( saveset, [[oncal:command/do_sync]], [[reset]])
g_device_timer_state = aha.GetSwitchTimer( tonumber(box.post.current_ule))
end
if ( g_val_result == newval.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
if ( box.post.apply) then
if ( g_call_register) then
local l_param = [[?device=]]..tonumber(box.post.current_ule)
l_param = l_param..[[&cal_node=]]..tostring(l_sz_node)
l_param = l_param..[[&last_timer=]]..tostring(l_sz_last_enabled_timer)
local l_url = [[/net/home_auto_install_gcal.lua]]..tostring(l_param)
http.redirect( l_url)
else
http.redirect( [[/net/home_auto_overview.lua]])
end
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/kids.css"/> -->
<?lua
if config.TIMERCONTROL then
box.out([[
<link rel="stylesheet" type="text/css" href="/css/default/timer.css"/>
]])
end
?>
<style type="text/css">
.timesSettings_daily {
vertical-align: middle;
width: 25px;
margin: 0px 0px 0px 20px;
}
.mt5 {margin-top: 5px;}
.mt10 {margin-top: 10px;}
.mt20 {margin-top: 20px;}
.mr_20 {margin-right: 20px;}
.mr_100 {margin-right: 100px;}
.fl_r {float: right;}
.clr { clear: both;}
</style>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?477:258?}</p>
<hr>
<?lua
ha_func_lib.get_device_tab_head( g_device_id, false, false)
box.out( [[<hr>]])
if g_hastime then
box.out( [[<h4>{?477:737?}]]..tostring( g_device_name)..[["</h4>]])
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( g_device_timer_state)
if ( l_sz_name == "") then
l_sz_name = g_sz_text_timerUse_default
end
box.out( elem._checkbox( "auto_switch_active", "uiView_AutoSwitchActive", l_sz_value, l_b_value, [[onclick="OnChange_AutoSwitchActive(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_AutoSwitchActive", "LabeluiView_AutoSwitchActive",[[{?477:319?}]]))
box.out( [[<div class="formular" id="uiShow_TimerUseOptions">]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_weekly", "weekly", ( l_sz_name == 'weekly'), [[onclick="OnChange_SwitchOnTimeUse('weekly')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_weekly", "LabeluiView_SwitchOnTimeUse_weekly", [[{?477:94?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_weekly">]])
box.out( [[<p>{?477:163?}</p>]] )
if config.TIMERCONTROL then
box.out( [[<div id="uiTimerArea" class="formular">]])
timer.write_html(g_timer_id, {
active = [[{?477:38?}]],
inactive = [[{?477:518?}]]
})
box.out( [[</div>]])
end
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_daily", "daily", ( l_sz_name == 'daily'), [[onclick="OnChange_SwitchOnTimeUse('daily')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_daily", "LabeluiView_SwitchOnTimeUse_daily", [[{?477:939?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_daily">]])
box.out( [[<p>{?477:953?}</p>]])
box.out( [[<div class="narrow">]])
local l_timer_values = get_switch_timer_values_of( "daily", g_device_timer_state)
local l_b_switch_on_checked, l_switch_on_timer = is_daily_switch_on( l_timer_values)
box.out( elem._checkbox( "switch_on_action_daily", "uiView_SwitchOnAction_Daily", "1", (l_b_switch_on_checked == true), [[onclick="OnChange_SwitchOnActionDaily(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_Daily", "LabeluiView_SwitchOnAction_Daily", [[{?477:69?}]], [[ width: 75px;]]))
box.out( elem._label( "uiView_daily_from_hh", "LabeluiView_daily_from_hh", [[{?477:789?}]], [[margin-left: 25px; width: 25px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "daily_from_hh", "uiView_daily_from_hh", l_switch_on_timer.hh, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;:&nbsp;]])
box.out( elem._input_plusplus( "text", "daily_from_mm", "uiView_daily_from_mm", ha_func_lib.get_leading_zero(l_switch_on_timer.mm), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_daily_from_mm", "LabeluiView_daily_from_mm", [[{?477:8586?}]]))
box.out( [[</div>]])
box.out( [[<div class="narrow">]])
local l_b_switch_off_checked, l_switch_off_timer = is_daily_switch_off( l_timer_values)
box.out( elem._checkbox( "switch_off_action_daily", "uiView_SwitchOffAction_Daily", "1", (l_b_switch_off_checked == true), [[onclick="OnChange_SwitchOffActionDaily(this.checked)"]], [[]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOffAction_Daily", "LabeluiView_SwitchOffAction_Daily", [[{?477:386?}]], [[ width: 75px;]]))
box.out( elem._label( "uiView_daily_to_hh", "LabeluiView_daily_from_hh", [[{?477:249?}]], [[margin-left: 25px; width: 25px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "daily_to_hh", "uiView_daily_to_hh", l_switch_off_timer.hh, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;:&nbsp;]])
box.out( elem._input_plusplus( "text", "daily_to_mm", "uiView_daily_to_mm", ha_func_lib.get_leading_zero(l_switch_off_timer.mm), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_daily_to_mm", "LabeluiView_daily_to_mm", [[{?477:24?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_zufall", "zufall", ( l_sz_name == 'zufall'), [[onclick="OnChange_SwitchOnTimeUse('zufall')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_zufall", "LabeluiView_SwitchOnTimeUse_zufall", [[{?477:447?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_zufall">]])
box.out( [[<p>{?477:65?}</p>]])
local l_timer_values = get_switch_timer_values_of( "zufall", g_device_timer_state)
local l_date_values_1 = aha.GetGlobTimeDate( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_from_date_day", "LabeluiView_zufall_from_date_day", [[{?477:913?}]]))
box.out( elem._input_plusplus( "text", "zufall_from_date_day", "uiView_zufall_from_date_day", l_date_values_1.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_from_date_month", "uiView_zufall_from_date_month", l_date_values_1.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_from_date_year", "uiView_zufall_from_date_year", l_date_values_1.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
-- box.out( elem._label( "uiView_zufall_from_date_year", "LabeluiView_zufall_from_date_year", [[{?477:806?}]]))
box.out( [[</div>]])
local l_date_values_2 = aha.GetGlobTimeDate( l_timer_values[4].time )
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_to_date_day", "LabeluiView_zufall_to_date_day", [[{?477:543?}]]))
box.out( elem._input_plusplus( "text", "zufall_to_date_day", "uiView_zufall_to_date_day", l_date_values_2.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_to_date_month", "uiView_zufall_to_date_month", l_date_values_2.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_to_date_year", "uiView_zufall_to_date_year", l_date_values_2.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
-- box.out( elem._label( "uiView_zufall_to_date_year", "LabeluiView_zufall_to_date_year", [[{?477:672?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular mt20">]])
box.out( elem._label( "uiView_zufall_from_time_hh", "LabeluiView_zufall_from_time_hh", [[{?477:3658?}]]))
box.out( elem._input_plusplus( "text", "zufall_from_time_hh", "uiView_zufall_from_time_hh", math.floor(l_timer_values[2].time/60), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "zufall_from_time_mm", "uiView_zufall_from_time_mm", ha_func_lib.get_leading_zero(math.mod(l_timer_values[2].time, 60)), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_zufall_from_time_mm", "LabeluiView_zufall_from_time_mm", [[{?477:8212?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_to_time_hh", "LabeluiView_zufall_to_time_hh", [[{?477:738?}]]))
box.out( elem._input_plusplus( "text", "zufall_to_time_hh", "uiView_zufall_to_time_hh", math.floor(l_timer_values[3].time/60), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "zufall_to_time_mm", "uiView_zufall_to_time_mm", ha_func_lib.get_leading_zero(math.mod(l_timer_values[3].time,60)), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_zufall_to_time_mm", "LabeluiView_zufall_to_time_mm", [[{?477:946?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular mt20">]])
box.out( elem._label( "uiView_zufall_from_time_hh", "LabeluiView_zufall_from_time_hh", [[{?477:957?}]]))
local sz_selected = tostring( l_timer_values[5].time)
box.out( elem._select( "zufall_duration_switch", "uiView_zufall_duration_switch", g_t_zufall_switch_duration, sz_selected))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_countdown", "countdown", ( l_sz_name == 'countdown'), [[onclick="OnChange_SwitchOnTimeUse('countdown')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_countdown", "LabeluiView_SwitchOnTimeUse_countdown", [[{?477:524?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_countdown">]])
local l_timer_values = aha.GetSwitchCountdownRule( tonumber( g_device_id))
if ( l_timer_values.OnOff == tonumber( 65535)) then
l_timer_values.OnOff = 0
end
g_device_countdown_OnOff = tostring( l_timer_values.OnOff)
box.out( [[<p>{?477:370?}</p>]])
box.out( [[<p>]])
box.out( elem._radio( "countdown_manuell_on", "uiView_Countdown_Manuell_Off", "0", (tostring(l_timer_values.OnOff) == "0"), [[onclick="OnChange_Countdown_Manuell_On('0')"]], [[]] ))
box.out( [[&nbsp;]])
local l_countdown_time_dd_off = tostring( math.floor( tonumber( l_timer_values.Seconds)/3600) )
local l_countdown_time_mm_off = tostring( math.floor( math.mod( tonumber( l_timer_values.Seconds), 3600)/60 ))
box.out( elem._label( "uiView_Countdown_Manuell_Off", "LabeluiView_Countdown_Manuell_Off", [[{?477:86?}]]))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._input_plusplus( "text", "countdown_time_dd_off", "uiView_countdown_time_dd_off", l_countdown_time_dd_off, "3", "3", [[text-align: right;]], [[]], [[]]))
box.out( elem._label( "uiView_countdown_time_dd_off", "LabeluiView_countdown_time_dd_off_2", [[{?477:553?}]]))
box.out( elem._input_plusplus( "text", "countdown_time_mm_off", "uiView_countdown_time_mm_off", l_countdown_time_mm_off, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_countdown_time_mm_off", "LabeluiView_countdown_time_mm_off", [[{?477:4695?}]]))
box.out( [[</p>]])
box.out( [[<p class="mt20">{?477:685?}</p>]])
box.out( [[<p>]])
box.out( elem._radio( "countdown_manuell_on", "uiView_Countdown_Manuell_On", "1", ( tostring(l_timer_values.OnOff) == "1"), [[onclick="OnChange_Countdown_Manuell_On('1')"]], [[]] ))
box.out( [[&nbsp;]])
local l_countdown_time_dd_on = tostring( math.floor( tonumber( l_timer_values.Seconds)/3600) )
local l_countdown_time_mm_on = tostring( math.floor( math.mod( tonumber( l_timer_values.Seconds), 3600)/60 ))
box.out( elem._label( "uiView_Countdown_Manuell_On", "LabeluiView_Countdown_Manuell_On", [[{?477:993?}]]))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._input_plusplus( "text", "countdown_time_dd_on", "uiView_countdown_time_dd_on", l_countdown_time_dd_on, "3", "3", [[text-align: right;]], [[]], [[]]))
box.out( elem._label( "uiView_countdown_time_dd_on", "LabeluiView_countdown_time_dd_on_2", [[{?477:777?}]]))
box.out( elem._input_plusplus( "text", "countdown_time_mm_on", "uiView_countdown_time_mm_on", l_countdown_time_mm_on, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_countdown_time_mm_on", "LabeluiView_countdown_time_mm_on", [[{?477:357?}]]))
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_rythmisch", "rythmisch", ( l_sz_name == 'rythmisch'), [[onclick="OnChange_SwitchOnTimeUse('rythmisch')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_rythmisch", "LabeluiView_SwitchOnTimeUse_rythmisch", [[{?477:413?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_rythmisch">]])
box.out( [[<p>{?477:494?}</p>]])
local l_timer_values = get_switch_timer_values_of( "rythmisch", g_device_timer_state)
local sz_selected_rythmisch_on = tostring( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_rythmisch_switch_state_on", "LabeluiView_rythmisch_switch_state_on", [[{?477:4617?}]]))
box.out( elem._select( "rythmisch_switch_state_on", "uiView_rythmisch_switch_state_on", g_t_rythmisch_switch_duration, sz_selected_rythmisch_on))
box.out( [[&nbsp;]])
box.out( [[</div>]])
local sz_selected_rythmisch_off = tostring( l_timer_values[2].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_rythmisch_switch_state_off", "LabeluiView_rythmisch_switch_state_off", [[{?477:848?}]]))
box.out( elem._select( "rythmisch_switch_state_off", "uiView_rythmisch_switch_state_off", g_t_rythmisch_switch_duration, sz_selected_rythmisch_off))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_single", "single", ( l_sz_name == 'single'), [[onclick="OnChange_SwitchOnTimeUse('single')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_single", "LabeluiView_SwitchOnTimeUse_single", [[{?477:533?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_single">]])
box.out( [[<p>{?477:318?}</p>]])
local l_timer_values = get_switch_timer_values_of( "single", g_device_timer_state)
local l_date_values = aha.GetGlobTimeDate( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._radio( "switch_on_action_single", "uiView_SwitchOnAction_single_1", "1", (l_timer_values[1].action == 1), [[onclick="OnChange_SwitchOnActionSingle('1')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_single_1", "LabeluiView_SwitchOnAction_single_1", [[{?477:16?}]]))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._radio( "switch_on_action_single", "uiView_SwitchOnAction_single_0", "0", (l_timer_values[1].action == 0), [[onclick="OnChange_SwitchOnActionSingle('0')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_single_0", "LabeluiView_SwitchOnAction_single_0", [[{?477:631?}]]))
box.out( [[<div class="narrow mt10">]])
box.out( elem._label( "uiView_single_date_day", "LabeluiView_single_date_day", [[{?477:514?}]], [[width: 40px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "single_date_day", "uiView_single_date_day", l_date_values.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "single_date_month", "uiView_single_date_month", l_date_values.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "single_date_year", "uiView_single_date_year", l_date_values.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="narrow">]])
box.out( elem._label( "uiView_single_time_hh", "LabeluiView_single_time_hh", [[{?477:605?}]], [[width: 40px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "single_time_hh", "uiView_single_time_hh",l_date_values.Hour, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "single_time_mm", "uiView_single_time_mm", ha_func_lib.get_leading_zero(l_date_values.Minute), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="narrow mt10">]])
local sz_selected_single_duration = tostring(-1)
if ((l_timer_values[1].loop == 1) and (l_timer_values[2] ~= nil)) then
sz_selected_single_duration = tostring( l_timer_values[2].time - l_timer_values[1].time)
end
box.out( elem._label( "uiView_single_switch_duration", "LabeluiView_single_switch_duration", [[{?477:836?}]], [[width: 70px;]], [[timesSettings_daily]]))
box.out( elem._select( "single_switch_duration", "uiView_single_switch_duration", g_t_single_switch_duration, sz_selected_single_duration))
box.out( [[&nbsp;]])
-- box.out( elem._label( "uiView_single_switch_duration", "LabeluiView_single_switch_duration", [[{?477:240?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
local l_select_style = [[width: 230px; text-align: left; margin: 3px 0px 0px 0px;]]
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_sun_calendar", "sun_calendar", ( l_sz_name == 'sun_calendar'), [[onclick="OnChange_SwitchOnTimeUse('sun_calendar')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_sun_calendar", "LabeluiView_SwitchOnTimeUse_sun_calendar", [[{?477:396?}]]))
box.out( [[<div class="formular" id="uiShow_TimerSetup_astro">]])
box.out( [[<p>{?477:948?}</p>]])
local l_t_coord_values = aha.GetBoxLocation()
box.out( [[<div>]])
box.out([[<p>]])
box.out(general.sprintf(
box.tohtml([[{?477:297?}]]),
[[<a href="javascript:OnClick_StartGeoLocation();">]], [[</a>]]
))
box.out([[</p>]])
box.out( [[<div class="formular">]])
-- box.out( [[<span id="uiView_StartGeoLocation" class="fl_r mr20">{?477:825?}</span>]])
box.out( elem._label( "uiView_sun_latitude_min", "LabeluiView_sun_latitude_mi", [[{?477:92?}]], [[width: 75px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "sun_latitude_degree", "uiView_sun_latitude_degree", ha_func_lib.value_as_float(l_t_coord_values.Latitude, 4), "8", "8", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="formular">]])
-- box.out( [[<button class="fl_r mr100"id="uiBtn_StartGeoLocation" type="button" name="start_geo_location" onclick="return OnClick_StartGeoLocation()">{?477:557?}</button>]])
box.out( elem._label( "uiView_sun_longitude_min", "LabeluiView_sun_longitude_mi", [[{?477:748?}]], [[width: 75px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "sun_longitude_degree", "uiView_sun_longitude_degree", ha_func_lib.value_as_float(l_t_coord_values.Longitude, 4), "8", "9", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[</div>]])
local l_timer_values = get_switch_timer_values_of( "sun_calendar", g_device_timer_state)
local l_astro_timer = aha.HelperGetAstroTimer( tonumber(g_device_id), l_timer_values)
box.out( [[<div class="formular">]])
box.out( [[<p>]])
local l_sunrise_active = (l_astro_timer.sunrisetime.duration_timetype ~= "u") and (l_astro_timer.sunrisetime.offset_timetype ~= "u")
box.out( elem._checkbox( "sun_checkbox_sunrise", "uiView_CheckboxSunrise", "1", l_sunrise_active, [[onclick="OnChange_Sunrise(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_CheckboxSunrise", "LabeluiView_CheckboxSunrise",[[{?477:106?}]]))
box.out( [[<div class="formular" id="uiShow_Sunrise">]])
box.out( elem._label( "uiView_Sunrise_Offset", "LabeluuiView_Sunrise_Offset", [[{?477:9463?}]]))
box.out( elem._select_plus( "sunrise_offset", "uiView_Sunrise_Offset", g_t_sunrise_offset, tostring(l_astro_timer.sunrisetime.offset_minutes), nil, l_select_style, [[]]))
box.out( [[<br />]])
box.out( elem._label( "uiView_Sunrise_Duration", "LabeluuiView_Sunrise_Duration", [[{?477:621?}]]))
local l_sunrise_duration_value = tostring(l_astro_timer.sunrisetime.duration_timetype)..[[#]]..tostring((l_astro_timer.sunrisetime.duration_minutes - l_astro_timer.sunrisetime.offset_minutes))
if ( tostring(l_astro_timer.sunrisetime.duration_timetype) == "d") or ( tonumber(l_astro_timer.sunrisetime.duration_minutes ) == 4095) then
l_sunrise_duration_value = tostring(l_astro_timer.sunrisetime.duration_timetype)..[[#]]..tostring(l_astro_timer.sunrisetime.duration_minutes )
end
box.out( elem._select_plus( "sunrise_duration", "uiView_Sunrise_Duration", g_t_sunrise_switch_duration, l_sunrise_duration_value, nil, l_select_style))
box.out( [[</div>]])
local l_sunset_active = (l_astro_timer.sunsettime.duration_timetype ~= "u") and (l_astro_timer.sunsettime.offset_timetype ~= "u")
box.out( elem._checkbox( "sun_checkbox_sunset", "uiView_CheckboxSunset", "1", l_sunset_active, [[onclick="OnChange_Sunset(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_CheckboxSunset", "LabeluiView_CheckboxSunset",[[{?477:184?}]]))
box.out( [[<div class="formular" id="uiShow_Sunset">]])
box.out( elem._label( "uiView_Sunset_Offset", "LabeluuiView_Sunset_Offset", [[{?477:684?}]]))
box.out( elem._select_plus( "sunset_offset", "uiView_Sunset_Offset", g_t_sunset_offset, tostring(l_astro_timer.sunsettime.offset_minutes), nil, l_select_style, [[]]))
box.out( [[<br />]])
box.out( elem._label( "uiView_Sunset_Duration", "LabeluiView_Sunset_Duration", [[{?477:285?}]]))
local l_sunset_duration_value = tostring(l_astro_timer.sunsettime.duration_timetype)..[[#]]..tostring((l_astro_timer.sunsettime.duration_minutes - l_astro_timer.sunsettime.offset_minutes))
if ( tostring(l_astro_timer.sunsettime.duration_timetype) == "d") or ( tonumber(l_astro_timer.sunsettime.duration_minutes ) == 4095) then
l_sunset_duration_value = tostring(l_astro_timer.sunsettime.duration_timetype)..[[#]]..tostring(l_astro_timer.sunsettime.duration_minutes )
end
box.out( elem._select_plus( "sunset_duration", "uiView_Sunset_Duration", g_t_sunset_switch_duration, l_sunset_duration_value,nil, l_select_style))
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p id="uiEnable_Google_Cal">]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_calendar", "calendar", ( l_sz_name == 'calendar'), [[onclick="OnChange_SwitchOnTimeUse('calendar')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_calendar", "LabeluiView_SwitchOnTimeUse_calendar", [[{?477:858?}]]))
box.out( [[<div class="wide" id="uiShow_TimerSetup_calendar">]])
box.out( [[<div class="formular">]])
box.out( [[<p id="uiView_calendar_google_Text_1">{?477:695?}</p>]])
if ( ha_func_lib.is_network_device( g_device_id)) then
box.out( [[<p id="uiView_calendar_google_Text_2">{?477:582?}</p>]])
end
local l_calendar_name = ha_func_lib.get_calendar_name( g_device_id)
box.out( [[<div class="formular mt10">]])
box.out( elem._label( "uiView_calendar_google_calendarname", "Label_calendar_google_calendarname", [[{?477:457?}:]]))
box.out( elem._input( "text", "calendar_google_calendarname", "uiView_calendar_google_calendarname", l_calendar_name, "24", "50", [[]]))
box.out( [[</div>]])
if ( not (ha_func_lib.is_network_device( g_device_id))) then
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(l_calendar_name))
if ( l_b_exist == true) then
g_last_calender_state = box.query( [[oncal:settings/]]..tostring( l_node)..[[/laststatus]])
local l_last_connect = ""
local l_err_msg_text = ""
local l_timer_values = {}
local l_sz_last_switch = [[{?477:364?}]]
local l_html_style_1 = [[]]
local l_html_style_2 = [[]]
if ( tonumber( g_last_calender_state) == 0) then
l_last_connect = box.query( [[oncal:settings/]]..tostring( l_node)..[[/lastconnect]])
l_timer_values = get_switch_timer_values_of( "calendar", g_device_timer_state)
if ((l_timer_values ~= nil) and (l_timer_values[1] ~= nil) and ( l_timer_values[1].time ~= nil) and (l_timer_values[1].time ~= 0)) then
local l_date_values = aha.GetGlobTimeDate( l_timer_values[1].time)
local l_sz_date = ha_func_lib.get_leading_zero( l_date_values.Day)..[[.]]..ha_func_lib.get_leading_zero( l_date_values.Month)..[[.]]..ha_func_lib.get_leading_zero( l_date_values.Year)
local l_sz_time = ha_func_lib.get_leading_zero( l_date_values.Hour)..[[:]]..ha_func_lib.get_leading_zero( l_date_values.Minute)
l_sz_last_switch = tostring( l_sz_date..[[ ]]..l_sz_time)
l_html_style_1 = [[ class="output" style="width: 200px;"]]
end
l_html_style_2, l_last_connect = ha_func_lib.convert_to_german( l_last_connect)
else
l_err_msg_text = get_cal_state_text( tostring( g_last_calender_state))
end
box.out( [[<div id ="uiShow_GoogleState_OK" class="formular" ]]..string_op.txt_style_display_none( not(tonumber(g_last_calender_state) == 0))..[[>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_calendar_google_NextSwitch", "Label_calendar_google_NextSwitch", [[{?477:277?}:]]))
box.out( [[<span id="uiView_calendar_google_NextSwitch"]]..tostring(l_html_style_1)..[[>]]..tostring( l_sz_last_switch)..[[</span>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_calendar_google_LastSync", "Label_calendar_google_LastSync", [[{?477:9092?}:]]))
box.out( [[<span id="uiView_calendar_google_LastSync"]]..tostring(l_html_style_2)..[[>]]..tostring( l_last_connect)..[[</span>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[<div id ="uiShow_GoogleState_Error" class="formular" ]]..string_op.txt_style_display_none( not(tonumber(g_last_calender_state) ~= 0))..[[>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_calendar_google_CurrentStatus", "Label_calendar_google_CurrentStatus", [[{?477:461?}:]]))
box.out( [[<span id="uiView_calendar_google_CurrentStatus" class="error" style="width: 200px;">]]..tostring( l_err_msg_text)..[[</span>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[<div><a id="uiLink_ResetGoogleArea" href="javascript:OnClick_ShowResetGoogleArea();" class="textlink nocancel">]]..[[{?477:29?}]]..[[<img id="uiLink_ResetGoogleArea_Img" src="/css/default/images/link_open.gif" height="12"></a></div>]])
box.out( [[<div id="uiView_ResetGoogleArea" style="display: none;">]])
box.out( [[<p>{?477:244?}</p>]])
box.out( [[<button id="uiBtn_ResetGoogle_Cal" type="submit" name="reset_google_calender" onclick="return OnClick_ResetGoogleCal()" style="margin: 0px 20px 0px 25px;">{?477:223?}</button>]])
box.out( [[</div>]])
end
end
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[<hr>]])
local l_b_value, l_n_power,l_n_duration= ha_func_lib.get_standby_state( g_device_id)
box.out( elem._checkbox( "stand_by_active", "uiView_StandByActive", "1", l_b_value, [[onclick="OnChange_StandByActive(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_StandByActive", "LabeluiView_StandByActive",[[{?477:273?}]]))
box.out( [[<div class="formular" id="uiShow_StandBySettings">]])
box.out( [[<p>{?477:303?}</p>]])
box.out( [[<div class="formular">]])
local l_power = tostring( ha_func_lib.value_as_float(tonumber(l_n_power), 2))
if ( l_power == "0,0") then
l_power = ""
end
box.out( elem._label( "uiView_Standby_Power", "LabeluiView_Standby_Power", [[{?477:425?}]]))
-- box.out( elem._select( "stand_by_power", "uiView_Standby_Power", g_t_stand_by_power, tostring(l_n_power)))
box.out( elem._input_plusplus( "text", "stand_by_power", "uiView_Standby_Power", l_power, "6", "6", [[text-align:right;]], [[]], [[]]))
box.out( [[&nbsp;&nbsp;]])
box.out( elem._label( "uiView_Standby_Power", "LabeluiView_Standby_Power_2", [[{?477:755?}]]))
box.out( [[</div>]])
box.out( [[<div class="formular">]])
local l_duration = tostring( tonumber(l_n_duration)/60)
if ( l_duration == "0") then
l_duration = ""
end
box.out( elem._label( "uiView_Standby_Duration", "LabeluiView_Standby_Duration", [[{?477:804?}]]))
-- box.out( elem._select( "stand_by_duration", "uiView_Standby_Duration", g_t_stand_by_duration, tostring(l_n_duration)))
box.out( elem._input_plusplus( "text", "stand_by_duration", "uiView_Standby_Duration", l_duration, "6", "5", [[text-align:right;]], [[]], [[]]))
box.out( [[&nbsp;&nbsp;]])
box.out( elem._label( "uiView_Standby_Duration", "LabeluiView_Standby_Duration_2", [[{?477:363?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
else
box.out( [[<div id="uiViewHasNoTime">]])
box.out( [[<p>{?477:841?}</p>]])
box.out( [[</div>]])
end
?>
<div id="btn_form_foot">
<input type="hidden" name="current_ule" value="<?lua box.out(g_device_id) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
if ( g_hastime ) then
box.out( [[<button type="submit" name="apply" id="uiApply">{?477:165?}</button>]])
box.out( [[<button type="submit" name="cancel">{?txtCancel?}</button>]])
else
box.out( [[<button type="submit" name="cancel">{?477:711?}</button>]])
end
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ha_sets.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<?lua
if config.TIMERCONTROL then
box.out([[
<script type="text/javascript" src="/js/timer.js"></script>
]])
end
?>
<script type="text/javascript">
var g_IsNetworkDevice = <?lua box.js( ha_func_lib.is_network_device( g_device_id)) ?>;
var g_ShowResetGoogleArea = false;
var g_bAutoSwitchActive = false;
var g_TO_All_States_Value = 1000 * 37; // alle 37 sec.
var json = makeJSONParser();
var sidParam = buildUrlParam( "sid", "<?lua box.js(box.glob.sid) ?>");
<?lua
box.out([[
var g_timer = null;
]])
if ( config.TIMERCONTROL and g_hastime) then
local l_timer_values = get_switch_timer_values_of( "weekly", g_device_timer_state)
local g_weekly_data = write_weekly_js_struct( l_timer_values)
box.out([[ var g_data = [
]]..tostring(g_weekly_data[1])..[[,
]]..tostring(g_weekly_data[2])..[[,
]]..tostring(g_weekly_data[3])..[[,
]]..tostring(g_weekly_data[4])..[[,
]]..tostring(g_weekly_data[5])..[[,
]]..tostring(g_weekly_data[6])..[[,
]]..tostring(g_weekly_data[7])..[[
];
]])
end
local l_timer_values_single = get_switch_timer_values_of( "single", g_device_timer_state)
g_current_single_date_values = aha.GetGlobTimeDate( l_timer_values_single[1].time)
local l_timer_values_zufall = get_switch_timer_values_of( "zufall", g_device_timer_state)
g_current_zufall_from_date_values = aha.GetGlobTimeDate( l_timer_values_zufall[1].time)
g_current_zufall_to_date_values = aha.GetGlobTimeDate( l_timer_values_zufall[2].time)
?>
var g_IsNetworkDevice = <?lua box.js( ha_func_lib.is_network_device( g_device_id)) ?>;
var g_current_single_date_year = "<?lua box.js( tostring( g_current_single_date_values.Year)) ?>";
var g_current_single_date_month = "<?lua box.js( tostring( g_current_single_date_values.Month)) ?>";
var g_current_single_date_day = "<?lua box.js( tostring( g_current_single_date_values.Day)) ?>";
var g_current_single_time_hh = "<?lua box.js( tostring( g_current_single_date_values.Hour)) ?>";
var g_current_single_time_mm = "<?lua box.js( tostring( g_current_single_date_values.Minute)) ?>";
var g_current_zufall_from_date_year = "<?lua box.js( tostring( g_current_zufall_from_date_values.Year)) ?>";
var g_current_zufall_from_month = "<?lua box.js( tostring( g_current_zufall_from_date_values.Month)) ?>";
var g_current_zufall_from_day = "<?lua box.js( tostring( g_current_zufall_from_date_values.Day)) ?>";
var g_current_zufall_from_time_hh = "<?lua box.js( tostring( g_current_zufall_from_date_values.Hour)) ?>";
var g_current_zufall_from_time_mm = "<?lua box.js( tostring( g_current_zufall_from_date_values.Minute)) ?>";
var g_current_zufall_to_date_year = "<?lua box.js( tostring( g_current_zufall_to_date_values.Year)) ?>";
var g_current_zufall_to_month = "<?lua box.js( tostring( g_current_zufall_to_date_values.Month)) ?>";
var g_current_zufall_to_day = "<?lua box.js( tostring( g_current_zufall_to_date_values.Day)) ?>";
var g_current_zufall_to_time_hh = "<?lua box.js( tostring( g_current_zufall_to_date_values.Hour)) ?>";
var g_current_zufall_to_time_mm = "<?lua box.js( tostring( g_current_zufall_to_date_values.Minute)) ?>";
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
setTimeout( "GetOutletStates("+response.DeviceID+")", 37000); // alle 37 sec.
}
}
function GetGoogleStatusText( szStatus) {
var szRetCode = "{?477:215?}"+szStatus+"{?477:8177?}";
switch( szStatus) {
case "1":
szRetCode = "{?477:146?}";
break;
case "2":
szRetCode = "{?477:545?}";
break;
case "11":
szRetCode = "{?477:780?}";
break;
case "10":
szRetCode = "{?477:64?}";
break;
case "8":
case "12":
szRetCode = "{?477:399?}";
break;
case "16":
case "17":
case "18":
case "19":
case "20":
case "21":
case "22":
szRetCode = "{?477:488?}"+szStatus+"{?477:61?}";
break;
}
return szRetCode
}
function PollCalenderState( szDeviceID) {
// Ajax get zum Abfragen.
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "CalendarState");
url += "&" + buildUrlParam( "id", szDeviceID);
ajaxGet( url, cb_Receive_Outlet_State_Values)
}
function cb_Receive_Calendar_State(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult != "0")) {
if ( response.LastState == "2") {
setTimeout( "PollCalenderState("+response.DeviceID+")", 1000)
} else {
if ( response.LastState == "0") {
jxl.setHtml( "uiView_calendar_google_NextSwitch", response.LastSwitch);
jxl.setHtml( "uiView_calendar_google_LastSync", response.LastSync);
jxl.addClass( "uiView_calendar_google_LastSync", "output");
jxl.setStyle( "uiView_calendar_google_LastSync", "width: 200px;");
jxl.display( "uiShow_GoogleState_Error", false);
jxl.display( "uiShow_GoogleState_OK", true);
} else {
szStatusText = GetGoogleStatusText( response.LastState);
jxl.setHtml( "uiView_calendar_google_CurrentStatus", szStatusText);
jxl.display( "uiShow_GoogleState_OK", false);
jxl.display( "uiShow_GoogleState_Error", true);
}
}
}
}
function OnChange_AutoSwitchActive( bValue) {
jxl.enableNode( "uiShow_TimerUseOptions", bValue);
if ( bValue ) {
jxl.setValue( "uiView_AutoSwitchActive", 1);
} else {
jxl.setValue( "uiView_AutoSwitchActive", 0);
}
if ( g_IsNetworkDevice == true) {
jxl.disable( "uiView_SwitchOnTimeUse_calendar");
jxl.disable( "LabeluiView_SwitchOnTimeUse_calendar");
}
}
function OnChange_SwitchOnTimeUse( szValue) {
if ( "daily" == szValue) {
OnChange_SwitchOnActionDaily( jxl.getChecked( "uiView_SwitchOnAction_Daily"));
OnChange_SwitchOffActionDaily( jxl.getChecked( "uiView_SwitchOffAction_Daily"));
}
if ( "countdown" == szValue) {
if ( jxl.getChecked("uiView_Countdown_Manuell_Off")) {
OnChange_Countdown_Manuell_On( "0");
} else {
OnChange_Countdown_Manuell_On( "1");
}
}
if ( "sun_calendar" == szValue) {
jxl.display( "uiView_StartGeoLocation", navigator.geolocation);
jxl.display( "uiBtn_StartGeoLocation", navigator.geolocation);
OnChange_Sunrise( jxl.getChecked( "uiView_CheckboxSunrise"));
OnChange_Sunset( jxl.getChecked( "uiView_CheckboxSunset"));
}
if ( g_IsNetworkDevice == true) {
jxl.disable( "uiView_SwitchOnTimeUse_calendar");
jxl.disable( "LabeluiView_SwitchOnTimeUse_calendar");
}
jxl.enableNode( "uiView_calendar_google_Text_1", ( g_IsNetworkDevice != true));
// jxl.enableNode( "uiView_calendar_google_Text_2", ( g_IsNetworkDevice == true));
jxl.enableNode( "Label_calendar_google_calendarname", ( g_IsNetworkDevice != true));
jxl.enableNode( "uiView_calendar_google_calendarname", ( g_IsNetworkDevice != true));
jxl.display( "uiShow_TimerSetup_daily", ("daily" == szValue));
jxl.display( "uiShow_TimerSetup_weekly", ("weekly" == szValue));
jxl.display( "uiShow_TimerSetup_zufall", ("zufall" == szValue));
jxl.display( "uiShow_TimerSetup_countdown", ("countdown" == szValue));
jxl.display( "uiShow_TimerSetup_rythmisch", ("rythmisch" == szValue));
jxl.display( "uiShow_TimerSetup_single", ("single" == szValue));
jxl.display( "uiShow_TimerSetup_astro", ("sun_calendar" == szValue));
jxl.display( "uiShow_TimerSetup_calendar", ("calendar" == szValue));
g_szTimerUse = szValue;
}
function OnChange_SwitchOnActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_from_hh");
jxl.enable( "uiView_daily_from_mm");
} else {
jxl.disable( "uiView_daily_from_hh");
jxl.disable( "uiView_daily_from_mm");
}
}
function OnChange_SwitchOffActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_to_hh");
jxl.enable( "uiView_daily_to_mm");
} else {
jxl.disable( "uiView_daily_to_hh");
jxl.disable( "uiView_daily_to_mm");
}
}
function OnChange_Countdown_Manuell_On( szValue) {
if ( szValue != "0") {
jxl.enable( "uiView_countdown_time_dd_on");
jxl.enable( "uiView_countdown_time_mm_on");
jxl.disable( "uiView_countdown_time_dd_off");
jxl.disable( "uiView_countdown_time_mm_off");
} else {
jxl.enable( "uiView_countdown_time_dd_off");
jxl.enable( "uiView_countdown_time_mm_off");
jxl.disable( "uiView_countdown_time_dd_on");
jxl.disable( "uiView_countdown_time_mm_on");
}
}
function OnChange_SwitchOnActionSingle( szValue) {
}
function OnChange_Sunrise( bValue) {
jxl.enableNode( "uiShow_Sunrise", bValue);
}
function OnChange_Sunset( bValue) {
jxl.enableNode( "uiShow_Sunset", bValue);
}
function OnChange_StandByActive( bValue) {
jxl.enableNode( "uiShow_StandBySettings", bValue);
}
function OnClick_ShowResetGoogleArea() {
g_ShowResetGoogleArea =! g_ShowResetGoogleArea;
jxl.display( "uiView_ResetGoogleArea", g_ShowResetGoogleArea);
var img = jxl.get( "uiLink_ResetGoogleArea_Img")
if ( img) {
img.src = g_ShowResetGoogleArea ? '/css/default/images/link_closed.gif' : '/css/default/images/link_open.gif';
}
}
function OnClick_ResetGoogleCal() {
var bRetCode = confirm('{?477:747?}');
return bRetCode;
}
function onEditDevSubmit() {
if (jxl.getChecked("uiView_AutoSwitchActive")) {
if ( jxl.getChecked( "uiView_SwitchOnTimeUse_zufall")) {
if ( ( Number(g_current_zufall_from_date_year) != Number( jxl.getValue( "uiView_zufall_from_date_year"))) ||
( Number(g_current_zufall_from_date_month) != Number( jxl.getValue( "uiView_zufall_from_date_month"))) ||
( Number(g_current_zufall_from_date_day) != Number( jxl.getValue( "uiView_zufall_from_date_day"))) ||
( Number(g_current_zufall_from_time_hh) != Number( jxl.getValue( "uiView_zufall_from_time_hh"))) ||
( Number(g_current_zufall_from_time_mm) != Number( jxl.getValue( "uiView_zufall_from_time_mm"))) ||
( Number(g_current_zufall_to_date_year) != Number( jxl.getValue( "uiView_zufall_to_date_year"))) ||
( Number(g_current_zufall_to_date_month) != Number( jxl.getValue( "uiView_zufall_to_date_month"))) ||
( Number(g_current_zufall_to_date_day) != Number( jxl.getValue( "uiView_zufall_to_date_day"))) ||
( Number(g_current_zufall_to_time_hh) != Number( jxl.getValue( "uiView_zufall_to_time_hh"))) ||
( Number(g_current_zufall_to_time_mm) != Number( jxl.getValue( "uiView_zufall_to_time_mm"))) ) {
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"));
oDate_Now = new Date()
oDate_DayNow = new Date( oDate_Now.getFullYear(), oDate_Now.getMonth(), oDate_Now.getDate());
if ( oDate_From.getTime() < oDate_DayNow.getTime()) {
val.markError("uiView_zufall_from_date_year");
val.markError("uiView_zufall_from_date_month");
val.markError("uiView_zufall_from_date_day");
var szErrorText = "{?477:123?}";
alert( szErrorText);
return false;
}
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"));
oDate_To = new Date(jxl.getValue("uiView_zufall_to_date_year"),jxl.getValue("uiView_zufall_to_date_month")-1,jxl.getValue("uiView_zufall_to_date_day"));
if ( oDate_From.getTime() > oDate_To.getTime()) {
val.markError("uiView_zufall_from_date_year");
val.markError("uiView_zufall_from_date_month");
val.markError("uiView_zufall_from_date_day");
val.markError("uiView_zufall_to_date_year");
val.markError("uiView_zufall_to_date_month");
val.markError("uiView_zufall_to_date_day");
var szErrorText = "{?477:7999?}";
alert( szErrorText);
return false;
} else if ( oDate_From.getTime() == oDate_To.getTime()) {
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"),jxl.getValue("uiView_zufall_from_time_hh"),jxl.getValue("uiView_zufall_from_time_mm"));
oDate_To = new Date(jxl.getValue("uiView_zufall_to_date_year"),jxl.getValue("uiView_zufall_to_date_month")-1,jxl.getValue("uiView_zufall_to_date_day"),jxl.getValue("uiView_zufall_to_time_hh"),jxl.getValue("uiView_zufall_to_time_mm"));
if ( oDate_From.getTime() > oDate_To.getTime()) {
val.markError("uiView_zufall_from_time_hh");
val.markError("uiView_zufall_from_time_mm");
val.markError("uiView_zufall_to_time_hh");
val.markError("uiView_zufall_to_time_mm");
var szErrorText = "{?477:101?}";
alert( szErrorText);
return false;
}
}
}
}
if ( jxl.getChecked( "uiView_SwitchOnTimeUse_weekly")) {
nWeeklySwitchCount = g_timer.ha_save("uiMainForm");
if ((nWeeklySwitchCount < 2) || (nWeeklySwitchCount > 100)) {
val.markError("uiMainForm");
var szErrorText = "{?477:2787?}";
if (nWeeklySwitchCount == 1) {
szErrorText = "{?477:906?}";
}
if (nWeeklySwitchCount > 100) {
szErrorText = "{?477:10?}"+nWeeklySwitchCount+"{?477:181?}";
}
alert( szErrorText);
return false;
}
}
if (jxl.getChecked("uiView_SwitchOnTimeUse_single")) {
if ( ( Number(g_current_single_date_year) != Number( jxl.getValue( "uiView_single_date_year"))) ||
( Number(g_current_single_date_month) != Number( jxl.getValue( "uiView_single_date_month"))) ||
( Number(g_current_single_date_day) != Number( jxl.getValue( "uiView_single_date_day"))) ||
( Number(g_current_single_time_hh) != Number( jxl.getValue( "uiView_single_time_hh"))) ||
( Number(g_current_single_time_mm) != Number( jxl.getValue( "uiView_single_time_mm"))) ) {
var oDate_Single = new Date(jxl.getValue("uiView_single_date_year"),jxl.getValue("uiView_single_date_month")-1,jxl.getValue("uiView_single_date_day"),jxl.getValue("uiView_single_time_hh"),jxl.getValue("uiView_single_time_mm"));
var oDate_Now = new Date()
if ( oDate_Single.getTime() < oDate_Now.getTime()) {
val.markError("uiView_single_date_year");
val.markError("uiView_single_date_month");
val.markError("uiView_single_date_day");
val.markError("uiView_single_time_hh");
val.markError("uiView_single_time_mm");
var szErrorText = "{?477:1855?}";
alert( szErrorText);
return false;
}
}
}
if ( g_szTimerUse == "") {
var szErrorText = "{?477:194?}";
alert( szErrorText);
return false;
}
}
}
function ui_cb_MainFormSubmit() {
}
function OnClick_StartGeoLocation() {
if (navigator.geolocation) {
navigator.geolocation.getCurrentPosition( cb_GetPosition, cb_GetPositionError);
}
}
function cb_GetPosition( oPosition) {
var nDirecetion_Lat = 1;
var nDirecetion_Long = 1;
if ( oPosition.coords.latitude < 0 ) {
nDirecetion_Lat = -1;
}
if ( oPosition.coords.longitude < 0 ) {
szDirecetion_Long = -1;
}
var nLatitude = (Math.abs(Number(oPosition.coords.latitude)))*3600;
var nLongitude = (Math.abs(Number(oPosition.coords.longitude)))*3600;
var nLati_Degree = Math.floor( nLatitude/3600);
var nLongi_Degree = Math.floor( nLongitude/3600);
var nLatitude_MinDez = nLatitude/60 - nLati_Degree*60;
var nLongitude_MinDez = nLongitude/60 - nLongi_Degree*60;
var nLatitude_Min = Math.floor( nLatitude_MinDez);
var nLongitude_Min = Math.floor( nLongitude_MinDez);
var nLatitude_Sec = Math.floor( (nLatitude_MinDez - nLatitude_Min)*60*1000000);
var nLongitude_Sec = Math.floor( (nLongitude_MinDez - nLongitude_Min)*60*1000000);
var nLatitude_Sec = Math.round( nLatitude_Sec/1000000);
var nLongitude_Sec = Math.round( nLongitude_Sec/1000000);
jxl.setValue("uiView_sun_latitude_degree", ha_sets.formatAsFloat(Number(oPosition.coords.latitude).toFixed(4)));
jxl.setValue("uiView_sun_longitude_degree", ha_sets.formatAsFloat(Number(oPosition.coords.longitude).toFixed(4)));
}
function cb_GetPositionError( error) {
switch(error.code) {
case error.PERMISSION_DENIED:
alert( "{?477:2936?}");
break;
case error.POSITION_UNAVAILABLE:
alert( "{?477:6113?}");
break;
case error.TIMEOUT:
alert( "{?477:722?}");
break;
default:
alert( "{?477:798?}"+error.code);
break;
}
}
<?lua
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( g_device_timer_state)
box.out( [[var g_bAutoSwitch = (]]..l_sz_value..[[ == 1);]])
box.out( [[var g_szTimerUse = "]]..l_sz_name..[[";]])
box.out( [[var g_nLastCalendarState = "]]..g_last_calender_state..[[";]])
?>
function init() {
var countdownSwitchValue = "0";
<?lua
if g_hastime then
box.out( [[
g_timer = new Timer("]]..g_timer_id..[[", g_data);
]] )
end
?>
OnChange_SwitchOnTimeUse( g_szTimerUse );
if ( (g_szTimerUse == "calender") && (g_nLastCalendarState == "2") ) {
setTimeout( "PollCalenderState(<?lua box.out(g_device_id) ?>)", 1000 );
}
setTimeout( "GetOutletStates(<?lua box.out(g_device_id) ?>)", 10000 ); // erste Mal nach 10 sec.
OnChange_AutoSwitchActive( g_bAutoSwitch );
OnChange_StandByActive( jxl.getChecked("uiView_StandByActive") );
}
ready.onReady(ajaxValidation({
formNameOrIndex: "main_form",
applyNames: "apply",
okCallback: onEditDevSubmit
}));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
