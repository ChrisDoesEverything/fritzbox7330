<?lua
g_page_type = "all"
g_page_title = "{?6058:315?}"
dofile("../templates/global_lua.lua")
require("general")
require("cmtable")
require("val")
g_hastime = (box.query("box:status/localtime") ~= "")
g_page_help = "hilfe_system_nachtschaltung.html"
if g_hastime then
g_page_help = "hilfe_system_nachtschalt_klingel.html"
end
g_val = {
prog = [[
if __checked(uiActive/active) then
clock_time(uiStartHour/start_hour, uiStartMinute/start_minute, starttime)
clock_time(uiEndHour/end_hour, uiEndMinute/end_minute, endtime)
end
]]
}
val.msg.starttime = {
[val.ret.empty] = [[{?6058:189?}]],
[val.ret.format] = [[{?6058:582?}]],
[val.ret.outofrange] = [[{?6058:254?}]]
}
val.msg.endtime = {
[val.ret.empty] = [[{?6058:93?}]],
[val.ret.format] = [[{?6058:825?}]],
[val.ret.outofrange] = [[{?6058:20?}]]
}
g_active = false
g_start_hour = ""
g_start_minute = ""
g_end_hour = ""
g_end_minute = ""
function read_box_values()
g_active = (box.query("box:settings/night_time_control_enabled") == "1") and (box.query("box:settings/night_time_control_ring_blocked") == "1")
g_start_hour, g_start_minute = string.match(box.query("box:settings/night_time_control_off_time"), "(%d+):(%d+)")
g_start_hour = g_start_hour or ""
g_start_minute = g_start_minute or ""
g_end_hour, g_end_minute = string.match(box.query("box:settings/night_time_control_on_time"), "(%d+):(%d+)")
g_end_hour = g_end_hour or ""
g_end_minute = g_end_minute or ""
end
function refill_user_input()
g_active = (box.post.active ~= nil)
g_start_hour = box.post.start_hour
g_start_minute = box.post.start_minute
g_end_hour = box.post.end_hour
g_end_minute = box.post.end_minute
end
function time_to_device(saveset, node)
if box.query(node.."/NoRingWithNightSetting")=="1" then
cmtable.add_var(saveset, node.."/RingAllowed", "1")
if box.post.active then
cmtable.add_var(saveset, node.."/NoRingTime",
string.format("%02d", tonumber(box.post.start_hour)) ..
string.format("%02d", tonumber(box.post.start_minute)) ..
string.format("%02d", tonumber(box.post.end_hour)) ..
string.format("%02d", tonumber(box.post.end_minute)))
else
cmtable.add_var(saveset, node.."/NoRingTime", "")
end
end
end
if next(box.post) and box.post.apply then
if val.validate(g_val) == val.ret.ok then
local saveset = {}
if box.post.active then
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "1")
cmtable.add_var(saveset, "box:settings/night_time_control_ring_blocked", "1")
cmtable.add_var(saveset, "box:settings/night_time_control_off_time",
string.format("%02d", tonumber(box.post.start_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.start_minute)))
cmtable.add_var(saveset, "box:settings/night_time_control_on_time",
string.format("%02d", tonumber(box.post.end_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.end_minute)))
if config.DECT_NO_EMISSION then
cmtable.add_var(saveset, "dect:settings/NightTime",
string.format("%02d", tonumber(box.post.start_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.start_minute)) ..
string.format("%02d", tonumber(box.post.end_hour)) .. ":" ..
string.format("%02d", tonumber(box.post.end_minute)))
end
else
cmtable.add_var(saveset, "box:settings/night_time_control_ring_blocked", "0")
if config.WLAN and not config.TIMERCONTROL then
if box.query("wlan:settings/night_time_control_enabled") == "0" then
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "0")
end
else
cmtable.add_var(saveset, "box:settings/night_time_control_enabled", "0")
end
end
if box.post.active then
for ab=1,config.AB_COUNT do
time_to_device(saveset, "telcfg:settings/MSN/Port"..tostring(ab-1))
end
if config.CAPI_TE then
time_to_device(saveset, "telcfg:settings/MSN/Port3")
end
box.query("telcfg:settings/Foncontrol")
for fc=1,tonumber(box.query("telcfg:settings/Foncontrol/User/count")) do
time_to_device(saveset, "telcfg:settings/Foncontrol/User"..tostring(fc-1))
end
end
local errcode, errmsg = box.set_config(saveset)
if errcode == 0 then
if box.post.active then
read_box_values()
else
http.redirect(href.get("/system/syslog.lua"))
end
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
local start_h = general.sprintf(timeinp, "start_hour", "uiStartHour", g_start_hour, val.get_attrs(g_val, "uiStartHour"))
local start_m = general.sprintf(timeinp, "start_minute", "uiStartMinute", g_start_minute, val.get_attrs(g_val, "uiStartMinute"))
if g_end_hour == "00" and g_end_minute == "00" then
g_end_hour = "24"
end
local end_h = general.sprintf(timeinp, "end_hour", "uiEndHour", g_end_hour, val.get_attrs(g_val, "uiEndHour"))
local end_m = general.sprintf(timeinp, "end_minute", "uiEndMinute", g_end_minute, val.get_attrs(g_val, "uiEndMinute"))
local start_str = general.sprintf("%1:%2", start_h, start_m)
local end_str = general.sprintf("%1:%2", end_h, end_m)
g_daily_line = general.sprintf([[{?6058:210?}]], start_str, end_str)
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function init() {
jxl.addEventHandler("uiActive", "click", uiDoOnActiveChanged);
uiDoOnActiveChanged();
}
function uiDoOnActiveChanged() {
jxl.disableNode("uiActiveArea", !jxl.getChecked("uiActive"));
}
function uiDoOnMainFormSubmit() {
var ret;
<?lua
val.write_js_checks(g_val)
?>
return true;
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<p>{?6058:275?}</p>
<hr>
<div id="uiViewHasTime" <?lua if not(g_hastime) then box.out([[style="display:none;"]]) end ?>>
<form action="/system/ring_block.lua" method="POST" name="main_form">
<h4>{?6058:311?}</h4>
<div class="formular">
<input type="checkbox" name="active" id="uiActive" <?lua if g_active then box.out("checked") end ?>>
<label for="uiActive">{?6058:961?}</label>
<div class="formular" id="uiActiveArea">
<?lua
box.out(g_daily_line)
val.write_html_msg(g_val, "uiStartHour", "uiStartMinute", "uiEndHour", "uiEndMinute")
?>
<p>
<?lua box.out(general.sprintf([[{?6058:255?}]],[[<a href="]]..href.get("/fon_devices/fondevices_list.lua")..[[">]],"</a>")) ?>
</p>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
</div>
<div id="uiViewHasNoTime" <?lua if g_hastime then box.out([[style="display:none;"]]) end ?>>
<p>
{?6058:930?}
</p>
</div>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
