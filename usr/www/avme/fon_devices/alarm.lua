<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_wecker.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("fon_devices")
require("bit")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_devices/alarm.lua" )
g_val = {
prog = [[
if __checked(uiViewActive/active) then
length(uiViewHour/hour, 2, 2, empty_allowed, error_txt)
length(uiViewMin/minutes, 2, 2, empty_allowed, error_txt)
char_range_regex(uiViewHour/hour, decimals, error_txt)
char_range_regex(uiViewMin/minutes, decimals, error_txt)
num_range(uiViewHour/hour,0,23,error_txt_hour)
num_range(uiViewMin/minutes,0,59,error_txt_min)
length(uiViewName/name,1,20, error_name)
end
]]
}
local msg=[[{?79:252?}]]
val.msg.error_txt = {
[val.ret.tooshort] = msg,
[val.ret.empty] = msg,
[val.ret.outofrange] = [[{?79:598?}]],
}
val.msg.error_txt_hour = {
[val.ret.outofrange] = [[{?79:882?}]],
}
val.msg.error_txt_min = {
[val.ret.outofrange] = [[{?79:327?}]],
}
val.msg.error_name = {
[val.ret.notfound] = [[{?79:304?}]],
[val.ret.tooshort] = [[{?79:993?}]],
[val.ret.toolong] = [[{?79:374?}]]
}
if (next(box.post) and (box.post.cancel)) then
end
g_data={}
if (box.get.tab) then
g_data.alarm_id=box.get.tab
elseif box.post.curtab then
g_data.alarm_id=box.post.curtab
else
g_data.alarm_id="0"
end
function get_weekday_flags_from_post()
local weekdays=0
if box.post.option=="per_day" then
if (box.post._mo) then
weekdays=bit.set(weekdays,0)
end
if (box.post._di) then
weekdays=bit.set(weekdays,1)
end
if (box.post._mi) then
weekdays=bit.set(weekdays,2)
end
if (box.post._do) then
weekdays=bit.set(weekdays,3)
end
if (box.post._fr) then
weekdays=bit.set(weekdays,4)
end
if (box.post._sa) then
weekdays=bit.set(weekdays,5)
end
if (box.post._so) then
weekdays=bit.set(weekdays,6)
end
elseif box.post.option=="only_once" then
weekdays=0
elseif box.post.option=="daily" then
weekdays=127
else
weekdays=box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Weekdays")
end
return weekdays
end
if (next(box.post) and (box.post.apply)) then
local result=val.validate(g_val)
if ( result== val.ret.ok) then
local saveset={}
if box.post.active then
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Active", "1")
g_data.name =box.post.name
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Name", g_data.name)
local timestr=box.post.hour..box.post.minutes
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Time", timestr)
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Number", box.post.device )
local weekdays=get_weekday_flags_from_post()
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Weekdays", tostring(weekdays))
g_data.active ="1"
g_data.time =timestr
g_data.number =box.post.device
g_data.weekdays=weekdays
else
cmtable.add_var( saveset, "telcfg:settings/AlarmClock"..g_data.alarm_id.."/Active", "0")
g_data.active ="0"
g_data.time =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Time")
g_data.number =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Number")
g_data.weekdays=box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Weekdays")
end
local err, msg = box.set_config( saveset)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
end
g_data.active = "0"
if box.post.active then
g_data.active = "1"
end
local timestr=""
if (box.post.hour and box.post.minutes) then
timestr=box.post.hour..box.post.minutes
else
timestr=box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Time")
end
g_data.time =timestr
g_data.number =box.post.device or box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Number")
g_data.weekdays=get_weekday_flags_from_post()
g_data.name =box.post.name or box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Name")
else
g_data.active =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Active")
g_data.time =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Time")
g_data.number =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Number")
g_data.weekdays=box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Weekdays")
g_data.name =box.query("telcfg:settings/AlarmClock"..g_data.alarm_id.."/Name")
end
local mask=bit.maskand(tonumber(g_data.weekdays)or 0,127)
g_data.day={
["_mo"] = false,
["_di"] = false,
["_mi"] = false,
["_do"] = false,
["_fr"] = false,
["_sa"] = false,
["_so"] = false
}
if mask==0 then
g_data.option="only_once"
elseif mask==127 then
g_data.option="daily"
else
g_data.option = "per_day"
g_data.day={
["_mo"] = bit.isset(mask,0),
["_di"] = bit.isset(mask,1),
["_mi"] = bit.isset(mask,2),
["_do"] = bit.isset(mask,3),
["_fr"] = bit.isset(mask,4),
["_sa"] = bit.isset(mask,5),
["_so"] = bit.isset(mask,6)
}
end
function write_per_day_visible()
if (g_data.option~="per_day") then
box.out([[display:none;]])
end
end
function write_day(cur_day)
if (g_data.day[cur_day]) then
box.out([[ checked="checked"]])
end
if (g_data.option~="per_day") then
box.out([[ disabled]])
end
end
function write_option_checked(cur_option)
if (cur_option==g_data.option) then
box.out([[checked="checked"]])
end
end
function write_fondevices()
local fondevs=fon_devices.get_all_fon_devices()
local sel=""
local no_selected=true
if (fon_devices.is_any_fondevice_configured(fondevs)) then
for i,elem in ipairs(fondevs) do
sel=""
if (g_data.number==tostring(elem.intern_id)) then
no_selected=false
sel=[[selected]]
end
if (elem.intern_id==50) then
elem.name=[[{?79:391?}]]
end
if (elem.type~="door" and elem.type~="tam" and elem.type~="fax" and elem.type~="faxintern") then
box.out([[<option value="]]..box.tohtml(elem.intern_id)..[[" ]]..sel..[[>]]..box.tohtml(elem.name)..[[</option>]])
end
end
else
local fon = {
[[{?79:671?}]],
[[{?79:122?}]],
[[{?79:228?}]]
}
for i=1,config.AB_COUNT do
sel=""
if (g_data.number==tostring(i)) then
no_selected=false
sel=[[selected]]
end
local x,elem=fon_devices.find_elem(fondevs,"fon123","intern_id",tostring(i))
if (elem and elem.name~="") then
fon[i]=elem.name
end
box.out([[<option value="]]..tostring(i)..[[" ]]..sel..[[>]]..box.tohtml(fon[i])..[[</option>]])
end
sel=""
if (g_data.number=="50") then
no_selected=false
sel=[[selected]]
end
if config.CAPI_NT then
box.out([[<option value="50" ]]..sel..[[>]]..box.tohtml([[{?79:158?}]])..[[</option>]])
end
end
sel=""
if (g_data.number=="9" or no_selected) then
sel=[[selected]]
end
box.out([[<option value="9" ]]..sel..[[>]]..box.tohtml([[{?79:26?}]])..[[</option>]])
end
function write_hours()
if (string.len(g_data.time)==4) then
box.html(string.sub(g_data.time,1,2))
end
end
function write_minutes()
if (string.len(g_data.time)==4) then
box.html(string.sub(g_data.time,3,4))
end
end
function write_active_checked()
if (g_data.active=="1") then
box.out([[checked="checked"]])
end
end
function write_active()
box.html(tostring(g_data.active=="1"))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiWeek {
border: 0 none;
background-color:transparent;
}
#uiWeek td {
vertical-align:top;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function OnActive(checked)
{
jxl.disableNode("uiAlarmBlock",!checked);
var val="";
if (jxl.getChecked("uiViewOption1"))
{
val=jxl.getValue("uiViewOption1");
}
else if (jxl.getChecked("uiViewOption2"))
{
val=jxl.getValue("uiViewOption2");
}
else if (jxl.getChecked("uiViewOption3"))
{
val=jxl.getValue("uiViewOption3");
}
OnSetOption(val);
}
function OnSetOption(n) {
jxl.setChecked("uiViewOption1", n=='only_once');
jxl.setChecked("uiViewOption2", n=='daily');
jxl.setChecked("uiViewOption3", n=='per_day');
jxl.setDisabled("uiViewMo", n!='per_day');
jxl.setDisabled("uiViewDi", n!='per_day');
jxl.setDisabled("uiViewMi", n!='per_day');
jxl.setDisabled("uiViewDo", n!='per_day');
jxl.setDisabled("uiViewFr", n!='per_day');
jxl.setDisabled("uiViewSa", n!='per_day');
jxl.setDisabled("uiViewSo", n!='per_day');
}
function init()
{
fc.init("uiTimeBlock", 2);
var checked=<?lua write_active() ?>;
OnActive(checked);
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script,[[tab=]]..g_data.alarm_id) ?>">
<p>{?79:347?}</p>
<p>{?79:131?}</p>
<div class="narrow"><div class="formular">
<p><input type="checkbox" id="uiViewActive" name="active" onclick="OnActive(this.checked)" <?lua write_active_checked() ?>>&nbsp;<label for="uiViewActive">{?79:110?}</label></p>
<div class="formular" id="uiAlarmBlock">
<div id="uiTimeBlock">
<label for="uiViewHour">{?79:784?}</label>
<input type="text" id="uiViewHour" name="hour" size="2" maxlength="2" value="<?lua write_hours()?>" <?lua val.write_attrs(g_val, 'uiViewHour')?>> : <input type="text" id="uiViewMin" name="minutes" size="2" maxlength="2" value="<?lua write_minutes()?>" <?lua val.write_attrs(g_val, 'uiViewMin')?>>
</div>
<div>
<label for="uiViewDevice">{?79:64?}</label>
<select size="1" id="uiViewDevice" name="device">
<?lua write_fondevices() ?>
</select>
</div>
<div>
<label for="uiViewName">{?79:779?}</label>
<input type="text" id="uiViewName" name="name" size="37" maxlength="20" value="<?lua box.html(g_data.name)?>" <?lua val.write_attrs(g_val, 'uiViewName')?>>
</div>
<p>{?79:251?}</p>
<p><input type="radio" onclick="OnSetOption('only_once')" name="option" id="uiViewOption1" <?lua write_option_checked("only_once")?> value="only_once">&nbsp;<label for="uiViewOption1">{?79:785?}</label></p>
<p><input type="radio" onclick="OnSetOption('daily')" name="option" id="uiViewOption2" <?lua write_option_checked("daily") ?> value="daily" >&nbsp;<label for="uiViewOption2">{?79:540?}</label></p>
<p><input type="radio" onclick="OnSetOption('per_day')" name="option" id="uiViewOption3" <?lua write_option_checked("per_day") ?> value="per_day" >&nbsp;<label for="uiViewOption3">{?79:206?}</label></p>
<div class="formular">
<table id="uiWeek" style="">
<tr>
<td >
<p><input type="checkbox" id="uiViewMo" name="_mo" <?lua write_day("_mo")?>>&nbsp;<label for="uiViewMo">{?79:83?}</label></p>
<p><input type="checkbox" id="uiViewDi" name="_di" <?lua write_day("_di")?>>&nbsp;<label for="uiViewDi">{?79:525?}</label></p>
<p><input type="checkbox" id="uiViewMi" name="_mi" <?lua write_day("_mi")?>>&nbsp;<label for="uiViewMi">{?79:710?}</label></p>
<p><input type="checkbox" id="uiViewDo" name="_do" <?lua write_day("_do")?>>&nbsp;<label for="uiViewDo">{?79:666?}</label></p>
</td>
<td >
<p><input type="checkbox" id="uiViewFr" name="_fr" <?lua write_day("_fr")?>>&nbsp;<label for="uiViewFr">{?79:655?}</label></p>
<p><input type="checkbox" id="uiViewSa" name="_sa" <?lua write_day("_sa")?>>&nbsp;<label for="uiViewSa">{?79:368?}</label></p>
<p><input type="checkbox" id="uiViewSo" name="_so" <?lua write_day("_so")?>>&nbsp;<label for="uiViewSo">{?79:411?}</label></p>
</td>
</tr>
</table>
</div>
</div>
</div></div>
<?lua
if (g_errmsg) then
box.out(g_errmsg)
end
?>
<div id="btn_form_foot">
<button type="submit" name="apply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="curtab" value="<?lua box.html(g_data.alarm_id) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
