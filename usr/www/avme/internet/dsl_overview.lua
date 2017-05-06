<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_dslinfo_uebersicht.html'
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("general")
require("libluadsl")
if (next(box.post) and (box.post.cancel)) then
http.redirect([[/internet/dsl_overview.lua]])
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_data={}
function convert_enum_to_sync(sync)
if sync=="stable" then
return "0"
elseif sync=="some_disturb" then
return "1"
elseif sync=="often_disturb" then
return "2"
elseif sync=="no_sync" then
return "3"
end
return ""
end
function convert_sync_to_enum(sync)
if sync=="0" then
return "stable"
elseif sync=="1" then
return "some_disturb"
elseif sync=="2" then
return "often_disturb"
elseif sync=="3" then
return "no_sync"
end
return ""
end
function get_var()
g_data.port ={}
g_data.port[1] ={}
g_data.port[2] ={}
g_data.equipment ={}
g_data.equipment[1]={}
g_data.equipment[2]={}
local train_state={
["0"]="NO",
["1"]="MULTI",
["2"]="T1413",
["3"]="GDMT",
["4"]="GLITE",
["5"]="ADSL2",
["6"]="ADSL2PLUS",
["7"]="VDSL2"
}
local carrier_state={
["0"]="IDLE",
["1"]="INIT",
["2"]="NO_CABLE",
["3"]="YES_CABLE",
["4"]="HS",
["5"]="RTDL",
["6"]="SHOWTIME",
["7"]="NONE"
}
g_data.port[1] = luadsl.getOverviewStatus(1,"DS")
if (g_data.port[1].PORTS>1) then
for i = 1, g_data.port[1].PORTS, 1 do
g_data.port[i] = {}
g_data.port[i] = luadsl.getOverviewStatus(i,"DS")
negotiated_values = luadsl.getNegotiatedValues(i,"DS")
g_data.port[i].L2_ENABLE = negotiated_values.L2_ENABLE
g_data.port[i].L2_SUPPORT = negotiated_values.L2_SUPPORT
end
end
g_data.equipment = luadsl.getEquipmentInfo(1,"DS")
g_data.equipment.DP_VERSION=string.gsub(g_data.equipment.DP_VERSION,"_"," ")
end
get_var()
function refill_user_input()
end
g_val = {
prog = [[
]]
}
function write_all_data()
require("js")
local cur_obj=get_all_data()
box.out(js.table(cur_obj))
end
function get_rate_str(val)
val = tostring(val)
local new_val = ""
local sep = 3
local dot_count = math.floor(#val / sep)
local begin = 0
for i = dot_count, 1, -1 do
begin = #val - sep * i + 1
local endd = begin + 2
new_val= new_val..".".. string.sub(val, begin, endd )
end
if #val % sep ~= 0 then
new_val= string.sub(val, 0, #val - sep * dot_count)..new_val
else
new_val = string.sub(new_val, 2, #new_val)
end
local str=new_val..[[ {?9855:620?}]]
return str
end
function get_ds_rate()
return get_rate_str(g_data.port[1].ACT_DATA_RATE_DS)
end
function get_us_rate()
return get_rate_str(g_data.port[1].ACT_DATA_RATE_US)
end
function write_ds_rate()
box.html(get_ds_rate())
end
function write_us_rate()
box.html(get_us_rate())
end
function get_dslam_info()
local str=g_data.equipment.ATUC_ID
str=str..[[<br>]]
str=str..g_data.equipment.ATUC_VERSION..[[<br>]]
if (g_data.equipment.DSLAM_ID~="00" or g_data.equipment.DSLAM_SERIAL~="00" or g_data.equipment.DSLAM_VERSION~="00") then
str=str..g_data.equipment.DSLAM_ID ..[[<br>]]
str=str..g_data.equipment.DSLAM_VERSION..[[<br>]]
str=str..g_data.equipment.DSLAM_SERIAL
end
return str
end
function write_dslam_info()
box.out(get_dslam_info())
end
function get_vector_info(dslport)
if g_data.port[dslport] and g_data.port[dslport].G_VECTOR_MODE then
if g_data.port[dslport].G_VECTOR_MODE == 1 then
return [[ - G.Vector ({?9855:104?})]]
elseif g_data.port[dslport].G_VECTOR_MODE == 2 then
return [[ - G.Vector ({?9855:505?})]]
end
end
return ""
end
function get_line_info(dslport)
require("general")
local mode =""
local carrier =""
local port=[[]]
if g_data.port[dslport].BONDING and g_data.port[dslport].PORTS>1 then
port=tostring(dslport)..[[. ]]
end
mode =g_data.port[dslport].MODE
carrier =g_data.port[dslport].STATE
local obj={}
obj.train_state=general.sprintf([[{?9855:88?}]],port)
if (dslport==1) then
obj.pic=[[/css/default/images/gelb_leitung.gif]]
else
obj.pic=[[/css/default/images/gelb_scnd_port.gif]]
end
obj.mode = mode..get_vector_info(dslport)
obj.time = "0";
if (carrier=="NO_CABLE") then
obj.train_state=general.sprintf([[{?9855:508?}]], port)
if (dslport==1) then
obj.pic=[[/css/default/images/rot_leitung.gif]]
else
obj.pic=[[/css/default/images/rot_scnd_port.gif]]
end
obj.mode=""
local time_in_state = g_data.port[dslport].TIME_IN_STATE
if tonumber(time_in_state) and time_in_state ~= "0" then
obj.train_state2 = [[{?9855:799?}]]
obj.time = general.convert_to_str_with_day(time_in_state)
end
elseif (carrier=="YES_CABLE" or carrier=="INIT" or carrier=="IDLE" or carrier=="HS") then
obj.train_state=general.sprintf([[{?9855:258?}]],port)
if (dslport==1) then
obj.pic=[[/css/default/images/rot_leitung.gif]]
else
obj.pic=[[/css/default/images/rot_scnd_port.gif]]
end
obj.mode=""
if carrier ~= "HS" then
local time_in_state = g_data.port[dslport].TIME_IN_STATE
if tonumber(time_in_state) and time_in_state ~= "0" then
obj.train_state2 = [[{?9855:493?}]]
obj.time = general.convert_to_str_with_day(time_in_state)
end
end
elseif (carrier=="SHOWTIME") then
obj.train_state=general.sprintf([[{?9855:558?}]],port)
if (dslport==1) then
obj.pic=[[/css/default/images/gruen_leitung.gif]]
else
obj.pic=[[/css/default/images/gruen_scnd_port.gif]]
end
obj.time=g_data.port[dslport].SHOWTIME
if (obj.time == "no-emu" or obj.time=="0") then
obj.time = "0";
else
obj.time = general.convert_to_str_with_day(obj.time);
end
if ((mode=="ADSL2" or mode == "ADSL2PLUS") and g_data.port[dslport].L2_ENABLE and g_data.port[dslport].L2_SUPPORT) then
obj.train_state=general.sprintf([[{?9855:438?}]],port)
if (dslport==1) then
obj.pic=[[/css/default/images/hellblau_leitung.gif]]
else
obj.pic=[[/css/default/images/hellblau_scnd_port.gif]]
end
end
end
return obj
end
function get_all_data()
local obj={}
obj.ds_rate=get_ds_rate()
obj.us_rate=get_us_rate()
obj.dslam=get_dslam_info()
obj.line={}
obj.line[1]=get_line_info(1)
if g_data.port[1].PORTS>1 then
obj.line[2]=get_line_info(2)
end
return obj
end
function write_hint()
box.out([[<div class="Hint">]])
if (box.query("sar:settings/DslDiagnosticStart")=="1") then
box.out([[<p>[]]..box.tohtml([[{?9855:447?}]])..[[]</p>]])
end
local marge_receive = tonumber(box.query("sar:settings/DownstreamMarginOffset")) or 0
local marge_send = tonumber(box.query("sar:settings/UsNoiseBits")) or 0
local rfi = tonumber(box.query("sar:settings/RFI_mode")) or 0
local inp = tonumber(box.query("sar:settings/DsINP")) or 0
if marge_receive~=0 or marge_send~=0 or rfi~=0 or inp~=0 then
box.out([[<p>[]]..box.tohtml([[{?9855:570?}]])..[[]</p>]])
end
box.out([[</div>]])
end
function write_umts_block()
if config.UMTS and box.query("umts:settings/enabled")=="1" and box.query("umts:settings/backup_enable")~="1" then
box.out([[<div><p>]]..box.tohtml([[{?9855:423?}]])..[[<br>]])
box.out(general.sprintf([[{?9855:43?}]],[[<a href="javascript:jslGoTo('internet','gsm');">]],[[</a>]]))
box.out([[</p></div>]])
end
end
g_ajax = false
g_action = ""
if box.get.useajax then
g_ajax = true
g_action = box.get.action
end
if box.post.useajax then
g_ajax = true
g_action = box.get.action
end
if g_ajax then
if (g_action=="get_data") then
write_all_data()
end
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#Table1 {
width:auto;
margin:auto;
background-color:transparent;
border: 0 none;
}
#Table1 .c1 {width: 100px;}
#Table1 .c2 {width: 100px;}
#Table1 .c3 {width: 220px;}
#Table1 .c4 {width: 140px;}
#Table1 .c5 {width: 100px;}
#Table1 th {
font-weight:bold;
height:23px;
}
#Table1 th span {
padding-left:60px;
}
#Table1 td.dsl_txt_info, td.dsl_txt_info_dslam {
vertical-align:middle;
}
.Graph {
position:relative;
height:85px;
}
.Graph img {
border:0 none;
outline: 0 none;
}
.Graph .Box {
}
.Graph .DslRate_us, .Graph .DslRate_ds{
position :absolute;
top :27px;
left :175px;
font-size :11px;
}
.Graph .DslRate_ds{
top :8px;
}
.Graph .dsl_line, .Graph .dsl_line_scnd_port {
position:absolute;
top:53px;
left:61px;
}
.Hint {
font-color:#FF8000;
}
</style>
<!--[if gt IE 8]>
<style type="text/css">
.Graph .dsl_line, .Graph .dsl_line_scnd_port {
top:55px;
}
.Graph .dsl_line_scnd_port {
top:63px;
}
</style>
<![endif]-->
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_Timer;
function stopTimer() {
if (g_Timer) {
window.clearTimeout(g_Timer);
g_Timer = null;
}
}
function update_gui(newData)
{
if (!newData) {
return;
}
jxl.setHtml("DslDslamInfo",newData.dslam);
var TrainState=newData.line[0].train_state;
if (newData.line[0].train_state2)
{
TrainState+="<br>"+newData.line[0].train_state2;
}
if (newData.line[0].time!="0")
{
TrainState+="<br>"+newData.line[0].time;
}
if (newData.line[0].mode)
{
TrainState+="<br>"+newData.line[0].mode;
}
jxl.setHtml("DslTrainState",TrainState);
jxl.setText("DsRate",newData.ds_rate);
jxl.setText("UsRate",newData.us_rate);
jxl.changeImage("dsl_line_pic",newData.line[0].pic,"/css/default/images/leer.gif")
}
function updateValues() {
var my_url = "/internet/dsl_overview.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&action=get_data";
stopTimer();
sendUpdateRequest();
function sendUpdateRequest() {
ajaxGet(my_url, cbUpdateValues);
}
var jsonParse = makeJSONParser();
function cbUpdateValues(xhr) {
var txt = xhr.responseText || "null";
if (xhr.status != 200) {
txt = "null";
}
var newData = jsonParse(txt);
update_gui(newData);
g_Timer = window.setTimeout(sendUpdateRequest, "2000");
}
}
function uiDoOnMainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
function init() {
updateValues();
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "send", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<table id="Table1">
<tr>
<th class="c1" >{?gTxtFritzBox?}</th>
<th class="c2" ></th>
<th class="c3" ><span>{?9855:934?}</span></th>
<th class="c4" ></th>
<th class="c5" >{?9855:158?}</th>
</tr>
<tr>
<td class="dsl_txt_info">{?9855:255?}<br><?lua box.html(g_data.equipment.DP_VERSION) ?></td>
<td colspan=3>
<div class="Graph">
<div class="Box"><img src="/css/default/images/illu_box.gif"></div>
<div id="DsRate" class="DslRate_ds">
<?lua write_ds_rate() ?>
</div>
<div id="UsRate" class="DslRate_us">
<?lua write_us_rate() ?>
</div>
<div class="dsl_line">
<img id='dsl_line_pic' src='/css/default/images/leer.gif' title='{?9855:647?}'>
</div>
</div>
</td>
<td id='DslDslamInfo' class="dsl_txt_info_dslam" >
<?lua
write_dslam_info()
?>
</td>
</tr>
<tr >
<td></td>
<td></td>
<td id='DslTrainState' class="dsl_line_state">
---
</td>
<td></td>
<td></td>
</tr>
</table>
<?lua
write_hint()
write_umts_block()
?>
</div>
<div id="btn_form_foot">
<button type="submit" name="cancel">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
