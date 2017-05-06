<?lua
g_page_type = "all"
g_page_title = "{?957:664?}"
dofile("../templates/global_lua.lua")
g_menu_active_page = "/fon_num/sip_option.lua"
require"html"
require("val")
require"general"
g_val = {
prog = [[]]
}
if next(box.post) then
require("cmtable")
local ctlmgr_save={}
if box.post.holdmusic == "0" or box.post.holdmusic == "1" then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MOHType", box.post.holdmusic)
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
else
http.redirect(href.get("/fon_num/sip_option.lua"))
end
end
g_moh_type = box.query("telcfg:settings/MOHType")
if g_moh_type~="0" and g_moh_type~="1" then
g_moh_type="2"
end
function write_radio_checked(select_type)
if tostring(select_type) == tostring(g_moh_type) then
return box.out([[ checked = "checked" ]])
end
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
uiOnTypeRadioClick("<?lua box.out(g_moh_type) ?>")
jxl.addEventHandler("uiCancel", "click", function(evt){
var backToPage = readCookie("backtopage");
eraseCookie("backtopage");
var url = backToPage || "/fon_num/sip_option.lua";
location.href = url + "?sid=<?lua box.js(box.glob.sid) ?>";
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
alert("{?957:899?}");
jxl.disable("uiApply");
jxl.setValue("uiMP3File","");
return false;
}else{
g_filechoose_isinit = 1;
jxl.enable("uiApply");
}
return true;
}
function uiOnTypeRadioClick(moh_type)
{
jxl.disableNode("uiFileDiv", moh_type!="2");
}
function OnOk()
{
if (!jxl.getChecked("uiCustom"))
{
jxl.submitForm("main");
return;
}
if (check_uploadfile(jxl.getValue("uiMP3File")))
jxl.submitForm("uploadform");
}
ready.onReady(initEventHandler);
</script>
<?include "templates/page_head.html" ?>
<div>
<div>{?957:668?}</div>
<br>
<form id="main_form" name="main" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="formular">
<input type="radio" name="holdmusic" id="uiMessage" value="0" onclick="uiOnTypeRadioClick('0')" <?lua write_radio_checked("0")?>>
<label for="uiMessage">{?957:924?}</label>
<br>
<input type="radio" name="holdmusic" id="uiMusic" value="1" onclick="uiOnTypeRadioClick('1')" <?lua write_radio_checked("1")?>>
<label for="uiMusic">{?957:725?}</label>
<br>
<input type="radio" name="holdmusic" id="uiCustom" value="custom" onclick="uiOnTypeRadioClick('2')" <?lua write_radio_checked("2")?>>
<label for="uiCustom">{?957:61?}</label>
<br>
</div>
</form>
<form name="uploadform" method="POST" action="../cgi-bin/firmwarecfg" target="_self" enctype="multipart/form-data">
<div class="formular" id="uiFileDiv">
<input type="hidden" name="sid" value="<?lua box.js(box.glob.sid) ?>">
<input type="hidden" name="MOHType" value="2">
<input id="uiMP3File" name="MOHImportFile" type="file" size="50" onchange="check_uploadfile(this.value);" accept="audio/*">
</div>
</form>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply" onclick="OnOk()">{?txtOK?}</button>
<button type="button" name="cancel" id="uiCancel">{?txtCancel?}</button>
</div>
</div>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
