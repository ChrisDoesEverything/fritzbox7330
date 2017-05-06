<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_system_import_uebernahme.html"
dofile("../templates/global_lua.lua")
require"val"
g_val = {
prog = " not_empty(uiPass/ImportExportPassword, passerr)"
}
val.msg.passerr = {
[val.ret.empty] = [[{?2219:924?}]]
}
?>
<?include "templates/html_head.html" ?>
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
ready.onReady(val.init(uiDoSubmit));
</script>
<?include "templates/page_head.html" ?>
<form action="/cgi-bin/firmwarecfg" method="POST" enctype="multipart/form-data" autocomplete="off"
class="narrow" name="mainform">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<p>{?2219:323?}</p>
<hr>
<h4>{?2219:394?}</h4>
<p>{?2219:896?}</p>
<div class="formular">
<label for="uiPass">{?2219:373?}</label>
<input type="text" id="uiPass" name="ImportExportPassword" autocomplete="off">
<br>
<input type="file" name="ConfigTakeOverImportFile" size="40" class="form_input_note">
</div>
<h4>{?2219:886?}</h4>
<p>{?2219:561?}</p>
<div id="btn_form_foot">
<button name="apply" type="submit">{?2219:199?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
