<?lua
g_page_type = "wizard"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"wizard"
require"general"
require"cmtable"
require"val"
require"http"
require"first"
require"html"
require"js"
require"umts"
g_val = {}
g_val.prog = ""
userinput = {}
userinput.names = {'connection', 'msn'}
function userinput.urlparams()
local params = {}
for i, name in ipairs(userinput.names) do
local value = box.post[name] or box.get[name]
if value then
table.insert(params, http.url_param(name, value))
end
end
return params
end
conn = {}
function conn.write_checked(which)
local checked = false
if box.post.connection == which or box.get.connection == which then
checked = true
else
checked = which == "dsl"
end
box.out(checked and " checked" or "")
end
function conn.write_class()
box.html(box.post.connection or box.get.connection or "")
end
pin = {}
pin.maxcount = {PIN = 3, PUK = 10}
pin.showerror = function()
return box.post.pinerror or box.get.pinerror
end
pin.wrong = function(which)
if umts.pin_needed(which) then
local trycount = tonumber(umts.Trycount) or 0
local maxcount = pin.maxcount[which]
return trycount < maxcount
end
return false
end
pin.write_value = function(which)
box.html(box.post[which] or box.get[which] or "")
end
pin.write_count = function(which)
if umts.pin_needed('PUK') and which == 'PIN' then
return
end
local count = umts.Trycount
if count then
box.html(general.sprintf(
[[{?2970:346?}]],
count, pin.maxcount[which]
))
end
end
pin.write_pin_label = function()
local txt = [[{?2970:961?}]]
if umts.pin_needed('PUK') then
txt = [[{?2970:488?}]]
end
box.html(txt)
end
pin.write_puk_msg = function()
if pin.showerror() and umts.pin_needed('PUK') then
html.p{class="form_input_note",
[[{?2970:725?}]]
}.write()
end
end
pin.wrongtxt = {
PIN = [[{?2970:278?}]],
PUK = [[{?2970:60?}]]
}
pin.write_error = function(which)
if pin.showerror() and pin.wrong(which) then
html.p{pin.wrongtxt[which]}.write()
end
end
pin.write_error_class = function(which)
local class = ""
if pin.showerror() and pin.wrong(which) then
class = " error"
end
box.out(class)
end
pin.write_class = function()
local class = ""
if umts.pin_needed('PUK') then
class = "pukneeded"
elseif umts.pin_needed('PIN') then
class = "pinneeded"
else
class = "pinready"
end
box.out(class)
end
pin.validation = function()
local puk_prog = " not_empty(uiPuk/PUK, pukerr) "
.. " char_range_regex(uiPuk/PUK, decimals, pukerr) "
local pin_prog = " length(uiPin/PIN, 4, 8, pinerr) "
.. " char_range_regex(uiPin/PIN, decimals, pinerr) "
val.msg.pinerr = {
[val.ret.tooshort] = [[{?2970:872?}]],
[val.ret.toolong] = [[{?2970:310?}]],
[val.ret.outofrange] = [[{?2970:633?}]]
}
val.msg.pukerr = {
[val.ret.empty] = [[{?2970:69?}]],
[val.ret.outofrange] = [[{?2970:215?}]]
}
if umts.pin_needed('PUK') then
return puk_prog .. pin_prog
elseif umts.pin_needed('PIN') then
return pin_prog
else
return ""
end
end
msn = {}
function msn.write_value()
local msn = box.post.msn or box.get.msn
if not msn or msn == "" then
msn = box.query("telcfg:settings/Mobile/MSN")
end
if not msn or msn == "" then
msn = umts.SubscriberNumber
end
box.html(msn or "")
end
function msn.write_disabled()
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
box.out(" disabled")
end
end
function msn.validation()
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
return ""
else
val.msg.msnerr = {
[val.ret.outofrange] = [[{?2970:743?}]]
}
val.msg.msnerr2 = {
[val.ret.outofrange] = [[{?2970:576?}]],
}
return " char_range_regex(uiMsn/msn, anynonwhitespace, msnerr2) "
.. " char_range_regex(uiMsn/msn, fonnum, msnerr) "
end
end
function msn.convert(value)
-- +49 am Anfang durch 0 ersetzen
-- dann alle Nichtziffern entfernen
value = value:gsub("^%s*%+%s*49", "0")
value = value:gsub("[^%d]", "")
return value
end
okz = {}
function okz.write_value()
local okz = box.post.okz or box.get.okz
if not okz or okz == "" then
okz = box.query("telcfg:settings/Location/OKZ")
if okz and okz:at(1) ~= "0" then
okz = "0" .. okz
end
end
box.html(okz or "")
end
function okz.write_disabled()
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
box.out(" disabled")
end
end
function okz.convert(value)
if value:at(1) == "0" then
value = value:sub(2)
end
return value
end
function okz.validation()
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
return ""
else
val.msg.numerr = {
[val.ret.outofrange] = [[{?2970:26?}]]
}
val.msg.okzerr = {
[val.ret.outofrange] = [[{?2970:973?}]]
}
return " char_range_regex(uiOkz/okz, decimals, numerr) "
.. " char_range_regex(uiOkz/okz, okz, okzerr) "
end
end
local function tam_already_there()
for i = 0, 4 do
if box.query("tam:settings/TAM" .. i .. "/Display") == "1" then
return true
end
end
return false
end
local function set_ctlmgr_values()
local saveset = {}
local pin_needed = umts.pin_needed('PIN')
local puk_needed = umts.pin_needed('PUK')
if pin_needed or puk_needed then
-- Pin/Puk setzen
if puk_needed then
cmtable.add_var(saveset, "gsm:settings/PUK", box.post.PUK)
end
cmtable.add_var(saveset, "gsm:settings/PIN", box.post.PIN)
else
-- Umts/Msn setzen
local i, p = array.find(umts.providers, func.eq("1&1 Internet", "name"))
if i and p then
cmtable.add_var(saveset, "umts:settings/name", p.name)
cmtable.add_var(saveset, "umts:settings/provider", p.provider)
cmtable.add_var(saveset, "umts:settings/number", p.number)
cmtable.add_var(saveset, "umts:settings/username", p.username)
cmtable.add_var(saveset, "umts:settings/password", p.password)
else
end
--TS839
cmtable.add_var(saveset, "umts:settings/backup_quickstart","1")
cmtable.add_var(saveset, "umts:settings/on_demand", "0")
cmtable.add_var(saveset, "umts:settings/enabled", "1")
cmtable.add_var(saveset, "telcfg:settings/Mobile/MSN", msn.convert(box.post.msn))
cmtable.add_var(saveset, "telcfg:settings/Location/OKZ", okz.convert(box.post.okz))
cmtable.add_var(saveset, "telcfg:settings/Location/LKZ", "49")
cmtable.add_var(saveset, "telcfg:settings/Location/OKZPrefix", "0")
cmtable.add_var(saveset, "telcfg:settings/Location/LKZPrefix", "00")
cmtable.add_var(saveset, "telcfg:settings/Mobile/UsePrefix", "1")
if not tam_already_there() then
cmtable.add_var(saveset, "tam:settings/TAM0/Mode", "1")
cmtable.add_var(saveset, "tam:settings/TAM0/RingCount", "4")
cmtable.add_var(saveset, "tam:settings/TAM0/RecordLength", "60")
cmtable.add_var(saveset, "tam:settings/TAM0/Name", [[{?g_AB?}]] .. " 1")
cmtable.add_var(saveset, "tam:settings/TAM0/Active", "1")
cmtable.add_var(saveset, "tam:settings/TAM0/Display", "1")
cmtable.add_var(saveset, "tam:settings/TAM0/PushmailActive", "0")
cmtable.add_var(saveset, "tam:settings/TAM0/MailAddress", "")
cmtable.add_var(saveset, "tam:settings/TAM0/PIN", "0000")
end
end
local err, msg = box.set_config(saveset)
end
wizard.dialogs = {
'dlg_choose_connection',
'dlg_modem_error',
'dlg_pin_number',
'dlg_end'
}
wizard.title = setmetatable({
dlg_pin_number = (umts.pin_needed('PIN') or umts.pin_needed('PUK'))
and [[{?2970:780?}]]
or [[{?2970:816?}]],
dlg_end = box.get.pincheck and [[{?2970:464?}]]
or [[{?2970:798?}]],
dlg_modem_error = [[{?2970:851?}]]
}, {__index = func.const([[{?2970:290?}]])}
)
wizard.start = function() return 'dlg_choose_connection' end
wizard.dlg_choose_connection = {
forward = function() return 'dlg_modem_error' end,
backward = function() end
}
function stick_ready()
local state = umts.pinstate()
return umts.is_1und1_modem() and not (state=="nosim" or state=="simerror" or state=="other" or state=="pinchecking")
end
wizard.dlg_modem_error = {
forward = function()
return stick_ready() and 'dlg_pin_number' or 'dlg_modem_error'
end,
backward = function() return 'dlg_choose_connection' end
}
wizard.dlg_pin_number = {
forward = function() return 'dlg_pin_number' end,
backward = function() return 'dlg_choose_connection' end
}
wizard.dlg_end = {
forward = function() return 'dlg_end' end,
backward = function() return 'dlg_pin_number' end
}
wizard.init = function()
wizard.curr = wizard.start()
if box.post.prevdlg and box.post.prevdlg ~= "" then
if box.post.forward then
wizard.curr = wizard[box.post.prevdlg].forward()
elseif box.post.backward then
wizard.curr = wizard[box.post.prevdlg].backward()
end
end
wizard.wiztype = box.post.wiztype or box.get.wiztype
end
local onquery = {}
onquery.pincheck = function()
local answer = {}
local pinstate = umts.pinstate()
answer.done = pinstate ~= "pinchecking" or pinstate == "pinready"
if answer.done then
answer.result = pinstate == "pinready" and "ok" or "nok"
if answer.result == "nok" then
answer.html = html.p{
[[{?2970:123?}]]
}.get()
end
end
return answer
end
onquery.modemcheck = function()
local answer = {}
answer.done = umts.is_1und1_modem()
answer.pinstate = umts.pinstate()
return answer
end
local function conn_check_timeout(starttime)
-- nach 2 Minuten geben wir auf
local diff = starttime and os.difftime(os.time(), starttime) or 0
return diff > 120
end
onquery.conncheck = function()
local answer = {}
local netstate = umts.networkstate()
local connstate = box.query("connection0:status/connect")
local netfound = netstate:find("registered_") == 1
local connected = connstate == "5"
if netfound and connected then
answer.done = true
answer.result = "ok"
answer.html = html.p{
[[{?2970:797?}]]
}.get()
else
local starttime = box.get.addinfo
if not starttime then
answer.done = false
answer.addinfo = os.time()
elseif conn_check_timeout(starttime) then
answer.done = true
answer.result = "nok"
answer.errortype = netfound and "connerror" or "neterror"
local txt = netfound
and [[{?2970:742?}]]
or [[{?2970:358?}]]
answer.html = html.p{txt}.get()
else
answer.done = false
answer.dbginfo = "netstate=".. tostring(netstate).. " connstate=".. tostring(connstate).. " connected=".. tostring(connected)
end
end
return answer
end
------------------------------------------------------------------------------
goto_startcode_wizard = function(wiztype)
http.redirect(href.get("/tr69_autoconfig/tr069startcode.lua", http.url_param("wiztype", wiztype)))
end
if box.get.query == "pincheck" or box.get.query == "conncheck" or box.get.query == "modemcheck" then
local answer = onquery[box.get.query]()
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
wizard.leave()
elseif box.post.forward and box.post.gotostartcode then
goto_startcode_wizard('umts')
else
wizard.init()
if box.get.pinerror or box.post.backward and box.post.pinerror then
wizard.curr = 'dlg_pin_number'
elseif box.get.pinok then
wizard.curr = 'dlg_pin_number'
elseif box.get.conncheck or box.get.pincheck then
wizard.curr = 'dlg_end'
end
if wizard.title then
g_page_title = wizard.title[wizard.curr]
end
if wizard.curr == 'dlg_pin_number' then
g_val.prog = pin.validation() .. msn.validation() .. okz.validation()
end
if wizard.curr == 'dlg_modem_error' then
wizard.override_btntext('forward', TXT([[{?2970:570?}]]))
end
if box.post.forward then
local prev = box.post.prevdlg
if prev == 'dlg_choose_connection' then
if box.post.connection == "dsl" then
goto_startcode_wizard('first')
end
elseif prev == 'dlg_pin_number' then
if val.validate(g_val) == val.ret.ok then
local check = "conncheck"
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
check = "pincheck"
end
set_ctlmgr_values()
local params = userinput.urlparams()
table.insert(params, http.url_param(check, ""))
http.redirect(href.get(box.glob.script, unpack(params)))
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
<?lua wizard.write_css() ?>
#dlg_choose_connection.dsl .hideif_dsl,
#dlg_choose_connection.umts .hideif_umts,
#dlg_pin_number.pinready .hideif_pinready,
#dlg_pin_number.pukneeded .hideif_pukneeded,
#dlg_pin_number.pinneeded .hideif_pinneeded,
#dlg_end.pincheck .hideif_pincheck,
#dlg_end.conncheck .hideif_conncheck {
display: none;
}
div.checklist p {
background-position: left top;
background-repeat: no-repeat;
padding-left: 30px;
}
div.checklist p.ok {
background-image: url(/css/default/images/icon_ok.png);
}
div.checklist p.nok {
background-image: url(/css/default/images/icon_error.png);
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
function initChooseConnection() {
classChangeOnRadio({
radioName: "connection",
destId: "dlg_choose_connection"
});
}
function initDlgErrorCheck() {
wizard.disable("forward");
setTimeout(checkModemActiv, 2000);
}
function checkModemActiv() {
var json = makeJSONParser();
var queryParam = "&" + buildUrlParam("query", "modemcheck");
var count = 0;
var maxtryouts = 10;
function callback_error_handling(error_id) {
if (count < maxtryouts ) {
setTimeout(request, 2000);
}
else {
jxl.display("uiWaitModemCheck", false);
jxl.display(error_id, true);
wizard.enable("forward");
}
}
function callback(xhr) {
var answer = json(xhr.responseText || "null");
if (!answer || !answer.done || !answer.pinstate) {
callback_error_handling("uiModemError");
}
else if ((answer.pinstate=="nosim" || answer.pinstate=="pinchecking") && maxtryouts == 10) {
maxtryouts = count + 8;
callback_error_handling("uiSimreadError");
}
else if (answer.pinstate=="simerror" || answer.pinstate=="other") {
maxtryouts = 0;
callback_error_handling("uiSimreadError");
}
else {
jxl.enable("auto_forward");
jxl.submitForm("mainform");
}
}
function request() {
count += 1;
ajaxGet(ajaxUrl + queryParam , callback);
}
jxl.addClass("dlg_modem_error", "modemcheck");
request();
}
var ajaxUrl = encodeURI("<?lua box.js(box.glob.script) ?>") +
"?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
var userInput = [<?lua box.out(js.array(userinput.urlparams())) ?>].join("&");
function reloadPage(param) {
var p = param && ("&" + param) || "";
location.href = ajaxUrl + "&" + userInput + p;
}
function checkPinOnly() {
var poll = 500;
var json = makeJSONParser();
var queryParam = "&" + buildUrlParam("query", "pincheck");
var addInfoParam = "";
function onPincheck(answer) {
var result = answer.result;
if (result == "ok") {
reloadPage(buildUrlParam("pinok", ""));
}
else {
reloadPage(buildUrlParam("pinerror", ""));
}
}
function callback(xhr) {
var answer = json(xhr.responseText || "null");
if (answer && answer.addinfo) {
addInfoParam = "&" + buildUrlParam("addinfo", answer.addinfo);
}
if (!answer || !answer.done) {
setTimeout(request, poll);
}
else {
onPincheck(answer);
}
}
function request() {
ajaxGet(ajaxUrl + queryParam + addInfoParam, callback);
}
wizard.disable("forward");
jxl.addClass("dlg_end", "pincheck");
request();
}
function checkPinAndConnection() {
var poll = 500;
var queries = ["pincheck", "conncheck"];
var json = makeJSONParser();
var currQuery = queries.shift();
var queryParam = "&" + buildUrlParam("query", currQuery);
var addInfoParam = "";
function onPincheck(answer) {
var result = answer.result;
jxl.addClass("uiPinChecked", result || "");
if (result == "ok") {
currQuery = queries.shift();
queryParam = "&" + buildUrlParam("query", currQuery);
setTimeout(request, poll);
}
else {
jxl.enable("uiPinError");
jxl.setHtml("uiWaitResult", answer.html || "");
}
}
function onConncheck(answer) {
var result = answer.result;
jxl.addClass("uiConnChecked", result || "");
if (result == "ok") {
jxl.enable("uiGotoStartcode");
wizard.enable("forward");
}
if (answer.errortype == "connerror") {
wizard.enable("forward");
}
jxl.setHtml("uiWaitResult", answer.html || "");
}
function callback(xhr) {
var answer = json(xhr.responseText || "null");
if (answer && answer.addinfo) {
addInfoParam = "&" + buildUrlParam("addinfo", answer.addinfo);
}
if (!answer || !answer.done) {
setTimeout(request, poll);
}
else {
if (currQuery == "pincheck") {
onPincheck(answer);
}
else {
onConncheck(answer);
}
}
}
function request() {
ajaxGet(ajaxUrl + queryParam + addInfoParam, callback);
}
wizard.disable("forward");
jxl.addClass("dlg_end", "conncheck");
request();
}
function onFocusInput(evt) {
var elem = jxl.evtTarget(evt);
if (elem) {
jxl.removeClass(elem, "error");
jxl.removeEventHandler(elem, "focus", onFocusInput);
}
}
<?lua val.write_js_error_strings() ?>
function uiDoSubmit() {
var result = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
return result;
}
<?lua
if wizard.curr == 'dlg_choose_connection' then
box.out("\n" .. [[
ready.onReady(initChooseConnection);
]])
elseif wizard.curr == 'dlg_modem_error' then
box.out("\n" .. [[
ready.onReady(initDlgErrorCheck);
]])
elseif wizard.curr == 'dlg_pin_number' then
box.out("\n" .. [[
ready.onReady(val.init(uiDoSubmit, "forward"));
]])
if box.post.pinerror or box.get.pinerror then
box.out("\n" .. [[
ready.onReady(function() {
jxl.addEventHandler("uiPin", "focus", onFocusInput);
jxl.addEventHandler("uiPuk", "focus", onFocusInput);
});
]])
end
elseif wizard.curr == 'dlg_end' then
if box.post.pincheck or box.get.pincheck then
box.out("\n" .. [[
ready.onReady(checkPinOnly);
]])
elseif box.post.conncheck or box.get.conncheck then
box.out("\n" .. [[
ready.onReady(checkPinAndConnection);
]])
end
end
?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>"
class="narrow <?lua wizard.write_class() ?>">
<?lua href.default_submit('forward') ?>
<?lua wizard.write_1und1_logo() ?>
<div id="dlg_choose_connection" class="<?lua conn.write_class() ?>">
<p>
{?2970:110?}
</p>
<div class="formular">
<input id="uiConnectionDsl" type="radio" name="connection" value="dsl" <?lua conn.write_checked('dsl') ?>>
<label for="uiConnectionDsl">{?2970:438?}</label>
<p class="hideif_umts form_input_explain">
{?2970:678?}
</p>
<br>
<input id="uiConnectionUmts" type="radio" name="connection" value="umts" <?lua conn.write_checked('umts') ?>>
<label for="uiConnectionUmts">{?2970:79?}</label>
<p class="hideif_dsl form_input_explain">
{?2970:611?}
</p>
</div>
</div>
<div id="dlg_modem_error">
<div id="uiWaitModemCheck">
<p class="waitimg" >{?2970:393?}</p>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<div id="uiModemError" style="display:none">
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<br>
<p>{?2970:842?}</p>
<p>{?2970:78?}</p>
</div>
<div id="uiSimreadError" style="display:none">
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<br>
<p>{?2970:435?}</p>
<p>{?2970:591?}</p>
</div>
</div>
<div id="dlg_pin_number" class="<?lua pin.write_class() ?>">
<p class="hideif_pinready">
{?2970:833?}
</p>
<p class="hideif_pinneeded hideif_pukneeded">
{?2970:321?}
</p>
<p class="hideif_pinneeded hideif_pukneeded">
{?2970:107?}
</p>
<?lua pin.write_puk_msg() ?>
<div class="formular hideif_pinready">
<div id="uiPukInput" class="hideif_pinneeded">
<label for="uiPuk">{?2970:480?}</label>
<input type="text" name="PUK" id="uiPuk" value="<?lua pin.write_value('PUK') ?>" autocomplete="off"
class="<?lua val.write_error_class(g_val, 'uiPuk', true) pin.write_error_class('PUK') ?>">
<span class="form_input_explain postfix"><?lua pin.write_count('PUK') ?></span>
<?lua val.write_html_msg(g_val, "uiPuk") ?>
<?lua pin.write_error('PUK') ?>
</div>
<div>
<label for="uiPin"><?lua pin.write_pin_label() ?></label>
<input type="text" name="PIN" id="uiPin" maxlength="8" value="<?lua pin.write_value('PIN') ?>" autocomplete="off"
class="<?lua val.write_error_class(g_val, 'uiPin', true) pin.write_error_class('PIN') ?>">
<span class="form_input_explain postfix"><?lua pin.write_count('PIN') ?></span>
<?lua val.write_html_msg(g_val, "uiPin") ?>
<?lua pin.write_error('PIN') ?>
</div>
</div>
<div class="hideif_pinneeded hideif_pukneeded">
<div class="formular">
<label for="uiMsn">{?2970:179?}</label>
<input type="text" name="msn" id="uiMsn"
value="<?lua msn.write_value() ?>"
<?lua msn.write_disabled() ?>
<?lua val.write_error_class(g_val, 'uiMsn') ?>>
<?lua val.write_html_msg(g_val, 'uiMsn') ?>
</div>
<div class="formular">
<label for="uiOkz">{?2970:412?}</label>
<input type="text" name="okz" id="uiOkz"
value="<?lua okz.write_value() ?>"
<?lua okz.write_disabled() ?>
<?lua val.write_error_class(g_val, 'uiOkz') ?>>
<span class="form_input_explain postfix">{?2970:284?}</span>
<?lua val.write_html_msg(g_val, "uiOkz") ?>
</div>
</div>
</div>
<div id="dlg_end">
<div id="uiWaitResult">
<p class="waitimg hideif_pincheck">{?2970:686?}</p>
<p class="waitimg hideif_conncheck">{?2970:845?}</p>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<div class="formular checklist hideif_pincheck">
<p id="uiPinChecked">{?2970:397?}</p>
<p id="uiConnChecked">{?2970:951?}</p>
</div>
</div>
<div id="btn_form_foot">
<?lua wizard.write_buttons() ?>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<input type="hidden" id="uiPinError" name="pinerror" value="" disabled>
<input type="hidden" id="auto_forward" name="forward" value="" disabled>
<input type="hidden" id="uiGotoStartcode" name="gotostartcode" value="" disabled>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
