<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_fondevices.html"
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("cmtable")
require("fon_devices")
require("fon_devices_html")
require("fon_numbers")
require"general"
g_remoteData = {}
function read_box_values(use_cache)
fon_devices.create_tam_empty_timeplans()
g_remoteData.error = ""
g_remoteData.all_fon_devices = fon_devices.get_all_fon_devices(use_cache)
end
read_box_values(true)
g_val = {
prog = [[
]]
}
if next(box.post) then
if box.post.delete then
local err,msg = fon_devices.delete_device(fon_devices.find_device(g_remoteData.all_fon_devices, box.post.delete))
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
else
--read_box_values()
http.redirect(href.get('/fon_devices/fondevices_list.lua'))
end
elseif box.post.new_device then
local param = {}
table.insert(param, http.url_param('FonAssiFromPage', "fonerweitert"))
table.insert(param, http.url_param('pagemaster', "fondevices_list"))
fon_devices_html.do_new_device(param,"/assis/assi_telefon_start.lua")
elseif box.post.edit then
fon_devices_html.show_device(fon_devices.find_device(g_remoteData.all_fon_devices, box.post.edit), "fon", "fondevices_list")
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_print_mode then
box.out([[
<style type="text/css">
.buttonrow { display: none; }
</style>
]])
end
?>
<style type="text/css">
div.incomingnumbers {
width:100px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" class="narrow" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p <?lua if g_print_mode then box.out([[style="display:none;"]]) end ?>>
{?6501:223?}
</p>
<?lua fon_devices_html.write_no_unconfigurable_devices() ?>
<div>
<?lua fon_devices_html.write_fon_table(g_remoteData.all_fon_devices) ?>
</div>
<?lua box.out(g_remoteData.error) ?>
<div id="btn_form_foot">
<button type="button" id="uiPrintList" name="print_list" onclick="uiDoPrint()" >{?6501:886?}</button>
<button type="submit" id="uiNewDevice" name="new_device" <?lua fon_devices_html.new_device_button_disabled() ?> onclick="uiShowNoNumber()">{?6501:62?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/focuschanger.js"></script>
<script type="text/javascript" src="/js/tam_switch.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onDeleteClick(value){
var msgArray = <?lua box.out(js.table(fon_devices_html.get_delete_msg_table(g_remoteData.all_fon_devices))) ?>;
var check = confirm(msgArray[value]);
if (!check)
return false;
}
function uiDoPrint() {
var url = "<?lua href.write( box.glob.script,'stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=775,height=400,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
function uiShowNoNumber() {
if (<?lua box.out(tostring(fon_devices_html.no_number_configured())) ?>)
alert("{?6501:468?}");
}
function initTableSorter() {
sort.init("uiFondevicesTbl");
sort.setDirection(0,-1);
sort.sort_table(0);
}
<?lua
if not g_print_mode then
box.out([[ready.onReady(initTableSorter);]])
end
?>
</script>
<?include "templates/html_end.html" ?>
