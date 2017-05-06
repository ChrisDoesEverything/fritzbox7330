<?lua
--[[
Datei Name: dial.lua
Datei Beschreibung: Die Wählhilfe unterstützt die Anwahl einer Rufnummer aus der Anrufliste und dem Telefonbuch durch einfaches Anklicken der Rufnummer oder des Namens.
]]
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_waehlhilfe.html"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("fon_numbers")
require("general")
require("js")
require("fon_devices")
require("cmtable")
g_back_to_page = http.get_back_to_page( box.glob.script )
g_fonlist = fon_devices.get_only_fon_devices()
local function show_nopassword()
local right_to_dial = tonumber(box.query("rights:status/Dial",0)) > 0
return not right_to_dial
end
g_val = {
prog = [[
if __value_equal(uiPort/port,0) then
const_error(uiPort/port, wrong, error_port_txt)
end
]]
}
function get_numberlist()
local number_data = fon_numbers.get_sip_num()
return number_data.numbers
end
local g_numberlist = get_numberlist()
function check_numberlist(resultquery)
local tmp=string.sub(resultquery,4,string.len(resultquery))
for index, data in ipairs(g_numberlist) do
if tmp == data.telcfg_id and data.active == false then
return true
end
end
return false
end
function get_is_sipdeactivated_list()
local returnlist = {}
if #g_fonlist ~= 0 then
for index, data in ipairs(g_fonlist) do
local value = {}
local result = check_numberlist(box.query(data.number_query))
if result then
value = {data.intern_id, result}
table.insert(returnlist, value)
end
end
end
return returnlist
end
function selected(id)
if tostring(box.query("telcfg:settings/DialPort")) == tostring(id) then
return "selected"
end
return ""
end
function get_html()
if show_nopassword() then
box.out([[<div><p>]])
box.html(
[[{?217:113?}]]
)
box.out([[</p><p>]])
local link = href.get("/system/boxuser_settings.lua", "back_to_page="..box.glob.script)
box.out(general.sprintf(
[[{?217:8968?}]],
[[<a href="]] .. box.tohtml(link) .. [[">]],
[[</a>]]
))
box.out([[</p></div>]])
else
box.out([[<div class="formular"><input ]])
if box.query("telcfg:settings/UseClickToDial") == "1" then
box.out([[ checked="checked" ]])
end
box.out([[ onclick="enabledDivTest()" type="checkbox" id="uiClickToDial" name="clicktodial">
<label for="uiClickToDial">]]..box.tohtml([[{?217:996?}]])..[[</label>
</div><div id="uiDivTest" name="DivTest">
<div class="formular left"><label for="uiPort">]]..box.tohtml([[{?217:9?}]])..
[[</label><select onclick="checkSip()" id="uiPort" name="port">
<option value="0">]]..box.tohtml([[{?txtPleaseSelect?}]])..[[</option>]])
if #g_fonlist ~= 0 then
for i = 1, #g_fonlist, 1 do
box.out([[<option ]]..selected(g_fonlist[i].intern_id)..[[ value="]]..box.tohtml(g_fonlist[i].intern_id)..[[">]]..box.tohtml(fon_devices.get_fonname(g_fonlist[i].intern_id, g_fonlist))..[[</option>]])
end
end
box.out([[</select></div>]])
if config.AB_COUNT >= 2 then
box.out([[<div class="ShowBtnRight"><input type="button" id="uiDialTest" name="dialtest" onclick="onDial()" value="]]..box.tohtml([[{?217:513?}]])..[[" ></div>]])
end
box.out([[</div>]])
end
end
if box.get.dial or box.get.hangup then
local saveset = {}
local orig_port, dialport
orig_port = box.query("telcfg:settings/DialPort")
if (box.get.orig_port) then
orig_port=tostring(box.get.orig_port)
end
if box.get.dial then
if config.CAPI_NT then
dialport = "50";
else
if orig_port == "1" then
dialport = "2";
else
dialport = "1";
end
end
cmtable.add_var(saveset, "telcfg:settings/DialPort", dialport)
cmtable.add_var(saveset, "telcfg:command/Dial", tostring(box.get.dial))
elseif box.get.hangup then
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
cmtable.add_var(saveset, "telcfg:settings/DialPort", orig_port)
end
local err, msg = box.set_config(saveset)
box.out(js.table({
dialing = box.get.dial and box.tohtml(box.get.dial) or false,
orig_port = box.tohtml(orig_port)
}))
box.end_page()
end
val.msg.error_port_txt = {
[val.ret.wrong] = [[{?217:318?}]]
}
local ctlmgr_save={}
local dialport = nil
if next(box.post) and box.post.btn_apply then
if val.validate(g_val) == val.ret.ok then
if box.post.clicktodial then
cmtable.add_var(ctlmgr_save, "telcfg:settings/DialPort", tostring(box.post.port))
cmtable.add_var(ctlmgr_save, "telcfg:settings/UseClickToDial","1")
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/UseClickToDial","0")
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
else
http.redirect(href.get(g_back_to_page))
end
end
if next(box.post) and box.post.btn_cancel then
http.redirect(href.get(g_back_to_page))
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua box.html(box.glob.script) ?>">
<div>{?217:444?}</div>
<hr>
<?lua
get_html()
?>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="btn_apply" id="uiBtnApply">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="uiBtnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onDial(num) {
var url = encodeURI("<?lua box.js(box.glob.script) ?>") +
"?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
var json = makeJSONParser();
var port = jxl.getValue('uiPort');
var dial = "**"+port;
if (port.charAt(0) == '6') {
dial = "**" + port.charAt(0) + "1" + port.charAt(1);
}
function cbDial(xhr) {
var answer = json(xhr.responseText || "null");
var txt = [
jxl.sprintf(
"{?217:12?}",
dial
),
"{?217:764?}"
];
alert(txt.join("\n\n"))
ajaxGet(url + "&" + buildUrlParam("hangup", "") + "&" + buildUrlParam("orig_port", answer.orig_port))
}
function cbHangup(xhr) {
alert("{?217:316?}");
}
ajaxGet(url + "&" + buildUrlParam("dial",dial), cbDial);
return false;
}
function checkSip() {
var viewPort = jxl.getValue('uiPort');
var SipDataList = <?lua box.out(js.table(get_is_sipdeactivated_list())) ?>;
for (var i = 0; i < SipDataList.length; ++i)
{
if (SipDataList[i][0] == viewPort && SipDataList[i][1] == true)
{
alert("{?217:650?}");
jxl.setDisabled('uiDialTest', true);
return;
}
else
{
setAktivCallButton()
}
}
}
function setAktivCallButton() {
if(jxl.getValue('uiPort'))
{
jxl.setDisabled('uiDialTest', jxl.getValue('uiPort') =='0');
}
else
{
jxl.setDisabled('uiDialTest', true);
}
return;
}
function enabledDivTest()
{
jxl.disableNode("uiDivTest", !jxl.getChecked("uiClickToDial"));
if (jxl.getChecked("uiClickToDial"))
{
setAktivCallButton();
}
}
function init() {
enabledDivTest();
setAktivCallButton();
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
