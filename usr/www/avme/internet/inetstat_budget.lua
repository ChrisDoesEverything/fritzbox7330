<?lua
g_page_type = "all"
g_page_title = ""
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("general")
require("newval")
require("js")
require("http")
g_back_to_page = http.get_back_to_page( "/internet/inetstat_counter.lua" )
g_menu_active_page = g_back_to_page
g_menu_active_showtabs = true
g_budget_type = "vol"
g_budget_unit = box.query("connection0:settings/VolumeRoundUp/Bytes")
if box.query("connection0:settings/Budget/ConnectionTime") ~= "0" then
g_budget_type = "time"
g_budget_unit = "1000000"
end
local an_start_time_fault = [[{?141:318?}]]
newval.msg.start_time_err_txt = {
[newval.ret.empty] = an_start_time_fault,
[newval.ret.format] = an_start_time_fault,
[newval.ret.outofrange] = an_start_time_fault
}
local an_time_fault=[[{?141:337?}]]
newval.msg.time_budget_err_txt = {
[newval.ret.empty] = an_time_fault,
[newval.ret.format] =an_time_fault,
[newval.ret.outofrange] =an_time_fault
}
local an_vol_fault = [[{?141:926?}]]
newval.msg.vol_budget_err_txt = {
[newval.ret.empty] = an_vol_fault,
[newval.ret.format] = an_vol_fault,
[newval.ret.outofrange] = an_vol_fault
}
function valprog()
if newval.checked("budget_enabled") then
newval.not_empty("budget_start_time", "start_time_err_txt")
newval.char_range_regex("budget_start_time", "decimals", "start_time_err_txt")
newval.num_range("budget_start_time", 1, 31, "start_time_err_txt")
if newval.radio_check("budget_type", "vol") then
newval.not_empty("budget_vol", "vol_budget_err_txt")
newval.char_range_regex("budget_vol", "decimals", "vol_budget_err_txt")
newval.num_range("budget_vol", 0, 999999, "vol_budget_err_txt")
end
if newval.radio_check("budget_type", "time") then
newval.not_empty("budget_time", "time_budget_err_txt")
newval.char_range_regex("budget_time", "decimals", "time_budget_err_txt")
newval.num_range("budget_time", 1, 744, "time_budget_err_txt")
end
end
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(valprog)
if answer.ok then
-- Confirm
end
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
require ("cmtable")
local result = newval.validate(valprog)
if result == newval.ret.ok then
local saveset = {}
cmtable.save_checkbox(saveset, "connection0:settings/Budget/Enabled", "budget_enabled")
if box.post.budget_enabled then
if box.post.warn_only then
cmtable.add_var(saveset, "connection0:settings/Budget/WarnOnly", "0")
else
cmtable.add_var(saveset, "connection0:settings/Budget/WarnOnly", "1")
end
if config.VOL_COUNTER then
cmtable.save_checkbox(saveset, "connection0:settings/VolumeRoundUp/Enabled", "budget_roundup")
if box.post.budget_roundup_bytes then
cmtable.add_var(saveset, "connection0:settings/VolumeRoundUp/Bytes", box.post.budget_roundup_bytes)
end
if box.post.budget_type == "time" then
cmtable.add_var(saveset, "connection0:settings/Budget/VolumeLow", "0")
cmtable.add_var(saveset, "connection0:settings/Budget/VolumeHigh", "0")
local newtime = tostring(tonumber(box.post.budget_time)*3600)
cmtable.add_var(saveset, "connection0:settings/Budget/ConnectionTime", newtime)
else
if tonumber(box.post.budget_vol) then
cmtable.add_var(saveset, "connection0:settings/Budget/VolumeMB", box.post.budget_vol)
end
cmtable.add_var(saveset, "connection0:settings/Budget/ConnectionTime", "0")
end
else
local newtime = tostring(tonumber(box.post.budget_time)*3600)
cmtable.add_var(saveset, "connection0:settings/Budget/ConnectionTime", newtime)
end
cmtable.add_var(saveset, "box:settings/Statistic/StartOfMonth", box.post.budget_start_time)
end
local err, errmsg = box.set_config(saveset)
if err == 0 then
http.redirect(href.get(g_back_to_page))
end
end
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
g_page_help = 'hilfe_budget.html'
g_max_x = 200
function get_bar(val, class)
if val == nil then
return ""
end
local w = val
local fill = g_max_x - w
local str = [[<div class="meter">]]
if w > 0 then
str = str .. [[<div class="bar ]]..class..[[" style="width:]]..w..[[px"></div>]]
if fill > 0 then
str = str .. [[<div class="bar fill" style="width:]]..fill..[[px"></div>]]
end
else
str = str .. [[<div class="bar fillonly" style="width:]]..fill..[[px"></div>]]
end
str = str .. [[</div>]]
return str
end
function write_bar(val, class)
box.out(get_bar(val, class))
end
local g_hours, g_minutes, g_cur, g_max, g_maxtime, g_maxvol = general.get_onlinecounter_data()
function write_budget_type()
box.js(g_budget_type)
end
function write_roundup()
if box.query("connection0:settings/VolumeRoundUp/Enabled") == "1" then
box.out("checked")
end
end
function write_roundup_sel(unit)
if g_budget_unit == unit then
box.out("selected")
end
end
function write_budget_enabled()
if box.query("connection0:settings/Budget/Enabled") == "1" then
box.out("checked")
end
end
function write_budget_checked(budget_type)
if g_budget_type == budget_type then
box.out("checked")
end
end
function write_budget_value(budget_type)
if "vol" == budget_type then
if g_budget_type == "vol" then
box.html(tostring(g_max))
else
box.html("0")
end
elseif "time" == budget_type then
if g_budget_type == "time" then
box.html(tostring(g_max))
else
box.html("0")
end
end
end
function write_additional()
box.out([[<p>]])
local txt_withlink
if config.VOL_COUNTER then
txt_withlink = [[{?141:801?}]]
else
txt_withlink = [[{?141:150?}]]
end
local linkbegin = [[<a class="textlink" href="]] .. href.get("/system/infoled.lua") .. [[">]]
local linkend = [[</a>]]
txt_withlink = general.sprintf(box.tohtml(txt_withlink), linkbegin, linkend)
box.out(txt_withlink)
box.out([[</p>]])
if (general.is_router()) then
local disconnect = box.query("connection0:settings/Budget/WarnOnly") ~= "1"
if disconnect then
box.out([[<p>]])
box.html([[{?141:485?}]])
box.out([[</p>]])
local labeltxt = [[{?141:703?}]]
if config.VOL_COUNTER then
labeltxt = [[{?141:77?}]]
end
box.out([[
<input type="checkbox" id="uiDisconnect" name="warn_only" checked>
<label for="uiDisconnect">
]])
box.html(labeltxt)
box.out([[</label>]])
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
div.meter {
margin-bottom: 3px;
}
.free {
background-color: #75CCFF;
}
.normal {
background-color: #006699;
}
.used {
background-color: #05d905;
}
.used_a_lot {
background-color: #f20622;
}
.fill {
background-color: #FFFFFF;
border-left-width: 0px;
}
.fillonly {
background-color: #FFFFFF;
}
.bar {
border: 1px solid #C6C7BF;
height: 9px;
display: inline-block;
}
.tab_bars {
background-color: transparent;
border: none;
}
.tab_bars td {
padding: 2px;
}
</style>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_BudgetType="<?lua write_budget_type()?>";
var g_BudgetEnabled=<?lua box.js(tostring(box.query("connection0:settings/Budget/Enabled")=="1"))?>;
var g_BudgetRoundup=<?lua box.js(tostring((box.query("connection0:settings/VolumeRoundUp/Enabled")=="1")))?>;
function OnToggleBudgetType(which_budget)
{
jxl.disableNode("uiVolBlock",which_budget!="vol");
jxl.disableNode("uiTimeBlock",which_budget!="time");
g_BudgetType=which_budget;
if (which_budget=="vol")
{
OnToggleRoundUp(g_BudgetRoundup);
}
}
function OnToggleBudget(enabled)
{
jxl.disableNode("uiBudgetBlock",!enabled);
OnToggleBudgetType(g_BudgetType)
g_BudgetEnabled=enabled;
}
function OnToggleRoundUp (checked)
{
jxl.setDisabled("uiViewRoundUpBytes",!checked);
g_BudgetRoundup=checked;
}
function uiDoOnMainFormSubmit() {
return true;
}
function doConfirm() {
var startOfMonth = "<?lua box.js(tostring(box.query('box:settings/Statistic/StartOfMonth')))?>";
if (jxl.getValue("uiViewStartOfMonth") != startOfMonth) {
if (!confirm("{?141:95?}")) {
return false;
}
}
}
function init() {
OnToggleBudget(g_BudgetEnabled);
}
ready.onReady(init);
ready.onReady(ajaxValidation({
okCallback: doConfirm
}));
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="<?lua box.html(box.glob.script) ?>" name="main_form">
<h4>
{?141:521?}
</h4>
<div>
<p>
{?141:156?}
</p>
<input type="checkbox" name="budget_enabled" id="uiBudgetEnabled"
onclick="OnToggleBudget(this.checked)" <?lua write_budget_enabled()?>>
<label for="uiBudgetEnabled">
{?141:990?}
</label>
<div id="uiBudgetBlock" class="formular">
<input type="radio" name="budget_type" id="uiVolBudget" value="vol"
onclick="OnToggleBudgetType('vol')" <?lua write_budget_checked('vol')?>>
<label for="uiVolBudget">
{?141:178?}
</label>
<div id="uiVolBlock" class="formular">
<input type="text" size="7" maxlength="6" id="uiVolValue" name="budget_vol"
style="text-align: right" value="<?lua write_budget_value('vol')?>">
{?141:657?}
<br>
{?141:931?}
<br>
<input type="checkbox" id="uiViewRoundUpOn" name="budget_roundup"
onclick="OnToggleRoundUp(this.checked)" <?lua write_roundup()?>>
<label for="uiViewRoundUpOn">
{?141:246?}
</label>
<select id="uiViewRoundUpBytes" name="budget_roundup_bytes">
<option value="1000" <?lua write_roundup_sel("1000")?>>
{?141:145?}
</option>
<option value="1000000" <?lua write_roundup_sel("1000000")?>>
{?141:359?}
</option>
</select>
</div>
<input type="radio" name="budget_type" id="uiTimeBudget" value="time"
onclick="OnToggleBudgetType('time')" <?lua write_budget_checked('time')?>>
<label for="uiTimeBudget">
{?141:676?}
</label>
<div id="uiTimeBlock" class="formular">
<input type="text" size="6" maxlength="3" name="budget_time" id="uiTimeValue"
style="text-align: right" value="<?lua write_budget_value('time')?>">
{?141:869?}
<br>
{?141:407?}
</div>
<div>
<label for="uiViewStartOfMonth" style="width:auto">
{?141:313?}
</label>
<input type="text" size="3" maxlength="2" name="budget_start_time" id="uiViewStartOfMonth"
value="<?lua box.html(tostring(box.query('box:settings/Statistic/StartOfMonth')))?>">
{?141:245?}
</div>
<div>
<?lua write_additional() ?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button name="apply">{?txtOK?}</button>
<button name="cancel" >{?txtCancel?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
