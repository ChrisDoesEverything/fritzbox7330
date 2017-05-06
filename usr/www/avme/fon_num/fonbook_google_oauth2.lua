<?lua
g_page_type = "all"
g_page_title = [[{?9501:628?}]]
dofile("../templates/global_lua.lua")
require"fon_book"
require"cmtable"
require"js"
g_back_to_page = http.get_back_to_page("/fon_num/fonbook_list.lua")
g_menu_active_page = g_back_to_page
local function get_webvar()
local node = box.get.ontelnode or box.post.ontelnode
if node then
return "ontel:settings/" .. node .. "/"
end
end
local function get_values()
local webvar = get_webvar()
local ontel = {}
ontel.usercode_verification_pending = box.query(webvar .. "usercode_verification_pending")
ontel.usercode = box.query(webvar .. "usercode")
ontel.verification_url = box.query(webvar .. "verification_url")
ontel.status = box.query(webvar .. "status")
ontel.rtok = box.query(webvar .. "rtok")
return ontel
end
local function delete_pb()
local webvar = get_webvar()
local id = box.query(webvar .. "id")
local err1 = fon_book.delete_fonbook(tonumber(id))
local saveset = {}
webvar = webvar:gsub("settings/", "command/")
cmtable.add_var(saveset, webvar , "delete")
local err2 = box.set_config(saveset)
local err3 = fon_book.set_akt_fonbook(0)
end
local function reset_pb()
local webvar = get_webvar()
local err, msg = box.set_config({{name=webvar .. "enabled", value="0"}})
err, msg = box.set_config({{name=webvar .. "enabled", value="1"}})
end
if not get_webvar() then
http.redirect(href.get(g_back_to_page))
end
if box.get.verification then
local answer = get_values()
answer.done = answer.usercode_verification_pending == "1"
box.out(js.table(answer))
box.end_page()
end
if box.post.retry then
reset_pb()
http.redirect(href.get(box.glob.script, http.url_param("ontelnode", box.post.ontelnode)))
end
if box.post.cancel then
if not box.post.success then
delete_pb()
end
http.redirect(href.get(g_back_to_page))
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style type="text/css">
.verify {
}
.verify span.usercode {
display: inline-block;
font-weight: bold;
width: 200px;
border: 1px solid #aaaaaa;
padding: 2px 4px;
}
.waiting .verifying,
.waiting .failure,
.waiting .success,
.verifying .waiting,
.verifying .failure,
.verifying .success,
.failure .waiting,
.failure .verifying,
.failure .success,
.success .waiting,
.success .verifying,
.success .failure {
display: none;
}
</style>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var box = <?lua box.out(js.table(box)) ?>;
function getVerification() {
var url = encodeURI(box.glob.script);
url = addUrlParam(url, "sid", box.glob.sid);
url = addUrlParam(url, "verification", "");
url = addUrlParam(url, "ontelnode", box.get.ontelnode || box.post.ontelnode);
var json = makeJSONParser();
var codeRetrieved = false;
var displayClasses = "waiting verifying success failure";
var frm = document.forms.mainform;
function display(className) {
jxl.removeClass(frm, displayClasses);
jxl.addClass(frm, className);
}
function request() {
ajaxGet(url, callback);
}
function urlOpener(url) {
return function() {
var opts = "width=500,height=400,resizable=yes,scrollbars=yes,location=no";
var ppWindow = window.open(url, "Google_Fenster", opts);
if (ppWindow) {
ppWindow.focus();
request();
jxl.show("uiWaitAuth");
jxl.hide("uiOpenUrl");
}
};
}
function callback(xhr) {
var answer = json(xhr.responseText || "{}");
var status = parseInt(answer.status);
if (isNaN(status)) {
status = 1000000;
}
if (answer.done && !codeRetrieved) {
codeRetrieved = true;
jxl.setText("uiCode", answer.usercode);
jxl.addEventHandler("uiOpenUrl", "click", urlOpener(answer.verification_url));
display("verifying");
} else if (answer.rtok) {
display("success");
jxl.enable("uiSuccess");
jxl.setText("uiCancel", "{?9501:878?}");
} else if (status == 1 || status > 2) {
display("failure");
jxl.enable("uiApply");
} else {
setTimeout(request, 3000);
}
}
request();
}
ready.onReady(getVerification);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="waiting">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="ontelnode"
value="<?lua box.html(box.get.ontelnode or box.post.ontelnode or '') ?>"
>
<input type="hidden" name="success" id="uiSuccess" value="" disabled>
<div class="wait waiting">
<p>
{?9501:605?}
</p>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<p>
{?9501:91?}
</p>
</div>
<div class="close verifying">
<div class="formular verify">
<p>
{?9501:433?}
<br>
{?9501:138?}
</p>
<p>
<label>
{?9501:756?}
</label>
<span class="usercode" id="uiCode">
</span>
</p>
<div>
<button type="button" id="uiOpenUrl">
{?9501:352?}
</button>
</div>
</div>
<div class="wait" id="uiWaitAuth" style="display:none;">
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<p>
{?9501:713?}
</p>
</div>
</div>
<div id="uiDone" class="wait success">
<p>
{?9501:18?}
</p>
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>
</div>
<div id="uiError" class="wait failure">
<p>
{?9501:53?}
</p>
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<p id="uiStatus"></p>
</div>
<div id="btn_form_foot">
<button type="submit" name="retry" class="failure">
{?9501:557?}
</button>
<button type="submit" name="cancel" id="uiCancel">
{?txtCancel?}
</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
