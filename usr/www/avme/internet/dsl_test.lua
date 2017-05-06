<?lua
g_page_type = "no_menu"
g_page_title = [[{?2553:767?}]]
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"http"
require"js"
require"html"
require"general"
g_back_to_page = http.get_back_to_page( "/support.lua" )
require"libluadsl"
local enum = {
CalibrateEcho = {
[0] = "CALIB_NONE",
[1] = "CALIB_RUNNING",
[2] = "CALIB_DONE",
[3] = "CALIB_FACTORY"
},
MeasureEcho = {
[0] = "MEAS_NONE",
[1] = "MEAS_NO_CALIB",
[2] = "MEAS_RUNNING",
[3] = "MEAS_DONE",
[4] = "MEAS_DONE_CABLE_NOK",
[5] = "MEAS_DONE_CABLE_OK"
}
}
local function read_sar_value(varname)
local value = tonumber(box.query("sar:settings/" .. varname)) or -1
return enum[varname][value] or ""
end
sar = general.lazytable({}, read_sar_value, {
CalibrateEcho = {"CalibrateEcho"},
MeasureEcho = {"MeasureEcho"}
})
local function line_testable()
if luadsl then
local dsl = luadsl.getOverviewStatus(1, "DS")
if array.find({"IDLE", "INIT", "NO_CABLE", "YES_CABLE"}, func.const(dsl.STATE)) then
local sec = tonumber(dsl.TIME_IN_STATE) or 0
return sec > 60*5
end
end
return true
end
function write_hide_if_testable(flag)
local testable = line_testable()
if sar.CalibrateEcho == "CALIB_RUNNING" or sar.MeasureEcho == "MEAS_RUNNING" then
testable = true
end
if testable == flag then
box.out([[style="display:none;"]])
end
end
function write_startajax_onload_js()
if sar.CalibrateEcho == "CALIB_RUNNING" then
box.js([[calibrate]])
elseif sar.MeasureEcho == "MEAS_RUNNING" then
box.js([[measure]])
end
end
local txt = {
notyet = [[{?2553:666?}]],
running = [[{?2553:552?}]],
done = [[{?2553:3691?}]],
noresult = [[{?2553:81?}]],
cable_nok = [[{?2553:240?}]],
cable_nok_dist = [[{?2553:98?}]],
cable_ok = [[{?2553:819?}]],
calib_factory = [[{?2553:423?}]]
}
g_state = {
uiStatusCalibrate = {
CALIB_NONE = {txt.notyet},
CALIB_RUNNING = {txt.running},
CALIB_DONE = {class="ok", txt.done},
CALIB_FACTORY = {class="ok", txt.calib_factory}
},
uiStatusMeasure = {
MEAS_NONE = {txt.notyet},
MEAS_NO_CALIB = {txt.notyet},
CALIB_RUNNING = {txt.notyet},
MEAS_RUNNING = {txt.running},
MEAS_DONE = {txt.running},
MEAS_DONE_CABLE_NOK = {class="ok", txt.done},
MEAS_DONE_CABLE_OK = {class="ok", txt.done}
},
uiStatusResult = {
MEAS_NONE = {txt.noresult},
MEAS_NO_CALIB = {txt.noresult},
CALIB_RUNNING = {txt.noresult},
MEAS_RUNNING = {txt.noresult},
MEAS_DONE = {txt.noresult},
MEAS_DONE_CABLE_NOK = {class="nok", txt.cable_nok},
MEAS_DONE_CABLE_OK = {class="ok", txt.cable_ok}
}
}
local function get_state_html(value)
local result = {}
for id, state in pairs(g_state) do
result[id] = state[value] and html.p(state[value]).get()
end
return result
end
function write_status(id, value)
html.p(g_state[id][value]).write()
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
if box.get.calibrate then
local answer = {}
if box.get.calibrate == "start" then
local err, msg = box.set_config({
{name="sar:settings/CalibrateEcho", value="1"}
})
if err ~= 0 then
answer.saveerror = general.create_error_div(err, msg)
end
end
local calib = sar.CalibrateEcho
answer.calibrate = calib
answer.done = calib == "CALIB_DONE" or calib == "CALIB_NONE"
answer.statehtml = get_state_html(calib)
if calib == "CALIB_NONE" then
answer.statehtml.uiStatusCalibrate = html.p{class="nok",
[[{?2553:2?}]]
}.get()
end
box.out(js.table(answer))
box.end_page()
end
if box.get.measure then
local answer = {}
if box.get.measure == "start" then
local err, msg = box.set_config({
{name="sar:settings/MeasureEcho", value="2"}
})
if err ~= 0 then
answer.saveerror = general.create_error_div(err, msg)
end
end
local meas = sar.MeasureEcho
answer.measure = meas
answer.done = meas == "MEAS_DONE_CABLE_NOK"
or meas == "MEAS_DONE_CABLE_OK"
or meas == "MEAS_NONE"
or meas == "MEAS_NO_CALIB"
answer.statehtml = get_state_html(meas)
if meas == "MEAS_DONE_CABLE_NOK" and luadsl then
local drdsl = luadsl.getDrDsl(1, "us")
local distance = tonumber(drdsl.CABLE_NOK_DISTANCE) or -1
if distance >= 0 then
answer.statehtml.uiStatusResult = html.p{class="nok",
general.sprintf(txt.cable_nok_dist, distance)
}.get()
end
end
if meas == "MEAS_NONE" then
answer.statehtml.uiStatusMeasure = html.p{class="nok",
[[{?2553:695?}]]
}.get()
end
box.out(js.table(answer))
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
table#uiStatusTable {
width: 600px;
}
table#uiStatusTable td {
vertical-align: baseline;
padding: 4px 6px;
}
table#uiStatusTable tr td:first-child {
width: 120px;
}
table#uiStatusTable td p {
background-position: left top;
background-repeat: no-repeat;
padding-left: 30px;
}
table#uiStatusTable td p.ok {
background-image: url(/css/default/images/icon_ok.png);
}
table#uiStatusTable td p.nok {
background-image: url(/css/default/images/icon_error.png);
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var url = "<?lua box.js(box.glob.script) ?>?sid=<?lua box.js(box.glob.sid) ?>";
var json = makeJSONParser();
var poll = 2000;
function onCalibrateClicked() {
var txt = [
"{?2553:371?}",
"{?2553:879?}"
];
if (!confirm(txt.join("\n"))) {
return;
}
ajaxGet(url + "&calibrate=start", cbCalibrate);
jxl.disable("uiStartCalibrate");
jxl.show("uiWaitCalibrate");
}
function onMeasureClicked() {
var txt = [
"{?2553:525?}",
"{?2553:769?}"
];
if (!confirm(txt.join("\n"))) {
return;
}
ajaxGet(url + "&measure=start", cbMeasure);
jxl.disable("uiStartMeasure");
jxl.show("uiWaitMeasure");
}
function refreshCalibrate() {
ajaxGet(url + "&calibrate=refresh", cbCalibrate);
jxl.disable("uiStartCalibrate");
jxl.show("uiWaitCalibrate");
}
function refreshMeasure() {
ajaxGet(url + "&measure=refresh", cbMeasure);
jxl.disable("uiStartMeasure");
jxl.show("uiWaitMeasure");
}
function updateState(statehtml) {
if (!statehtml) { return; }
for (var id in statehtml) {
jxl.setHtml(id, statehtml[id]);
}
}
function cbCalibrate(xhr) {
var answer = json(xhr.responseText || "{}");
updateState(answer.statehtml);
if (answer.saveerror) {
jxl.setHtml("uiSaveError", answer.saveerror);
jxl.hide("uiWaitCalibrate");
}
else if (answer.done) {
jxl.hide("uiWaitCalibrate");
jxl.enable("uiStartCalibrate");
jxl.enable("uiStartMeasure");
}
else {
setTimeout(refreshCalibrate, poll);
}
}
function cbMeasure(xhr) {
var answer = json(xhr.responseText || "{}");
updateState(answer.statehtml);
if (answer.saveerror) {
jxl.setHtml("uiSaveError", answer.saveerror);
jxl.hide("uiWaitMeasure");
}
else if (answer.done) {
jxl.hide("uiWaitMeasure");
jxl.enable("uiStartMeasure");
}
else {
setTimeout(refreshMeasure, poll);
}
}
var toStart = "<?lua write_startajax_onload_js() ?>";
if (toStart == "calibrate") {
ready.onReady(refreshCalibrate);
}
else if (toStart == "measure") {
ready.onReady(refreshMeasure);
}
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<div <?lua write_hide_if_testable(true) ?>>
<p>
{?2553:63?}
</p>
</div>
<div <?lua write_hide_if_testable(false) ?>>
<div id="uiCalibrateContainer">
<p>
{?2553:581?}
</p>
<p>
{?2553:499?}
</p>
<div class="btn_form">
<button id="uiStartCalibrate" type="button" onclick="onCalibrateClicked();">
{?2553:669?}
</button>
</div>
<div id="uiWaitCalibrate" class="wait" style="display:none;">
<div id="uiWaitCalibrateTop"></div>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
</div>
<hr>
<div id="uiMeasureContainer">
<p>
{?2553:172?}
</p>
<p>
{?2553:199?}
</p>
<div class="btn_form">
<button id="uiStartMeasure" type="button" onclick="onMeasureClicked();">
{?2553:150?}
</button>
</div>
<div id="uiWaitMeasure" class="wait" style="display:none;">
<div id="uiWaitMeasureTop"></div>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
</div>
<hr>
<h4>{?2553:941?}</h4>
<div id="uiStatusContainer" class="formular">
<div id="uiSaveError"></div>
<table class="grid" id="uiStatusTable">
<tr>
<td>{?2553:986?}</td>
<td id="uiStatusCalibrate">
<?lua write_status("uiStatusCalibrate", sar.CalibrateEcho) ?>
</td>
</tr>
<tr>
<td>{?2553:792?}</td>
<td id="uiStatusMeasure">
<?lua write_status("uiStatusMeasure", "MEAS_NONE") ?>
</td>
</tr>
<tr>
<td>{?2553:715?}</td>
<td id="uiStatusResult">
<?lua write_status("uiStatusResult", "MEAS_NONE") ?>
</td>
</tr>
</table>
</div>
</div>
<div id="btn_form_foot">
<button id="uiCancel" type="submit" name="cancel">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
