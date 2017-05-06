<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_dslinfo_ADSL.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("general")
require "libluadsl"
function split(data)
local tmp=string.split(data,";")
return tmp
end
if (next(box.post) and (box.post.cancel)) then
http.redirect([[/internet/dsl_stats_tab.lua]])
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
g_data.port = {}
g_data.port[1] = {}
g_data.port[2] = {}
g_data.port[1].ds_negotiated= luadsl.getNegotiatedValues(1, "DS")
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
g_data.port[i] = {}
g_data.port[i].ds_negotiated= luadsl.getNegotiatedValues(i, "DS")
g_data.port[i].us_negotiated = luadsl.getNegotiatedValues(i, "US")
g_data.port[i].ds_errors = luadsl.getErrorCounters(i, "DS")
g_data.port[i].us_errors = luadsl.getErrorCounters(i, "US")
g_data.port[i].ds_overview = luadsl.getOverviewStatus(i, "DS")
g_data.port[i].us_overview = luadsl.getOverviewStatus(i, "US")
end
function refill_user_input()
end
function get_ds_delay(port_nr)
if not g_data.port[port_nr].ds_negotiated.INTERLEAVE_PATH then return box.tohtml([[{?572:133?}]]) end
if g_data.port[port_nr].ds_negotiated.INTERLEAVE_PATH then return box.tohtml(tostring(g_data.port[port_nr].ds_negotiated.DELAY)..[[ {?572:988?}]]) end
end
function get_us_delay(port_nr)
if not g_data.port[port_nr].us_negotiated.INTERLEAVE_PATH then return box.tohtml([[{?572:216?}]]) end
if g_data.port[port_nr].us_negotiated.INTERLEAVE_PATH then return box.tohtml(tostring(g_data.port[port_nr].us_negotiated.DELAY)..[[ {?572:316?}]]) end
end
function get_on_off_friendly(value)
if value==1 then
return [[{?572:920?}]]
elseif value==2 then
return [[{?572:70?}]]
elseif value==0 then
return [[{?txtAus?}]]
else
if (type(value)=='string') then
return box.tohtml(value)
end
return ""
end
end
function get_on_off(bitswap_enabled)
if bitswap_enabled then
return [[{?txtAn?}]]
else
return [[{?txtAus?}]]
end
end
function get_exp_ds_olr_Bitswap(port_nr)
return box.tohtml(get_on_off(g_data.port[port_nr].ds_negotiated.BITSWAP_ENABLE))
end
function get_exp_us_olr_Bitswap(port_nr)
return box.tohtml(get_on_off(g_data.port[port_nr].us_negotiated.BITSWAP_ENABLE))
end
function valid_string(str)
if (str and type(str)~='boolean' and str ~= "") then
return tostring(str)
elseif type(str)=='boolean' then
return get_on_off(str)
else
return ""
end
end
function write_tds(func_table, key, c_cnt)
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
local value = ""
if g_data.port[i] and g_data.port[i][func_table] and g_data.port[i][func_table][key]~=nil then
value = valid_string(g_data.port[i][func_table][key])
end
write_td(i + c_cnt, value)
end
end
function write_td(class_num, content)
local td_content = ""
if content and type(content)=='string' then
td_content = content
end
box.out([[<td class="c]]..box.tohtml(tostring(class_num))..[[">]]..box.tohtml(td_content)..[[</td>]])
end
function write_row(name, unit, key, func, hide_values)
if not func then
func = "negotiated"
end
local rec_func = "ds_"..func
local send_func = "us_"..func
name = valid_string(name)
unit = valid_string(unit)
local show = false
local ports = g_data.port[1].ds_negotiated.PORTS
for i = 1, ports, 1 do
if g_data.port[i] and g_data.port[i][rec_func] and g_data.port[i][rec_func][key] ~= nil then
show = true
end
if g_data.port[i][send_func] and g_data.port[i][send_func][key] ~= nil then
show = true
end
end
if hide_values then
key = nil
end
if show then
box.out([[
<tr>]])
write_td(1, name)
write_td(2, unit)
write_tds(rec_func, key, 2)
write_tds(send_func, key, 2 + ports)
box.out([[
</tr>]])
end
end
function write_adsl2_rows()
local rate_adapt_text = [[{?572:391?}]]
local power_mode_text = [[{?572:156?}]]
write_row(rate_adapt_text, [[]], "SRA_ENABLE")
write_row(power_mode_text, valid_string(g_data.port[1].ds_negotiated.L2_ENABLE), "L2_ENABLE", nil, true)
end
function write_inp_row()
if g_data.port[1].ds_overview.MODE == "VDSL2" then
write_row([[{?572:670?}]], [[]], "INP")
else
write_row([[{?572:881?}]], [[]], "INP")
end
end
function write_vdsl_rows()
end
function write_cutback()
local cutback_text = [[{?572:11?}]]
local db_text = [[{?572:129?}]]
write_row(cutback_text, db_text, "PCB")
end
function write_toneset()
write_row([[{?572:146?}]], [[]], "TONESET")
end
function write_profile()
local profile_text = [[{?572:503?}]]
write_row(profile_text, g_data.port[1].ds_negotiated.PROFIL, "PROFIL", nil, true)
end
function write_psd_mask()
local psd_mask_text = [[{?572:193?}]]
write_row(psd_mask_text, "", "PSD_SUBMODE_MASK", "overview")
end
function roundPerMinuteValue(val)
val = tonumber(val) or 0;
local valFloor = math.floor(val);
if (valFloor == val or valFloor > 1) then
return tostring(valFloor);
end
if (val <= 1) then
return tostring(val);
end
return tostring(math.floor(math.round(val)));
end
function write_dsl_gui_version_greater_1(port_nr)
local str=general.sprintf([[
<tr>
<th class="c1 "></th>
<th class="c2 hint" colspan="2">]]..box.tohtml([[{?572:875?}]])..[[</th>
<th class="c4 hint" colspan="2">]]..box.tohtml([[{?572:57?}]])..[[</th>]])
str=str..general.sprintf([[
</tr>
<tr>
<th class="c1"></th>
<th class="c2">]]..box.tohtml([[{?572:378?}]])..[[</th>
<th class="c3">]]..box.tohtml([[{?572:562?}]])..[[<br />]]..box.tohtml([[{?572:221?}]])..[[</th>
<th class="c4">]]..box.tohtml([[{?572:732?}]])..[[<br />]]..box.tohtml([[{?572:946?}]])..[[</th>
<th class="c5">]]..box.tohtml([[{?572:8?}]])..[[<br />]]..box.tohtml([[{?572:967?}]])..[[</th>]])
str=str..general.sprintf([[
</tr>
<tr>
<td class="c1">]]..box.tohtml([[{?572:841?}]])..[[</td>
<td class="c2">%1</td>
<td class="c3">%2</td>
<td class="c4">%3</td>
<td class="c5">%4</td>]],
box.tohtml(g_data.port[port_nr].ds_errors.ES), box.tohtml(g_data.port[port_nr].ds_errors.SES),
box.tohtml(roundPerMinuteValue(g_data.port[port_nr].ds_errors.CRC_MIN)), box.tohtml(g_data.port[port_nr].ds_errors.CRC_15MIN))
str=str..general.sprintf([[
</tr>
<tr>
<td class="c1">]]..box.tohtml([[{?572:446?}]])..[[</td>
<td class="c2">%1</td>
<td class="c3">%2</td>]],
box.tohtml(g_data.port[port_nr].us_errors.ES), box.tohtml(g_data.port[port_nr].us_errors.SES))
str=str..general.sprintf([[
<td class="c4">%1</td>
<td class="c5">%2</td>
</tr>]],
box.tohtml(roundPerMinuteValue(g_data.port[port_nr].us_errors.CRC_MIN)), box.tohtml(g_data.port[port_nr].us_errors.CRC_15MIN))
box.out(str)
end
function write_ginp()
local ginp_down = g_data.port[1].ds_negotiated.G_INP_ACTIVE
local ginp_up = g_data.port[1].us_negotiated.G_INP_ACTIVE
if (ginp_down~=nil or ginp_up~=nil) then
write_ginp_row()
end
end
function write_gvector()
local vector_mode_down = g_data.port[1].ds_negotiated.G_VECTOR_MODE
local vector_mode_up = g_data.port[1].us_negotiated.G_VECTOR_MODE
if (vector_mode_down~=nil or vector_mode_up~=nil) then
write_gvector_row()
end
end
function write_table1_header()
local colspan = ""
if g_data.port[1].ds_negotiated.PORTS > 1 then
colspan = [[ colspan = "]]..g_data.port[1].ds_negotiated.PORTS..[["]]
end
box.out([[
<tr>
<th class="c1"></th>
<th class="c2"></th>
<th class="c3h"]]..colspan..[[>]]..box.tohtml([[{?572:4?}]])..[[</th>
<th class="c4h"]]..colspan..[[>]]..box.tohtml([[{?572:909?}]])..[[</th>
</tr>
]])
end
function write_dsl_max_data_rate()
write_row([[{?572:540?}]], [[{?572:808?}]], "MAX_DR")
end
function write_dsl_min_data_rate()
write_row([[{?572:462?}]], [[{?572:327?}]], "MIN_DR")
end
function write_dsl_cable_capacity()
write_row([[{?572:180?}]], [[{?572:683?}]], "ATTAIN_DR")
end
function write_dsl_atm_rate()
write_row([[{?572:825?}]], [[{?572:5063?}]], "ACTUAL_DR")
end
function write_empty_row()
box.out(
[[<tr>
<td class="c1">&nbsp;</td>]])
write_td(2, [[]])
write_tds("", "", 2)
write_tds("", "", 2 + g_data.port[1].ds_negotiated.PORTS)
box.out(
[[</tr>]])
end
function write_dsl_latency()
box.out([[
<tr>]])
write_td(1, [[{?572:715?}]])
write_td(2, [[]])
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
write_td(i + 2, valid_string(get_ds_delay(i)))
end
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
write_td(g_data.port[1].ds_negotiated.PORTS + i + 2, valid_string(get_us_delay(i)))
end
box.out([[
</tr>]])
end
function write_dsl_bit_swap()
box.out([[
<tr>]])
write_td(1, [[{?572:675?}]])
write_td(2, [[]])
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
write_td(i + 2, valid_string(get_exp_ds_olr_Bitswap(i)))
end
for i = 1, g_data.port[1].ds_negotiated.PORTS, 1 do
write_td(g_data.port[1].ds_negotiated.PORTS + i + 2, valid_string(get_exp_us_olr_Bitswap(i)))
end
box.out([[
</tr>]])
end
function write_dsl_signal_noise_distance()
write_row([[{?572:951?}]], [[{?572:626?}]], "MARGIN")
end
function write_dsl_line_loss()
write_row([[{?572:550?}]], [[{?572:968?}]], "ATTENUATION")
end
function write_ginp_row()
local ginp_down = g_data.port[1].ds_negotiated.G_INP_ACTIVE
local ginp_up = g_data.port[1].us_negotiated.G_INP_ACTIVE
box.out([[
<tr>]])
write_td(1, [[{?572:928?}]])
write_td(2, [[]])
write_td(3, get_on_off(ginp_down))
write_td(4, get_on_off(ginp_up))
box.out([[
</tr>
]])
end
function write_gvector_row()
local vector_mode_down = g_data.port[1].ds_negotiated.G_VECTOR_MODE
local vector_mode_up = g_data.port[1].us_negotiated.G_VECTOR_MODE
box.out([[
<tr>]])
write_td(1, [[{?572:242?}]])
write_td(2, [[]])
write_td(3, get_on_off_friendly(vector_mode_down))
write_td(4, get_on_off_friendly(vector_mode_up))
box.out([[
</tr>
]])
end
function write_main_div()
box.out([[<h4>]])
if g_data.port[1].us_overview.STATE=="SHOWTIME" then
box.html([[{?572:414?}]])
else
box.html([[{?572:229?}]])
end
box.out([[</h4>]])
box.out([[
<table id="Table1" class="zebra">]])
write_table1_header()
write_dsl_max_data_rate()
write_dsl_min_data_rate()
write_dsl_cable_capacity()
write_dsl_atm_rate()
write_adsl2_rows()
write_empty_row()
write_dsl_latency()
write_inp_row()
write_ginp()
write_empty_row()
write_dsl_signal_noise_distance()
write_dsl_bit_swap()
write_dsl_line_loss()
write_cutback()
write_psd_mask()
write_empty_row()
write_profile()
write_gvector()
write_empty_row()
write_toneset()
box.out([[
</table>]])
if g_data.port[1].us_overview.STATE=="SHOWTIME" then
box.out([[
<br>
<h4>]]..box.tohtml([[{?572:75?}]])..[[</h4>
<table id="Table2" class="zebra_reverse">]])
write_dsl_gui_version_greater_1(1)
box.out([[
</table>
]])
end
end
function write_table_classes()
--#Table1 .c]]..tostring(c_cnt+i)..[[, #Table1 .c]]..tostring(c_cnt+i)..[[ {width: 60px; text-align: center;}
local port_cnt = g_data.port[1].ds_negotiated.PORTS
local c_cnt = 2
for i = 1, port_cnt, 1 do
box.out([[
#Table1 .c]]..tostring(c_cnt + 2 * i - 1)..[[, #Table1 .c]]..tostring(c_cnt + 2 * i)..[[{width: ]]..tostring(120 / port_cnt)..[[px; text-align: right;}
]])
end
box.out([[
#Table1 .c3h, #Table1 .c4h {width: ]]..tostring(120 / port_cnt)..[[px; text-align: right;}
]])
box.out([[
#Table2 .c2, #Table2 .c3, #Table2 .c4, #Table2 .c5 {width: 85px; text-align: center;vertical-align:top;}
]])
end
if box.get.update == "mainDiv" or false then
write_main_div()
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#Table1, #Table2 {
padding:0;
background-color:transparent;
width: 600px;
margin: auto;
}
#Table1, #Table2 {height: 12px; font-size: 12px;}
#Table1 td, #Table2 td {padding: 1px 2px;}
#Table1 .c1 {width: 150px; text-align: left; padding-right: 0px;}
#Table1 .c2 {width: 50px; text-align: left; padding-left: 0px;}
#Table2 .c1 {width: 80px; text-align: left;}
<?lua write_table_classes() ?>
#Table2 th {
font-weight:bold;
background-color:#eeeeee;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function init() {
updateInfo();
}
function updateInfo(refresh) {
var timeOut = 5000;
if (refresh) {
timeOut = 0;
}
var page = "<?lua box.js(box.glob.script) ?>";
var sid = "<?lua box.js(box.glob.sid) ?>";
ajaxUpdateHtml("mainDiv", page, sid, timeOut);
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="mainDiv">
<?lua write_main_div() ?>
</div>
<div id="btn_form_foot">
<button type="button" name="cancel" onclick="updateInfo(true)">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
