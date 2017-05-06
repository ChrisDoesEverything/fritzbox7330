<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_dslinfo_ATM.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("libluadsl")
if (next(box.post) and (box.post.cancel)) then
http.redirect([[/internet/dsl_stats_graph.lua]])
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
local stats = luadsl.getLongTimeStats(1, "DS")
g_data.statistics = {
volume = stats.DAY_PER_HOUR_STAT_SW_RETRAIN,
snr = stats.DAY_PER_HOUR_STAT_NOISE_MARGIN_MIN,
crc = stats.DAY_PER_HOUR_STAT_CRC,
resync = stats.DAY_PER_HOUR_STAT_RESYNC
}
g_data.range = {
volume = {min=0,max=1},
snr = {min=0,max=4},
crc = {min=0,max=4},
resync = {min=0,max=4}
}
function Find_Maximum(s)
local w = tonumber(s[1][3]) or 0
for i=1, #s do
local x=tonumber(s[i][3]) or 0
if ( x > w ) then
w = x
end
end
if (w==0) then
w=4
end
local m = w % 4;
if (m~=0) then
w = w + (4 - m)
end
return w;
end
function get_var()
end
function refill_user_input()
end
local function create_scale_func(min1, max1, min2, max2)
local factor = (max2 - min2) / (max1 - min1)
local add = min2 - min1 * factor
return function(val)
val[3] = math.round(val[3] * factor + add)
return val
end
end
local function get_values(which)
local values = {}
values = g_data.statistics[which]
values = array.revert(values)
return values
end
local function scale_values(which, values, drawheight)
if (not values or #values==0) then
return {
min_value = 0,
max_value = 0,
values = values
}
end
local min_value = g_data.range[which].min
local max_value=Find_Maximum(values)
values = array.map(values, function(v)
v[3] = tonumber(v[3]) or min_value
v[3] = math.max(min_value, math.min(max_value, v[3]))
return v
end
)
local scale = create_scale_func(min_value, max_value, 0, drawheight)
values = array.map(values, function(v) return scale(v) end)
return {
min_value = min_value,
max_value = max_value,
values = values
}
end
local function scale_values_array(which, values, drawheight)
return scale_values(which,values,drawheight)
end
local function write_value(value,id,cur)
local bottom = 37
local height = value
if value > 0 then
bottom = bottom + height - 1
box.out([[<div class="valuetop]]..id..[[" style="bottom:]] .. bottom .. [[px;"></div>]])
height = height - 1
bottom = bottom - height
box.out([[<div class="value]]..id..[[ ]]..cur..[[" style="height:]] .. height .. [[px;bottom:]] .. bottom .. [[px;"></div>]])
end
end
local function write_column(hour, value1, value2, cur)
box.out([[<div class="statscolumn">]])
if value1 then
write_value(value1,"",cur)
end
box.out([[<div class="xscale">]])
box.html(hour)
box.out([[</div>]])
box.out([[</div>]])
end
local function write_columns(obj)
local values = obj.values
box.out([[<div class="statscolumn firststatscolumn">]])
box.out([[<div class="yscale ymax">]])
box.html(obj.max_value)
box.out([[</div>]])
box.out([[<div class="yscale ymin">]])
box.html(obj.min_value)
box.out([[</div>]])
box.out([[</div>]])
local cur=""
for i, elem in ipairs(values) do
if i == 24 then
cur="cur"
end
write_column(elem[2], elem[3],nil,cur)
end
end
function write_volume_columns()
local volume = get_values('volume')
volume = scale_values_array('volume', volume, 80)
write_columns(volume)
end
function write_snr_columns()
local snr = get_values('snr')
snr = scale_values_array('snr', snr, 80)
write_columns(snr)
end
function write_crc_columns()
local crc = get_values('crc')
crc = scale_values_array('crc', crc, 80)
write_columns(crc)
end
function write_resync_columns()
local resync = get_values('resync')
resync = scale_values_array('resync', resync, 80)
write_columns(resync)
end
function write_snr_graph()
box.out([[
<div class="statsContainer">
<h4 class="statshead">]]..box.tohtml([[{?664:643?}]])..[[</h4>
<p class="xaxislegend"></p>
<div class="statsGraphic">]])
write_snr_columns()
box.out([[
</div>
<p class="yaxislegend">]]..box.tohtml([[{?664:477?}]])..[[</p>
</div>]])
end
function write_crc_graph()
box.out([[
<div class="statsContainer">
<h4 class="statshead">]]..box.tohtml([[{?664:685?}]])..[[</h4>
<p class="xaxislegend"></p>
<div class="statsGraphic">]])
write_crc_columns()
box.out([[
</div>
<p class="yaxislegend">]]..box.tohtml([[{?664:903?}]])..[[</p>
</div>]])
end
function write_resync_graph()
box.out([[
<div class="statsContainer">
<h4 class="statshead">]]..box.tohtml([[{?664:161?}]])..[[</h4>
<p class="xaxislegend"></p>
<div class="statsGraphic">]])
write_resync_columns()
box.out([[
</div>
<p class="yaxislegend">]]..box.tohtml([[{?664:36?}]])..[[</p>
</div>]])
end
if next(box.post) and (box.post.send ) then
end
if box.get.update == "mainDiv" or false then
write_snr_graph()
write_crc_graph()
write_resync_graph()
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/columns.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function updateInfo(refresh) {
var timeOut = 5000;
if (refresh) {
timeOut = 0;
}
var page = "<?lua box.js(box.glob.script) ?>";
var sid = "<?lua box.js(box.glob.sid) ?>";
ajaxUpdateHtml("mainDiv", page, sid, timeOut);
}
function init()
{
updateInfo();
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="mainDiv">
<?lua
write_snr_graph()
write_crc_graph()
write_resync_graph()
?>
</div>
<div id="btn_form_foot">
<button type="button" name="cancel" onclick="updateInfo(true)">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
