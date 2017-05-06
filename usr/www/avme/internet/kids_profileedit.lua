<?lua
g_page_type = "all"
g_page_title = ""
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"http"
require"href"
require"filter"
require"newval"
require"cmtable"
require"js"
g_back_to_page = http.get_back_to_page( "/internet/kids_profilelist.lua" )
g_menu_active_page = g_back_to_page
local function get_profile()
local uid = box.get.edit or box.post.edit or ""
if uid == "" then
return filter.get_profile_template()
else
return filter.get_profile(uid) or {UID=""}
end
end
g_err = {code=0}
g_profile = get_profile()
local function cut_string(str)
if #str > 32 then
str = str:sub(1, 32) .. [[ ...]]
end
return str
end
local function set_title()
local name = filter.profile_name(g_profile)
if name == "" then
return [[{?3693:74?}]]
else
return general.sprintf(
[[{?3693:169?}]], cut_string(name)
)
end
end
g_page_title = set_title()
g_page_help = "hilfe_zugangsprofil_individuell.html"
if g_profile.UID == filter.fixed_profile_uid('standard') then
g_page_help = "hilfe_zugangsprofil_standard.html"
elseif g_profile.UID == filter.fixed_profile_uid('guest') then
g_page_help = "hilfe_zugangsprofil_gast.html"
end
local netapp = {}
netapp.apps = general.listquery("netapp:settings/profile/list(name,profile_id)")
netapp.apps = array.filter(netapp.apps, function(app) return #app.profile_id > 0 end)
netapp.chosen = {}
netapp.tochoose = {}
local function get_filterlist(ruleset_node)
local list = general.listquery("internet_ruleset:settings/" .. ruleset_node .. "/filter_list/entry/list(name)")
return array.map(list, function(entry) return entry.name end)
end
local function netapp_init()
netapp.ruleset_id = filter.get_ruleset_id(g_profile)
if netapp.ruleset_id then
netapp.ruleset_node = filter.get_ruleset_node(netapp.ruleset_id)
end
local is_chosen = {}
if box.post.apply and box.post.netappschosen then
is_chosen = array.truth(string.split(box.post.netappschosen, ","))
elseif netapp.ruleset_node then
is_chosen = array.truth(get_filterlist(netapp.ruleset_node))
end
netapp.chosen, netapp.tochoose = array.filter(netapp.apps,
function(app) return is_chosen[app.profile_id] end
)
end
function write_netappnames_js()
local tbl = {}
for i, app in ipairs(netapp.apps) do
tbl[app.profile_id] = app.name
end
box.out(js.object(tbl))
end
function write_emptytext_js()
box.js([[{?3693:883?}]])
end
local function get_netapp_table()
local div = html.div{class="formular"}
local tbl = html.table{class="zebra", id="uiNetappsTable"}
tbl.add(html.tr{class="thead",
html.th{class="sortable",
[[{?3693:835?}]],
html.span({class="sort_no",html.raw([[&nbsp;]])})
},
html.th{class="btncolumn",
[[{?3693:156?}]]
}
})
if #netapp.chosen > 0 then
for i, app in ipairs(netapp.chosen) do
tbl.add(html.tr{
html.td{app.name},
html.td{class="btncolumn",
html.button{type="button", class="icon", name="value_" .. app.profile_id,
html.img{src="/css/default/images/loeschen.gif"}
}
}
})
end
end
div.add(tbl)
return div
end
local function get_netapp_select()
local div = html.div{class="formular tableselect"}
div.add(html.label{['for']="uiNetappsSelect",
[[{?3693:105?}]]
})
local sel = html.select{id="uiNetappsSelect", name="choosenetapps"}
sel.add(html.option{value="choose", selected=true,
[[{?txtPleaseSelect?}]]
})
for i, app in ipairs(netapp.tochoose) do
sel.add(html.option{value=app.profile_id, app.name})
end
div.add(sel)
return div
end
local function write_netappschosen()
local values = table.map(netapp.chosen, function(app) return app.profile_id end)
html.input{type="hidden", name="netappschosen", id="uiNetappsChosen",
value=table.concat(values, ",")
}.write()
end
function write_netapp_html()
if not general.is_expert() then
return
end
html.hr{}.write()
write_netappschosen()
html.div{id="uiNetapps",
html.h4{
[[{?3693:865?}]]
},
html.p{
[[{?3693:336?}]]
},
get_netapp_table(),
get_netapp_select()
}.write()
html.div{class="formular",
html.strong{
[[{?3693:1298?}]]
},
html.p{
[[{?3693:868?}]]
}
}.write()
end
netapp_init()
local function get_user_name(user)
if user.hostname and user.hostname ~= "" then
return user.hostname
end
return user.name
end
function write_users_html()
filter.gethtml_list_by_profile(g_profile).write()
end
local function budget_validation()
if filter.budget_possible(g_profile) then
newval.msg.duration = {
[newval.ret.format] = [[{?3693:102?}]],
[newval.ret.outofrange] = [[{?3693:539?}]]
}
local budgets = filter.get_budget(g_profile)
if newval.radio_check("budget", "limited") then
for i, budget in ipairs(budgets) do
newval.clock_duration("hours_" .. budget.day, "minutes_" .. budget.day, "duration")
end
end
end
end
local function name_is_used(name)
local used = filter.used_names(g_profile.UID or "")
return used[string.lower(box.post.name or "")]
end
local function name_validation()
newval.msg.name_used = {
[newval.ret.notdifferent] = [[{?3693:2?}]]
}
newval.msg.name_empty = {
[newval.ret.empty] = [[{?3693:58?}]]
}
if newval.exists("name") then
newval.not_empty("name", "name_empty")
if name_is_used("name") then
newval.const_error("name", "notdifferent", "name_used")
end
end
end
local function get_profile_webvarprefix()
if box.post.edit == "" then
return string.format("filter_profile:settings/%s/",
box.query("filter_profile:settings/profile/newid")
)
else
return string.format("filter_profile:settings/profile[%s]/", box.post.edit)
end
end
local function get_timer_savetype()
local savetype = box.post.time
if savetype == "limited" then
if box.post.timer_complete == "0" then
savetype = "never"
elseif box.post.timer_complete == "1" then
savetype = "unlimited"
end
end
return savetype
end
local function save_timer(saveset, profile_webvarprefix)
local savetype = get_timer_savetype()
local old_timeprofile_id = tonumber(g_profile.timeprofile_id) or 0
local timer_node
if savetype ~= "limited" then
-- kein Zeitprofil speichern, evtll. vorhandenes löschen
if old_timeprofile_id ~= 0 then
if filter.timeprofile_unique(g_profile) then
-- Zeitprofil löschen
timer_node = timer.get_timerid("kisi", old_timeprofile_id)
if timer_node then
cmtable.add_var(saveset, "timer:command/KidsTimerXML" .. timer_node, "delete")
end
end
-- neue timeprofil_id im Profil setzen
cmtable.add_var(saveset, profile_webvarprefix .. "timeprofile_id", "0")
end
-- ruleset_id_without_timeprofile setzen
local policy = "0"
if savetype == "never" then
policy = "1"
end
cmtable.add_var(saveset, profile_webvarprefix .. "ruleset_id_without_timeprofile", policy)
else
-- Zeitprofil speichern, evtll. neu anlegen
local timeprofile_id = old_timeprofile_id
if timeprofile_id ~= 0 then
timer_node = "KidsTimerXML" .. timer.get_timerid("kisi", old_timeprofile_id)
else
timeprofile_id = timer.get_next_ruleid("kisi")
timer_node = box.query("timer:settings/KidsTimerXML/newid")
end
cmtable.add_var(saveset, "timer:settings/" .. timer_node, timer.get_kids_xml("kisi", timeprofile_id))
cmtable.add_var(saveset, profile_webvarprefix .. "timeprofile_id", tostring(timeprofile_id))
cmtable.add_var(saveset, profile_webvarprefix .. "ruleset_id_without_timeprofile", "0")
end
end
local function save_budget(saveset, profile_webvarprefix)
local budgets = filter.get_budget(g_profile)
local unlimited = box.post.budget == "unlimited"
local h, m, value, webvar
webvar = profile_webvarprefix .. "budget_time_"
for i, budget in ipairs(budgets) do
if unlimited then
value = "0"
else
h = tonumber(box.post["hours_" .. budget.day]) or 0
m = tonumber(box.post["minutes_" .. budget.day]) or 0
if h == 24 then h = 0 end
value = tostring(h * 3600 + m * 60)
end
cmtable.add_var(saveset, webvar .. budget.day, value)
end
local share_budget = box.post.share_budget and not unlimited
webvar = profile_webvarprefix .. "share_budget"
cmtable.add_var(saveset, webvar, share_budget and "1" or "0")
end
local function save_parental_filter(saveset, profile_webvarprefix)
local enabled = box.post.parental
if enabled then
cmtable.add_var(saveset, "parental_control:settings/enabled", "1")
end
local isblack = enabled and box.post.filtertype == 'black'
local iswhite = enabled and box.post.filtertype == 'white'
local isbpjm = isblack and box.post.bpjm
local https_filter_off = not enabled or box.post.filterhttps
cmtable.add_var(saveset, profile_webvarprefix .. "blacklist_enabled", isblack and "1" or "0")
cmtable.add_var(saveset, profile_webvarprefix .. "bpjm_filter_enabled", isbpjm and "1" or "0")
cmtable.add_var(saveset, profile_webvarprefix .. "whitelist_enabled", iswhite and "1" or "0")
cmtable.add_var(saveset, profile_webvarprefix .. "filter_https_also", https_filter_off and "0" or "1")
end
local function save_netapp_values(saveset, profile_webvarprefix)
if #netapp.chosen == 0 or get_timer_savetype() == "never" then
if netapp.ruleset_node then
cmtable.add_var(saveset, "internet_ruleset:command/" .. netapp.ruleset_node, "delete")
end
cmtable.add_var(saveset, profile_webvarprefix .. "internet_ruleset_id", "0")
else
if not netapp.ruleset_id then
netapp.ruleset_id, netapp.ruleset_node = filter.create_ruleset_id_node()
end
cmtable.add_var(saveset,
"internet_ruleset:settings/" .. netapp.ruleset_node .. "/id", netapp.ruleset_id
)
local prefix = "internet_ruleset:settings/" .. netapp.ruleset_node .. "/filter_list/entry"
local cnt = box.query(prefix .. "/count")
local postfix = "/name"
for i, app in ipairs(netapp.chosen) do
cmtable.add_var(saveset, prefix .. tostring(i-1) .. postfix, app.profile_id)
end
prefix = "internet_ruleset:command/" .. netapp.ruleset_node .. "/filter_list/entry"
for i = #netapp.chosen, cnt - 1 do
cmtable.add_var(saveset, prefix .. i, "delete")
end
cmtable.add_var(saveset, profile_webvarprefix .. "internet_ruleset_id", netapp.ruleset_id)
end
end
local function validation()
name_validation()
budget_validation()
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
if box.post.validate == "apply" then
require"js"
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
if newval.validate(validation) == newval.ret.ok then
local saveset = {}
local profile_webvarprefix = get_profile_webvarprefix()
cmtable.add_var(saveset,
profile_webvarprefix .. "disallow_guest", box.post.disallow_guest and "1" or "0"
)
if box.post.name then
cmtable.add_var(saveset, profile_webvarprefix .. "name", box.post.name)
end
save_timer(saveset, profile_webvarprefix)
save_budget(saveset, profile_webvarprefix)
save_parental_filter(saveset, profile_webvarprefix)
save_netapp_values(saveset, profile_webvarprefix)
if #saveset > 0 then
g_err.code, g_err.msg = box.set_config(saveset)
end
if g_err.code == 0 then
http.redirect(g_back_to_page)
end
end
end
function write_error()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
function write_hidden_edit()
html.input{type="hidden", name="edit", value=g_profile.UID or ""}.write()
end
function write_name()
local txt = [[{?3693:455?}]]
local value = filter.profile_name(g_profile)
if filter.is_fixed(g_profile) then
html.span{class="label", txt}.write()
html.span{class="output", value}.write()
else
html.label{['for']="uiName", txt}.write()
html.input{type="text", name="name", id="uiName", value=value, maxlength=30}.write()
end
end
function write_link_to_list()
if g_profile.UID then
local link = general.sprintf(
box.tohtml([[{?3693:385?}]]),
html.a{href="#uiUserlistAnchor",
[[{?3693:681?}]]
}.get(true)
)
html.p{html.raw(link)}.write()
end
end
function write_time_explain()
local txt1 = [[{?3693:343?}]]
local txt2
if filter.budget_possible(g_profile) then
txt2 = [[ {?3693:200?}]]
end
html.p{txt1, txt2}.write()
end
function write_time_radios()
local x = filter.time_allowed(g_profile)
local checked = x == "unlimited"
html.input{
type="radio", name="time", id="uiTime:unlimited", value="unlimited", checked=checked
}.write()
html.label{['for']="uiTime:unlimited",
[[{?3693:534?}]]
}.write()
html.br{}.write()
checked = x == "never"
html.input{
type="radio", name="time", id="uiTime:never", value="never", checked=checked
}.write()
html.label{['for']="uiTime:never",
[[{?3693:517?}]]
}.write()
html.br{}.write()
checked = (x ~= "unlimited" and x ~= "never")
html.input{
type="radio", name="time", id="uiTime:limited", value="limited", checked=checked
}.write()
html.label{['for']="uiTime:limited",
[[{?3693:270?}]]
}.write()
end
local function get_max_times()
local budgets = filter.get_budget(g_profile)
local result = html.fragment()
for i, budget in ipairs(budgets) do
result.add(html.div{class="budget_input",
html.input{type="text", maxlength="2", size="2",
id="uiHours_" .. budget.day, name="hours_" .. budget.day, value=budget.hours
},
[[ h ]],
html.input{type="text", maxlength="2", size="2",
id="uiMinutes" .. budget.day, name="minutes_" .. budget.day, value=budget.minutes
},
[[ min ]]
})
end
return result
end
function write_budget()
if filter.budget_possible(g_profile) then
local limited = filter.budget_restriction(g_profile)
html.div{
html.input{
type="radio", name="budget", id="uiBudget:unlimited", value="unlimited", checked=not limited
},
html.label{['for']="uiBudget:unlimited",
[[{?3693:661?}]]
}
}.write()
html.div{
html.input{
type="radio", name="budget", id="uiBudget:limited", value="limited", checked=limited
},
html.label{['for']="uiBudget:limited",
[[{?3693:416?}]]
},
html.div{id="uiBudgetArea", class="disableif_budget:unlimited", get_max_times()}
}.write()
end
end
function write_budget_shared()
if filter.budget_possible(g_profile) then
local checked = g_profile.share_budget == "1"
html.div{id="uiSharedBox", class="disableif_budget:unlimited",
html.input{type="checkbox", id="uiShare_budget", name="share_budget", checked=checked},
html.label{['for']="uiShare_budget",
[[{?3693:401?}]]
}
}.write()
end
end
function write_hidebudget_style()
if not filter.budget_possible(g_profile) then
box.out([[ style="display:none;"]])
end
end
local function parental_filtertype()
if box.post.apply then
if box.post.filtertype == 'black' then
return box.post.bpjm and 'bpjm' or 'black'
end
return box.post.filtertype
end
if g_profile.blacklist_enabled == "1" then
if g_profile.bpjm_filter_enabled == "1" then
return 'bpjm'
else
return 'black'
end
end
if g_profile.whitelist_enabled == "1" then
return 'white'
end
return 'bpjm'
end
function write_timer_data_js()
local id = tonumber(g_profile.timeprofile_id) or 0
if id ~= 0 then
box.out(timer.get_data_js("kisi", id))
elseif g_profile.ruleset_id_without_timeprofile == "0" then
box.out([=[
[[new Period(new Moment(0,0,0), new Moment(0,24,0))],
[new Period(new Moment(1,0,0), new Moment(1,24,0))],
[new Period(new Moment(2,0,0), new Moment(2,24,0))],
[new Period(new Moment(3,0,0), new Moment(3,24,0))],
[new Period(new Moment(4,0,0), new Moment(4,24,0))],
[new Period(new Moment(5,0,0), new Moment(5,24,0))],
[new Period(new Moment(6,0,0), new Moment(6,24,0))]]
]=])
else
box.out("[]")
end
end
function write_disallow_guest()
if g_profile.UID ~= filter.fixed_profile_uid('guest') then
local checked = g_profile.disallow_guest == "1"
html.br{}.write()
html.div{
html.input{type="checkbox", id="uiDisallow_guest", name="disallow_guest", checked=checked},
html.label{['for']="uiDisallow_guest",
[[{?3693:745?}]]
},
html.p{class="form_checkbox_explain",
[[{?3693:121?}]]
}
}.write()
end
end
function write_bpjm_filter()
if box.query("box:settings/country") == "049" then
local val = parental_filtertype()
local checked = false
if val == "bpjm" then
checked = true
end
html.br{}.write()
html.div{id="uiBpjmFilter", class="formular enableif_black",
html.input{type="checkbox", id="uiBpjm", name="bpjm", checked=checked},
html.label{['for']="uiBpjm",
[[{?3693:183?}]]
},
html.a{class="textlink",href="http://www.avm.de/BPjM-Modul",target="_blank",
[[{?3693:733?}]]
},
html.p{class="form_checkbox_explain",
[[{?3693:4?}]]
}
}.write()
end
end
local function parental_enabled()
if box.post.apply then
return box.post.parental
end
return g_profile.bpjm_filter_enabled == "1"
or g_profile.blacklist_enabled == "1"
or g_profile.whitelist_enabled == "1"
end
local function allow_https()
if box.post.apply then
return box.post.filterhttps ~= nil
end
return g_profile.filter_https_also ~= "1"
end
function write_parental_checked()
if parental_enabled() then
box.out(" checked")
end
end
function write_filtertype_checked(which)
local val = parental_filtertype()
if val == which or (which == 'black' and val == 'bpjm') then
box.out(" checked")
end
end
function write_filterhttps_checked()
if allow_https() then
box.out(" checked")
end
end
function write_urllist_link(listtype)
href.write("/internet/kids_urllist.lua",
"listtype=" .. listtype
)
end
function write_blockedip_list_link()
href.write("/internet/kids_blockedip_list.lua")
end
function write_explain()
local txt = [[{?3693:324?}]]
if g_profile then
if g_profile.UID == filter.fixed_profile_uid('standard') then
txt = [[{?3693:8718?}]]
elseif g_profile.UID == filter.fixed_profile_uid('guest') then
txt = [[{?3693:160?}]]
end
end
html.p{txt}.write()
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/timer.css">
<style type="text/css">
div.leftright {
width:99%;
overflow:hidden;
border: 1px solid #C6C7BE;
}
div.leftright div.left {
width: 580px;
padding: 2px 0 5px 15px;
float: left;
}
div.leftright div.right {
border: 0 solid #C6C7BE;
border-left-width: 1px;
padding: 2px 0 5px 15px;
margin-left: 580px;
}
div.budget_input {
line-height: 35px;
}
div.budget_input input[type="text"] {
font-size: 10px;
width: 20px;
margin: 0 0 0 5px;
text-align: right;
}
div.budget_input input[type="text"]:first_child {
margin-left: 0;
}
div#uiBudgetArea {
margin-top: 62px;
}
div#uiSharedBox {
margin-top: 33px;
}
div.urllist {
width: 70%;
max-height: 70px;
overflow-y: auto;
}
div.urllist table {
margin-top: 0;
margin-bottom: 0;
}
.formular span.label {
display: inline-block;
width: 200px;
}
span.linklabel {
margin: 1px 0px;
vertical-align: middle;
display: inline-block;
margin-right: 6px;
}
.formular.tableselect {
text-align:right;
}
.formular.tableselect label {
width: auto;
}
</style>
<script type="text/javascript" src="/js/timer.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/tableselectchooser.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
var gTimer;
function disableTimer(flag) {
flag = Boolean(flag);
jxl.disableNode("uiTimerArea", flag);
gTimer.disabled = flag;
}
function onTimeRadio(evt) {
var radio = jxl.evtTarget(evt);
if (radio) {
disableTimer(radio.value == "unlimited" || radio.value == "never");
}
}
function initTimer() {
gTimer = new Timer("uiTimer",
<?lua write_timer_data_js() ?>
);
disableTimer(jxl.getChecked("uiTime:unlimited") || jxl.getChecked("uiTime:never"));
jxl.addEventHandler("uiTime:unlimited", "click", onTimeRadio);
jxl.addEventHandler("uiTime:never", "click", onTimeRadio);
jxl.addEventHandler("uiTime:limited", "click", onTimeRadio);
}
function addPopupOpeners() {
var popupWin = null;
var opts = "width=520,height=560,statusbar,resizable=yes,scrollbars=yes"
function openPopup(evt) {
var elem = jxl.evtTarget(evt);
var url = elem.href;
url += "&stylemode=print&popupwnd=1";
if (!popupWin || popupWin.closed) {
popupWin = open(url, "Zweitfenster", opts);
}
else {
popupWin.location.href = url;
}
if (popupWin) {
popupWin.focus();
}
return jxl.cancelEvent(evt);
}
var links = document.links;
var i = links.length || 0;
while (i--) {
if (jxl.hasClass(links[i], "popup")) {
jxl.addEventHandler(links[i], 'click', openPopup);
}
}
}
function init() {
initTimer();
initTableSorter();
disableOnClick({
inputName: "budget",
classString: "disableif_budget:%1"
});
enableOnClick({
inputName: "parental",
classString: "enableif_parental"
});
showOnClick({
inputName: "parental",
classString: "showif_parental"
});
enableOnClick({
inputName: "filtertype",
classString: "enableif_%1"
});
createTableSelectChooser({
tableId: "uiNetappsTable",
selectId: "uiNetappsSelect",
chosenId: "uiNetappsChosen",
displayNames: {
<?lua write_netappnames_js() ?>
},
emptyText: "<?lua write_emptytext_js() ?>",
sort: sort
});
addPopupOpeners();
}
ready.onReady(init);
function initTableSorter() {
sort.init("uiNetappsTable");
sort.sort_table(0);
}
function onApply() {
var never = gTimer.save("uiMainform");
}
ready.onReady(ajaxValidation({
okCallback: onApply
}));
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainform" name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="narrow">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<?lua write_hidden_edit() ?>
<?lua write_error() ?>
<?lua write_explain() ?>
<hr>
<div class="formular widetext">
<?lua write_name() ?>
</div>
<?lua write_link_to_list() ?>
<hr>
<h4>{?3693:436?}</h4>
<?lua write_time_explain() ?>
<div class="leftright">
<div class="left">
<p>{?3693:904?}</p>
<?lua write_time_radios() ?>
<div id="uiTimerArea" class="formular">
<?lua
timer.write_html("uiTimer", {
active = [[{?3693:713?}]],
inactive = [[{?3693:182?}]]
})
?>
</div>
</div>
<div class="right" <?lua write_hidebudget_style() ?>>
<p>{?3693:588?}</p>
<?lua write_budget() ?>
<?lua write_budget_shared() ?>
<div style="clear:both;"></div>
</div>
</div>
<?lua write_disallow_guest() ?>
<hr>
<h4>{?3693:353?}</h4>
<p>{?3693:877?}</p>
<div class="formular">
<input type="checkbox" name="parental" id="uiParental" <?lua write_parental_checked() ?>>
<label for="uiParental">{?3693:782?}</label>
<div id="uiParentalChoose" class="enableif_parental showif_parental">
<div class="formular">
<input type="checkbox" name="filterhttps" id="uiHttps" <?lua write_filterhttps_checked() ?>>
<label for="uiHttps">{?3693:472?}</label>
<p class="form_input_explain">
{?3693:232?}
</p>
<p class="form_input_explain">
{?3693:79?}
</p>
</div>
<div class="formular">
<p>{?3693:460?}</p>
</div>
<div class="formular">
<input type="radio" name="filtertype" value="white" id="uiWhite" <?lua write_filtertype_checked('white') ?>>
<label for="uiWhite">{?3693:415?}</label>
<a class="textlink popup" href="<?lua write_urllist_link('white') ?>" target="_blank">
{?3693:962?}
</a>
<p class="form_input_explain">
{?3693:231?}
</p>
</div>
<div class="formular">
<input type="radio" name="filtertype" value="black" id="uiBlack" <?lua write_filtertype_checked('black') ?>>
<label for="uiBlack">{?3693:2730?}</label>
<a class="textlink popup" href="<?lua write_urllist_link('black') ?>" target="_blank">
{?3693:374?}
</a>
<p class="form_input_explain">
{?3693:46?}
</p>
<p class="form_input_explain">
<span class="linklabel">{?3693:855?}</span>
<a class="textlink popup" href="<?lua write_blockedip_list_link() ?>" target="_blank">
{?3693:503?}
</a>
</p>
<?lua write_bpjm_filter() ?>
</div>
<div class="formular">
<strong>{?3693:743?}</strong>
<p>{?3693:921?}</p>
</div>
</div>
</div>
<?lua write_netapp_html() ?>
<?lua write_users_html() ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">
{?txtApplyOk?}
</button>
<button type="submit" name="cancel">
{?txtCancel?}
</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
