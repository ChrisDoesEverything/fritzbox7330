<?lua
g_page_type = "all"
g_page_title = box.tohtml( [[{?8968:884?}]])
g_page_help = "hilfe_home_auto_energy_view.html"
g_page_needs_js=true
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("menu")
require("cmtable")
require("val")
require("general")
require("elem")
require("ha_func_lib")
require("libaha")
g_t_week_days = { [[{?8968:267?}]],
[[{?8968:667?}]],
[[{?8968:27?}]],
[[{?8968:875?}]],
[[{?8968:275?}]],
[[{?8968:494?}]],
[[{?8968:326?}]] }
g_t_month = { [[{?8968:292?}]],
[[{?8968:620?}]],
[[{?8968:155?}]],
[[{?8968:400?}]],
[[{?8968:736?}]],
[[{?8968:230?}]],
[[{?8968:729?}]],
[[{?8968:6621?}]],
[[{?8968:166?}]],
[[{?8968:488?}]],
[[{?8968:842?}]],
[[{?8968:846?}]] }
g_current_box_time = os.time()
g_hastime = (box.query("box:status/localtime") ~= "")
g_tab_type = nil
g_show_type = nil
g_tab_to_compare = nil
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
g_device_defaults = nil
g_multimeter_entry = {}
g_average_values = nil
g_energy_view_tabs = {
{ page = "/net/home_auto_energy_view.lua", text = [[{?8968:650?}]], param = [[sub_tab=watt]] },
{ page = "/net/home_auto_energy_view.lua", text = [[{?8968:660?}]], param = [[sub_tab=kWh]] }
}
if box.get.back_to_page then
back_to_page = box.get.back_to_page
elseif box.post.back_to_page then
back_to_page = box.post.back_to_page
end
if back_to_page==nil or back_to_page=="" then
back_to_page = [[/net/home_auto_overview.lua]]
end
<?include "net/home_auto_x_view_tabs.lua" ?>
function init_page_vars( device, tab_type)
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
local l_average = aha.GetEnergyAverage( tonumber( device))
if ( l_average ~= nil) then
g_average_values = {}
g_average_values[1] = l_average.DayAverage
g_average_values[2] = l_average.MonthAverage
g_average_values[3] = l_average.YearAverage
end
g_device_defaults = aha.GetEnergyDefaults()
g_tab_type = tab_type
g_tab_to_compare = [[sub_tab=]]..tab_type
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
add_param_tab_table( g_energy_view_tabs, ([[&device=]]..device) )
g_page_title = g_page_title..[["]]..tostring(g_device_name)..[["]]
g_show_type = "24h"
if ( g_tab_type == "watt") then
g_show_type = "10"
end
return true
end
function write_local_tabs( tabs_elems, compare_with)
tabs_elems = tabs_elems or {}
if ( #tabs_elems > 1) then
box.out("<ul class=\"tabs\">\n")
for i=1, #tabs_elems do
if ( tabs_elems[i].param == compare_with ) then
box.out("<li class=\"active\">")
else
box.out("<li>")
end
box.out("<a href=\"".. href.get(tabs_elems[i].page, tabs_elems[i].param).. "\">")
box.html( tabs_elems[i].text)
box.out("</a></li>\n")
end
box.out("</ul><div class='clear_float'></div>\n")
end
end
function add_param_tab_table( tabs_elems, param )
if ( tabs_elems ~= nil ) then
for i = 1, #tabs_elems do
tabs_elems[i].param = tabs_elems[i].param .. param
end
end
end
function as_euro( n_value )
return tonumber( n_value ) / 10000 -- der Tarif wird als hundertstel-Cent abgespeichert
end
function as_kilo( n_value )
return tonumber( n_value ) / 1000 -- der CO2-Emission wird als Gramm abgespeichert
end
function get_show_type( sz_type)
if ( sz_type == "10") then
return [[{?8968:676?}]]
elseif ( sz_type == "hour") then
return [[{?8968:852?}]]
elseif ( sz_type == "24h") then
return [[{?8968:88?}]]
elseif ( sz_type == "week") then
return [[{?8968:991?}]]
elseif ( sz_type == "month") then
return [[{?8968:698?}]]
elseif ( sz_type == "year") then
return [[{?8968:600?}]]
end
return "{?8968:901?}"
end
function get_device_power( value)
if ( value == nil) then
return [[-.-]]
end
if ( value == tonumber(0)) then
return value
end
return (value/100)
end
function get_device_voltage( value)
if ( value == nil) then
return [[ -.-]]
end
if ( value == tonumber(0)) then
return value
end
return (((value/1000)*10)/10)
end
function get_device_ampere( value)
if ( value == nil) then
return [[-.-]]
end
if ( value == tonumber(0)) then
return value
end
return (((value/10000)*1000)/1000)
end
function write_consumption_table_header()
local l_szRet = [[<tr>]]
l_szRet = l_szRet..[[<th class="c1">&nbsp;</th>]]
l_szRet = l_szRet..[[<th class="c2">{?8968:232?}</th>]]
l_szRet = l_szRet..[[<th class="c3">{?8968:360?}</th>]]
l_szRet = l_szRet..[[<th class="c4">{?8968:587?}</th>]]
l_szRet = l_szRet..[[</tr>]]
return l_szRet
end
function get_date_values_of_24h(t_current_date)
local t_Retcode = {}
local l_hour = t_current_date.hour
local l_min = t_current_date.min
local l_t_mins_str = ha_func_lib.get_minute_quarter_string( l_min)
local l_start_hour = l_hour
if ( l_start_hour == 24) then
l_start_hour = 0
end
for i=l_start_hour, 23 do
for j=1, #l_t_mins_str do
if (l_t_mins_str[j] == ":00") then
i = i + 1
if ( i == 24 ) then
i = 0
end
end
local l_sz_elem = tostring(i)..l_t_mins_str[j]
table.insert( t_Retcode, l_sz_elem)
end
end
if ( l_start_hour ~= 0) then
local l_end_hour = l_hour - 1;
for i=0, l_end_hour do
for j=1, #l_t_mins_str do
if (l_t_mins_str[j] == ":00") then
i = i + 1
if ( i == 24 ) then
i = 0
end
end
local l_sz_elem = tostring(i)..l_t_mins_str[j]
table.insert( t_Retcode, l_sz_elem)
end
end
end
table.insert( t_Retcode,#t_Retcode,[[{?8968:744?}]])
return t_Retcode
end
function get_date_values_of_week( current_date)
local t_Retcode = {}
local n_hour = tonumber( current_date.hour)
local n_mins = tonumber( current_date.min)
local n_week_day = tonumber( current_date.wday)
local ar_day_set = { [[x]], [[6]], [[12]], [[18]] }
if ( (n_hour <= 5 ) or ((n_hour == 6) and (n_mins == 0)) ) then
ar_day_set = { [[6]], [[12]], [[18]], [[x]]}
elseif ( (n_hour <= 11 ) or ((n_hour == 12) and (n_mins == 0)) ) then
ar_day_set = { [[12]], [[18]], [[x]], [[6]]}
elseif ( (n_hour <= 17 ) or ((n_hour == 18) and (n_mins == 0)) ) then
ar_day_set = { [[18]], [[x]], [[6]], [[12]]}
end
local n_from = tonumber(n_week_day)+1
for i=n_from, 7 do
for j=1, 4 do
local sz_text = ar_day_set[j]
if ( sz_text == "x") then
sz_text = g_t_week_days[i]
end
table.insert( t_Retcode, sz_text)
end
end
for i=1, tonumber(n_week_day) do
for j=1, 4 do
local sz_text = ar_day_set[j]
if ( sz_text == "x") then
sz_text = g_t_week_days[i]
end
table.insert( t_Retcode, sz_text)
end
end
return t_Retcode
end
function get_date_values_of_month( t_current_date)
local t_Retcode = {}
local l_previous_month = t_current_date.month - 1
if ( l_previous_month == 0) then
l_previous_month = 12
end
local l_days = ha_func_lib.get_month_count_of( l_previous_month)
local l_start_day = t_current_date.day + 1
if ( l_days <= 29) then
l_start_day = l_start_day - ( 31 - l_days)
if ( l_previous_month == 2) then
if ((t_current_date.day == 1) and ( l_days == 28)) then
table.insert( t_Retcode,[["30.1."]])
table.insert( t_Retcode,[["31.1."]])
l_start_day = 1
end
if (t_current_date.day == 2) then
table.insert( t_Retcode,[["31.1."]])
l_start_day = 1
end
end
else
l_start_day = l_start_day - ( 31 - l_days)
end
for i=l_start_day, l_days do
local l_elem = tostring(i)..[[.]]..tostring(l_previous_month)..[[.]]
table.insert( t_Retcode, l_elem)
end
for j=1,t_current_date.day do
local l_elem = tostring(j)..[[.]]..tostring(t_current_date.month)..[[.]]
table.insert( t_Retcode, l_elem)
end
return t_Retcode
end
function get_date_values_of_year(t_current_date)
local t_Retcode = {}
for i=(tonumber(t_current_date.month)+1), #g_t_month do
table.insert( t_Retcode, g_t_month[i] )
end
for i=0, tonumber(t_current_date.month) do
table.insert( t_Retcode, g_t_month[i] )
end
return t_Retcode
end
function write_csv_btn( btn_id)
local t_params = {}
l_params = http.url_param("csv", "")..[[&]]..http.url_param("id", g_device_id)..[[&]]..http.url_param("show_type", "")
box.out([[
<a href="]],
href.get(box.glob.script, l_params),
[[">]],
[[<button type="button" name="export" id="]]..btn_id..[[" onclick="OnClick_SaveDataNow(this);">]],
box.tohtml([[{?8968:843?}]]),
[[</button>]],
[[</a>
]])
end
function write_as_csv( n_device_id, sz_showtype)
local sep = ";"
if ( n_device_id ~= nil ) then
local l_device = aha.GetDevice( tonumber(n_device_id))
local sz_aktor_name = string.gsub( l_device.Name, [[ ]], [[_]])
local t_current_date = os.date("*t");
local l_sz_date = tostring(ha_func_lib.get_leading_zero(t_current_date.day))..[[.]]
l_sz_date = l_sz_date..tostring(ha_func_lib.get_leading_zero(t_current_date.month))..[[.]]
l_sz_date = l_sz_date..tostring(t_current_date.year)
l_sz_time = tostring(ha_func_lib.get_leading_zero(t_current_date.hour))..[[:]]
l_sz_time = l_sz_time..tostring(ha_func_lib.get_leading_zero(t_current_date.min))
local l_filename = tostring(sz_aktor_name)
l_filename = l_filename..l_sz_date..[[_]]..l_sz_time
l_filename = l_filename..[[_]]..tostring(sz_showtype)
box.header(
"HTTP/1.0 200 OK\n"
.. "Content-Type: text/csv; charset=utf-8\n"
.. "Content-Disposition: attachment; filename="..tostring( l_filename)..".csv\n\n"
)
box.out([[sep=]], sep, "\n")
local l_line = {
[[{?8968:196?}]],
[[{?8968:826?}]],
[[{?8968:988?}]],
[[{?8968:602?}]],
[[{?8968:313?}]],
[[{?8968:476?}]],
[[{?8968:277?}]],
[[]],
[[{?8968:135?}]],
get_show_type( sz_showtype),
[[]],
[[{?8968:151?}]],
tostring( l_sz_date..[[ ]]..l_sz_time..[[{?8968:344?}]]),
}
box.out(table.concat(l_line, sep), "\n")
local l_energy_defaults = aha.GetEnergyDefaults()
t_data_to_store = {};
t_time_marks = {};
local sz_unit = "W"
if ( sz_showtype ~= nil) then
if ( sz_showtype =="10") then
t_data_to_store = aha.GetSwitchEnergyStat10MinValues( tonumber(n_device_id))
sz_unit = "W"
elseif ( sz_showtype == "hour") then
t_data_to_store = aha.GetSwitchEnergyStatHourValues( tonumber(n_device_id))
sz_unit = "W"
elseif ( sz_showtype == "24h") then
t_data_to_store = aha.GetSwitchEnergyStat24hValues( tonumber(n_device_id))
t_time_marks = get_date_values_of_24h(t_current_date)
sz_unit = "Wh"
elseif ( sz_showtype == "week") then
t_data_to_store = aha.GetSwitchEnergyStatWeekValues( tonumber(n_device_id))
t_time_marks = get_date_values_of_week(t_current_date)
sz_unit = "kWh"
elseif ( sz_showtype == "month") then
t_data_to_store = aha.GetSwitchEnergyStatMonthValues( tonumber(n_device_id))
t_time_marks = get_date_values_of_month(t_current_date)
sz_unit = "kWh"
elseif ( sz_showtype == "year") then
t_data_to_store = aha.GetSwitchEnergyStatYearValues( tonumber(n_device_id))
t_time_marks = get_date_values_of_year(t_current_date)
sz_unit = "kWh"
end
if (t_data_to_store.values ~= nil) then
for i=1, #t_data_to_store.values do
local l_energy_value = tonumber( t_data_to_store.values[((#t_data_to_store.values+1)-i)])
local l_energy_value_kilo = as_kilo( l_energy_value)
if ( sz_unit =="kWh") then
l_energy_value = as_kilo( l_energy_value)
end
line = {
tostring( t_time_marks[i]),
ha_func_lib.value_as_float(tonumber(l_energy_value), 3),
sz_unit,
ha_func_lib.value_as_float(tonumber(l_energy_value_kilo)*as_euro(l_energy_defaults.Tarif), 2),
tostring([[Euro]]),
ha_func_lib.value_as_float(tonumber(l_energy_value_kilo)*as_kilo(l_energy_defaults.CO2Emission), 3),
[[kg CO2]]
}
box.out(table.concat(line, sep), "\n")
end
end
end
end
box.end_page()
end
function write_consumption_table_content( t_content)
local l_szRet = ""
local l_t_strings = { [[{?8968:409?}]], [[{?8968:872?}]], [[{?8968:299?}]]}
if ((t_content ~= nil) and (#t_content > 0 )) then
l_default = aha.GetEnergyDefaults()
for i=1, #t_content do
local l_Str = [[<tr>]]
local n_base_value = tonumber( t_content[i])/1000
l_Str = l_Str..[[<td class="c1">]]..tostring(l_t_strings[i])..[[</td>]]
local l_td_text = ha_func_lib.value_as_float((as_euro(l_default.Tarif)*n_base_value), 2)
l_Str = l_Str..[[<td class="c2">]]..elem._span_plus( [[uiView_TConsumption_Euro]]..tostring(i), l_td_text, true, true)..[[</td>]]
l_td_text = ha_func_lib.value_as_float( n_base_value, 3)
l_Str = l_Str..[[<td class="c3">]]..elem._span_plus( [[uiView_TConsumption_Power]]..tostring(i), l_td_text, true, true)..[[</td>]]
l_td_text = ha_func_lib.value_as_float((as_kilo(l_default.CO2Emission)*n_base_value), 3)
l_Str = l_Str..[[<td class="c4">]]..elem._span_plus( [[uiView_TConsumption_CO2]]..tostring(i), l_td_text, true, true)..[[</td>]]
l_Str = l_Str..[[</tr>]]
l_szRet = l_szRet..l_Str
end
else
l_szRet = [[<tr id="ui_NoInfos"><td colspan="4" class="ta_c">{?8968:139?}</td></tr>]]
end
return l_szRet
end
function is_push_service_active()
require"pushservice"
return ( pushservice.account_configured())
end
function is_ha_push_service_active()
l_t_ps_config = aha.GetPushMailConfig( g_device_id)
if ( (l_t_ps_config ~= nil) and ( l_t_ps_config.activ ~= nil)) then
return ( tostring( l_t_ps_config.activ) == "1")
else
return false
end
end
local l_next_id = nil
local l_next_tab = nil
if ( next(box.get)) then
l_next_id = box.get.device
l_next_tab = box.get.sub_tab
if box.get.csv then
write_as_csv( tonumber(box.get.id), box.get.show_type)
end
else
if ( next(box.post)) then
if (box.post.cancel) then
http.redirect( [[/net/home_auto_overview.lua]])
end
l_next_id = box.post.current_ule
l_next_tab = box.post.sub_tab
end
end
if ( init_page_vars( l_next_id, l_next_tab) == false) then
http.redirect( back_to_page)
end
function get_val_prog()
g_val = {
prog = [[
]]
}
end
get_val_prog()
if ( next(box.post)) then
local l_val_result = val.ret.ok
local saveset = {}
if ( box.post.apply) then
-- g_device_name:save_value( saveset)
end
if ( l_val_result == val.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
if ( box.post.apply) then
http.redirect( [[/net/home_auto_overview.lua]])
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<!-- <link rel="stylesheet" type="text/css" href="/css/default/xxx.css"/> -->
<style type="text/css">
#tHAconsumption {margin: 20px 0px 20px 50px; width: 450px;}
#tHAconsumption td, tHAdevices th {padding: 1px 2px;}
#tHAconsumption .c1 {text-align: left; width: 125px; padding-left:20px;}
#tHAconsumption .c2 {text-align: right; width: 100px;}
#tHAconsumption .c3 {text-align: right; width: 100px;}
#tHAconsumption .c4 {text-align: right; width: 100px; padding-right: 10px;}
.divBar_ShowType {width: 30%; min-height: 50px; padding-top:5px; float: clear; margin-bottom: 10px;}
.divBar_ValueType {width: 30%; min-height: 50px; padding-top:5px; float: right;}
.divBar_SumType {width: 40%; min-height: 50px; padding-top:5px; float: right; margin-right: 10px;}
.divBar_SumType div.btnline {
position: relative;
min-height: 27px;
padding: 5px 0;
}
.divBar_SumType div.btnline span {
position: absolute;
left: 0;
width: 200px;
}
.divBar_SumType div.btnline button,
.divBar_SumType div.btnline a {
position: absolute;
right: 0;
}
.mt5 {margin-top: 5px;}
.mt10 {margin-top: 10px;}
.mt15 {margin-top: 15px;}
.mt20 {margin-top: 20px;}
.ml-30 {margin-left: -30px;}
.ml30 {margin-left: 30px;}
.ta_c {text-align: center;}
.canvas_tooltip {
font-size: 12px;
background-color: #F8FCE9;
position: absolute;
border: 1px solid #000000;
z-index: 2000;
top: 450px;
left: 450px;
text-align: center;
vertical-align: middle;
padding: 1px 2px 1px 2px;
-moz-box-shadow: 3px 2px 5px #484848;
-webkit-box-shadow: 3px 2px 5px #484848;
box-shadow: 3px 2px 5px #484848;
}
.div_tab_header {
background-color: #eeeeee;
min-height: 21px;
display: block;
border: 1px solid #C6C7BE;
border-bottom: 0px solid #000000;
margin: 0px 30px 0px 0px;
padding: 2px 0px 2px 0px;
font-weight. bold;
}
.div_tab_body {
background-color: #ffffff;
min-height: 21px;
display: block;
border: 1px solid #C6C7BE;
border-top: 0px solid #000000;
margin: 0px 30px 0px 0px;
padding: 3px 0px 2px 0px;
vertical-align middle;
display. none;
}
.span_tab-von { margin: 0px 250px 0px 10px; font-weight: bold; vertical-align: middle;}
.span_tab-bis { margin: 0px 250px 0px 0px; font-weight: bold; vertical-align: middle;}
.span_tab-values { float: right; margin-right:10px; font-weight: bold; vertical-align: middle;}
.select_From_Hour_24h { width: 65px; margin: 0px 0px 0px 10px;}
.select_From_Min_24h { width: 65px; margin: 0px 0px 0px 5px;}
.span_tab_From_Min { margin: 0px 112px 0px 5px; vertical-align: middle;}
.select_To_Hour_24h { width: 65px; margin: 0px 0px 0px 0px;}
.select_To_Min_24h { width: 65px; margin: 0px 0px 0px 5px;}
.span_tab_To_Min { margin: 0px 112px 0px 5px; vertical-align: middle;}
span.output.EM_Sum_Value { width: 80px; text-align: right;}
.EM_Sum_Text { margin-left: 3px; font-weight: bold; vertical-align: middle;}
.select_From_Hour_week { width: 135px; margin: 0px 0px 0px 10px;}
.select_From_Min_week { width: 70px; margin: 0px 63px 0px 5px;}
.select_To_Hour_week { width: 135px; margin: 0px 0px 0px 0px;}
.select_To_Min_week { width:70px; margin: 0px 60px 0px 5px;}
.select_From_month { width: 135px; margin: 0px 0px 0px 10px;}
.select_To_month { width: 135px; margin: 0px 135px 0px 138px;}
.select_From_year { width: 135px; margin: 0px 0px 0px 10px;}
.select_To_year { width: 135px; margin: 0px 135px 0px 138px;}
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?8968:336?}</p>
<hr>
<?lua
ha_func_lib.get_device_tab_head( g_device_id, false, false)
box.out( [[<hr>]])
if g_hastime then
box.out( [[<h4>{?8968:92?}]]..tostring( g_device_name)..[["</h4>]])
write_local_tabs( g_energy_view_tabs, (g_tab_to_compare..([[&device=]]..g_device_id)))
box.out( elem._canvas( "uiView_CanvasEnergy", "770", "330", "", "") )
box.out( [[<div id="uiView_CanvasTooltip" class="canvas_tooltip" style="">]])
box.out( elem._span_plus( "uiView_Tooltip_Text", "", false, true))
box.out( [[</div>]])
box.out( [[<div class="formular" style="margin-top:15px;">]])
if ( g_tab_type == "watt") then
box.out( [[ <a id="uiLink_VoltLine" href="javascript: OnClick_VoltLine();" class="textlink nocancel" style="float: right; margin: 7px 29px 0px 0px; display: none;">]]..[[<span id="uiLink_VoltLine_Text">{?8968:907?}]]..[[</span></a>]] )
box.out( [[{?8968:3707?}]] )
box.out( [[<span id="uiView_EnergyStats_Average" class="output" style="float: clear; width: 75px; text-align: right;margin-left: 55px;">]]..get_device_power( tonumber(0))..[[</span>&nbsp;]])
box.out( [[{?8968:272?}&nbsp;]] )
box.out( [[<span id="uiView_EnergyStats_Min" class="output" style="width: 75px; text-align: right;">]]..get_device_power( tonumber(0))..[[</span>&nbsp;]])
box.out( [[{?8968:371?}&nbsp;]] )
box.out( [[<span id="uiView_EnergyStats_Max" class="output" style="width: 75px; text-align: right;">]]..get_device_power( tonumber(0))..[[</span>&nbsp;W]])
box.out( [[<br />{?8968:239?}]] )
box.out( [[<span id="uiView_EnergyStats_Ampere" class="output" style="width: 75px; text-align: right; margin-left: 33px;">]]..get_device_ampere( tonumber(0))..[[</span>&nbsp;A]])
else
box.out( [[<div id="uiView_Area_EM_Sum_Type" class="divBar_SumType">]])
box.out( elem._label( "", "LabeluiView_EM_SumType_From1", [[{?8968:162?}]], [[margin-left:-30px;]]))
box.out([[<div class="btnline">]])
box.out([[<span>]])
box.html([[{?8968:675?}]])
box.out([[</span>]])
box.out([[<button id="uiBtn_PushServiceNow" type="button" name="snd_push_service" onclick="OnClick_PushServiceNow()">]])
box.html([[{?8968:837?}]])
box.out([[</button>]])
box.out([[</div>]])
box.out([[<div class="btnline">]])
box.out([[<span>]])
box.html([[{?8968:580?}]])
box.out([[</span>]])
write_csv_btn( "uiBtn_ExportView")
box.out([[</div>]])
box.out( [[</div>]])
box.out( [[<div id="uiView_Area_EM_Value_Type" class="divBar_ValueType">]])
box.out( elem._label( "uiView_EM_ValueType_Euro", "LabeluiView_EM_ValueType_Euro1", [[{?8968:523?}]], [[width: 75px;]]))
box.out( elem._radio_plus( "em_value_type", "uiView_EM_ValueType_Watt", "2", true, [[margin-left: 0px;]], [[onclick="OnChange_EM_ValueType('2')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_ValueType_Watt", "LabeluiView_EM_ValueType_Watt", [[{?8968:985?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_value_type", "uiView_EM_ValueType_Euro", "1", false, [[margin-left: 81px;]], [[onclick="OnChange_EM_ValueType('1')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_ValueType_Euro", "LabeluiView_EM_ValueType_Euro2", [[{?8968:953?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_value_type", "uiView_EM_ValueType_CO2", "3", false, [[margin-left: 81px;]], [[onclick="OnChange_EM_ValueType('3')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_ValueType_CO2", "LabeluiView_EM_ValueType_CO2", [[{?8968:536?}]]))
box.out( [[</div>]])
end
box.out( [[<div id="uiView_Area_EM_Show_Type" class="divBar_ShowType" style="">]])
box.out( elem._label( "uiView_EM_Show_Type_24h", "LabeluiView_EM_Show_Type_24h1", [[{?8968:657?}]], [[width: 75px;]]))
if ( g_tab_type == "watt") then
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_10", "10", true, [[margin-left: 0px;]], [[onclick="OnChange_EM_ShowType('10')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_10", "LabeluiView_EM_Show_Type_10", [[{?8968:2096?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_hour", "hour", false, [[margin-left: 81px;]], [[onclick="OnChange_EM_ShowType('hour')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_hour", "LabeluiView_EM_Show_Type_hour", [[{?8968:530?}]]))
else
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_24h", "24h", true, [[margin-left: 0px;]], [[onclick="OnChange_EM_ShowType('24h')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_24h", "LabeluiView_EM_Show_Type_24h", [[{?8968:757?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_week", "week", false, [[margin-left: 81px;]], [[onclick="OnChange_EM_ShowType('week')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_week", "LabeluiView_EM_Show_Type_week", [[{?8968:535?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_month", "month", false, [[margin-left: 81px;]],[[onclick="OnChange_EM_ShowType('month')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_month", "LabeluiView_EM_Show_Type_month", [[{?8968:379?}]]))
box.out( [[<br />]])
box.out( elem._radio_plus( "em_show_type", "uiView_EM_Show_Type_year", "year", false, [[margin-left: 81px;]], [[onclick="OnChange_EM_ShowType('year')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "uiView_EM_Show_Type_year", "LabeluiView_EM_Show_Type_year", [[{?8968:978?}]]))
end
box.out( [[</div>]])
local sz_pushmail_now_style = [[]]
-- if ( g_show_type == "10" ) then
sz_pushmail_now_style = [[style="display: none;"]]
-- end
box.out( [[<div id="uiShow_PushMail_Now" ]]..sz_pushmail_now_style..[[ >]])
if ( g_tab_type == "watt") then
box.out( [[{?8968:847?}]])
box.out( [[<button id="uiBtn_PushServiceNow" type="button" name="snd_push_service" style="margin-left: 30px;" onclick="OnClick_PushServiceNow()">{?8968:941?}</button>]])
end
if ( not(is_push_service_active()) or not( is_ha_push_service_active()) ) then
box.out( [[<div style="margin: 3px 0px 12px 0px">]])
box.out( [[<p class="subtitle" style="margin: 0px;">{?8968:307?}</p>]])
if ( not( is_push_service_active() and not( is_ha_push_service_active())) ) then
box.out( [[<p style="margin: 6px 0px 0px 0px;">{?8968:538?}</p>]])
elseif ( not(is_ha_push_service_active())) then
box.out( [[<p style="margin: 6px 0px 0px 0px;">{?8968:373?}</p>]])
end
box.out( [[</div>]])
end
box.out( [[</div>]])
box.out( [[</div>]])
if ( g_tab_type == "kWh") then
box.out( [[<hr>]])
box.out( [[<h4>{?8968:687?}</h4>]])
box.out( [[<div class="formular">]])
box.out( [[<div class="div_tab_header">]])
box.out( [[<span id="" class="span_tab-von">]]) box.html([[{?8968:710?}]]) box.out([[</span>]])
box.out( [[<span id="" class="span_tab-bis">]]) box.html([[{?8968:6354?}]]) box.out([[</span>]])
box.out( [[<span id="" class="span_tab-values">]]) box.html([[{?8968:690?}]]) box.out([[</span>]])
box.out( [[</div>]])
box.out( [[<div id="uiView_EM_Show_24h" class="div_tab_body">]])
box.out( [[<select name="selection_sum_from_hour_24h" id="uiView_EM_SumType_From_Hour_24h" class="select_From_Hour_24h" size=1 onChange="OnChange_SelectSum( '24h', 'From_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_from_min_24h" id="uiView_EM_SumType_From_Min_24h" class="select_From_Min_24h" size=1 onChange="OnChange_SelectSum( '24h', 'From_Min', this.value)"></select>]])
box.out( [[<span class="span_tab_From_Min">]]) box.html([[{?8968:134?}]]) box.out([[</span>]])
box.out( [[<select name="selection_sum_to_hour_24h" id="uiView_EM_SumType_To_Hour_24h" class="select_To_Hour_24h" size=1 onChange="OnChange_SelectSum( '24h', 'To_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_to_min_24h" id="uiView_EM_SumType_To_Min_24h" class="select_To_Min_24h" size=1 onChange="OnChange_SelectSum( '24h', 'To_Min', this.value)"></select>]])
box.out( [[<span class="span_tab_To_Min">]]) box.html([[{?8968:25?}]]) box.out([[</span>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_24h" class="EM_Sum_Value output ">0.000</span>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_t1_24h" class="EM_Sum_Text">{?8968:5970?}</span>]])
box.out( [[</div>]])
box.out( [[<div id="uiView_EM_Show_week" class="div_tab_body">]])
box.out( [[<select name="selection_sum_from_hour_week" id="uiView_EM_SumType_From_Hour_week" class="select_From_Hour_week" size=1 onChange="OnChange_SelectSum( 'week', 'From_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_from_min_week" id="uiView_EM_SumType_From_Min_week" class="select_From_Min_week" size=1 onChange="OnChange_SelectSum('week', 'From_Min', this.value)"></select>]])
box.out( [[<select name="selection_sum_to_hour_week" id="uiView_EM_SumType_To_Hour_week" class="select_To_Hour_week" size=1 onChange="OnChange_SelectSum('week', 'To_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_to_min_week" id="uiView_EM_SumType_To_Min_week" class="select_To_Min_week" size=1 onChange="OnChange_SelectSum('week', 'To_Min', this.value)"></select>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_week" class="EM_Sum_Value output ">0.000</span>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_t1_week" class="EM_Sum_Text">{?8968:90?}</span>]])
box.out( [[</div>]])
box.out( [[<div id="uiView_EM_Show_month" class="div_tab_body">]])
box.out( [[<select name="selection_sum_from_month" id="uiView_EM_SumType_From_Hour_month" class="select_From_month" size=1 onChange="OnChange_SelectSum( 'month', 'From_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_to_month" id="uiView_EM_SumType_To_Hour_month" class="select_To_month" size=1 onChange="OnChange_SelectSum('month', 'To_Hour', this.value)"></select>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_month" class="EM_Sum_Value output ">0.000</span>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_t1_month" class="EM_Sum_Text">{?8968:34?}</span>]])
box.out( [[</div>]])
box.out( [[<div id="uiView_EM_Show_year" class="div_tab_body">]])
box.out( [[<select name="selection_sum_from_year" id="uiView_EM_SumType_From_Hour_year" class="select_From_year" size=1 onChange="OnChange_SelectSum( 'year', 'From_Hour', this.value)"></select>]])
box.out( [[<select name="selection_sum_to_year" id="uiView_EM_SumType_To_Hour_year" class="select_To_year" size=1 onChange="OnChange_SelectSum('year', 'To_Hour', this.value)"></select>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_year" class="EM_Sum_Value output ">0.000</span>]])
box.out( [[<span id="uiView_EnergyStats_LastUnit_t1_year" class="EM_Sum_Text">{?8968:234?}</span>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<hr>]])
box.out( [[<h4>{?8968:96?}</h4>]])
box.out( [[<div class="formular">]])
box.out( [[{?8968:399?}]] )
box.out( [[<table id="tHAconsumption" name="personal_consumption" class="zebra">]])
box.out( write_consumption_table_header())
box.out( write_consumption_table_content( g_average_values))
box.out( [[</table>]])
box.out( [[</div>]])
box.out( [[<hr>]])
box.out( [[<h4>{?8968:912?}</h4>]])
box.out( [[<div class="formular">]])
box.out( [[<p>{?8968:575?}</p>]])
box.out( [[<button id="uiBtn_ResetEnergyDatas" type="button" name="reset_energy_datas" onclick="OnClick_ResetEnergyDatas()" style="float: right; margin-right: 10px;">{?8968:868?}</button>]])
box.out( [[</div>]])
end
else
box.out( [[<div id="uiViewHasNoTime">]])
box.out( [[<p>{?8968:437?}</p>]])
box.out( [[</div>]])
end
?>
<div id="btn_form_foot">
<input type="hidden" name="sub_tab" value="<?lua box.html(g_tab_type) ?>">
<input type="hidden" name="current_ule" value="<?lua box.html(g_device_id) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua
box.out( [[<button type="submit" name="cancel">{?8968:182?}</button>]])
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ha_sets.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/ha_draw.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_oCurrentBoxtime = new Date(<?lua box.js((tonumber(g_current_box_time)*1000)) ?>);
var g_canvas_elem = jxl.get("uiView_CanvasEnergy");
var g_Has_Time = <?lua box.js( g_hastime) ?>;
var g_Tab_Type = "<?lua box.js( g_tab_type) ?>";
var g_Show_Type = "<?lua box.js( g_show_type) ?>";
var g_Device_ID = "<?lua box.js(g_device_id) ?>";
var g_Is_connected = <?lua box.js((tostring(g_device_valid) == "2")) ?>;
var g_TO_All_States_Value = GetTO_Value( g_Show_Type);
var g_nFrom = 0;
var g_nTo = 0;
var g_nSkip = 0;
var g_szSelectKind = "start";
var g_CurrentSelectValues = null;
var g_Reset_EnergyDatas = false;
var g_IndexOfTTValue = -1;
var g_timeout_ID = null;
var g_timeout_ID_2 = null;
var g_Abs_PosTop = -100;
var g_Abs_PosLeft = -100;
var json = makeJSONParser();
var sidParam = buildUrlParam( "sid", "<?lua box.js(box.glob.sid) ?>");
if ( g_Has_Time == true )
{
ha_draw.init( "uiView_CanvasEnergy", 770, 330 );
ha_draw.set_Date( g_oCurrentBoxtime );
<?lua
if g_device_defaults then
box.out( [[ha_draw.set_Tarif_Value( ]], box.tojs( as_euro( g_device_defaults.Tarif ) ), [[);]] )
box.out( [[ha_draw.set_CO2_Ouput( ]], box.tojs( as_kilo( g_device_defaults.CO2Emission ) ), [[);]])
end
?>
ha_draw.set_EM_ValueType( "2" );
}
function GetTO_Value( szType) {
var nRetCode = 0;
switch (szType) {
case "10":
nRetCode = 10 * 1000; // 10 sec.
break;
case "hour":
nRetCode = 60 * 1000; // 1 min..
break;
case "24h":
var nMins = ha_draw.MinsTillNextQuarter() + 1;
nRetCode = nMins * 60 * 1000; // max. alle 15 min..
break;
case "week":
var nHours = ha_draw.TimeTillNextWeekSkip();
var nOffset_30Mins = 30 * 60 * 60 * 1000;
nRetCode = (nHours * 60 * 60 * 1000) + nOffset_30Mins; // max. alle 6 Std. + 30Min...
break;
case "month":
nRetCode = 24 * 60 * 60 * 1000; // 1 mal täglich..
break;
case "year":
nRetCode = 24 * 60 * 60 * 1000; // 1 mal täglich..
break;
}
return nRetCode;
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
}
setTimeout( "GetOutletStates("+g_Device_ID+")", 37000); // alle 37 sec.
}
function Energy_Value( Power, Voltage, Ampere) {
this.power = Power;
this.voltage = Voltage;
this.ampere = Ampere;
}
function GetEnergyStatsValues( szDeviceID) {
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "EnergyStats_"+g_Show_Type);
url += "&" + buildUrlParam( "id", szDeviceID);
ajaxGet( url, cb_Receive_Energy_Stats_Values)
}
function cb_Receive_Energy_Stats_Values(xhr) {
var response = json(xhr.responseText || "null");
ha_draw.set_Date();
if ( response && (response.RequestResult != "0")) {
ha_sets.setConnectStateOf( response.DeviceID, response.DeviceConnectState);
ha_sets.setSwitchStateOf( response.DeviceID, response.DeviceSwitchState);
ha_draw.set_Date( new Date(( Number( response.CurrentDateInSec)*1000)));
if ( g_Show_Type == response.tabType) {
var n_MaxEnergy_Amount = 0;
var array_EnergyValues = new Array();
for ( var i = Number(response.EnStats_count); i > 0 ; i-- ) {
var newEnergyEntry = null;
if ( g_Tab_Type == "watt") {
newEnergyEntry = new Energy_Value( response["EnStats_watt_value_"+String(i)], response["EnStats_volt_value_"+String(i)], 0);
} else {
newEnergyEntry = new Energy_Value( response["EnStats_watt_value_"+String(i)], 0, 0);
n_MaxEnergy_Amount = n_MaxEnergy_Amount + Number( response["EnStats_watt_value_"+String(i)]);
}
array_EnergyValues.push( newEnergyEntry);
}
ha_draw.set_EnergyValues( array_EnergyValues);
ha_draw.set_MaxEnergy_Amount( n_MaxEnergy_Amount);
if ( Number(response.EnStats_count) > 0) {
ha_draw.set_MaxToDraw( Number( response.EnStats_max_value));
if ( g_Tab_Type == "watt") {
ha_draw.set_MaxToDraw( ha_draw.getDevicePower( response.EnStats_max_value));
var nTmp = ha_draw.getDevicePower( response.EnStats_min_value).toFixed(2);
jxl.setHtml( "uiView_EnergyStats_Min", ha_sets.formatAsFloat( nTmp) );
nTmp = ha_draw.getDevicePower( response.EnStats_max_value).toFixed(2);
jxl.setHtml( "uiView_EnergyStats_Max", ha_sets.formatAsFloat( nTmp));
nTmp = ha_draw.getDevicePower( response.MM_Value_Power).toFixed(2);
jxl.setHtml( "uiView_EnergyStats_Average", ha_sets.formatAsFloat( nTmp));
nTmp = ha_draw.getDeviceAmpere( response.MM_Value_Amp).toFixed(2);
jxl.setHtml( "uiView_EnergyStats_Ampere", ha_sets.formatAsFloat( nTmp));
}
}
if ( g_Reset_EnergyDatas == true) {
g_Reset_EnergyDatas = false;
var arNewConsumptionsValue = new Array( response.sum_Day, response.sum_Month, response.sum_Year);
updateComsumptionValues( arNewConsumptionsValue);
}
}
}
setTimeout( "GetEnergyStatsValues("+g_Device_ID+")", GetTO_Value( g_Show_Type));
ha_draw.draw_Monitor_of( g_Show_Type);
if ((g_Is_connected == true) && ( ha_draw.EnergyValuesSize() > 0)) {
jxl.enable( "uiBtn_ResetEnergyDatas");
} else {
jxl.disable( "uiBtn_ResetEnergyDatas");
}
if ( ha_draw.EnergyValuesSize() > 0) {
jxl.enable( "uiBtn_ExportView");
} else {
jxl.disable( "uiBtn_ExportView");
}
if ( g_Tab_Type != "watt") {
clear_Selection_of( g_Show_Type);
build_Selection_of( g_Show_Type);
show_EM_Sum_Type_of( g_Show_Type);
GetMeasuredConsumption( g_Show_Type, g_szSelectKind);
}
}
function Select_Parameters( ShowTab, nFrom, nTo, nSkip, nFrom_2, nTo_2) {
if ( nFrom_2 == null) nFrom_2 = 0;
if ( nTo_2 == null) nTo_2 = 0;
this.showtab = ShowTab;
this.from = nFrom;
this.to = nTo;
this.skip = nSkip;
this.from_2 = nFrom_2;
this.to_2 = nTo_2;
}
function updateComsumptionValues( arNewValues) {
if ( arNewValues.length > 0) {
for ( var i = 0; i < 3; i++) {
var nBase_Value = Number( arNewValues[i])/1000;
var nBase_Euro = nBase_Value * ha_draw.Tarif_As_Euro();
var nBase_CO2 = nBase_Value * ha_draw.CO2_As_Kilo();
jxl.setText( "uiView_TConsumption_Euro"+(i+1), ha_sets.formatAsFloat( nBase_Euro.toFixed(2)));
jxl.setText( "uiView_TConsumption_Power"+(i+1), ha_sets.formatAsFloat( nBase_Value.toFixed(3)));
jxl.setText( "uiView_TConsumption_CO2"+(i+1), ha_sets.formatAsFloat( nBase_CO2.toFixed(3)));
}
}
}
function show_EM_Sum_Type_of( show_type) {
jxl.display( "uiView_EM_Show_24h", show_type == "24h");
jxl.display( "uiView_EM_Show_week", show_type == "week");
jxl.display( "uiView_EM_Show_month", show_type == "month");
jxl.display( "uiView_EM_Show_year", show_type == "year");
}
function clear_Selection_of( show_type) {
jxl.clearSelection( "uiView_EM_SumType_From_Hour_"+show_type);
jxl.clearSelection( "uiView_EM_SumType_From_Min_"+show_type);
jxl.clearSelection( "uiView_EM_SumType_To_Hour_"+show_type);
jxl.clearSelection( "uiView_EM_SumType_To_Min_"+show_type);
}
function build_Selection_of( show_type) {
var ar_Select_Texts_From = ha_draw.getSelectDates( show_type, "From");
var n_SelectValue_FromHour = 0;
for ( var i=0; i < ar_Select_Texts_From.length; i++) {
jxl.addOption( "uiView_EM_SumType_From_Hour_"+show_type, i, ar_Select_Texts_From[i]);
}
var ar_Select_Texts_To = ha_draw.getSelectDates( show_type, "To");
var n_SelectValue_ToHour = ar_Select_Texts_To.length - 1;
for ( var i=0; i < ar_Select_Texts_To.length; i++) {
jxl.addOption( "uiView_EM_SumType_To_Hour_"+show_type, i, ar_Select_Texts_To[i]);
}
g_nSkip = 0;
var n_SelectValue_FromMin = 0;
var n_SelectValue_ToMin = 0;
if ((show_type == "24h") || (show_type == "week")) {
if ( show_type == "24h") {
g_nSkip = ha_draw.getHourSkip();
}
if (show_type == "week") {
g_nSkip = ha_draw.getDaySkip();
}
var nCountSkip = ((4 - g_nSkip)%4);
var ar_Select_Texts_Min = ha_draw.getSubSelectDatas( show_type, true);
for ( var i=0; i < ar_Select_Texts_Min.length; i++) {
jxl.addOption( "uiView_EM_SumType_From_Min_"+show_type, i /*((i + nCountSkip)%4)*/, ar_Select_Texts_Min[i]);
jxl.addOption( "uiView_EM_SumType_To_Min_"+show_type, i /*((i + nCountSkip)%4)*/, ar_Select_Texts_Min[i]);
}
jxl.setSelection( "uiView_EM_SumType_From_Min_"+show_type, (nCountSkip%4));
jxl.setSelection( "uiView_EM_SumType_To_Min_"+show_type, (nCountSkip%4));
}
jxl.setSelection( "uiView_EM_SumType_From_Hour_"+show_type, n_SelectValue_FromHour);
jxl.setSelection( "uiView_EM_SumType_To_Hour_"+show_type, n_SelectValue_ToHour);
}
function GetMeasuredConsumption_Index( szTab) {
var nRetCode = 0;
var nFrom_Org = Number(jxl.getValue( "uiView_EM_SumType_From_Hour_"+szTab));
var nTo_Org = Number(jxl.getValue( "uiView_EM_SumType_To_Hour_"+szTab));
var nFrom = nFrom_Org;
var nTo = nTo_Org;
var nFrom_Min = 0;
var nTo_Min = 0;
if ((szTab == "24h") || ( szTab == "week")) {
var nCountSkip = ((4 - g_nSkip)%4);
nFrom_Min = Number( jxl.getValue( "uiView_EM_SumType_From_Min_"+szTab));
nTo_Min = Number( jxl.getValue( "uiView_EM_SumType_To_Min_"+szTab));
nFrom = ((nFrom*4) + nFrom_Min - nCountSkip);
nTo = ((nTo*4) + nTo_Min - nCountSkip);
if ( nTo != 0) {
nTo -= 1;
}
}
g_CurrentSelectValues = new Select_Parameters( szTab, nFrom_Org, nTo_Org, g_nSkip, nFrom_Min, nTo_Min);
if ( nFrom > nTo) {
nRetCode = 2;
} else if ( nFrom < 0) {
nRetCode = 3;
} else if ( nTo >= ha_draw.EnergyValuesSize()) {
nRetCode = 4;
} else {
g_CurrentSelectValues = new Select_Parameters( szTab, nFrom_Org, nTo_Org, g_nSkip, nFrom_Min, nTo_Min);
g_nFrom = nFrom;
g_nTo = nTo;
}
return nRetCode;
}
function GetMeasuredConsumption( szTab, sz_special)
{
var nFailed = 0;
if ( "start" == sz_special)
{
DefineAmountRange_Start( szTab);
}
else if ( "update" == sz_special)
{
nFailed = DefineAmountRange_Update( szTab);
}
else
{
nFailed = GetMeasuredConsumption_Index( szTab);
}
var nEV_Size = ha_draw.EnergyValuesSize();
var nAmount = 0;
if ( nFailed == 0 )
{
var nAmount = ha_draw.getSummaryOf( g_nFrom, g_nTo);
if ((g_szSelectKind == "start") || ((g_nTo - g_nFrom) == (ha_draw.EnergyValuesSize() - 1)))
{
g_szSelectKind = "";
}
else
{
g_szSelectKind = "update";
}
}
else
{
g_szSelectKind = "";
if ( nEV_Size < 1 )
{
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, "--,--");
return;
}
else if ( nFailed == 2 )
{
alert("{?8968:564?}");
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, "--,--");
return;
}
else if ( nFailed == 3 )
{
alert("{?8968:914?}");
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, "--,--");
return;
}
else if ( nFailed == 4 )
{
alert("{?8968:5974?}");
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, "--,--");
return;
}
}
if ( szTab == "24h" && ha_draw.EM_ValueType() == "2" )
{
nAmount = nAmount * 1000; // Wh statt KWh
}
if ( ha_draw.EM_ValueType() == "1" )
{
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, ha_sets.formatAsFloat( nAmount.toFixed(2)));
}
else
{
jxl.setText( "uiView_EnergyStats_LastUnit_"+szTab, ha_sets.formatAsFloat( nAmount.toFixed(3)));
}
jxl.setText( "uiView_EnergyStats_LastUnit_t1_"+szTab, ha_draw.getTopLeftScaleText( szTab));
}
function DefineAmountRange_Start( szTab) {
switch( szTab) {
case "24h":
g_nFrom = 0;
g_nTo = 95;
break;
case "week":
g_nFrom = 0;
g_nTo = 27;
break;
case "month":
g_nFrom = 0;
g_nTo = 30;
break;
case "year":
g_nFrom = 0;
g_nTo = 11;
break;
}
if ((szTab == "24h") || ( szTab == "week")) {
g_CurrentSelectValues = new Select_Parameters( szTab,
g_nFrom,
((g_nTo+1)/4),
g_nSkip,
((4 - g_nSkip)%4),
((4 - g_nSkip)%4));
} else {
g_CurrentSelectValues = new Select_Parameters( szTab,
g_nFrom,
g_nTo,
g_nSkip,
((4 - g_nSkip)%4),
((4 - g_nSkip)%4));
}
}
function DefineAmountRange_Update( szTab)
{
var nFrom = g_CurrentSelectValues.from;
var nTo = g_CurrentSelectValues.to;
var nSkipKomplement = ((4 - g_nSkip)%4);
var nFrom_Min = nSkipKomplement;
var nTo_Min = nFrom_Min;
if ((szTab == "24h") || ( szTab == "week"))
{
nFrom_Min = g_CurrentSelectValues.from_2;
nTo_Min = g_CurrentSelectValues.to_2;
if ( 0 == g_nSkip)
{
nFrom = g_CurrentSelectValues.from - 1;
nTo = g_CurrentSelectValues.to - 1;
if ( 0 > nFrom )
{
nFrom = 0;
}
if ( 0 > nTo )
{
nTo = ha_draw.EnergyValuesSize()/4;
}
}
if (( 0 == nFrom) && (((nFrom_Min - nSkipKomplement) < 0) || (((nFrom_Min - nSkipKomplement) == 3))))
{
nFrom_Min = (nFrom_Min+1)%4;
}
if ( ( 0 == nTo) && (0 == (nTo_Min - nFrom_Min)) )
{
nTo = ha_draw.EnergyValuesSize()/4;
nTo_Min = nFrom_Min;
}
jxl.setSelection( "uiView_EM_SumType_From_Min_"+szTab, nFrom_Min);
jxl.setSelection( "uiView_EM_SumType_To_Min_"+szTab, nTo_Min);
}
else
{
nFrom -= 1;
//nTo -= 1;
if ( nFrom < 0)
{
nFrom = 0;
}
if ( nTo < 0)
{
nTo = ha_draw.EnergyValuesSize();
}
g_nFrom = nFrom;
g_nTo = nTo;
}
jxl.setSelection( "uiView_EM_SumType_From_Hour_"+szTab, nFrom);
jxl.setSelection( "uiView_EM_SumType_To_Hour_"+szTab, nTo);
return GetMeasuredConsumption_Index( szTab);
}
function onEditDevSubmit() {
}
function OnChange_SelectSum( szTab, szID, nValue) {
GetMeasuredConsumption( g_Show_Type, "");
}
function OnChange_EM_ValueType( szValue)
{
ha_draw.set_EM_ValueType( szValue);
ha_draw.draw_Monitor_of( g_Show_Type);
ha_draw.drawSubTabsElements( g_Show_Type);
GetMeasuredConsumption( g_Show_Type, g_szSelectKind);
if ((szValue == "1") || (szValue == "3"))
{
jxl.disable( "uiBtn_PushServiceNow");
}
else
{
<?lua
if ( is_push_service_active() and is_ha_push_service_active() ) then
box.out( [[jxl.enable( "uiBtn_PushServiceNow");]] )
else
box.out( [[jxl.disable( "uiBtn_PushServiceNow");]] )
end
?>
}
}
function OnChange_EM_ShowType( szValue)
{
g_Show_Type = szValue;
var szEM_Value_Text = "kWh";
if ( g_Show_Type == "24h")
{
szEM_Value_Text = "Wh";
}
if ( ha_draw.get_Context())
{
if ( g_Show_Type == "10")
{
jxl.display( "uiShow_PushMail_Now", false);
}
else
{
jxl.display( "uiShow_PushMail_Now", true);
}
}
else
{
jxl.display( "uiShow_PushMail_Now", false);
}
jxl.setText( "LabeluiView_EM_ValueType_Watt", szEM_Value_Text)
ha_draw.set_Date();
ha_draw.set_EnergyValues( new Array());
if ( ha_draw.get_Context() != null)
{
ha_draw.drawMonitorBackground( g_Show_Type, true, true);
setTimeout( "GetEnergyStatsValues("+g_Device_ID+")", 1000); // nach 1 sec.
}
g_CurrentSelectValues = null;
clear_Selection_of( g_Show_Type);
build_Selection_of( g_Show_Type);
show_EM_Sum_Type_of( g_Show_Type);
GetMeasuredConsumption( g_Show_Type, "start");
}
function OnClick_PushServiceNow() {
jxl.disable( "uiBtn_PushServiceNow");
var url = encodeURI("/net/home_auto_query.lua");
var szData = sidParam;
szData += "&" + buildUrlParam( "command", "PushServiceNow");
szData += "&" + buildUrlParam( "id", g_Device_ID);
szData += "&" + buildUrlParam( "currentView", g_Show_Type);
ajaxPost( url, szData, cb_Finish)
return false;
}
function OnClick_SaveDataNow(btn) {
var a = btn && btn.parentNode;
if (a && a.href) {
var first = a.href.indexOf( "&show_type=");
var new_href = a.href.substring(0,(first+11));
a.href = new_href + g_Show_Type;
if (a && a.click) {
a.click();
}
} else {
alert( "{?8968:181?}");
}
}
function OnClick_ResetEnergyDatas() {
if ( confirm('{?8968:3485?}') ) {
jxl.disable( "uiBtn_ResetEnergyDatas");
g_Reset_EnergyDatas = true;
var url = encodeURI("/net/home_auto_query.lua");
var szData = sidParam;
szData += "&" + buildUrlParam( "command", "ResetEnergyDatas");
szData += "&" + buildUrlParam( "id", g_Device_ID);
ajaxPost( url, szData, cb_Finish_2)
}
return false;
}
function cb_Finish(xhr) {
var response = json(xhr.responseText || "null");
if (!response ) {
} else {
if ( response.RequestResult == "1") {
} else {
}
}
jxl.enable( "uiBtn_PushServiceNow");
}
function cb_Finish_2(xhr) {
if ( xhr != null) {
var response = json(xhr.responseText || "null");
if (!response ) {
} else {
if ( response.RequestResult == "1") {
} else {
}
}
ha_draw.set_EnergyValues( new Array());
if ( ha_draw.get_Context() != null) {
ha_draw.drawMonitorBackground( g_Show_Type, true, true);
setTimeout( "GetEnergyStatsValues("+g_Device_ID+")", 2000); // nach 2 sec.
}
}
}
function OnClick_VoltLine() {
ha_draw.set_Draw_Volt_Line( !ha_draw.draw_Volt_Line());
if ( ha_draw.draw_Volt_Line() == false) {
jxl.setText( "uiLink_VoltLine_Text", "{?8968:514?}")
}
if ( ha_draw.draw_Volt_Line() == true) {
jxl.setText( "uiLink_VoltLine_Text", "{?8968:974?}")
}
ha_draw.draw_Monitor_of( g_Show_Type);
}
function onMouseoverCanvas(e) {
g_IndexOfTTValue = -1;
if ( g_timeout_ID != null) {
clearTimeout( g_timeout_ID);
g_timeout_ID = null;
}
if ( g_timeout_ID_2 != null) {
jxl.display( "uiView_CanvasTooltip", false);
clearTimeout( g_timeout_ID_2);
g_timeout_ID_2 = null;
}
g_IndexOfTTValue = ha_draw.isInChartOf( e.clientX+(window.scrollX-g_canvas_elem.offsetLeft), e.clientY+(window.scrollY-g_canvas_elem.offsetTop));
var nIsInPos_X = e.clientX+(window.scrollX-g_canvas_elem.offsetLeft);
var nIsInPos_Y = e.clientY+(window.scrollY-g_canvas_elem.offsetTop);
if ( (!isNaN(e.offsetX)) && (!isNaN(e.offsetY))) {
nIsInPos_X = e.offsetX;
nIsInPos_Y = e.offsetY;
}
if ( ha_draw.EnergyValuesSize() > 0) {
g_IndexOfTTValue = ha_draw.isInChartOf( nIsInPos_X, nIsInPos_Y);
if ( g_IndexOfTTValue >= 0) {
g_Abs_PosTop = g_canvas_elem.offsetTop + (e.clientY+(window.scrollY-g_canvas_elem.offsetTop)) - 20;
g_Abs_PosLeft = g_canvas_elem.offsetLeft + (e.clientX+(window.scrollX-g_canvas_elem.offsetLeft)) + 10;
if ( (!isNaN(e.offsetX)) && (!isNaN(e.offsetY))) {
g_Abs_PosTop = g_canvas_elem.offsetTop + (e.offsetY/*+(window.scrollY-g_canvas_elem.offsetTop)*/) - 20;
g_Abs_PosLeft = g_canvas_elem.offsetLeft + (e.offsetX/*+(window.scrollX-g_canvas_elem.offsetLeft)*/) + 10;
}
g_timeout_ID = setTimeout( "ShowTooltip("+g_IndexOfTTValue+")", 750); // nach 0,75 sec.
}
}
}
function onMouseoutCanvas(e) {
g_IndexOfTTValue = -1;
if ( g_timeout_ID != null) {
clearTimeout( g_timeout_ID);
g_timeout_ID = null;
}
if ( g_timeout_ID_2 != null) {
jxl.display( "uiView_CanvasTooltip", false);
clearTimeout( g_timeout_ID_2);
g_timeout_ID_2 = null;
}
}
function ShowTooltip( indexOfValues) {
if ((ha_draw.EnergyValuesSize() > 0) && ( indexOfValues >= 0)) {
var nEnergyValue = ha_draw.EnergyValueOf( g_Show_Type, indexOfValues);
var szUnit = ha_draw.getTopLeftScaleText( g_Show_Type);
jxl.setText( "uiView_Tooltip_Text", ha_sets.formatAsFloat( String(nEnergyValue))+" "+szUnit);
jxl.setStyle( "uiView_CanvasTooltip", "top", g_Abs_PosTop+"px");
jxl.setStyle( "uiView_CanvasTooltip", "left", g_Abs_PosLeft+"px");
g_timeout_ID_2 = setTimeout( "DisableTooltip()", 45000); // nach 45 sec.
jxl.display( "uiView_CanvasTooltip", true);
}
}
function DisableTooltip() {
g_IndexOfTTValue = -1;
if ( g_timeout_ID != null) {
clearTimeout( g_timeout_ID);
g_timeout_ID = null;
}
if ( g_timeout_ID_2 != null) {
jxl.display( "uiView_CanvasTooltip", false);
clearTimeout( g_timeout_ID_2);
g_timeout_ID_2 = null;
}
}
function init() {
<?lua
if ( is_push_service_active() and is_ha_push_service_active() ) then
box.out( [[jxl.enable( "uiBtn_PushServiceNow");]] )
else
box.out( [[jxl.disable( "uiBtn_PushServiceNow");]] )
end
?>
jxl.display( "uiView_CanvasTooltip", false);
if ( g_Has_Time == true) {
if ((g_Is_connected == false) || ( ha_draw.EnergyValuesSize() == 0)) {
jxl.disable( "uiBtn_ResetEnergyDatas");
}
if ( ha_draw.EnergyValuesSize() == 0) {
jxl.disable( "uiBtn_ExportView");
}
ha_draw.set_Date();
ha_draw.drawMonitorBackground( g_Show_Type, false, true);
setTimeout( "GetEnergyStatsValues("+g_Device_ID+")", 2000); // nach 2 sec.
if ( ha_draw.get_Context()) {
if ( g_Tab_Type == "watt") {
jxl.display( "uiLink_VoltLine", true);
} else {
build_Selection_of( g_Show_Type);
show_EM_Sum_Type_of( g_Show_Type);
GetMeasuredConsumption( g_Show_Type, g_szSelectKind);
g_canvas_elem.addEventListener( 'mousemove', onMouseoverCanvas, 1);
g_canvas_elem.addEventListener( 'mouseout', onMouseoutCanvas, 1);
}
if ( g_Show_Type != "10") {
jxl.display( "uiShow_PushMail_Now", true);
}
} else {
jxl.display( "uiShow_PushMail_Now", false);
}
}
}
// ready.onReady(val.init(onEditDevSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
