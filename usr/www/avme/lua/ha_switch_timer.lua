--[[Access denied<?lua
box.end_page()
?>]]
require("general")
require("lualib")
if config.TIMERCONTROL then
require("timer")
else
general.dbg_out("Das funktioniert hier nicht ohne TimerCtrl!!!\n")
return
end
require("textdb")
require("cmtable")
require("html")
require("math")
require("libaha")
require("ha_func_lib")
ha_switch_timer = {}
local g_sz_text_userdefined = TXT( [[{?235:3581?}]])
local g_t_rythmisch_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], TXT( [[{?235:948?}]]) },
{ [[2]], TXT( [[{?235:308?}]]) },
{ [[5]], TXT( [[{?235:223?}]]) },
{ [[10]], TXT( [[{?235:581?}]]) },
{ [[15]], TXT( [[{?235:286?}]]) },
{ [[30]], TXT( [[{?235:707?}]]) },
{ [[45]], TXT( [[{?235:21?}]]) },
{ [[60]], TXT( [[{?235:424?}]]) },
{[[120]], TXT( [[{?235:349?}]]) },
{[[180]], TXT( [[{?235:205?}]]) },
{[[300]], TXT( [[{?235:458?}]]) }
}
local g_t_single_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], TXT( [[{?235:757?}]]) },
{ [[5]], TXT( [[{?235:177?}]]) },
{ [[15]], TXT( [[{?235:867?}]]) },
{ [[30]], TXT( [[{?235:583?}]]) },
{ [[60]], TXT( [[{?235:129?}]]) },
{[[120]], TXT( [[{?235:536?}]]) },
{[[180]], TXT( [[{?235:687?}]]) },
{[[300]], TXT( [[{?235:116?}]]) },
{[[600]], TXT( [[{?235:192?}]]) },
{[[1440]], TXT( [[{?235:668?}]]) },
{[[-1]], TXT( [[{?235:971?}]]) }
}
local g_t_zufall_switch_duration = { { [[0]], g_sz_text_userdefined},
{ [[1]], TXT( [[{?235:600?}]]) },
{ [[2]], TXT( [[{?235:990?}]]) },
{ [[5]], TXT( [[{?235:857?}]]) },
{[[10]], TXT( [[{?235:182?}]]) },
{[[15]], TXT( [[{?235:983?}]]) },
{[[20]], TXT( [[{?235:6932?}]]) },
{[[30]], TXT( [[{?235:659?}]]) },
{[[40]], TXT( [[{?235:688?}]]) },
{[[50]], TXT( [[{?235:232?}]]) },
{[[60]], TXT( [[{?235:319?}]]) }
}
local g_t_sunrise_switch_duration = { { [[u#0]], g_sz_text_userdefined},
{ [[r#5]], TXT( [[{?235:912?}]]) },
{ [[r#10]], TXT( [[{?235:813?}]]) },
{ [[r#15]], TXT( [[{?235:957?}]]) },
{ [[r#30]], TXT( [[{?235:619?}]]) },
{ [[r#45]], TXT( [[{?235:186?}]]) },
{ [[r#60]], TXT( [[{?235:382?}]]) },
{ [[r#90]], TXT( [[{?235:320?}]]) },
{[[r#120]], TXT( [[{?235:392?}]]) },
{[[r#180]], TXT( [[{?235:840?}]]) },
{[[r#240]], TXT( [[{?235:77?}]]) },
{[[r#300]], TXT( [[{?235:569?}]]) },
{[[d#480]], TXT( [[{?235:59?}]]) },
{[[d#600]], TXT( [[{?235:13?}]]) },
{[[d#720]], TXT( [[{?235:50?}]]) },
{[[r#4095]], TXT( [[{?235:4052?}]]) }
}
local g_t_sunset_switch_duration = { { [[u#0]], g_sz_text_userdefined},
{ [[r#5]], TXT( [[{?235:167?}]]) },
{ [[r#10]], TXT( [[{?235:140?}]]) },
{ [[r#15]], TXT( [[{?235:720?}]]) },
{ [[r#30]], TXT( [[{?235:2092?}]]) },
{ [[r#45]], TXT( [[{?235:4347?}]]) },
{ [[r#60]], TXT( [[{?235:626?}]]) },
{ [[r#90]], TXT( [[{?235:397?}]]) },
{ [[r#120]], TXT( [[{?235:386?}]]) },
{ [[r#180]], TXT( [[{?235:910?}]]) },
{ [[r#240]], TXT( [[{?235:56?}]]) },
{ [[r#300]], TXT( [[{?235:75?}]]) },
{[[d#1260]], TXT( [[{?235:143?}]]) },
{[[d#1320]], TXT( [[{?235:728?}]]) },
{[[d#1380]], TXT( [[{?235:339?}]]) },
{ [[d#0]], TXT( [[{?235:4685?}]]) },
{ [[d#60]], TXT( [[{?235:310?}]]) },
{[[r#4095]], TXT( [[{?235:495?}]]) }
}
local g_t_sunrise_offset = { {[[-120]], TXT( [[{?235:67?}]]) },
{ [[-60]], TXT( [[{?235:630?}]]) },
{ [[-45]], TXT( [[{?235:887?}]]) },
{ [[-30]], TXT( [[{?235:260?}]]) },
{ [[-15]], TXT( [[{?235:6808?}]]) },
{ [[0]], TXT( [[{?235:671?}]]) },
{ [[15]], TXT( [[{?235:72?}]]) },
{ [[30]], TXT( [[{?235:210?}]]) },
{ [[45]], TXT( [[{?235:8124?}]]) },
{ [[60]], TXT( [[{?235:463?}]]) },
{ [[120]], TXT( [[{?235:4220?}]]) }
}
local g_t_sunset_offset = { {[[-120]], TXT( [[{?235:556?}]]) },
{ [[-60]], TXT( [[{?235:258?}]]) },
{ [[-45]], TXT( [[{?235:567?}]]) },
{ [[-30]], TXT( [[{?235:534?}]]) },
{ [[-15]], TXT( [[{?235:655?}]]) },
{ [[0]], TXT( [[{?235:306?}]]) },
{ [[15]], TXT( [[{?235:445?}]]) },
{ [[30]], TXT( [[{?235:712?}]]) },
{ [[45]], TXT( [[{?235:733?}]]) },
{ [[60]], TXT( [[{?235:940?}]]) },
{ [[120]], TXT( [[{?235:792?}]]) }
}
local g_t_suncalender_latitude = { { [[1]], TXT( [[{?235:5248?}]]) },
{ [[-1]], TXT( [[{?235:477?}]]) }
}
local g_t_suncalender_longitude = { { [[1]], TXT( [[{?235:734?}]]) },
{ [[-1]], TXT( [[{?235:743?}]]) }
}
local g_default_astro_timer = { ["sunrisetime"] = {["duration_minutes"] =0,["duration_timetype"]="u",["offset_minutes"]=0, ["offset_timetype"] = "u"},
["sunsettime"] = {["duration_minutes"] =0,["duration_timetype"] ="u",["offset_minutes"]=0, ["offset_timetype"] = "u"}
}
local function is_valid_timer_item( timer_item)
local l_ret = true
if (( timer_item.action == nil) or
( timer_item.time == nil) or
( timer_item.start == nil) or
( timer_item.loop == nil)) then
l_ret = false
end
return l_ret
end
local function get_cal_state_text( n_cal_state)
local sz_retcode = TXT([[{?235:1?}]])..tostring(n_cal_state)..TXT([[{?235:549?}]])
if ( tostring(n_cal_state) == "1") then
sz_retcode = TXT([[{?235:347?}]])
elseif ( tostring(n_cal_state) == "2") then
sz_retcode = TXT([[{?235:654?}]])
elseif ( tostring(n_cal_state) == "11") then
sz_retcode = TXT([[{?235:483?}]])
elseif ( tostring(n_cal_state) == "10") then
sz_retcode = TXT([[{?235:8?}]])
elseif ((tostring(n_cal_state) == "8") or ( tostring(n_cal_state) == "12")) then
sz_retcode = TXT([[{?235:485?}]])
elseif ((tostring(n_cal_state) == "16") or ( tostring(n_cal_state) == "17") or ( tostring(n_cal_state) == "18") or ( tostring(n_cal_state) == "19") or
(tostring(n_cal_state) == "20") or ( tostring(n_cal_state) == "21") or ( tostring(n_cal_state) == "22")) then
sz_retcode = TXT([[{?235:92?}]])..tostring(n_cal_state)..TXT([[{?235:554?}]])
end
return sz_retcode
end
local function get_timer_daily( n_start_time, n_end_time)
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
local function is_daily_switch_on( t_timer_setup)
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
local function is_daily_switch_off( t_timer_setup)
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
local function get_timer_weekly()
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
local function get_timer_zufall( n_start_day, n_end_day, n_start_time, n_end_time, n_duration)
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
local function get_timer_rythmisch( n_off_at, n_on_at)
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
local function get_timer_single( n_start_day, n_end_day)
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
local function get_timer_sun_calendar( n_id, sun_calendar_timer)
local l_ret_timer = {}
local l_astro_timer = g_default_astro_timer
if ( tonumber( n_id) == nil) then
l_ret_timer = aha.HelperSetAstroTimer( tonumber(0), l_astro_timer)
else
l_ret_timer = aha.HelperSetAstroTimer( tonumber( n_id), l_astro_timer)
end
end
local function get_timer_calendar()
local l_ret_timer = {}
l_ret_timer.enabled = 0
return l_ret_timer
end
local function get_day_id( time_value)
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
local function get_entries_per_day( start_index, t_timer_state)
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
local function build_struct_per_day( n_start_index, n_entry_count, t_timer_state, n_day_id)
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
local function write_weekly_js_struct( t_timer_state)
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
local function compare_t_item( value_1, value_2)
if ( value_1.time < value_2.time) then
return true
end
return false
end
local function overwrite_timer_values_of( t_timer_org, t_timer_new)
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
local function read_weekly_timer_data( t_post)
local l_ret_timer = {}
local n_i = tonumber(#l_ret_timer)
for name, value in pairs(t_post) do
if string.sub(name, 1, 11)=="timer_item_" and string.sub(name,-2)~="_i" then
local l_time, l_action, l_daybits = string.match( tostring(value),"(%d*);(%d*);(%d*)")
for day=1, 7 do
local day_time = 1440
if ( math.floor(l_daybits / 2^(day-1)) % 2 == 1 ) then
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
local function get_switch_timer_values( sz_value_to_compare, t_timer_state)
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
function ha_switch_timer._get_timerctrl_id()
return g_sz_timer_id
end
function ha_switch_timer.init_js_section( device_id, b_use_timer_ctrl, sz_timer_ctrl_id, device_timer_state, n_master_id)
box.out([[var g_timer = null;
]])
box.out([[var g_hasTimerCtrl = false;
]])
if ( b_use_timer_ctrl) then
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( [[weekly]], device_id, device_timer_state)
local l_weekly_data = write_weekly_js_struct( l_timer_values)
box.out([[g_hasTimerCtrl = true;
]])
box.out( [[var g_TimerCtrl_ID = "]]..box.tojs( sz_timer_ctrl_id)..[[";
]])
box.out([[ var g_data = [
]]..tostring(l_weekly_data[1])..[[,
]]..tostring(l_weekly_data[2])..[[,
]]..tostring(l_weekly_data[3])..[[,
]]..tostring(l_weekly_data[4])..[[,
]]..tostring(l_weekly_data[5])..[[,
]]..tostring(l_weekly_data[6])..[[,
]]..tostring(l_weekly_data[7])..[[
];
]])
end
local l_timer_values_single = ha_switch_timer.get_switch_timer_values_of( "single", device_timer_state)
local g_current_single_date_values = aha.GetGlobTimeDate( l_timer_values_single[1].time)
local l_timer_values_zufall = ha_switch_timer.get_switch_timer_values_of( "zufall", device_timer_state)
local g_current_zufall_from_date_values = aha.GetGlobTimeDate( l_timer_values_zufall[1].time)
local g_current_zufall_to_date_values = aha.GetGlobTimeDate( l_timer_values_zufall[2].time)
local l_is_net_device = ha_func_lib.is_network_device( device_id)
box.out( [[var g_IsNetworkDevice = ]]..box.tojs(l_is_net_device)..[[;
]])
box.out( [[var g_current_single_date_year = "]]..box.tojs( g_current_single_date_values.Year)..[[";
]])
box.out( [[var g_current_single_date_month = "]]..box.tojs( g_current_single_date_values.Month)..[[";
]])
box.out( [[var g_current_single_date_day = "]]..box.tojs( g_current_single_date_values.Day)..[[";
]])
box.out( [[var g_current_single_time_hh = "]]..box.tojs( g_current_single_date_values.Hour)..[[";
]])
box.out( [[var g_current_single_time_mm = "]]..box.tojs( g_current_single_date_values.Minute)..[[";
]])
box.out( [[var g_current_zufall_from_date_year = "]]..box.tojs( g_current_zufall_from_date_values.Year)..[[";
]])
box.out( [[var g_current_zufall_from_date_month = "]]..box.tojs( g_current_zufall_from_date_values.Month)..[[";
]])
box.out( [[var g_current_zufall_from_date_day = "]]..box.tojs(g_current_zufall_from_date_values.Day)..[[";
]])
box.out( [[var g_current_zufall_from_time_hh = "]]..box.tojs( g_current_zufall_from_date_values.Hour)..[[";
]])
box.out( [[var g_current_zufall_from_time_mm = "]]..box.tojs( g_current_zufall_from_date_values.Minute)..[[";
]])
box.out( [[var g_current_zufall_to_date_year = "]]..box.tojs( g_current_zufall_to_date_values.Year)..[[";
]])
box.out( [[var g_current_zufall_to_month = "]]..box.tojs( g_current_zufall_to_date_values.Month)..[[";
]])
box.out( [[var g_current_zufall_to_day = "]]..box.tojs( g_current_zufall_to_date_values.Day)..[[";
]])
box.out( [[var g_current_zufall_to_time_hh = "]]..box.tojs( g_current_zufall_to_date_values.Hour)..[[";
]])
box.out( [[var g_current_zufall_to_time_mm = "]]..box.tojs( g_current_zufall_to_date_values.Minute)..[[";
]])
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( device_timer_state)
box.out( [[var g_szTimerUse = "]]..box.tojs( l_sz_name)..[[";
]])
box.out( [[var g_nLastCalendarState = "]]..box.tojs( g_last_calender_state)..[[";
]])
box.out( [[var g_nMasterDeviceID = ]]..box.tojs( n_master_id)..[[;
]])
end
function ha_switch_timer.list_of_current_state_group_member( sz_group_name, t_post)
l_t_retcode = {}
local l_devicelist = aha.GetDeviceList()
if ( l_devicelist ~= nil and #l_devicelist > 0 ) then
for i=1, #l_devicelist do
if (( ha_func_lib.is_outlet(l_devicelist[i].FunctionBitMask)) and
( not( ha_func_lib.is_virtual_group_device( l_devicelist[i].DeviceType, l_devicelist[i].FunctionBitMask))) ) then
local sz_groupname_to_store = [[]]
local n_device_id = l_devicelist[i].ID
local l_is_group_member = false
if ( (t_post["selected_group_device_"..tostring(n_device_id)] ~= nil) and (tostring( t_post["selected_group_device_"..tostring(n_device_id)]) == tostring(n_device_id))) then
l_is_group_member = true
else
l_is_group_member = false
end
table.insert( l_t_retcode,{ DeviceID=tostring(n_device_id), IsMember=tostring(l_is_group_member)} )
end
end
end
return l_t_retcode
end
function ha_switch_timer.table_of_selectable_device( t_content)
local l_t_retcode = {}
if ( t_content ~= nil and #t_content > 0 ) then
table.insert( l_t_retcode, { tostring(0), g_sz_text_userdefined} )
for i=1, #t_content do
if (( ha_func_lib.is_outlet(t_content[i].FunctionBitMask)) and
( not( ha_func_lib.is_virtual_group_device( t_content[i].DeviceType, t_content[i].FunctionBitMask))) ) then
table.insert( l_t_retcode, { tostring(t_content[i].ID), tostring(t_content[i].Name)} )
end
end
end
return l_t_retcode
end
function ha_switch_timer.is_calendar_enabled( n_device_id)
l_ret_code = false
if ( n_device_id ~= nil) then
local l_t_timer = aha.GetSwitchTimer( tonumber( n_device_id))
local l_b_timer, l_timer_calendar = get_switch_timer_values( "calendar", l_t_timer)
if ( l_b_timer == true) then
l_ret_code = ( tostring(l_timer_calendar.enabled) == "1")
end
end
return l_ret_code
end
function ha_switch_timer.get_url_for_oncal_register( n_device_id, sz_query_node, sz_last_selected_timer)
local l_param = [[?device=]]..tonumber(n_device_id)
l_param = l_param..[[&cal_node=]]..tostring(sz_query_node)
l_param = l_param..[[&last_timer=]]..tostring(sz_last_selected_timer)
return [[/net/home_auto_install_gcal.lua]]..tostring(l_param)
end
function ha_switch_timer.get_switch_timer_values_of( sz_value_to_compare, n_id, t_timer_state)
local l_ret_timer = {}
local l_b_timer_exist = false
local l_b_timer_exit, l_ret_timer = get_switch_timer_values( sz_value_to_compare, t_timer_state)
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
l_ret_timer = get_timer_sun_calendar( n_id)
elseif ( sz_value_to_compare=="calendar") then
l_ret_timer = get_timer_calendar()
end
end
return l_ret_timer
end
function ha_switch_timer.set_current_timer_inactive( n_id, t_current_timer)
local l_b_cal_was_enabled = false
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( t_current_timer)
local l_sz_last_enabled_timer = l_sz_name
local l_timer_weekly = ha_switch_timer.get_switch_timer_values_of( [[weekly]], n_id, t_current_timer)
local l_timer_daily = ha_switch_timer.get_switch_timer_values_of( [[daily]], n_id, t_current_timer)
local l_timer_zufall = ha_switch_timer.get_switch_timer_values_of( [[zufall]], n_id, t_current_timer)
local l_timer_countdown = ha_switch_timer.get_switch_timer_values_of( [[countdown]], n_id, t_current_timer)
local l_timer_rythmisch = ha_switch_timer.get_switch_timer_values_of( [[rythmisch]], n_id, t_current_timer)
local l_timer_single = ha_switch_timer.get_switch_timer_values_of( [[single]], n_id, t_current_timer)
local l_timer_sun_calendar = ha_switch_timer.get_switch_timer_values_of( [[sun_calendar]], n_id, t_current_timer)
local l_timer_calendar = ha_switch_timer.get_switch_timer_values_of( [[calendar]], n_id, t_current_timer)
l_b_cal_was_enabled = ( tostring(l_timer_calendar.enabled) == "1")
l_timer_daily.enabled = 0
l_timer_weekly.enabled = 0
l_timer_zufall.enabled = 0
l_timer_countdown.enabled = 0
l_timer_rythmisch.enabled = 0
l_timer_single.enabled = 0
if ( l_timer_sun_calendar == nil) then
l_timer_sun_calendar = {}
end
l_timer_sun_calendar.enabled = 0
l_timer_calendar.enabled = 0
aha.SetSwitchTypeTimer(tonumber(n_id),[[weekly]], l_timer_weekly)
aha.SetSwitchTypeTimer(tonumber(n_id),[[daily]], l_timer_daily)
aha.SetSwitchTypeTimer(tonumber(n_id),[[zufall]], l_timer_zufall)
aha.SetSwitchCountdownRule(tonumber(n_id),0, 0)
aha.SetSwitchTypeTimer(tonumber(n_id),[[rythmisch]], l_timer_rythmisch)
aha.SetSwitchTypeTimer(tonumber(n_id),[[single]], l_timer_single)
aha.SetSwitchTypeTimer(tonumber(n_id),[[sun_calendar]], l_timer_sun_calendar)
aha.SetSwitchTypeTimer(tonumber(n_id),[[calendar]], l_timer_calendar)
return l_sz_last_enabled_timer, l_b_cal_was_enabled
end
function ha_switch_timer.save_timer_weekly( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[weekly]]) then
local l_timer_weekly = ha_switch_timer.get_switch_timer_values_of( [[weekly]], tonumber(device.ID), t_device_timer)
local l_timer_data = read_weekly_timer_data( box.post) --(t_post)
l_timer_weekly = overwrite_timer_values_of( l_timer_weekly, l_timer_data)
l_timer_weekly.enabled = 1
aha.SetSwitchTypeTimer(tonumber(device.ID), [[weekly]], l_timer_weekly)
end
end
function ha_switch_timer.save_timer_daily( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[daily]]) then
local l_timer_daily = ha_switch_timer.get_switch_timer_values_of( [[daily]], tonumber(device.ID), t_device_timer)
local l_starttime = nil
local l_endtime = nil
if ( (t_post.switch_on_action_daily) and (t_post.switch_on_action_daily == "1")) then
l_starttime = tonumber( t_post.daily_from_hh)*60 + tonumber( t_post.daily_from_mm)
end
if ( (t_post.switch_off_action_daily) and (t_post.switch_off_action_daily == "1")) then
l_endtime = tonumber( t_post.daily_to_hh)*60 + tonumber( t_post.daily_to_mm)
end
local timer = get_timer_daily( l_starttime, l_endtime)
l_timer_daily = overwrite_timer_values_of( l_timer_daily, timer)
l_timer_daily.enabled = 1
aha.SetSwitchTypeTimer(tonumber( device.ID), [[daily]], l_timer_daily)
end
end
function ha_switch_timer.save_timer_zufall( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[zufall]]) then
local l_timer_zufall = ha_switch_timer.get_switch_timer_values_of( [[zufall]], tonumber(device.ID), t_device_timer)
local l_year = tonumber( t_post.zufall_from_date_year)
local l_month = tonumber( t_post.zufall_from_date_month)
local l_day = tonumber( t_post.zufall_from_date_day)
local l_startday = aha.GetGlobTimeMinute( l_year, l_month, l_day, tonumber( t_post.zufall_from_time_hh), tonumber( t_post.zufall_from_time_mm))
l_year = tonumber( t_post.zufall_to_date_year)
l_month = tonumber( t_post.zufall_to_date_month)
l_day = tonumber( t_post.zufall_to_date_day)
local l_endday = aha.GetGlobTimeMinute( l_year, l_month, l_day, tonumber( t_post.zufall_to_time_hh), tonumber( t_post.zufall_to_time_mm))
local l_starttime = tonumber( t_post.zufall_from_time_hh)*60 + tonumber( t_post.zufall_from_time_mm)
local l_endtime = tonumber( t_post.zufall_to_time_hh)*60 + tonumber( t_post.zufall_to_time_mm)
local l_duration = tonumber( t_post.zufall_duration_switch)
timer = get_timer_zufall( l_startday.Minute, l_endday.Minute, l_starttime, l_endtime, l_duration)
l_timer_zufall = overwrite_timer_values_of( l_timer_zufall, timer )
l_timer_zufall.enabled = 1
aha.SetSwitchTypeTimer(tonumber( device.ID), [[zufall]], l_timer_zufall)
end
end
function ha_switch_timer.save_timer_countdown( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[countdown]]) then
local t_countdown_rule = aha.GetSwitchCountdownRule( tonumber(device.ID))
if ( tonumber(t_post.countdown_manuell_on) == 0) then
t_countdown_rule.OnOff = 0
t_countdown_rule.Seconds = ( tonumber( t_post.countdown_time_dd_off)*3600) + (tonumber( t_post.countdown_time_mm_off)*60)
else
t_countdown_rule.OnOff = 1
t_countdown_rule.Seconds = ( tonumber( t_post.countdown_time_dd_on)*3600) + (tonumber( t_post.countdown_time_mm_on)*60)
end
aha.SetSwitchCountdownRule(tonumber( device.ID),t_countdown_rule.OnOff, t_countdown_rule.Seconds)
end
end
function ha_switch_timer.save_timer_rythmisch( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[rythmisch]]) then
local l_timer_rythmisch = ha_switch_timer.get_switch_timer_values_of( [[rythmisch]], tonumber(device.ID), t_device_timer)
local l_switch_off_after = tonumber( t_post.rythmisch_switch_state_on)
local l_switch_on_after = tonumber( t_post.rythmisch_switch_state_off)
local timer = get_timer_rythmisch( l_switch_off_after, l_switch_on_after)
l_timer_rythmisch = overwrite_timer_values_of( l_timer_rythmisch, timer)
l_timer_rythmisch.enabled = 1
local l_virtual_member_id = ha_func_lib.get_virtual_id_by_hash( device.GroupHash)
if ( l_virtual_member_id ~= nil) then
aha.SetSwitchOnOff( tonumber( l_virtual_member_id), 1)
else
aha.SetSwitchOnOff( tonumber( device.ID), 1)
end
aha.SetSwitchTypeTimer(tonumber( device.ID), [[rythmisch]], l_timer_rythmisch)
end
end
function ha_switch_timer.save_timer_single( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[single]]) then
local l_timer_single = ha_switch_timer.get_switch_timer_values_of( [[single]], tonumber(device.ID), t_device_timer)
local l_year = tonumber( t_post.single_date_year)
local l_month = tonumber( t_post.single_date_month)
local l_day = tonumber( t_post.single_date_day)
local l_hour = tonumber( t_post.single_time_hh)
local l_minute = tonumber( t_post.single_time_mm)
local l_starttime = aha.GetGlobTimeMinute( l_year, l_month, l_day, l_hour, l_minute)
local l_endtime = 0
local timer = {}
if ( tonumber( t_post.single_switch_duration) ~= -1) then
l_endtime = l_starttime.Minute + tonumber( t_post.single_switch_duration)
timer = get_timer_single( l_starttime.Minute, l_endtime)
if ( tonumber(t_post.switch_on_action_single) == 0) then
timer[1].action = 0
timer[2].action = 1
end
else
timer = get_timer_single( l_starttime.Minute, l_endtime)
timer[1].loop = 0
if ( tonumber(t_post.switch_on_action_single) == 0) then
timer[1].action = 0
end
end
l_timer_single = overwrite_timer_values_of( l_timer_single, timer)
l_timer_single.enabled = 1
aha.SetSwitchTypeTimer(tonumber( device.ID), [[single]], l_timer_single)
end
end
function ha_switch_timer.save_timer_sun_calendar( sz_timer_state, device, t_device_timer, t_post)
if ( tostring(sz_timer_state) == [[sun_calendar]]) then
local l_timer_sun_calendar = ha_switch_timer.get_switch_timer_values_of( [[sun_calendar]], tonumber(device.ID), t_device_timer)
if ( l_timer_sun_calendar == nil) then
l_timer_sun_calendar = {}
end
l_t_Location = {}
local l_n_degree = tostring(t_post.sun_latitude_degree)
n_result = string.find(l_n_degree, '°')
if ( n_result ~= nil) then
l_n_degree = string.sub(l_n_degree, 1, (tonumber( n_result)-1))
end
local sz_degree, n_count = string.gsub(l_n_degree, [[,]], [[.]])
l_t_Location.Latitude = tonumber(sz_degree)
l_n_degree = tostring(t_post.sun_longitude_degree)
n_result = string.find(l_n_degree, '°')
if ( n_result ~= nil) then
l_n_degree = string.sub(l_n_degree, 1, (tonumber( n_result)-1))
end
sz_degree, n_count = string.gsub(l_n_degree, [[,]], [[.]])
l_t_Location.Longitude = tonumber(sz_degree)
local l_sunrise_time = 0
local l_sunset_time = 0
local l_astro_timer = aha.HelperGetAstroTimer( tonumber(device.ID), l_timer_sun_calendar)
if ( (t_post.sun_checkbox_sunrise) and (t_post.sun_checkbox_sunrise == "1")) then
l_astro_timer.sunrisetime.offset_timetype = [[r]]
l_astro_timer.sunrisetime.offset_minutes = tonumber(t_post.sunrise_offset)
local l_sunrise_duration = t_post.sunrise_duration
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
if ( (t_post.sun_checkbox_sunset) and (t_post.sun_checkbox_sunset == "1")) then
l_astro_timer.sunsettime.offset_timetype = [[r]]
l_astro_timer.sunsettime.offset_minutes = tonumber(t_post.sunset_offset)
local l_sunset_duration = t_post.sunset_duration
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
l_timer_sun_calendar = aha.HelperSetAstroTimer( tonumber(device.ID), l_astro_timer)
l_timer_sun_calendar.enabled = 1
aha.SetBoxLocation( l_t_Location)
aha.SetSwitchTypeTimer( tonumber( device.ID), [[sun_calendar]], l_timer_sun_calendar)
end
end
function ha_switch_timer.save_timer_calendar( sz_timer_state, device, t_device_timer, t_post, sz_last_selected_timer)
local l_t_saveset = {}
local l_regsiter_oncal = false
local l_sz_node = [[]]
if ( tostring(sz_timer_state) == [[calendar]]) then
local l_b_cal_exist = false
local l_sz_devices = ""
local l_timer_calendar = ha_switch_timer.get_switch_timer_values_of( [[calendar]], tonumber(device.ID), t_device_timer)
l_timer_calendar.enabled = tonumber(1)
l_timer_calendar.Calname = tostring( t_post.calendar_google_calendarname)
l_b_cal_exist, l_sz_node, l_sz_devices = ha_func_lib.calendar_always_exist( tostring(l_timer_calendar.Calname))
if ( l_b_cal_exist == true) then
local l_current_oncal_state = box.query( [[oncal:settings/]]..l_sz_node..[[/laststatus]])
local l_devices_new = ha_func_lib.append_to_oncal_devices( tostring(device.ID), l_sz_devices)
if ( tostring( device.GroupHash) ~= "0") then
local l_t_group_member_list = ha_switch_timer.list_of_current_state_group_member( device.Name, t_post)
l_devices_new = ha_func_lib.update_oncal_by_group_member_2(l_t_group_member_list, l_devices_new)
end
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(1))
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_sz_node..[[/deviceid]], l_devices_new)
if (( sz_last_selected_timer == [[calendar]]) and
( ha_func_lib.get_calendar_name( device.ID) ~= l_timer_calendar.Calname)) then
local l_b_exist, l_old_node, l_devices_old = ha_func_lib.calendar_always_exist( tostring(t_device_timer.Calname))
local l_old_devices_new = ha_func_lib.remove_from_oncal_devices( device.ID, l_devices_old)
if (( tostring( device.GroupHash) ~= "0") and
( l_old_devices_new ~= [[]] )) then
local l_t_group_member_list = ha_switch_timer.list_of_current_state_group_member( device.Name, t_post)
if ((l_t_group_member_list ~= nil) and (#l_t_group_member_list > 0)) then
for i=1, #l_t_group_member_list do
if ( l_t_group_member_list[i].IsMember == true) then
l_old_devices_new = ha_func_lib.remove_from_oncal_devices( l_t_group_member_list[i].ID, l_old_devices_new)
end
end
end
end
if ( l_old_devices_new == [[]] ) then
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_old_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_old_node..[[/deviceid]], l_old_devices_new)
end
cmtable.add_var( l_t_saveset, [[oncal:command/do_sync]], [[1]])
else
l_regsiter_oncal = true
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_sz_node..[[/enabled]], tonumber(1))
cmtable.add_var( l_t_saveset, [[oncal:settings/]]..l_sz_node..[[/calname]], tostring(t_post.calendar_google_calendarname))
end
aha.SetSwitchTypeTimer(tonumber(device.ID), [[calendar]], l_timer_calendar)
end
return l_t_saveset, l_regsiter_oncal, l_sz_node
end
function ha_switch_timer.updating_oncal_struture( device, t_device_timer, t_post, t_saveset)
local l_b_exist, l_old_node, l_devices_old = ha_func_lib.calendar_always_exist( tostring(t_device_timer.Calname))
local l_old_devices_new = ha_func_lib.remove_from_oncal_devices( device.ID, l_devices_old)
if (( tostring( device.GroupHash) ~= "0") and ( l_old_devices_new ~= [[]] )) then
local l_t_group_member_list = ha_switch_timer.list_of_current_state_group_member( device.Name, t_post)
if ((l_t_group_member_list ~= nil) and (#l_t_group_member_list > 0)) then
for i=1, #l_t_group_member_list do
if ( l_t_group_member_list[i].IsMember == true) then
l_old_devices_new = ha_func_lib.remove_from_oncal_devices( l_t_group_member_list[i].ID, l_old_devices_new)
end
end
end
end
if ( l_old_devices_new == "") then
cmtable.add_var( t_saveset, [[oncal:settings/]]..l_old_node..[[/enabled]], tonumber(0))
end
cmtable.add_var( t_saveset, [[oncal:settings/]]..l_old_node..[[/deviceid]], l_old_devices_new)
cmtable.add_var( t_saveset, [[oncal:command/do_sync]], [[1]])
return t_saveset
end
function ha_switch_timer.write_html_timer_weekly( sz_timer_state, sz_timer_id, device_timer_state)
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_weekly", [[weekly]], ( tostring(sz_timer_state) == [[weekly]]), [[onclick="OnChange_SwitchOnTimeUse('weekly')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_weekly", "LabeluiView_SwitchOnTimeUse_weekly", TXT( [[{?235:897?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_weekly">]])
box.out( [[<p>]]..TXT([[{?235:716?}]])..[[</p>]] )
if config.TIMERCONTROL then
box.out( [[<div id="uiTimerArea" class="formular">]])
timer.write_html( sz_timer_id, {
active = TXT( [[{?235:982?}]]),
inactive = TXT( [[{?235:509?}]])
})
box.out( [[</div>]])
end
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_daily( sz_timer_state, device_id, device_timer_state)
box.out( [[<p>]])
local l_b_select_radio = false
if ( tostring(sz_timer_state) == [[daily]] ) then
l_b_select_radio = true
end
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_daily", [[daily]], l_b_select_radio, [[onclick="OnChange_SwitchOnTimeUse('daily')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_daily", "LabeluiView_SwitchOnTimeUse_daily", TXT([[{?235:401?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_daily">]])
box.out( [[<p>]]..TXT([[{?235:855?}]])..[[</p>]])
box.out( [[<div class="narrow">]])
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( "daily", device_id, device_timer_state)
local l_b_switch_on_checked, l_switch_on_timer = is_daily_switch_on( l_timer_values)
box.out( elem._checkbox( "switch_on_action_daily", "uiView_SwitchOnAction_Daily", "1", (l_b_switch_on_checked == true), [[onclick="OnChange_SwitchOnActionDaily(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_Daily", "LabeluiView_SwitchOnAction_Daily", TXT([[{?235:356?}]]), [[ width: 75px;]]))
box.out( elem._label( "uiView_daily_from_hh", "LabeluiView_daily_from_hh", TXT([[{?235:621?}]]), [[margin-left: 25px; width: 25px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "daily_from_hh", "uiView_daily_from_hh", l_switch_on_timer.hh, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;:&nbsp;]])
box.out( elem._input_plusplus( "text", "daily_from_mm", "uiView_daily_from_mm", ha_func_lib.get_leading_zero(l_switch_on_timer.mm), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_daily_from_mm", "LabeluiView_daily_from_mm", TXT( [[{?235:157?}]]) ))
box.out( [[</div>]])
box.out( [[<div class="narrow">]])
local l_b_switch_off_checked, l_switch_off_timer = is_daily_switch_off( l_timer_values)
box.out( elem._checkbox( "switch_off_action_daily", "uiView_SwitchOffAction_Daily", "1", (l_b_switch_off_checked == true), [[onclick="OnChange_SwitchOffActionDaily(this.checked)"]], [[]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOffAction_Daily", "LabeluiView_SwitchOffAction_Daily", TXT([[{?235:532?}]]), [[ width: 75px;]]))
box.out( elem._label( "uiView_daily_to_hh", "LabeluiView_daily_from_hh", TXT([[{?235:197?}]]), [[margin-left: 25px; width: 25px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "daily_to_hh", "uiView_daily_to_hh", l_switch_off_timer.hh, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;:&nbsp;]])
box.out( elem._input_plusplus( "text", "daily_to_mm", "uiView_daily_to_mm", ha_func_lib.get_leading_zero(l_switch_off_timer.mm), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_daily_to_mm", "LabeluiView_daily_to_mm", TXT([[{?235:595?}]])))
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_zufall( sz_timer_state, device_id, device_timer_state)
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_zufall", [[zufall]], ( tostring(sz_timer_state) == [[zufall]]), [[onclick="OnChange_SwitchOnTimeUse('zufall')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_zufall", "LabeluiView_SwitchOnTimeUse_zufall", TXT( [[{?235:683?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_zufall">]])
box.out( [[<p>]]..TXT( [[{?235:213?}]])..[[</p>]])
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( "zufall", device_id, device_timer_state)
local l_date_values_1 = aha.GetGlobTimeDate( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_from_date_day", "LabeluiView_zufall_from_date_day", TXT( [[{?235:627?}]]) ))
box.out( elem._input_plusplus( "text", "zufall_from_date_day", "uiView_zufall_from_date_day", l_date_values_1.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_from_date_month", "uiView_zufall_from_date_month", l_date_values_1.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_from_date_year", "uiView_zufall_from_date_year", l_date_values_1.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( [[</div>]])
local l_date_values_2 = aha.GetGlobTimeDate( l_timer_values[4].time )
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_to_date_day", "LabeluiView_zufall_to_date_day", TXT( [[{?235:758?}]]) ))
box.out( elem._input_plusplus( "text", "zufall_to_date_day", "uiView_zufall_to_date_day", l_date_values_2.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_to_date_month", "uiView_zufall_to_date_month", l_date_values_2.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "zufall_to_date_year", "uiView_zufall_to_date_year", l_date_values_2.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[<div class="formular mt20">]])
box.out( elem._label( "uiView_zufall_from_time_hh", "LabeluiView_zufall_from_time_hh", TXT([[{?235:3?}]]) ))
box.out( elem._input_plusplus( "text", "zufall_from_time_hh", "uiView_zufall_from_time_hh", math.floor(l_timer_values[2].time/60), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "zufall_from_time_mm", "uiView_zufall_from_time_mm", ha_func_lib.get_leading_zero(math.mod(l_timer_values[2].time, 60)), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_zufall_from_time_mm", "LabeluiView_zufall_from_time_mm", TXT([[{?235:491?}]]) ))
box.out( [[</div>]])
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_zufall_to_time_hh", "LabeluiView_zufall_to_time_hh", TXT( [[{?235:489?}]]) ))
box.out( elem._input_plusplus( "text", "zufall_to_time_hh", "uiView_zufall_to_time_hh", math.floor(l_timer_values[3].time/60), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "zufall_to_time_mm", "uiView_zufall_to_time_mm", ha_func_lib.get_leading_zero(math.mod(l_timer_values[3].time,60)), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_zufall_to_time_mm", "LabeluiView_zufall_to_time_mm", TXT( [[{?235:162?}]]) ))
box.out( [[</div>]])
box.out( [[<div class="formular mt20">]])
box.out( elem._label( "uiView_zufall_from_time_hh", "LabeluiView_zufall_from_time_hh", TXT( [[{?235:550?}]]) ))
local sz_selected = tostring( l_timer_values[5].time)
box.out( elem._select( "zufall_duration_switch", "uiView_zufall_duration_switch", g_t_zufall_switch_duration, sz_selected))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_countdown( sz_timer_state, device_id)
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_countdown", [[countdown]], ( tostring(sz_timer_state) == [[countdown]]), [[onclick="OnChange_SwitchOnTimeUse('countdown')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_countdown", "LabeluiView_SwitchOnTimeUse_countdown", TXT([[{?235:10?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_countdown">]])
local l_timer_values = ha_func_lib.get_countdown_rule( tonumber( device_id))
box.out( [[<p>]]..TXT([[{?235:444?}]]..[[</p>]]))
box.out( [[<p>]])
box.out( elem._radio( "countdown_manuell_on", "uiView_Countdown_Manuell_Off", "0", (tostring(l_timer_values.OnOff) == "0"), [[onclick="OnChange_Countdown_Manuell_On('0')"]], [[]] ))
box.out( [[&nbsp;]])
local l_countdown_time_dd_off = tostring( math.floor( tonumber( l_timer_values.Seconds)/3600) )
local l_countdown_time_mm_off = tostring( math.floor( math.mod( tonumber( l_timer_values.Seconds), 3600)/60 ))
box.out( elem._label( "uiView_Countdown_Manuell_Off", "LabeluiView_Countdown_Manuell_Off", TXT( [[{?235:989?}]]) ))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._input_plusplus( "text", "countdown_time_dd_off", "uiView_countdown_time_dd_off", l_countdown_time_dd_off, "3", "3", [[text-align: right;]], [[]], [[]]))
box.out( elem._label( "uiView_countdown_time_dd_off", "LabeluiView_countdown_time_dd_off_2", TXT( [[{?235:590?}]]) ))
box.out( elem._input_plusplus( "text", "countdown_time_mm_off", "uiView_countdown_time_mm_off", l_countdown_time_mm_off, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_countdown_time_mm_off", "LabeluiView_countdown_time_mm_off", TXT( [[{?235:656?}]]) ))
box.out( [[</p>]])
box.out( [[<p class="mt20">]]..TXT( [[{?235:936?}]])..[[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "countdown_manuell_on", "uiView_Countdown_Manuell_On", "1", ( tostring(l_timer_values.OnOff) == "1"), [[onclick="OnChange_Countdown_Manuell_On('1')"]], [[]] ))
box.out( [[&nbsp;]])
local l_countdown_time_dd_on = tostring( math.floor( tonumber( l_timer_values.Seconds)/3600) )
local l_countdown_time_mm_on = tostring( math.floor( math.mod( tonumber( l_timer_values.Seconds), 3600)/60 ))
box.out( elem._label( "uiView_Countdown_Manuell_On", "LabeluiView_Countdown_Manuell_On", TXT([[{?235:844?}]]) ))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._input_plusplus( "text", "countdown_time_dd_on", "uiView_countdown_time_dd_on", l_countdown_time_dd_on, "3", "3", [[text-align: right;]], [[]], [[]]))
box.out( elem._label( "uiView_countdown_time_dd_on", "LabeluiView_countdown_time_dd_on_2", TXT( [[{?235:62?}]]) ))
box.out( elem._input_plusplus( "text", "countdown_time_mm_on", "uiView_countdown_time_mm_on", l_countdown_time_mm_on, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_countdown_time_mm_on", "LabeluiView_countdown_time_mm_on", TXT( [[{?235:189?}]]) ))
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_rythmisch( sz_timer_state, device_id, device_timer_state)
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_rythmisch", [[rythmisch]], ( tostring(sz_timer_state) == [[rythmisch]]), [[onclick="OnChange_SwitchOnTimeUse('rythmisch')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_rythmisch", "LabeluiView_SwitchOnTimeUse_rythmisch", TXT([[{?235:377?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_rythmisch">]])
box.out( [[<p>]]..TXT([[{?235:9444?}]])..[[</p>]])
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( "rythmisch", device_id, device_timer_state)
local sz_selected_rythmisch_on = tostring( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_rythmisch_switch_state_on", "LabeluiView_rythmisch_switch_state_on", TXT([[{?235:684?}]]) ))
box.out( elem._select( "rythmisch_switch_state_on", "uiView_rythmisch_switch_state_on", g_t_rythmisch_switch_duration, sz_selected_rythmisch_on))
box.out( [[&nbsp;]])
box.out( [[</div>]])
local sz_selected_rythmisch_off = tostring( l_timer_values[2].time)
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_rythmisch_switch_state_off", "LabeluiView_rythmisch_switch_state_off", TXT([[{?235:890?}]]) ))
box.out( elem._select( "rythmisch_switch_state_off", "uiView_rythmisch_switch_state_off", g_t_rythmisch_switch_duration, sz_selected_rythmisch_off))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_single( sz_timer_state, device_id, device_timer_state)
box.out( [[<p>]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_single", [[single]], ( tostring(sz_timer_state) == [[single]]), [[onclick="OnChange_SwitchOnTimeUse('single')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_single", "LabeluiView_SwitchOnTimeUse_single", TXT( [[{?235:837?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_single">]])
box.out( [[<p>]]..TXT( [[{?235:124?}]])..[[</p>]])
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( "single", device_id, device_timer_state)
local l_date_values = aha.GetGlobTimeDate( l_timer_values[1].time)
box.out( [[<div class="formular">]])
box.out( elem._radio( "switch_on_action_single", "uiView_SwitchOnAction_single_1", "1", (l_timer_values[1].action == 1), [[onclick="OnChange_SwitchOnActionSingle('1')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_single_1", "LabeluiView_SwitchOnAction_single_1", TXT([[{?235:588?}]]) ))
box.out( [[&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]])
box.out( elem._radio( "switch_on_action_single", "uiView_SwitchOnAction_single_0", "0", (l_timer_values[1].action == 0), [[onclick="OnChange_SwitchOnActionSingle('0')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnAction_single_0", "LabeluiView_SwitchOnAction_single_0", TXT([[{?235:312?}]]) ))
box.out( [[<div class="narrow mt10">]])
box.out( elem._label( "uiView_single_date_day", "LabeluiView_single_date_day", TXT( [[{?235:807?}]]), [[width: 40px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "single_date_day", "uiView_single_date_day", l_date_values.Day, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "single_date_month", "uiView_single_date_month", l_date_values.Month, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[.]])
box.out( elem._input_plusplus( "text", "single_date_year", "uiView_single_date_year", l_date_values.Year, "6", "4", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="narrow">]])
box.out( elem._label( "uiView_single_time_hh", "LabeluiView_single_time_hh", TXT([[{?235:154?}]]), [[width: 40px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "single_time_hh", "uiView_single_time_hh",l_date_values.Hour, "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[:]])
box.out( elem._input_plusplus( "text", "single_time_mm", "uiView_single_time_mm", ha_func_lib.get_leading_zero(l_date_values.Minute), "3", "2", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="narrow mt10">]])
local sz_selected_single_duration = tostring(-1)
if ((l_timer_values[1].loop == 1) and (l_timer_values[2] ~= nil)) then
sz_selected_single_duration = tostring( l_timer_values[2].time - l_timer_values[1].time)
end
box.out( elem._label( "uiView_single_switch_duration", "LabeluiView_single_switch_duration", TXT( [[{?235:939?}]]), [[width: 70px;]], [[timesSettings_daily]]))
box.out( elem._select( "single_switch_duration", "uiView_single_switch_duration", g_t_single_switch_duration, sz_selected_single_duration))
box.out( [[&nbsp;]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
function ha_switch_timer.write_html_timer_sun_calendar( sz_timer_state, device_id, device_timer_state)
box.out( [[<p>]])
local l_select_style = [[width: 230px; text-align: left; margin: 3px 0px 0px 0px;]]
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_sun_calendar", [[sun_calendar]], ( tostring(sz_timer_state) == [[sun_calendar]]), [[onclick="OnChange_SwitchOnTimeUse('sun_calendar')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_sun_calendar", "LabeluiView_SwitchOnTimeUse_sun_calendar", TXT( [[{?235:244?}]]) ))
box.out( [[<div class="formular" id="uiShow_TimerSetup_astro">]])
box.out( [[<p>]]..TXT( [[{?235:255?}]])..[[</p>]])
local l_t_coord_values = aha.GetBoxLocation()
box.out( [[<div>]])
box.out( [[<p><a class="nocancel" href="javascript:OnClick_StartGeoLocation();" >]]..TXT([[{?235:886?}]])..[[</a> ]]..TXT([[{?235:685?}]])..[[</p>]] )
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_sun_latitude_min", "LabeluiView_sun_latitude_mi", TXT( [[{?235:15?}]]), [[width: 75px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "sun_latitude_degree", "uiView_sun_latitude_degree", ha_func_lib.value_as_float(l_t_coord_values.Latitude, 4), "8", "8", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[<div class="formular">]])
box.out( elem._label( "uiView_sun_longitude_min", "LabeluiView_sun_longitude_mi", TXT( [[{?235:1673?}]]), [[width: 75px;]], [[timesSettings_daily]]))
box.out( elem._input_plusplus( "text", "sun_longitude_degree", "uiView_sun_longitude_degree", ha_func_lib.value_as_float(l_t_coord_values.Longitude, 4), "8", "9", [[text-align: right;]], [[]], [[]]))
box.out( [[</div>]])
box.out( [[</div>]])
local l_timer_values = ha_switch_timer.get_switch_timer_values_of( "sun_calendar", device_id, device_timer_state)
local l_astro_timer = {}
if ( tonumber( device_id) == nil) or (l_timer_values == nil)then
l_astro_timer = g_default_astro_timer
else
l_astro_timer = aha.HelperGetAstroTimer( tonumber( device_id), l_timer_values)
end
box.out( [[<div class="formular">]])
box.out( [[<p>]])
local l_sunrise_active = (l_astro_timer.sunrisetime.duration_timetype ~= "u") and (l_astro_timer.sunrisetime.offset_timetype ~= "u")
box.out( elem._checkbox( "sun_checkbox_sunrise", "uiView_CheckboxSunrise", "1", l_sunrise_active, [[onclick="OnChange_Sunrise(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_CheckboxSunrise", "LabeluiView_CheckboxSunrise",TXT([[{?235:109?}]]) ))
box.out( [[<div class="formular" id="uiShow_Sunrise">]])
box.out( elem._label( "uiView_Sunrise_Offset", "LabeluuiView_Sunrise_Offset", TXT( [[{?235:1367?}]]) ))
box.out( elem._select_plus( "sunrise_offset", "uiView_Sunrise_Offset", g_t_sunrise_offset, tostring(l_astro_timer.sunrisetime.offset_minutes), nil, l_select_style, [[]]))
box.out( [[<br />]])
box.out( elem._label( "uiView_Sunrise_Duration", "LabeluuiView_Sunrise_Duration", TXT( [[{?235:985?}]]) ))
local l_sunrise_duration_value = tostring(l_astro_timer.sunrisetime.duration_timetype)..[[#]]..tostring((l_astro_timer.sunrisetime.duration_minutes - l_astro_timer.sunrisetime.offset_minutes))
if ( tostring(l_astro_timer.sunrisetime.duration_timetype) == "d") or ( tonumber(l_astro_timer.sunrisetime.duration_minutes ) == 4095) then
l_sunrise_duration_value = tostring(l_astro_timer.sunrisetime.duration_timetype)..[[#]]..tostring(l_astro_timer.sunrisetime.duration_minutes )
end
box.out( elem._select_plus( "sunrise_duration", "uiView_Sunrise_Duration", g_t_sunrise_switch_duration, l_sunrise_duration_value, nil, l_select_style))
box.out( [[</div>]])
local l_sunset_active = (l_astro_timer.sunsettime.duration_timetype ~= "u") and (l_astro_timer.sunsettime.offset_timetype ~= "u")
box.out( elem._checkbox( "sun_checkbox_sunset", "uiView_CheckboxSunset", "1", l_sunset_active, [[onclick="OnChange_Sunset(this.checked)"]], [[]]))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_CheckboxSunset", "LabeluiView_CheckboxSunset", TXT([[{?235:771?}]]) ))
box.out( [[<div class="formular" id="uiShow_Sunset">]])
box.out( elem._label( "uiView_Sunset_Offset", "LabeluuiView_Sunset_Offset", TXT( [[{?235:854?}]]) ))
box.out( elem._select_plus( "sunset_offset", "uiView_Sunset_Offset", g_t_sunset_offset, tostring(l_astro_timer.sunsettime.offset_minutes), nil, l_select_style, [[]]))
box.out( [[<br />]])
box.out( elem._label( "uiView_Sunset_Duration", "LabeluiView_Sunset_Duration", TXT([[{?235:357?}]]) ))
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
end
function ha_switch_timer.write_html_timer_calendar( sz_timer_state, device_id, device_timer_state)
box.out( [[<p id="uiEnable_Google_Cal">]])
box.out( elem._radio( "switch_on_timer", "uiView_SwitchOnTimeUse_calendar", [[calendar]], ( tostring(sz_timer_state) == [[calendar]]), [[onclick="OnChange_SwitchOnTimeUse('calendar')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_SwitchOnTimeUse_calendar", "LabeluiView_SwitchOnTimeUse_calendar", TXT([[{?235:8789?}]]) ))
box.out( [[<div class="wide" id="uiShow_TimerSetup_calendar">]])
box.out( [[<div class="formular">]])
box.out( [[<p id="uiView_calendar_google_Text_1">]]..TXT([[{?235:691?}</p>]]) )
if ( ha_func_lib.is_network_device( device_id)) then
box.out( [[<p id="uiView_calendar_google_Text_2">]]..TXT( [[{?235:578?}</p>]]) )
end
local l_calendar_name = ha_func_lib.get_calendar_name( tonumber(device_id))
box.out( [[<div class="formular mt10">]])
box.out( elem._label( "uiView_calendar_google_calendarname", "Label_calendar_google_calendarname", TXT([[{?235:650?}:]]) ))
box.out( elem._input( "text", "calendar_google_calendarname", "uiView_calendar_google_calendarname", l_calendar_name, "24", "50", [[]]))
box.out( [[</div>]])
if ( not (ha_func_lib.is_network_device( g_device_id))) then
local l_b_exist, l_node, l_devices = ha_func_lib.calendar_always_exist( tostring(l_calendar_name))
if ( l_b_exist == true) then
g_last_calender_state = box.query( [[oncal:settings/]]..tostring( l_node)..[[/laststatus]])
local l_last_connect = ""
local l_err_msg_text = ""
local l_timer_values = {}
local l_sz_last_switch = TXT( [[{?235:459?}]])
local l_html_style_1 = [[]]
local l_html_style_2 = [[]]
if ( tonumber( g_last_calender_state) == 0) then
l_last_connect = box.query( [[oncal:settings/]]..tostring( l_node)..[[/lastconnect]])
l_timer_values = ha_switch_timer.get_switch_timer_values_of( [[calendar]], device_id, device_timer_state)
if ((l_timer_values ~= nil) and (l_timer_values[1] ~= nil) and
( l_timer_values[1].time ~= nil) and (l_timer_values[1].time ~= 0)) then
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
box.out( elem._label( "uiView_calendar_google_NextSwitch", "Label_calendar_google_NextSwitch", TXT([[{?235:256?}:]]) ))
box.out( [[<span id="uiView_calendar_google_NextSwitch"]]..tostring(l_html_style_1)..[[>]]..tostring( l_sz_last_switch)..[[</span>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_calendar_google_LastSync", "Label_calendar_google_LastSync", TXT([[{?235:1277?}:]]) ))
box.out( [[<span id="uiView_calendar_google_LastSync"]]..tostring(l_html_style_2)..[[>]]..tostring( l_last_connect)..[[</span>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[<div id ="uiShow_GoogleState_Error" class="formular" ]]..string_op.txt_style_display_none( not(tonumber(g_last_calender_state) ~= 0))..[[>]])
box.out( [[<p>]])
box.out( elem._label( "uiView_calendar_google_CurrentStatus", "Label_calendar_google_CurrentStatus", TXT([[{?235:787?}:]]) ))
box.out( [[<span id="uiView_calendar_google_CurrentStatus" class="error" style="width: 200px;">]]..tostring( l_err_msg_text)..[[</span>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[<div><a id="uiLink_ResetGoogleArea" href="javascript:OnClick_ShowResetGoogleArea();" class="textlink nocancel">]]..TXT([[{?235:880?}]])..[[<img id="uiLink_ResetGoogleArea_Img" src="/css/default/images/link_open.gif" height="12"></a></div>]])
box.out( [[<div id="uiView_ResetGoogleArea" style="display: none;">]])
box.out( [[<p>]]..TXT([[{?235:316?}</p>]]) )
box.out( [[<button id="uiBtn_ResetGoogle_Cal" type="submit" name="reset_google_calender" onclick="return OnClick_ResetGoogleCal()" class="nocancel" style="margin: 0px 20px 0px 25px;">]]..TXT([[{?235:266?}</button>]]) )
box.out( [[</div>]])
end
end
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[</p>]])
end
