<?lua
g_page_type = "all"
g_page_title = [[{?7613:773?}]]
g_page_help = "hilfe_fon_telefonbucheintrag.html"
g_page_needs_js = true
g_menu_active_page = "/fon_num/fonbook_list.lua"
dofile("../templates/global_lua.lua")
require"http"
require"html"
require"js"
require"newval"
require"fon_book"
require"general"
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_list.lua" )
if box.post.cancel then
http.redirect(g_back_to_page)
end
local function set_local_tabs(entry, cfg)
g_local_tabs = {}
local params = table.concat({
"uid=" .. (entry.uid or "new"),
"back_to_page=" .. g_back_to_page
}, "&")
if config.DECT_PICTURED and cfg.photo then
table.insert(g_local_tabs, {
page = "/fon_num/fonbook_entry.lua",
text = [[{?7613:582?}]],
param = params
})
table.insert(g_local_tabs, {
page = "/fon_num/fonbook_photo.lua",
text = [[{?7613:606?}]],
param = params
})
end
end
local function gui_type_display(gui_type)
if gui_type == 'single_email' then
return [[{?7613:407?}]]
end
return fon_book.type_display(gui_type)
end
local function format_code(code)
code = tonumber(code)
return code and string.format("%02d", code) or ""
end
local function vanity2digits(str)
local special = {S = 7, V = 8, Y = 9, Z = 9}
local a = string.byte('A')
local digits = ""
for i, ch in ipairs(str:split()) do
digits = digits .. (
tonumber(ch) or special[ch]
or math.floor((ch:byte() - a) / 3) + 2
)
end
return digits
end
local function get_used_codes(entry)
local codes = fon_book.get_all_quickdials()
for i, num in ipairs(entry.numbers) do
if num.prio == 1 and num.code then
codes[tostring(num.code)] = nil
end
end
return codes
end
local function get_used_vanities(entry)
local vanities = fon_book.get_all_vanity_codes()
for i, num in ipairs(entry.numbers) do
if num.prio == 1 and num.vanity then
vanities[vanity2digits(num.vanity)] = nil
end
end
return vanities
end
local function create_cfg(entry)
local cfg = {}
if entry.uid then
cfg.addnum = box.get.number
else
cfg.newnum = box.get.number
end
local booktype = fon_book.booktype()
cfg.photo = booktype ~= 'online'
cfg.number = {
min = 3, max = 9,
types = {'home', 'mobile', 'work', 'fax_work'}
}
cfg.category = booktype ~= 'online' or fon_book.bookprovider() == "google"
cfg.numberplus = booktype == 'standard'
if cfg.numberplus then
cfg.number.newcode = format_code(fon_book.find_free_quickdial())
cfg.number.used_codes = get_used_codes(entry)
cfg.number.used_vanities = get_used_vanities(entry)
end
if #entry.emails > 0 or box.query("dect:settings/enabled") == "1" then
cfg.email = {
min = 1, max = 1
}
cfg.email.showtype = #entry.emails > 1 or booktype == 'online'
end
return cfg
end
local function read_entry()
local entry = {name = "", numbers = {}, emails = {}}
local uid = tonumber(box.get.uid or box.post.uid)
if uid then
entry = fon_book.read_entry_by_uid(uid)
end
entry.numbers = entry.numbers or {}
entry.emails = entry.emails or {}
return entry
end
local function sort_by_guitype(tbl, types)
local order = array.indices(types)
local last = #types
table.sort(tbl, function(n1, n2)
return (order[n1.guitype] or last) < (order[n2.guitype] or last) end
)
end
local function create_view(entry, cfg)
local required_types = array.slice(cfg.number.types, 1, cfg.number.min)
local types_left = array.truth(required_types)
for i, num in ipairs(entry.numbers) do
num.guitype = fon_book.gui_type(num.type)
types_left[num.guitype] = false
end
if cfg.newnum then
table.insert(entry.numbers, {
id = "new1",
guitype = 'home',
number = cfg.newnum
})
types_left.home = false
end
if cfg.addnum and #entry.numbers >= cfg.number.min and #entry.numbers < cfg.number.max then
table.insert(entry.numbers, {
id = "new1",
guitype = 'home'
})
types_left.home = false
end
required_types = array.filter(required_types, function(t) return types_left[t] end)
for i = #entry.numbers + 1, cfg.number.min do
table.insert(entry.numbers, {
id = "new" .. i,
guitype = table.remove(required_types, 1) or 'home'
})
end
if cfg.email then
for i, email in ipairs(entry.emails) do
if cfg.email.showtype then
email.guitype = fon_book.gui_type(email.type)
else
email.guitype = 'single_email'
end
end
for i = #entry.emails + 1, cfg.email.min do
local email = {}
email.id = "new" .. i
if cfg.email.showtype then
email.guitype = fon_book.gui_type('private')
else
email.guitype = 'single_email'
end
table.insert(entry.emails, email)
end
end
return entry
end
local function is_same_vanity(name, digits)
local vanity = box.post[name] or ""
vanity = vanity:upper()
return vanity2digits(vanity) == digits
end
local err_add_txt = [[ {?7613:8183?}]]
local function name_validation(cfg)
newval.msg.nameerror = {
[newval.ret.outofrange] = [[{?7613:411?}]]
}
newval.char_range_regex("entryname", "anynonwhitespace", "nameerror")
end
local function code_used_validation(cfg)
newval.msg.codeused = {
[newval.ret.wrong] = [[{?7613:826?}]] .. err_add_txt
}
for code in pairs(cfg.number.used_codes) do
if newval.value_equal("code", format_code(code)) then
newval.const_error("code", "wrong", "codeused")
end
end
end
local function vanity_used_validation(cfg)
newval.msg.vanityused = {
[newval.ret.wrong] = [[{?7613:917?}]] .. err_add_txt
}
for vanity in pairs(cfg.number.used_vanities) do
if is_same_vanity("vanity", vanity2digits(vanity)) then
newval.const_error("vanity", "wrong", "vanityused")
end
end
end
local function prio_validation(cfg)
local codeerr_txt = [[{?7613:256?}]] .. err_add_txt
newval.msg.codeerror = {
[newval.ret.format] = codeerr_txt,
[newval.ret.outofrange] = codeerr_txt,
[newval.ret.empty] = codeerr_txt
}
newval.msg.vanityerror = {
[newval.ret.outofrange] = [[{?7613:860?}]] .. err_add_txt
}
newval.msg.vanityneedscode = {
[newval.ret.empty]= [[{?7613:696?}]] .. err_add_txt
}
if not newval.value_equal("prionumber", "none") then
newval.num_range("code", 0, 99, "codeerror")
if not newval.value_empty("vanity") then
newval.char_range_regex("vanity", "wepascii", "vanityerror")
newval.not_empty("code", "vanityneedscode")
end
code_used_validation(cfg)
vanity_used_validation(cfg)
end
end
local function email_validation(cfg)
newval.msg.email = {
[newval.ret.format] = [[{?7613:232?}]]
}
local email_names = table.filter(box.post,
function(v, k) return type(v) ~= 'number' and not k:find("_i", -2) and k:find("email") == 1 end
)
for name in pairs(email_names) do
if not newval.value_empty(name) then
newval.email(name, "email")
end
end
end
local function add_save_prio(number, numbername)
if box.post.prionumber == numbername then
number.prio = 1
local code, vanity = tonumber(box.post.code)
if code then
vanity = box.post.vanity
if vanity == "" then
vanity = nil
else
vanity = vanity:upper()
end
end
number.code = code
number.vanity = vanity
else
number.prio = 0
number.code = nil
number.vanity = nil
end
end
local function create_save(entry, cfg)
entry.name = box.post.entryname
if cfg.category then
entry.category = box.post.category and 1 or 0
end
for i = #entry.numbers, 1, -1 do
local num = entry.numbers[i]
local post_num = box.post["number" .. num.id]
if not post_num or post_num:trim() == "" then
table.remove(entry.numbers, i)
else
num.number = post_num
local post_type = box.post["numbertype" .. num.id]
if fon_book.gui_type(num.type) ~= post_type then
num.type = post_type
end
if cfg.numberplus then
add_save_prio(num, "number" .. num.id)
end
end
end
for i = #entry.emails, 1, -1 do
local email = entry.emails[i]
local post_email = box.post["email" ..email.id]
if not post_email or post_email:trim() == "" then
table.remove(entry.emails, i)
else
entry.emails[i].email = post_email
end
end
for i, name in ipairs(general.sorted_by_i(box.post)) do
if name:find("numbernew") == 1 then
local post_num = box.post[name]
local typename = name:gsub("number", "numbertype")
if post_num and post_num:trim() ~= "" then
local new_num = {
number = post_num,
type = box.post[typename]
}
if cfg.numberplus then
add_save_prio(new_num, name)
end
table.insert(entry.numbers, new_num)
end
elseif name:find("emailnew") == 1 then
local post_email = box.post[name]
if post_email and post_email:trim() ~= "" then
table.insert(entry.emails, {
email = post_email,
type = 'private'
})
end
end
end
return entry
end
local entry = read_entry()
local cfg = create_cfg(entry)
set_local_tabs(entry, cfg)
local function validation()
name_validation(cfg)
if cfg.numberplus then
prio_validation(cfg)
end
if cfg.email then
email_validation(cfg)
end
end
if box.post.validate == "apply" then
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.apply then
entry = create_save(entry, cfg)
local valresult = newval.validate(validation)
if valresult == newval.ret.ok then
cfg.error = fon_book.write_entry(entry)
if cfg.error == 0 then
http.redirect(g_back_to_page)
end
end
else
entry = create_view(entry, cfg)
end
function write_error()
if cfg.error and cfg.error ~= 0 then
box.out(general.create_error_div(cfg.error))
end
end
function write_numberplus()
if cfg.numberplus then
html.hr{}.write()
html.div{class="formular",
html.h4{[[{?7613:883?}]]},
html.p{[[{?7613:604?}]]}
}.write()
local code, vanity
local prio_select = html.select{id="uiPrionumber", name="prionumber"}
local selected
prio_select.add(
html.option{value="none", [[{?7613:827?}]]}
)
for i, num in ipairs(entry.numbers) do
if tonumber(num.id) or num.number then
selected = num.prio == 1 and num.code~=nil
if selected then
code, vanity = num.code, num.vanity
end
prio_select.add(
html.option{value="number" .. num.id, selected=selected, num.number}
)
end
end
html.div{class="formular",
html.label{['for']="uiPrionumber", [[{?7613:580?}]]},
prio_select
}.write()
html.div{class="formular",
html.label{['for']="uiCode", [[{?7613:763?}]]},
html.span{class="prefix", [[**7]]},
html.input{type="text", name="code", id="uiCode", value=format_code(code), maxlength=2}
}.write()
html.div{class="formular",
html.label{['for']="uiVanity", [[{?7613:9?}]]},
html.span{class="prefix", [[**8]]},
html.input{type="text", name="vanity", id="uiVanity", value=vanity or "", maxlength=8}
}.write()
end
if cfg.category then
html.div{class="formular",
html.input{type="checkbox", name="category", id="uiCategory", checked=entry.category == 1},
html.label{['for']="uiCategory", [[{?7613:487?}]]}
}.write()
end
end
local function email_delete_btn_html(email)
local txt
return html.span{class="btn_align",
html.button{
type="button", class="icon", id="uiDeleteemail" .. email.id, title=txt,
html.img{src="/css/default/images/loeschen.gif"}
}
}
end
local function email_input_html(email)
local name = "email" .. email.id
local id = "uiEmail" .. email.id
local value = email.email or ""
return html.fragment(
html.label{['for']=id, gui_type_display(email.guitype)},
html.input{type="text", name=name, id=id, value=value, size=32},
email_delete_btn_html(email)
)
end
function write_emails()
if cfg.email then
html.hr{}.write()
local head = html.div{class="formular",
html.h4{[[{?7613:480?}]]}
}
if box.query("dect:settings/enabled") == "1" then
head.add(html.p{
[[{?7613:787?}]]
})
end
head.write()
for i, email in ipairs(entry.emails) do
html.div{class="formular emaildiv",
email_input_html(email)
}.write()
end
end
end
function write_add_emails_link()
if cfg.email then
local style = ""
if #entry.emails >= cfg.email.max then
style = "display:none;"
end
html.div{class="formular",
html.span{class="label"},
html.a{style=style, id="uiAddemail", href=" ", class="textlink",
[[{?7613:717?}]]
}
}.write()
end
end
function write_newemail_template_js()
if not cfg.email then
box.js("")
else
local email = {}
email.id = "new%1"
if cfg.email and cfg.email.showtype then
email.guitype = fon_book.gui_type('private')
else
email.guitype = 'single_email'
end
local str = email_input_html(email).get()
box.out(js.quoted(str))
end
end
local function number_delete_btn_html(number)
local txt
return html.span{class="btn_align hideif_addnum",
html.button{
type="button", class="icon", id="uiDeletenumber" .. number.id, title=txt,
html.img{src="/css/default/images/loeschen.gif"}
}
}
end
local function typeselect_html(number)
local sel = html.select{name="numbertype" .. number.id}
local type_found = false
for i, typename in ipairs(cfg.number.types) do
local selected = typename == number.guitype
if selected then type_found = true end
sel.add(html.option{
value=typename, selected=selected, gui_type_display(typename) or ""
})
end
if not type_found then
sel.add(html.option{
value=number.guitype, selected=true, gui_type_display(number.guitype) or ""
})
end
return html.span{class="label", sel}
end
local function addnum_btn_html(number)
if cfg.addnum then
local txt = [[{?txtOverwrite?}]]
if not number.number then
txt = [[{?txtInsert?}]]
end
return html.span{class="btn_align addnumbtn",
html.button{type="button", id="uiAddnumbtn" .. number.id, txt}
}
end
end
local function number_input_html(number)
local name = "number" .. number.id
local id = "uiNumber" .. number.id
local value = number.number or ""
return html.fragment(
typeselect_html(number),
html.input{type="text", name=name, id=id, value=value, size=32},
number_delete_btn_html(number),
addnum_btn_html(number)
)
end
function write_numbers()
if cfg.addnum then
local explain = [[{?7613:553?}]]
if #entry.numbers < cfg.number.max then
explain = [[{?7613:343?}]]
end
explain = general.sprintf(explain, cfg.addnum)
html.div{class="formular", id="uiAddnumexplain",
html.p{explain},
html.label{[[{?7613:872?}]]},
html.input{type="text", id="uiAddnumNumber", size=32, value=cfg.addnum},
html.br{}
}.write()
end
for i, num in ipairs(entry.numbers) do
html.div{class="formular numberdiv",
number_input_html(num)
}.write()
end
end
function write_add_numbers_link()
local style = ""
if #entry.numbers >= cfg.number.max then
style = "display:none;"
end
html.div{class="formular hideif_addnum",
html.span{class="label"},
html.a{style=style, id="uiAddnumber", href=" ", class="textlink",
[[{?7613:702?}]]
}
}.write()
end
function write_sipuri_hint()
if cfg.numberplus then
html.div{class="formular", id="uiSipurihint", style="display:none;",
html.strong{[[{?txtHinweis?}]]},
html.br{},
html.p{[[{?7613:538?}]]}
}.write()
end
end
function write_newnumber_template_js()
local num = {id="new%1", guitype='home'}
local str = number_input_html(num).get()
box.out(js.quoted(str))
end
function write_hidden_values()
local names = {'idx', 'uid'}
for i, name in ipairs(names) do
html.input{type="hidden", name=name, value=entry[name] or ""}.write()
end
end
function write_entryname_input()
local entryname = entry.name or ""
if cfg.newnum then
entryname = box.get.numbername or box.post.numbername or ""
end
html.div{class="formular",
html.label{['for']="uiEntryname",[[{?7613:427?}]]},
html.input{type="text", name="entryname", id="uiEntryname", value=entryname, size=32}
}.write()
end
function write_cfg_js()
box.out(js.table(cfg or {}));
end
function write_form_class()
if cfg.addnum then box.out([[ addnum]]) end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
margin-right: 6px;
}
.narrow .formular span.label {
width: 150px;
}
span.btn_align {
display: inline-block;
vertical-align: middle;
}
.addnum .numberdiv input[type="text"] {
background-color: #F8F8C0;
/*
border:solid 1px #7f9db9;
padding: 2px;
*/
}
.addnum .hideif_addnum {
display:none;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript">
var gCfg = <?lua write_cfg_js() ?>;
var gDirty = false;
function initWarnIfDirtyHandler() {
var txt = [
'{?7613:503?}',
'{?7613:960?}',
'{?7613:432?}'
].join("\n");
function warnIfDirty(evt) {
if (gDirty && !confirm(txt)) {
return jxl.cancelEvent(evt);
}
}
if (gCfg.newnum || gCfg.addnum) {
gDirty = true;
}
var tabs = jxl.getByClass("tabs", "", "ul");
if (tabs && tabs.length) {
jxl.walkDom(tabs[0], 'a', function(a) {
jxl.addEventHandler(a, 'click', warnIfDirty);
});
}
}
function initFormHandler() {
jxl.focus("uiEntryname");
var form = document.forms.mainform;
var mainDiv = {
number: jxl.get("uiNumbers"),
email: jxl.get("uiEmails")
};
var divClass = {
number: "numberdiv",
email: "emaildiv"
};
var template = {};
template.number = String(<?lua write_newnumber_template_js() ?>);
var nextIdx = {};
nextIdx.number = count('number');
if (gCfg.email) {
template.email = String(<?lua write_newemail_template_js() ?>);
nextIdx.email = count('email');
}
var prioSelect = null;
var prioValues = {};
if (gCfg.numberplus) {
prioSelect = jxl.get("uiPrionumber");
prioValues[jxl.getValue(prioSelect)] = {
code: jxl.getValue("uiCode") || gCfg.number.newcode,
vanity: jxl.getValue("uiVanity")
};
prioValues.none = {
code: "",
vanity: ""
}
}
function savePrioValues() {
var selected = jxl.getValue(prioSelect);
prioValues[selected] = {
code: jxl.getValue("uiCode"),
vanity: jxl.getValue("uiVanity")
};
}
function updatePrioValues() {
var selected = jxl.getValue(prioSelect);
if (!prioValues[selected]) {
prioValues[selected] = {
code: gCfg.number.newcode,
vanity: ""
}
}
jxl.setValue("uiCode", prioValues[selected].code);
jxl.setValue("uiVanity", prioValues[selected].vanity);
}
function count(which) {
var cnt = jxl.getByClass(divClass[which], mainDiv[which], 'div').length;
return cnt;
}
function doAdd(which) {
nextIdx[which]++;
var newDiv = document.createElement('div');
jxl.addClass(newDiv, "formular");
jxl.addClass(newDiv, divClass[which]);
jxl.setHtml(newDiv, jxl.sprintf(template[which], nextIdx[which]));
addChangeHandler(newDiv);
mainDiv[which].appendChild(newDiv);
}
function adjustAddLink(which) {
jxl.display("uiAdd" + which, count(which) < gCfg[which].max);
}
function doDelete(which, btn) {
var div = btn.parentNode;
while (div && !jxl.hasClass(div, divClass[which])) {
div = div.parentNode;
}
if (div) {
mainDiv[which].removeChild(div);
}
}
function clickTarget(evt) {
var tgt = jxl.evtTarget(evt);
if (tgt) {
var id = tgt.id || "";
if (id.indexOf("uiAdd") == 0 || id.indexOf("uiDelete") == 0) {
return tgt;
}
}
return jxl.evtTarget(evt, "button");
}
function clickHandler(evt) {
var tgt = clickTarget(evt);
var id = (tgt && tgt.id) || "";
if (id == "uiAddnumber") {
gDirty = true;
doAdd('number');
adjustAddLink('number');
return jxl.cancelEvent(evt);
}
if (id.indexOf("uiDeletenumber") == 0) {
gDirty = true;
doDelete('number', tgt);
if (prioSelect) {
jxl.deleteOption(prioSelect, id.replace("uiDelete", ""));
updatePrioValues();
}
adjustAddLink('number');
return jxl.cancelEvent(evt);
}
if (id == "uiAddemail") {
gDirty = true;
doAdd('email');
adjustAddLink('email');
return jxl.cancelEvent(evt);
}
if (id.indexOf("uiDeleteemail") == 0) {
gDirty = true;
doDelete('email', tgt);
adjustAddLink('email');
return jxl.cancelEvent(evt);
}
}
function changeHandler(evt) {
var tgt = jxl.evtTarget(evt);
var name = tgt.name || "";
if (name.indexOf("number") == 0 && name.indexOf("numbertype") != 0) {
gDirty = true;
if (prioSelect) {
if (tgt.value == "" && jxl.getValue(prioSelect) == name) {
jxl.setValue(prioSelect, "none");
}
jxl.updateOptions(prioSelect, name, tgt.value);
updatePrioValues();
if (tgt.value.indexOf("@") >= 0) {
jxl.show("uiSipurihint");
}
}
}
else if (name.indexOf("email") == 0) {
gDirty = true;
}
else {
switch(name) {
case "prionumber":
gDirty = true;
updatePrioValues();
break;
case "code":
case "vanity":
gDirty = true;
savePrioValues();
break;
case "entryname":
case "category":
gDirty = true;
break;
}
}
}
function addChangeHandler(newDiv) {
if (form.addEventListener) {
if (!newDiv) {
jxl.addEventHandler(form, "change", changeHandler);
}
}
else {
if (newDiv) {
var elems = jxl.walkDom(newDiv, "input");
}
else {
var elems = form.elements;
}
for (var i = 0, len = elems.length; i < len; i++) {
jxl.addEventHandler(elems[i], "change", changeHandler);
}
}
}
var toDisable;
var addnumBtns;
function waitForAddnum(evt) {
var tgt = jxl.evtTarget(evt);
var id = (tgt.id || "").replace("uiAddnumbtn", "");
var inputId = "uiNumber" + id;
var newNumber = jxl.getValue("uiAddnumNumber") || gCfg.addnum;
jxl.setValue(inputId, newNumber);
jxl.setHtml("uiAddnumexplain", "");
for (var i = 0; i < toDisable.length; i++) {
jxl.disableNode(toDisable[i], false);
}
jxl.addOption(prioSelect, "number" + id, newNumber);
updatePrioValues();
if (gCfg.addnum.indexOf("@") >= 0) {
jxl.show("uiSipurihint");
}
jxl.removeClass(form, "addnum");
for (var i = 0; i < addnumBtns.length; i++) {
jxl.removeEventHandler(addnumBtns[i], 'click', waitForAddnum);
var parent = addnumBtns[i].parentNode;
if (parent) {
parent.removeChild(addnumBtns[i]);
}
}
addChangeHandler();
jxl.addEventHandler(form, "click", clickHandler);
}
if (gCfg.addnum) {
toDisable = jxl.getByClass("disableif_addnum", form);
for (var i = 0; i < toDisable.length; i++) {
jxl.disableNode(toDisable[i], true);
}
addnumBtns = jxl.getByClass("addnumbtn", form);
for (var i = 0; i < addnumBtns.length; i++) {
jxl.addEventHandler(addnumBtns[i], 'click', waitForAddnum);
}
}
else {
addChangeHandler();
jxl.addEventHandler(form, "click", clickHandler);
}
}
ready.onReady(initFormHandler);
ready.onReady(initWarnIfDirtyHandler);
ready.onReady(ajaxValidation({}));
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.out(box.glob.script) ?>"
class="narrow<?lua write_form_class() ?>"
>
<div class="disableif_addnum">
<?lua href.default_submit('apply') ?>
<?lua write_error() ?>
<?lua write_hidden_values() ?>
<?lua write_entryname_input() ?>
</div>
<div class="formular">
<h4>{?7613:392?}</h4>
</div>
<div id="uiNumbers">
<?lua write_numbers() ?>
</div>
<div class="disableif_addnum">
<?lua write_add_numbers_link() ?>
<?lua write_sipuri_hint() ?>
<?lua write_numberplus() ?>
<div id="uiEmails">
<?lua write_emails() ?>
</div>
<?lua write_add_emails_link() ?>
</div>
<div id="btn_form_foot">
<button class="disableif_addnum" type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
