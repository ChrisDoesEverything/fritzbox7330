<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_needs_js = true
g_page_help = "hilfe_system_export.html"
if box.get.exportmode and box.get.exportmode == "as" or
box.post.exportmode and box.post.exportmode == "as" then
g_page_type = "wizard"
g_page_title = [[{?741:368?}]]
g_assi = box.get.exportmode == "as" or box.post.exportmode == "as"
end
dofile("../templates/global_lua.lua")
require"val"
require"cmtable"
require"general"
require"http"
require"href"
require"pushservice"
g_back_to_page = http.get_back_to_page( box.glob.script )
if next(box.post) and box.post.btn_pressed or box.post.cancel then
if box.post.btn_pressed == "back" then
http.redirect(href.get("/assis/imexport.lua", "back_to_page="..g_back_to_page))
elseif box.post.cancel or box.post.btn_pressed == "save" then
http.redirect(href.get(g_back_to_page))
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
form.forminline {
display: inline;
}
</style>
<?include "templates/page_head.html" ?>
<div>
<form action="/cgi-bin/firmwarecfg" method="POST" class="narrow" name="exportform" id="uiExportform" enctype="multipart/form-data" autocomplete="off">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<p>
{?741:8478?}
</p>
<p>
{?741:346?}
</p>
<hr>
<h4>{?741:2517?}</h4>
<p>{?741:7555?}</p>
<div class="formular">
<label for="uiPass">
{?741:3813?}
</label>
<input type="text" name="ImportExportPassword" id="uiPass" autocomplete="off">
</div>
<strong>{?txtHinweis?}</strong>
<p>{?741:493?}
<br>
{?741:63?}</p>
<?lua
box.out([[
<div id="btn_form_foot">]])
if g_page_type == "wizard" then
box.out([[<button type="button" name="btnBack" id="btnBack" onclick="onBackBtn();">{?txtBack?}</button>]])
end
box.out([[<button type="submit" name="ConfigExport" onclick="onSaveBtn();">{?741:72?}</button> </form>]])
if g_page_type == "wizard" then
box.out([[</form><form name="main_form" class="forminline" method="POST" action="]]..box.glob.script..[[">]])
box.out([[<button type="submit" style="display:inline" name="cancel" id="btnCancel">{?txtCancel?}</button>]])
box.out([[<input type="hidden" name="back_to_page" value="]]..box.tohtml(tostring(g_back_to_page))..[[">]])
box.out([[</form>]])
end
box.out([[
</div>
]])
?>
</div>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
createPasswordChecker( "uiPass" );
function submitWizardForm()
{
jxl.submitForm("wizard_form");
}
function onBackBtn()
{
jxl.setValue("btn_pressed", "back");
submitWizardForm();
}
function onSaveBtn()
{
jxl.setValue("btn_pressed", "save");
window.setTimeout(submitWizardForm,2000);
}
</script>
<?include "templates/html_end.html" ?>
