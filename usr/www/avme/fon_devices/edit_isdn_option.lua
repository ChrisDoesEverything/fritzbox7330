<?lua
g_page_type = "all"
g_page_title = [[{?4291:84?}]]
g_page_help = "hilfe_fon_isdn.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("http")
g_back_to_page = http.get_back_to_page( "/fon_devices/fondevices_list.lua" )
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assis")) then
g_page_type ="wizard"
end
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
function redirect_back()
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
end
g_val = {
prog = [[]]
}
g_data={}
function read_data()
g_data.idx=box.get.idx or box.post.idx or 1
if not g_data.idx or not config.CAPI_NT then
redirect_back()
end
local isdn_list = fon_devices.read_nt_hotdiallist(true)
local l, device = fon_devices.find_elem(isdn_list, "nthotdiallist", "idx", tonumber(g_data.idx))
g_data.cur_elem = device
if not g_data.cur_elem then
redirect_back()
end
end
read_data()
g_local_tabs = fon_devices_html.get_isdn_tabs(g_data.cur_elem, {back_to_page=g_back_to_page, popup_url=popup_url})
if(next(box.post)) then
if box.post.btn_cancel then
redirect_back()
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save=fon_devices_html.get_other_options_save_data(g_data.cur_elem)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg)
box.out(criterr)
else
redirect_back()
end
end
end
end
function write_other_options()
box.out(fon_devices_html.get_other_options(g_data.cur_elem))
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<?include "templates/page_head.html" ?>
<form id="MainForm" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<?lua
write_other_options()
?>
</div>
<div id="btn_form_foot">
<input type="hidden" value="<?lua box.html(g_back_to_page)?>" name="back_to_page">
<input type="hidden" value="<?lua box.html(g_data.idx)?>" name="idx">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<button type="submit" name="btn_save" >{?txtApplyOk?}</button>
<button type="submit" name="btn_cancel" >{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_Warning = "{?4291:894?}";
<?lua
val.write_js_error_strings()
?>
function OnClickMwi(checked)
{
jxl.enableNode("uiMwiOptions", checked);
}
function OnClickBusy(checked)
{
jxl.enableNode("uiBusyOption", checked);
}
function init()
{
OnClickBusy(jxl.getChecked("uiBusy"));
OnClickMwi(jxl.getChecked("uiMwi"));
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
if (jxl.getChecked("uiFromInet"))
{
if (!confirm(g_Warning))
{
return false;
}
}
}
ready.onReady(val.init(onNumEditSubmit, "btn_save", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
