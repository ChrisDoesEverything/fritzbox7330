<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_dect_moni_erweitert.html"
dofile("../templates/global_lua.lua")
require("general")
require("js")
require("cmtable")
g_var = {}
function get_var()
local handsets = general.listquery("dect:settings/Handset/list(Subscribed,Name,State,Channel,HSDataValid,Uptime,BERTESTMODE)")
g_var.handsets = {}
for idx, hs in pairs(handsets) do
if hs.Subscribed == "1" then
box.query("dect:settings/"..hs._node.."/Basestatus")
hs.id = hs._node
local basestatus = general.listquery("dect:settings/"..hs._node.."/Basestatus/list(ACRC,XCRC,ZCRC,SLIDEERR,SYNCERR,QBIT1COUNT,QBIT2COUNT,CONNECTTIME,HANDOVER,RSSI,BER,RXCOUNT)")
hs.Basestatus = basestatus[1]
local handsetstatus = general.listquery("dect:settings/"..hs._node.."/Handsetstatus/list(CRCVALID,ACRC,XCRC,ZCRC,SLIDEERR,SYNCERR,QBIT1COUNT,QBIT2COUNT,CONNECTTIME,HANDOVER,RSSI,BER,RXCOUNT,Channel)")
hs.Handsetstatus = handsetstatus[1]
table.insert(g_var.handsets, hs)
end
end
end
get_var()
function write_table_row(text, id)
box.out( [[
<tr>
<td>]]..text..[[</td>
<td id="]]..id..[[1" class="c2"></td>
<td id="]]..id..[[2" class="c2"></td>
<td id="]]..id..[[3" class="c2"></td>
<td id="]]..id..[[4" class="c2"></td>
</tr>
]])
end
if box.get.useajax then
if (box.get.bertest and box.get.hsId) then
local hsId = box.get.hsId
local ctlmgr_save={}
if box.get.bertest == "1" then
cmtable.add_var(ctlmgr_save, "dect:command/"..hsId.."/StartBitrateTest", "21811,0")
else
cmtable.add_var(ctlmgr_save, "dect:command/"..hsId.."/StopBitrateTest", "1")
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
box.query("dect:settings/"..hsId.."/Basestatus")
box.out(box.query("dect:settings/"..hsId.."/BERTESTMODE"))
end
box.end_page()
end
box.out(js.table(g_var.handsets))
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style>
table.tDectEx { table-layout:fixed; width:100%; text-align:left; }
table.tDectEx td, .tDectEx th { font-size:13px; padding: 2px 3px; white-space:nowrap; overflow: hidden; }
table.tDectEx .c1 { width:200px; text-align:right; }
table.tDectEx .c2 { text-align:right; padding-right:5px;}
table.tDectEx th.sub { font-size: 12px; font-weight:normal; }
table.tRssi { table-layout:fixed; width:100%; text-align:left; }
table.tRssi td, .tRssi th { font-size:13px; padding: 2px 3px; white-space:nowrap; overflow: hidden; }
table.tRssi td { text-align: right; }
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script>
function init() {
updateTables();
StateConnectCheck();
startAjax();
}
function onAccReset() {
var hsId = jxl.getValue("uiViewSelectHandset");
if (hsId) {
g_Handsets.reset(hsId);
}
resetAccTableValues(hsId);
}
var g_txt = {
startBERTest: "{?1178:903?}",
stopBERTest: "{?1178:25?}",
notConnected: "{?1178:971?}"
};
var g_postBERTest;
function readHandsetsFromBox() {
var result = <?lua box.out(js.table(g_var.handsets)) ?>;
return result;
}
var g_Handsets = (function () {
var handsets = readHandsetsFromBox();
var values = calcAllValues(handsets);
function findIdx(hsId) {
for (var i = 0, len = handsets.length; i < len; i++) {
if (handsets[i].id == hsId) {
return i;
}
}
return 0;
}
function setValue(hsId, property, Value) {
var i = findIdx(hsId);
if (i > 0) {
values[i][property] = Value;
}
}
function getValue(type ,hsId, view, property, rssiIdx) {
var i = findIdx(hsId);
if (!view) {
return values[i][property];
}
if (type == 'curr' && !values[i][view].CRCVALID) {
return "?";
}
if (property == "RSSI") {
if (type == 'acc') {
return " - ";
}
if (isNaN(rssiIdx) || rssiIdx < 0) {
if (isNaN(values[i].Channel)) {
return " - ";
}
if(view == "Handsetstatus"){
if (isNaN(values[i][view]["Channel"]["curr"])) {
rssiIdx = values[i].Channel;
}else{
rssiIdx = values[i][view]["Channel"]["curr"];
}
}else{
rssiIdx = values[i].Channel;
}
}
return values[i][view].RSSI[rssiIdx];
}
var result = values[i][view][property] || 0;
if (typeof result != 'undefined') {
result = result[type];
}
return result || 0;
}
return {
update: function (newHandsets) {
handsets = newHandsets;
values = calcAllValues(handsets,values);
},
setVal: function (hsId, property, Value) {
setValue(hsId, property, Value);
},
getVal: function (hsId, view, property, rssiIdx) {
return getValue('curr',hsId, view, property, rssiIdx);
},
getAccVal: function (hsId, view, property, rssiIdx) {
return getValue('acc',hsId, view, property, rssiIdx);
},
getValidIds: function () {
var result = [];
for (var i = 0, len = handsets.length; i < len; i++) {
if (handsets[i].Subscribed == "1") { //&& handsets[i].HSValidData == "1") {
result.push(handsets[i].id);
}
}
return result;
},
reset: function (hsId) {
var i = findIdx(hsId);
if (i < 1) {
return;
}
values[i].Basestatus = {};
values[i].Handsetstatus = {};
}
};
})();
function calcAllValues(handsets, values) {
values = values || [];
for (var i = 0, len = handsets.length; i < len; i++) {
var hs = handsets[i];
values[i] = values[i] || {};
values[i].id = hs.id;
values[i].Channel = parseInt(hs.Channel, 10);
values[i].Uptime = parseInt(hs.Uptime, 10) || 0;
values[i].BERTESTMODE = parseInt(hs.BERTESTMODE, 10) || 0;
var state = parseInt(hs.State, 10) || 0;
var oldConnected = values[i].Connected;
values[i].Connected = state == 2 || state == 3;
if (!oldConnected && values[i].Connected) {
values[i].Basestatus = {};
values[i].Handsetstatus = {};
}
else {
values[i].Basestatus = values[i].Basestatus || {};
values[i].Handsetstatus = values[i].Handsetstatus || {};
}
values[i].Basestatus = calcStatusValues(hs.Basestatus, values[i].Basestatus);
values[i].Handsetstatus = calcStatusValues(hs.Handsetstatus, values[i].Handsetstatus);
}
return values;
}
function calcStatusValues(hsStatus, valStatus) {
var crcValid = typeof hsStatus.CRCVALID == 'undefined' || hsStatus.CRCVALID == "1";
valStatus.CRCVALID = crcValid;
if (crcValid) {
for (var prop in hsStatus) {
switch (prop) {
case "CRCVALID":
break;
case "RSSI":
var rssi = hsStatus.RSSI.split(",");
valStatus.RSSI = rssi;
break;
case "CONNECTTIME":
valStatus[prop] = valStatus[prop] || {};
valStatus[prop].curr = (parseInt(hsStatus[prop], 10) || 0) * 10;
valStatus[prop].acc = (valStatus[prop].acc || 0) + valStatus[prop].curr;
break;
case "Channel":
valStatus[prop] = valStatus[prop] || {};
valStatus[prop].curr = parseInt(hsStatus[prop], 10) || " - ";
valStatus[prop].acc = "0";
break;
default:
valStatus[prop] = valStatus[prop] || {};
valStatus[prop].curr = parseInt(hsStatus[prop], 10) || 0;
valStatus[prop].acc = (valStatus[prop].acc || 0) + valStatus[prop].curr;
break;
}
}
}
return valStatus;
}
function getFramesPercValue(errorItems,itemCount){
return getCalcFramesPercValue(errorItems,(itemCount/10)) + "%";
}
function getCalcFramesPercValue(errorItems,itemCount){
if(itemCount>0){
var percentFrames = Math.round((errorItems*1000)/itemCount) / 10;
if(isNaN(percentFrames) || percentFrames<0){
percentFrames=0;
}else if(percentFrames>100){
percentFrames=100;
}
return percentFrames;
}else{
return 0;
}
}
function getAccDefectBitsValue(handsetId,view){
var defectBits = g_Handsets.getAccVal(handsetId,view,"BER",0);
var ConnectTime = g_Handsets.getAccVal(handsetId,view,"CONNECTTIME",0);
var BitsCount = (ConnectTime /10 )* 320;//40 Byte-payload * 8 bit * 2 slots, ABER dann durch 2 weil Bitfehler nicht 100% sein kann - geht nur zur hälfte ein
var rxCountDiff = 0;
if(ConnectTime>0){
rxCountDiff = (ConnectTime / 10) - g_Handsets.getAccVal(handsetId,view,"RXCOUNT",0);
}
defectBits+=rxCountDiff * 640;
BERPerc = getCalcFramesPercValue(defectBits,BitsCount);
return BERPerc + "%";
}
function getCurrDefectBitsValue(handsetId,view){
var defectBits = g_Handsets.getVal(handsetId,view,"BER",0);
var connectTime = g_Handsets.getVal(handsetId,view,"CONNECTTIME",0);
var BitsCount = (connectTime /10 )* 320;//40 Byte-payload * 8 bit * 2 slots, ABER dann durch 2 weil Bitfehler nicht 100% sein kann - geht nur zur hälfte ein
var rxCountDiff = 0;
if(connectTime>0){
rxCountDiff = (connectTime / 10) - g_Handsets.getVal(handsetId,view,"RXCOUNT",0);
}
defectBits+=rxCountDiff * 640;
BERPerc = getCalcFramesPercValue(defectBits,BitsCount);
return BERPerc + "%";
}
function getAccDefectFramesValue(handsetId,view){
var defectFrames = g_Handsets.getAccVal(handsetId,view,"ACRC",0) + g_Handsets.getAccVal(handsetId,view,"XCRC",0) + g_Handsets.getAccVal(handsetId,view,"SYNCERR",0) + g_Handsets.getAccVal(handsetId,view,"SLIDEERR",0);
var connectTime = g_Handsets.getAccVal(handsetId,view,"CONNECTTIME",0);
return getFramesPercValue(defectFrames,connectTime);
}
function getCurrDefectFramesValue(handsetId,view){
var defectFrames = g_Handsets.getVal(handsetId,view,"ACRC",0) + g_Handsets.getVal(handsetId,view,"XCRC",0) + g_Handsets.getVal(handsetId,view,"SYNCERR",0) + g_Handsets.getVal(handsetId,view,"SLIDEERR",0);
var connectTime = g_Handsets.getVal(handsetId,view,"CONNECTTIME",0);
return getFramesPercValue(defectFrames,connectTime);
}
function getAccDFramesValue(handsetId,view){
var droppedFrames = g_Handsets.getAccVal(handsetId,view,"SYNCERR",0) + g_Handsets.getAccVal(handsetId,view,"SLIDEERR",0);
var connectTime = g_Handsets.getAccVal(handsetId,view,"CONNECTTIME",0);
return getFramesPercValue(droppedFrames,connectTime);
}
function getCurrDFramesValue(handsetId,view){
var droppedFrames = g_Handsets.getVal(handsetId,view,"SYNCERR",0) + g_Handsets.getVal(handsetId,view,"SLIDEERR",0);
var connectTime = g_Handsets.getVal(handsetId,view,"CONNECTTIME",0);
return getFramesPercValue(droppedFrames,connectTime);
}
function getCurrValue(handsetId,view,property,rssiIdx) {
return g_Handsets.getVal(handsetId,view,property,rssiIdx);
}
function getAccValue(handsetId,view,property,rssiIdx) {
return g_Handsets.getAccVal(handsetId,view,property,rssiIdx);
}
function startAjax() {
function cbUpdate(xhr) {
if (xhr.status == 200) {
jxl.disable("uiResetAcc");
var json = makeJSONParser();
g_Handsets.update(json(xhr.responseText || "null"));
jxl.enable("uiResetAcc");
updateTables();
}
window.setTimeout(sendRequest, 2000);
}
function sendRequest(xhr) {
var url = "/dect/dect_moni_ex.lua?useajax=1";
url += "&sid=<?lua box.js(box.glob.sid) ?>";
ajaxGet(url, cbUpdate);
}
sendRequest();
}
var g_trOrder = [
'CONNECTTIME','ACRC','XCRC','ZCRC','SLIDEERR','SYNCERR','QBIT1COUNT','QBIT2COUNT','HANDOVER','RSSI','BER'
];
function StateConnectCheck()
{
var hsId = jxl.getValue("uiViewSelectHandset");
var uptimeTxt = jxl.getHtml("uiUptime");
if ((g_Handsets.getVal(hsId, "", "BERTESTMODE") == 1) || (uptimeTxt == "" || uptimeTxt == "(" + g_txt.notConnected + ")"))
{
return;
}
if (g_Handsets.getVal(hsId, false, "Connected", ""))
{
jxl.disable("uiBERTest");
}
else
{
jxl.enable("uiBERTest");
}
}
function updateBERTestBtn(hsId) {
var tstBtnId = "uiBERTest";
var tstRunning = g_Handsets.getVal(hsId, "", "BERTESTMODE") == 1;
jxl.setValue(tstBtnId, tstRunning ? g_txt.stopBERTest : g_txt.startBERTest);
}
function resetAccTableValues(hsId) {
var table = document.getElementById("dect_value");
if (table) {
var rows = table.rows;
for (var i = 2, rowLen = rows.length-1; i < rowLen; i++) {
var cells = rows[i].cells;
cells[1].innerHTML = "0";
cells[3].innerHTML = "0";
}
}
}
function uptimeStr(hsId, uptime) {
uptime = parseInt(uptime,10) || 0;
if (uptime > 0) {
return "(" + "{?1178:328?}" + ": " + timeConvert(uptime*10) + " " + "{?txtSekunden?}" + ")";
}
return "(" + g_txt.notConnected + ")";
}
function timeConvert(ms) {
var str = "" + Number(ms/1000).toFixed(3);
return str.replace(".",",");
}
function setErrRowValues(hsId, rowId, func1, func2) {
jxl.setText(rowId + "1", func1.apply(this, [hsId, "Handsetstatus"]));
jxl.setText(rowId + "2", func2.apply(this, [hsId, "Handsetstatus"]));
jxl.setText(rowId + "3", func1.apply(this, [hsId, "Basestatus"]));
jxl.setText(rowId + "4", func2.apply(this, [hsId, "Basestatus"]));
}
function setRowValues(hsId, rowId, property, rssiIdx) {
jxl.setText(rowId + "1", getAccValue(hsId,"Handsetstatus", property));
jxl.setText(rowId + "2", getCurrValue(hsId,"Handsetstatus", property));
jxl.setText(rowId + "3", getAccValue(hsId,"Basestatus", property));
jxl.setText(rowId + "4", getCurrValue(hsId,"Basestatus", property));
}
function setRssiRowValues(hsId, rssiIdx) {
for (var i = 0; i <= 9; i++) {
jxl.setText("handsetCurr" + i, getCurrValue(hsId, "Handsetstatus", "RSSI", i));
jxl.setText("baseCurr" + i, getCurrValue(hsId, "Basestatus", "RSSI", i));
var channel = g_Handsets.getVal(hsId, "", "Channel") || -1;
if (i == channel) {
jxl.setStyle("handsetCurr" + i, "fontWeight", "bold");
}
else {
jxl.setStyle("handsetCurr" + i, "fontWeight", "normal");
}
}
}
function updateTables()
{
var hsId = jxl.getValue("uiViewSelectHandset");
setRowValues(hsId, "connectTime", "CONNECTTIME");
setRowValues(hsId, "acrc", "ACRC");
setRowValues(hsId, "xcrc", "XCRC");
setRowValues(hsId, "zcrc", "ZCRC");
setRowValues(hsId, "slideerr", "SLIDEERR");
setRowValues(hsId, "syncerr", "SYNCERR");
setRowValues(hsId, "qbit1count", "QBIT1COUNT");
setRowValues(hsId, "qbit2count", "QBIT2COUNT");
setRowValues(hsId, "handover", "HANDOVER");
setRowValues(hsId, "rssi", "RSSI", -1);
setRowValues(hsId, "biterr", "BER");
setRowValues(hsId, "biterr", "BER");
setErrRowValues(hsId, "droppedFrames", getAccDFramesValue, getCurrDFramesValue);
setErrRowValues(hsId, "defectFrames", getAccDefectFramesValue, getCurrDefectFramesValue);
setErrRowValues(hsId, "ber", getAccDefectBitsValue, getCurrDefectBitsValue);
setRssiRowValues(hsId)
var uptimeSpan = document.getElementById("uiUptime");
if (uptimeSpan)
uptimeSpan.innerHTML = uptimeStr(hsId, g_Handsets.getVal(hsId,"","Uptime"));
updateBERTestBtn(hsId);
StateConnectCheck();
}
function onBERTest() {
var hsId = jxl.getValue("uiViewSelectHandset");
function cbBERTest(response)
{
var result = parseInt(response.responseText,10) || 0;
jxl.setValue("uiBERTest", result == 1 ? g_txt.stopBERTest : g_txt.startBERTest);
jxl.setStyle("uiBERTest","cursor","");
jxl.enable("uiBERTest");
jxl.enable("uiViewSelectHandset");
}
var Connected = g_Handsets.getVal(hsId, false, "Connected", "");
var testRunning = g_Handsets.getVal(hsId, "", "BERTESTMODE") == 1;
if (Connected && (!testRunning))
{
alert("{?3704:716?}");
return;
}
jxl.disable("uiViewSelectHandset");
jxl.disable("uiBERTest");
jxl.setStyle("uiBERTest","cursor","wait");
var url = "/dect/dect_moni_ex.lua?useajax=1&bertest="+ (testRunning ? "0" : "1") + "&hsId=" + hsId;
url += "&sid=<?lua box.js(box.glob.sid) ?>";
ajaxGet(url, cbBERTest);
}
function uiDoOnMainFormSubmit()
{
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "uiMainForm" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
Auf dieser Seite können Sie anhaltende Probleme Ihrer DECT-Verbindungen analysieren.
</p>
<hr>
<?lua
if #g_var.handsets > 0 then
box.out([[
<div>
<h4>{?3704:977?}</h4>
<p>
{?1178:394?}
</p>
<select id="uiViewSelectHandset" name="selected_handset" onchange="updateTables()"> ]])
-- selection nicht vergessen
for i, hs in pairs(g_var.handsets) do
if hs.Subscribed == "1" then
box.out([[<option value="]]..hs._node..[[">]]..hs.Name..[[</option>]])
end
end
box.out([[
</select>
<span id="uiUptime"></span>
</div>
<div>
<p style="text-align:right;"><input type="button" id="uiBERTest" value="{?1178:180?}" class="PushbuttonBig" onclick="onBERTest()"></p>
<table id="dect_value" class="zebra">
<tr>
<th class="c1"></th>
<th colspan="2" class="c2">{?1178:529?}</th>
<th colspan="2" class="c2">{?1178:52?}</th>
</tr>
<tr>
<th class="c1 sub" style="background-color:#F8F8F8;"></th>
<th class="c2 sub" style="background-color:#F8F8F8;">{?1178:472?}</th>
<th class="c2 sub" style="background-color:#F8F8F8;">{?1178:383?}</th>
<th class="c2 sub" style="background-color:#F8F8F8;">{?1178:990?}</th>
<th class="c2 sub" style="background-color:#F8F8F8;">{?1178:525?}</th>
</tr> ]])
write_table_row("{?1178:859?}", "connectTime")
write_table_row("A-CRC", "acrc")
write_table_row("X-CRC", "xcrc")
write_table_row("Z-CRC", "zcrc")
write_table_row("Slide-Error", "slideerr")
write_table_row("Sync-Error", "syncerr")
write_table_row("Q1/BCK Bit", "qbit1count")
write_table_row("Q2 Bit", "qbit2count")
write_table_row("Handover", "handover")
write_table_row("RSSI", "rssi")
write_table_row("Bit-Error", "biterr")
write_table_row("dropped Frames", "droppedFrames")
write_table_row("defect Frames", "defectFrames")
write_table_row("BER", "ber")
box.out([[
</table>
</div>
<hr>
<div>
<table id="tRssi$1" class="mt10 tborder tRssi zebra">
<tr>
<th colspan="11">{?1178:665?}</th>
</tr>
<tr>
<td>{?1178:233?}</td>
<td>1897,3</td>
<td>1895,6</td>
<td>1893,9</td>
<td>1892,2</td>
<td>1890,4</td>
<td>1888,7</td>
<td>1887,0</td>
<td>1885,2</td>
<td>1883,5</td>
<td>1881,8</td>
</tr>
<tr>
<td >{?1178:611?}</td> ]])
for i = 0, 9, 1 do
box.out([[<td ><span id="handsetCurr]]..i..[["></span></td>]])
end
box.out([[
</tr>
<tr>
<td>{?1178:827?}</td>]])
for i = 0, 9, 1 do
box.out([[<td ><span id="baseCurr]]..i..[["></span></td>]])
end
box.out([[
</tr>
</table>
</div>]])
else
box.out([[<div id="uiNoHGPresentInfo">{?3704:196?}</div>]])
end
?>
<div id="btn_form_foot">
<button type="button" onclick="onAccReset()" id="btnReset">{?txtReset?}</button>
<button type="submit" name="btn_refresh" id="btnRefresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
