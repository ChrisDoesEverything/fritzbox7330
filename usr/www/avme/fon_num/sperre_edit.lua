<?lua
g_page_type = "all"
g_page_needs_js = true
g_menu_active_page = "/fon_num/sperre.lua"
g_page_title = [[{?177:171?}]]
g_page_help = "hilfe_fon_sperre_neu.html"
dofile("../templates/global_lua.lua")
require("config")
require("cmtable")
require("val")
require("boxvars")
require("elem")
require("general")
?>
<?lua
if (next(box.post) and (box.post.cancel)) then
http.redirect( [[/fon_num/sperre.lua]])
end
?>
<?lua
g_errcode = 0
g_t_err_text = { _in = { [[{?177:761?}]],
[[{?177:319?}]]},
_out = { [[{?177:905?}]],
[[{?177:603?}]],
[[{?177:827?}]]}
}
g_t_txt_rule_kind = { _out = [[{?177:765?}]],
_in = [[{?177:982?}]]
}
g_b_is_new = false
g_current_rule = ""
g_Delete = ""
g_sz_current_mode = "_out"
g_sz_selected_mode = ""
g_sz_current_rule_value = ""
g_t_blocked_number_out = {{[[rufnummer]], [[{?txtRufnummer?}]]},
{[[mobile]], [[{?txtMobilfunk?}]]},
{[[ortsnetz]], [[{?177:759?}]]},
{[[national]], [[{?177:544?}]]},
{[[international]], [[{?177:153?}]]},
{[[sonderrufnrn]], [[{?177:530?}]]},
{[[auskunft]], [[{?177:739?}]]}}
if config.no_number_area then
g_t_blocked_number_out = { {[[rufnummer]], [[{?txtRufnummer?}]]} }
end
g_t_blocked_number_in = { { [[rufnummer]], [[{?txtRufnummer?}]]},
{ [[ohne]], [[{?177:27?}]]},
}
?>
<?lua
function init_page_vars( sz_mode, sz_rule)
local l_variablen_strings = {}
if ( sz_mode == "_out") then
table.insert( l_variablen_strings, ( [[telcfg:settings/Routing/]]..sz_rule..[[/Number]] ) )
table.insert( l_variablen_strings, ( [[telcfg:settings/Routing/]]..sz_rule..[[/Route]] ) )
table.insert( l_variablen_strings, ( [[telcfg:settings/Routing/]]..sz_rule..[[/Provider]] ) )
else
table.insert( l_variablen_strings, ( [[telcfg:settings/]]..sz_rule..[[/CallerID]] ) )
table.insert( l_variablen_strings, ( [[telcfg:settings/]]..sz_rule..[[/Action]] ) )
table.insert( l_variablen_strings, ( [[telcfg:settings/]]..sz_rule..[[/Active]] ) )
end
boxvars.init( l_variablen_strings)
end
function get_table_for_select( sz_mode)
if ( sz_mode == "_in") then
return g_t_blocked_number_in
end
return g_t_blocked_number_out
end
function get_selected_kind( sz_mode, sz_value)
if ( sz_mode == "_new") then
return "rufnummer"
end
if ( sz_mode == "_in") then
if ( sz_value == "") then
return "ohne"
end
return "rufnummer"
else
if (( sz_value == "mobile") or ( sz_value == "ortsnetz") or ( sz_value == "national") or
( sz_value == "auskunft") or ( sz_value == "sonderrufnrn") or ( sz_value == "international")) then
return sz_value
else
return "rufnummer"
end
end
end
function get_input_value( sz_mode, sz_value)
if ( sz_mode == "_new") then
return ""
end
if (( sz_value == "mobile") or ( sz_value == "ortsnetz") or ( sz_value == "national") or ( sz_value == "auskunft") or
( sz_value == "sonderrufnrn") or ( sz_value == "international") or ( sz_value == "ohne")) then
return ""
end
return sz_value
end
function get_rule_mode( sz_rule)
local n_start, n_end = string.find( sz_rule, "Group")
if ( n_start == nil) then
return "_in"
end
return "_out"
end
function write_blocked_calls_js()
local l_sz_js_text = [[]]
for i=1, #g_t_blocked_number_out do
l_sz_js_text = [[g_ar_block_call_out[]]..tostring((i-1))
l_sz_js_text = l_sz_js_text..[[] = new Item( "]]
l_sz_js_text = l_sz_js_text..box.tojs(tostring(g_t_blocked_number_out[i][1]))
l_sz_js_text = l_sz_js_text..[[", "]]..box.tojs(tostring(g_t_blocked_number_out[i][2]))..[[");
]]
box.out( l_sz_js_text)
end
for i=1, #g_t_blocked_number_in do
l_sz_js_text = [[g_ar_block_call_in[]]..tostring((i-1))
l_sz_js_text = l_sz_js_text..[[] = new Item( "]]
l_sz_js_text = l_sz_js_text..box.tojs(tostring(g_t_blocked_number_in[i][1]))
l_sz_js_text = l_sz_js_text..[[", "]]..box.tojs(tostring(g_t_blocked_number_in[i][2]))..[[");
]]
box.out( l_sz_js_text)
end
end
function write_blocked_call_entries_js ()
end
function determine_current_value()
local l_sz_value = box.post.rule_kind
if ( l_sz_value == "rufnummer") then
l_sz_value = box.post.rule_number
end
return l_sz_value
end
function backend_validation( sz_mode, sz_value, sz_rule_id)
local l_query_str = [[]]
local l_t_compare_field = {}
local l_compare_value = ""
local l_sz_DelPath=""
if ( sz_mode == "_in") then
l_query_str = [[telcfg:settings/CallerIDActions/list(CallerID,Action,Active)]]
l_t_compare_field = {"CallerID","Action","Active"}
l_compare_value = "1"
if ( sz_value == "ohne") then
sz_value = ""
end
else
l_query_str = [[telcfg:settings/Routing/Group/list(Number,Route,Provider)]]
l_t_compare_field = {"Number","Route","Provider"}
l_compare_value = "s"
l_sz_DelPath="Routing/"
end
local l_t_rule_list = general.listquery(l_query_str)
for i=1, #l_t_rule_list do
if (( tostring(sz_rule_id) ~= tostring(l_t_rule_list[i]._node)) and
( tostring(sz_value) == tostring(l_t_rule_list[i][l_t_compare_field[1]]) )) then
g_Delete=l_sz_DelPath..tostring(l_t_rule_list[i]._node)
if ( tostring(l_t_rule_list[i][l_t_compare_field[2]]) == l_compare_value ) then
return 1
else
return 2
end
end
end
return 0
end
function prepare_to_save( sz_mode, t_save_set)
local l_sz_value_1 = box.post.rule_kind
local l_sz_value_2 = ""
local l_sz_value_3 = ""
if ( l_sz_value_1 == "rufnummer") then
l_sz_value_1 = box.post.rule_number
end
if ( sz_mode == "_out") then
l_sz_value_2 = "s"
l_sz_value_3 = "0"
end
if ( sz_mode == "_in") then
if ( l_sz_value_1 == "ohne") then
l_sz_value_1 = ""
end
l_sz_value_2 = "1"
l_sz_value_3 = "1"
end
cmtable.add_var( t_save_set, boxvars.get_str(1), l_sz_value_1)
cmtable.add_var( t_save_set, boxvars.get_str(2), l_sz_value_2)
cmtable.add_var( t_save_set, boxvars.get_str(3), l_sz_value_3)
return t_save_set
end
function box_is_german()
return config.country == "049"
end
function box_is_international()
return not( config.country == "049")
end
function is_new_entry()
return g_sz_current_mode == "_new"
end
function is_not_new_entry()
return g_sz_current_mode ~= "_new"
end
g_val = {
prog = [[
if __value_equal(ui_RuleKind/rule_kind,rufnummer) then
if is_new_entry() then
if __radio_check(ui_ModeCall_In/mode_call,_in) then
is_num_in_enh(ui_RuleNumber/rule_number,is_num_in_enh)
end
if __radio_check(ui_ModeCall_Out/mode_call,_out) then
if box_is_international() then
is_num_out(ui_RuleNumber/rule_number,112,911,is_num_out)
end
if box_is_german() then
is_num_out(ui_RuleNumber/rule_number,110,112,19222,is_num_out)
end
end
end
if is_not_new_entry() then
if __radio_check(ui_ModeCall_In/mode_call,_in) then
is_num_in_enh(ui_RuleNumber/rule_number,is_num_in_enh)
end
if __radio_check(ui_ModeCall_Out/mode_call,_out) then
if box_is_international() then
is_num_out(ui_RuleNumber/rule_number,112,911,is_num_out)
end
if box_is_german() then
is_num_out(ui_RuleNumber/rule_number,110,112,19222,is_num_out)
end
end
end
end
]]
}
val.msg.is_num_in_enh = {
[val.ret.notfound] = [[{?177:990?}]],
[val.ret.empty] = [[{?177:872?}]],
[val.ret.format] = [[{?177:386?}]]
}
val.msg.is_num_out = {
[val.ret.notfound] = [[{?177:980?}]],
[val.ret.empty] = [[{?177:945?}]],
[val.ret.format] = [[{?177:643?}]],
[val.ret.wrong] = [[{?177:236?}]]
}
if ( next(box.get)) then
if ( box.get.new) then
g_sz_current_mode = "_new"
else
g_current_rule = box.get.rule
g_sz_current_mode = get_rule_mode(g_current_rule)
init_page_vars(g_sz_current_mode,g_current_rule)
g_sz_current_rule_value = boxvars.get_value(1)
end
else
if ( next(box.post)) and (box.post.apply) then
g_current_rule = box.post.current_rule
g_sz_current_mode = box.post.current_mode
g_sz_current_rule_value = box.post.rule_kind
local l_now_selected_mode = box.post.mode_call
g_sz_selected_mode = l_now_selected_mode
local l_val_result = val.ret.ok
if (string.find( g_current_rule, "Group") and l_now_selected_mode=="_in") or
(string.find( g_current_rule, "CallerIDActions") and l_now_selected_mode=="_out") then
local delset = {}
local szDelValue = g_current_rule
local nBeginn, nEnde = string.find( g_current_rule, "Group")
if ( nBeginn == 1 and nEnde == 5) then
szDelValue = "Routing/"..g_current_rule
end
cmtable.add_var( delset, ("telcfg:command/"..szDelValue), "delete")
g_errcode, g_errmsg = box.set_config(delset)
g_sz_current_mode = "_new"
end
if (g_sz_current_mode == "_new") then
if ( l_now_selected_mode == "_out") then
g_current_rule = box.query( [[telcfg:settings/Routing/Group/newid]])
else
g_current_rule = box.query( [[telcfg:settings/CallerIDActions/newid]])
end
end
l_val_result = val.validate( g_val)
if ( l_val_result == val.ret.ok) then
local l_current_value = determine_current_value()
if ( box.post.error_code ~= nil) and ( box.post.errcode == 2) then
else
if ( l_now_selected_mode == "_out") and (l_current_value == "ohne") then
g_errcode = 3
end
if ( g_errcode == 0) then
g_errcode = backend_validation( l_now_selected_mode, l_current_value, g_current_rule)
end
end
if ( g_errcode ~= 0) then
g_sz_current_rule_value = l_current_value
g_val.errmsg = g_t_err_text[g_sz_selected_mode][g_errcode]
else
local saveset = {}
init_page_vars( l_now_selected_mode, g_current_rule)
saveset = prepare_to_save( l_now_selected_mode, saveset)
g_errcode, g_errmsg = box.set_config( saveset)
if g_errcode ~= 0 then
g_val.errmsg = errmsg
else
http.redirect( [[/fon_num/sperre.lua]])
end
end
else
if ( g_sz_current_rule_value == "rufnummer") then
g_sz_current_rule_value = tostring(box.post.rule_number)
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular select,
.formular input[type=text] {
width: 200px;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_ar_block_call_out = new Array();
var g_ar_block_call_in = new Array();
<?lua
write_blocked_calls_js()
?>
function init()
{
var radio_elem1 = jxl.get( "ui_ModeCall_Out");
if (radio_elem1)
radio_elem1.onchange = On_ChangeRuleMode;
var radio_elem2 = jxl.get( "ui_ModeCall_In");
if (radio_elem2)
radio_elem2.onchange = On_ChangeRuleMode;
var select_elem = jxl.get( "ui_RuleKind");
if (select_elem)
select_elem.onchange = On_ChangeSelectKind;
On_ChangeSelectKind();
}
function On_ChangeRuleMode()
{
var szValue = "";
var arOfSelection = new Array();
if ( jxl.getChecked( "ui_ModeCall_Out")) {
arOfSelection = g_ar_block_call_out;
}
if ( jxl.getChecked( "ui_ModeCall_In")) {
arOfSelection = g_ar_block_call_in;
}
jxl.clearSelection( "ui_RuleKind");
for (i=0; i<arOfSelection.length; i++) {
jxl.addOption( "ui_RuleKind", arOfSelection[i].value, arOfSelection[i].text);
}
On_ChangeSelectKind();
}
function On_ChangeSelectKind() {
szValue = jxl.getValue( "ui_RuleKind");
jxl.display( "uiViewNumberBox", ( szValue == "rufnummer"));
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
function Item ( sz_value, sz_text) {
this.value = sz_value;
this.text = sz_text;
}
g_ValPage = false;
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="/fon_num/sperre_edit.lua" name="main_form">
<p>{?177:869?}</p>
<hr>
<h4>{?177:339?}</h4>
<div class="formular">
<input type="radio" name="mode_call" id="ui_ModeCall_Out" value="_out" <?lua if g_sz_current_mode~="_in" then box.out([[checked]]) end ?>>
<label for="ui_ModeCall_Out"><?lua box.html(g_t_txt_rule_kind["_out"]) ?></label>
<br>
<input type="radio" name="mode_call" id="ui_ModeCall_In" value="_in" <?lua if g_sz_current_mode=="_in" then box.out([[checked]]) end ?>>
<label for="ui_ModeCall_In"><?lua box.html(g_t_txt_rule_kind["_in"]) ?></label>
</div>
<hr>
<h4>{?177:678?}</h4>
<div class="formular">
<label for="ui_RuleKind">{?177:817?}</label>
<?lua
g_t_selected = get_table_for_select( g_sz_current_mode)
if ( g_errcode ~= 0 ) then
g_t_selected = get_table_for_select( g_sz_selected_mode)
end
local l_sz_selected = get_selected_kind( g_sz_current_mode, g_sz_current_rule_value)
if ( g_errcode ~= 0 ) then
l_sz_selected = g_sz_current_rule_value
end
box.out( elem._select( "rule_kind", "ui_RuleKind", g_t_selected, l_sz_selected))
?>
<div id="uiViewNumberBox" <?lua if get_selected_kind( g_sz_current_mode, g_sz_current_rule_value) ~= "rufnummer" then box.out([[style="display:none;"]]) end?>>
<label for="ui_RuleNumber">{?177:886?}</label>
<?lua
local l_input_value = get_input_value( g_sz_current_mode, g_sz_current_rule_value)
if ( g_errcode ~= 0 ) then
l_input_value = get_input_value( g_sz_selected_mode, g_sz_current_rule_value)
end
box.out( elem._input( "text", "rule_number", "ui_RuleNumber", l_input_value, "30", "20", val.get_attrs(g_val, 'ui_RuleNumber')))
val.write_html_msg( g_val, "ui_RuleNumber")
?>
</div>
</div>
<?lua
if (g_errcode ~= 0) then
box.out( [[<p class="ErrorMsg" style="">]])
box.out( tostring( g_t_err_text[g_sz_selected_mode][g_errcode]))
if ( g_errcode == 2) then
box.out( elem._input( "hidden", "error_code", "", g_errcode, "0", "0", ""))
box.out( elem._input( "hidden", "error_mode", "", g_sz_selected_mode, "0", "0", ""))
box.out( elem._input( "hidden", "error_kind", "", g_sz_current_rule_value, "0", "0", ""))
box.out( elem._input( "hidden", "error_number", "", l_input_value, "0", "0", ""))
end
box.out( [[</p>]] )
end
?>
<input type="hidden" name="current_rule" id="ui_CurrentRule" value="<?lua box.html( g_current_rule) ?>">
<input type="hidden" name="current_mode" id="ui_CurrentMode" value="<?lua box.html( g_sz_current_mode) ?>">
<input type="hidden" name="backend_validation" id="ui_BackendValidation" value="false">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
