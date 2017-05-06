<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_needs_js=true
g_page_help = "hilfe_system_import.html"
--g_page_help = "hilfe_system_import_uebernahme.html"
if box.get.importmode and box.get.importmode == "as" or
box.post.importmode and box.post.importmode == "as" then
g_page_type = "wizard"
g_page_title = [[{?485:421?}]]
g_assi = box.get.importmode or box.post.importmode
end
dofile("../templates/global_lua.lua")
require"http"
require"href"
require"general"
g_back_to_page = http.get_back_to_page( box.glob.script )
if next(box.post) and box.post.btn_pressed or box.post.cancel then
if box.post.btn_pressed == "back" then
http.redirect(href.get("/assis/imexport.lua", "back_to_page="..g_back_to_page))
elseif box.post.cancel then
http.redirect(href.get(g_back_to_page))
end
end
require"val"
g_val = {
prog = [[
if __radio_check(uiRestoreFromOther/restore,other) then
not_empty(uiPass/ImportExportPassword, passerr)
end
]]
}
val.msg.passerr = {
[val.ret.empty] = [[{?485:840?}]]
}
function write_method_checked(which)
local tocheck = "same"
if box.get.cfg_nok then
tocheck = "other"
end
if which == tocheck then
box.out([[ checked]])
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<style type="text/css">
table.grid {
width:100%;
table-layout:fixed;
}
table.grid td {
vertical-align:top;
overflow:hidden;
}
form.forminline {
display: inline;
}
</style>
<?include "templates/page_head.html" ?>
<p>
{?485:4119?}
</p>
<hr/>
<h4>{?485:9032?}</h4>
<div class="formular">
<input type="radio" id="uiRestoreFromSame" name="restore" value="same" onclick="OnMethod('same')" <?lua write_method_checked('same') ?>>
<label for="uiRestoreFromSame">{?485:212?}</label>
<p class="form_radio_explain">{?485:451?}</p>
<input type="radio" id="uiRestoreFromOther" name="restore" value="other" onclick="OnMethod('other')" <?lua write_method_checked('other') ?>>
<label for="uiRestoreFromOther">{?485:626?}</label>
<p class="form_radio_explain">{?485:81?}</p>
</div>
<h4>{?485:126?}</h4>
<p>{?485:9661?}</p>
<form action="/cgi-bin/firmwarecfg" method="POST" class="narrow" enctype="multipart/form-data" autocomplete="off" name="mainform">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div class="formular">
<table class="grid">
<colgroup>
<col width="150px">
<col width="auto">
</colgroup>
<tr>
<td>
<label for="uiPass">{?485:755?}</label>
</td>
<td>
<input type="text" id="uiPass" name="ImportExportPassword" autocomplete="off"/><br>
<input type="file" id="uiImport" name="ConfigImportFile" size="40" />
<input type="file" id="uiTakeOver" name="ConfigTakeOverImportFile" size="40" disabled style="display:none;"/>
</td>
</tr>
</table>
</div>
<h4>{?485:4962?}</h4>
<p>{?485:3729?}</p>
<div id="btn_form_foot">
<?lua
if g_page_type == "wizard" then
box.out([[<button type="button" name="btnBack" id="btnBack" onclick="onBackBtn();">{?txtBack?}</button>]])
end
?>
<button name="apply" type="submit">{?485:9775?}</button>
</form>
<?lua
if g_page_type == "wizard" then
box.out([[<form class="forminline" name="main_form" method="POST" action="]]..box.glob.script..[[">]])
box.out([[<button type="submit" name="cancel" id="btnCancel">{?txtCancel?}</button>]])
box.out([[<input type="hidden" name="back_to_page" value="]]..box.tohtml(tostring(g_back_to_page))..[[">]])
box.out([[</form>]])
end
?>
</div>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua val.write_js_error_strings() ?>
function uiDoSubmit() {
var result = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
return result;
}
<?lua
if g_page_type ~= "wizard" then
box.out([[ready.onReady(val.init(uiDoSubmit));]])
end
?>
function OnMethod(method)
{
method = method || jxl.getRadioValue("restore") || "same";
if (method) {
var other=(method=="other");
var same=(method=="same");
jxl.setDisabled("uiTakeOver",!other);
jxl.display("uiTakeOver",other);
jxl.setDisabled("uiImport",!same);
jxl.display("uiImport",same);
}
}
<?lua
if g_page_type ~= "wizard" then
box.out([[ready.onReady(OnMethod);]])
end
?>
function submitWizardForm()
{
jxl.submitForm("wizard_form");
}
function onBackBtn()
{
jxl.setValue("btn_pressed", "back");
submitWizardForm();
}
</script>
<?include "templates/html_end.html" ?>
