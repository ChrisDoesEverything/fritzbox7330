<?lua
g_page_type = "all"
dofile("../templates/global_lua.lua")
require"html"
require"http"
g_back_to_page = http.get_back_to_page( "/dect/dect_list.lua" )
phototype = box.get.phototype or "0"
g_page_title = "{?1586:703?}"
if (phototype=="1") then
g_page_title = "{?1586:717?}"
end
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assi")) then
g_page_type = "wizard"
end
function write_hidden_values()
html.input{type="hidden", name="PhonebookId", value=box.get.bookid or ""}.write()
html.input{type="hidden", name="PhonebookType", value=phototype}.write()
html.input{type="hidden", name="PhonebookEntryId", value=box.get.entryid or ""}.write()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
function initEventHandler() {
jxl.addEventHandler("uiCancel", "click", function(evt){
var backToPage = readCookie("backtopage");
eraseCookie("backtopage");
var url = backToPage || "/fon_num/fonbook_list.lua";
location.href = url + "&sid=<?lua box.js(box.glob.sid) ?>";
return jxl.cancelEvent(evt);
});
}
ready.onReady(initEventHandler);
</script>
<?include "templates/page_head.html" ?>
<form name="uploadform" method="POST" action="../cgi-bin/firmwarecfg" target="_self" enctype="multipart/form-data">
<p>
<?lua if phototype == "1" then
box.out([[{?1586:952?}]])
else
box.out([[{?1586:524?}]])
end ?>
</p>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_hidden_values() ?>
<div class="formular">
<input name="PhonebookPictureFile" type="file" size="50">
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="button" name="cancel" id="uiCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
