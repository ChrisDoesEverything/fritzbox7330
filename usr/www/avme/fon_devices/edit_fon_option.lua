<?lua
g_page_type = "all"
g_page_help = "hilfe_fon_nebenstelle.html"
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
g_data = {}
function read_data()
g_data.id = nil
if (next(box.get)) then
g_data.id = tonumber(box.get["idx"])
elseif(next(box.post)) then
g_data.id = tonumber(box.post["idx"])
end
if not g_data.id then
redirect_back()
end
g_data.cur_123phon = fon_devices.get_fon123_ring_data("Port"..tostring(g_data.id))
if not g_data.cur_123phon then
redirect_back()
end
local phonedata=fon_devices.get_fon123_phonedata(tostring(g_data.id))
if (phonedata) then
table.insert(g_data.cur_123phon, phonedata)
end
end
read_data()
g_page_title = [[{?3474:259?} ]]..g_data.cur_123phon[1].portname
g_local_tabs = fon_devices_html.get_fon_tabs(g_data.id, {back_to_page=g_back_to_page, popup_url=popup_url})
if next(box.post) then
if box.post.button_cancel then
redirect_back()
elseif box.post.button_save then
local ctlmgr_save={}
ctlmgr_save=fon_devices_html.get_other_options_save_data(g_data.cur_123phon[1])
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
box.out(general.create_error_div(err,msg))
else
redirect_back()
end
end
end
function write_other_options()
box.out(fon_devices_html.get_other_options(g_data.cur_123phon[1]))
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
<div class="formular small_indent">
<?lua
write_other_options()
?>
</div>
<div id="btn_form_foot">
<input type="hidden" value="<?lua box.html(g_back_to_page)?>" name="back_to_page">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<input type="hidden" name="idx" value="<?lua box.html(g_data.id) ?>">
<input type="hidden" name="type" value="<?lua box.html(g_type) ?>">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel" >{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
var g_mldClir = '{?3474:253?}\x0A\x0A{?3474:739?}';
var g_mldClir_ohneFestnetz = '{?3474:730?}\x0A\x0A{?3474:937?}';
function OnClickMwi(checked)
{
jxl.enableNode("uiMwiOptions", checked);
}
function OnClickBusy(checked)
{
jxl.enableNode("uiBusyOption", checked);
}
function OnClickClip(checked)
{
jxl.enableNode("uiClipMode", checked);
}
function OnClickClir(checked)
{
if (checked)
{
if ((<?lua box.out(tostring(config.CAPI_TE)) ?> == false) && (<?lua box.out(tostring(config.CAPI_POTS)) ?> == false))
{
alert(g_mldClir_ohneFestnetz);
}
else
{
if (<?lua box.out(config.is_known_oem()) ?>)
{
alert(g_mldClir);
}
else
{
alert(g_mldClir_ohneFestnetz);
}
}
}
}
function OnChangeTyp()
{
switch("<?lua box.out(g_data.cur_123phon[1].type) ?>") {
case "fon":
jxl.setDisabled("uiKnock", false);
break;
case "tam":
jxl.setChecked("uiKnock", true);
jxl.setDisabled("uiKnock", true);
break;
case "fax":
jxl.setChecked("uiKnock", false);
jxl.setDisabled("uiKnock", true);
break;
}
}
function init()
{
OnClickBusy(jxl.getChecked("uiBusy"));
OnClickMwi(jxl.getChecked("uiMwi"));
OnClickClip(jxl.getChecked("uiClip0"));
OnChangeTyp();
}
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
