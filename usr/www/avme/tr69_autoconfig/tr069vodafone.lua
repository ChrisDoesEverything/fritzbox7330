<?lua
g_page_type = "wizard"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"wizard"
require"tr069"
require"general"
require"newval"
require"first"
require"js"
require"html"
require"isp"
local httpvar = setmetatable({post = box.post, get = box.get}, {
__index = function(self, key) return self.post[key] or self.get[key] end
})
wizard.wiztype = httpvar.wiztype
wizard.dialogs = {
'dlg_mic',
'dlg_provision',
'dlg_end'
}
wizard.title = setmetatable({
}, {__index = func.const([[{?179:922?}]])}
)
wizard.start = function()
return 'dlg_mic'
end
wizard.dlg_mic = {
forward = function() return 'dlg_mic' end,
backward = function() end
}
wizard.dlg_end = {
forward = function()
if wizard.wiztype == 'first' then
return 'dlg_end'
end
end,
backward = function() end
}
wizard.dlg_provision = {
forward = function() end,
backward = function() end
}
local function goto_fonwizard()
local page
local params = {}
if wizard.wiztype == 'first' or wizard.wiztype == 'umts' then
table.insert(params, http.url_param("first_wizard", "1"))
end
local use_pstn = box.query("telcfg:settings/UsePSTN") == "1"
if wizard.wiztype == 'umts' or not use_pstn then
page = "/assis/assi_fondevices_list.lua"
http.redirect(href.get(page, unpack(params)))
end
-- ab hier gehts zu assi_fon_nums
page = "/assis/assi_fon_nums.lua"
if use_pstn then
table.insert(params, http.url_param("configure", "pstn"))
else
table.insert(params, http.url_param("configure", "inet"))
end
table.insert(params, http.url_param("back_to_page", "/assis/assi_fondevices_list.lua"))
table.insert(params, http.url_param("pagemaster", "/home/home.lua"))
http.redirect(href.get(page, unpack(params)))
end
local function goto_wlanwizard()
local page = "/assis/wlan_first.lua"
local params = {}
table.insert(params, http.url_param("wiztype", wizard.wiztype or ""))
http.redirect(href.get(page, unpack(params)))
end
wizard.leave = function()
local dest = href.get("/home/home.lua")
if wizard.wiztype == 'dsl' then
dest = href.get("/assis/home.lua")
end
http.redirect(dest)
end
wizard.init = function()
wizard.curr = wizard.start()
if box.post.prevdlg and box.post.prevdlg ~= "" then
if box.post.forward then
wizard.curr = wizard[box.post.prevdlg].forward()
elseif box.post.backward then
wizard.curr = wizard[box.post.prevdlg].backward()
end
end
end
local function checksum_mic(mic, odd)
mic = mic or ""
local pattern = odd and [[(%d)%d]] or [[%d(%d)]]
local sum = 0
local isodd = true
for digit in mic:gmatch(pattern) do
digit = tonumber(digit)
if isodd then
digit = 2 * digit
if digit >= 10 then
digit = digit - 9
end
end
sum = sum + digit
isodd = not isodd
end
return sum % 10 == 0
end
local function mic_validation()
local txt1 = [[{?179:260?}]]
local txt2 = [[{?179:543?}]]
local txt3 = [[{?179:623?}]]
local addtxt = "\\n\\n" .. [[{?179:967?}]]
txt1 = txt1 .. addtxt
txt2 = txt2 .. addtxt
txt3 = txt3 .. addtxt
local mic = ""
for i = 0, 3 do
newval.msg["micerr" .. i] = {
[newval.ret.tooshort] = txt1,
[newval.ret.toolong] = txt1,
[newval.ret.outofrange] = txt2,
[newval.ret.format] = txt2
}
newval.length("mic" .. i, 5, 5, "micerr" .. i)
newval.char_range_regex("mic" .. i, "decimals", "micerr" .. i)
mic = mic .. box.post["mic" .. i]
end
newval.msg.micerr = {[newval.ret.wrong] = txt3}
if not checksum_mic(mic, true) or not checksum_mic(mic, false) then
newval.const_error("mic0,mic1,mic2,mic3", "wrong", "micerr")
end
end
function mic_convert(m0, m1, m2, m3)
if m0 and m1 and m2 and m3 then
local user = m0 .. m1
local pw = m2 .. m3
return user, pw
end
end
function mic_set_vars()
require"cmtable"
local saveset = {}
cmtable.add_var(saveset, "providerlist:settings/activeprovider", httpvar.provider)
local user, pass = mic_convert(box.post.mic0, box.post.mic1, box.post.mic2, box.post.mic3)
cmtable.add_var(saveset, "tr069:settings/username", user)
cmtable.add_var(saveset, "tr069:settings/password", pass)
local ch = isp.characteristics(httpvar.provider)
for webvar, value in pairs(ch) do
if webvar:find("tr069:settings/") ~= 1 and value ~= "" then
cmtable.add_var(saveset, webvar, value)
end
end
local c, e = box.set_config(saveset)
end
wizard.set_validation = function(dlg)
if dlg == 'dlg_mic' then
return mic_validation
end
end
local function build_provision_url()
local toptext = html.strong{
[[{?179:332?}]]
}
local bottomtext = html.p{
[[{?179:655?}]],
html.br{},
[[{?179:151?}]]
}
local url = "/internet/isp_change.lua"
local provcount = tonumber(httpvar.provcount) or 3
provcount = provcount - 1
local params = {
http.url_param("provcount", provcount),
http.url_param("prevdlg", "dlg_mic"),
http.url_param("query", "provision"),
http.url_param("pagetype", "wizard"),
http.url_param("pagemaster", box.glob.script),
http.url_param("title", wizard.title.provision),
http.url_param("toptext", toptext.get(true)),
http.url_param("bottomtext", bottomtext.get(true)),
http.url_param("poll", "10000"),
http.url_param("wiztype", wizard.wiztype or "")
}
table.insert(params, http.url_param("provider", httpvar.provider or ""))
return url .. "?" .. table.concat(params, "&")
end
local function ppp_notconnected()
require"opmode"
return opmode.is_ppp() and box.query("connection0:status/connect") == "3"
end
local function onquery_provision()
local answer = {}
local count = tonumber(box.get.addinfo) or 0
if not tr069.unprovisioned() then
answer.done = true
elseif count > 10 then
answer.done = true
answer.error = true
answer.errortype = "timeout"
elseif count > 3 and wizard.wiztype == 'first' then
if ppp_notconnected() then
answer.done = true
answer.error = true
answer.errortype = "configerr"
end
end
if not answer.done then
answer.addinfo = count + 1
end
return answer
end
if box.get.query == 'provision' then
local answer = onquery_provision()
box.out(js.table(answer))
box.end_page()
end
require("general")
if box.post.validate == "forward" then
local valprog = wizard.set_validation(box.post.prevdlg)
local valresult, answer = newval.validate(valprog)
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
wizard.leave()
elseif box.post.forward and httpvar.prevdlg == 'dlg_end' then
if box.post.onleave == "fonwizard" then
goto_fonwizard()
elseif box.post.onleave == "wlanwizard" then
goto_wlanwizard()
end
end
wizard.init()
if box.post.provcount then
wizard.curr = 'dlg_mic'
elseif httpvar.ispchangedone then
local err = httpvar.ispchangedone == "error"
if httpvar.prevdlg == 'dlg_mic' then
wizard.curr = err and 'dlg_provision' or 'dlg_end'
if not err or httpvar.provcount == "0" then
wizard.override_btntext("cancel", [[{?179:585?}]])
wizard.noconfirm_oncancel = true
end
end
end
if wizard.curr == 'dlg_mic' then
if box.post.forward and box.post.prevdlg == 'dlg_mic' then
local valprog = wizard.set_validation('dlg_mic')
if newval.validate(valprog) ~= newval.ret.ok then
wizard.curr = 'dlg_mic'
else
mic_set_vars()
local url = build_provision_url()
http.redirect(url)
end
end
end
if wizard.title then
g_page_title = wizard.title[wizard.curr]
end
function write_mic()
html.p{
[[{?179:420?}]]
}.write()
html.div{class="formular",
html.br{},
html.img{src="/css/default/images/mic.png", width="587", height="52",
title=[[{?179:965?}]]
},
html.br{}
}.write()
html.p{
[[{?179:4312?}]]
}.write()
html.div{class="formular", id="uiMic",
html.label{['for']="uiMic0",
[[ ]]
},
html.input{
type="text", name="mic0", id="uiMic0", size="6", maxlength="5", autocomplete="off",
value=box.post.mic0 or ""
},
html.span{[[ - ]]},
html.input{
type="text", name="mic1", id="uiMic1", size="6", maxlength="5", autocomplete="off",
value=box.post.mic1 or ""
},
html.span{[[ - ]]},
html.input{
type="text", name="mic2", id="uiMic2", size="6", maxlength="5", autocomplete="off",
value=box.post.mic2 or ""
},
html.span{[[ - ]]},
html.input{
type="text", name="mic3", id="uiMic3", size="6", maxlength="5", autocomplete="off",
value=box.post.mic3 or ""
}
}.write()
end
function write_end()
html.h4{[[{?179:666?}]]}.write()
html.p{
[[{?179:82?}]]
}.write()
if wizard.wiztype == 'first' then
html.hr{}.write()
html.h4{[[{?179:149?}]]}.write()
html.input{type="radio", name="onleave", id="uiOnleave:fonwizard", value="fonwizard"}.write()
html.label{['for']="uiOnleave:fonwizard",
[[{?179:542?}]]
}.write()
html.br{}.write()
html.input{type="radio", name="onleave", id="uiOnleave:wlanwizard", value="wlanwizard"}.write()
html.label{['for']="uiOnleave:wlanwizard",
[[{?179:252?}]]
}.write()
end
end
function write_provision_error()
local reason = [[{?179:7212?}]]
if ppp_notconnected() then
reason = box.query("connection0:pppoe:status/detail")
end
html.p{
[[{?179:972?}]],
html.div{class="formular", html.em{reason}}
}.write()
local provcount = tonumber(httpvar.provcount) or 0
if provcount > 0 then
html.p{
[[{?179:161?}]]
}.write()
html.div{class="btn_form",
html.button{id="uiProvcount", type="submit", name="provcount", value=tostring(provcount),
[[{?179:931?}]]
}
}.write()
end
html.p{
[[{?179:682?}]]
}.write()
end
function write_hidden_params()
html.input{type="hidden", name="provider", value=httpvar.provider or ""}.write()
if wizard.curr == 'dlg_mic' then
local provcount = tonumber(httpvar.provcount)
if provcount then
html.input{type="hidden", name="provcount", value=tostring(provcount)}.write()
end
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
<?lua wizard.write_css() ?>
div.btn_form button {
width: 300px;
}
</style>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/dialog.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript">
function initForwardEnable() {
wizard.disable("forward");
var radios = jxl.getFormElements("onleave");
function onRadio(evt) {
wizard.enable("forward");
var i = radios.length || 0;
while (i--) {
jxl.removeEventHandler(radios[i], "click", onRadio);
}
}
var i = radios.length || 0;
while (i--) {
jxl.addEventHandler(radios[i], "click", onRadio);
}
}
function initMic() {
fc.init("uiMic", 5, "", "uiForward");
jxl.focus("uiMic0");
}
<?lua
if wizard.curr == 'dlg_mic' then
box.out("\n", [[ready.onReady(initMic);]])
elseif wizard.curr == 'dlg_end' then
box.out("\n", [[ready.onReady(initForwardEnable);]])
end
?>
ready.onReady(ajaxValidation({
applyNames: "forward"
}));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>"
class="narrow <?lua wizard.write_class() ?>">
<?lua href.default_submit('forward') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<?lua write_hidden_params() ?>
<div id="dlg_mic">
<?lua write_mic() ?>
</div>
<div id="dlg_end">
<?lua write_end() ?>
</div>
<div id="dlg_provision">
<h4>
{?179:333?}
</h4>
<?lua write_provision_error() ?>
</div>
<div id="btn_form_foot">
<?lua wizard.write_buttons() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
