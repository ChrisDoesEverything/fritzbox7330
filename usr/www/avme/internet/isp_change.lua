<?lua
-- de-first -begin
g_page_type = "no_menu"
g_page_title = [[{?9675:243?}]]
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"cmtable"
require"js"
local known_params = array.truth{
'title', 'pagemaster', 'pagetype', 'button', 'query',
'toptext', 'bottomtext', 'poll', 'nologo', 'showtabs',
'cancel'
}
local unknown_params = {}
local options = {pagemaster = "/home/home.lua"}
for i, name in ipairs(general.sorted_by_i(box.get)) do
if known_params[name] then
options[name] = box.get[name]
else
table.insert(unknown_params, {
name = name, value = (box.get[name] or "")
})
end
end
if options.title then
g_page_title = options.title
end
if options.pagetype then
g_page_type = options.pagetype
if g_page_type == "all" then
g_menu_active_page = options.pagemaster
if options.showtabs then
g_menu_active_showtabs = true
end
end
end
function write_unknown_params()
for i, param in ipairs(unknown_params) do
html.input{
type="hidden", name=param.name, value=param.value
}.write()
end
end
function write_js_unknown_params()
box.out(js.array(unknown_params))
end
function write_pagemaster(ajax_call)
if (options.query=="reboot" and not ajax_call) then
box.out(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
return
end
box.html(options.pagemaster)
end
function write_pagemaster_js(ajax_call)
if (options.query=="reboot" and not ajax_call) then
box.js(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
return
end
box.js(options.pagemaster)
end
function write_script()
if options.pagetype == 'wizard' then
html.script{
type = "text/javascript",
src = "/js/dialog.js?lang=" .. config.language
}.write()
html.script{
type = "text/javascript",
src = "/js/wizard.js?lang=" .. config.language
}.write()
end
end
function write_callback()
if options.query then
box.out([[createQueryCallback("]] .. options.query .. [[")]])
end
end
function write_ondone()
if options.button then
box.out([[onDoneWithButton]])
else
box.out([[onDoneAutomatic]])
end
end
function write_poll()
box.out(tonumber(options.poll) or 1000)
end
function write_css()
if options.pagetype == 'wizard' then
html.link{
rel = "stylesheet",
type = "text/css",
href = "/css/default/wizard.css"
}.write()
end
end
function write_buttons()
if options.button then
local div = html.div{id="btn_form_foot"}
local btn = html.button{type="submit", name="ispchangedone", id="uiOk"}
if options.button == 'wizard' then
btn.class = "fwd_btn"
btn.add([[{?txtNextGreaterThan?}]])
else
btn.add([[{?txtApplyOk?}]])
end
div.add(btn)
if options.cancel then
div.add(html.button{
type="submit", name="ispchangecancel", id="uiCancel", [[{?txtCancel?}]]
})
end
div.write()
end
end
function write_toptext()
if options.toptext then
box.out(options.toptext)
else
box.out([[<p>]])
box.html([[{?9675:32?}]])
box.out([[</p>]])
end
end
function write_bottomtext()
if options.bottomtext then
box.out(options.bottomtext)
else
box.out([[<p>]])
box.html([[{?9675:789?}]])
box.out([[</p>]])
end
end
function write_1und1_logo()
if options.pagetype == 'wizard' and not options.nologo then
require"wizard"
wizard.write_1und1_logo()
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<?lua write_css() ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<?lua write_script() ?>
<script type="text/javascript">
var poll = <?lua write_poll() ?>;
var json = makeJSONParser();
var sidParam = buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
function createQueryCallback(query) {
var url = encodeURI("<?lua write_pagemaster_js(true) ?>");
url += "?" + sidParam;
url += "&";
var queries = (query || "").split(/\s*,\s*/);
return function(onDone) {
var nextQuery = queries.shift();
var queryParam = buildUrlParam("query", nextQuery);
var addInfoParam = "";
function continueOnClick(evt) {
jxl.cancelEvent(evt);
jxl.removeEventHandler("uiOk", "click", continueOnClick);
jxl.disableNode("btn_form_foot", true);
startNextQuery("notimeout");
}
function startNextQuery(notimeout) {
nextQuery = queries.shift();
if (nextQuery) {
queryParam = buildUrlParam("query", nextQuery);
if (notimeout) {
request();
}
else {
setTimeout(request, poll);
}
}
else {
onDone();
}
}
function callback(xhr) {
var response = json(xhr.responseText || "null");
if (!response) {
setTimeout(request, poll);
return;
}
jxl.show("uiWait");
jxl.hide("uiDone");
jxl.hide("uiError");
if (response.pagetitle) {
jxl.setHtml("uiPageTitle", response.pagetitle);
}
if (!response.done) {
if (response.showhtml) {
jxl.setHtml("uiWaitTop", response.showhtml);
}
if (response.addinfo) {
addInfoParam = "&" + buildUrlParam("addinfo", response.addinfo);
}
setTimeout(request, poll);
return;
}
else {
addInfoParam = "";
if (response.error) {
jxl.setValue("uiIspchangeDone", "error");
}
if (response.showresult) {
var idToShow = "uiDone"
if (response.error) {
idToShow = "uiError";
}
if (response.showhtml) {
jxl.setHtml(idToShow + "Top", response.showhtml);
}
if (response.dontstop && queries.length > 0) {
jxl.hide("uiWait");
jxl.show("uiDone");
jxl.disableNode("btn_form_foot", false);
jxl.addEventHandler("uiOk", "click", continueOnClick);
}
else {
onDone(idToShow);
}
}
else {
startNextQuery()
}
}
}
function request() {
ajaxGet(url + queryParam + addInfoParam, callback);
}
setTimeout(request, poll);
};
}
function onDoneWithButton(idToShow) {
jxl.hide("uiWait");
jxl.show(idToShow || "uiDone");
jxl.disableNode("btn_form_foot", false);
}
function onDoneAutomatic() {
var url = encodeURI("<?lua write_pagemaster_js(false) ?>");
url += "?" + sidParam;
url += "&" + buildUrlParam("ispchangedone", jxl.getValue("uiIspchangeDone") || "");
var unknownParams = [
<?lua write_js_unknown_params() ?>
];
for (var i = 0; i < unknownParams.length; i++) {
url += "&" + buildUrlParam(unknownParams[i].name, unknownParams[i].value);
}
location.href = url;
}
var onDone = <?lua write_ondone() ?>;
function waitForCtlmgr(onCtlmgrRestarted) {
var url = encodeURI("/query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam("restarting", "box:status/ctlmgr_restarting");
onCtlmgrRestarted = onCtlmgrRestarted || function(cb){return cb();};
function callback(xhr) {
var response = json(xhr.responseText || "null");
if (!response || parseInt(response.restarting) !== 0) {
setTimeout(request, 1000);
}
else {
onCtlmgrRestarted(onDone);
}
}
function request() {
ajaxGet(url, callback);
}
request();
}
function init() {
jxl.disableNode("btn_form_foot", true);
setTimeout(function() {
waitForCtlmgr(<?lua write_callback() ?>);
}, 1000);
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form action="<?lua write_pagemaster(false) ?>" method="POST">
<?lua write_1und1_logo() ?>
<div id="uiWait" class="wait">
<div id="uiWaitTop"><?lua write_toptext() ?></div>
<p class="waitimg"><img src="/css/default/images/wait.gif"></p>
<div id="uiWaitBottom"><?lua write_bottomtext() ?></div>
</div>
<div id="uiDone" class="wait" style="display:none;">
<div id="uiDoneTop">
<p>{?9675:732?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif"></p>
<div id="uiDoneBottom"></div>
</div>
<div id="uiError" class="wait" style="display:none;">
<div id="uiErrorTop">
<p>{?9675:358?}</p>
</div>
<p class="waitimg"><img src="/css/default/images/finished_error.gif"></p>
<div id="uiErrorBottom"></div>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="ispchangedone" value="" id="uiIspchangeDone">
<?lua write_unknown_params() ?>
<?lua write_buttons() ?>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
