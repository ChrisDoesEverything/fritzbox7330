<?lua
g_page_type = "wizard"
g_page_title = box.tohtml( [[{?4777:799?}]])
--g_page_help = "hilfe_smart_home_overview.html"
dofile("../templates/global_lua.lua")
g_menu_active_page = "/net/home_auto_overview.lua"
require("elem")
require("menu")
require("cmtable")
require("newval")
require("general")
require("libaha")
require("ha_func_lib")
require("ha_switch_timer")
g_back_to_page = http.get_back_to_page( "/net/home_auto_overview.lua" )
g_has_time = (box.query("box:status/localtime") ~= "")
g_current_group_id = nil
g_current_state = nil
g_current_group = nil
g_current_group_timer_state = nil
g_current_device_count = 0
g_current_selected_count = 0
g_sz_group_switch_kind = [[manuell]]
g_sz_timer_ctrl_id = box.tohtml( [[uiTimerWeekly]])
function init_page_vars( state, device)
if ( (state == nil) and (device == nil)) then
return false
end
g_current_group_id = device
g_current_state = state
if (device ~= nil) then
if ( tonumber(device) ~= nil) then
if ( tostring(device) ~= [[0]] ) then
g_current_group = aha.GetGroup( tonumber( device))
else
g_current_group = {}
g_current_group.ID = 0
g_current_group.Name = [[]]
g_current_group.GroupHash = [[0]]
g_current_group.MasterDeviceID = 0
end
if ( tostring(state) == [[edit]]) then
g_page_title = box.tohtml( [[{?4777:944?}]])
g_page_type = "all"
end
else
g_current_group = {}
g_current_group.ID = 0
g_current_group.Name = [[]]
g_current_group.GroupHash = [[0]]
g_current_group.MasterDeviceID = 0
end
else
g_current_group = {}
g_current_group.ID = 0
g_current_group.Name = [[]]
g_current_group.GroupHash = [[0]]
g_current_group.MasterDeviceID = 0
end
g_current_group_timer_state = aha.GetSwitchTimer( tonumber(g_current_group.ID))
return true
end
function write_selectable_devices( t_content, sz_group_name, sz_group_hash)
local l_t_retcode = {}
local l_current_selected = 0
if ( t_content ~= nil and #t_content > 0 ) then
for i=1, #t_content do
if (( ha_func_lib.is_outlet(t_content[i].FunctionBitMask)) and
( not( ha_func_lib.is_virtual_group_device( t_content[i].DeviceType, t_content[i].FunctionBitMask))) ) then
local b_selected_device = false
local l_other_group_name = [[]];
if ( tonumber(t_content[i].GroupHash) ~= 0) then
l_other_group_name = ha_func_lib.get_groupname_by_hash( t_content[i].GroupHash)
end
if ( (sz_group_name ~= [[]] ) and ( sz_group_name == l_other_group_name)) then
b_selected_device = true
l_current_selected = l_current_selected + 1
end
table.insert( l_t_retcode, { ID=tostring(t_content[i].ID), GroupName=tostring(l_other_group_name)} )
write_device_to_select( sz_group_name, t_content[i].ID, t_content[i].Name, b_selected_device, l_other_group_name)
end
end
end
return l_t_retcode, l_current_selected
end
function write_device_to_select( sz_group_name, n_device_id, sz_device_name, b_set_checked, sz_member_of_other_group)
box.out( [[<p>]])
box.out( elem._checkbox( "selected_group_device_"..tostring(n_device_id), "ui_SelectGroupDevice_"..tostring(n_device_id), tostring(n_device_id), b_set_checked, [[onclick="OnChange_SelectedDevice(this.value,this.checked)"]]))
box.out( [[&nbsp;]])
local l_device_name = sz_device_name
if ((sz_member_of_other_group ~= [[]]) and (sz_group_name ~= sz_member_of_other_group)) then
l_device_name = sz_device_name..box.tohtml( [[{?4777:808?}]])..[["]]..box.tohtml(sz_member_of_other_group)..[["]]..box.tohtml( [[{?4777:321?}]])
end
box.out( elem._label( "ui_SelectGroupDevice_"..tostring(n_device_id), "Label_ui_SelectGroupDevice_"..tostring(n_device_id), l_device_name))
box.out( [[</p>]])
end
function write_last_group_of_device( t_state_list)
if ( t_state_list ~= nil and #t_state_list > 0 ) then
for i=1, #t_state_list do
box.out([[<input type="hidden" name="device_last_group_]]..box.tohtml(t_state_list[i].ID)..[[" value="]]..box.tohtml(t_state_list[i].GroupName)..[[">]])
end
end
end
function reset_group_member_settings( t_post)
local l_devicelist = aha.GetDeviceList()
if ( l_devicelist ~= nil and #l_devicelist > 0 ) then
for i=1, #l_devicelist do
if (( ha_func_lib.is_outlet(l_devicelist[i].FunctionBitMask)) and
( not( ha_func_lib.is_virtual_group_device( l_devicelist[i].DeviceType, l_devicelist[i].FunctionBitMask))) ) then
local n_device_id = l_devicelist[i].ID
local l_group_name = t_post["device_last_group_"..tostring(n_device_id)]
if ( l_group_name == nil) then
l_group_name = [[]]
end
aha.EditDeviceGroup( tonumber(n_device_id), l_group_name)
end
end
end
end
function update_group_member_settings( sz_group_name, t_post)
local l_devicelist = aha.GetDeviceList()
if ( l_devicelist ~= nil and #l_devicelist > 0 ) then
for i=1, #l_devicelist do
if (( ha_func_lib.is_outlet(l_devicelist[i].FunctionBitMask)) and
( not( ha_func_lib.is_virtual_group_device( l_devicelist[i].DeviceType, l_devicelist[i].FunctionBitMask))) ) then
local sz_groupname_to_store = [[]]
local n_device_id = l_devicelist[i].ID
local l_is_group_member = false
if ( (t_post["selected_group_device_"..tostring(n_device_id)] ~= nil) and (tostring( t_post["selected_group_device_"..tostring(n_device_id)]) == tostring(n_device_id))) then
l_is_group_member = true
sz_groupname_to_store = sz_group_name
else
l_is_group_member = false
local l_group_name = t_post["device_last_group_"..tostring(n_device_id)]
if ( l_group_name == nil) then
l_group_name = [[]]
end
if ( l_group_name ~= sz_group_name) then
sz_groupname_to_store = l_group_name
else
sz_groupname_to_store = [[]]
end
end
aha.EditDeviceGroup( tonumber(n_device_id), sz_groupname_to_store)
end
end
end
end
local l_page_state = nil
local l_group_device_id = nil
if ( next(box.get)) then
l_page_state = box.get.state
l_group_device_id = box.get.device
else
if ( next(box.post)) then
l_page_state = box.post.call_state
l_group_device_id = box.post.current_group_id
if ( box.post.cancel) then
if ( l_page_state == [[new]]) then
reset_group_member_settings( box.post)
end
http.redirect( [[/net/home_auto_overview.lua]])
end
end
end
if ( init_page_vars( l_page_state, l_group_device_id) == false) then
http.redirect( g_back_to_page )
end
local function val_prog()
newval.not_empty( "group_name","groupname_not_empty")
if newval.radio_check("select_group_switch","manuell") then
end
if newval.radio_check("select_group_switch","master") then
newval.value_unallowable("group_master_switch",0,"select_master_id_not_set")
end
if newval.radio_check("select_group_switch","automatic") then
<?include "lua/ha_switch_timer_val_prog.lua" ?>
end
end
newval.msg.groupname_not_empty = {
[newval.ret.notfound] = [[{?4777:699?}]],
[newval.ret.empty] = [[{?4777:756?}]],
}
newval.msg.select_master_id_not_set= {
[newval.ret.wrong] = [[{?4777:335?}]]
}
<?include "lua/ha_switch_timer_val_text.lua" ?>
g_val_result = newval.ret.ok
if ( box.post.validate == "apply") then
require("js")
local valresult, answer = newval.validate(val_prog)
g_val_result = valresult
box.out( js.table( answer))
box.end_page()
end
if ( next(box.post)) then
local saveset = {}
local l_call_oncal_register = false;
local l_sz_oncal_node = ""
local l_sz_last_enabled_timer = ""
if ( box.post.apply) then
if ( g_val_result == newval.ret.ok) then
if ( tostring(g_current_group.ID) == [[0]]) then
g_current_group.ID = box.post.current_group_id
end
local l_switched_by_master = ha_func_lib.group_switched_by_master( g_current_group.ID)
local l_group_timer_state = aha.GetSwitchTimer( tonumber(g_current_group.ID))
local l_b_automatic, l_sz_last_enabled_timer, l_sz_value = ha_func_lib.is_timer_active( l_group_timer_state)
if ( tostring(box.post.call_state) == [[edit]] ) then
update_group_member_settings( box.post.group_name_old, box.post)
end
if ( box.post.group_name_old ~= box.post.group_name) then
aha.SetName( tonumber(g_current_group.ID), tostring(box.post.group_name))
end
local l_selected_group_mode = box.post.select_group_switch
if ( tostring( l_selected_group_mode) == "manuell") then
if ( l_switched_by_master == true) then
-- aha.SetGroupMasterDevice( tonumber(g_current_group.ID), 0)
end
if ( l_b_automatic == true) then
ha_switch_timer.set_current_timer_inactive( g_current_group.ID, l_group_timer_state)
end
end
if ( tostring( l_selected_group_mode) == "master") then
if ( l_b_automatic == true) then
ha_switch_timer.set_current_timer_inactive( g_current_group.ID, l_group_timer_state)
end
aha.SetGroupMasterDevice( tonumber(g_current_group.ID), tonumber(box.post.group_master_switch))
end
if ( tostring( l_selected_group_mode) == "automatic") then
if ( l_switched_by_master == true) then
aha.SetGroupMasterDevice( tonumber(g_current_group.ID), 0)
end
local l_sz_current_timer_mode = box.post.switch_on_timer
l_sz_last_selected_timer, l_b_cal_was_enabled = ha_switch_timer.set_current_timer_inactive( g_current_group.ID, l_group_timer_state)
if config.TIMERCONTROL then
ha_switch_timer.save_timer_weekly( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
end
ha_switch_timer.save_timer_daily( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
ha_switch_timer.save_timer_zufall( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
ha_switch_timer.save_timer_countdown( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
ha_switch_timer.save_timer_rythmisch( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
ha_switch_timer.save_timer_single( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
ha_switch_timer.save_timer_sun_calendar( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post)
saveset, l_call_oncal_register, l_sz_oncal_node = ha_switch_timer.save_timer_calendar( l_sz_current_timer_mode, g_current_group, l_group_timer_state, box.post, l_sz_last_selected_timer)
if ( l_b_cal_was_enabled == true) then
saveset = ha_switch_timer.updating_oncal_struture( g_current_group, l_group_timer_state, box.post, saveset)
end
end
end
elseif ( box.post.reset_google_calender) then
local l_reset_cal_timer = {}
l_reset_cal_timer.enabled = tonumber(0)
l_reset_cal_timer.Calname = tostring( [[]] )
aha.SetSwitchTypeTimer( tonumber(g_current_group.ID), [[calendar]], l_reset_cal_timer)
aha.ResetSwitchCalTimer()
cmtable.add_var( saveset, [[oncal:command/do_sync]], [[reset]])
end
if ( g_val_result == newval.ret.ok) then
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
if ( box.post.apply) then
local l_url = [[/net/home_auto_overview.lua]]
if ( l_call_oncal_register == true) then
l_url = ha_switch_timer.get_url_for_oncal_register( g_current_group.ID, l_sz_oncal_node, l_sz_last_selected_timer)
end
http.redirect( l_url)
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
]])
end
if config.TIMERCONTROL then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/timer.css"/>
]])
end
?>
<link rel="stylesheet" type="text/css" href="/css/default/ha_switch_timer.css">
<style type="text/css">
</style>
<?include "templates/page_head.html" ?>
<form name="main_form" id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
box.out( [[<div id="ui_Show_WaitForGroup" style="display: none;" >]])
box.out( [[<div id="uiWait" class="wait">]])
box.out( [[<div id="uiWaitText">]])
box.out( [[<p>{?4777:933?}"<span id="ui_NewGroup_wait"></span>"{?4777:998?}</p>]])
box.out( [[</div>]])
box.out( [[<p class="waitimg"><img src="/css/default/images/wait.gif"></p>]])
box.out( [[<p>{?4777:355?}</p>]])
box.out( [[</div>]])
box.out( [[<div id="uiDone" class="wait" style="display:none;">]])
box.out( [[<div id="uiDoneText">]])
box.out( [[<p>{?4777:417?}"<span id="ui_NewGroup_done"></span>"{?4777:429?}</p>]])
box.out( [[</div>]])
box.out( [[<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>]])
box.out( [[</div>]])
box.out( [[<div id="uiDoneError" class="wait" style="display:none;">]])
box.out( [[<div id="uiDoneErrorText">]])
box.out( [[<p>{?4777:870?}"<span id="ui_NewGroup_error"></span>"{?4777:409?}</p>]])
box.out( [[</div>]])
box.out( [[<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<div id="ui_Show_InitGroup" style="display: none;" >]])
box.out( [[<p>{?4777:256?}</p>]])
box.out( [[<hr>]])
box.out( elem._label( "ui_GroupName", "Label_uiGroupName", [[{?4777:831?}]], [[width: 200px;]]))
box.out( elem._input_new( "text", "group_name", "ui_GroupName", g_current_group.Name, "35", nil, nil, [[]]))
box.out( [[<p>{?4777:987?}</p>]])
box.out( [[<div class="formular" >]])
local l_t_device_list = aha.GetDeviceList()
if ( l_t_device_list ~= nil) then
g_current_device_count = #l_t_device_list
l_t_group_state_device_list, g_current_selected_count = write_selectable_devices( l_t_device_list, g_current_group.Name, g_current_group.GroupHash)
end
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<div id="ui_Show_SetGroupTimer" style="display: none;" >]])
box.out( [[<hr>]])
box.out( [[<h4>{?4777:378?}</h4>]])
box.out( [[{?4777:632?}]] )
g_sz_group_switch_kind = [[manuell]]
local l_b_active, l_sz_timer_state_name, l_sz_value = ha_func_lib.is_timer_active( g_current_group_timer_state)
if ( ha_func_lib.group_switched_by_master( g_current_group.ID)) then
g_sz_group_switch_kind = [[master]]
else
if ( l_b_active == true) then
g_sz_group_switch_kind = [[automatic]]
end
end
box.out( [[<div class="formular">]])
box.out( [[<p>]])
box.out( elem._radio( "select_group_switch", "ui_SelectGroupSwitch_manuell", [[manuell]], ( g_sz_group_switch_kind == [[manuell]]), [[onclick="OnChange_SelectGroupSwitch('manuell')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "ui_SelectGroupSwitch_manuell", "Label_ui_SelectGroupSwitch_manuell", [[{?4777:956?}]]))
box.out( [[<div class="formular" id="uiShow_SelectGroupSwitch_manuell">]])
box.out( [[<p>Es ist keine automatische Schaltung konfiguriert, die Gruppe kann ausschließlich manuell geschaltet werden.</p>]])
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
local t_selectable_devices = ha_switch_timer.table_of_selectable_device( l_t_device_list)
box.out( elem._radio( "select_group_switch", "ui_SelectGroupSwitch_master", [[master]], ( g_sz_group_switch_kind == [[master]]), [[onclick="OnChange_SelectGroupSwitch('master')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "ui_SelectGroupSwitch_master", "Label_ui_SelectGroupSwitch_master", [[{?4777:906?}]]))
box.out( [[<div class="formular" id="uiShow_SelectGroupSwitch_master">]])
box.out( [[<p>{?4777:638?}</p>]])
box.out( elem._label( "ui_SelectSwitchAktor", "Label_ui_SelectSwitchAktor", [[{?4777:582?}]]))
box.out( elem._select( "group_master_switch", "ui_SelectSwitchAktor", t_selectable_devices, g_current_group.MasterDeviceID))
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[<p>]])
box.out( elem._radio( "select_group_switch", "ui_SelectGroupSwitch_automatic", [[automatic]], ( g_sz_group_switch_kind == [[automatic]]), [[onclick="OnChange_SelectGroupSwitch('automatic')"]] ))
box.out( [[&nbsp;]])
box.out( elem._label( "ui_SelectGroupSwitch_automatic", "Label_ui_SelectGroupSwitch_automatic", [[{?4777:514?}]]))
box.out( [[<div class="formular" id="uiShow_SelectGroupSwitch_automatic">]])
if config.TIMERCONTROL then
ha_switch_timer.write_html_timer_weekly( l_sz_timer_state_name, g_sz_timer_ctrl_id, g_current_group_timer_state)
end
ha_switch_timer.write_html_timer_daily( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
ha_switch_timer.write_html_timer_zufall( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
ha_switch_timer.write_html_timer_countdown( l_sz_timer_state_name, g_current_group.ID)
ha_switch_timer.write_html_timer_rythmisch( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
ha_switch_timer.write_html_timer_single( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
ha_switch_timer.write_html_timer_sun_calendar( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
ha_switch_timer.write_html_timer_calendar( l_sz_timer_state_name, g_current_group.ID, g_current_group_timer_state)
box.out( [[</div>]])
box.out( [[</p>]])
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<div id="btn_form_foot">]])
write_last_group_of_device( l_t_group_state_device_list)
if ( g_current_state == [[edit]]) then
box.out( [[<input type="hidden" name="group_name_old" id="ui_Old_GroupName" value="]]..box.tohtml(g_current_group.Name)..[[">]])
end
box.out( [[<input type="hidden" name="device_count" id="ui_deviceCount" value="]]..box.tohtml(g_current_device_count)..[[">]])
box.out( [[<input type="hidden" name="call_state" id="ui_CallState" value="]]..box.tohtml(g_current_state)..[[">]])
box.out( [[<input type="hidden" name="current_group_id" id="ui_GroupID" value="]]..box.tohtml(g_current_group.ID)..[[">]])
box.out( [[<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">]])
box.out( [[<button type="submit" name="apply" id="uiApply">{?4777:488?}</button>]])
box.out( [[<button type="submit" name="cancel" id="uiCancel">{?4777:924?}</button>]])
box.out( [[</div>]])
?>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/ha_sets.js?lang=<?lua box.out(config.language) ?>"></script>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
end
if config.TIMERCONTROL then
box.out([[<script type="text/javascript" src="/js/timer.js"></script>]])
end
?>
<script type="text/javascript">
var json = makeJSONParser();
var sidParam = buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
var g_ar_Of_Selected_Devices = new Array();
var g_nCurrentSelected = <?lua box.js(g_current_selected_count) ?>;
var g_szGroupSwitchKind = "<?lua box.js(g_sz_group_switch_kind) ?>";
<?lua
ha_switch_timer.init_js_section( g_current_group.ID, (config.TIMERCONTROL and g_has_time),
g_sz_timer_ctrl_id, g_current_group_timer_state, g_current_group.MasterDeviceID)
?>
<?include "js/ha_switch_timer.js" ?>
function sendRequest_CreatNewGroup( szGroupName) {
var url = encodeURI("/net/home_auto_query.lua");
var szData = sidParam;
szData += "&" + buildUrlParam( "command", "CreateNewGroup");
szData += "&" + buildUrlParam( "group_name", szGroupName);
szData += "&" + buildUrlParam( "selected_devices", g_nCurrentSelected);
for ( var i = 0; i < g_nCurrentSelected; i++) {
szData += "&" + buildUrlParam( "group_device_"+(i+1), g_ar_Of_Selected_Devices[i]);
}
ajaxPost( url, szData, cb_response_CreateNewGroup);
}
function cb_response_CreateNewGroup(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult == "1")) {
setTimeout( "sendRequest_GetGroupIdOf('"+response.GroupName+"')", 2000); // nach 2 sec.
} else {
jxl.display( "uiWait", false);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
}
function sendRequest_GetGroupIdOf( szGroupName) {
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "GetGroupId");
url += "&" + buildUrlParam( "group_name", szGroupName);
ajaxGet( url, cb_response_GetGroupIdOf)
}
function cb_response_GetGroupIdOf(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult == "1")) {
jxl.setValue( "ui_GroupID", response.GroupID);
OnChange_SelectGroupSwitch( "manuell")
jxl.display( "ui_Show_WaitForGroup", false);
jxl.display( "ui_Show_SetGroupTimer", true);
jxl.display( "uiApply", true);
jxl.display( "uiCancel", true);
} else {
jxl.display( "uiWait", false);
jxl.display( "uiDoneError", true);
jxl.display( "uiCancel", true);
}
}
function OnChange_SelectedDevice( szValue, bChecked) {
if ( jxl.getValue("ui_CallState") == "new") {
if ( bChecked == true) {
g_ar_Of_Selected_Devices[g_nCurrentSelected] = szValue;
} else {
var nCurPos = g_ar_Of_Selected_Devices.indexOf( szValue);
g_ar_Of_Selected_Devices.splice( nCurPos, 1);
}
g_nCurrentSelected = g_ar_Of_Selected_Devices.length;
} else {
if ( bChecked == true) {
g_nCurrentSelected += 1
} else {
g_nCurrentSelected -= 1
}
}
}
function OnChange_SelectGroupSwitch( szValue) {
jxl.display( "uiShow_SelectGroupSwitch_manuell",(szValue == "manuell"));
jxl.display( "uiShow_SelectGroupSwitch_master",(szValue == "master"));
jxl.display( "uiShow_SelectGroupSwitch_automatic",(szValue == "automatic"));
jxl.setChecked( "ui_SelectGroupSwitch_manuell", (szValue == "manuell"));
jxl.setChecked( "ui_SelectGroupSwitch_master", (szValue == "master"));
jxl.setChecked( "ui_SelectGroupSwitch_automatic", (szValue == "automatic"));
}
function onSubmit_AfterValidation() {
if ( g_nCurrentSelected <= 0) {
alert( "{?4777:994?}");
return false;
}
var bRetCode = false;
if ( jxl.getValue("ui_GroupID") == "0") {
var szGroupName = jxl.getValue( "ui_GroupName");
jxl.setText( "ui_NewGroup_wait", szGroupName);
jxl.setText( "ui_NewGroup_done", szGroupName);
jxl.setText( "ui_NewGroup_error", szGroupName);
jxl.display( "ui_Show_InitGroup", false);
jxl.display( "ui_Show_WaitForGroup", true);
jxl.display( "uiApply", false);
jxl.display( "uiCancel", false);
sendRequest_CreatNewGroup( szGroupName);
bRetCode = false;
} else {
bRetCode = true;
if ( jxl.getChecked( "ui_SelectGroupSwitch_automatic")) {
bRetCode = Extended_Validation_Automatic_Timer();
}
}
return bRetCode;
}
function init() {
var nGroupID = jxl.getValue( "ui_GroupID");
OnChange_SelectGroupSwitch( g_szGroupSwitchKind)
if ( jxl.getValue( "ui_CallState") == "new") {
jxl.display( "ui_Show_InitGroup", true);
} else {
jxl.display( "ui_Show_InitGroup", true);
if ( jxl.getValue( "ui_GroupID") != "nil" ) {
jxl.display( "ui_Show_SetGroupTimer", true);
}
}
jxl.setSelection( "ui_SelectSwitchAktor", g_nMasterDeviceID);
if ( g_hasTimerCtrl == true) {
insideInit( nGroupID, g_szTimerUse, g_TimerCtrl_ID, g_data, g_nLastCalendarState);
} else {
insideInit( nGroupID, g_szTimerUse, "", new Array(), g_nLastCalendarState);
}
}
ready.onReady(ajaxValidation({
formNameOrIndex: "main_form",
applyNames: "apply",
okCallback: onSubmit_AfterValidation
}));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
