<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("val")
if config.TIMERCONTROL then
require("timer")
g_timer_id = "uiTimer"
end
g_hastime = (box.query("box:status/localtime") ~= "")
g_fon = config.FON
g_button = config.BUTTON
function fbox_sync_avail()
return config.WLAN.has_night_time_auto_update
end
g_page_help = "hilfe_system_nachtschaltung.html"
if g_hastime then
g_page_help = "hilfe_system_nachtschalt_wlan.html"
end
g_txt_intro = [[{?9178:425?}]]
if g_button then
if g_fon then
g_txt_intro = g_txt_intro .. [[ {?9178:845?}]]
else
g_txt_intro = g_txt_intro .. [[ {?9178:285?}]]
end
else
if g_fon then
g_txt_intro = g_txt_intro .. [[ {?9178:125?}]]
end
end
if config.TIMERCONTROL then
if fbox_sync_avail() then
g_val = {
prog = [[
if __checked(uiActive/active) then
if __not_checked(uiSyncWithFbox/sync_with_fbox) then
if __radio_check(uiDaily/mode,daily) then
clock_time(uiStartHour/start_hour, uiStartMinute/start_minute, starttime)
clock_time(uiEndHour/end_hour, uiEndMinute/end_minute, endtime)
end
end
end
]]
}
else
g_val = {
prog = [[
if __checked(uiActive/active) then
if __radio_check(uiDaily/mode,daily) then
clock_time(uiStartHour/start_hour, uiStartMinute/start_minute, starttime)
clock_time(uiEndHour/end_hour, uiEndMinute/end_minute, endtime)
end
end
]]
}
end
else
if fbox_sync_avail() then
g_val = {
prog = [[
if __checked(uiActive/active) then
if __not_checked(uiSyncWithFbox/sync_with_fbox) then
clock_time(uiStartHour/start_hour, uiStartMinute/start_minute, starttime)
clock_time(uiEndHour/end_hour, uiEndMinute/end_minute, endtime)
end
end
]]
}
else
g_val = {
prog = [[
if __checked(uiActive/active) then
clock_time(uiStartHour/start_hour, uiStartMinute/start_minute, starttime)
clock_time(uiEndHour/end_hour, uiEndMinute/end_minute, endtime)
end
]]
}
end
end
val.msg.starttime = {
[val.ret.empty] = [[{?9178:561?}]],
[val.ret.format] = [[{?9178:683?}]],
[val.ret.outofrange] = [[{?9178:397?}]]
}
val.msg.endtime = {
[val.ret.empty] = [[{?9178:758?}]],
[val.ret.format] = [[{?9178:128?}]],
[val.ret.outofrange] = [[{?9178:257?}]]
}
g_active = false
g_start_hour = ""
g_start_minute = ""
g_end_hour = ""
g_end_minute = ""
g_soft_off = false
g_daily = true
if (fbox_sync_avail()) then
g_sync_with_fbox = false
else
g_sync_with_fbox = true
end
g_sync_with_fbox_state = ""
function get_fbox_sync()
return g_sync_with_fbox
end
function read_box_values()
if config.TIMERCONTROL then
timer.read_wlan(g_timer_id)
g_active = timer.active(g_timer_id)
g_daily = timer.daily_mode(g_timer_id)
g_start_hour = string.sub(timer.daily_end(g_timer_id), 1, 2)
g_start_minute = string.sub(timer.daily_end(g_timer_id), -2)
g_end_hour = string.sub(timer.daily_start(g_timer_id), 1, 2)
g_end_minute = string.sub(timer.daily_start(g_timer_id), -2)
g_sync_with_fbox_state = box.query("wlan:settings/time_control_update_status")
else
g_active = (box.query("box:settings/night_time_control_enabled") == "1") and (box.query("wlan:settings/night_time_control_enabled") == "1")
g_start_hour, g_start_minute = string.match(box.query("box:settings/night_time_control_off_time"), "(%d+):(%d+)")
g_start_hour = g_start_hour or ""
g_start_minute = g_start_minute or ""
g_end_hour, g_end_minute = string.match(box.query("box:settings/night_time_control_on_time"), "(%d+):(%d+)")
g_end_hour = g_end_hour or ""
g_end_minute = g_end_minute or ""
end
if (fbox_sync_avail()) then
g_sync_with_fbox = (box.query("wlan:settings/night_time_control_auto_update")=="1")
if g_sync_with_fbox then
g_active=g_sync_with_fbox
end
end
g_soft_off = (box.query("wlan:settings/night_time_control_no_forced_off") == "1")
end
function refill_user_input()
g_active = (box.post.active ~= nil)
g_soft_off = (box.post.soft ~= nil)
g_start_hour = box.post.start_hour
g_start_minute = box.post.start_minute
g_end_hour = box.post.end_hour
g_end_minute = box.post.end_minute
if config.TIMERCONTROL then
g_daily = (box.post.mode == "daily")
end
g_sync_with_fbox=false
if (box.post.sync_with_fbox) then
g_sync_with_fbox=true
end
end
if next(box.post) and box.post.apply then
if val.validate(g_val) == val.ret.ok then
local saveset = {}
if config.TIMERCONTROL then
if (box.post.sync_with_fbox==nil) then
timer.read_wlan(g_timer_id)
cmtable.add_var(saveset, "timer:settings/WLANTimerXML0", timer.get_wlan_daily_xml(g_timer_id, box.post.active and box.post.mode=="daily"))
if timer.has_wlan_timeplan(g_timer_id) or (box.post.active and box.post.mode=="timer") then
cmtable.add_var(saveset, "timer:settings/WLANTimerXML1", timer.get_wlan_timeplan_xml(g_timer_id, box.post.active and box.post.mode=="timer"))
end
end
else
if box.post.active then
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "1")
cmtable.add_var(saveset, "wlan:settings/night_time_control_enabled", "1")
cmtable.add_var(saveset, "box:settings/night_time_control_off_time",
string.format("%02d", tonumber(box.post.start_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.start_minute)))
cmtable.add_var(saveset, "box:settings/night_time_control_on_time",
string.format("%02d", tonumber(box.post.end_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.end_minute)))
else
cmtable.add_var(saveset, "wlan:settings/night_time_control_enabled", "0")
if g_fon then
if box.query("box:settings/night_time_control_ring_blocked") == "0" then
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "0")
end
else
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "0")
end
end
end
if (fbox_sync_avail()) then
cmtable.save_checkbox(saveset, "wlan:settings/night_time_control_auto_update", "sync_with_fbox")
end
if (box.post.sync_with_fbox==nil) then
cmtable.save_checkbox(saveset, "wlan:settings/night_time_control_no_forced_off", "soft")
end
local errcode, errmsg = box.set_config(saveset)
if errcode == 0 then
read_box_values()
else
refill_user_input()
g_val.errmsg = errmsg
end
else
refill_user_input()
end
else
read_box_values()
end
local timeinp = [[<input type="text" size="3" maxlength="2" name="%1" id="%2" value="%3" %4>]]
local start_h = general.sprintf(timeinp, "start_hour", "uiStartHour", box.tohtml(g_start_hour), val.get_attrs(g_val, "uiStartHour"))
local start_m = general.sprintf(timeinp, "start_minute", "uiStartMinute", box.tohtml(g_start_minute), val.get_attrs(g_val, "uiStartMinute"))
if g_end_hour == "00" and g_end_minute == "00" then
g_end_hour = "24"
end
local end_h = general.sprintf(timeinp, "end_hour", "uiEndHour", box.tohtml(g_end_hour), val.get_attrs(g_val, "uiEndHour"))
local end_m = general.sprintf(timeinp, "end_minute", "uiEndMinute", box.tohtml(g_end_minute), val.get_attrs(g_val, "uiEndMinute"))
local start_str = general.sprintf("%1:%2", start_h, start_m)
local end_str = general.sprintf("%1:%2", end_h, end_m)
local labelstart=[[<label for="uiDaily">]]
local labelend=[[</label>]]
if not(config.TIMERCONTROL) then
labelstart=[[]]
labelend =[[]]
end
g_daily_line = general.sprintf([[{?9178:184?}]], labelstart,labelend,start_str, end_str)
?>
<?include "templates/html_head.html" ?>
<?lua
if config.TIMERCONTROL then
box.out([[
<link rel="stylesheet" type="text/css" href="/css/default/timer.css"/>
<script type="text/javascript" src="/js/timer.js"></script>
]])
end
?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
if config.TIMERCONTROL then
box.out([[
var g_timer = null;
]])
if not timer.has_wlan_timeplan(g_timer_id) then
box.out([[
var g_data = [ [new Period(new Moment(0,5,0), new Moment(0,23,0))],[new Period(new Moment(1,5,0), new Moment(1,23,0))],[new Period(new Moment(2,5,0), new Moment(2,23,0))],[new Period(new Moment(3,5,0), new Moment(3,23,0))],[new Period(new Moment(4,5,0), new Moment(4,23,0))],[new Period(new Moment(5,5,0), new Moment(5,23,0))],[new Period(new Moment(6,5,0), new Moment(6,23,0))] ];
]])
else
box.out([[
var g_data = ]]..timer.get_data_js(g_timer_id)..[[;
]])
end
end
val.write_js_error_strings()
?>
var g_sync_with_fbox_avail=<?lua box.js(tostring(fbox_sync_avail()))?>;
var g_sync_with_fbox=<?lua box.js(tostring(get_fbox_sync())) ?>;
function init() {
jxl.addEventHandler("uiActive", "click", uiDoOnActiveChanged);
jxl.addEventHandler("uiSyncWithFbox", "click", uiDoOnSyncChanged);
<?lua
if config.TIMERCONTROL and g_hastime then
box.out([[
g_timer = new Timer("]]..g_timer_id..[[", g_data);
jxl.addEventHandler("uiDaily", "click", uiDoOnModeClicked);
jxl.addEventHandler("uiUseTimer", "click", uiDoOnModeClicked);
uiDoOnModeClicked();
]])
end
?>
uiDoOnActiveChanged();
}
function uiDoOnSyncChanged() {
g_sync_with_fbox=jxl.getChecked("uiSyncWithFbox");
uiDoOnActiveChanged();
}
function uiDoOnActiveChanged() {
if (g_sync_with_fbox_avail)
{
jxl.disableNode("uiActiveArea", !jxl.getChecked("uiActive"));
jxl.disableNode("uiActiveArea2", (jxl.getChecked("uiActive")&&g_sync_with_fbox));
}
else
{
jxl.disableNode("uiActiveArea", !jxl.getChecked("uiActive"));
}
<?lua
if config.TIMERCONTROL and g_hastime then
box.out([[
g_timer.disabled = !jxl.getChecked("uiActive");
if (jxl.getChecked("uiActive")) {
uiDoOnModeClicked();
}
]])
end
?>
}
function uiDoOnMainFormSubmit() {
var ret;
<?lua
val.write_js_checks(g_val)
if config.TIMERCONTROL and g_hastime then
box.out([[
if (jxl.getChecked("uiUseTimer"))
g_timer.save("uiMainForm");
]])
end
?>
return true;
}
<?lua
if config.TIMERCONTROL then
box.out([[
function uiDoOnModeClicked() {
jxl.setDisabled("uiStartHour", jxl.getChecked("uiUseTimer"));
jxl.setDisabled("uiStartMinute", jxl.getChecked("uiUseTimer"));
jxl.setDisabled("uiEndHour", jxl.getChecked("uiUseTimer"));
jxl.setDisabled("uiEndMinute", jxl.getChecked("uiUseTimer"));
jxl.display("uiTimerArea", jxl.getChecked("uiUseTimer"));
}
]])
end
?>
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<?lua
box.html(g_txt_intro)
?>
<hr>
<div id="uiViewHasTime" <?lua if not(g_hastime) then box.out([[style="display:none;"]]) end ?>>
<form action="/system/wlan_night.lua" method="POST" id="uiMainForm" name="main_form">
<h4>{?9178:191?}</h4>
<div class="formular">
<input type="checkbox" name="active" id="uiActive" <?lua if g_active then box.out("checked") end ?>>
<label for="uiActive">{?9178:92?}</label>
<div class="formular" id="uiActiveArea">
<?lua
if (fbox_sync_avail()) then
box.out([[<input type="checkbox" name="sync_with_fbox" id="uiSyncWithFbox"]])
if (get_fbox_sync()) then box.out("checked") end
box.out([[>
<label for="uiSyncWithFbox">{?9178:696?}</label>
<div class="formular" id="uiActiveArea2">
]])
end
?>
<input type="checkbox" name="soft" id="uiSoft" <?lua if g_soft_off then box.out("checked") end ?>>
<label for="uiSoft">{?9178:984?}</label>
<br>
<input type="radio" name="mode" id="uiDaily" value="daily"
<?lua
if g_daily then box.out(" checked ") end;
if not(config.TIMERCONTROL) then box.out([[style="display:none;"]]) end
?>
>
<?lua
box.out(g_daily_line)
val.write_html_msg(g_val, "uiStartHour", "uiStartMinute", "uiEndHour", "uiEndMinute")
?>
<div <?lua if not(config.TIMERCONTROL) then box.out([[style="display:none;"]]) end ?>>
<input type="radio" name="mode" id="uiUseTimer" value="timer" <?lua if not g_daily then box.out(" checked") end ?>>
<label for="uiUseTimer">{?9178:849?}</label>
<div id="uiTimerArea" class="formular">
<?lua
timer.write_html(g_timer_id, {
active = [[{?9178:903?}]],
inactive = [[{?9178:760?}]]
})
?>
</div>
</div>
<?lua
if (fbox_sync_avail()) then
box.out([[</div>]])
end
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<?lua
if (fbox_sync_avail()) then
box.out([[<button type="submit" name="refresh">{?txtRefresh?}</button>]])
end
?>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
</div>
<div id="uiViewHasNoTime" <?lua if g_hastime then box.out([[style="display:none;"]]) end ?>>
<p>{?9178:566?}</p>
</div>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
