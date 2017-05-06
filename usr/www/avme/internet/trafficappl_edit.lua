<?lua
g_page_type = "all"
g_page_help = "hilfe_internet_prio_neue-nwanwendung.html"
g_page_title = "{?718:229?}"
g_menu_active_page = "/internet/trafficappl.lua"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("cmtable")
g_remoteData = {}
function read_box_values()
g_remoteData.error = ""
local table_index = "get"
if (box.post and box.post.appl_id) then
table_index = "post"
end
if (box[table_index]) then
if (box[table_index].appl_id) then
g_remoteData.appl_id = box[table_index].appl_id
end
g_remoteData.is_new = g_remoteData.appl_id == nil or g_remoteData.appl_id == "" or g_remoteData.appl_id == "xxx"
if g_remoteData.is_new then
g_remoteData.appl_id=box.query("netapp:settings/profile/newid")
g_remoteData.name = ""
else
g_remoteData.name = box.query("netapp:settings/"..g_remoteData.appl_id.."/name")
g_remoteData.protocol_list = general.listquery("netapp:settings/"..g_remoteData.appl_id.."/rules0/entry/list(protocol,srcport,srcendport,dstport,dstendport)")
end
end
end
read_box_values()
function refill_user_input()
if (box.post) then
if (box.post.name) then
g_remoteData.name = box.post.name
end
end
end
function name_validate()
local appl_id = box.post.appl_id
if (g_remoteData.appl_id) then
appl_id = g_remoteData.appl_id
end
local app_list = general.listquery("netapp:settings/profile/list(name)")
local name_list = ""
for index,value in ipairs(app_list) do
if (appl_id ~= value._node) then
name_list = name_list .. "," .. value.name
end
end
return "not_equals(uiNameInput/name,"..name_list..",name_err)"
end
g_val = {
prog = name_validate()..[[
not_empty(uiNameInput/name, name_err)
]]
}
g_val_num_protocols = {
prog = [[
not_equals(uiNumProtocols/num_protocols, 0, table_err)
]]
}
g_txtNoName = "{?718:831?}"
g_txtCheckName = "{?718:772?}"
val.msg.name_err = {
[val.ret.empty] = g_txtNoName,
[val.ret.notfound] = g_txtNoName,
[val.ret.format] = g_txtCheckName,
[val.ret.outofrange] = g_txtCheckName,
[val.ret.equalerr] = "{?718:638?}"
}
val.msg.table_err = {
[val.ret.empty] = "{?718:586?}",
[val.ret.equalerr] = "{?718:224?}"
}
function write_rule_table()
local onclick = "onDeleteClick()"
box.out([[<tr class="thead"><th class="sortable">]])
box.html([[{?718:879?}]])
box.out([[<span class="sort_no">&nbsp;</span></th><th class="sortable">]])
box.html([[{?718:823?}]])
box.out([[<span class="sort_no">&nbsp;</span></th><th class="sortable">]])
box.html([[{?718:470?}]])
box.out([[
<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
]])
if (g_remoteData.protocol_list and #g_remoteData.protocol_list > 0) then
for index,value in ipairs(g_remoteData.protocol_list) do
box.out("<tr><td>"..box.tohtml(value.protocol).."</td><td> "..get_ports(value.srcport, value.srcendport).."</td><td>"..get_ports(value.dstport, value.dstendport) .."</td><td>"
..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_protocol", "edit", value._node, box.tohtml([[{?txtIconBtnEdit?}]]), "", b_disabled)..
"</td><td>"
.. general.get_icon_button("/css/default/images/loeschen.gif", "delete_protocol", "delete", value._node, box.tohtml([[{?txtIconBtnDelete?}]]), onclick, b_disabled)
.."</td></tr>")
end
else
box.out([[<tr><td colspan="5" class="txt_center"><p>]]..box.tohtml([[{?718:501?}]])..[[</p></td></tr>]])
end
end
function get_ports(startport, endport)
local str="";
if (startport=="0" and endport=="0") then
str = str.."{?718:252?}"
elseif (endport=="0") then
str=str..startport
elseif (startport=="0") then
str=str..endport
else
str=startport.."-"..endport
end
return str
end
function save_appl(appl_id, name, dst_url)
if val.validate(g_val) == val.ret.ok then
if (box.post.appl_id and box.post.name) then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "netapp:settings/"..appl_id.."/name", name)
if (g_remoteData.is_new) then
cmtable.add_var(ctlmgr_save, "netapp:settings/"..appl_id.."/predefined", "0")
cmtable.add_var(ctlmgr_save, "netapp:settings/"..appl_id.."/internal", "0")
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
refill_user_input()
else
if (dst_url ~= nil and dst_url ~= "") then
http.redirect(href.get(dst_url))
end
return true
end
end
else
refill_user_input()
end
return false
end
function num_protocols_value()
if (g_remoteData.protocol_list and #g_remoteData.protocol_list > 0) then
return tostring(#g_remoteData.protocol_list)
end
return "0"
end
function show_protocol(post)
local param = {}
param[1] = http.url_param('appl_id', post.appl_id)
param[2] = http.url_param('rule_id', post.edit)
http.redirect(href.get('/internet/trafficprotocol_edit.lua', unpack(param)))
end
if next(box.post) then
if box.post.btn_cancel then
http.redirect(href.get('/internet/trafficappl.lua'))
elseif box.post.delete then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "netapp:command/"..g_remoteData.appl_id.."/rules0/"..box.post.delete, "delete")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
else
read_box_values()
end
elseif box.post.new_protocol then
if (save_appl(box.post.appl_id, box.post.name)) then
show_protocol(box.post, "")
end
elseif box.post.edit then
show_protocol(box.post, "Edit")
elseif box.post.apply then
if val.validate(g_val_num_protocols) == val.ret.ok then
save_appl(g_remoteData.appl_id, box.post.name, "/internet/trafficappl.lua")
else
refill_user_input()
end
end
else
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?718:765?}</p>
<p>
{?718:745?}
<input type="text" id="uiNameInput" name="name" value="<?lua box.html(g_remoteData.name)?>">
</p>
<?lua val.write_html_msg(g_val_num_protocols, "cmd_vorn", "uiNameInput")?>
<?lua val.write_html_msg(g_val, "cmd_vorn", "uiNameInput")?>
<p>
{?718:126?}
</p>
<div class="formular">
<table class="zebra" id="uiRulelist">
<?lua write_rule_table()?>
</table>
<?lua val.write_html_msg(g_val_num_protocols, "cmd_vorn", "uiNumProtocols")?>
</div>
<p class="innerbutton">
<button type="submit" name="new_protocol" onclick="apply_clicked = false">{?718:486?}</button>
</p>
<?lua box.out(g_remoteData.error) ?>
<div id="btn_form_foot">
<input type="hidden" name="appl_id" value="<?lua box.html(g_remoteData.appl_id)?>">
<input type="hidden" id="uiNumProtocols" name="num_protocols" value="<?lua box.html(num_protocols_value())?>" >
<button type="submit" name="apply" id="uiBtnOK" onclick="apply_clicked = true">{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" id="uiBtnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var sort = sorter();
var apply_clicked = true;
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
if (apply_clicked) {
<?lua
val.write_js_checks_no_active(g_val_num_protocols)
?>
}
}
function onDeleteClick(){
var check = confirm("{?718:267?}");
if (!check)
return false;
}
function init() {
}
function initTableSorter() {
sort.init("uiRulelist");
sort.sort_table_again(0);
}
ready.onReady(val.init(onNumEditSubmit, "apply", "main_form" ));
ready.onReady(val.init(onNumEditSubmit, "new_protocol", "main_form" ));
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
