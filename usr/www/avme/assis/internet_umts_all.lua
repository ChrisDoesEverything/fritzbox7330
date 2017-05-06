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
require"umts_html"
g_data = {
account = umts.name,
provider = umts.provider,
number = umts.number,
username = umts.username,
password = umts.password
}
g_accounts = umts.providerlist()
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
[[{?457:889?}]],
count, pin.maxcount[which]
))
end
end
pin.write_pin_label = function()
local txt = [[{?457:769?}]]
if umts.pin_needed('PUK') then
txt = [[{?457:468?}]]
end
box.html(txt)
end
pin.write_puk_msg = function()
if pin.showerror() and umts.pin_needed('PUK') then
html.p{class="form_input_note",
[[{?457:984?}]]
}.write()
end
end
pin.wrongtxt = {
PIN = [[{?457:439?}]],
PUK = [[{?457:727?}]]
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
[val.ret.tooshort] = [[{?457:796?}]],
[val.ret.toolong] = [[{?457:481?}]],
[val.ret.outofrange] = [[{?457:762?}]]
}
val.msg.pukerr = {
[val.ret.empty] = [[{?457:74?}]],
[val.ret.outofrange] = [[{?457:423?}]]
}
if umts.pin_needed('PUK') then
return puk_prog .. pin_prog
elseif umts.pin_needed('PIN') then
return pin_prog
else
return ""
end
end
dlg_provider = {}
function dlg_provider.write_class()
local class = ""
if wizard.curr~="dlg_provider" then
class = "providerneeded"
end
box.out(class)
end
function dlg_provider.validation()
return umts_html.account_validation(val)
end
msn = {}
function msn.write_value()
if umts.is_voice_modem() then
local msn = box.post.msn or box.get.msn
if not msn or msn == "" then
msn = box.query("telcfg:settings/Mobile/MSN")
end
if not msn or msn == "" then
msn = umts.SubscriberNumber
end
box.html(msn or "")
end
end
function msn.write_class()
if not umts.is_voice_modem() then
box.out("hideif_nonumbers")
end
end
function msn.write_disabled()
if umts.is_voice_modem() then
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
box.out(" disabled")
end
end
end
function msn.validation()
if umts.is_voice_modem() then
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
return ""
else
val.msg.msnerr = {
[val.ret.outofrange] = [[{?457:841?}]]
}
val.msg.msnerr2 = {
[val.ret.outofrange] = [[{?457:59?}]],
}
return " char_range_regex(uiMsn/msn, anynonwhitespace, msnerr2) "
.. " char_range_regex(uiMsn/msn, fonnum, msnerr) "
end
end
return ""
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
if umts.is_voice_modem() then
local okz = box.post.okz or box.get.okz
if not okz or okz == "" then
okz = box.query("telcfg:settings/Location/OKZ")
if okz and okz:at(1) ~= "0" then
okz = "0" .. okz
end
end
box.html(okz or "")
end
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
if umts.is_voice_modem() then
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
return ""
else
val.msg.numerr = {
[val.ret.outofrange] = [[{?457:51?}]]
}
val.msg.okzerr = {
[val.ret.outofrange] = [[{?457:850?}]]
}
return " char_range_regex(uiOkz/okz, decimals, numerr) "
.. " char_range_regex(uiOkz/okz, okz, okzerr) "
end
end
return ""
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
function save_phone(saveset)
if umts.is_voice_modem() then
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
end
function save_provider(saveset,providername)
local i, p = array.find(umts.providers, func.eq(providername, "name"))
if i and p then
cmtable.add_var(saveset, "umts:settings/name", p.name)
cmtable.add_var(saveset, "umts:settings/provider", p.provider)
if (providername=="") then
cmtable.add_var(saveset, "umts:settings/number", box.post.number)
cmtable.add_var(saveset, "umts:settings/username", box.post.username)
cmtable.add_var(saveset, "umts:settings/password", box.post.password)
else
cmtable.add_var(saveset, "umts:settings/number", p.number)
cmtable.add_var(saveset, "umts:settings/username", p.username)
cmtable.add_var(saveset, "umts:settings/password", p.password)
end
else
end
end
local saveset = {}
if box.post.step=="dlg_pin" then
local pin_needed = umts.pin_needed('PIN')
local puk_needed = umts.pin_needed('PUK')
if pin_needed or puk_needed then
-- Pin/Puk setzen
if puk_needed then
cmtable.add_var(saveset, "gsm:settings/PUK", box.post.PUK)
end
cmtable.add_var(saveset, "gsm:settings/PIN", box.post.PIN)
end
cmtable.add_var(saveset, "umts:settings/backup_quickstart","1")
cmtable.add_var(saveset, "umts:settings/on_demand", "0")
cmtable.add_var(saveset, "umts:settings/enabled", "1")
elseif box.post.step=="dlg_provider" then
local providername=box.post.account
save_provider(saveset,providername)
elseif box.post.step=="dlg_number" then
-- Umts/Msn setzen
save_phone(saveset)
end
local err, msg = box.set_config(saveset)
end
wizard.dialogs = {
'dlg_choose_connection',
'dlg_modem_error',
'dlg_pin',
'dlg_number',
'dlg_provider',
'dlg_end'
}
local modem_title=[[{?457:696?}]]
if config.oem~="1und1" then
modem_title=[[{?457:220?}]]
end
wizard.title = setmetatable({
dlg_pin = (umts.pin_needed('PIN') or umts.pin_needed('PUK'))
and [[{?457:546?}]],
dlg_number = [[{?457:620?}]],
dlg_end = box.get.pincheck and [[{?457:551?}]]
or [[{?457:698?}]],
dlg_modem_error = modem_title,
dlg_provider = [[{?457:999?}]]
}, {__index = func.const([[{?457:484?}]])}
)
function write_antenna()
local modem_title=[[{?457:16?}]]
if config.oem~="1und1" then
modem_title=[[{?457:41?}]]
end
box.html(modem_title)
end
function write_antenna_explain()
if config.oem~="1und1" then
box.html([[{?457:4532?}]])
else
box.html([[{?457:552?}]])
end
end
function write_dsl_explain()
if config.oem~="1und1" then
box.html([[{?457:7541?}]])
else
box.html([[{?457:361?}]])
end
end
function write_txt(txt_id)
local txt={}
if config.oem~="1und1" then
txt["sim"]=[[{?457:888?}]]
txt["wait"]=[[{?457:310?}]]
txt["not_detected"]=[[{?457:830?}]]
txt["check_modem"]=[[{?457:224?}]]
txt["read_error"]=[[{?457:750?}]]
else
txt["sim"]=[[{?457:909?}]]
txt["wait"]=[[{?457:20?}]]
txt["not_detected"]=[[{?457:231?}]]
txt["check_modem"]=[[{?457:23?}]]
txt["read_error"]=[[{?457:447?}]]
end
box.html(txt[txt_id] or "")
end
function stick_ready()
local state = umts.pinstate()
return umts.is_1und1_modem() and not (state=="nosim" or state=="simerror" or state=="other" or state=="pinchecking")
end
wizard.start = function() return 'dlg_choose_connection' end
wizard.dlg_choose_connection = {
forward = function() return 'dlg_modem_error' end,
backward = function() end
}
wizard.dlg_modem_error = {
forward = function()
return stick_ready() and 'dlg_pin' or 'dlg_modem_error'
end,
backward = function() return 'dlg_choose_connection' end
}
wizard.dlg_pin = {
forward = function() return 'dlg_number' end,
backward = function() return 'dlg_choose_connection' end
}
wizard.dlg_number = {
forward = function() return 'dlg_provider' end,
backward = function() return 'dlg_pin' end
}
wizard.dlg_provider = {
forward = function() return 'dlg_end' end,
backward = function()
if umts.is_voice_modem() then
return 'dlg_number'
else
return 'dlg_pin'
end
end
}
wizard.dlg_end = {
forward = function() return 'dlg_end' end,
backward = function() return 'dlg_provider' end
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
if pinstate == "pinready" then
local netstate = umts.networkstate()
if (netstate=="searching") then
pinstate=pinstate..[[_net_searching]]
answer.done=false
end
end
if answer.done then
answer.result = pinstate == "pinready" and "ok" or "nok"
if answer.result == "nok" then
answer.html = html.p{
[[{?457:6?}]]
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
[[{?457:864?}]]
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
and [[{?457:506?}]]
or [[{?457:57?}]]
answer.html = html.p{txt}.get()
else
answer.done = false
answer.dbginfo = "netstate=".. tostring(netstate).. " connstate=".. tostring(connstate).. " connected=".. tostring(connected)
end
end
return answer
end
leave_wizard = function(wiztype)
if config.oem~="1und1" then
http.redirect(href.get("/assis/home.lua"))
else
http.redirect(href.get("/tr69_autoconfig/tr069startcode.lua", http.url_param("wiztype", wiztype)))
end
end
if box.get.query == "pincheck" or box.get.query == "conncheck" or box.get.query == "modemcheck" then
local answer = onquery[box.get.query]()
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
wizard.leave()
elseif box.post.forward and box.post.gotostartcode then
leave_wizard('umts')
else
wizard.init()
if box.get.pinerror or box.post.backward and box.post.pinerror then
wizard.curr = 'dlg_pin'
elseif box.get.pinok then
if (config.oem~="1und1") then
if umts.is_voice_modem() then
wizard.curr = 'dlg_number'
else
wizard.curr = 'dlg_provider'
end
else
wizard.curr = 'dlg_number'
end
elseif box.get.conncheck or box.get.pincheck then
wizard.curr = 'dlg_end'
end
if wizard.title then
g_page_title = wizard.title[wizard.curr]
end
if wizard.curr == 'dlg_pin' then
g_val.prog = pin.validation()
end
if wizard.curr == 'dlg_number' then
g_val.prog = msn.validation() .. okz.validation()
end
if wizard.curr == 'dlg_provider' then
g_val.prog = dlg_provider.validation()
end
if wizard.curr == 'dlg_modem_error' then
wizard.override_btntext('forward', TXT([[{?457:715?}]]))
end
if box.post.forward then
local prev = box.post.prevdlg
if prev == 'dlg_choose_connection' then
if box.post.connection == "dsl" then
leave_wizard('first')
end
elseif prev == 'dlg_provider' then
if val.validate(g_val) == val.ret.ok then
local check = "conncheck"
set_ctlmgr_values()
local params = userinput.urlparams()
table.insert(params, http.url_param(check, ""))
http.redirect(href.get(box.glob.script, unpack(params)))
end
elseif prev == 'dlg_pin' then
if val.validate(g_val) == val.ret.ok then
--local check="conncheck"
local check=""
if umts.pin_needed('PIN') or umts.pin_needed('PUK') then
check = "pincheck"
end
set_ctlmgr_values()
local params = userinput.urlparams()
table.insert(params, http.url_param(check, ""))
http.redirect(href.get(box.glob.script, unpack(params)))
end
elseif prev == 'dlg_number' then
set_ctlmgr_values()
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
#dlg_pin.pinready .hideif_pinready,
#dlg_pin.pukneeded .hideif_pukneeded,
#dlg_pin.pinneeded .hideif_pinneeded,
#dlg_number.pinready .hideif_pinready,
#dlg_number.pukneeded .hideif_pukneeded,
#dlg_number.pinneeded .hideif_pinneeded,
#dlg_provider.providerneeded .hideif_providerneeded,
.hideif_nonumbers,
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
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
function initAccountHandler() {
var account = <?lua umts_html.write_accountlist_js(g_accounts) ?>;
var currAccount = jxl.getValue("uiAccount");
var values = inputValueStore("uiAccountContainer", account);
var hide = {"1&1 Internet": true};
function removeErrorClass() {
jxl.walkDom("uiAccountContainer", "input",
function(el){jxl.removeClass(el, "error");}
);
}
function onAccountChange(evt) {
values.save(currAccount);
currAccount = jxl.getValue("uiAccount");
values.restore(currAccount);
removeErrorClass();
jxl.disableNode("uiAccountContainer", currAccount || !jxl.getEnabled("uiAccount"));
jxl.display("uiAccountContainer", !hide[currAccount]);
}
onAccountChange();
jxl.addEventHandler("uiAccount", "change", onAccountChange);
jxl.addEventHandler("uiActivation:enabled", "click", onAccountChange);
jxl.addEventHandler("uiActivation:fallback", "click", onAccountChange);
jxl.addEventHandler("uiActivation:disabled", "click", onAccountChange);
}
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
jxl.enable("uiGotoStartcode");
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
elseif wizard.curr == 'dlg_provider' then
box.out("\n" .. [[
ready.onReady(initAccountHandler);
]])
elseif wizard.curr == 'dlg_modem_error' then
box.out("\n" .. [[
ready.onReady(initDlgErrorCheck);
]])
elseif wizard.curr == 'dlg_pin' then
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
{?457:554?}
</p>
<div class="formular">
<input id="uiConnectionDsl" type="radio" name="connection" value="dsl" <?lua conn.write_checked('dsl') ?>>
<label for="uiConnectionDsl">{?457:629?}</label>
<p class="hideif_umts form_input_explain">
<?lua write_dsl_explain() ?>
</p>
<br>
<input id="uiConnectionUmts" type="radio" name="connection" value="umts" <?lua conn.write_checked('umts') ?>>
<label for="uiConnectionUmts"><?lua write_antenna() ?></label>
<p class="hideif_dsl form_input_explain">
<?lua write_antenna_explain() ?>
</p>
</div>
</div>
<div id="dlg_modem_error">
<div id="uiWaitModemCheck">
<p class="waitimg" ><?lua write_txt("wait") ?></p>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<div id="uiModemError" style="display:none">
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<br>
<p><?lua write_txt("not_detected") ?></p>
<p><?lua write_txt("check_modem") ?></p>
</div>
<div id="uiSimreadError" style="display:none">
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<br>
<p>{?457:613?}</p>
<p><?lua write_txt("read_error") ?></p>
</div>
</div>
<div id="dlg_pin" class="<?lua pin.write_class() ?>">
<p class="hideif_pinready">
<?lua write_txt("sim") ?>
</p>
<?lua pin.write_puk_msg() ?>
<div class="formular hideif_pinready">
<div id="uiPukInput" class="hideif_pinneeded">
<label for="uiPuk">{?457:311?}</label>
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
</div>
<div id="dlg_number" class="<?lua msn.write_class() ?>">
<p class="hideif_pinneeded hideif_pukneeded <?lua msn.write_class()?>">
{?457:174?}
</p>
<p class="hideif_pinneeded hideif_pukneeded <?lua msn.write_class()?>">
{?457:532?}
</p>
<div class="hideif_pinneeded hideif_pukneeded <?lua msn.write_class()?>">
<div class="formular">
<label for="uiMsn">{?457:525?}</label>
<input type="text" name="msn" id="uiMsn"
value="<?lua msn.write_value() ?>"
<?lua msn.write_disabled() ?>
<?lua val.write_error_class(g_val, 'uiMsn') ?>>
<?lua val.write_html_msg(g_val, 'uiMsn') ?>
</div>
<div class="formular">
<label for="uiOkz">{?457:368?}</label>
<input type="text" name="okz" id="uiOkz"
value="<?lua okz.write_value() ?>"
<?lua okz.write_disabled() ?>
<?lua val.write_error_class(g_val, 'uiOkz') ?>>
<span class="form_input_explain postfix">{?457:680?}</span>
<?lua val.write_html_msg(g_val, "uiOkz") ?>
</div>
</div>
</div>
<div id="dlg_provider" class="<?lua dlg_provider.write_class()?>">
<?lua
if wizard.curr=="dlg_provider" then
umts_html.write_account(g_data,g_accounts)
end
?>
</div>
<div id="dlg_end">
<div id="uiWaitResult">
<p class="waitimg hideif_pincheck">{?457:567?}</p>
<p class="waitimg hideif_conncheck">{?457:367?}</p>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
</div>
<div class="formular checklist hideif_pincheck">
<p id="uiPinChecked">{?457:564?}</p>
<p id="uiConnChecked">{?457:471?}</p>
</div>
</div>
<div id="btn_form_foot">
<?lua wizard.write_buttons() ?>
</div>
<input type="hidden" id="uiStep" name="step" value="<?lua box.html(wizard.curr)?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<input type="hidden" id="uiPinError" name="pinerror" value="" disabled>
<input type="hidden" id="auto_forward" name="forward" value="" disabled>
<input type="hidden" id="uiGotoStartcode" name="gotostartcode" value="" disabled>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
