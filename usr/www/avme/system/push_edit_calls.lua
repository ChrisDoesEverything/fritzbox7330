<?lua
g_page_type = "all"
g_page_title = [[{?695:82?}]]
g_page_help = "hilfe_system_pushservice_calls.html"
dofile("../templates/global_lua.lua")
require"pushservice"
require"html"
require"js"
require"cmtable"
require"newval"
require"general"
require"http"
g_back_to_page = http.get_back_to_page( "/system/push_list.lua" )
g_menu_active_page = g_back_to_page
local function get_numbers(pushlist)
local double_numbers = {}
local numbers = {}
require"fon_numbers"
local all_nums = fon_numbers.get_all_numbers()
local numstr, numidx
for i, number in ipairs(all_nums.numbers) do
numstr = tostring(number.msnnum)
if numstr ~= "" and not double_numbers[numstr] then
numidx = array.find(pushlist, func.eq(numstr, "MSN"))
if not numidx then
double_numbers[numstr] = numstr
table.insert(numbers, numstr)
end
end
end
local allnumbers = table.clone(double_numbers)
for i, item in ipairs(pushlist) do
allnumbers[item.MSN] = item.MSN
end
return numbers, allnumbers
end
local function read_data()
local data = {}
local pushlist = table.clone(pushservice.calls.list)
data.default = table.remove(pushlist, 1)
data.pushlist = array.filter(pushlist, func.neq("", "MSN"))
data.numbers, data.allnumbers = get_numbers(data.pushlist)
return data
end
local function refill_data()
local data = {}
data.default = {
MSN = "",
Active = box.post.Active or "0",
Address = box.post.Address or ""
}
data.pushlist = {}
local chosen = string.split(box.post.chosen or "", ",")
for i, msn in ipairs(chosen) do
table.insert(data.pushlist, {
MSN = msn,
Active = box.post["Active:" .. msn] or "0",
Address = box.post["Address:" .. msn] or ""
})
end
data.numbers, data.allnumbers = get_numbers(data.pushlist)
return data
end
local function validation()
newval.msg.email = {
[newval.ret.empty] = [[{?695:477?}]],
[newval.ret.format] = [[{?695:711?}]]
}
if not newval.radio_check("Active", "0") then
newval.email_list("Address", "email")
end
for msn in pairs(g_data.allnumbers) do
local active = "Active:" .. msn
if newval.exists(active) then
if not newval.value_equal(active, "0") then
newval.email_list("Address:" .. msn, "email")
end
end
end
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
g_data = read_data()
g_err = {code=0}
if box.post.validate == "apply" then
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
g_data = refill_data()
if newval.validate(validation) == newval.ret.ok then
local saveset = {}
local webvar = [[telcfg:settings/NotifyEmail/]]
cmtable.add_var(saveset, webvar .. "Active", g_data.default.Active)
cmtable.add_var(saveset, webvar .. "MSN", "")
if g_data.default.Active ~= "0" then
cmtable.add_var(saveset, webvar .. "Address", general.clear_whitespace(g_data.default.Address))
end
local webvar_fmt = [[telcfg:settings/NotifyEmail%d/]]
for i, p in ipairs(g_data.pushlist) do
webvar = webvar_fmt:format(i)
cmtable.add_var(saveset, webvar .. "MSN", p.MSN)
cmtable.add_var(saveset, webvar .. "Active", p.Active)
if p.Active ~= "0" then
cmtable.add_var(saveset, webvar .. "Address", general.clear_whitespace(p.Address))
end
end
for i = #g_data.pushlist + 1, 9 do
webvar = webvar_fmt:format(i)
cmtable.add_var(saveset, webvar .. "MSN", "")
cmtable.add_var(saveset, webvar .. "Active", "0")
cmtable.add_var(saveset, webvar .. "Address", "")
end
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(g_back_to_page)
end
end
end
function write_error()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local active_options = {{
value = "0", txt = [[{?695:133?}]]
}, {
value = "2", txt = [[{?695:631?}]]
}, {
value = "1", txt = [[{?695:475?}]]
}}
function write_default()
html.p{
[[{?695:368?}]]
}.write()
local name, id = "Active"
for i, option in ipairs(active_options) do
id = "uiActive:" .. option.value
html.div{class="formular",
html.input{
type="radio", name=name, id=id, value=option.value, checked=g_data.default.Active == option.value
},
html.label{['for']=id, option.txt}
}.write()
end
html.div{class="formular disableif_Active:0",
pushservice.gethtml_mailto{
html_name = "Address",
Address = pushservice.default_mailto(g_data.default.Address)
}
}.write()
end
local function active_select(name, value)
local id = "ui" .. name:at(1):upper() .. name:sub(2)
local sel = html.select{name=name, id=id}
for i, option in ipairs(active_options) do
sel.add(html.option{
value=option.value, selected=option.value == value, option.txt
})
end
return sel
end
local function address_input(name, value, active)
local id = "ui" .. name:at(1):upper() .. name:sub(2)
local disabled = active and active == "0"
return html.div{class="widetext",
html.input{type="text", name=name, id=id, value=value, disabled=disabled}
}
end
local function remove_btn(value)
return html.button{type="button", class="icon", name="value_" .. value,
html.img{src="/css/default/images/loeschen.gif"}
}
end
function write_more_link()
local src = "/css/default/images/link_open.gif"
if #g_data.pushlist > 0 then
src = "/css/default/images/link_closed.gif"
end
html.a{class="textlink", href=" ", onclick="onMoreClicked();return false;",
[[{?695:714?}]],
html.img{id="uiMoreLink", src=src, height="12"}
}.write()
end
function write_more_style()
if #g_data.pushlist == 0 then
box.out([[style="display:none;"]])
end
end
function write_calls_table()
local tbl = html.table{class="zebra", id="uiCallsTable"}
tbl.add(
html.tr{
html.th{[[{?695:828?}]]},
html.th{[[{?695:149?}]]},
html.th{[[{?695:204?}]]},
html.th{class="buttonrow",
[[{?695:718?}]]
}
}
)
for i, item in ipairs(g_data.pushlist) do
tbl.add(html.tr{
html.td{item.MSN},
html.td{active_select("Active:" .. item.MSN, item.Active)},
html.td{address_input("Address:" .. item.MSN, item.Address, item.Active)},
html.td{class="buttonrow", remove_btn(item.MSN)}
})
end
tbl.write()
end
function write_chosen()
local value = {}
for i, item in ipairs(g_data.pushlist) do
table.insert(value, item.MSN)
end
html.input{type="hidden", name="chosen", id="uiChosen",
value=table.concat(value, ",")
}.write()
end
function write_calls_select()
local sel = html.select{id="uiNumber", name="number"}
sel.add(
html.option{value="choose", selected=true,
[[{?txtPleaseSelect?}]]
}
)
for i, msn in ipairs(g_data.numbers) do
sel.add(html.option{value=msn, msn})
end
html.div{class="formular tableselect",
html.label{['for']="uiNumber",
[[{?695:126?}]]
},
sel
}.write()
end
function write_calls_names_js()
box.out(js.table(g_data.allnumbers))
end
function write_calls_td_list_js()
local result = {}
local defaultAddress = pushservice.default_mailto(g_data.default.Address)
for i, msn in ipairs(g_data.numbers) do
result[msn] = {
active_select("Active:" .. msn, g_data.default.Active).get(),
address_input("Address:" .. msn, defaultAddress, g_data.default.Active).get()
}
end
for i, item in ipairs(g_data.pushlist) do
result[item.MSN] = {
active_select("Active:" .. item.MSN, item.Active).get(),
address_input("Address:" .. item.MSN, item.Address, item.Active).get()
}
end
box.out(js.table(result))
end
function write_emptytext_js()
box.js(
[[{?695:340?}]]
)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular.tableselect {
text-align:right;
}
.formular.tableselect label {
width: auto;
}
#uiCallsTable tr td:first-child {
width: 200px;
}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/tableselectchooser.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
function onMoreClicked() {
var div = jxl.get("uiMore");
var img = jxl.get("uiMoreLink");
if (div) {
var isOpen = div.style.display != "none";
jxl.display(div, !isOpen);
if (img) {
img.src = isOpen ? "/css/default/images/link_open.gif" : "/css/default/images/link_closed.gif";
}
}
}
function init() {
disableOnClick({
inputName: "Active",
classString: "disableif_Active:%1"
});
var numTdList = <?lua write_calls_td_list_js() ?>;
createTableSelectChooser({
tableId : "uiCallsTable",
selectId: "uiNumber",
chosenId: "uiChosen",
displayNames: <?lua write_calls_names_js() ?>,
emptyText: "<?lua write_emptytext_js() ?>",
colSpan: 4,
maxTableSize: 9,
addTdsCallback: function(value) {
return numTdList[value] || ["", ""];
}
});
function onChangeActive(evt) {
var tgt = jxl.evtTarget(evt);
var id = tgt.id || "";
if (id.indexOf("uiActive:") == 0) {
id = id.replace("uiActive:", "uiAddress:");
var val = jxl.getValue(tgt);
jxl.setDisabled(id, val == "0");
}
}
jxl.addEventHandler("uiCallsTable", "change", onChangeActive);
}
ready.onReady(init);
ready.onReady(ajaxValidation());
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_error() ?>
<p>
{?695:29?}
</p>
<hr>
<h4>
{?695:535?}
</h4>
<p>
{?695:490?}
</p>
<?lua write_default() ?>
<br>
<?lua write_more_link() ?>
<div id="uiMore" <?lua write_more_style() ?>>
<p>
{?695:613?}
</p>
<?lua write_chosen() ?>
<?lua write_calls_table() ?>
<?lua write_calls_select() ?>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
