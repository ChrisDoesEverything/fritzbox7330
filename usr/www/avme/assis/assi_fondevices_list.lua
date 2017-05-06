<?lua
g_page_type = "wizard"
g_page_title = "{?4368:506?}"
dofile("../templates/global_lua.lua")
if g_print_mode then
g_page_title = "{?4368:388?}"
end
require("http")
require("general")
require("fon_devices")
require("fon_devices_html")
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
g_first_wizard = false
if box.post.wiztype == "first" or box.get.wiztype == "first" then
g_first_wizard = true
end
if popup_url == "1" then
g_first_wizard = true
end
g_remoteData = {}
function read_box_values(use_cache)
g_remoteData.error = ""
g_remoteData.all_fon_devices = fon_devices.get_all_fon_devices(use_cache)
end
read_box_values(true)
if next(box.post) then
if box.post.delete then
local err,msg = fon_devices.delete_device(fon_devices.find_device(g_remoteData.all_fon_devices, box.post.delete))
if err ~= 0 then
g_remoteData.error = general.create_error_div(err, msg)
else
http.redirect(href.get('/assis/assi_fondevices_list.lua', http.url_param('popup_url', popup_url)))
end
elseif box.post.new_device then
local param = {}
table.insert(param, http.url_param('FonAssiFromPage', "assi_fondevices_list"))
table.insert(param, http.url_param('pagemaster', "assi_fondevices_list"))
table.insert(param, http.url_param('popup_url', popup_url))
fon_devices_html.do_new_device(param,"/assis/assi_telefon_start.lua")
elseif box.post.edit then
fon_devices_html.show_device(fon_devices.find_device(g_remoteData.all_fon_devices, box.post.edit), "fon_config", "assi_fondevices_list",popup_url)
elseif box.post.forward then
http.redirect(href.get("/assis/wlan_first.lua", http.url_param('popup_url', popup_url)))
elseif box.post.cancel then
http.redirect(href.get("/assis/home.lua", http.url_param('popup_url', popup_url)))
end
end
function write_popup()
if popup_url == "1" then
require("tr069")
local url = tr069.get_servicecenter_url()
box.js(url)
end
end
function write_forward_btn()
local show_wlan_first = config.WLAN and general.wlan_active()
if g_first_wizard and show_wlan_first then
box.out([[<button type="submit" name="forward">]])
box.html([[{?4368:803?}]])
box.out([[</button>]])
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<?lua
if g_print_mode then
box.out([[
<style type="text/css">
.buttonrow { display: none; }
</style>
]])
end
?>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" class="narrow" name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p <?lua if g_print_mode then box.out([[style="display:none;"]]) end ?>>
{?4368:367?}
</p>
<?lua fon_devices_html.write_no_unconfigurable_devices() ?>
<div>
<?lua fon_devices_html.write_fon_table(g_remoteData.all_fon_devices) ?>
</div>
<?lua box.out(g_remoteData.error) ?>
<div class="btn_form">
<button type="button" id="uiPrintList" name="print_list" onclick="onDoPrint()" >{?4368:539?}</button>
<button type="submit" id="uiNewDevice" name="new_device" <?lua fon_devices_html.new_device_button_disabled() ?> onclick="onNewDevice()">{?4368:718?}</button>
</div>
<div id="btn_form_foot">
<input type="hidden" name="wiztype" value="<?lua box.html(box.get.wiztype or box.post.wiztype or '') ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
<?lua write_forward_btn() ?>
<button type="submit" id="uiCancel" onclick="OnCancel()" name="cancel" class="nocancel">{?4368:816?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/tam_switch.js"></script>
<script type="text/javascript" src="/js/isp.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onDeleteClick(value){
var msgArray = <?lua box.out(js.table(fon_devices_html.get_delete_msg_table(g_remoteData.all_fon_devices))) ?>;
var check = confirm(msgArray[value]);
if (!check)
return false;
}
function onDoPrint() {
var url = "<?lua href.write(box.glob.script,'stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=775,height=400,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
function onNewDevice() {
if (<?lua box.out(tostring(fon_devices_html.no_number_configured())) ?>)
alert("{?4368:675?}");
}
function OnCancel()
{
openServiceCenter("<?lua write_popup() ?>");
return true;
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
