<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_dect_handgeraete.html"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("cmtable")
require("fon_devices")
require("fon_devices_html")
require("fon_numbers")
g_remoteData = {}
function read_box_values(use_cache)
g_remoteData.error = ""
g_remoteData.dect_devices = fon_devices.read_fon_control(use_cache)
end
read_box_values(true)
g_val = {
prog = [[
]]
}
if next(box.post) then
if box.post.delete then
local err,msg = fon_devices.delete_device(fon_devices.find_device(g_remoteData.dect_devices, box.post.delete))
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
else
if #g_remoteData.dect_devices > 1 then
http.redirect(href.get('/dect/dect_list.lua'))
else
http.redirect(href.get('/dect/dect_settings.lua'))
end
end
elseif box.post.new_device then
local param = {}
table.insert(param, http.url_param('Submit_Goto', "AssiFonDectConStart"))
table.insert(param, http.url_param('TechTyp', "DECT"))
table.insert(param, http.url_param('FonAssiFromPage', "dect_list"))
table.insert(param, http.url_param('pagemaster', "dect_list"))
fon_devices_html.do_new_device(param, "/assis/assi_telefon.lua", "assi_telefon")
elseif box.post.edit then
fon_devices_html.show_device(fon_devices.find_device(g_remoteData.dect_devices, box.post.edit), "dect", "dect_list")
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" class="narrow" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?96:297?}
</p>
<?lua fon_devices_html.write_no_unconfigurable_devices() ?>
<div>
<?lua fon_devices_html.write_fon_table(g_remoteData.dect_devices) ?>
</div>
<?lua box.out(g_remoteData.error) ?>
<div id="btn_form_foot">
<button type="submit" id="uiNewDevice" name="new_device" <?lua fon_devices_html.new_device_button_disabled() ?> onclick="onShowNoNumber()">{?96:733?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/tam_switch.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
<?lua
val.write_js_error_strings()
?>
function onDeleteClick(value){
var msgArray = <?lua box.out(js.table(fon_devices_html.get_delete_msg_table(g_remoteData.dect_devices))) ?>;
var check = confirm(msgArray[value]);
if (!check)
return false;
}
function onShowNoNumber() {
if (<?lua box.out(tostring(fon_devices_html.no_number_configured())) ?>)
{
alert("{?96:893?}");
}
}
function init() {
}
function initTableSorter() {
sort.init("uiFondevicesTbl");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
