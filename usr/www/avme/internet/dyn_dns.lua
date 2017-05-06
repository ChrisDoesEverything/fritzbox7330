<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_dyndns.html"
dofile("../templates/global_lua.lua")
g_page_needs_js=true
require("cmtable")
require("val")
require("boxvars2")
require("elem")
require("general")
require("utf8")
ddns_enabled = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/account0/activated"} )
ddns_domain = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/account0/domain"} )
ddns_username = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/account0/username"} )
ddns_password = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/account0/password"} )
ddns_provider = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/account0/ddnsprovider"} )
g_szListQuery_DnsType = [[ddns:settings/type/list(type,url)]]
g_t_dnstype_list = general.listquery( g_szListQuery_DnsType)
g_szListQuery_Provider = [[ddns:settings/provider/list(name,type,infourl)]]
g_t_provider_list = general.listquery( g_szListQuery_Provider)
local tmp_list1, tmp_list2 = array.filter(g_t_provider_list, func.eq("userdefined", 'type'))
utf8.sort(tmp_list2, function(p) return (p.name or ""):lower() end)
g_t_provider_list = array.cat(tmp_list2, tmp_list1)
function get_update_url()
for i=1, #g_t_dnstype_list do
if ( "userdefined" == g_t_dnstype_list[i].type) then
return g_t_dnstype_list[i].url, i
end
end
return "", 0
end
local sz_selected_update_url, n_pos = get_update_url()
ddns_infourl = boxvars2.c_boxvars:init( { sz_query = "ddns:settings/type"..tostring(n_pos-1).."/url"} )
function init_page_vars()
end
function split(_str, _sep)
local result = {}
if not _sep or _sep == "" then
for i = 1, #str do
table.insert(result, _str:sub(i,i))
end
return result
end
local curr = 1
local left, right = _str:find(_sep, curr, true)
while left do
table.insert(result, _str:sub(curr, left-1))
curr = right + 1
left, right = _str:find(_sep, curr, true)
end
table.insert(result, _str:sub(curr))
return result
end
function write_provider_values_js()
local l_sz_js_text = [[]]
for i=1, #g_t_provider_list do
l_sz_js_text = [[g_ar_provider_values[]]..tostring((i-1))
l_sz_js_text = l_sz_js_text..[[] = new Item( "]]..box.tojs(tostring(g_t_provider_list[i].type))..[[",]]
l_sz_js_text = l_sz_js_text..[["]]..box.tojs(tostring(g_t_provider_list[i].name))..[[",]]
l_sz_js_text = l_sz_js_text..[["]]..box.tojs(tostring(g_t_provider_list[i].infourl))..[[");
]]
box.out( l_sz_js_text)
end
end
function get_provider_select_list()
local l_t_select_list = {}
for i=1, #g_t_provider_list do
local l_t_select_entry = {}
table.insert( l_t_select_entry, g_t_provider_list[i].type)
table.insert( l_t_select_entry, g_t_provider_list[i].name)
table.insert( l_t_select_list, l_t_select_entry)
end
return l_t_select_list
end
function get_selected_provider( _provider_name, _t_option_list)
for i=1, #_t_option_list do
if ( _provider_name == _t_option_list[i].name) then
return _t_option_list[i].type
end
end
return _t_option_list[1]
end
function get_provider_name( _sz_type)
for i=1, #g_t_provider_list do
if ( _sz_type == g_t_provider_list[i].type) then
return g_t_provider_list[i].name
end
end
return ""
end
function save_update_url( _t_save_set, _sz_update_url, _at_pos)
cmtable.add_var( _t_save_set, ("ddns:settings/type"..tostring(_at_pos-1).."/url"), _sz_update_url)
g_t_dnstype_list[_at_pos].url = _sz_update_url
end
function is_userdefined()
if ( "userdefined" == get_provider_type( box.post["provider_name"])) then
return true
else
return false
end
end
g_val = {
prog = [[
if __checked(]]..ddns_enabled:get_val_names()..[[) then
if __value_equal(uiView_Provider/provider_name,userdefined) then
not_empty(]]..ddns_infourl:get_val_names()..[[, updateurl_empty)
end
not_empty(]]..ddns_domain:get_val_names()..[[, domain_empty)
not_empty(]]..ddns_username:get_val_names()..[[, user_empty)
not_empty(]]..ddns_password:get_val_names()..[[, password_empty)
end
]]
}
val.msg.domain_empty = {
[val.ret.empty] = [[{?8312:438?}]],
[val.ret.notfound] = [[{?8312:512?}]]
}
val.msg.user_empty = {
[val.ret.empty] = [[{?8312:740?}]],
[val.ret.notfound] = [[{?8312:121?}]]
}
val.msg.password_empty = {
[val.ret.empty] = [[{?8312:674?}]],
[val.ret.notfound] = [[{?8312:253?}]]
}
val.msg.updateurl_empty = {
[val.ret.empty] = [[{?8312:710?}]],
[val.ret.notfound] = [[{?8312:396?}]]
}
if ( next(box.post)) then
if ( box.post.apply) then
local saveset = {}
if ( val.validate(g_val) == val.ret.ok) then
ddns_enabled:save_check_value( saveset)
if ddns_enabled:var_exist() then
ddns_domain:save_value( saveset)
ddns_username:save_value( saveset)
ddns_password:update_value()
if (ddns_password:get_value()~=[[****]]) then
ddns_password:save_value( saveset)
end
local l_sz_provider = get_provider_name(box.post["provider_name"])
ddns_provider:save_value( saveset, l_sz_provider)
if ( "userdefined" == box.post["provider_name"]) then
local sz_selected_update_url, n_pos = get_update_url()
save_update_url( saveset, box.post[ddns_infourl:get_var_name()], n_pos)
else
save_update_url( saveset, "", n_pos)
end
end
errcode, errmsg = box.set_config( saveset)
if errcode ~= 0 then
g_val.errmsg = errmsg
else
ddns_password:set_value([[****]])
end
else
if ddns_enabled:var_exist() then
ddns_enabled:set_value( "1")
else
ddns_enabled:set_value( "0")
end
ddns_domain:set_value( box.post[ddns_domain:get_var_name()])
ddns_username:set_value( box.post[ddns_username:get_var_name()])
ddns_password:set_value( box.post[ddns_password:get_var_name()])
local l_sz_provider = get_provider_name(box.post["provider_name"])
ddns_provider:set_value( l_sz_provider)
end
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_ar_provider_values = new Array();
<?lua
val.write_js_error_strings()
write_provider_values_js()
?>
var is_ip_client=<?lua box.out(tostring(general.is_ip_client()))?>;
function init() {
OnChange_DDnsProvider();
if ( jxl.getChecked( <?lua box.out( [["]]..ddns_enabled:get_var_name_js()..[["]]) ?>) ) {
OnChange_DDnsActivated( true);
} else {
OnChange_DDnsActivated( false);
}
var elem = jxl.get("uiView_Provider");
if (elem) {
elem.onchange = OnChange_DDnsProvider;
}
if (is_ip_client) {
jxl.disableNode("uiViewDnydns",true);
jxl.setDisabled("uiApply",true);
}
}
function OnChange_DDnsActivated( bChecked) {
jxl.setDisabled( "uiView_Provider", !bChecked);
jxl.setDisabled( "ui_BtnShow_Info", !bChecked);
jxl.setDisabled(<?lua box.out( [["]]..ddns_infourl:get_var_name_js()..[["]]) ?>, !bChecked);
jxl.setDisabled(<?lua box.out( [["]]..ddns_domain:get_var_name_js()..[["]]) ?>, !bChecked);
jxl.setDisabled(<?lua box.out( [["]]..ddns_username:get_var_name_js()..[["]]) ?>, !bChecked);
jxl.setDisabled(<?lua box.out( [["]]..ddns_password:get_var_name_js()..[["]]) ?>, !bChecked);
jxl.setDisabled(<?lua box.out( [["]]..ddns_provider:get_var_name_js()..[["]]) ?>, !bChecked);
}
function OnChange_DDnsProvider() {
var szValue = jxl.getValue( "uiView_Provider");
if ( szValue == "userdefined") {
jxl.display( "uiShow_UpdateUrl", true);
} else {
jxl.display( "uiShow_UpdateUrl", false);
}
}
function GetProviderInfoUrl( szValue) {
for ( i = 0; i < g_ar_provider_values.length; i++) {
if ( szValue == g_ar_provider_values[i].value) {
return g_ar_provider_values[i].url;
}
}
return "";
}
function uiDoInfo() {
var szValue = jxl.getValue( "uiView_Provider");
var ppWindow = window.open( GetProviderInfoUrl( szValue), "{?8312:593?}");
}
function On_MainFormSubmit() {
<?lua
val.write_js_checks( g_val)
?>
}
function Item ( sz_value, sz_name, sz_url) {
this.value = sz_value;
this.name = sz_name;
this.url = sz_url;
}
g_ValPage = false;
ready.onReady(val.init(On_MainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="/internet/dyn_dns.lua" id="uiMainForm">
<input type="hidden" id="uiView_TmpUpdateUrl" value="<?lua box.out(get_update_url( [[userdefined]])) ?>" >
<p>
{?8312:281?}
</p>
<hr>
<div <?lua if box.query("connection0:status/ip_is_private") == "0" then box.out([[style="display:none;"]]) end ?>>
<span class="hintMsg">{?txtHinweis?}</span>
<p>{?8312:30?}</p>
</div>
<div class="formular" id="uiViewDnydns">
<?lua
box.out( elem._checkbox( ddns_enabled:get_var_name(), ddns_enabled:get_var_name_js(), ddns_enabled:get_value(), (ddns_enabled:get_value() == "1"), [[onclick="OnChange_DDnsActivated(this.checked)"]]))
box.out( [[&nbsp;]])
box.out( elem._label( ddns_enabled:get_var_name_js(), "Label"..ddns_enabled:get_var_name_js(), [[{?8312:43?}]]))
box.out( [[<p>{?8312:506?}</p>]])
box.out( [[<p class="formular">]])
local l_t_provider_list = get_provider_select_list()
box.out( elem._label( "uiView_Provider", "Label_uiView_Provider",[[{?8312:574?}]]))
g_sz_selected = get_selected_provider( ddns_provider:get_value(), g_t_provider_list)
box.out( elem._select( "provider_name", "uiView_Provider", l_t_provider_list, g_sz_selected))
box.out( [[&nbsp;]])
box.out( [[<button id="ui_BtnShow_Info" type="submit" name="show_info" onclick="uiDoInfo()">{?8312:128?}</button>]])
box.out( [[</p>]])
box.out( [[<p class="formular" id="uiShow_UpdateUrl">]])
ddns_infourl:set_value(get_update_url())
box.out( elem._label( ddns_infourl:get_var_name_js(), "Label"..ddns_infourl:get_var_name_js(), [[{?8312:624?}:]]))
box.out( elem._input( "text", ddns_infourl:get_var_name(), ddns_infourl:get_var_name_js(), ddns_infourl:get_value(), "30", "", val.get_attrs( g_val, ddns_infourl:get_var_name_js(), ddns_infourl:get_var_name())))
val.write_html_msg(g_val, ddns_infourl:get_var_name_js())
box.out( [[</p>]])
box.out( [[<p class="formular">]])
box.out( elem._label( ddns_domain:get_var_name_js(), "Label"..ddns_domain:get_var_name_js(), [[{?8312:957?}:]]))
box.out( elem._input( "text", ddns_domain:get_var_name(), ddns_domain:get_var_name_js(), ddns_domain:get_value(), "30", "", val.get_attrs( g_val, ddns_domain:get_var_name_js(), ddns_domain:get_var_name())))
val.write_html_msg(g_val, ddns_domain:get_var_name_js())
box.out( [[</p>]])
box.out( [[<p class="formular">]])
box.out( elem._label( ddns_username:get_var_name_js(), "Label"..ddns_username:get_var_name_js(), [[{?txtUsername?}:]]))
box.out( elem._input( "text", ddns_username:get_var_name(), ddns_username:get_var_name_js(), ddns_username:get_value(), "30", "", val.get_attrs( g_val, ddns_username:get_var_name_js(), ddns_username:get_var_name())))
val.write_html_msg(g_val, ddns_username:get_var_name_js())
box.out( [[</p>]])
local attribs=val.get_attrs( g_val, ddns_password:get_var_name_js(), ddns_password:get_var_name())
if attribs==nil then
attribs=""
end
attribs=attribs..[[autocomplete="off"]]
box.out( [[<p class="formular">]])
box.out( elem._label( ddns_password:get_var_name_js(), "Label"..ddns_password:get_var_name_js(), [[{?txtKennwort?}:]]))
box.out( elem._input( "text", ddns_password:get_var_name(), ddns_password:get_var_name_js(), ddns_password:get_value(), "30", "", attribs))
val.write_html_msg(g_val, ddns_password:get_var_name_js())
?>
</p>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
