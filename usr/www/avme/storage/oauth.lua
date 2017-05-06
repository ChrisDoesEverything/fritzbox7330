<?lua
g_page_type = "no_menu"
g_page_title = [[{?869:711?}]]
g_popup_nobuttons = true
dofile("../templates/global_lua.lua")
require"cmtable"
require"html"
require"http"
require"js"
local state = {
["0"] = "service_unused",
["1"] = "state_fail",
["2"] = "state_success",
["3"] = "state_in_progress",
[""] = "unknown"
}
if box.get.oauth then
box.out(js.table({
authstate = state[box.query("t_media:settings/authstate")]
}))
box.end_page()
end
if box.post.code or box.get.code then
local code = box.post.code or box.get.code or ""
local saveset = {}
cmtable.add_var(saveset, "t_media:settings/authcode", code)
--local redirect_uri = [[http://fritz.box/storage/oauth.lua?popupwnd=1&sid=]] .. box.glob.inputsid
local redirect_uri = [[http://fritz.box/storage/oauth.lua?sid=]] .. box.glob.inputsid
cmtable.add_var(saveset, "t_media:settings/redirect_uri", redirect_uri)
local err, msg = box.set_config(saveset)
end
g_erronload = box.get.error or ""
?>
<?include "templates/html_head_popup.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
.wait {
margin-top: 30px;
margin-bottom: 30px;
}
#btn_form_foot {
width: 100%;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
function waitForResult() {
var json = makeJSONParser();
var url = encodeURI("<?lua box.js(box.glob.script) ?>") +
"?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>") +
"&" + buildUrlParam("oauth", "");
function sendRequest() {
ajaxGet(url, callback);
}
function callback(xhr) {
var done = false;
if (xhr && xhr.status == 200) {
var obj = json(xhr.responseText || "null");
switch(obj.authstate) {
case "state_in_progress":
break;
case "state_success":
jxl.hide("uiWait");
jxl.show("uiSuccess");
jxl.show("btn_form_foot");
done = true;
break;
case "state_fail":
default:
jxl.hide("uiWait");
jxl.show("uiFail");
jxl.show("btn_form_foot");
done = true;
break;
}
}
if (!done) {
setTimeout(sendRequest, 1000);
}
}
if ("<?lua box.js(g_erronload) ?>") {
jxl.hide("uiWait");
jxl.show("uiFail");
jxl.show("btn_form_foot");
}
else {
sendRequest();
}
}
ready.onReady(waitForResult);
</script>
<?include "templates/page_head_popup.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="uiWait" class="wait">
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<div>
{?869:629?}
</div>
</div>
<div id="uiSuccess" class="wait" style="display:none;">
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>
<div>
{?869:209?}
</div>
</div>
<div id="uiFail" class="wait" style="display:none;">
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<div>
{?869:198?}
</div>
</div>
<div id="btn_form_foot" style="display: none;">
<button type="button" name="close" onclick="window.close()">{?txtOK?}</button>
</div>
</form>
<?include "templates/page_end_popup.html" ?>
<?include "templates/html_end_popup.html" ?>
