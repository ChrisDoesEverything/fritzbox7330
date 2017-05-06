<?lua
g_page_type = "all"
g_page_title = ""
g_page_needs_js = true
g_page_help = 'hilfe_inetstat.html'
dofile("../templates/global_lua.lua")
require("general")
if box.post.reset then
require ("cmtable")
local saveset = {}
cmtable.add_var(saveset, "box:settings/Statistic/Reset", "1")
local err, errmsg = box.set_config(saveset)
elseif box.post.editbudget then
require"href"
require"http"
http.redirect(
href.get("/internet/inetstat_budget.lua", http.url_param("back_to_page", box.glob.script))
)
end
local g_Kilo = 1000
local g_Mega = 1000000
local g_Giga = 1000000000
g_timeknown = box.query("inetstat:status/timeknown") == "1"
function get_data_table_header()
local str = [[
<tr class="first_row">
<th class="first_col"></th>
<th>{?815:780?}</th>
<th style="text-align:center;" colspan="3">{?815:401?}</th>
<th>{?815:377?}</th>
</tr>
<tr class="first_row">
<th class="first_col"></th>
<th>{?815:351?}</th>
<th>{?815:151?}</th>
<th>{?815:605?}</th>
<th>{?815:915?}</th>
<th></th>
</tr>
]]
return str
end
function query_send_receive(request)
local inh = box.query("inetstat:status/"..request.."/BytesReceivedHigh")
local inl = box.query("inetstat:status/"..request.."/BytesReceivedLow")
local outh = box.query("inetstat:status/"..request.."/BytesSentHigh")
local outl = box.query("inetstat:status/"..request.."/BytesSentLow")
return inh, inl, outh, outl
end
local function get_vol_str(high1, low1, high2, low2)
local bytes = general.highlow2byte(high1, low1)
if high2 and low2 then
bytes = bytes + general.highlow2byte(high2, low2)
end
local result = math.round(bytes/g_Mega, 0)
if 0 < result and result < 1 then
end
result = string.format([[%d]], result)
return result
end
function get_data(request)
local str = ""
local outgoingcalls = box.query("inetstat:status/"..request.."/OutgoingCalls")
local time = box.query("inetstat:status/"..request.."/PhyConnTimeOutgoing")
str = [[<td class="time">]] .. general.convert_to_str(time) .. [[</td>]]
local inh, inl, outh, outl = query_send_receive(request)
str = str .. general.sprintf([[
<td class="vol">%1</td><td class="vol">%2</td><td class="vol">%3</td>]],
box.tohtml(get_vol_str(inh, inl, outh, outl)),
box.tohtml(get_vol_str(outh, outl)),
box.tohtml(get_vol_str(inh, inl))
)
str = str .. [[<td class="conn">]] .. outgoingcalls .. [[</td>]]
return str
end
function get_data_table_row(request)
local str = [[<tr>]]
local txt = {
Today = [[{?815:124?}]],
Yesterday = [[{?815:693?}]],
ThisWeek = [[{?815:110?}]],
ThisMonth = [[{?815:215?}]],
LastMonth = [[{?815:617?}]]
}
str = str .. [[
<td class="first_col">]]
.. box.tohtml(txt[request] or "")
.. [[
</td>
]]
str = str .. get_data(request)
str = str .. [[</tr>]]
return str
end
function get_data_table_rows()
local str = get_data_table_row("Today")
str = str .. get_data_table_row("Yesterday")
str = str .. get_data_table_row("ThisWeek")
str = str .. get_data_table_row("ThisMonth")
str = str .. get_data_table_row("LastMonth")
return str
end
function get_data_table()
local str = [[<table id="tStat">]]
str = str .. get_data_table_header()
str = str .. get_data_table_rows()
str = str .. [[</table>]]
return str
end
function write_data_table()
box.out(get_data_table())
end
local g_hours, g_minutes, g_cur, g_max, g_maxtime, g_maxvol = general.get_onlinecounter_data()
local g_start = {
day = tonumber(box.query("box:settings/Statistic/StartOfMonth")) or 0,
month = 0,
year = 0
}
local g_end = {
day = 0,
month = 0,
year = 0
}
local g_used = {
cur = 0,
limit = 0
}
local g_max_x = 200
function days_in_month(month, year)
local ret = 31
if month == 4 or month == 6 or month == 9 or month == 11 then
ret = 30
end
if month == 2 then
ret = 28
if (year % 4) == 0 then
ret = 29
if (year % 100) == 0 then
ret = 28
end
end
end
return ret
end
function init_time_range(start_date, end_date, used)
local now = os.date("*t")
local heuteTag = now.day
local heuteMonat = now.month
local heuteJahr = now.year
if heuteTag < start_date.day then
start_date.month = heuteMonat - 1
if start_date.month < 1 then
start_date.month = 12
start_date.year = heuteJahr - 1
else
start_date.year = heuteJahr
end
else
start_date.month = heuteMonat
start_date.year = heuteJahr
end
if start_date.day > days_in_month(start_date.month, start_date.year) then
start_date.day = 1
start_date.month = start_date.month + 1
end
end_date.month = start_date.month + 1
end_date.year = start_date.year
if end_date.month > 12 then
end_date.month = 1
end_date.year = end_date.year + 1
end
end_date.day = start_date.day - 1
if end_date.day < 1 then
end_date.month = end_date.month - 1
if end_date.month < 1 then
end_date.month = 12
end_date.year = end_date.year - 1
end
end_date.day = days_in_month(end_date.month, end_date.year)
end
if end_date.day > days_in_month(end_date.month, end_date.year) then
end_date.day = days_in_month(end_date.month, end_date.year)
end
used.limit = 0
if end_date.day < start_date.day then
used.limit = days_in_month(start_date.month, start_date.year) - start_date.day + end_date.day + 1
else
used.limit = days_in_month(start_date.month, start_date.year)
end
used.cur = 0
if start_date.day <= heuteTag then
used.cur = heuteTag - start_date.day + 1
else
used.cur = heuteTag + (days_in_month(start_date.month, start_date.year) - start_date.day) + 1
end
end
init_time_range(g_start, g_end, g_used)
g_budget_enabled = box.query("connection0:settings/Budget/Enabled") == "1"
function is_data_vol()
return g_maxtime == 0
end
function is_time_vol()
return g_maxtime ~= 0
end
function hideif(cond)
if cond then
box.out([[ style="display:none;"]])
end
end
function get_bar(val, class)
if val == nil then
return ""
end
local w = val
local fill = g_max_x - w
local str = [[<div class="meter">]]
if w > 0 then
str = str .. [[<span class="bar ]]..class..[[" style="width:]]..w..[[px"></span>]]
if fill > 0 then
str = str .. [[<span class="bar fill" style="width:]]..fill..[[px"></span>]]
end
else
str = str .. [[<span class="bar fillonly" style="width:]]..fill..[[px"></span>]]
end
str = str .. [[</div>]]
return str
end
function write_bar(val, class)
box.out(get_bar(val, class))
end
function write_consum_bar()
local cur = 0
local curclass = "used"
if (g_used.cur/g_used.limit) < (g_cur/g_max) then
curclass = "used_a_lot"
end
if is_data_vol() then
cur = math.ceil(math.min(g_max_x,(g_cur/g_max)*g_max_x))
else
cur = math.ceil(math.min(g_max_x,(g_cur/g_maxtime)*g_max_x))
end
write_bar(cur, curclass)
end
function write_consum()
local retstr = general.get_online_usage_str(g_hours, g_minutes, g_max)
if is_data_vol() then
retstr = general.get_onlinecounter_amount()
end
box.out(retstr)
end
function write_time_bar()
local cur = math.ceil(math.min(g_max_x, (g_used.cur/g_used.limit)*g_max_x))
write_bar(cur, "normal")
end
function write_time()
box.html(general.sprintf([[{?815:58?}]], g_used.cur))
end
function write_warning()
local tmp_max = g_maxtime
if is_data_vol() then
tmp_max = g_max
end
if (g_used.cur/g_used.limit) < (g_cur/tmp_max) then
local effTage = math.floor((tmp_max/g_cur)*g_used.cur)
local kritTag = g_start.day
local kritMonat = g_start.month
local kritJahr = g_start.year
if g_start.day + effTage > days_in_month(g_start.month, g_start.year) then
kritMonat = kritMonat + 1
if kritMonat > 12 then
kritMonat = 1
kritJahr = kritJahr + 1
end
kritTag = effTage - (days_in_month(g_start.month, g_start.year) - g_start.day)
else
kritTag = g_start.day + effTage
end
local str = ""
local dateformat = [[{?815:704?}]]
local szDateInfo = general.sprintf(dateformat, kritTag, kritMonat, kritJahr)
if is_data_vol() then
--XXX math.floor(box.query??????
--XXX auch weiter unten Rechnen mit box.query-Ergebnisstring???
if (g_cur + math.floor(box.query("connection0:settings/VolumeThreshold")/1000000 + 0.5) <tmp_max) then
str = general.sprintf([[{?815:387?} ]],g_max,szDateInfo)
else
str = general.sprintf([[{?815:192?} ]],g_max);
end
else
if (g_cur + box.query("connection0:settings/ConnectionTimeThreshold") / 60 <tmp_max) then
str = general.sprintf([[{?815:506?} ]],g_max,szDateInfo);
else
str = general.sprintf([[{?815:166?} ]],g_max);
end
end
szDateInfo = general.sprintf(dateformat, g_end.day, g_end.month, g_end.year)
str = str .. general.sprintf([[{?815:680?}]], szDateInfo)
box.out([[<p>]]..box.tohtml(str)..[[</p>]])
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#tStat {
width: 100%;
font-size: 12px;
margin: 15px 0;
}
#tStat td, #tStat th {
text-align: right;
}
#tStat tr.first_row th,
#tStat td.first_col {
background-color: #F8F8F8;
}
#tStat td.first_col {
text-align: left;
}
#tStat td.time {
width: 80px;
}
#tStat td.vol {
}
#tStat td.conn {
padding-right: 20px;
}
table.tab_bars div.meter {
}
table.tab_bars .free {
background-color: #75CCFF;
}
table.tab_bars .normal {
background-color: #006699;
}
table.tab_bars .used {
background-color: #05d905;
}
table.tab_bars .used_a_lot {
background-color: #f20622;
}
table.tab_bars .fill {
background-color: #FFFFFF;
border-left-width: 0px;
}
table.tab_bars .fillonly {
background-color: #FFFFFF;
}
table.tab_bars .bar {
border: 1px solid #C6C7BF;
height: 9px;
display: inline-block;
}
table.tab_bars {
background-color: transparent;
border: none;
}
table.tab_bars td {
padding: 2px 4px;
}
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua box.html(box.glob.script) ?>" name="main_form">
<div class="formular small_indent">
<p>
{?815:993?}
</p>
<div id="uiNoTime" <?lua hideif(g_timeknown) ?>>
<p>
{?815:255?}
</p>
</div>
<div <?lua hideif(not g_timeknown) ?>>
<?lua
write_data_table()
?>
</div>
<div>
<p>
{?815:122?}
</p>
<div class="btn_form">
<button type="submit" name="reset">
{?815:632?}
</button>
</div>
</div>
<hr>
<div>
<h4>
{?815:556?}
</h4>
<div <?lua hideif(not g_budget_enabled or not g_timeknown) ?>>
<table class="tab_bars">
<tr>
<td>{?815:996?}</td>
<td><?lua write_consum_bar()?></td>
<td><?lua write_consum()?></td>
</tr>
<tr>
<td>{?815:349?}</td>
<td><?lua write_time_bar("normal")?></td>
<td><?lua write_time()?></td>
</tr>
</table>
<?lua write_warning() ?>
<div class="btn_form">
<button type="submit" name="editbudget">
{?815:123?}
</button>
</div>
</div>
<div <?lua hideif(g_budget_enabled) ?>>
<p>
{?815:491?}
</p>
<div class="btn_form">
<button type="submit" name="editbudget">
{?815:601?}
</button>
</div>
</div>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="btn_refresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
