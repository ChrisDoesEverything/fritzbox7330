<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_internet_prio.html"
dofile("../templates/global_lua.lua")
require("http")
require("general")
require("cmtable")
g_realtime = "1"
g_prio = "2"
g_background = "4"
g_remoteData = {}
function read_box_values()
g_remoteData.rule_list = general.listquery("trafficprio:settings/user/list(type,ip,profile)")
local device_list = general.listquery("landevice:settings/landevice/list(ip,name)")
g_remoteData.device_list_associative = {}
for index,value in ipairs(device_list) do
g_remoteData.device_list_associative[value.ip] = value
end
local profile_list = general.listquery("netapp:settings/profile/list(name,internal)")
g_remoteData.profile_list_associative = {}
for index,value in ipairs(profile_list) do
g_remoteData.profile_list_associative[value.name] = value
end
end
read_box_values()
function get_device_name(ip, internal)
if (ip=="0.0.0.0") then
if (internal == "0") then
return [[{?3926:216?}]]
else
return [[{?3926:504?}]]
end
end
if (g_remoteData.device_list_associative[ip]) then
return g_remoteData.device_list_associative[ip].name
else
return [[{?3926:356?}]]
end
end
function write_rule_table(type)
local no_rule_txt = [[{?3926:407?}]]
if (type == g_prio) then
no_rule_txt = [[{?3926:104?}]]
elseif (type == g_background) then
no_rule_txt = [[{?3926:506?}]]
end
local no_rule = true
for index,value in ipairs(g_remoteData.rule_list) do
if (value.type == type) then
no_rule = false
local onclick = "onDeleteClick()"
local internal = "1"
local profile_name = "{?3926:701?}"
if (g_remoteData.profile_list_associative[value.profile]) then
internal = g_remoteData.profile_list_associative[value.profile].internal
profile_name = value.profile
end
box.out("<tr><td>"..box.tohtml(get_device_name(value.ip, internal)).."</td><td> "..box.tohtml(profile_name).."</td>")
write_button_td(value, "/css/default/images/bearbeiten.gif", "edit_protocol", "edit", [[{?txtIconBtnEdit?}]], "", internal == "1")
write_button_td(value, "/css/default/images/loeschen.gif", "delete_protocol", "delete", [[{?txtIconBtnDelete?}]], onclick)
box.out("</tr>")
end
end
if (no_rule) then
box.out([[<tr><td colspan="5" class="txt_center">]]..no_rule_txt..[[</td></tr>]])
end
end
function write_button_td(value, icon, id, name, label, handler, empty)
box.out([[<td class="buttonrow">]])
if not (empty) then
box.out(general.get_icon_button(icon, id, name, value._node, label, handler))
end
box.out([[</td>]])
end
function show_appl(type, user_id)
local param = {}
if (user_id and user_id ~= "") then
param[1] = http.url_param('user_id', user_id)
else
param[1] = http.url_param('type', type)
end
http.redirect(href.get('/internet/trafficprio_edit.lua', unpack(param)))
end
if next(box.post) then
if box.post.delete then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "trafficprio:command/"..box.post.delete, "delete")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
refill_user_input()
else
read_box_values()
end
elseif box.post.new_appl then
show_appl(box.post.new_appl)
elseif box.post.edit then
local user_list = g_remoteData.rule_list
local type = ""
for index,value in ipairs(user_list) do
if (value._node == box.post.edit) then
type = value.type
end
end
show_appl(type, box.post.edit)
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" class="narrow" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?3926:200?}
</p>
<p>
{?3926:846?}
</p>
<hr>
<h4>{?3926:930?}</h4>
<p>
{?3926:542?}
<br>
{?3926:433?}
</p>
<div class="formular">
<table id="uiRealtimeList" class="zebra">
<tr class="thead">
<th class="sortable">{?3926:929?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3926:117?}<span class="sort_no">&nbsp;</span></th>
<th></th>
<th></th>
</tr>
<?lua write_rule_table(g_realtime) ?>
</table>
<p class="innerbutton">
<button type="submit" name="new_appl" value="<?lua box.out(g_realtime)?>">{?3926:607?}</button>
</p>
</div>
<hr>
<h4>{?3926:592?}</h4>
<p>
{?3926:774?}
<br>
{?3926:350?}
</p>
<div class="formular">
<table id="uiPrioApp"class="zebra">
<tr class="thead">
<th class="sortable">{?3926:420?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3926:49?}<span class="sort_no">&nbsp;</span></th>
<th></th>
<th></th>
</tr>
<?lua write_rule_table(g_prio)?>
</table>
<p class="innerbutton">
<button type="submit" name="new_appl" value="<?lua box.out(g_prio)?>">{?3926:470?}</button>
</p>
</div>
<hr>
<h4>{?3926:904?}</h4>
<p>{?3926:361?}</p>
<div class="formular">
<table id="uiBackApp" class="zebra">
<tr class="thead">
<th class="sortable">{?3926:748?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3926:59?}<span class="sort_no">&nbsp;</span></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua write_rule_table(g_background) ?>
</table>
<p class="innerbutton">
<button type="submit" name="new_appl" value="<?lua box.out(g_background)?>">{?3926:703?}</button>
</p>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort_PrioApp = sorter();
var sort_BackApp = sorter();
var sort_RealTime = sorter();
function onDeleteClick(){
var check = confirm("{?3926:474?}");
if (!check)
return false;
}
function initTableSorter() {
sort_PrioApp.init(uiPrioApp);
sort_PrioApp.sort_table_again(0);
sort_BackApp.init(uiBackApp);
sort_BackApp.sort_table_again(0);
sort_RealTime.init(uiRealtimeList);
sort_RealTime.sort_table_again(0);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/html_end.html" ?>
