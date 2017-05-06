<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_usb_fernanschluss.html"
dofile("../templates/global_lua.lua")
require("http")
require("cmtable")
require("general")
g_aura = {}
function get_var()
g_aura.enabled = box.query("aura:settings/enabled")
g_aura.aura4storage = box.query("aura:settings/aura4storage")
g_aura.aura4printer = box.query("aura:settings/aura4printer")
g_aura.aura4other = box.query("aura:settings/aura4other")
end
get_var()
function check_aura_changed()
return (box.post.aura_enabled and g_aura.enabled~="1") or (not(box.post.aura_enabled) and g_aura.enabled=="1") or
(box.post.aura_storage and g_aura.aura4storage~="1") or (not(box.post.aura_storage) and g_aura.aura4storage=="1") or
(box.post.aura_printer and g_aura.aura4printer~="1") or (not(box.post.aura_printer) and g_aura.aura4printer=="1") or
(box.post.aura_other and g_aura.aura4other~="1") or (not(box.post.aura_other) and g_aura.aura4other=="1")
end
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
local show_aura_change = false
if check_aura_changed() then
cmtable.save_checkbox(ctlmgr_save, "aura:settings/enabled" , "aura_enabled")
if box.post.aura_enabled then
cmtable.save_checkbox(ctlmgr_save, "aura:settings/aura4storage" , "aura_storage")
cmtable.save_checkbox(ctlmgr_save, "aura:settings/aura4printer" , "aura_printer")
cmtable.save_checkbox(ctlmgr_save, "aura:settings/aura4other" , "aura_other")
end
show_aura_change = true
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=general.create_error_div(err,msg,[[{?1162:55?}]])
box.out(criterr)
else
get_var()
if show_aura_change then
http.redirect(href.get('/usb/aura_change.lua', 'back_to_page='..box.glob.script))
end
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript">
function ShowPopup()
{
var url = "<?lua href.write('/usb/aura_download.lua') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=520,height=560,scrollbars=yes,resizable=yes");
ppWindow.focus();
}
function onAuraEnabled()
{
jxl.disableNode("uiViewAuraEnabledInnerBox", !jxl.getChecked("uiViewAuraEnabled"));
jxl.display("uiViewProgramHint", jxl.getChecked("uiViewAuraEnabled"));
}
function init()
{
onAuraEnabled();
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
{?1162:117?}
</p>
<p>
{?1162:616?}
</p>
<p id="uiViewProgramHint" <?lua if g_aura.enabled~="1" then box.out('style="display:none;"') end ?>>
<?lua
local txt = [[<span class="hintMsg">{?1162:991?}</span>]]
txt = txt..[[{?1162:734?}]]
txt = general.sprintf(txt, [[<a href="javascript:ShowPopup()" title="{?1162:47?}">]], [[</a>]])
box.out(txt)
?>
</p>
<div id="uiViewAuraEnabledBox">
<hr>
<h4>{?1162:118?}</h4>
<div class="formular">
<input type="checkbox" name="aura_enabled" id="uiViewAuraEnabled" onclick="onAuraEnabled()" <?lua if g_aura.enabled=="1" then box.out("checked") end?>>
<label for="uiViewAuraEnabled">{?1162:724?}</label>
<div id="uiViewAuraEnabledInnerBox" class="formular">
<p>
{?1162:305?}
</p>
<input type="checkbox" name="aura_printer" id="uiViewAuraPrinter" <?lua if g_aura.aura4printer=="1" then box.out("checked") end?>>
<label for="uiViewAuraPrinter">{?1162:512?}</label>
<br>
<input type="checkbox" name="aura_storage" id="uiViewAuraStorage" <?lua if g_aura.aura4storage=="1" then box.out("checked") end?>>
<label for="uiViewAuraStorage">{?1162:761?}</label>
<br>
<input type="checkbox" name="aura_other" id="uiViewAuraOther" <?lua if g_aura.aura4other=="1" then box.out("checked") end?>>
<label for="uiViewAuraOther">{?1162:704?}</label>
</div>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
