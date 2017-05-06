<?lua
--[[
Datei Name: capture.lua
Datei Beschreibung: Mitschnitte starten und stoppen
]]
g_page_type = "no_menu"
g_homelink_top = true
g_page_title = [[{?946:222?}]]
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require("general")
require("http")
if config.DOCSIS and config.gu_type == 'release' then
http.redirect("")
end
g_txt_intro = general.sprintf([[{?946:333?}]], [[<a href="http://www.wireshark.org/" target="_blank">]], [[</a>]])
local show_row_needed = config.DOCSIS and config.oem == 'kdg'
and not(config.gu_type == 'private' or config.gu_type == 'beta')
local function show_row(row)
if show_row_needed then
if row.type == "30" and row.minor == "3000" then
-- DOCSIS Management
return false
elseif row.type == "1" then
-- erouter0, esafe0
return row.name:find("erouter") ~= 1 and row.name:find("esafe") ~= 1
else
-- internet, voip, etc. (2, 3), und auch wlan (4)
return row.type ~= "2" and row.type ~= "3" and row.type ~= "4"
end
end
return true
end
function cb_ifs(idx, row)
row.startvalue = row.type .. "-" .. row.minor
row.stopvalue = row.type .. ";" .. row.minor ..";" .. row.name
if show_row(row) then
if row.type=="1" then
row.text = row.name
row.startvalue = row.type .. "-" .. row.name
table.insert(g_local, row)
elseif row.type=="2" then
row.text = row.if_nr .. [[. {?946:330?}]]
table.insert(g_dsl, row)
elseif row.type=="3" then
if row.minor=="0" then
row.text = [[{?946:214?}]]
else
row.text = [[{?946:622?} ]] .. row.if_nr .. [[ (']] .. row.name .. [[')]]
end
table.insert(g_dsl, row)
elseif row.type=="4" then
row.text = row.name .. [[ - {?946:865?} ]] .. row.if_nr
table.insert(g_wlan, row)
elseif row.type=="5" then
row.text = row.name
table.insert(g_usb, row)
else
row.text = "Minor = " .. row.minor .. " ['" .. row.name .. "']"
row.startvalue = row.minor
table.insert(g_unknown, row)
end
end
end
function cb_session(idx, row)
for _,iface in ipairs(g_table[tonumber(row.type)]) do
if (row.type=="1" and row.ifacename==iface.name) or (row.type~="1" and iface.minor == row.minor) then
iface.active = true
end
end
end
function fix_ie7(val)
local spanval = string.match(val, "<[Ss][Pp][Aa][Nn].+>(.+)</[Ss][Pp][Aa][Nn]>")
if spanval then
return spanval
end
return val
end
g_local = {}
g_dsl = {}
g_wlan = {}
g_usb = {}
g_unknown = {}
g_table = { g_local, g_dsl, g_wlan, g_usb, g_unknown }
g_len = 1600
if box.post.len and tonumber(box.post.len) then
g_len = box.post.len
end
g_dtrace_running = (box.query("capture:settings/dtrace_running") == "1")
g_dfile = { old = box.query("capture:settings/dtrace_old"), new = box.query("capture:settings/dtrace_new") }
g_lte_running = (tonumber(box.query("lted:settings/trace/status")) or 0) >= 3
function write_iframe_src_js()
local src = [[/cgi-bin/capture_notimeout]]
.. [[?sid=]] .. box.tojs(box.glob.sid)
.. [[&capture=Start]]
box.js(src)
end
function write_iframe_ltesrc_js()
box.js([[/cgi-bin/rpcstreamcap_notimeout?name=lted&action=start&wv=lted:settings/trace/status]])
end
general.listquery("capture:settings/iface/list(name,minor,type,if_nr)", cb_ifs)
general.listquery("capture:settings/session/list(displayname,ifacename,minor,type)", cb_session)
if next(box.post) then
if box.post.start then
box.post.start = fix_ie7(box.post.start)
http.redirect("/cgi-bin/capture_notimeout?ifaceorminor="..box.post.start.."&snaplen="..box.post.len.."&capture=Start")
end
if box.post.stop then
box.post.stop = fix_ie7(box.post.stop)
local t, m, n = string.match(box.post.stop, "(.*);(.*);(.*)")
http.redirect("/cgi-bin/capture_notimeout?iface="..n.."&minor="..m.."&type="..t.."&capture=Stop")
end
if box.post.stopall then
http.redirect("/cgi-bin/capture_notimeout?iface=stopall&capture=Stop")
end
-- DTrace
if box.post.dstart then
if box.post.dparams and string.len(box.post.dparams) > 0 then
http.redirect("/cgi-bin/capture_notimeout?dtracetype=3&dtraceparam="..http.url_encode(box.post.dparams).."&dtrace=Start")
else
http.redirect("/cgi-bin/capture_notimeout?dtracetype=1&dtrace=Start")
end
end
if box.post.dstop then
http.redirect("/cgi-bin/capture_notimeout?dtrace=Stop")
end
if box.post.dfile_old then
http.redirect("/cgi-bin/capture_notimeout?dtracefile="..g_dfile.old.."&dtrace=Save")
end
if box.post.dfile_new then
http.redirect("/cgi-bin/capture_notimeout?dtracefile="..g_dfile.new.."&dtrace=Save")
end
-- LTE
if box.post.lstart then
if box.post.ltesetlog then
local e, m = box.set_config({
{name="lted:settings/trace/setlog", value=box.post.ltesetlog or ""}
})
end
http.redirect(
"/cgi-bin/rpcstreamcap_notimeout?name=lted&action=start&wv=lted:settings/trace/status"
)
end
if box.post.lstop then
http.redirect(
"/cgi-bin/rpcstreamcap_notimeout?name=lted&action=stop&wv=lted:settings/trace/status"
)
end
if box.post.lreconnect then
local e, m = box.set_config({
{name="lted:settings/enabled", value="0"},
{name="lted:settings/enabled", value="1"}
})
end
end
function write_table(t)
box.out([[
<table class="zebra">
]])
for _,iface in ipairs(t) do
local suffix = iface.minor
if suffix=="-1" then suffix = iface.name end
box.out([[
<tr>
<th>]] .. box.tohtml(iface.text) .. [[</th>
<td class="buttonrow">
<button type="submit" name="start" id="uiStart_]] .. suffix .. [[" value="]] .. box.tohtml(iface.startvalue) .. [[">{?946:727?}</button>
</td>
<td class="imgcol" id="uiImage_]] .. suffix .. [[">]])
if iface.active then
box.out([[<img src="/css/default/images/wait.gif">]])
end
box.out([[
</td>
<td class="buttonrow"><button type="submit" name="stop" id="uiStop_]] .. suffix .. [[" value="]] .. box.tohtml(iface.stopvalue) .. [[">{?946:888?}</button></td>
</tr>
]])
end
box.out([[</table>]])
end
function write_save_btn(suffix)
if g_dfile[suffix] and string.len(g_dfile[suffix]) > 0 then
box.out([[
<td class="buttonrow"><button type="submit" name="dfile_]]..suffix..[[" id="uiFile_]]..suffix..[[">]]..box.tohtml(g_dfile[suffix])..[[</button></td>
]])
else
box.out([[
<td class="buttonrow"><button type="submit" name="dfile_]]..suffix..[[" id="uiFile_]]..suffix..[[" disabled>{?946:332?}</button></td>
]])
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/capture.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<!--[if lt IE 8]>
<script type="text/javascript">
<?lua
require"js"
local vals = {start={}, stop={}}
for _,t in ipairs(g_table) do
for _,iface in ipairs(t) do
local suffix = iface.minor
if suffix=="-1" then suffix = iface.name end
vals.start["_" .. suffix] = iface.startvalue
vals.stop["_" .. suffix] = iface.stopvalue
end
end
function write_vals(which)
box.out(js.object(vals[which]))
end
?>
var start_val = {<?lua write_vals('start') ?>};
var stop_val = {<?lua write_vals('stop') ?>};
function fixButtons() {
var btns = document.getElementsByTagName("button");
for (var i=0; i<btns.length; i++) {
if (btns[i].name) {
if (btns[i].name.indexOf("start") == 0) {
btns[i].innerHTML = '<span style="display:none;">'+start_val['_'+btns[i].id.substr(8)]+'</span> ' + btns[i].innerHTML;
} else if (btns[i].name.indexOf("stop") == 0) {
btns[i].innerHTML = '<span style="display:none;">'+stop_val['_'+btns[i].id.substr(7)]+'</span> ' + btns[i].innerHTML;
}
}
}
}
function getBtnValue(btn) {
var span = jxl.walkDom(btn, 'span');
if (span && span.length) {
return span[0].innerText;
}
else {
return btn.value;
}
}
ready.onReady(fixButtons);
</script>
<![endif]-->
<script type="text/javascript">
// -- im IE < 8 haben wir die Funktion oben definiert, für alle anderen hier
if (typeof getBtnValue != 'function') {
getBtnValue = function(b){return b.value;};
}
var gQueryVars = {
sessions: { query: "capture:settings/session/list(displayname,ifacename,minor,type)" },
dtrace: { query: "capture:settings/dtrace_running" },
dfileold: { query: "capture:settings/dtrace_old" },
dfilenew: { query: "capture:settings/dtrace_new" },
lte: { query: "lted:settings/trace/status" }
};
var g_active = {};
var g_dactive = false;
var g_lactive = false;
var g_seq = 0;
var g_ajaxSubmit = false;
function init() {
disableStopButtons();
jxl.addEventHandler("uiStopAll", "click", uiDoOnStopAllClicked);
jxl.addEventHandler("uiStart_dtrace", "click", uiDoOnStartDTraceClicked);
jxl.addEventHandler("uiStop_dtrace", "click", uiDoOnStopDTraceClicked);
addStartButtonHandlers();
var form = jxl.get("uiMainForm");
if (form) form.onsubmit = uiDoOnMainFormSubmit;
ajaxWait(gQueryVars, "<?lua box.js(box.glob.sid) ?>", 5000, cbState);
}
function uiDoOnMainFormSubmit() {
if (g_ajaxSubmit) {
g_ajaxSubmit = false;
return false;
}
return true;
}
function disableStopButtons() {
var b = document.getElementsByTagName("button");
for (var i=0; i < b.length; i++) {
if (b[i].name.indexOf("stop")!=-1) {
jxl.disable(b[i]);
}
if (b[i].name.indexOf("stop") == 0) {
jxl.addEventHandler(b[i], "click", uiDoOnStopClicked);
}
}
}
function uiDoOnStopClicked(evt) {
var btn = jxl.evtTarget(evt);
if (btn) {
var p = getBtnValue(btn).split(";");
ajaxGet("/cgi-bin/capture_notimeout?iface="+p[2]+"&minor="+p[1]+"&type="+p[0]+"&capture=Stop&sid=<?lua box.js(box.glob.sid) ?>", cbStop);
g_ajaxSubmit = true;
}
}
function uiDoOnStopAllClicked() {
ajaxGet("/cgi-bin/capture_notimeout?iface=stopall&capture=Stop&sid=<?lua box.js(box.glob.sid) ?>", cbStopAll);
g_ajaxSubmit = true;
}
function uiDoOnStartDTraceClicked() {
var pstr = jxl.getValue("uiDtraceParams");
if (pstr.length == 0) {
ajaxGet("/cgi-bin/capture_notimeout?dtracetype=1&dtrace=Start&sid=<?lua box.js(box.glob.sid) ?>", cbStartDTrace);
} else {
ajaxGet("/cgi-bin/capture_notimeout?dtracetype=3&dtraceparam="+encodeURIComponent(pstr)+"&dtrace=Start&sid=<?lua box.js(box.glob.sid) ?>", cbStartDTrace);
}
g_ajaxSubmit = true;
}
function uiDoOnStopDTraceClicked() {
ajaxGet("/cgi-bin/capture_notimeout?dtrace=Stop&sid=<?lua box.js(box.glob.sid) ?>", cbStopDTrace);
g_ajaxSubmit = true;
}
function uiDoOnStopLTEClicked() {
ajaxGet(
"/cgi-bin/rpcstreamcap_notimeout?name=lted&action=stop&wv=lted:settings/trace/status&sid=<?lua box.js(box.glob.sid) ?>",
cbStopLte
);
g_ajaxSubmit = true;
}
function uiOnReconnectLte(evt) {
jxl.disable("uiReconnect_lte");
ajaxGet(
"<?lua box.js(box.glob.script) ?>?sid=<?lua box.js(box.glob.sid) ?>&lreconnect=",
function(xhr) {
jxl.enable("uiReconnect_lte");
}
);
return jxl.cancelEvent(evt);
}
function cbStop() {
}
function cbStopAll() {
}
function cbStartDTrace() {
jxl.disable("uiStart_dtrace");
jxl.enable("uiStop_dtrace");
jxl.setHtml("uiImage_dtrace", '<img src="/css/default/images/wait.gif" alt="{?946:271?}">');
g_dactive = true;
}
function cbStopDTrace() {
jxl.enable("uiStart_dtrace");
jxl.disable("uiStop_dtrace");
if (g_dactive) {
jxl.setHtml("uiImage_dtrace", '<img src="/css/default/images/finished_ok_green.gif" alt="{?946:211?}">');
}
}
function cbStopLte() {
jxl.enable("uiStart_lte");
jxl.disable("uiStop_lte");
if (g_lactive) {
jxl.setHtml("uiImage_lte", '<img src="/css/default/images/finished_ok_green.gif" alt="{?946:486?}">');
}
}
function cbState() {
g_seq++;
for (var i=0; i < gQueryVars.sessions.value.length; i++) {
var suffix = gQueryVars.sessions.value[i].minor;
if (suffix=="-1") suffix = gQueryVars.sessions.value[i].ifacename;
jxl.disable("uiStart_"+suffix);
jxl.enable("uiStop_"+suffix);
jxl.setHtml("uiImage_"+suffix, '<img src="/css/default/images/wait.gif" alt="{?946:995?}">');
g_active[suffix] = g_seq;
}
for (var suffix in g_active) {
if (g_active[suffix] != g_seq) {
jxl.enable("uiStart_"+suffix);
jxl.disable("uiStop_"+suffix);
jxl.setHtml("uiImage_"+suffix, '<img src="/css/default/images/finished_ok_green.gif" alt="{?946:263?}">');
g_active[suffix] = null;
}
}
if (gQueryVars.sessions.value.length > 0) {
jxl.enable("uiStopAll");
} else {
jxl.disable("uiStopAll");
}
if (gQueryVars.dtrace.value == "1") {
jxl.disable("uiStart_dtrace");
jxl.enable("uiStop_dtrace");
jxl.setHtml("uiImage_dtrace", '<img src="/css/default/images/wait.gif" alt="{?946:802?}">');
g_dactive = true;
} else {
jxl.enable("uiStart_dtrace");
jxl.disable("uiStop_dtrace");
if (g_dactive) {
jxl.setHtml("uiImage_dtrace", '<img src="/css/default/images/finished_ok_green.gif" alt="{?946:287?}">');
}
}
if (gQueryVars.dfilenew.value != "") {
jxl.setHtml("uiFile_new", gQueryVars.dfilenew.value);
jxl.enable("uiFile_new");
}
if (gQueryVars.dfileold.value != "") {
jxl.setHtml("uiFile_old", gQueryVars.dfileold.value);
jxl.enable("uiFile_old");
}
/* poll forever*/
return false;
}
function addStartButtonHandlers() {
var src = "<?lua write_iframe_src_js() ?>";
var ltesrc = "<?lua write_iframe_ltesrc_js() ?>";
var iFrame = {};
function onStart(evt) {
var btn = jxl.evtTarget(evt);
if (btn && btn.id) {
//-- LTE: wenn geändert, musss setlog gesetzt werden, deshalb Seite neu laden
if (btn.name.indexOf("lstart") == 0) {
if (g_lteSetlog != jxl.getValue("uiLteSetlog")) {
g_ajaxSubmit = false;
return true;
}
}
if (!iFrame[btn.id]) {
iFrame[btn.id] = document.createElement('iframe');
iFrame[btn.id].style.display = "none";
document.body.appendChild(iFrame[btn.id]);
}
if (btn.name.indexOf("lstart") == 0) {
iFrame[btn.id].src = ltesrc;
}
else {
iFrame[btn.id].src = src + '&snaplen='+ jxl.getValue("uiLen") + '&ifaceorminor=' + getBtnValue(btn);
}
return jxl.cancelEvent(evt);
}
}
(function() {
var b = document.getElementsByTagName('button');
var len = b && b.length || 0;
for (var i = 0; i < len; i++) {
if (b[i].name) {
if (b[i].name.indexOf("start") == 0) {
jxl.addEventHandler(b[i], 'click', onStart);
}
if (b[i].name.indexOf("lstart") == 0) {
jxl.addEventHandler(b[i], 'click', onStart);
}
}
}
})();
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<p><?lua box.out(g_txt_intro) ?></p>
<hr>
<p>{?946:668?}</p>
<p>{?946:163?}</p>
<p>{?946:974?}</p>
<hr>
<form action="/capture.lua" method="POST" id="uiMainForm">
<?lua
if next(g_dsl) then
box.out([[<h3>{?946:3601?}</h3>]])
write_table(g_dsl)
end
if next(g_local) then
box.out([[
<h3>{?946:264?}</h3>
<div class="formular">
<label for="uiLen">{?946:3?}</label>
<input type="text" id="uiLen" name="len" size="7" value="]]..g_len..[["> Bytes
</div>
]])
write_table(g_local)
end
if next(g_wlan) then
box.out([[<h3>{?946:454?}</h3>]])
write_table(g_wlan)
end
if next(g_usb) then
box.out([[<h3>{?946:305?}</h3>]])
write_table(g_usb)
end
if next(g_unknown) then
box.out([[<h3>{?946:977?}</h3>]])
write_table(g_unknown)
end
?>
<h3>DTrace</h3>
<table class="zebra">
<tr>
<td class="paramcell">
<label for="uiDtraceParams">{?946:863?}</label>
<input type="text" id="uiDtraceParams" name="dparams">
</td>
<td class="buttonrow"><button type="submit" name="dstart" id="uiStart_dtrace">{?946:652?}</button></td>
<td class="imgcol" id="uiImage_dtrace"><?lua if g_dtrace_running then box.out([[<img src="/css/default/images/wait.gif">]]) end ?></td>
<td class="buttonrow"><button type="submit" name="dstop" id="uiStop_dtrace">{?946:401?}</button></td>
</tr>
<tr>
<th>{?946:930?}</th>
<td></td>
<td></td>
<?lua write_save_btn("new") ?>
</tr>
<tr>
<th>{?946:660?}</th>
<td></td>
<td></td>
<?lua write_save_btn("old") ?>
</tr>
</table>
<div class="formular">
<p>{?946:744?}</p>
<blockquote><code>-D&nbsp;-s&nbsp;-m&nbsp;-i256&nbsp;-dect&nbsp;-dlc&nbsp;-c1&nbsp;-c2&nbsp;-c3&nbsp;-c4&nbsp;-c5&nbsp;-nt3&nbsp;-d2&nbsp;-d3</code></blockquote>
<p>{?946:107?}</p>
<blockquote><code>-D&nbsp;-s&nbsp;-m&nbsp;-i256</code></blockquote>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="stopall" id="uiStopAll">{?946:249?}</button>
<button type="submit" name="refresh">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
