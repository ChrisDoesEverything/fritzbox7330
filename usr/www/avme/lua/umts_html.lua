--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require"general"
require"umts"
require"html"
function sep_string(separator, ...)
separator = separator or ""
local n = select('#', ...)
local result, s
for i = 1, n do
s = select(i, ...)
if s then
result = result and (result .. separator .. s) or s
end
end
return result
end
function quality_img()
local n = tonumber(umts.RSSI) or 0
if n > 0 then
n = math.min(5, 1 + math.floor(n / 20))
end
return html.img{
width = 26, height = 13,
src = "/css/default/images/umts_rssi" .. n .. ".gif",
title = n == 0 and [[<20]] or (n * 20)
}
end
function homezone_img()
if umts.InHomeZone == "1" then
return html.img{
width=16, height=16,
src="/css/default/images/umts_homezone.gif",
title=TXT([[{?6566:76?}]])
}
end
end
function connect_state()
local netstate = umts.networkstate()
local connected = box.query("connection0:status/connect") == "5"
local established = umts.Established == "1"
local txt = TXT([[{?6566:407?}]])
if umts.registered() then
if connected and established then
txt = TXT([[{?6566:701?}]])
elseif umts.registered("home") then
txt = TXT([[{?6566:758?}]])
elseif umts.registered("roamimg") then
txt = TXT([[{?6566:563?}]])
end
local str = {}
local act = umts.access_technology()
local inhomezone
if umts.InHomeZone == "1" then
inhomezone = TXT([[{?6566:206?}]])
end
txt = sep_string(", ", act, txt, inhomezone)
elseif netstate == "searching" then
txt = TXT([[{?6566:606?}]])
elseif netstate == "registration_denied" then
txt = TXT([[{?6566:766?}]])
end
return txt, connected and established
end
state_txt = setmetatable({
disabled = {
nomodem = TXT([[{?6566:549?}]]),
simproblem = TXT([[{?6566:703?}]]),
default = TXT([[{?6566:628?}]])
},
searching = TXT([[{?6566:111?}]]),
registration_denied = TXT([[{?6566:465?}]])
}, {
__index = func.const(TXT([[{?6566:577?}]]))
})
function get_pininfo()
local info = {}
local trycount = tonumber(umts.Trycount) or 0
local pinstate = umts.pinstate()
info.pinlabel = TXT([[{?6566:792?}]])
if umts.pin_ready() then
info.msg = TXT([[{?6566:225?}]])
elseif pinstate == "pinchecking" then
info.msg = TXT([[{?6566:451?}]])
info.disabled = true
elseif umts.pin_needed('PUK') then
info.pukcount = trycount
if trycount > 0 then
info.msg = TXT([[{?6566:872?}]])
info.pinlabel = TXT([[{?6566:856?}]])
else
info.msg = TXT([[{?6566:362?}]])
info.disabled = true
end
else
info.msg = TXT([[{?6566:899?}]])
if umts.pin_needed('PIN') then
info.pincount = trycount
elseif not umts.sim_ok() then
info.disabled = true
end
end
return info
end
local function get_account_select(data,accounts)
local index = table.keys(accounts)
utf8.sort(index)
local sel = html.select{name="account", id="uiAccount"}
for i, account in ipairs(index) do
sel.add(html.option{value=account, selected=data.account == account, account})
end
sel.add(html.option{value="", selected=data.account == "", TXT([[{?6566:352?}]])})
return sel
end
function write_account(data,accounts)
html.h4{TXT([[{?6566:968?}]])}.write()
html.p{TXT([[{?6566:804?}]])}.write()
html.div{class="formular disableif_umts:disabled",
--Betreiber
html.label{['for']="uiAccount", TXT([[{?6566:920?}]])},
get_account_select(data,accounts)
}.write()
html.div{id="uiAccountContainer", class="disableif_umts:disabled",
html.div{class="formular", id="uiProviderInput",
--Provider
html.label{['for']="uiProvider", TXT([[{?6566:986?}]])},
html.input{type="text", maxlength="128", id="uiProvider", name="provider", value=data.provider}
},
html.div{class="formular", id="uiNumberInput",
--Einwahlnummer
html.label{['for']="uiNumber", TXT([[{?6566:769?}]])},
html.input{type="text", maxlength="128", id="uiNumber", name="number", value=data.number}
},
html.div{class="formular", id="uiUsernameInput",
--Benutzername
html.label{['for']="uiUsername", TXT([[{?txtUsername?}]])},
html.input{type="text", maxlength="128", id="uiUsername", name="username", value=data.username}
},
html.div{class="formular", id="uiPasswordInput",
--Passwort
html.label{['for']="uiPassword", TXT([[{?txtKennwort?}]])},
html.input{type="text", maxlength="128", id="uiPassword", name="password", autocomplete="off", value=data.password}
}
}.write()
end
function account_validation(val)
val.msg.account = {
[val.ret.empty] = TXT([[{?2653:163?}]])
}
return [[
if __exists(uiAccount/account) then
if __value_empty(uiAccount/account) then
not_empty(uiProvider/provider, account)
not_empty(uiNumber/number, account)
end
end
]]
end
function write_accountlist_js(accounts)
if not accounts then
accounts={}
end
local list = {
[""] = {name="", provider="", number="", username="", password=""}
}
list = table.extend(list, accounts)
box.out(js.table(list))
end
