<?lua
g_page_type = "all"
g_page_title = [[{?689:161?}]]
g_page_help = "hilfe_net_plc_spectrum.html"
dofile("../templates/global_lua.lua")
require("general")
require("js")
require("http")
g_back_to_page = http.get_back_to_page( "/net/network_user_devices.lua" )
g_remote = { name="",mac=""}
if next(box.post) and box.post.remote_mac and box.get.remote_mac ~= "" then
g_remote.mac=box.post.remote_mac
elseif next(box.get) and box.get.remote_mac and box.get.remote_mac ~= "" then
g_remote.mac=box.get.remote_mac
end
g_devid=""
if box.get.dev then
g_devid = box.get.dev
elseif box.post.dev then
g_devid = box.post.dev
end
if not g_remote.mac or g_remote.mac=="" then
local param = {}
param[1]=http.url_param('dev',g_devid)
http.redirect(href.get(g_back_to_page, unpack(param)))
end
g_remote.name=""
if next(box.post) and box.post.remote_name and box.get.remote_name ~= "" then
g_remote.name=box.post.remote_name
elseif next(box.get) and box.get.remote_name and box.get.remote_name ~= "" then
g_remote.name=box.get.remote_name
end
g_menu_active_page="/net/network_user_devices.lua"
if next(box.post) and box.post.btn_cancel then
local param = {}
param[1]=http.url_param('dev',g_devid)
http.redirect(href.get(g_back_to_page, unpack(param)))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
table {
background-color: #FAF8F2;
border: 0px;
vertical-align:top;
}
th, td,tr {
vertical-align:top;
}
.column {
padding-left: 15px;
padding-top: 15px;
}
.errorText {
text-align: center;
}
#rxtonemaps,
#txtonemaps,
#phys {
}
.headline {
text-align: center;
font-size: 16px;
font-weight: bold;
margin-top:10px;
margin-bottom:10px;
}
.view {
width:100%;
height:200px
}
</style>
<script type="text/javascript">
var isIE11 = !!(navigator.userAgent.match(/Trident/) && !navigator.userAgent.match(/MSIE/));
if (isIE11) {
if (window.attachEvent == "undefined" || !window.attachEvent)
{
window.attachEvent = window.addEventListener;
}
}
</script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/jquery-1.10.1.min.js"></script>
<script type="text/javascript" src="/js/jquery.flot.js"></script>
<script type="text/javascript" src="/js/jquery.flot.fillbetween.js"></script>
<script type="text/javascript" src="/js/plc_tonemaps.ps.js"></script>
<script type="text/javascript">
var gRxPhyrates = [];
var gTxPhyrates = [];
var gPhyRateTimeStamp = new Date().getTime();
var gPhyRateLastTimeDiff = 0;
var gPlcHandle = null;
var slotColors = ["#F00000", "#00F000", "#0000F0", "#F0F000", "#00F0F0", "#F000F0"];
var g_curUID = 1234;
var gRemote = <?lua box.out(js.table(g_remote)) ?>;
var g_Coupling = 0;
function send_plc_cmd(params,cb) {
var uri = "/net/plc_json.lua";
ajaxPost(uri, addUrlParamTable(params), function (data) {
var json = makeJSONParser();
var response = json(data.responseText || "null");
cb(response);
});
}
function updateSlotMasks(masks) {
var mask = 1;
for (var i = 0; i < 6; i++)
{
jxl.setChecked("rxSlot" + (i + 1), masks.rx & mask);
jxl.setChecked("txSlot" + (i + 1), masks.rx & mask);
mask = mask << 1;
}
}
function getSlotMasks(masks) {
var mask = 1;
for (var i = 0; i < 6; i++) {
if (jxl.getChecked("rxSlot" + (i + 1)))
masks.rx = masks.rx | mask;
if (jxl.getChecked("txSlot" + (i + 1)))
masks.tx = masks.tx | mask;
mask = mask << 1;
}
}
function countMask(mask) {
var bitmask = 1;
var count = 0;
for (var i = 0; i < 6; i++) {
if (mask & bitmask) count++;
bitmask = bitmask << 1;
}
return count;
}
function displaySlot(divname, slotHeader, slotData, divider) {
var d1 = [];
var len = slotData.length;
if (slotHeader.Proc == 4) {
for (var i = 0; i < len; i += 1)
d1.push([i, slotData[i] / divider / slotHeader.Granularity]);
}
else {
for (var i = 0; i < len; i += 1)
d1.push([i, slotData[i]/slotHeader.Granularity]);
}
return d1;
}
function yAxisFormatter(val, axis) {
return val.toFixed(0)+" {?689:368?}";
}
function xAxisFormatter(val, axis) {
return ((val+74)/40.96).toFixed(2) + " {?689:920?}";
}
function initPhyRates() {
for (var i = 0; i < 60; i++ ) {
gRxPhyrates.push([i, 0]);
gTxPhyrates.push([i, 0]);
}
}
function updatePhyRates(data) {
var now = new Date().getTime();
var sumrx = data.RxPhyRate;
var sumtx = data.TxPhyRate;
gPhyRateLastTimeDiff = now - gPhyRateTimeStamp;
var indx = 59 - Math.floor(gPhyRateLastTimeDiff / 60000) % 60;
var currrx = gRxPhyrates[indx][1];
var currtx = gTxPhyrates[indx][1];
if (currrx == 0)
gRxPhyrates[indx] = [indx, sumrx];
else
gRxPhyrates[indx] = [indx, (currrx + sumrx) / 2];
if (currtx == 0)
gTxPhyrates[indx] = [indx, sumtx];
else
gTxPhyrates[indx] = [indx, (currtx + sumtx) / 2];
}
function displayCarrierData(directionText,carrierData,granularity,divider) {
var mindata = null;
var meandata = null;
var maxdata = null;
var rawdataset = [];
var rawdatacount = 0;
for (var slot = 0; slot < carrierData.length; slot++) {
var slotData = carrierData[slot];
var divname = directionText + (slot + 1);
var slotHeader = {
Proc: slotData.ProcFunction,
CarrierCount: slotData.CarrierCount,
CarrierStart:slotData.CarrierStart,
Granularity: granularity,
Slot: slotData.Slot
};
var d = displaySlot(divname, slotHeader, slotData.Carriers, divider);
switch(slotHeader.Proc) {
default:
rawdataline = { label: "{?689:48?}" + slotHeader.Slot, id: "'" + slotHeader.Slot + "'", data: d, lines: { show: true, lineWidth: 1 }, color: slotColors[slotHeader.Slot] };
rawdataset.push(rawdataline);
rawdatacount++;
break;
case 1: mindata = d; break;
case 2: maxdata = d; break;
case 4: meandata = d; break;
};
}
var showpsd = false;
var psdchbx = document.getElementById("psdDisplay");
if (psdchbx && psdchbx.checked == true)
showpsd = true;
var amfnkline = null;
var showamfnk = false;
var showamfnkchbx = document.getElementById("uiAmtFnkDisplay");
if (showamfnkchbx && showamfnkchbx.checked == true)
{
showamfnk = true;
}
g_Coupling = 0;
var showCouplingchbx = document.getElementById("uiCouplingOther");
if (showCouplingchbx && showCouplingchbx.checked == true)
{
g_Coupling = 1;
}
if (showamfnk) {
var fnkfreqs = [ [1,14.9], [69, 14.9], [212, 14.9], [336, 14.9], [500,14.9], [663,14.9], [786,14.9], [946,14.9], [1072,14.9], [1977,14.9] ];
amfnkline = { label: "{?689:189?}", id: 9, data: fnkfreqs, lines: {show: false}, bars: { show: true, barWidth: 1, vertical: true}, color: "#f7be81" };
}
var maskline = null;
if (showpsd) {
var prescaler = gPrescalerData;
var maskdata = [];
var cnt = 0;
var sum = 0;
for (var i = 0; i < prescaler.length; i++) {
if (cnt == granularity) {
maskdata.push([ 2 * (i / granularity - 1), 7.0 * Math.log( (sum / cnt) / 256) + 15]);
sum = 0; cnt = 0;
}
cnt++;
sum += prescaler[i];
}
if (cnt != granularity) {
maskdata.push([2 * (i / granularity), 7.0 * Math.log( (sum / cnt) / 256) + 15]);
}
maskline = { label: "{?689:236?}", id: "8", data: maskdata, lines: { show: true, lineWidth: 1 }, color: "#b0b0b0" };
}
if( mindata!=null && maxdata!=null && meandata!=null ) {
var dataset = [
{ id: '0', label: "{?689:736?}", data: maxdata, lines: { show: true, lineWidth: 0, fill: false }, color: "rgb(50,50,255)", fillBetween: '1' },
{ id: '1', data: mindata, lines: { show: true, lineWidth: 0, fill: 0.2 }, color: "rgb(50,50,255)", fillBetween: '0' },
{ id: '2', label: "{?689:717?}", data: meandata, lines: { show: true, lineWidth: 1, shadowsize: 0 }, color: "rgb(255,50,50)"}
];
if (maskline != null)
dataset.push(maskline);
if (showamfnk)
dataset.push(amfnkline);
$.plot($("#" + directionText), dataset, {
xaxis: { tickFormatter: xAxisFormatter },
yaxis: { tickDecimals: 0, tickFormatter: yAxisFormatter, tickLength: 20, min: 0, max: 15 },
legend: { position: 'ne', noColumns: 10 }
});
}
else if( rawdatacount>0 ) {
if (maskline != null)
rawdataset.push(maskline);
if (showamfnk)
rawdataset.push(amfnkline);
$.plot($("#" + directionText), rawdataset, {
xaxis: { tickFormatter: xAxisFormatter },
yaxis: { tickDecimals: 0, tickFormatter: yAxisFormatter, tickLength: 20, min: 0, max: 15 },
legend: { position: 'ne', noColumns: 10 }
});
}
}
function displayPhyrates(rxPhyrates, txPhyrates, rxCurrent, txCurrent) {
var dataset = [];
var rxline = { label: "{?689:865?}(" + rxCurrent + " MBit/s)", id: "1", data: rxPhyrates, lines: { show: true, lineWidth: 1 }, color: "#0000FF" };
var txline = { label: "{?689:979?}(" + txCurrent + " MBit/s)", id: "2", data: txPhyrates, lines: { show: true, lineWidth: 1 }, color: "#088A29" };
dataset.push(rxline);
dataset.push(txline);
$.plot($("#phyrates"), dataset, {
xaxis: { tickDecimals: 0, tickFormatter: function(val, axis) {return "-" + (60 - val) + " min";} },
yaxis: { tickDecimals: 0, min: 0, max: 550, tickLength: 4, tickFormatter: function(val, axis) { return val+" Mbit/s";} },
legend: { position: 'sw', noColumns:2}
});
}
function showWait(show)
{
jxl.display("rxErr", show);
jxl.display("txErr", show);
jxl.display("phyratesErr", show);
var pleaseWait="{?689:740?}";
if (show) {
jxl.setStyle("rx", "visibility", "hidden");
jxl.setStyle("tx", "visibility", "hidden");
jxl.setStyle("phyrates", "visibility", "hidden");
jxl.setText("rxErr",pleaseWait);
jxl.setText("txErr",pleaseWait);
jxl.setText("phyratesErr",pleaseWait);
} else {
jxl.setStyle("rx", "visibility", "inherit");
jxl.setStyle("tx", "visibility", "inherit");
jxl.setStyle("phyrates", "visibility", "inherit");
}
}
function showError(show) {
jxl.display("rxErr", show);
jxl.display("txErr", show);
jxl.display("phyratesErr", show);
if (show) {
jxl.setText("rxErr","{?689:860?}");
jxl.setStyle("rx", "visibility", "hidden");
jxl.setText("txErr","{?689:886?}");
jxl.setStyle("tx", "visibility", "hidden");
jxl.setText("phyratesErr","{?689:106?}");
jxl.setStyle("phyrates", "visibility", "hidden");
} else {
jxl.setStyle("rx", "visibility", "inherit");
jxl.setStyle("tx", "visibility", "inherit");
jxl.setStyle("phyrates", "visibility", "inherit");
}
}
function onData(data) {
if (jxl.getChecked("autoUpdate"))
window.setTimeout(timerRequestData,2000);
if (data && data.Status == 0 && data.UID==g_curUID){
showError(false);
//updateSlotMasks({ rx: data.RxSlotMask, tx: data.TxSlotMask });
if (data.RxCarrierData)
displayCarrierData("rx", data.RxCarrierData, data.Granularity, countMask(data.RxSlotMask));
if (data.TxCarrierData)
displayCarrierData("tx", data.TxCarrierData, data.Granularity, countMask(data.TxSlotMask));
updatePhyRates(data);
displayPhyrates(gRxPhyrates, gTxPhyrates, data.RxPhyRate, data.TxPhyRate);
} else {
showError(true);
}
}
function timerRequestData() {
var plcDataHandle = gPlcHandle;
if (gPlcHandle && plcDataHandle.CarrierCount > 0) {
var procFunction = jxl.getValue("uiProcFunction");
var granularity = jxl.getValue("uiGranularity");
var masks = {rx: 0, tx: 0};
getSlotMasks(masks);
send_plc_cmd({
Cmd: "RequestData",
HandleId: plcDataHandle.HandleId,
ProcFunction: procFunction,
RxSlotMask: masks.rx,
TxSlotMask: masks.tx,
CarrierStart: 0,
CarrierCount: plcDataHandle.CarrierCount,
Granularity: granularity,
UID: g_curUID,
Coupling: g_Coupling,
sid: "<?lua box.js(box.glob.sid)?>"
}, onData);
} else {
showError(true);
}
}
function onDataHandle(plcDataHandle) {
gPlcHandle = plcDataHandle;
if (gPlcHandle)
{
updateSlotMasks({ rx: plcDataHandle.RxSlotMask, tx: plcDataHandle.TxSlotMask });
timerRequestData();
}
else
{
showError(true);
}
}
function onAdapterList(adapterList) {
gAdapterList = adapterList;
var AdapterList = gAdapterList.Adapters;
var RemoteAdapters=[];
var RemoteElem = null;
var Remote_mac="";
var Local_mac="";
function findLocalByMac(adapters,mac)
{
for (var idx in adapters)
{
var elem=adapters[idx];
if( elem.isLocal && elem.active=="1" && elem.mac==mac)
return elem;
}
return null;
}
function findRemoteByMac(adapters,mac)
{
for (var idx in adapters)
{
var elem=adapters[idx];
if(elem.mac==mac)
{
if (elem.usr=="" && gRemote.name!="")
{
elem.usr=gRemote.name;
}
return elem;
}
}
return null;
}
function getLocal(adapters,RemoteAdapters)
{
for (var idx in RemoteAdapters)
{
var mac=RemoteAdapters[idx];
var localelem=findLocalByMac(adapters,mac)
if (localelem)
return localelem;
}
return null;
}
function get_name(elem)
{
return elem.usr!=""?elem.usr:elem.mac
}
RemoteElem=findRemoteByMac(AdapterList,gRemote.mac);
if (!RemoteElem)
{
showError(true);
return;
}
Remote_mac = RemoteElem.mac;
RemoteAdapters=RemoteElem.remoteAdapters.split(",");
LocalElem = getLocal(AdapterList,RemoteAdapters);
if (!LocalElem)
{
showError(true);
return;
}
Local_mac = LocalElem.mac;
var txtExplain=jxl.sprintf("{?689:203?}",get_name(RemoteElem),get_name(LocalElem))
if (LocalElem.couplingClass=="MIMO")
{
jxl.display("uiShowMimo",true);
}
jxl.setText("uiExplain",txtExplain);
jxl.display("uiNeigbours",true);
getHandle(Local_mac,Remote_mac);
}
function getHandle(Local_mac,Remote_mac)
{
if (Local_mac && Remote_mac) {
showWait(true);
send_plc_cmd({
Cmd: "RequestDataHandle",
AdapterFrom: Local_mac,
AdapterTo: Remote_mac,
Coupling: g_Coupling,
sid: "<?lua box.js(box.glob.sid)?>"
}, onDataHandle);
}
else {
showError(true);
}
}
function getAdapterList()
{
send_plc_cmd({
Cmd: "ListAdapters",
sid: "<?lua box.js(box.glob.sid)?>"
}, onAdapterList);
}
function init() {
$.support.cors = true;
var elem = document.createElement('canvas');
if (elem.getContext && elem.getContext('2d')){
initPhyRates();
getAdapterList();
} else {
jxl.hide("allElems");
jxl.show("noCanvas");
}
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="noCanvas" style="display: none;">{?689:638?}</div>
<div id="allElems">
<div id="uiNeigbours" style="display:none;">
<p id="uiExplain"></p>
<hr>
</div>
<div id="uiShowMimo" style="display:none;">
<p>
{?689:937?}
</p>
<div>
<input type="radio" id="uiCouplingStandard" name="coupling" checked><label for="uiCouplingStandard">{?689:316?}</label>
</div>
<div>
<input type="radio" id="uiCouplingOther" name="coupling"><label for="uiCouplingOther">{?689:913?}</label>
</div>
</div>
<div id="rxtonemaps">
<div class="headline">{?689:834?}</div>
<div id="rxErr" class="errorText" style="display: none;"></div>
<div id="rx" class="view"></div>
</div>
<div id="txtonemaps">
<div class="headline">{?689:990?}</div>
<div id="txErr" class="errorText" style="display: none;"></div>
<div id="tx" class="view"></div>
</div>
<div id="phys">
<div class="headline">{?689:250?}</div>
<div id="phyratesErr" class="errorText" style="display: none;"></div>
<div id="phyrates" class="view"></div>
</div>
<table class="settings">
<tr>
<td class="column">
<table>
<tr>
<th>{?689:713?}</th>
<th>1</th>
<th>2</th>
<th>3</th>
<th>4</th>
<th>5</th>
<th>6</th>
</tr>
<tr>
<td>{?689:5915?}</td>
<td><input id="rxSlot1" type="checkbox" checked="checked"/></td>
<td><input id="rxSlot2" type="checkbox" checked="checked"/></td>
<td><input id="rxSlot3" type="checkbox" checked="checked"/></td>
<td><input id="rxSlot4" type="checkbox" checked="checked"/></td>
<td><input id="rxSlot5" type="checkbox" checked="checked"/></td>
<td><input id="rxSlot6" type="checkbox" checked="checked"/></td>
</tr>
<tr>
<td>{?689:97?}</td>
<td><input id="txSlot1" type="checkbox" checked="checked"/></td>
<td><input id="txSlot2" type="checkbox" checked="checked"/></td>
<td><input id="txSlot3" type="checkbox" checked="checked"/></td>
<td><input id="txSlot4" type="checkbox" checked="checked"/></td>
<td><input id="txSlot5" type="checkbox" checked="checked"/></td>
<td><input id="txSlot6" type="checkbox" checked="checked"/></td>
</tr>
</table>
</td>
<td class="column">
<table >
<tr>
<th>{?689:154?}</th>
</tr>
<tr>
<td>
<select id="uiProcFunction" style="width:150px;">
<option value="0">{?689:967?}</option>
<option value="7" selected="selected">{?689:269?}</option>
</select>
</td>
</tr>
</table>
</td>
<td class="column">
<table >
<tr>
<th>&nbsp;
</th>
</tr>
<tr>
<td>
<input id="uiAmtFnkDisplay" type="checkbox" checked="checked">
<label for="uiAmtFnkDisplay">{?689:41?}</label>
</td>
</tr>
</table>
</td>
<td class="column">
<table style="display: none;">
<tr>
<td>{?689:627?}</td>
</tr>
<tr>
<td>
<select id="uiGranularity" style="width:70px;">
<option selected="selected">1</option>
<option>2</option>
<option>4</option>
<option>8</option>
<option>16</option>
<option>32</option>
</select>
</td>
</tr>
</table>
</td>
</tr>
</table>
<div id="btn_form_foot">
<input type="hidden" name="dev" value="<?lua box.html(g_devid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<div style="display: none;"><input id="autoUpdate" type="checkbox" checked="checked" onclick="timerRequestData()">{?689:233?}</div>
<button type="submit" name="btn_cancel">{?txtOk?}</button>
<button type="button" id="queryButton" onclick="getAdapterList()">{?689:99?}</button>
</div>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
