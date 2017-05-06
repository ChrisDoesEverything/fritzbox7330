<?lua
g_page_type = "no_menu"
g_page_title = "{?3834:410?}"
if box.frominternet() or "1" ~= box.query("updatecheck:status/notification_active") then
box.end_page();
end
dofile("../templates/global_lua.lua")
if "now" == box.post.update or "later" == box.post.update then
require("cmtable")
local saveset = {}
local value = ""
if "now" == box.post.update then
value = "1"
end
cmtable.add_var(saveset, "updatecheck:settings/unauthorized_update", value)
box.set_config(saveset)
end
function get_features_url(info_url)
if info_url and #info_url > 0 then
local src = config.UPDATEFEATURE_URL
src = src .. [[&file=]] .. info_url
return src
end
return ""
end
g_info_url = box.query("updatecheck:status/notification_info_url")
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<?include "templates/page_head.html" ?>
<div id="uiState">
<?lua
if "now" == box.post.update then
box.out( [[
<p>{?3834:766?}</p>
<p class='waitimg'><img src='/css/default/images/wait.gif'></p>
<p>{?3834:195?}</p>
<br><p class='attention'>{?3834:419?}</p>
<p>{?3834:443?}</p>
]] )
elseif "later" == box.post.update then
box.out( [[
<p>{?3834:623?}</p>
]] )
else
local cur_ver = box.query("logic:status/nspver"):gsub("^(.-%.)", "")
local new_ver = box.query("updatecheck:status/notification_version"):gsub("^(.-%.)", "")
box.out( [[
<p>
{?3834:63?}
</p>
<div class="formular">
<label>{?3834:904?}:</label>
<span>]], box.tohtml(cur_ver), [[</span>
<br>
<label>{?3834:139?}:</label>
<span>]], box.tohtml(new_ver), [[</span>
</div>
<br>
]] )
if g_info_url and #g_info_url > 0 then
box.out([[<iframe src="http://boxupdate.avm.de:8080/hinweis.html" seamless height="200"></iframe>]])
end
box.out( [[
<p>
<a href="]], box.tohtml(g_info_url), [[" target="_blank">{?3834:425?}</a>
</p>
<br>
<p id="uiTextDoUpdate">
{?3834:324?}
</p>
<div id="btn_form_foot">
<form id="mainform" name="mainform" method="POST" action="]], box.tohtml( box.glob.script ), [[">
<input type="hidden" id="uiUpdate" name="update" value="">
</form>
<button type="button" onclick="uiUpdateNow()">{?3834:744?}</button>
<button type="button" onclick="uiUpdateLater()">{?3834:57?}</button>
</div>
]] )
end
?>
</div>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
if ( "now" == "<?lua box.html( box.post.update ) ?>" )
{
ajaxWaitForBox();
}
function delayedSubmit()
{
var form = jxl.get( "mainform" );
if ( form )
{
form.submit();
}
}
function uiUpdateNow()
{
jxl.get("uiUpdate").value = "now";
delayedSubmit();
return false;
}
function uiUpdateLater()
{
jxl.get("uiUpdate").value = "later";
delayedSubmit();
return false;
}
</script>
<?include "templates/html_end.html" ?>
