<?lua
g_page_type = "all"
g_page_title = "{?9820:157?}"
dofile("../templates/global_lua.lua")
require"html"
require"val"
require"http"
g_back_to_page = http.get_back_to_page( "/dect/dect_list.lua" )
g_menu_active_page = g_back_to_page
g_page_help = "hilfe_fon_dect_klingeltoene.html"
if (string.find(g_back_to_page,"assi")) then
g_page_type = "wizard"
end
g_val = {
prog = [[
if __exists(uiMP3FileShowName/PhonebookRingtoneName) then
char_range_regex(uiMP3FileShowName/PhonebookRingtoneName, url, error_txt)
end
]]
}
val.msg.error_txt = {
[val.ret.notfound] = [[{?9820:973?}]],
[val.ret.outofrange] = [[{?9820:987?}]]
}
phototype = box.get.phototype or "0"
function write_hidden_values()
html.input{type="hidden", name="PhonebookId", value=box.get.bookid or ""}.write()
html.input{type="hidden", name="PhonebookType", value=phototype}.write()
html.input{type="hidden", name="PhonebookEntryId", value=box.get.entryid or ""}.write()
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
function initEventHandler() {
jxl.addEventHandler("uiCancel", "click", function(evt){
var backToPage = readCookie("backtopage");
eraseCookie("backtopage");
var url = backToPage || "/fon_devices/edit_dect_ring_tone.lua";
location.href = url + "&sid=<?lua box.js(box.glob.sid) ?>";
return jxl.cancelEvent(evt);
});
}
function check_uploadfile(filename) {
var lastindex = filename.lastIndexOf("/");
var lastindex2 = filename.lastIndexOf("\\");
index=lastindex;
if(lastindex2>lastindex){index=lastindex2}
var titlename = filename.substring(index+1, filename.lastIndexOf("."));
var lowerext = filename.substr(filename.length-3, 3);
if(lowerext.toLowerCase() != "mp3" && lowerext.toLowerCase() != "wav"){
alert("{?9820:104?}");
jxl.disable("uiApply");
jxl.setValue("uiMP3File","");
return false;
}else{
g_filechoose_isinit = 1;
jxl.enable("uiApply");
}
if(jxl.getValue('uiMP3FileShowName') == ""){
jxl.setValue('uiMP3FileShowName',titlename);
}
return true;
}
<?lua
require("val")
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
ready.onReady(initEventHandler);
ready.onReady(val.init(uiDoOnMainFormSubmit));
</script>
<?include "templates/page_head.html" ?>
<form method="POST" action="../cgi-bin/firmwarecfg" target="_self" enctype="multipart/form-data" onsubmit="uiDoOnMainFormSubmit();">
<div class="formular">
<p>
{?9820:228?}
</p>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_hidden_values() ?>
<input id="uiMP3FileShowName" name="PhonebookRingtoneName" type="text" size="50" maxlength="70">
<?lua val.write_html_msg(g_val, "uiMP3FileShowName") ?>
<p>
{?9820:454?}
<br>
{?9820:860?}
</p>
<input id="uiMP3File" name="DECTMP3RingtoneFile" type="file" size="50" onchange="check_uploadfile(this.value);" accept="audio/*">
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="button" name="cancel" id="uiCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
