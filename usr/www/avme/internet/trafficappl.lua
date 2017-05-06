<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_internet_filter_listen.html"
dofile("../templates/global_lua.lua")
require("http")
require("general")
require("cmtable")
g_remoteData = {}
g_error_3165 = ""
function read_box_values()
g_remoteData.error = ""
g_remoteData.filter_netbios=box.query("connection0:settings/filter_netbios")
g_remoteData.filter_teredo=box.query("connection0:settings/filter_teredo")
g_remoteData.appl_list = general.listquery("netapp:settings/profile/list(predefined,name)")
if (g_remoteData.appl_list and #g_remoteData.appl_list > 0) then
for index,value in ipairs(g_remoteData.appl_list) do
local protocol_list = ""
local remote_protocol_list = general.listquery("netapp:settings/"..value._node.."/rules0/entry/list(protocol)")
if (remote_protocol_list and #remote_protocol_list > 0) then
for index2,value2 in ipairs(remote_protocol_list) do
if not (string.find(protocol_list, value2.protocol)) then
protocol_list = protocol_list..value2.protocol..", "
end
end
protocol_list = string.sub(protocol_list, 0, #protocol_list - 2)
end
g_remoteData.appl_list[index].protocol_list = protocol_list
end
end
end
read_box_values()
function refill_user_input()
g_remoteData.filter_netbios = box.post.filter_netbios and "1" or "0"
g_remoteData.filter_teredo = box.post.filter_teredo and "1" or "0"
end
function get_netbios_checked()
if g_remoteData.filter_netbios == "1" then
return "checked"
end
return ""
end
function get_teredo_checked()
if g_remoteData.filter_teredo == "1" then
return "checked"
end
return ""
end
function write_appl_table()
local onclick = "onDeleteClick()"
if (g_remoteData.appl_list and #g_remoteData.appl_list > 0) then
for index,value in ipairs(g_remoteData.appl_list) do
if value.predefined == "0" or value.predefined == "1" and not config.DOCSIS then
box.out("<tr><td>"..box.tohtml(value.name).."</td><td> "..box.tohtml(value.protocol_list).."</td>")
write_button_td(value, "/css/default/images/bearbeiten.gif", "edit_protocol", "edit", [[{?txtIconBtnEdit?}]])
write_button_td(value, "/css/default/images/loeschen.gif", "delete_protocol", "delete", [[{?txtIconBtnDelete?}]], onclick)
box.out("</tr>")
end
end
else
box.out([[<tr><td colspan="5" class="txt_center">{?385:342?}</td></tr>]])
end
end
function write_button_td(value, icon, id, name, label, handler)
box.out([[<td class="buttonrow">]])
if (value.predefined == "0") then
box.out(general.get_icon_button(icon, id, name, value._node, label, handler))
end
box.out([[</td>]])
end
function show_appl_list()
local result = true
if box.query("box:settings/opmode")=="opmode_eth_ipclient" then result = false end
if box.query("box:settings/opmode") == "opmode_modem" then result = false end
if config.USB_GSM and box.query("umts:settings/enabled") == '1' then result = true end
if not general.is_expert() then result = false end
return result
end
function save()
local ctlmgr_save={}
if not config.DOCSIS then
cmtable.save_checkbox(ctlmgr_save, "connection0:settings/filter_netbios", "filter_netbios")
end
cmtable.save_checkbox(ctlmgr_save, "connection0:settings/filter_teredo", "filter_teredo")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
end
refill_user_input()
end
function show_appl(post)
local param = {}
param[1] = http.url_param('appl_id', post.edit)
http.redirect(href.get('/internet/trafficappl_edit.lua', unpack(param)))
end
if next(box.post) then
if box.post.btn_cancel then
elseif box.post.delete then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "netapp:command/"..box.post.delete, "delete")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 3165 and err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
refill_user_input()
elseif err == 3165 then
g_error_3165 = msg
else
read_box_values()
end
elseif box.post.new_appl then
show_appl(box.post)
elseif box.post.edit then
show_appl(box.post)
elseif box.post.apply then
save()
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
span.label {
display: inline-block;
width: 250px;
margin-right: 6px;
vertical-align: middle;
}
</style>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" class="narrow" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
<?lua if menu.show_page["/internet/trafficprio.lua"] then
box.out([[ {?385:552?} ]])
else
box.out([[{?385:931?}]])
end ?>
</p>
<hr>
<h4>{?385:981?}</h4>
<p>
{?385:975?}
</p>
<p>
{?385:239?}
</p>
<div class="formular">
<p>
<span class="label">{?385:767?}</span>
<a class="textlink" href="<?lua href.write('/internet/kids_urllist.lua', http.url_param('listtype', 'white')) ?>">
{?385:308?}
</a>
</p>
<p>
<span class="label">{?385:122?}</span>
<a class="textlink" href="<?lua href.write('/internet/kids_urllist.lua', http.url_param('listtype', 'black')) ?>">
{?385:825?}
</a>
</p>
<p>
<span class="label">{?385:925?}</span>
<a class="textlink" href="<?lua href.write('/internet/kids_blockedip_list.lua') ?>">
{?385:816?}
</a>
</p>
</div>
<?lua
if show_appl_list() then box.out([[
<hr>
<h4>]]..box.tohtml([[{?385:564?}]])..[[</h4>
<p >
]]..
box.tohtml([[{?385:114?}]])
..[[
</p>
<div class="formular">
<table class="zebra" id="uiApplList">
<tr class="thead">
<th class="sortable">]]..box.tohtml([[{?385:85?}]])..[[<span class="sort_no">&nbsp;</span></th>
<th class="sortable">]]..box.tohtml([[{?385:307?}]])..[[<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr> ]])
write_appl_table()
box.out([[
</table>
<p class="innerbutton">
<button type="submit" name="new_appl" >]]..box.tohtml([[{?385:753?}]])..[[</button>
</p>
</div>]])
box.out([[
<div class="formular">
<span class="hintMsg">]]..box.tohtml([[{?txtHinweis?}]])..[[</span>
<p>]]..box.tohtml([[{?385:44?}]])..[[</p>
</div>]])
end
if general.is_expert() then box.out([[
<hr>
<h4>]]..box.tohtml([[{?385:572?}]])..[[</h4>
]])
if not config.DOCSIS then box.out([[
<div>
<input type="checkbox" id="uiFilterNetbios" name="filter_netbios" ]]..get_netbios_checked() .. [[>
<label for="uiFilterNetbios">]]..box.tohtml([[{?385:983?}]])..[[</label>
</div>
<div class="formular">
<p>
]]..box.tohtml([[{?385:933?}]])..[[
</p>
</div> ]])
end
box.out([[
<div>
<input type="checkbox" id="uiFilterTeredo" name="filter_teredo" ]]..get_teredo_checked() .. [[>
<label for="uiFilterTeredo">]]..box.tohtml([[{?385:458?}]])..[[</label>
</div>
<div class="formular">
<p>
]]..box.tohtml([[{?385:726?}]])..[[
</p>
</div> ]])
end
box.out(g_remoteData.error)
?>
<?lua
if general.is_expert() then
box.out([[
<div id="btn_form_foot">
<button type="submit" name="apply" >]]..box.tohtml([[{?txtApply?}]])..[[</button>
<button type="submit" name="btn_cancel" >]]..box.tohtml([[{?txtCancel?}]])..[[</button>
</div>
]])
end
?>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript">
var sort=sorter();
function onDeleteClick(){
var check = confirm("{?385:493?}");
if (!check)
return false;
}
function initTableSorter() {
sort.init("uiApplList");
}
function init() {
var err_message = "<?lua box.out(tostring(g_error_3165)) ?>";
if (err_message.length > 0)
{
alert(err_message);
}
}
ready.onReady(init);
ready.onReady(initTableSorter);
</script>
<?include "templates/html_end.html" ?>
