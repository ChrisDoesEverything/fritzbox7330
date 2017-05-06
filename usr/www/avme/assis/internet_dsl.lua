<?lua
-- de-first -begin
g_page_type = "wizard"
g_page_title = [[{?2759:509?}]]
dofile("../templates/global_lua.lua")
require"general"
require"cmtable"
require"newval"
require"http"
require"isp"
require"html"
require"authform"
require"js"
require"wizard"
require"isphtml"
require"opmode"
require"wlanscan"
--isp.exclude_providers(isp.is_oma)
--isp.exclude_providers(func.eq('oma_wlan'))
g_err = {}
g_var = {}
g_var = isp.read_all_post_vars()
do
if box.get.o2pin then
if config.oem == "otwo" then
g_var.provider = "o2_7270_native"
else
g_var.provider = "o2"
end
g_var.subprovider = "withpin"
elseif not g_var.provider and isp.is_other() then
g_var.provider = isp.initial_provider()
local medium = isp.initial_medium(g_var.provider)
g_var.subprovider = 'auth'
if medium == 'extern' then
g_var.medium = 'dsl'
end
end
end
g_var.provider = g_var.provider or isp.initial_provider()
g_var.medium = g_var.medium or isp.initial_medium(g_var.provider)
do
local dontpanic = array.truth{"tochoose", "tochoose2"}
if not (box.get.panic or dontpanic[g_var.provider] or isp.exists(g_var.provider)) then
local params = {
http.url_param("panic", "")
}
local wiztype = box.post.wiztype or box.get.wiztype or ""
if wiztype ~= "" then
table.insert(params, http.url_param("wiztye", wiztype))
end
http.redirect(box.glob.script .. "?" .. table.concat(params, "&"))
end
end
if box.get.wlanscan then
local opts = {
startscan = box.get.startscan,
stamac = box.get.stamac
}
local json_string = wlanscan.getjson(opts)
box.out(json_string)
box.end_page()
end
local conncheck_txt = {
[0] = [[{?2759:690?}]],
[8] = [[{?2759:704?}]],
[9] = [[{?2759:378?}]],
[10] = [[{?2759:607?}]],
[11] = [[{?2759:271?}]],
[12] = [[{?2759:337?}]],
[13] = [[{?2759:921?}]],
[14] = [[{?2759:595?}]],
[15] = [[{?2759:656?}]]
}
if box.get.query == 'conncheck' then
local answer = {}
answer.addinfo = 'running'
answer.pagetitle = [[{?2759:104?}]]
if box.get.addinfo ~= 'running' then
box.set_config({{name="connection0:settings/Check/Start", value="1"}})
answer.showhtml = html.p{conncheck_txt[8]}.get()
else
local status = box.query("connection0:status/Check/Status")
status = tonumber(status) or 10
answer.showhtml = html.p{conncheck_txt[status]}.get()
answer.done = status ~= 8
answer.error = status ~= 9
--answer.showresult = true
end
box.out(js.table(answer))
box.end_page()
elseif box.get.query == "poweroff" then
local answer = {}
answer.done = true
answer.showresult = true
answer.pagetitle = [[{?2759:547?}]]
answer.showhtml = html.p{
[[{?2759:385?}]]
}.get()
box.out(js.table(answer))
box.end_page()
end
function write_end_result()
local ispchangedone = box.get.ispchangedone or box.post.ispchangedone
local withconncheck = box.get.withconncheck or box.post.withconncheck
if ispchangedone then
local imgsrc, txt
if ispchangedone == "error" then
local state
if withconncheck then
state = box.query("connection0:status/Check/Status")
state = tonumber(state) or 10
wizard.disable_button("forward")
wizard.nocancel = false
end
imgsrc = "/css/default/images/finished_error.gif"
txt = state and conncheck_txt[state]
or [[{?2759:667?}]]
else
imgsrc = "/css/default/images/finished_ok_green.gif"
txt = withconncheck and conncheck_txt[9]
or [[{?2759:247?}]]
end
html.div{class="wait",
html.p{class="waitimg", html.img{src=imgsrc}},
html.p{txt}
}.write()
end
end
local function do_poweroff()
return false
end
local function do_ipchange()
return general.boxip_isdefault()
and isp.is_oma(g_var.provider)
end
local function build_change_isp_url()
local url = "/internet/isp_change.lua"
local params = {
http.url_param("pagetype", "wizard"),
http.url_param("pagemaster", box.glob.script)
}
if do_ipchange() then
url = "/networkchange.lua"
params = {
http.url_param("ifmode", "oma"),
http.url_param("newipaddr", "192.168.188.1"),
}
else
if wizard.wiztype then
table.insert(params, http.url_param("wiztype", wizard.wiztype))
end
if wizard.wiztype ~= 'first' then
table.insert(params, http.url_param("nologo", ""))
end
local queries
if do_poweroff() then
queries = "poweroff"
table.insert(params, http.url_param("button", "wizard"))
elseif box.post.conncheck then
queries = "conncheck"
table.insert(params, http.url_param("withconncheck", ""))
end
if queries then
table.insert(params, http.url_param("query", queries))
end
end
return url .. "?" .. table.concat(params, "&")
end
wizard.dialogs = {
'dlg_welcome',
'dlg_provider',
'dlg_medium',
'dlg_freelan1',
'dlg_auth',
'dlg_speed',
'dlg_connectlan1',
'dlg_wlanscan',
'dlg_wlansecurity',
'dlg_summary',
'dlg_end'
}
wizard.show = array.truth(wizard.dialogs)
do
wizard.show.dlg_provider = isp.count() > 1
wizard.show.dlg_auth = false
if isp.is_other(g_var.provider) then
wizard.show.dlg_auth = g_var.medium == 'dsl'
elseif isp.auth_needed(g_var.provider) then
local auth = isp.auth_defaults(g_var.provider)
wizard.show.dlg_auth = auth.username == "" or auth.pwd == ""
end
wizard.show.dlg_speed = false
if isp.is_other(g_var.provider) then
wizard.show.dlg_speed = g_var.medium == 'cable'
elseif isp.speed_needed(g_var.provider) then
local defaults = isp.speed_defaults(g_var.provider)
wizard.show.dlg_speed = defaults.ManualDSLSpeed == "1"
end
wizard.show.dlg_connectlan1 = false
if isp.is_other(g_var.provider) then
if g_var.medium ~= 'dsl' then
wizard.show.dlg_connectlan1 = true
end
elseif not isp.is_dsl(g_var.provider) then
wizard.show.dlg_connectlan1 = true
end
wizard.show.dlg_wlanscan = false
wizard.show.dlg_wlansecurity = false
if isp.is('oma_wlan', g_var.provider) then
wizard.show.dlg_connectlan1 = false
wizard.show.dlg_wlanscan = true
wizard.show.dlg_wlansecurity = true
end
end
wizard.title = {
dlg_welcome = [[{?2759:450?}]]
}
do
if isp.is("o2", g_var.provider) then
wizard.title.dlg_auth = [[{?2759:477?}]]
wizard.title.dlg_summary = [[{?2759:622?}]]
end
end
wizard.start = function()
if box.get.panic then
return 'dlg_provider'
end
if box.get.ispchangedone or box.post.ispchangedone then
return 'dlg_end'
end
if box.get.o2pin then
return 'dlg_auth'
end
if wizard.wiztype == "first" then
return 'dlg_welcome'
end
return wizard.dlg_welcome.forward()
end
wizard.dlg_welcome = {
forward = function()
if wizard.show.dlg_provider then
return 'dlg_provider'
else
return wizard.dlg_provider.forward()
end
end,
backward = function() end
}
wizard.dlg_provider = {
forward = function()
if isp.is('oma_wlan', g_var.provider) then
return 'dlg_wlanscan'
end
if isp.is_other(g_var.provider) then
return 'dlg_medium'
end
if not isp.is_dsl(g_var.provider) then
return 'dlg_freelan1'
end
if wizard.show.dlg_auth then
return 'dlg_auth'
end
if wizard.show.dlg_speed then
return 'dlg_speed'
end
return 'dlg_summary'
end,
backward = function()
if wizard.wiztype == "first" then
return 'dlg_welcome'
end
end
}
wizard.dlg_medium = {
forward = function()
-- hier ist provider auf jeden Fall other!
if g_var.medium ~= 'dsl' then
return 'dlg_freelan1'
end
if wizard.show.dlg_auth then
return 'dlg_auth'
end
if wizard.show.dlg_speed then
return 'dlg_speed'
end
if wizard.show.dlg_connectlan1 then
return 'dlg_connectlan1'
end
return 'dlg_summary'
end,
backward = function()
if wizard.show.dlg_provider then
return 'dlg_provider'
end
return wizard.dlg_provider.backward()
end
}
wizard.dlg_freelan1 = {
forward = function()
if wizard.show.dlg_auth then
return 'dlg_auth'
end
if wizard.show.dlg_speed then
return 'dlg_speed'
end
if wizard.show.dlg_connectlan1 then
return 'dlg_connectlan1'
end
return 'dlg_summary'
end,
backward = function()
if isp.is_other(g_var.provider) then
return 'dlg_medium'
end
return wizard.dlg_medium.backward()
end
}
wizard.dlg_auth = {
forward = function()
if wizard.show.dlg_speed then
return 'dlg_speed'
end
if wizard.show.dlg_connectlan1 then
return 'dlg_connectlan1'
end
return 'dlg_summary'
end,
backward = function()
if isp.is_other(g_var.provider) then
return 'dlg_medium'
end
return wizard.dlg_medium.backward()
end
}
wizard.dlg_speed = {
forward = function()
if wizard.show.dlg_connectlan1 then
return 'dlg_connectlan1'
end
return 'dlg_summary'
end,
backward = function()
if wizard.show.dlg_auth then
return 'dlg_auth'
end
return wizard.dlg_auth.backward()
end
}
wizard.dlg_summary = {
forward = function()
if box.post.ratechanged then
return 'dlg_summary'
end
return 'dlg_summary'
end,
backward = function()
if wizard.show.dlg_wlansecurity then
-- TODO: besser wlanscan?
return 'dlg_wlansecurity'
end
if wizard.show.dlg_connectlan1 then
return 'dlg_connectlan1'
end
if wizard.show.dlg_speed then
return 'dlg_speed'
end
return wizard.dlg_speed.backward()
end
}
wizard.dlg_connectlan1 = {
forward = function()
return 'dlg_summary'
end,
backward = function()
if wizard.show.dlg_speed then
return 'dlg_speed'
end
return wizard.dlg_speed.backward()
end
}
wizard.dlg_wlanscan = {
forward = function()
return 'dlg_wlansecurity'
end,
backward = function()
if wizard.show.dlg_provider then
return 'dlg_provider'
end
return wizard.dlg_provider.backward()
end
}
wizard.dlg_wlansecurity = {
forward = function()
return 'dlg_summary'
end,
backward = function()
return 'dlg_wlanscan'
end
}
wizard.dlg_end = {
forward = function()
return 'dlg_end'
end,
backward = function()
return wizard.dlg_summary.backward()
end
}
wizard.init = function()
wizard.wiztype = box.post.wiztype or box.get.wiztype
wizard.curr = wizard.start()
if box.post.prevdlg and box.post.prevdlg ~= "" then
if box.post.forward then
wizard.curr = wizard[box.post.prevdlg].forward()
elseif box.post.backward then
wizard.curr = wizard[box.post.prevdlg].backward()
end
end
if wizard.title then
g_page_title = wizard.title[wizard.curr] or g_page_title
end
if wizard.wiztype ~= "first" then
if wizard.curr == 'dlg_end' then
wizard.nocancel = true
end
end
end
wizard.do_apply = function()
if wizard.curr == 'dlg_summary' then
if box.post.prevdlg == 'dlg_summary' and not box.post.ratechanged then
return true
end
end
return false
end
function write_oma_explain()
if wizard.curr == 'dlg_provider' then
for i, p in ipairs{'oma_lan', 'oma_wlan'} do
if not isp.is_excluded(p) then
local explain = isphtml.get_provider_explain(p)
if explain then
html.div{class="showif_" .. p, explain}.write()
end
end
end
end
end
function write_excluded_hint()
if isp.is_excluded() then
html.div{class="formular",
html.strong{[[{?txtHinweis?}]]},
html.p{
general.sprintf(
[[{?2759:97?}]],
isp.providername()
)
}
}.write()
end
end
function write_havestartcode()
if config.TR069 then
local ab_count_gt0 = config.AB_COUNT and config.AB_COUNT > 0
if not config.FON or config.CAPI_TE or config.POTS or ab_count_gt0 then
local name = "havestartcode"
local id = "uiHavestartcode"
local checked = box.post.havestartcode ~= nil
if wizard.curr == 'dlg_provider' then
if isp.unconfigured() then
html.div{class="formular showif_ui",
html.input{type="checkbox", id=id, name=name, value="", checked=checked},
html.label{['for']=id,
[[{?2759:873?}]]
},
html.p{class="form_checkbox_explain",
[[{?2759:588?}]],
html.br{},
[[{?2759:577?}]]
}
}.write()
else
html.div{class="formular showif_ui",
html.strong{[[{?txtHinweis?}]]},
html.p{
[[{?2759:836?}]]
}
}.write()
end
elseif isp.is_ui(g_var.provider) and checked then
html.input{type="hidden", name=name, value=""}.write()
end
end
end
end
function write_subprovider_radioname_js(provider)
box.out(js.object({
[provider] = authform.subprovider_radioname(provider)
}))
end
function write_first_input_id_js()
box.out(js.quoted(isp.html_id(authform.get_first_inputname(g_var.provider, g_var.subprovider))))
end
function write_isps_classnames_js()
local str = {}
for p in isp.providers() do
table.insert(str, "isp_" .. p)
end
table.insert(str, "isp_tochoose")
table.insert(str, "isp_tochoose2")
table.insert(str, "isp_mobil")
box.js(table.concat(str, " "))
end
function write_super_list_js()
local list = table.clone(isp.get_super_list())
for k, v in pairs(list) do
list[k].txt = nil
list[k].listlevel = nil
end
box.out(js.table(list))
end
function write_super_classnames_js()
local str = {}
for i, super in ipairs(isp.get_superproviders()) do
if tonumber(super) then
table.insert(str, "super_" .. super)
end
end
table.insert(str, "super_")
box.js(table.concat(str, " "))
end
function write_initial_class()
local classes = isp.initial_classes(g_var.provider)
local sub = g_var.subprovider
if sub then
table.insert(classes, "sub_" .. sub)
end
table.insert(classes, "")
box.out(table.concat(classes, " "))
end
function write_isp_css(provider)
local selectors = {}
for p in isp.providers() do
if provider and p ~= provider then
table.insert(selectors, ".isp_" .. provider .. " .showif_" .. p)
end
if not isp.is_ui(p) then
table.insert(selectors, ".isp_" .. p .. " .showif_ui")
end
if p ~= 'other' then
table.insert(selectors, ".isp_" .. p .. " .showif_other")
end
if not isp.is_oma(p) then
table.insert(selectors, ".isp_" .. p .. " .showif_oma_lan")
table.insert(selectors, ".isp_" .. p .. " .showif_oma_wlan")
end
end
table.insert(selectors, ".isp_oma_lan .showif_oma_wlan")
table.insert(selectors, ".isp_oma_wlan .showif_oma_lan")
table.insert(selectors, ".isp_tochoose" .. " .showif_ui")
table.insert(selectors, ".isp_tochoose2" .. " .showif_ui")
table.insert(selectors, ".isp_tochoose" .. " .showif_other")
table.insert(selectors, ".isp_tochoose2" .. " .showif_other")
table.insert(selectors, ".isp_tochoose" .. " .showif_oma_lan")
table.insert(selectors, ".isp_tochoose" .. " .showif_oma_wlan")
table.insert(selectors, ".isp_tochoose2" .. " .showif_oma_lan")
table.insert(selectors, ".isp_tochoose2" .. " .showif_oma_wlan")
table.insert(selectors, ".isp_oma_lan .hideif_oma_lan")
table.insert(selectors, ".isp_oma_wlan .hideif_oma_wlan")
box.out("\n",
table.concat(selectors, ",\n"),
" {\n display: none;\n}"
)
end
function write_super_css()
local selectors = {}
local fmt = [[.super_%s .super_%s]]
for _, super1 in ipairs(isp.get_superproviders()) do
table.insert(selectors, fmt:format("", super1))
for _, super2 in ipairs(isp.get_superproviders()) do
if tonumber(super1) and super1 ~= super2 then
table.insert(selectors, fmt:format(super2, super1))
end
end
end
box.out("\n",
table.concat(selectors, ",\n"),
" {\n display: none;\n}"
)
end
function write_medium()
local div
if isp.is_other(g_var.provider) then
div = isphtml.get_medium(g_var.provider, {noheading=true, exclude_extern=true})
end
if div then
div.write()
else
local m = isp.initial_medium(g_var.provider)
local name = isp.html_name('medium', g_var.provider)
local id = isp.html_id(name, m)
html.input{
type="radio", id=id, name=name, value=m, checked=true, style="display:none;"
}.write()
end
end
function write_freelan1()
local txt = {"", ""}
if isp.is_other(g_var.provider) or isp.is_cable(g_var.provider) then
txt[1] = html.raw(general.sprintf(
box.tohtml([[{?2759:325?}]]),
[[<strong>]], [[</strong>]]
))
else
txt[1] = html.raw(general.sprintf(
box.tohtml([[{?2759:6992?}]]),
[[<strong>]], [[</strong>]]
))
end
if config.ETH_COUNT and config.ETH_COUNT > 1 then
txt[2] = [[{?2759:233?}]]
elseif config.WLAN then
txt[2] = [[{?2759:731?}]]
end
html.ul{class="hintlist",
html.li{txt[1]}, html.li{txt[2]}
}.write()
end
function write_connectlan1()
local txt = {"", ""}
if isp.is_other(g_var.provider) or isp.is_cable(g_var.provider) then
txt[1] = [[{?2759:858?}]]
txt[2] = [[{?2759:428?}]]
else
txt[1] = [[{?2759:2032?}]]
txt[2] = [[{?2759:790?}]]
end
html.ul{class="hintlist",
html.li{txt[1]}, html.li{txt[2]}
}.write()
end
function write_wlanscan()
local options = {
show_scan = box.post.forward ~= nil,
noheading = true,
vars = g_var
}
local html_elem = isphtml.get_wlanscan(g_var.provider, options)
if html_elem then html_elem.write() end
end
function write_wlansecurity()
html_elem = isphtml.get_wlansecurity(g_var.provider, {noheading=true, vars=g_var})
if html_elem then html_elem.write() end
end
function write_authform_head()
if isp.is("o2", g_var.provider) then
html.p{
[[{?2759:279?}]]
}.write()
else
html.p{
[[{?2759:976?}]]
}.write()
html.div{class="formular",
html.span{class="label", [[{?2759:914?}]]},
html.span{class="output", isp.providername(g_var.provider)}
}.write()
end
end
function write_authform()
local options = {noheading=true}
if g_var.subprovider then
options.initial_subprovider = g_var.subprovider
if isp.is_other(g_var.provider) and g_var.subprovider == "auth" then
options.subprovider = g_var.subprovider
local name = isp.html_name('subprovider', g_var.provider)
local id = isp.html_id(name, g_var.subprovider)
html.input{
type="radio", name=name, id=id,
value=g_var.subprovider, checked=true, style="display:none;"
}.write()
end
end
if isp.is("o2", g_var.provider) then
options.noexplain = true
end
local div = isphtml.get_auth(g_var.provider, options)
if div then
div.write()
end
end
function write_speed()
local options = {noheading=true}
local div = isphtml.get_speed(g_var.provider, options)
if div then div.write() end
end
function write_rate()
local rate_label = {
lcp = [[{?2759:868?}]],
on_demand = [[{?2759:860?}]]
}
local rate_explain = {
lcp = [[{?2759:361?}]],
on_demand = [[{?2759:700?}]]
}
if isp.connmode_needed(g_var.provider) or isp.is_other(g_var.provider) and g_var.medium == 'dsl' then
local val = isp.initial_connmode(g_var.provider)
html.p{
[[{?2759:947?}]]
}.write()
local name = isp.html_name("connmode", g_var.provider)
local id, label_txt, explain_txt
for i, value in ipairs{"lcp", "on_demand"} do
id = isp.html_id(name, value)
html.div{class="formular",
html.input{type="radio", name=name, id=id,
value=value, checked=value == val.mode
},
html.label{["for"]=id, rate_label[value]},
html.p{class="form_checkbox_explain", rate_explain[value]}
}.write()
end
end
end
function write_hidden_params()
local vars = {
optype = isp.initial_optype(g_var.provider)
}
local tmp = isp.initial_prevention(g_var.provider)
if tmp.Enabled == "1" then
vars.useprevention = tmp.Enabled
vars.prevention = tmp.Hour
end
for name, value in pairs(vars) do
html.input{
type="hidden", name=isp.html_name(name, g_var.provider), value=value
}.write()
end
if wizard.curr == 'dlg_summary' then
html.input{type="hidden", name="ratechanged", id="uiRatechanged", disabled=true}.write()
end
end
local function get_rate_info()
local result = ""
local show_rate = false
if isp.is_other(g_var.provider) then
show_rate = g_var.medium ~= 'cable'
else
show_rate = isp.connmode_needed(g_var.provider)
end
if show_rate then
local txt = {
on_demand = [[{?2759:147?}]],
lcp = [[{?2759:66?}]]
}
local val = isp.initial_connmode(g_var.provider)
local msg=txt[val.mode] or tostring(val.mode)
result = general.sprintf(msg, val.idle or "")
end
return result
end
local function get_medium_info()
local txt = {
dsl = [[{?2759:672?}]],
cable = [[{?2759:489?}]],
extern = [[{?2759:916?}]],
wlan = [[{?2759:1324?}]],
}
if isp.is_other(g_var.provider) then
return txt[g_var.medium]
elseif isp.is_cable(g_var.provider) then
return txt.cable
elseif isp.is_dsl(g_var.provider) then
return txt.dsl
elseif isp.is('oma_wlan', g_var.provider) then
return txt.wlan
else
return txt.extern
end
end
local function get_user_info()
local username, txt
if isp.is_other(g_var.provider) and g_var.medium == 'dsl'
or isp.auth_needed(g_var.provider) then
username = authform.read_user_pass(g_var.provider)
if not username then
local auth = isp.auth_defaults(g_var.provider)
username = auth and auth.username or ""
end
txt = authform.get_label_txt('user', g_var.provider, g_var.subprovider)
if not txt then
txt = authform.get_label_txt('pin', g_var.provider, g_var.subprovider)
if txt and g_var.pin ~= "****" then
username = g_var.pin or ""
else
username = ""
end
end
end
return username, txt
end
function write_summary_tbl()
local new_opmode = isphtml.save_opmode({}, g_var)
local tbl = html.table{class="zebra summary"}
tbl.add(html.tr{
html.td{[[{?2759:88?}]]},
html.td{get_medium_info()}
})
tbl.add(html.tr{
html.td{[[{?2759:360?}]]},
html.td{isp.providername(g_var.provider)}
})
local user, txt = get_user_info()
if txt and user ~= "" then
tbl.add(html.tr{
html.td{txt},
html.td{user}
})
end
txt = isphtml.get_encaps_txt(new_opmode)
if txt and txt ~= "" then
tbl.add(html.tr{
html.td{[[{?2759:755?}]]},
html.td{txt}
})
end
local rate = get_rate_info()
if rate ~= "" then
local ratelink
if wizard.curr == 'dlg_summary' then
ratelink = html.a{id="uiRateLink", class="nocancel", href=" ", [[{?2759:221?}]]}
end
tbl.add(html.tr{
html.td{[[{?2759:449?}]]},
html.td{rate, ratelink}
})
end
local show_ip = false
if isp.is_other(g_var.provider) then
show_ip = g_var.medium ~= 'dsl'
elseif not isp.is_dsl(g_var.provider) or new_opmode == 'opmode_ether' then
show_ip = true
end
if show_ip then
tbl.add(html.tr{
html.td{[[{?2759:497?}]]},
html.td{[[{?2759:219?}]]}
})
tbl.add(html.tr{
html.td{[[{?2759:188?}]]},
html.td{[[{?2759:82?}]]}
})
end
html.div{class="formular", tbl}.write()
end
function write_conncheck()
local checked = box.post.conncheck ~= nil
if not checked then
checked = array.truth{'dlg_welcome', 'dlg_provider', 'dlg_medium', 'dlg_auth'}[wizard.curr]
end
if wizard.curr == 'dlg_summary' then
html.p{
[[{?2759:9749?}]]
}.write()
html.div{
html.input{type="checkbox", id="uiConncheck", name="conncheck", checked=checked, value=""},
html.label{['for']="uiConncheck",
html.strong{
[[{?2759:1341?}]]
}
}
}.write()
elseif checked then
html.input{type="hidden", id="uiConncheck", name="conncheck", value=""}.write()
end
end
function write_crashreport()
if wizard.wiztype == "first" then
local checked = box.query("emailnotify:settings/crashreport_mode") ~= "disabled_by_user"
html.hr{}.write()
html.h4{
[[{?2759:189?}]]
}.write()
html.div{class="formular",
html.input{
type="checkbox", name="crashreport", id="uiCrashreport", checked=checked
},
html.label{['for']="uiCrashreport",
[[{?2759:674?}]]
},
html.p{class="form_checkbox_explain",
[[{?2759:708?}]]
}
}.write()
end
end
function write_welcome_explain()
local txt = [[{?2759:543?}]]
local ab_count_gt0 = config.AB_COUNT and config.AB_COUNT > 0
if config.FON and (config.CAPI_TE or config.POTS or ab_count_gt0 or config.FON_IPPHONE) then
txt = [[{?2759:865?}]]
end
html.p{txt}.write()
end
function write_add_buttons()
if wizard.curr == 'dlg_welcome' then
if config.oem == "1und1" and config.TR069 and isp.unconfigured() then
html.button{type="submit", name="autoconfig", id="uiAutoconfig",
[[{?2759:673?}]]
}.write()
end
end
end
function write_ratecancel()
if wizard.curr == 'dlg_summary' then
html.button{type="button", name="ratecancel", id="uiRatecancel", style="display:none;",
[[{?txtCancel?}]]
}.write()
end
end
function write_btntxt_js()
box.out(js.table{
ok = [[{?txtOK?}]],
forward = [[{?txtNextGreaterThan?}]]
})
end
function write_error()
if box.get.panic and wizard.curr == 'dlg_provider' then
html.div{class="LuaSaveVarError",
html.p{
[[{?2759:556?}]]
}
}.write()
end
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
--------------------------------------------------------------------
-- Validation Funktionen
--------------------------------------------------------------------
function write_wan_confirm_params()
local result = {needed={}}
local over_lan1 = array.truth{'opmode_eth_pppoe', 'opmode_eth_ip', 'opmode_eth_ipclient'}
if not over_lan1[box.query("box:settings/opmode")] then
if wizard.curr == 'dlg_medium' then
-- nur other
if isp.is_other(g_var.provider) then
result.needed[g_var.provider] = true
end
elseif wizard.curr == 'dlg_provider' then
-- nur provider over lan1
for p in isp.providers() do
if isp.over_lan1(p) then
result.needed[p] = true
end
end
end
end
if next(result.needed) then
result.msg = isphtml.wan_confirm_txt()
end
box.out(js.table(result))
end
local opmode_check = {
opmode_standard = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoe = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoa = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_pppoa_llc = array.truth{'auth', 'connmode', 'vlan', 'atm', 'speed'},
opmode_ether = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_eth_pppoe = array.truth{'auth', 'connmode', 'vlan', 'speed'},
opmode_eth_ip = array.truth{'auth', 'speed', 'vlan', 'ipsetting', 'mac'},
opmode_eth_ipclient = array.truth{'auth', 'speed', 'ipsetting'},
opmode_wlan_ip = array.truth{'wlanscan'},
opmode_ipnlpid = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_ipsnap = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
opmode_ipraw = array.truth{'vlan', 'atm', 'ipsetting', 'speed'},
}
local function set_ctlmgr_values()
local saveset = {}
isphtml.save_provider(saveset, g_var)
local new_opmode = isphtml.save_opmode(saveset, g_var)
isphtml.save_auth(saveset, g_var)
local nocheck = not isp.is_other(g_var.provider)
if nocheck or opmode_check[new_opmode].connmode then
isphtml.save_connmode(saveset, g_var)
end
if nocheck or opmode_check[new_opmode].speed then
isphtml.save_speed(saveset, g_var)
end
isphtml.save_oma_ipsetting(saveset, g_var)
isphtml.save_wlanscan(saveset, g_var)
isphtml.save_guiflag(saveset, g_var)
isphtml.save_specials(saveset, g_var)
g_err.code, g_err.msg = box.set_config(saveset)
end
local function set_crashreport()
if wizard.wiztype == "first" then
box.set_config({{
name = "emailnotify:settings/crashreport_mode",
value = box.post.crashreport and "to_support_only" or "disabled_by_user"
}})
end
end
wizard.init()
if box.post.autoconfig then
http.redirect("tr69_autoconfig/tr069startcode.lua")
end
if box.post.forward and box.post.prevdlg == 'dlg_provider' then
if isp.is_vodafone_bytr069(g_var.provider) then
http.redirect("/tr69_autoconfig/tr069vodafone.lua"
.. "?" .. http.url_param("wiztype", box.post.wiztype or "dsl")
.. "&" .. http.url_param("provider", g_var.provider)
)
elseif isp.is_ui(g_var.provider) and box.post.havestartcode then
local saveset = {}
cmtable.add_var(saveset, "tr069:settings/enabled", "1")
if config.oem ~= "1und1" then
cmtable.add_var(saveset, "tr069:settings/provcode", "000.000.000.000")
cmtable.add_var(saveset, "tr069:settings/url", "https://acs1.online.de/")
end
local err, msg = box.set_config(saveset)
http.redirect("/tr69_autoconfig/tr069startcode.lua?" .. http.url_param("wiztype", "dsl"))
end
end
local validation
if box.post.forward or box.post.validate == "forward" then
if box.post.prevdlg == 'dlg_provider' then
validation = function() isphtml.noprovider_validation() end
elseif box.post.prevdlg == 'dlg_auth' then
validation = function() authform.validation(g_var.provider) end
elseif box.post.prevdlg == 'dlg_speed' then
validation = function() isphtml.speed_validation(g_var.provider) end
elseif box.post.prevdlg == 'dlg_wlanscan' then
validation = function() isphtml.wlanscan_validation(g_var.provider) end
elseif box.post.prevdlg == 'dlg_wlansecurity' then
validation = function() isphtml.wlansecurity_validation(g_var.provider) end
else
validation = function() end
end
if box.post.validate == "forward" then
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if newval.validate(validation) ~= newval.ret.ok then
wizard.curr = box.post.prevdlg
end
end
if wizard.curr == 'dlg_provider' then
validation = function() isphtml.noprovider_validation() end
elseif wizard.curr == 'dlg_auth' then
validation = function() authform.validation(g_var.provider) end
elseif wizard.curr == 'dlg_speed' then
validation = function() isphtml.speed_validation(g_var.provider) end
elseif box.post.prevdlg == 'dlg_wlanscan' then
validation = function() isphtml.wlanscan_validation(g_var.provider) end
elseif box.post.prevdlg == 'dlg_wlansecurity' then
validation = function() isphtml.wlansecurity_validation(g_var.provider) end
else
validation = function() end
end
if box.post.cancel then
wizard.leave()
end
if box.post.forward and wizard.curr == 'dlg_end' then
if wizard.wiztype == "first" then
if box.post.prevdlg == 'dlg_end' then
set_crashreport()
end
http.redirect(href.get("/fon_num/fon_num_list.lua",
http.url_param("fonNumMode", "asfirst")
))
else
wizard.leave()
end
end
if wizard.do_apply() then
local url = build_change_isp_url()
set_ctlmgr_values()
http.redirect(url)
else
--
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<link rel="stylesheet" type="text/css" href="/css/default/wds.css">
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
margin-right: 6px;
}
.formular span.output {
width: 250px;
}
<?lua wizard.write_css() ?>
div.doubleselect select {
width: 250px;
}
div.doubleselect select.secondselect {
margin-top: 5px;
}
div.doubleselect select.secondselect.invisible {
visibility: hidden;
}
table.summary tr td:first-child {
width: 150px;
}
<?lua write_super_css() ?>
<?lua write_isp_css(g_var.provider) ?>
<?lua authform.write_subprovider_css(g_var.provider) ?>
#dlg_speed div.formular:first-child {
padding-left: 0px;
}
.isp_oma_lan.ipchange .hideif_ipchange,
.isp_oma_wlan.ipchange .hideif_ipchange {
display: none;
}
<?lua wizard.write_1und1_logo_css(wizard.wiztype ~= "first") ?>
</style>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript" src="/js/dialog.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/wlanscan.js"></script>
<script type="text/javascript">
function confirmNoStartcode() {
var ui = {"1und1": true, "gmx": true};
if (jxl.get("uiHavestartcode") && ui[jxl.getRadioValue("provider")]) {
if (!jxl.getChecked("uiHavestartcode")) {
var confirmNoStartcodeTxt = [
"{?2759:480?}",
"{?2759:105?}"
].join("\n\n");
if (!confirm(confirmNoStartcodeTxt)) {
return false;
}
}
}
}
function doWanConfirm() {
var params = <?lua write_wan_confirm_params() ?>;
var isp = jxl.getRadioValue("provider");
if (params.needed[isp]) {
var medium = jxl.getRadioValue("medium:" + isp);
var msg;
if (medium != "dsl") {
msg = params.msg;
}
if (msg && !confirm(msg)) {
return false;
}
}
}
var gProvider = "<?lua box.js(g_var.provider) ?>";
function initProvider() {
var superList = <?lua write_super_list_js() ?>;
var allSuperClasses = "<?lua write_super_classnames_js() ?>";
var allIspClasses = "<?lua write_isps_classnames_js() ?>";
function onProvider(isp) {
jxl.removeClass("uiMainform", allIspClasses);
jxl.addClass("uiMainform", "isp_" + isp);
}
function onProviderClick(evt) {
var radio = jxl.evtTarget(evt);
onProvider(radio.value);
}
function onSuperprovider(sup) {
var newClass = "super_";
var provider = sup;
if (Number(sup)) {
newClass += sup;
provider = superList[sup][0].id;
}
jxl.removeClass("uiMainform", allSuperClasses);
jxl.addClass("uiMainform", newClass);
jxl.setChecked("uiProvider:" + provider);
onProvider(provider);
}
initDoubleSelect('superprovider', 'more', onSuperprovider);
onProvider(gProvider);
var radios = jxl.getFormElements("provider");
var i = radios.length || 0;
while (i--) {
jxl.addEventHandler(radios[i], "click", onProviderClick);
}
}
function initAuthform() {
var handler = initSubproviderHandlers(
"uiMainform",
{<?lua write_subprovider_radioname_js(g_var.provider) ?>}
);
if (handler[gProvider]) {
handler[gProvider].start();
}
var toFocus = <?lua write_first_input_id_js() ?>;
if (toFocus) {
jxl.focus(toFocus);
}
}
function initSummary() {
var origChecked = "uiConnmode:" + gProvider + "::on_demand";
if (!jxl.getChecked(origChecked)) {
origChecked = "uiConnmode:" + gProvider + "::lcp";
}
var btnTxt = <?lua write_btntxt_js() ?>
function onClickRateLink(evt) {
jxl.hide("uiSummary");
jxl.show("uiRate");
jxl.enable("uiRatechanged");
wizard.rename("forward", btnTxt.ok);
wizard.hide("backward");
wizard.hide("cancel");
jxl.show("uiRatecancel");
return jxl.cancelEvent(evt);
}
function onCancelRate(evt) {
jxl.setChecked(origChecked);
jxl.show("uiSummary");
jxl.hide("uiRate");
jxl.disable("uiRatechanged");
wizard.rename("forward", btnTxt.forward);
wizard.show("backward");
wizard.show("cancel");
jxl.hide("uiRatecancel");
}
jxl.addEventHandler("uiRateLink", "click", onClickRateLink);
jxl.addEventHandler("uiRatecancel", "click", onCancelRate);
}
var sort;
function initWlanscan() {
sort = sorter();
wlanscanOnload({
url: "<?lua box.js(box.glob.script or '') ?>",
stamac: "<?lua box.js(g_var.stamac or '') ?>",
sid: "<?lua box.js(box.glob.sid) ?>",
scan: <?lua box.out(wlanscan.getstate()) ?>
});
}
function doConfirms() {
if (false == doWanConfirm()) {
return false;
}
if (false == confirmNoStartcode()) {
return false;
}
}
<?lua
if wizard.curr == 'dlg_provider' then
box.out("\n", [[ready.onReady(initProvider);]])
elseif wizard.curr == 'dlg_auth' then
box.out("\n", [[ready.onReady(initAuthform);]])
elseif wizard.curr == 'dlg_summary' then
box.out("\n", [[ready.onReady(initSummary);]])
elseif wizard.curr == 'dlg_wlanscan' and box.post.forward then
box.out("\n", [[ready.onReady(initWlanscan);]])
end
?>
ready.onReady(ajaxValidation({
applyNames: "forward",
okCallback: doConfirms
}));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>"
id="uiMainform" class="<?lua write_initial_class() wizard.write_class() ?>">
<?lua href.default_submit('forward') ?>
<?lua wizard.write_1und1_logo(wizard.wiztype ~= "first") ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<?lua write_hidden_params() ?>
<?lua write_error() ?>
<div id="dlg_welcome">
<p>
{?2759:934?}
</p>
<?lua write_welcome_explain() ?>
<p>
{?2759:124?}
<a class="nocancel" href="<?lua href.write('/system/cfgtakeover.lua') ?>">
{?2759:767?}
</a>
{?2759:764?}
</p>
</div>
<div id="dlg_provider">
<p>
{?2759:143?}
</p>
<br>
<p>{?2759:185?}</p>
<div class="formular doubleselect">
<?lua
isp.write_super_select{
id = "uiSuperprovider",
name = "superprovider",
label = [[{?2759:354?}]],
curr_provider = g_var.provider
}
?>
</div>
<div>
<?lua
isp.write_radios{
id = "uiProvider",
name = "provider",
curr_provider = g_var.provider,
explain = isphtml.get_provider_radio_explain
}
?>
</div>
<?lua write_havestartcode() ?>
<?lua write_excluded_hint() ?>
<?lua write_oma_explain() ?>
<div class="formular showif_other" id="uiActivenameContainer">
<label for="uiActivename">{?2759:983?}</label>
<input type="text" name="activename" id="uiActivename" maxlength="256"
value="<?lua box.html(g_var.activename or '') ?>"
>
</div>
</div>
<div id="dlg_medium">
<p>
{?2759:747?}
</p>
<?lua write_medium() ?>
</div>
<div id="dlg_freelan1">
<?lua write_freelan1() ?>
</div>
<div id="dlg_auth">
<?lua write_authform_head() ?>
<div id="uiAuthform">
<?lua write_authform() ?>
</div>
</div>
<div id="dlg_speed">
<?lua write_speed() ?>
</div>
<div id="dlg_summary">
<div id="uiSummary">
<p>
{?2759:239?}
</p>
<?lua write_summary_tbl() ?>
<?lua write_conncheck() ?>
</div>
<div id="uiRate" style="display:none;">
<?lua write_rate() ?>
</div>
</div>
<div id="dlg_connectlan1">
<?lua write_connectlan1() ?>
</div>
<div id="dlg_wlanscan">
<?lua write_wlanscan() ?>
</div>
<div id="dlg_wlansecurity">
<?lua write_wlansecurity() ?>
</div>
<div id="dlg_end">
<p>
{?2759:826?}
</p>
<?lua write_summary_tbl() ?>
<?lua write_end_result() ?>
<?lua write_crashreport() ?>
</div>
<div id="btn_form_foot">
<?lua write_add_buttons() ?>
<?lua wizard.write_buttons() ?>
<?lua write_ratecancel() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
