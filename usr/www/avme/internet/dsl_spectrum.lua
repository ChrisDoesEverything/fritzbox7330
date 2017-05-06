<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_dslinfo_Spektrum.html'
dofile("../templates/global_lua.lua")
require("general")
require"js"
require("libluadsl")
function get_empty_struct()
return {
PORTS=1,
BONDING=false,
ACT_SNR_VALUES = {},
MIN_SNR_VALUES = {},
MAX_SNR_VALUES = {},
ACT_BIT_VALUES = {},
PILOT = "",
BIT_US_BANDCONFIG = "",
DETECTED_RFI_VALUES= {},
MIN_BIT_VALUES = {},
MAX_BIT_VALUES = {}
}
end
if (next(box.post) and (box.post.cancel)) then
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
g_data.ports = 1
g_data.port = {}
g_data.port[1] = luadsl.getSpectrum(1,"DS")
if (g_data.port[1].PORTS and g_data.port[1].PORTS>1) then
g_data.ports = g_data.port[1].PORTS
for i = 1, g_data.port[1].PORTS, 1 do
g_data.port[i] = {}
g_data.port[i] = luadsl.getSpectrum(i,"DS")
end
end
function refill_user_input()
end
function write_bits_canvas()
local ports = g_data.ports
for i = 1, ports - 1, 1 do
local top = (ports + i - 1) * 150 - 15
box.out([[<canvas id="graph_bits]]..i..[[" width="512" height="90" style="border:0px solid #000000;position: absolute;margin-top:]]..top..[[px;margin-left:117px;"></canvas>]])
end
box.out([[<canvas id="graph_bits]]..ports..[[" width="512" height="90" style="border:0px solid #000000;position: absolute;margin-top:]]..((2* ports - 1) * 150)..[[px;margin-left:117px;"></canvas>]])
end
function write_signal_canvas()
box.out([[<canvas id="graph_signal1" width="512" height="90" style="border:0px solid #000000;position: absolute;margin-top:15px;margin-left:117px;"></canvas>]])
for i = 2, g_data.ports, 1 do
local top = (i - 1) * 150
box.out([[<canvas id="graph_signal]]..i..[[" width="512" height="90" style="border:0px solid #000000;position: absolute;margin-top:]]..top..[[px;margin-left:117px;"></canvas>]])
end
end
function write_colspan1()
if g_data.port and g_data.port[1] and g_data.port[1].MIN_BIT_VALUES then
box.out(tostring(2 + #g_data.port[1].MIN_BIT_VALUES))
else
box.out('514')
end
end
function write_colspan2()
if g_data.port and g_data.port[1] and g_data.port[1].MIN_BIT_VALUES then
box.out(tostring(1 + #g_data.port[1].MIN_BIT_VALUES))
else
box.out('513')
end
end
if next(box.post) and (box.post.send ) then
end
if box.get.useajax then
box.out(js.table(g_data))
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#Table1 {
padding:0;
background-color:transparent;
/*height:318px;*/
width:auto;
margin:auto;
border:0 none;
border-spacing:0px;
font-size:11px;
}
#Table1 tr, #Table1 td {
padding:0px 0px;
margin:0;
line-height:0;
}
#Table1 tr.dslSpectrumBITS, tr.dslSpectrumBITS td,
#Table1 tr.dslSpectrumSNR, tr.dslSpectrumSNR td {
height:91px;
vertical-align:bottom;
}
tr.dslSpectrumSNR img, tr.dslSpectrumBITS img{
border:0 none;
outline: 0 none;
}
tr.dslSpectrumSNR span, tr.dslSpectrumBITS span{
display:inline-block;
width:100%;
}
.blue {
background-color:#0000ff;
}
.lightblue {
background-color:#e1f4ff;
}
.orange {
background-color:#ff9b00;
}
.darkorange {
background-color:#c8781d;
}
.red {
background-color:#ff0000;
}
.white {
background-color:#ffffff;
}
.yellow {
background-color:#ffff00;
}
.green {
background-color:#00ff00;
}
.pilot {
height:91px;
background-color:#ff0000;
}
.bitCells {
background: url("/css/default/images/bitsnr_bitbackground.gif");
width:1px;
}
.snrCells {
background: url("/css/default/images/bitsnr_snrbackground.gif") no-repeat;
width:1px;
}
.BitsLegendeText{
font-size:11px;
height:14px;
}
#Table1 td.ColorLegendeItem {
width:20px;
}
#Table1 td.ColorLegendeItem div{
border: 2px;
border-style:solid;
border-width:1px;
border-color:black;
font-size:1px;
width:6px;
height:6px;
}
#Table1 td.Legend {
padding-top: 7px;
text-align : center;
}
#Table1 td.Legend table{
border:0 none;
background-color:transparent;
width:408px;
margin:auto;
}
#Table1 td.Legend tr {
height:14px;
}
#Table1 td.Legend td {
white-space:nowrap;
}
#Table1 tr.btncolumn, #Table1 td.btncolumn {
line-height:20px;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript">
var g_spectrum = <?lua box.out(js.table(g_data)) ?>;
var g_mincolor = "rgb(255,155,0)";
var g_maxcolor = "rgb(200,120,29)";
var g_show_MinMax=<?lua if box.get.min_max then box.out(" true ") else box.out(" false ") end ?>;
var g_snrMax = 512;
function renderGraphSnr(spectrumId, spectrum)
{
var spectrumSnr = jxl.get(spectrumId);
var marginValues;
var rfi;
if (spectrum && spectrum.ACT_SNR_VALUES && spectrum.ACT_SNR_VALUES.length)
{
marginValues = spectrum.ACT_SNR_VALUES;
rfi = spectrum.DETECTED_RFI_VALUES;
g_snrMax = marginValues.length;
}
for (var i=0; i<g_snrMax; i++) {
var stoerer = false;
if (rfi) {
for(var s = 0; s < Number(rfi.length); s++){
if (rfi[s] == i)
stoerer = true;
}
}
var height = 0;
var spanClass = "yellow";
if (!marginValues)
{
height = 0;
spanClass = "yellow";
}
else if (stoerer)
{
height = 89;
spanClass = "white";
//continue;
} else {
height = marginValues[i];
height = 90 * height / 127;
if (height > 90) height = 90;
spanClass = "yellow";
}
var td = document.createElement("td");
jxl.addClass(td, "snrCells");
var span = document.createElement("span");
jxl.addClass(span, spanClass);
jxl.setStyle(span, "height", height + "px");
td.appendChild(span);
spectrumSnr.appendChild(td);
}
var endTd = document.createElement("td");
endTd.width = 18;
spectrumSnr.appendChild(endTd);
}
var g_bitsMax = 512;
function renderGraphBits(spectrumId, spectrum)
{
var spectrumBits = jxl.get(spectrumId);
var bitsValues;
var height;
var pilot;
var US_band_config;
if (spectrum && spectrum.ACT_BIT_VALUES && spectrum.ACT_BIT_VALUES.length)
{
US_band_config = spectrum.BIT_US_BANDCONFIG;
bitsValues = spectrum.ACT_BIT_VALUES;
pilot = spectrum.PILOT;
g_bitsMax = bitsValues.length;
}
if(pilot < 0) pilot = 96;
var is_US = false;
var actual_band = 0;
for (i=0; i<g_bitsMax; i++)
{
is_US = false;
if (US_band_config) {
for (actual_band=0; actual_band< US_band_config.length; actual_band++)
{
if ((i>= US_band_config[actual_band].FIRST) && (i<= US_band_config[actual_band].LAST))
{
is_US = true;
break;
}
}
}
var spanClass = "blue";
var spanStyle = "0px";
if (!bitsValues)
{
spanClass = "blue";
spanStyle = "0px";
}
else if (is_US)
{
height = 6*bitsValues[i];
if (height > 90) height = 90;
spanClass = "green";
spanStyle = height +"px";
}
else {
if (i==pilot) {
spanClass = "pilot";
spanStyle = "89px";
}
else {
height = 6*bitsValues[i];
if (height > 90) height = 90;
spanClass = "blue";
spanStyle = height +"px";
}
}
var td = document.createElement("td");
jxl.addClass(td, "bitCells");
var span = document.createElement("span");
jxl.addClass(span, spanClass);
jxl.setStyle(span, "height", spanStyle);
td.appendChild(span);
spectrumBits.appendChild(td);
}
var endTd = document.createElement("td");
endTd.width = 18;
spectrumBits.appendChild(endTd);
}
function get_graph_carrier(scaleMax)
{
var img = document.createElement("img");
if (scaleMax > 512)
img.src = "/css/default/images/bitsnr_carriers_vdsl.gif";
else if (scaleMax > 256)
img.src = "/css/default/images/bitsnr_carriers_adsl2p.gif";
else
img.src = "/css/default/images/bitsnr_carriers.gif";
return img;
}
function get_graph_bitsfreq(scaleMax)
{
var img = document.createElement("img");
if (scaleMax > 17664000)
img.src = "/css/default/images/bitsnr_frequencies_vdsl_30a.gif";
else if (scaleMax > 2208000)
img.src = "/css/default/images/bitsnr_frequencies_vdsl.gif";
else if (scaleMax > 1104000)
img.src = "/css/default/images/bitsnr_frequencies_adsl2p.gif";
else
img.src = "/css/default/images/bitsnr_frequencies.gif";
return img;
}
var g_useCanvas = false;
function getGraphicsContext(name_of_canvas)
{
if (name_of_canvas=="")
{
name_of_canvas="graph"
}
var c = document.getElementById( name_of_canvas );
if ( !c || !g_useCanvas)
return null;
var ctx = c.getContext( "2d" );
return ctx;
}
function drawText( ctx, posX, posY, text, color, size )
{
ctx.font = size + "px Arial";
ctx.fillStyle = color;
ctx.fillText( text, posX, posY );
}
function drawBackgroundSNR( ctx, posX, posY, width, height, bkgcolor, linecolor )
{
ctx.fillStyle = bkgcolor;
ctx.fillRect( posX, posY, posX + width, posX + height );
ctx.beginPath();
ctx.strokeStyle = linecolor;
var offset = 7.5;
for ( i = 0; i < 6; i ++ )
{
ctx.moveTo( posX, posY + offset + i * 14 );
ctx.lineTo( posX + width, posY + offset + i * 14 );
ctx.stroke();
}
}
function drawBackgroundBits( ctx, posX, posY, width, height, bkgcolor, linecolor )
{
ctx.fillStyle = bkgcolor;
ctx.fillRect( posX, posY, posX + width, posX + height );
ctx.beginPath();
ctx.strokeStyle = linecolor;
var offset = 7.5;
for ( i = 0; i < 7; i ++ )
{
ctx.moveTo( posX, posY + offset + i * 12 );
ctx.lineTo( posX + width, posY + offset + i * 12 );
ctx.stroke();
}
}
function drawRange( ctx, posX, posY, scaleX, scaleY, values, rangeBegin, rangeEnd, color, stroke )
{
ctx.beginPath();
ctx.moveTo( posX + scaleX * rangeBegin, posY );
if ( stroke )
ctx.strokeStyle = color;
else
ctx.fillStyle = color;
for ( i = rangeBegin; i < rangeEnd; i++ )
{
ctx.lineTo( posX + scaleX * i, posY - values[ i ] * scaleY );
}
if ( stroke )
{
ctx.stroke();
}
else
{
ctx.lineTo( posX + scaleX * rangeEnd, posY );
ctx.fill();
}
}
function drawSpectrum( ctx, x, y, scaleX, scaleY, bandConfig, bitsValues, bitsMinValues, bitsMaxValues, minColor, maxColor, usColor, dsColor )
{
if (!bandConfig)
return;
ctx.lineWidth = 1;
ctx.strokeStyle = "rgb(0,0,0);";
drawRange( ctx, x, y, scaleX, scaleY, bitsMaxValues, 0, bandConfig[ 0 ].FIRST, maxColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsValues, 0, bandConfig[ 0 ].FIRST, dsColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsMinValues, 0, bandConfig[ 0 ].FIRST, minColor, true );
for ( b = 0; b < bandConfig.length; b++ )
{
drawRange( ctx, x, y, scaleX, scaleY, bitsMaxValues, bandConfig[ b ].FIRST, bandConfig[ b ].LAST, maxColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsValues, bandConfig[ b ].FIRST, bandConfig[ b ].LAST, usColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsMinValues, bandConfig[ b ].FIRST, bandConfig[ b ].LAST +1, minColor, true );
}
for ( b = 0; b < bandConfig.length - 1; b++ )
{
drawRange( ctx, x, y, scaleX, scaleY, bitsMaxValues, bandConfig[ b ].LAST, bandConfig[ b + 1 ].FIRST, maxColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsValues, bandConfig[ b ].LAST, bandConfig[ b + 1 ].FIRST, dsColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsMinValues, bandConfig[ b ].LAST, bandConfig[ b + 1 ].FIRST, minColor, true );
}
drawRange( ctx, x, y, scaleX, scaleY, bitsMaxValues, bandConfig[ bandConfig.length - 1 ].LAST, bitsMaxValues.length, maxColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsValues, bandConfig[ bandConfig.length - 1 ].LAST, bitsValues.length, dsColor, false );
drawRange( ctx, x, y, scaleX, scaleY, bitsMinValues, bandConfig[ bandConfig.length - 1 ].LAST, bitsMinValues.length, minColor, true );
}
function drawSNR( ctx, x, y, scaleX, scaleY, snrValues, snrMinValues, snrMaxValues, minColor, maxColor, fillColor )
{
ctx.lineWidth = 1;
ctx.strokeStyle = "rgb(0,0,0);";
drawRange( ctx, x, y, scaleX, scaleY, snrMaxValues, 0, snrMaxValues.length, maxColor, false );
drawRange( ctx, x, y, scaleX, scaleY, snrValues, 0, snrValues.length, fillColor, false );
drawRange( ctx, x, y, scaleX, scaleY, snrMinValues, 0, snrMinValues.length, minColor, true );
}
function drawPilot( ctx, x, y, bin, height, color )
{
ctx.beginPath();
ctx.moveTo( x + bin, y );
ctx.strokeStyle = color;
ctx.lineTo( x + bin, y - height );
ctx.stroke();
}
function renderSNR(name_of_canvas, spectrum)
{
var scaleY = 5.9;
var posx = 0, posy = 0;
var ctx = getGraphicsContext(name_of_canvas);
drawBackgroundSNR(ctx, posx + 1, posy, 700, 90, "rgb(100,122,143)", "rgb(116,135,153)" );
if (!spectrum || !spectrum.ACT_SNR_VALUES)
{
return;
}
var scaleX = 1;
var snrValues = spectrum.ACT_SNR_VALUES;
var snrMinValues = [];
var snrMaxValues = [];
if (g_show_MinMax)
{
snrMinValues = spectrum.MIN_SNR_VALUES;
snrMaxValues = spectrum.MAX_SNR_VALUES;
}
if (snrValues.length < 512)
scaleX = 512 / snrValues.length
var snroffset = 91;
var snrfillcolor = ctx.createLinearGradient( posx, snroffset + posy - 15 * scaleY, posx, snroffset + posy );
snrfillcolor.addColorStop(0, "rgb(255,243,24)");
snrfillcolor.addColorStop(1, "rgb(245,220,20)");
drawSNR( ctx, posx, posy + snroffset, scaleX, 0.7, snrValues, snrMinValues, snrMaxValues, g_mincolor, g_maxcolor, snrfillcolor );
}
function renderBits(name_of_canvas, spectrum)
{
var scaleY = 5.9;
var posx = 0, posy = 0;
var ctx = getGraphicsContext(name_of_canvas);
drawBackgroundBits(ctx, posx + 1, posy, 700, 90, "rgb(100,122,143)", "rgb(116,135,153)" );
if (!spectrum || !spectrum.ACT_BIT_VALUES)
{
return;
}
var scaleX = 1;
var bitsValues = spectrum.ACT_BIT_VALUES;
var bitsMinValues = [];
var bitsMaxValues = [];
if (g_show_MinMax)
{
bitsMinValues = spectrum.MIN_BIT_VALUES;
bitsMaxValues = spectrum.MAX_BIT_VALUES;
}
if (bitsValues.length < 512)
scaleX = 512 / bitsValues.length
var bandconfig = spectrum.BIT_US_BANDCONFIG;
var pilot = spectrum.PILOT;
var rfi = spectrum.DETECTED_RFI_VALUES;
var spectrumoffset = 91;
var uscolor = ctx.createLinearGradient( posx, spectrumoffset + posy - 15 * scaleY, posx, spectrumoffset + posy );
uscolor.addColorStop(0, "rgb(39,201,35)");
uscolor.addColorStop(1, "rgb(35,182,32)");
var dscolor = ctx.createLinearGradient( posx, spectrumoffset + posy - 15 * scaleY, posx, spectrumoffset + posy );
dscolor.addColorStop(0, "rgb(35,81,202)");
dscolor.addColorStop(1, "rgb(17,68,152)");
drawSpectrum( ctx, posx, posy + spectrumoffset, scaleX, scaleY, bandconfig, bitsValues, bitsMinValues, bitsMaxValues, g_mincolor, g_maxcolor, uscolor, dscolor );
drawPilot( ctx, posx, posy + spectrumoffset, pilot*scaleX, 88, "rgba(255,0,0,1)" );
for ( i = 0; i < rfi.length; i++ )
if ( rfi[i] > 0 )
drawPilot( ctx, posx, posy+spectrumoffset, rfi[i]*scaleX, 15*scaleY, "rgba(255,255,255,1)" );
}
function renderGraph(name_of_canvas)
{
}
function clearContent(container) {
var newContainer = container.cloneNode(false);
if (container.parentNode) {
container.parentNode.replaceChild(newContainer, container);
}
return newContainer;
}
function renderSnrScales(port)
{
var spectrumSnr = clearContent(jxl.get("dslSpectrumSnr"+port));
var scaleTd = document.createElement("td");
var scaleImg = document.createElement("img");
scaleImg.src = "/css/default/images/bitsnr_snrscale.gif";
scaleTd.appendChild(scaleImg);
spectrumSnr.appendChild(scaleTd);
var graphCarrier = clearContent(jxl.get("graphSnrCarrier"+port));
var scaleMax = 256;
if (g_spectrum.port[0] && g_spectrum.port[0].ACT_SNR_VALUES) {
scaleMax = g_spectrum.port[0].ACT_SNR_VALUES.length * g_spectrum.port[0].TONES_PER_SNR_VALUE;
}
graphCarrier.appendChild(get_graph_carrier(scaleMax));
}
function renderBitsScales(port)
{
var spectrumBits = clearContent(jxl.get("dslSpectrumBits"+port));
var scaleTd = document.createElement("td");
var scaleImg = document.createElement("img");
scaleImg.src = "/css/default/images/bitsnr_bitscale.gif";
scaleTd.appendChild(scaleImg);
spectrumBits.appendChild(scaleTd);
var graphCarrier = clearContent(jxl.get("graphBitCarrier"+port));
var scaleMax = 256;
var maxBatFreq = 1104;
if (g_spectrum.port[0] && g_spectrum.port[0].TONES_PER_BAT_VALUE) {
scaleMax = g_spectrum.port[0].ACT_BIT_VALUES.length * g_spectrum.port[0].TONES_PER_BAT_VALUE;
maxBatFreq = g_spectrum.port[0].MAX_BAT_FREQ;
}
graphCarrier.appendChild(get_graph_carrier(scaleMax));
var bitsFreq = clearContent(jxl.get("bitsFreq"+port));
bitsFreq.appendChild(get_graph_bitsfreq(maxBatFreq));
}
function updateGraph()
{
for (var k=0; k < g_spectrum.ports; k++) {
var port = String(k + 1);
renderSnrScales(port);
renderBitsScales(port);
var spectrum = g_spectrum.port[k];
var signalId = "graph_signal"+ port;
var bitsId = "graph_bits"+port;
if (getGraphicsContext(signalId) && getGraphicsContext(bitsId))
{
renderSNR(signalId, spectrum);
renderBits(bitsId, spectrum);
}
else
{
renderGraphSnr("dslSpectrumSnr" + port, spectrum);
renderGraphBits("dslSpectrumBits" + port, spectrum);
}
}
}
function OnMinMax()
{
g_show_MinMax=!g_show_MinMax;
if (g_show_MinMax)
jxl.setHtml("uiToggleMinMax","{?7888:518?}");
else
jxl.setHtml("uiToggleMinMax","{?7888:491?}");
startAjax(0);
}
var gXhr = {}
function startAjax(starttime) {
var my_url = "/internet/dsl_spectrum.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1";
sendUpdateRequest();
function sendUpdateRequest() {
stopXhr(gXhr)
gXhr = ajaxGet(my_url, cbUpdateValues);
}
var jsonParse = makeJSONParser();
function cbUpdateValues(xhr) {
var txt = xhr.responseText || "null";
if (xhr.status != 200) {
txt = "null";
}
var newData = jsonParse(txt);
if (newData) {
g_spectrum = newData;
updateGraph();
}
window.setTimeout(sendUpdateRequest, starttime?starttime:2000);
}
}
function init() {
updateGraph();
startAjax();
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<!--[if !IE] -->
<script type="text/javascript">g_useCanvas = true;</script>
<?lua write_signal_canvas() ?>
<?lua write_bits_canvas() ?>
<!--[endif]-->
<table style="" id="Table1">
<!-- Rauschen xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-->
<tr height="14">
<td width="555" colspan="<?lua write_colspan1() ?>">
<span class='BitsLegendeText'>{?7888:347?}</span>
</td>
</tr>
<tr class="dslSpectrumSNR" id="dslSpectrumSnr1">
</tr>
<tr>
<td width="25"><img src="/css/default/images/bitsnr_angle.gif"></td>
<td colspan="<?lua write_colspan2() ?>" id="graphSnrCarrier1">
</td>
</tr>
<tr height="14">
<td colspan="<?lua write_colspan1() ?>" style="text-align: center;">
<span class='BitsLegendeText'>{?7888:222?}</span>
</td>
</tr>
<!-- Bits xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-->
<tr height="14">
<td width="555" colspan="<?lua write_colspan1() ?>" align="left">
<span class='BitsLegendeText'>{?7888:588?}</span>
</td>
</tr>
<tr class="dslSpectrumBITS" id="dslSpectrumBits1">
</tr>
<tr height="16">
<td width="25"><img src="/css/default/images/bitsnr_angle.gif"></td>
<td colspan="<?lua write_colspan2() ?>" id="graphBitCarrier1">
</td>
</tr>
<tr height="12">
<td colspan="<?lua write_colspan1() ?>" id="bitsFreq1">
</td>
</tr>
<tr height="14">
<td colspan="<?lua write_colspan1() ?>" style="text-align: center;">
<span class='BitsLegendeText'>{?7888:704?}</span></td>
</tr>
<!-- Legende xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-->
<tr>
<td colspan="<?lua write_colspan1() ?>" class="Legend">
<table >
<tr style="">
<td class="ColorLegendeItem"><div class="green"></div></td>
<td style="width:120px;">{?7888:707?}</td>
<td style="width:90px;">{?7888:605?}</td>
<td class="ColorLegendeItem"><div class="white" ></div></td>
<td style="">{?7888:42?}</td>
</tr>
<tr style="">
<td class="ColorLegendeItem"><div class="blue"></div></td>
<td style="">{?7888:940?}</td>
<td style="">{?7888:570?}</td>
<td class="ColorLegendeItem"><div class="orange"></div></td>
<td style="">{?7888:699?}</td>
</tr>
<tr style="">
<td class="ColorLegendeItem"><div class="red"></div></td>
<td style="">{?7888:795?}</td>
<td style=""></td>
<td class="ColorLegendeItem"><div class="darkorange"></div></td>
<td style="">{?7888:235?}</td>
</tr>
</table>
</td>
</tr>
<tr class="btncolumn">
<td colspan="<?lua write_colspan1() ?>" class="btncolumn">
<a href="javascript:OnMinMax()" class="textlink nocancel" id="uiToggleMinMax">{?7888:38?}</a>
</td>
</tr>
</table>
</div>
<div id="btn_form_foot">
<button type="submit" name="cancel">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
