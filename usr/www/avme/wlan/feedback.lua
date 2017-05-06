<?lua
g_page_type = "all"
g_page_title = [[{?836:836?}]]
g_page_help = "hilfe_wlan_feedback.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
require("http")
g_back_to_page = http.get_back_to_page( "/wlan/wlan_settings.lua" )
g_menu_active_page = g_back_to_page
if box.get.menu_active_page then
g_menu_active_page = box.get.menu_active_page
end
if box.post.menu_active_page then
g_menu_active_page = box.post.menu_active_page
end
function redirect_to_backpage()
local dev
local idx
require("net_devices")
idx, dev = net_devices.find_dev_by_mac(net_devices.g_list, box.post.current_mac)
if not(dev) then
idx, dev = net_devices.find_dev_by_name(net_devices.g_list, box.post.current_device)
if not(dev) then
http.redirect(href.get("/wlan/wlan_settings.lua"))
end
end
http.redirect(href.get(g_back_to_page,'dev='..tostring(dev.UID), 'back_to_page='..g_menu_active_page))
end
if (next(box.post) and (box.post.cancel)) then
redirect_to_backpage()
end
g_errcode = 0
g_errmsg = [[Fehler: Es ist ein Fehler beim Übernehmen der Daten aufgetreten. Die aktuellen Daten dieser Seite wurden nicht gespeichert.]]
g_sz_text_choise = [[{?836:271?}]]
g_feedback_satisfaction = nil
g_feedback_device_type = nil
g_feedback_remarks = nil
g_current_device_name = ""
g_current_device_mac = ""
g_no_satisfation_1 = 0
g_no_satisfation_2 = 0
g_no_satisfation_4 = 0
g_t_dev_list = {}
function init_page_vars( sz_device)
g_feedback_satisfaction = boxvars2.c_boxvars:init( { sz_query = [[wlan:settings/feedback_satisfaction]]} )
g_feedback_device_type = boxvars2.c_boxvars:init( { sz_query = [[wlan:settings/feedback_device_type]]} )
g_feedback_remarks = boxvars2.c_boxvars:init( { sz_query = [[wlan:settings/feedback_remarks]]} )
g_current_device_name = sz_device
g_feedback_satisfaction:set_value("0")
g_feedback_device_type:set_value("0")
g_feedback_remarks:set_value("")
end
function refill_user_input()
g_feedback_satisfaction:update_value()
g_no_satisfaction_1 = 0
if ( box.post[ "no_satisfaction_1"] ~= nil) then
g_no_satisfaction_1 = box.post[ "no_satisfaction_1"]
end
g_no_satisfaction_2 = 0
if ( box.post[ "no_satisfaction_2"] ~= nil) then
g_no_satisfaction_2 = box.post[ "no_satisfaction_2"]
end
g_no_satisfaction_4 = 0
if ( box.post[ "no_satisfaction_4"] ~= nil) then
g_no_satisfaction_4 = box.post[ "no_satisfaction_4"]
end
g_feedback_device_type:update_value()
g_feedback_remarks:update_value()
g_current_device_name = ""
if ( box.post[ "current_device"] ~= nil) then
g_current_device_name = box.post[ "current_device"]
end
end
function get_dev_list ()
table.insert( g_t_dev_list, { [[0]], g_sz_text_choise } )
table.insert( g_t_dev_list, { [[1]], [[ {?836:0?}]] } )
table.insert( g_t_dev_list, { [[2]], [[ {?836:348?}]] } )
table.insert( g_t_dev_list, { [[3]], [[ {?836:664?}]] } )
table.insert( g_t_dev_list, { [[4]], [[ {?836:872?}]] } )
table.insert( g_t_dev_list, { [[5]], [[ {?836:944?}]] } )
table.insert( g_t_dev_list, { [[6]], [[ {?836:439?}]] } )
return g_t_dev_list
end
init_page_vars( "")
if (next(box.get) and box.get.devname) then
g_current_device_name = box.get.devname
end
if (next(box.get) and box.get.mac) then
g_current_device_mac = box.get.mac
end
g_val = {
prog = [[
if __value_equal(]]..g_feedback_device_type:get_val_names()..[[,0) then
const_error(]]..g_feedback_device_type:get_val_names()..[[,empty,no_choice)
end
]]
}
val.msg.no_choice = {
[val.ret.empty] = [[{?836:339?}]],
[val.ret.notfound] = [[{?836:696?}]]
}
if next(box.post) and (box.post.send ) then
if val.validate(g_val) == val.ret.ok then
local saveset={}
g_feedback_satisfaction:save_value( saveset)
if ( g_feedback_satisfaction:get_value() == "1") then
g_no_satisfaction_1 = 0
if ( box.post[ "no_satisfaction_1"] ~= nil) then
g_no_satisfaction_1 = box.post[ "no_satisfaction_1"]
end
g_no_satisfaction_2 = 0
if ( box.post[ "no_satisfaction_2"] ~= nil) then
g_no_satisfaction_2 = box.post[ "no_satisfaction_2"]
end
g_no_satisfaction_4 = 0
if ( box.post[ "no_satisfaction_4"] ~= nil) then
g_no_satisfaction_4 = box.post[ "no_satisfaction_4"]
end
g_feedback_satisfaction:save_value( saveset, (g_no_satisfaction_1 + g_no_satisfaction_2 + g_no_satisfaction_4))
end
g_feedback_device_type:save_value( saveset)
g_feedback_remarks:save_value( saveset)
cmtable.add_var(saveset,"wlan:settings/feedback_device",box.post.current_mac)
cmtable.add_var(saveset,"wlan:settings/feedback_send","1")
local err, msg = box.set_config(saveset)
if err == 0 then
redirect_to_backpage()
else
local criterr = general.create_error_div(err,msg,[[{?836:855?}]])
box.out(criterr)
refill_user_input()
end
else
refill_user_input()
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function OnChange_Satisfaction( szValue) {
jxl.setDisabled( "ui_No_Satisfaction_1", szValue == "0");
jxl.setDisabled( "Label_No_Satisfaction_1", szValue == "0");
jxl.setDisabled( "ui_No_Satisfaction_2", szValue == "0");
jxl.setDisabled( "Label_No_Satisfaction_2", szValue == "0");
jxl.setDisabled( "ui_No_Satisfaction_4", szValue == "0");
jxl.setDisabled( "Label_No_Satisfaction_4", szValue == "0");
}
function init() {
OnChange_Satisfaction( <?lua box.out( [["]]..box.tojs(g_feedback_satisfaction:get_value())..[["]]) ?> );
}
function uiDoOnMainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
alert( "{?836:149?}");
}
/******* initialize page via js ************/
ready.onReady(val.init(uiDoOnMainFormSubmit, "send", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" class="narrow" action="<?lua href.write(box.glob.script) ?>" id="uiMainForm">
<input type="hidden" name="current_device" value="<?lua box.html( g_current_device_name) ?>">
<input type="hidden" name="current_mac" value="<?lua box.html( g_current_device_mac) ?>">
<p>{?836:123?}<br /></p>
<p>{?836:724?}</p>
<hr>
<h4>{?836:169?}</h4>
<p>{?836:20?}</p>
<?lua
box.out( [[<div class="formular">]])
box.out( [[<label for="uiView_DeviceName">]]..box.tohtml([[{?836:821?}]])..[[</label>]])
box.out( [[<span class="output">]]..box.tohtml(g_current_device_name)..[[</span>]])
box.out([[<div>]])
box.out( elem._radio( g_feedback_satisfaction:get_var_name(), g_feedback_satisfaction:get_var_name_js()..[[_0]], "0", (g_feedback_satisfaction:get_value() == "0"), [[onclick="OnChange_Satisfaction('0')"]]))
box.out( elem._label( g_feedback_satisfaction:get_var_name_js()..[[_0]], "Label_"..g_feedback_satisfaction:get_var_name_js()..[[_01]], [[{?836:727?}]], "short"))
box.out([[<br>]])
box.out( elem._radio( g_feedback_satisfaction:get_var_name(), g_feedback_satisfaction:get_var_name_js()..[[_1]], "1", (g_feedback_satisfaction:get_value() ~= "0"), [[onclick="OnChange_Satisfaction('1')"]]))
box.out( elem._label( g_feedback_satisfaction:get_var_name_js()..[[_1]], "Label_"..g_feedback_satisfaction:get_var_name_js()..[[_11]], [[{?836:658?}]]))
box.out( [[<div class="formular" id="ui_Satisfaction_Entries">]])
box.out( elem._checkbox( "no_satisfaction_1", "ui_No_Satisfaction_1", "1", (g_no_satisfaction_1 == "1")))
box.out( elem._label( "ui_No_Satisfaction_1", "Label_".."No_Satisfaction_1", [[{?836:124?}]]))
box.out([[<br>]])
box.out( elem._checkbox( "no_satisfaction_2", "ui_No_Satisfaction_2", "2", (g_no_satisfaction_2 == "2")))
box.out( elem._label( "ui_No_Satisfaction_2", "Label_".."No_Satisfaction_2", [[{?836:61?}]]))
box.out([[<br>]])
box.out( elem._checkbox( "no_satisfaction_4", "ui_No_Satisfaction_4", "4", (g_no_satisfaction_4 == "4")))
box.out( elem._label( "ui_No_Satisfaction_4", "Label_".."No_Satisfaction_4", [[{?836:534?}]]))
box.out( [[</div>]])
box.out( [[</div>]])
box.out( [[<div>]])
g_t_dev_list = get_dev_list()
box.out( elem._label( g_feedback_device_type:get_var_name_js(), "Label"..g_feedback_device_type:get_var_name_js(),[[{?836:254?}]]))
local sz_selected = [[0#]]..g_sz_text_choise
box.out( elem._select( g_feedback_device_type:get_var_name(), g_feedback_device_type:get_var_name_js(), g_t_dev_list, sz_selected, nil, val.get_attrs( g_val, g_feedback_device_type:get_var_name_js()) ))
val.write_html_msg(g_val, g_feedback_device_type:get_var_name_js())
box.out( [[</div>]])
box.out( [[<div>]])
box.out( elem._label( g_feedback_remarks:get_var_name_js(), "Label"..g_feedback_remarks:get_var_name_js(),[[{?836:255?}]], [[vertical-align: top;]]))
box.out( elem._textarea( g_feedback_remarks:get_var_name(), g_feedback_remarks:get_var_name_js(), g_feedback_remarks:get_value(), "3", "63"))
box.out( [[</div>]])
box.out( [[</div>]])
?>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="menu_active_page" value="<?lua box.html(g_menu_active_page) ?>">
<button type="submit" id="uiBtnSend" name="send">{?836:323?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
