<?lua
--[[
Datei Name: ulemon.lua
Datei Beschreibung: (Direktlink) Showcase für DECT Zähler
]]
g_page_type = "no_menu"
g_homelink_top = false
g_page_title = [[Energy Monitoring Demo]]
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"capiterm"
require"string_op"
require"cmtable"
local function get_power_values()
local result = {}
val = box.query("dect:settings/ULEPOWER/IsValid")
result.IsValid = val or "0"
if(result.IsValid ~= "1") then
result.LastPower = val or "0"
result.DaysThisYear = val or "1"
result.MinutesToday = val or "1"
result.ThisYear = "0,0,0,0,0,0,0,0,0,0,0,0"
result.LastYear = "0,0,0,0,0,0,0,0,0,0,0,0"
result.ThisMonth = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
result.Today = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
result.ThisHour = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
result.LastHour = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
result.KwhCost = "22"
else
val = box.query("dect:settings/ULEPOWER/LastPower")
result.LastPower = val or "0"
val = box.query("dect:settings/ULEPOWER/DaysThisYear")
result.DaysThisYear = val or "0"
val = box.query("dect:settings/ULEPOWER/MinutesToday")
result.MinutesToday = val or "0"
val = box.query("dect:settings/ULEPOWER/ThisYear")
result.ThisYear = val or "0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/LastYear")
result.LastYear = val or "0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/ThisMonth")
result.ThisMonth = val or "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/Today")
result.Today = val or "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/ThisHour")
result.ThisHour = val or "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/LastHour")
result.LastHour = val or "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
val = box.query("dect:settings/ULEPOWER/KwhCost")
result.KwhCost = val or "22"
end
return result
end
local function get_values(idx)
local result = {}
val = box.query("dect:settings/ULE" .. idx .. "/Subscribed")
result.Subscribed = val or "0"
if result.Subscribed == "1" then
val = box.query("dect:settings/ULE" .. idx .. "/Name")
result.Name = val or ""
val = box.query("dect:settings/ULE" .. idx .. "/IsDataValid")
result.IsDataValid = val or "0"
val = box.query("dect:settings/ULE" .. idx .. "/IsDECTMeter")
result.IsDECTMeter = val or "0"
val = box.query("dect:settings/ULE" .. idx .. "/IsButton")
result.IsButton = val or "0"
val = box.query("dect:settings/ULE" .. idx .. "/IsReedRelais")
result.IsReedRelais = val or "0"
if (result.IsReedRelais == "1") then
val = box.query("dect:settings/ULE" .. idx .. "/ReedRelaisState")
result.ReedRelaisState = val or "0"
else
result.ReedRelaisState = "0"
end
val = box.query("dect:settings/ULE" .. idx .. "/IsSwitch")
result.IsSwitch = val or "0"
val = box.query("dect:settings/ULE" .. idx .. "/IsSwitchOn")
result.IsSwitchOn = val or "0"
if(result.IsButton == "1") then
val = box.query("dect:settings/ULE" .. idx .. "/IsButtonPressed")
result.IsButtonPressed = val or "0"
else
result.IsButtonPressed = "0"
end
val = box.query("dect:settings/ULE" .. idx .. "/IsTempMeas")
result.IsTempMeas = val or "0"
if(result.IsTempMeas == "1") then
val = box.query("dect:settings/ULE" .. idx .. "/TempMeas")
result.TempMeas = val or "0"
else
result.TempMeas = "0"
end
if(result.IsDECTMeter == "1") then
val = box.query("dect:settings/ULE" .. idx .. "/DECTMeter")
result.DECTMeter = tonumber(val) or 0
else
result.DECTMeter = 0
end
result.id = "ULE" .. idx
else
result.DECTMeter = 0
result.IsDECTMeter = 0
result.IsDataValid = 0
result.IsButton = 0
result.IsButtonPressed = 0
result.IsReedRelais = 0
result.ReedRelaisState = 0
result.IsSwitch = 0
result.IsSwitchOn = 0
result.IsTempMeas = 0
result.TempMeas = "0"
result.Name = ""
result.id = "ULE" .. idx
end
return result
end
local function quoted(s)
s = tostring(s)
s = s:gsub([["]], [[\"]]) -- "
return [["]] .. s .. [["]]
end
function on_meter()
box.out("[\n")
-- power
local values = get_power_values()
box.out("{\n")
local str = {}
for k, v in pairs(values) do
table.insert(str, quoted(k) .. [[: ]] .. quoted(v))
end
box.out(table.concat(str, ",\n"))
box.out("\n}")
for idx = 0,19,1 do
local values = get_values(tonumber(idx) or 0)
box.out(",{\n")
local str = {}
for k, v in pairs(values) do
table.insert(str, quoted(k) .. [[: ]] .. quoted(v))
end
box.out(table.concat(str, ",\n"))
box.out("\n}")
end
box.out("\n]")
end
------------------------------------------------------------------------------
-- main
if box.get.meter then
on_meter()
box.end_page()
end
if next(box.post) and box.post.on and box.post.on~="" then
capiterm.var("post on", box.post)
local saveset = {}
cmtable.add_var(saveset, "dect:settings/ULE"..box.post.on .. "/IsSwitch","1")
box.set_config(saveset)
end
if next(box.post) and box.post.off and box.post.off~="" then
capiterm.var("post off", box.post)
local saveset = {}
cmtable.add_var(saveset, "dect:settings/ULE"..box.post.off .. "/IsSwitch","0")
box.set_config(saveset)
end
if next(box.post) and box.post.buttonaction and box.post.buttonaction~="" then
capiterm.var("post buttonaction", box.post)
local actioninfo = "SelectButtonAction" .. box.post.buttonaction
if(box.post[actioninfo] and box.post[actioninfo]~= "") then
local infos = string_op.split2table(box.post[actioninfo],",",0)
if #infos == 3 then
local saveset = {}
cmtable.add_var(saveset, "dect:settings/ULERULE"..(tonumber(infos[1])-1) .. "/IsValid","1")
cmtable.add_var(saveset, "dect:settings/ULERULE"..(tonumber(infos[1])-1) .. "/ActorID",infos[2])
cmtable.add_var(saveset, "dect:settings/ULERULE"..(tonumber(infos[1])-1) .. "/SensorID",infos[3])
box.set_config(saveset)
else
local saveset = {}
cmtable.add_var(saveset, "dect:settings/ULERULE"..(tonumber(infos[1])-1) .. "/IsValid","0")
box.set_config(saveset)
end
end
end
function get_actor_buttons(ule)
local onclick = ""
--return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/led_green.gif", "On_"..ule.id, "on", ule.id, [[On]], onclick)..[[</td>
-- <td class="buttonrow">]]..general.get_icon_button("/css/default/images/led_red.gif", "Off_"..ule.id, "off", ule.id, [[Off]], onclick)..[[</td>]]
return [[<td class="buttonrow"><button type="submit" id="Off_]]..ule.id..[[" name="off" style="min-width: 25px;" value="]]..ule.id..[[" />Off</button></td>
<td class="buttonrow"><button type="submit" style="min-width: 25px;" id="On_]]..ule.id..[[" name="on" value="]]..ule.id..[[" />On</button></td>]]
end
function show_actors()
local str = ""
for idx = 0,19,1 do
local result = {}
result.id = idx
val = box.query("dect:settings/ULE" .. idx .. "/IsSwitch")
result.IsSwitch = val or "0"
if(result.IsSwitch == "1") then
val = box.query("dect:settings/ULE" .. idx .. "/Name")
result.Name = val or ""
val = box.query("dect:settings/ULE" .. idx .. "/IsSwitchOn")
result.IsSwitchOn = val or ""
val = box.query("dect:settings/ULE" .. idx .. "/IsDataValid")
result.IsDataValid = val or ""
capiterm.var("IsSwitch result",result)
str = str..[[<tr>]]
local led = "led_red"
if(result.IsDataValid == "1") then
led = "led_green"
end
str = str..[[<td id="uiActorDataValid]] ..idx .. [[" class="]] .. led .. [["></td>]]
str = str..[[<td>]]..box.tohtml(result.Name)..[[</td>]]
str = str..[[<td>Switch</td>]]
local info = "off"
if(result.IsSwitchOn == "1") then
info = "on"
end
str = str..[[<td id="uiActorSwitchOn]] ..idx .. [[">]] .. info .. [[</td>]]
str = str..get_actor_buttons(result)
str = str..[[</tr>]]
end
end
return str
end
function get_first_free_rule(ulerules)
for idx, ulerule in ipairs(ulerules) do
if (tonumber(ulerule.IsValid)==0) then
return idx;
end
end
return 0
end
function get_rule_id(sensorid,ulerules)
local testsensorid = tonumber(sensorid)
for idx, ulerule in ipairs(ulerules) do
if ( tonumber(ulerule.IsValid)==1 and tonumber(ulerule.SensorID)==testsensorid) then
return idx;
end
end
return 0
end
function show_sensor_settings()
local str = ""
local uledevices = general.listquery("dect:settings/ULE/list(Name,IsSwitch)")
local ulerules = general.listquery("dect:settings/ULERULE/list(SensorID,ActorID,IsValid)")
capiterm.var("ulerules",ulerules)
capiterm.var("uledevices",uledevices)
local switchcount = 0
for idx, uledev in ipairs(uledevices) do
if uledev.IsSwitch=="1" then
switchcount = switchcount + 1
end
end
local freeruleid = get_first_free_rule(ulerules)
for idx = 0,19,1 do
local result = {}
result.id = idx
val = box.query("dect:settings/ULE" .. idx .. "/IsButton")
result.IsButton = val or "0"
val = box.query("dect:settings/ULE" .. idx .. "/IsReedRelais")
result.IsReedRelais = val or "0"
if((result.IsButton == "1") or (result.IsReedRelais == "1")) then
val = box.query("dect:settings/ULE" .. idx .. "/Name")
result.Name = val or ""
capiterm.var("result",result)
str = str..[[<tr><td>]]..box.tohtml(result.Name)..[[</td>]]
str = str..[[<td><select name="SelectButtonAction]] .. result.id .. [[" id="uiSelectButtonAction]] .. result.id .. [[">]]
local uleruleid = get_rule_id(tonumber(result.id)+16,ulerules)
local ulerule = nil
if(uleruleid>0) then
ulerule = ulerules[uleruleid]
end
str = str..[[<option value="]] .. uleruleid .. [[">switch none</option>]]
if (switchcount > 0) then
for idx, uledev in ipairs(uledevices) do
if uledev.IsSwitch=="1" then
if(ulerule~=nil and tonumber(ulerule.IsValid)==1 and tonumber(ulerule.ActorID) == (idx+15))then
capiterm.var("ulerule match",ulerule)
str = str..[[<option value="]] .. uleruleid .. [[,]] ..(idx + 15) .. [[,]] .. (tonumber(result.id)+16).. [[" selected="selected">switch ]] ..uledev.Name .. [[</option>]]
else
capiterm.var("ulerule freeruleid",freeruleid)
str = str..[[<option value="]] .. freeruleid .. [[,]] ..(idx + 15) .. [[,]] .. (tonumber(result.id)+16).. [[">switch ]] ..uledev.Name .. [[</option>]]
end
end
end
end
str = str..[[</select></td>]]..get_button_buttons(result)..[[</tr>]]
end
end
return str
end
function get_button_buttons(ule)
local onclick = ""
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "Buttonaction_"..ule.id, "buttonaction", ule.id, [[Save]], onclick)..[[</td>]]
end
?>
<?include "templates/html_head_popup.html" ?>
<style type="text/css">
div#uiCanvasContainer{
text-align: center;
}
.InfoElementHead{
}
.MeterInfoElement{
margin: 5px;
border-width: 3px;
border-style: outset;
border-color: black;
border-collapse:collapse;
width: 350px;
height: 350px;
text-align:center;
float:left;
position:relative;
top:0px;
left:0px;
}
.sensoractorTable{
border-collapse: collapse;
font-size: 12px;
margin: 15px 0;
width: 100%;
text-algin:center;
}
#uiMainDemoBoard{
}
.MeterTextHead{
width: 120px;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<!--[if lt IE 9]>
<script type="text/javascript" src="/meter/excanvas.js"></script>
<![endif]-->
<script type="text/javascript" src="/meter/gauge.js"></script>
<script type="text/javascript">
function paintDailyPath(percent) {
maxvalue = 200;
if(percent>maxvalue){
maxvalue = Math.floor(percent*1.1);
}
new Gauge(jxl.get("uiDailyPath"), {
value: percent,
unit: " %",
label: "",
min: 0,
max: maxvalue,
majorTicks: 5,
minorTicks: 4,
greenFrom: 0,
greenTo: 0,
yellowFrom: 0,
yellowTo: 0,
redFrom: 120,
redTo: maxvalue
});
}
function paintGauge(metervalue) {
var maxval = 1000;
var greenToval = 100;
var yellowFromval = 450;
var yellowToval = 750;
var redFromval = 750;
if(metervalue>1000){
maxval = 2000;
greenToval = 200;
yellowFromval = 950;
yellowToval = 1500;
redFromval = 1500;
}
new Gauge(jxl.get("uiMeter"), {
value: Number(metervalue) || 0,
unit: " W",
label: "",
min: 0,
max: maxval,
majorTicks: 4,
minorTicks: 3,
greenFrom: 0,
greenTo: greenToval,
yellowFrom: yellowFromval,
yellowTo: yellowToval,
redFrom: redFromval,
redTo: maxval
});
}
function readULEsFromXhr(txt) {
var hs = [];
try {
hs = eval('(' + txt + ')');
}
catch (err) {
hs = [];
}
return hs;
}
var g_cfg = {
uiCurrentPower : true,
uiPowerLevel : true,
uiPowerCost : true,
uiSensors : true,
uiActors : true,
uiButtons : true
};
function ToggleShowMeterInfoElement(uiMeterInfo){
g_cfg[uiMeterInfo] = g_cfg[uiMeterInfo]?false:true;
jxl.display(uiMeterInfo,g_cfg[uiMeterInfo]);
}
var g_Meter = (function () {
var ules = [];
var values = [];
var power = [];
function findIdx(hsId) {
for (var i = 0, len = ules.length; i < len; i++) {
if (ules[i].id == hsId) {
return i;
}
}
return -1;
}
function getULECount() {
return ules.length;
}
function getMeterULE() {
for (var i = 0, len = ules.length; i < len; i++) {
if (ules[i].IsDECTMeter == "1") {
return ules[i].id;
}
}
return "";
}
function getValue(hsId, property) {
var i = findIdx(hsId);
if (i < 0) {
return "";
}
return values[i][property];
}
function getPower( property) {
return power[property];
}
function getValById(uleindex,property) {
if(values.length >= uleindex){
return values[uleindex][property];
}else{
return "";
}
}
return {
update: function (newULEs) {
ules = filterULEs(newULEs);
values = calcAllValues(ules,values);
power = calcPower(newULEs,power);
},
getVal: function (hsId, property) {
return getValue(hsId, property);
},
getMeterULEId: function () {
return getMeterULE();
},
getValByIndex: function (uleindex,property) {
return getValById(uleindex,property);
},
getPow: function (property) {
return getPower(property);
},
getULELength: function () {
return getULECount();
}
};
})();
function calcAllValues(ules, values) {
values = values || [];
for (var i = 0, len = ules.length; i < len; i++) {
if(ules[i].id){
var hs = ules[i];
values[i] = values[i] || {};
values[i].id = hs.id;
values[i].IsDECTMeter = parseInt(hs.IsDECTMeter,10) || 0;
values[i].IsDataValid = parseInt(hs.IsDataValid,10) || 0;
values[i].IsButton = parseInt(hs.IsButton,10) || 0;
values[i].IsReedRelais = parseInt(hs.IsReedRelais,10) || 0;
values[i].ReedRelaisState = parseInt(hs.ReedRelaisState,10) || 0;
values[i].IsButtonPressed = parseInt(hs.IsButtonPressed,10) || 0;
values[i].IsSwitch = parseInt(hs.IsSwitch,10) || 0;
values[i].IsSwitchOn = parseInt(hs.IsSwitchOn,10) || 0;
values[i].IsTempMeas = parseInt(hs.IsTempMeas,10) || 0;
values[i].TempMeas = hs.TempMeas;
values[i].Name = hs.Name;
values[i].DECTMeter = parseInt(hs.DECTMeter,10) || 0;
}else{
alert("duerfte nicht passieren");
}
}
return values;
}
function filterULEs(ules) {
newules = [];
var j = 0;
for (var i = 0, len = ules.length; i < len; i++) {
if(ules[i].id){
newules[j] = ules[i];
j++;
}
}
return newules;
}
function calcPower( items,power) {
power = power || [];
for (var i = 0, len = items.length; i < len; i++) {
if(!items[i].id){
var poweritem = items[i];
power = power || {};
power.ThisYear = {};
var poweryear=poweritem.ThisYear.split(",");
for(var i=0;i<poweryear.length;i++){
power.ThisYear[i]=parseInt(poweryear[i],10);
}
power.LastYear = {};
poweryear=poweritem.LastYear.split(",");
for(var i=0;i<poweryear.length;i++){
power.LastYear[i]=parseInt(poweryear[i],10);
}
power.ThisMonth = {};
var powermonth=poweritem.ThisMonth.split(",");
for(var i=0;i<powermonth.length;i++){
power.ThisMonth[i]=parseInt(powermonth[i],10);
}
power.Today = {};
var powertoday=poweritem.Today.split(",");
for(var i=0;i<powertoday.length;i++){
power.Today[i]=parseInt(powertoday[i],10);
}
power.ThisHour =new Array();
var powerhour=poweritem.ThisHour.split(",");
for(var i=0;i<powerhour.length;i++){
power.ThisHour[i]=parseInt(powerhour[i],10);
}
power.LastHour =new Array();
powerhour=poweritem.LastHour.split(",");
for(var i=0;i<powerhour.length;i++){
power.LastHour[i]=parseInt(powerhour[i],10);
}
power.KwhCost = parseInt(poweritem.KwhCost,10) ||22;
power.LastPower = parseInt(poweritem.LastPower,10) ||0;
power.IsValid = parseInt(poweritem.IsValid,10) ||0;
power.DaysThisYear = parseInt(poweritem.DaysThisYear,10) ||0;
power.MinutesToday = parseInt(poweritem.MinutesToday,10) ||0;
}else{
}
}
return power;
}
function showSensorInfo(){
var TableSensorInfo = "<tr><th class='iconrow'></th><th>Name</th><th>Type</th><th>Info</th><tr>";
var i = 0;
for (len = g_Meter.getULELength(); i < len; i++) {
if (g_Meter.getValByIndex(i, "IsButton") == "1") {
var led = "led_red";
if(g_Meter.getValByIndex(i, "IsDataValid") == "1"){
led = "led_green";
}
TableSensorInfo = TableSensorInfo + "<tr><td class='" + led + "'></td>";
TableSensorInfo = TableSensorInfo + "<td>" + g_Meter.getValByIndex(i, "Name") + "</td>";
TableSensorInfo = TableSensorInfo + "<td>Button</td>";
var led = "/css/default/images/led_red.gif";
if(g_Meter.getValByIndex(i, "IsButtonPressed") == "1"){
led = "/css/default/images/led_green.gif";
}
TableSensorInfo = TableSensorInfo + "<td><img src='" + led + "' /></td></tr>";
}
if (g_Meter.getValByIndex(i, "IsTempMeas") == "1") {
var led = "led_red";
var tempmeas = " - "
if(g_Meter.getValByIndex(i, "IsDataValid") == "1"){
led = "led_green";
tempmeas = g_Meter.getValByIndex(i, "TempMeas") + " °C";
}
TableSensorInfo = TableSensorInfo + "<tr><td class='" + led + "'></td>";
TableSensorInfo = TableSensorInfo + "<td>" + g_Meter.getValByIndex(i, "Name") + "</td>";
TableSensorInfo = TableSensorInfo + "<td>Temperature</td>";
TableSensorInfo = TableSensorInfo + "<td>" + tempmeas + "</td></tr>";
}
if (g_Meter.getValByIndex(i, "IsReedRelais") == "1") {
var led = "led_red";
if(g_Meter.getValByIndex(i, "IsDataValid") == "1"){
led = "led_green";
}
TableSensorInfo = TableSensorInfo + "<tr><td class='" + led + "'></td>";
TableSensorInfo = TableSensorInfo + "<td>" + g_Meter.getValByIndex(i, "Name") + "</td>";
TableSensorInfo = TableSensorInfo + "<td>Reed Relais</td>";
var info = "closed";
if(g_Meter.getValByIndex(i, "ReedRelaisState") == "1"){
info = "open";
}
TableSensorInfo = TableSensorInfo + "<td>" + info + "</td></tr>";
}
}
var Table = document.getElementById("uiSensorTable");
if(Table){
Table.innerHTML = TableSensorInfo;
}
}
function showActorInfo(){
var i = 0;
for (len = g_Meter.getULELength(); i < len; i++) {
if (g_Meter.getValByIndex(i, "IsSwitch") == "1") {
var tdid = "uiActorSwitchOn"+i;
var info = "off";
if(g_Meter.getValByIndex(i, "IsSwitchOn") == "1"){
info = "on";
}
var td = document.getElementById(tdid);
if(td){
td.innerHTML = info;
}
var led = "led_red";
if(g_Meter.getValByIndex(i, "IsDataValid") == "1"){
led = "led_green";
}
tdid = "uiActorDataValid"+i;
var td = document.getElementById(tdid);
if(td){
td.setAttribute("class", led);
}
}
}
}
function updateValues() {
var url = "<?lua box.js(box.glob.script) ?>";
url += "?sid=<?lua box.js(box.glob.sid) ?>";
url += "&meter=true";
var json = makeJSONParser();
function request() {
return ajaxGet(url, callback);
}
function callback(xhr) {
var values = json(xhr.responseText || "null");
if (values) {
if (xhr.status == 200) {
g_Meter.update(readULEsFromXhr(xhr.responseText));
var uleid = g_Meter.getMeterULEId();
paintGauge( g_Meter.getVal(uleid, "DECTMeter"));
updatePowerInfos();
showSensorInfo();
showActorInfo();
drawPowerToday();
drawPowerYear();
}
}
setTimeout(request, 1000);
}
window.setTimeout(request, 1000);
var canvas = document.getElementById('powertoday');
canvas.onclick= powerclick;
// When ready...
window.addEventListener("load",function() {
/mobile/i.test(navigator.userAgent) && setTimeout(function () {
window.scrollTo(0, 1);}, 0);
});
}
function powerclick(event){
//alert(event.clientX );
if(g_ShowToday==1){
g_ShowToday = 0;
}else{
g_ShowToday = 1;
}
drawPowerToday();
}
function GetPowerSoFarThisYear(){
var power = g_Meter.getPow("ThisYear");
watthours=0;
var i=0;
for(i=0;i<12;i++){
if(power[i]>-1){
watthours = watthours + power[i];
}
}
power = g_Meter.getPow("ThisMonth");
for(i=0;i<31;i++){
if(power[i]>-1){
watthours = watthours + power[i];
}
}
watthours = watthours + GetPowerSoFarToday();
return watthours;
}
function GetPowerSoFarToday(){
var powertoday = g_Meter.getPow("Today");
watthours=0;
var i=0;
for(i=0;i<24;i++){
if(powertoday[i]>-1){
watthours = watthours + powertoday[i];
}
}
var wattminutes = 0;
var powerthishour = g_Meter.getPow("ThisHour");
for(i=0;i<60;i++){
if(powerthishour[i]>-1){
wattminutes = wattminutes + powerthishour[i];
}
}
watthours = watthours + Math.floor(wattminutes / 60);
return watthours;
}
function GetTotalPowerConsumptionInfo(bGetDays){
var power = g_Meter.getPow("LastYear");
var days = 0;
var watthours=0;
var bAktivTrigger = false;
var i=0;
for(i=0;i<12;i++){
if(power[i]>0 || bAktivTrigger){
watthours = watthours + power[i];
//ab den ersten aktiven Monat wird gezählt
bAktivTrigger = true;
//oder doch je Monat ..., also Feb: +28 ...
days = days + 30;
}
}
power = g_Meter.getPow("ThisYear");
for(i=0;i<12;i++){
if(power[i]>-1 && (power[i]>0|| bAktivTrigger) ){
watthours = watthours + power[i];
//oder doch je Monat ...
days = days + 30;
bAktivTrigger = true;
}
}
power = g_Meter.getPow("ThisMonth");
for(i=0;i<31;i++){
if(power[i]>-1 && (power[i]>0|| bAktivTrigger) ){
watthours = watthours + power[i];
days = days + 1;
bAktivTrigger = true;
}
}
if(bGetDays){
return days;
}else{
return watthours;
}
}
function roundNumber(num, dec) {
var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
return result;
}
function updatePowerInfos(){
if(g_Meter.getPow("IsValid")=="0"){return;}
var item = document.getElementById("uiPowerNowValue");
var uleid = g_Meter.getMeterULEId();
if(item && g_Meter.getVal(uleid, "IsDataValid")=="1"){
item.innerHTML = g_Meter.getVal(uleid, "DECTMeter") + " W";
}else{
item.innerHTML = "- W";
}
var watthourstoday = GetPowerSoFarToday();
var kwhsofartoday = roundNumber(watthourstoday/1000,2);
var watthoursyear = GetPowerSoFarThisYear();
var kwhsofaryear = roundNumber(watthoursyear/1000,2);
//gesamte History durchgehn und watthours berechnen, dazu dann noch die Tag ermitteln an denen was verbraucht wurde
//-> falls Stromzähler erst "letzten Monat" aufgestellt wurde
var totalpowercosumption = GetTotalPowerConsumptionInfo(false);
var totalpowercosumptiondays = GetTotalPowerConsumptionInfo(true);
item = document.getElementById("uiPowerSoFarToday");
if(item){item.innerHTML = kwhsofartoday + " kwh"; }
var PowerDailyAverage = 0;
if(totalpowercosumptiondays!=0){
PowerDailyAverage = roundNumber((totalpowercosumption / totalpowercosumptiondays)/1000,2);
}
item = document.getElementById("uiPowerDailyAverage");
if(item){item.innerHTML = PowerDailyAverage +" kwh"; }
var PowerDailyPercentage = 0;
if(totalpowercosumptiondays!=0){
PowerDailyPercentage = Math.floor((watthourstoday * (1440 / g_Meter.getPow("MinutesToday"))) / (totalpowercosumption / totalpowercosumptiondays) * 100);
}
paintDailyPath(PowerDailyPercentage);
var CostSoFarToday = roundNumber((g_Meter.getPow("KwhCost")/100) * (watthourstoday/1000),2);
item = document.getElementById("uiCostSoFarToday");
if(item){item.innerHTML = CostSoFarToday + " €"; }
var CostDailyAverage = 0;
if(totalpowercosumptiondays!=0){
CostDailyAverage = roundNumber((g_Meter.getPow("KwhCost")/100) * (totalpowercosumption / totalpowercosumptiondays)/1000,2);
}
item = document.getElementById("uiCostDailyAverage");
if(item){item.innerHTML = CostDailyAverage + " €"; }
var CostSoFarYear = roundNumber((g_Meter.getPow("KwhCost")/100) * (watthoursyear/1000),2);
item = document.getElementById("uiCostSoFarYear");
if(item){item.innerHTML = CostSoFarYear+ " €"; }
var daysyear = g_Meter.getPow("DaysThisYear");
var CostPredictionYear = 0;
if(daysyear!=0){
CostPredictionYear = roundNumber(CostSoFarYear * (365/daysyear),2);
}
item = document.getElementById("uiCostYearPrediction");
if(item){item.innerHTML = CostPredictionYear+ " €"; }
}
function PowerMaxValue(power,size,minvalue){
maxval=0;
var i=0;
for(i=0;i<size;i++){
if(power[i]>maxval){
maxval=power[i];
}
}
//10% mehr
maxval=Math.floor(maxval*1.1);
if(maxval<10){
maxval=minvalue;
}
return maxval;
}
function PowerValidCount(power,size){
var count=0;
var i=0;
for(i=0;i<size;i++){
if(power[i]>-1){
count++;
}else{
break;
}
}
return count;
}
var g_ShowToday = 1;
function drawPowerToday(){
var canvas = document.getElementById('powertoday');
if (canvas.getContext){
var ctx = canvas.getContext('2d');
// drawing code here
ctx.save();
//Hintergrund zeichen
ctx.fillStyle = "white";//rgb(200,0,0);
ctx.fillRect (0, 0, 310, 160);
ctx.restore();
var powertoday = 0;
var maxvalue = 10;
var validcount = 0;
ctx.save();
ctx.fillText("Show: ", 2, 150);
if(g_ShowToday==1){
ctx.fillStyle = "rgb(200,0,0)";
ctx.fillText("Today", 35, 150);
ctx.restore();
ctx.save();
ctx.fillText("last Hour", 70, 150);
}else{
ctx.fillStyle = "rgb(200,0,0)";
ctx.fillText("last Hour", 70, 150);
ctx.restore();
ctx.save();
ctx.fillText("Today", 35, 150);
}
ctx.fillText("/", 65, 150);
if(g_ShowToday==1){
if(g_Meter.getPow("IsValid") == "1"){
powertoday = g_Meter.getPow("Today");
maxvalue = PowerMaxValue(powertoday,24,10);
validcount = PowerValidCount(powertoday,24);
}
ctx.save();
var mytext = maxvalue + "W";
//Beschriftung
ctx.fillText(mytext, 3, 35);
ctx.fillText("0", 40, 140);
ctx.fillText("24", 280, 140);
ctx.restore();
ctx.save();
//Graph
ctx.beginPath();
ctx.moveTo(40,30);
ctx.lineTo(40,130);
ctx.lineTo(280,130);
ctx.stroke();
ctx.restore();
ctx.save();
if(validcount>0){
//Power Today Verlauf
ctx.beginPath();
var daywidth = 10;
var yzero = 130;
var ymax = 30;
var xzero = 40;
//Power max value
var ycor = yzero - Math.floor((powertoday[0] * 100) / maxvalue);
ctx.moveTo(xzero,ycor);
var i = 1;
for (i=1;i<Math.min(24,validcount);i++){
ycor = yzero - Math.floor((powertoday[i] * 100) / maxvalue);
ctx.lineTo(xzero + i*daywidth,ycor);
}
ctx.stroke();
ctx.restore();
}
}else{
var powerhour = 0;
if(g_Meter.getPow("IsValid") == "1"){
ThisHour = g_Meter.getPow("ThisHour");
LastHour = g_Meter.getPow("LastHour");
validcount = PowerValidCount(ThisHour,60);
var tmphour = LastHour.slice(validcount-60);
powerhour = tmphour.concat(ThisHour.slice(0,validcount));
maxvalue = PowerMaxValue(powerhour,60,10);
validcount=60;
}
ctx.save();
var mytext = maxvalue + "W";
//Beschriftung
ctx.fillText(mytext, 3, 35);
//ctx.fillText("0", 40, 140);
//ctx.fillText("60", 280, 140);
ctx.restore();
ctx.save();
//Graph
ctx.beginPath();
ctx.moveTo(40,30);
ctx.lineTo(40,130);
ctx.lineTo(280,130);
ctx.stroke();
ctx.restore();
ctx.save();
if(validcount>0){
//Power Today Verlauf
ctx.beginPath();
var hourwidth = 4;
var yzero = 130;
var ymax = 30;
var xzero = 40;
//Power max value
var ycor = yzero - Math.floor((powerhour[0] * 100) / maxvalue);
ctx.moveTo(xzero,ycor);
var i = 1;
for (i=1;i<Math.min(60,validcount);i++){
ycor = yzero - Math.floor((powerhour[i] * 100) / maxvalue);
ctx.lineTo(xzero + i*hourwidth,ycor);
}
ctx.stroke();
ctx.restore();
}
}
} else {
// canvas-unsupported code here
}
}
function drawPowerYear(){
var canvas = document.getElementById('poweryear');
if (canvas.getContext){
var ctx = canvas.getContext('2d');
// drawing code here
ctx.save();
//Hintergrund zeichen
ctx.fillStyle = "white";//rgb(200,0,0);
ctx.fillRect (0, 0, 310, 160);
ctx.restore();
var poweryear = 0;
var maxvalue = 10;
var validcount = 0;
if(g_Meter.getPow("IsValid") == "1"){
poweryear = g_Meter.getPow("ThisYear");
var maxvalue = PowerMaxValue(poweryear,12,2000);
maxvalue = Math.floor(maxvalue/1000);
validcount = PowerValidCount(poweryear,12);
}
ctx.save();
var mytext = maxvalue + "kwh";
//Beschriftung
ctx.fillText(mytext, 3, 35);
ctx.fillText("Jan", 40, 140);
ctx.fillText("Dec", 280, 140);
ctx.restore();
ctx.save();
//Graph
ctx.beginPath();
ctx.moveTo(40,30);
ctx.lineTo(40,130);
ctx.lineTo(280,130);
ctx.stroke();
ctx.restore();
ctx.save();
if(validcount>0){
//Power Today Verlauf
ctx.beginPath();
var yearwidth = 20;
var yzero = 130;
var ymax = 30;
var xzero = 40;
ctx.fillStyle = "blue";//rgb(200,0,0);
//Power max value
ctx.moveTo(xzero,yzero);
for (var i=0;i<Math.min(12,validcount);i++){
ycor = yzero - Math.floor( (poweryear[i]/10) / maxvalue);
ctx.lineTo(xzero + i*yearwidth,ycor);
ctx.lineTo(xzero + (i+1)*yearwidth,ycor);
}
ctx.lineTo(xzero + i*yearwidth,yzero);
ctx.lineTo(xzero,yzero);
ctx.fill();
ctx.restore();
}
} else {
// canvas-unsupported code here
}
}
ready.onReady(updateValues);
</script>
<?include "templates/page_head_popup.html" ?>
<div id="uiMainDiv">
<div id="uiMainDemoBoard">
<form id="ulemon" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<!-- Power now -->
<div id="uiCurrentPower" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Power now</h2><hr></div>
<canvas id="uiMeter" width="200" height="200"></canvas>
<hr>
<div style="position:absolute; top: 280px; left:20px">
<span>Power Now</span>
<h3 id="uiPowerNowValue">- W</h3>
</div>
</div>
</div>
<div id="uiPowerLevel" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Power Today</h2><hr></div>
<canvas id="powertoday" width="310" height="160">
</canvas>
<hr>
<div style="position:absolute; top: 230px; left:20px">
<span>so far Today</span>
<h3 id="uiPowerSoFarToday">- kwh</h3>
</div>
<div style="position:absolute; top: 290px; left:20px">
<span>daily average</span>
<h3 id="uiPowerDailyAverage">- kwh</h3>
</div>
<div style="position:absolute; top: 230px; left:200px">
<span>How am In doing today?</span>
<canvas id="uiDailyPath" width="100" height="100"></canvas>
</div>
</div>
<!-- Cost -->
<div id="uiPowerCost" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Cost</h2><hr></div>
<canvas id="poweryear" width="310" height="160">
</canvas>
<hr>
<div style="position:absolute; top: 230px; left:20px">
<div class="MeterTextHead">so far Today</div>
<h3 id="uiCostSoFarToday">- €</h3>
</div>
<div style="position:absolute; top: 290px; left:20px">
<div class="MeterTextHead">daily average</div>
<h3 id="uiCostDailyAverage">- €</h3>
</div>
<div style="position:absolute; top: 230px; left:200px">
<div class="MeterTextHead">so far year</div>
<h3 id="uiCostSoFarYear">- €</h3>
</div>
<div style="position:absolute; top: 290px; left:200px">
<div class="MeterTextHead">year cost prediction</div>
<h3 id="uiCostYearPrediction">- €</h3>
</div>
</div>
<!-- Sensor Overview -->
<div id="uiSensors" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Sensor Overview</h2><hr></div>
<table class="sensoractorTable" id="uiSensorTable">
</table>
</div>
<!-- Actor Overview -->
<div id="uiActors" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Actor Overview</h2><hr></div>
<table class="sensoractorTable" id="uiActorTable">
<tr>
<th class="iconrow"></th>
<th>Name</th>
<th>Type</th>
<th>State</th>
<th class="buttonrow">Off</th>
<th class="buttonrow">On</th>
<tr>
<?lua box.out(show_actors()) ?>
</table>
</div>
<!-- Sensor Setting -->
<div id="uiButtons" class="MeterInfoElement">
<div class="InfoElementHead"><h2>Sensor Setting</h2><hr></div>
<table class="sensoractorTable">
<tr>
<th>Name</th>
<th>Action</th>
<th class="buttonrow">Save</th>
<tr>
<?lua box.out(show_sensor_settings()) ?>
</table>
</div>
</form>
</div>
<hr style="clear:both;">
<div id="uiCanvasContainer">
<div style="width: 800px; margin: auto;">
<img src="/meter/SiTelLogo.gif" width="180px">
<img src="/meter/AVM_top_logo.gif" width="180px">
</div>
</div>
<!-- Toggle Buttons -->
<div style="clear:both;">
<hr>
<div style="text-align: center;">
<a href="javascript:ToggleShowMeterInfoElement('uiCurrentPower');">Power Now</a>
<a href="javascript:ToggleShowMeterInfoElement('uiPowerLevel');">Power Today</a>
<a href="javascript:ToggleShowMeterInfoElement('uiPowerCost');">Power Cost</a>
<a href="javascript:ToggleShowMeterInfoElement('uiSensors');">Sensor Overview</a>
<a href="javascript:ToggleShowMeterInfoElement('uiActors');">Actor Overview</a>
<a href="javascript:ToggleShowMeterInfoElement('uiButtons');">Sensor Setting</a>
</div>
</div>
</div>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
