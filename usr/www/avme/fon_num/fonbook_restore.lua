<?lua
g_page_type = "all"
g_page_title = [[{?6572:271?}]]
dofile("../templates/global_lua.lua")
require("http")
require("fon_book")
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_list.lua" )
fonbook_id = ""
if box.post.uid then
fonbook_id = box.post.uid
elseif box.get.uid then
fonbook_id = box.get.uid
end
fonbook_name = ""
for i, book in ipairs(fon_book.get_fonbooks()) do
if book.id == tonumber(fonbook_id) then
fonbook_name = [[ "]]..book.name..[["]]
break
end
end
if box.post.btn_cancel then
http.redirect(href.get(g_back_to_page))
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form method="POST" action="../cgi-bin/firmwarecfg" enctype="multipart/form-data" id="uiPostImportForm" name="uiPostImportForm" onsubmit="return false">
<div>
{?6572:872?}<?lua box.html([[{?6572:172?}]]) ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="PhonebookId" value="<?lua box.html(fonbook_id) ?>">
<div class="formular">
<br>
<input type="file" size="40" value="" name="PhonebookImportFile" id="PhonebookImportFile">
</div>
</div>
</form>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<span id="btn_form_foot">
<button type="button" onclick="uiDoImport()" name="btn_ok">{?6572:4?}</button>
<button type="submit" id="btnCancel" name="btn_cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.out(g_back_to_page) ?>">
<input type="hidden" name="uid" value="<?lua box.html(fonbook_id) ?>">
</span>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript">
function uiDoImport ()
{
if (jxl.getValue("PhonebookImportFile") == "")
{
alert("{?6572:858?}");
return;
}
jxl.submitForm("uiPostImportForm");
}
</script>
<?include "templates/html_end.html" ?>
