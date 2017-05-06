<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_system_import_uebernahme.html"
g_menu_active_page = "/system/import.lua"
g_menu_active_showtabs = true
dofile("../templates/global_lua.lua")
require"dbg"
require"html"
require"general"
require"cmtable"
require"js"
local list = general.listquery(
"cfgtakeover:settings/cfgtakeover/list("
.. "gui_text,do_takeover"
.. ",add1_text,add2_text,add3_text,add4_text,add5_text,add6_text"
.. ",add7_text,add8_text,add9_text,add10_text"
.. ",msgbox_text"
.. ")"
)
local function show_list()
local cfg_ok = box.get.cfg_ok or box.post.cfg_ok
return cfg_ok and #list > 0
end
local function add_text(item)
local span = html.span{class="addtext"}
local txt
local cnt = 0
for t = 1, 10 do
txt = item['add' .. t .. '_text']
if #txt > 0 then
cnt = cnt + 1
span.add(txt, html.br{})
end
end
if cnt > 0 then
return span
end
end
function write_checkboxes()
if show_list() then
if #list > 1 then
html.div{
html.input{type="checkbox", name="all", id="uiAll"},
html.label{['for']="uiAll",
[[{?2016:341?}]]
}
}.write()
html.br{}.write()
end
for i, item in ipairs(list) do
local div = html.div{}
local cbox = html.input{type="checkbox"}
cbox.name = item._node
cbox.id = "uiCheck" .. item._node
if item.do_takeover == "1" then
cbox.checked = ""
end
div.add(cbox)
div.add(html.label{["for"]=cbox.id, item.gui_text or ""})
local addtext = add_text(item)
if addtext then
div.class = "formular grid"
div.add(addtext)
else
div.class = "formular"
end
div.write()
end
end
end
local function split_msgbox_text(msgbox_text)
local id, txt
if msgbox_text and #msgbox_text > 0 then
txt = msgbox_text
if txt:find("msg%d%d") == 1 then
id = txt:sub(1, 5)
txt = txt:sub(6)
end
end
return txt, id
end
function write_msg_list_js()
local result = {}
local msgid, txt
if show_list() then
for i, item in ipairs(list) do
txt, msgid = split_msgbox_text(item.msgbox_text)
result[item._node] = {txt=txt, msgid=msgid}
end
end
box.out(js.object(result))
end
function write_state_class()
if show_list() then
box.out(" listnotempty")
else
box.out(" listempty")
end
end
function write_apply_button()
if show_list() then
html.button{type="submit", name="apply",
[[{?txtApply?}]]
}.write()
end
end
if box.post.cancel then
http.redirect("/system/import.lua")
elseif box.post.apply then
local saveset = {}
local atleast_one = false
for i, item in ipairs(list) do
atleast_one = atleast_one or box.post[item._node]
cmtable.add_var(saveset,
"cfgtakeover:settings/" .. item._node .. "/do_takeover",
box.post[item._node] and "1" or "0"
)
end
local err, msg = box.set_config(saveset)
if atleast_one then
http.redirect(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
else
http.redirect(href.get("/system/import.lua"))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.listempty .hideif_listempty,
.listnotempty .hideif_listnotempty {
display: none;
}
span.addtext {
display: inline-block;
border: 1px solid #c6c7be;
width: 480px;
vertical-align: top;
padding: 2px;
}
</style>
<script type="text/javascript">
function addClickHandlers(list) {
var done = {};
var cBoxes = {};
var frm = document.forms['mainform'];
if (frm) {
frm = frm.elements;
}
if (!frm) {
return;
}
for (var name in list) {
if (list.hasOwnProperty(name)) {
var cbox = frm[name];
if (cbox) {
cBoxes[name] = cbox;
if (list[name].txt) {
jxl.addEventHandler(cbox, 'click', msgOnClickHandler(list[name]));
}
}
}
}
jxl.addEventHandler("uiAll", "click", onClickAll);
function onClickAll(evt) {
var cbox = jxl.evtTarget(evt);
if (cbox) {
var messages = [];
for (var name in cBoxes) {
cBoxes[name].checked = cbox.checked;
if (cbox.checked) {
var msg = list[name];
if (msg && msg.txt) {
if (!msg.msgid || !done[msg.msgid]) {
messages.push(msg.txt);
}
}
}
}
if (messages.length > 0) {
alert(messages.join("\n\n"));
}
}
}
function msgOnClickHandler(msg) {
var handler = function(evt) {
var cbox = jxl.evtTarget(evt);
if (msg.msgid && done[msg.msgid]) {
jxl.removeEventHandler(cbox, 'click', handler);
}
else {
if (cbox.checked) {
alert(msg.txt);
if (msg.msgid) {
done[msg.msgid] = true;
}
}
}
};
return handler;
}
}
ready.onReady(function() {
addClickHandlers({<?lua write_msg_list_js() ?>})
});
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="/system/cfgtakeover_edit.lua"
class="<?lua write_state_class() ?>">
<?lua href.default_submit('apply') ?>
<div class="hideif_listempty">
<p>
{?2016:989?}
</p>
<br>
<div>
<?lua write_checkboxes() ?>
</div>
<hr>
<strong>{?2016:206?}</strong>
<p>{?2016:875?}</p>
<p>{?2016:74?}</p>
</div>
<div class="hideif_listnotempty">
<p>
{?2016:250?}
</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_apply_button() ?>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
