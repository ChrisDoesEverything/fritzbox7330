<?lua
g_page_type = "all"
g_page_title = "{?346:623?}"
g_page_help = "hilfe_fon_quality.html"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("fon_numbers")
require("general")
require("js")
g_val = {
prog = [[
]]
}
g_errormsg = nil
g_data={}
function read_values()
box.query("voipstat:status/load")
g_data.actual_list = general.listquery("voipstat:status/localnames/list(localname)")or {}
for i, k in ipairs(g_data.actual_list) do
k.state=general.listquery("voipstat:status/" ..k._node.. "/calls/entry/list(started,duration,remotename,remoteaddr,tx_codecs,rx_codecs,tx_packets_voice,tx_octets_voice,rx_packets_voice,rx_octets_voice,tx_percent_lost,rx_percent_lost,roundtriptime,tx_jitter,rx_jitter,tx_percent_vad_cng,rx_percent_vad_cng,is_fax,is_secure,tx_burst_duration,tx_burst_density,rx_burst_duration,rx_burst_density,call_setup_time,tx_percent_silence,rx_percent_silence,rating_total)")
end
box.query("voipstat:status/unload")
box.query("voipjournal:status/load")
g_data.journal=general.listquery("voipjournal:status/localnames/list(localname)") or {}
for i, k in ipairs(g_data.journal) do
k.state=general.listquery("voipjournal:status/" ..k._node.. "/calls/entry/list(started,duration,remotename,remoteaddr,tx_codecs,rx_codecs,tx_packets_voice,tx_octets_voice,rx_packets_voice,rx_octets_voice,tx_percent_lost,rx_percent_lost,roundtriptime,tx_jitter,rx_jitter,tx_percent_vad_cng,rx_percent_vad_cng,is_fax,is_secure,tx_burst_duration,tx_burst_density,rx_burst_duration,rx_burst_density,call_setup_time,tx_percent_silence,rx_percent_silence,rating_total)")
end
box.query("voipjournal:status/unload")
end
read_values()
function nil_to_empty(str)
if str == nil then
return ""
else
return str
end
end
function get_out_call_infos(callnode, infonode)
local txt,txt1,txt2="","",""
if infonode.call_setup_time =="" or infonode.call_setup_time =="er" then
txt1= box.tohtml(infonode.duration)
else
txt1= box.tohtml(infonode.duration)..[[ (]]..box.tohtml(nil_to_empty(infonode.call_setup_time))..[[ ms)]]
end
txt2=box.tohtml(infonode.started)
txt=txt2..[[ ]]..txt1
local str = [[<tr><td title="]]..txt..[[">]]..txt2..[[<br>&nbsp;&nbsp;]]..txt1..[[</td>]]
txt1=box.tohtml(infonode.remotename)
txt2=box.tohtml(infonode.remoteaddr)
txt=txt1..[[<br>]]..txt2
str = str..[[<td title="]]..txt1..[[ ]]..txt2..[[">]]..txt..[[</td>]]
local txt1=box.tohtml(infonode.tx_codecs)
local txt2=box.tohtml(infonode.rx_codecs)
str = str..[[<td title="Tx: ]]..txt1..[[ Rx: ]]..txt2..[["><span class="LedSpan"><img src="/css/default/images/send.png"></span><span class="LedDesc">]]..txt1..[[</span><br><span class="LedSpan"><img src="/css/default/images/receive.png"></span><span class="LedDesc">]]..txt2..[[</span></td>]]
if infonode.tx_percent_silence ~= nil or string.find(tostring(infonode.tx_percent_silence),"(0") ~= nil then
txt1=box.tohtml(infonode.tx_packets_voice)..[[ (]]..box.tohtml(infonode.tx_percent_silence)..[[)]]
else
txt1=box.tohtml(infonode.tx_packets_voice)
end
if infonode.rx_percent_silence ~= nil or string.find(tostring(infonode.rx_percent_silence),"(0") ~= nil then
txt2=box.tohtml(infonode.rx_packets_voice)..[[ (]]..box.tohtml(infonode.rx_percent_silence)..[[)]]
else
txt2=box.tohtml(infonode.rx_packets_voice)
end
txt=txt1..[[<br>]]..txt2
str = str..[[<td title="Tx: ]]..txt1..[[ Rx: ]]..txt2..[[">]]..txt..[[</td>]]
txt1=box.tohtml(infonode.tx_percent_lost)
txt2=box.tohtml(infonode.rx_percent_lost)
txt=txt1..[[<br>]]..txt2
str = str..[[<td title="Tx: ]]..txt1..[[ Rx: ]]..txt2..[[">]]..txt..[[</td>]]
txt=box.tohtml(delay_display(infonode.roundtriptime))
str = str..[[<td title="]]..txt..[[">]]..txt..[[</td>]]
txt1=box.tohtml(infonode.tx_jitter)..[[ ms]]
txt2=box.tohtml(infonode.rx_jitter)..[[ ms]]
txt=txt1..[[<br>]]..txt2
str = str..[[<td title="Tx: ]]..txt1..[[ Rx: ]]..txt2..[[">]]..txt..[[</td>]]
if string.find(infonode.tx_burst_duration,"65535 ms",1,true)=="" then
txt1=box.tohtml(infonode.tx_burst_duration)..[[ ]]..box.tohtml(infonode.tx_burst_density)
else
txt1=[[-]]
end
txt2=box.tohtml(infonode.rx_burst_duration)..[[ ]]..box.tohtml(infonode.rx_burst_density)
txt=txt1..[[<br>]]..txt2
str = str..[[<td title="Tx: ]]..txt1..[[ Rx: ]]..txt2..[[">]]..txt..[[</td>]]
str = str..[[<td>]]..other_display(callnode, infonode)..[[</td></tr>]]
g_foundRul = true
return str
end
function find_reachability_by_number(number)
local str=""
local curNum = ""
local val=""
local siplist = general.listquery("sip:settings/sip/list(displayname,registrar,ID)")
for i=1, #siplist do
if string.find(tostring(siplist[i].displayname),"@") ~= nil then
curNum= string.sub(tostring(siplist[i].displayname),0,string.find(tostring(siplist[i].displayname),"@"))
else
curNum=siplist[i].displayname;
end
if curNum==number then
val= box.query([[sip:status/]]..siplist[i]._node..[[/registrar_reachability]]);
if val=="--" then
val="0";
end
str= [[&nbsp;({?346:550?}]]..val..[[%)]]
break;
end
end
return str;
end
function get_callumberinfos(callnr)
local str = [[<tr>]]
str = str..[[<td colspan=9 class="sip_quality_align">{?346:484?}<span class="hintMsg">&nbsp;]]..callnr..[[</span>]]
str = str..find_reachability_by_number(callnr)
str = str..[[</td>]]
return str;
end
function other_display (callnode, infonode)
local str = infonode.tx_percent_vad_cng
if infonode.is_fax == "1" then
str = str..[[{?346:825?}]]
end
if infonode.is_fax == "2" then
str = str.. [[{?346:991?}]]
end
if infonode.rx_percent_vad_cng ~= "" then
str = str..infonode.rx_percent_vad_cng
end
if infonode.is_secure == "1" then
str = str..[[{?346:60?}]]
end
if callnode.localname ~= nil then
local id = [[Send]]..callnode.localname..[[_]]..infonode.started..[[_]]..infonode.remotename..[[_]]..infonode.duration
local button_callback = [[(SendUserDetails('nil_to_empty(dx)','nil_to_empty(Num)',']]..infonode.started..[[')]]
local value_send = [[{?346:693?}]]
local value_issend = [[{?346:59?}]]
if infonode.rating_total == "0" then
str = str..general.get_icon_button([[/css/default/images/feedback.gif]], "uiButton"..infonode.started, "button"..infonode.started , value_issend, value_issend, [[doShowSpeechfeedback(']]..callnode.localname..[[',']]..infonode.started..[[',']]..infonode.remotename..[[',']]..infonode.duration..[[')]], false)
else
str = str..general.get_icon_button([[/css/default/images/feedback_done.png]], "uiButton"..infonode.started, "button"..infonode.started, value_send, value_send, "", true)
end
end
return str;
end
function delay_display(n)
if n==0 then
return [[ ]]
end
return tostring(tonumber(n)/2)..[[ ms]]
end
local ctlmgr_save={}
if box.post.btn_clear then
require("cmtable")
cmtable.add_var(ctlmgr_save, "voipjournal:settings/clear","1")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
else
read_values()
end
elseif box.post.btn_apply then
require("cmtable")
if box.post.voipmonitor then
cmtable.add_var(ctlmgr_save, "emailnotify:settings/show_voipstat", "1")
else
cmtable.add_var(ctlmgr_save, "emailnotify:settings/show_voipstat", "0")
end
if val.validate(g_val) == val.ret.ok then
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
end
end
end
function write_colgroup()
box.out([[
<colgroup>
<col width="115px">
<col width="85px">
<col width="85px">
<col width="75px">
<col width="60px">
<col width="125px">
<col width="50px">
<col width="85px">
<col width="auto">
</colgroup>
]])
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<style type="text/css">
.sip_quality_align{
text-align:center
}
.sip_quality_allalign{
vertical-align: bottom;
text-align:center
}
.LedDesc {
padding-left:3px;
}
.LedSpan{
display: inline-block;
vertical-align: middle;
}
tr, td, th {
font-size:12px;
overflow: hidden;
text-overflow: ellipsis;
white-space: nowrap;
}
<?lua
if (#g_data.actual_list<3) then
box.out([[
table.zebra_reverse.active_calls td.scroll_container, table.zebra.active_calls td.scroll_container {
height: auto;
padding: 0;
}
]])
end
if (#g_data.journal<3) then
box.out([[
table.zebra_reverse.old_calls td.scroll_container, table.zebra.old_calls td.scroll_container {
height: auto;
padding: 0;
}
]])
end
?>
</style>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua box.html(box.glob.script) ?>">
<div>
{?346:591?}
<hr>
</div>
<div>
<table class="zebra cut_table">
<tr>
<td class="sip_quality_allalign"><span class="LedSpan"><img src="/css/default/images/send.png"></span><span class="LedDesc">{?346:839?}</span></td>
<td class="sip_quality_allalign"><span class="LedSpan"><img src="/css/default/images/receive.png"></span><span class="LedDesc">{?346:8?}</span></td>
</tr>
</table>
<p>
{?346:135?}
</p>
<table class="zebra active_calls cut_table">
<?lua
write_colgroup()
?>
<tr>
<th>{?346:129?}<br>{?346:0?}</th>
<th>{?txtRufnummer?}<br>{?346:373?}</th>
<th>&nbsp;<br>{?346:89?}</th>
<th>&nbsp;<br>{?346:337?}</th>
<th>&nbsp;<br>{?346:773?}</th>
<th>{?346:474?}<br>{?346:624?}</th>
<th>&nbsp;<br>{?346:346?}</th>
<th>&nbsp;<br>{?346:253?}</th>
<th>&nbsp;<br>{?346:226?}</th>
</tr>
<tr >
<td class="scroll_container" colspan="9">
<div class="scroll">
<table id="uiListOfActivCalls" class="zebra_reverse noborder cut_table">
<?lua
write_colgroup()
if #g_data.actual_list == 0 then
box.out([[<tr><td colspan=9 class="sip_quality_align">{?346:281?}</td></tr>]])
else
for i, k in ipairs(g_data.actual_list) do
box.out(get_callumberinfos(k.localname))
for j, l in ipairs(k.state) do
box.out(get_out_call_infos(k,l))
end
end
end
?>
</table>
</div>
</td>
</tr>
</table>
<div class="formular">
<input type="checkbox" id="uiVoipMonitor" name="voipmonitor" <?lua if box.query("emailnotify:settings/show_voipstat") == "1" then box.out([[checked="checked"]]) end ?>>
<label for="uiVoipMonitor">{?346:264?}</label>
</div>
<table class="zebra old_calls cut_table" <?lua if box.query("emailnotify:settings/show_voipstat") == "0" then box.out([[style="display:none"]]) end ?>>
<?lua
write_colgroup()
?>
<tr>
<th>{?346:405?}<br>{?346:230?}</th>
<th>{?txtRufnummer?}<br>{?346:918?}</th>
<th>&nbsp;<br>{?346:23?}</th>
<th>&nbsp;<br>{?346:132?}</th>
<th>&nbsp;<br>{?346:265?}</th>
<th>{?346:646?}<br>{?346:682?}</th>
<th>&nbsp;<br>{?346:749?}</th>
<th>&nbsp;<br>{?346:472?}</th>
<th>&nbsp;<br>{?346:26?}</th>
</tr>
<tr >
<td class="scroll_container" colspan="9">
<div class="scroll">
<table id="uiListOfAllCalls" class="zebra_reverse noborder cut_table">
<?lua
write_colgroup()
if #g_data.journal == 0 then
box.out([[<tr><td colspan=9 class="sip_quality_align">{?346:931?}</td></tr>]])
else
for i, k in ipairs(g_data.journal) do
box.out(get_callumberinfos(k.localname))
for j, l in ipairs(k.state) do
box.out(get_out_call_infos(k,l))
end
end
end
?>
</table>
</div>
</td>
</tr>
</table>
<p>
{?346:161?}
</p>
<p>
{?346:165?}
</p>
</div>
<?lua
if g_errormsg ~= nil then
box.out([[<div>]]..g_errormsg..[[</div>]])
end
?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid)?>">
<div id="btn_form_foot">
<?lua
if box.query("emailnotify:settings/show_voipstat") == "1" then
box.out([[<button type="submit" name="btn_clear" onclick="return showDeleteConfirm()" id="uiBtnClear">{?346:85?}</button>]])
end
?>
<button type="submit" name="btn_apply" id="uiBtnApply">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="uiBtnCancel">{?txtCancel?}</button>
<button type="submit" name="btn_refresh" id="uiBtnRefresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/ip.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function showDeleteConfirm()
{
return confirm("{?346:104?}");
}
function doShowSpeechfeedback(localname, started, remotename, duration) {
window.location.href = "/fon_num/sip_feedback.lua?localname=" + encodeURIComponent(localname) + "&started=" + started + "&remotename=" + remotename+ "&duration="+ duration +"&sid=<?lua box.out(box.glob.sid) ?>";
return false;
}
</script>
<?include "templates/html_end.html" ?>
