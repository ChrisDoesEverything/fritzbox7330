<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require("cmtable")
require("general")
require("http")
require("href")
function get_features_url(info_url)
if info_url and #info_url > 0 then
local src = config.UPDATEFEATURE_URL
src = src .. [[&file=]] .. info_url
return src
end
return ""
end
g_back_to_page = http.get_back_to_page( box.glob.script )
if box.post.cancel or box.post.home then
if g_back_to_page == box.glob.script then
box.get.check = nil
else
http.redirect(href.get(g_back_to_page))
end
end
if box.post.start or box.get.start=="1" then
local saveset = {}
cmtable.save_checkbox(saveset, "updatecheck:settings/start", "1")
box.set_config(saveset)
end
if box.get.check then
g_state = box.query("updatecheck:status/state")
else
g_state = "0"
end
if g_state=="0" then
g_page_help = "hilfe_system_update_automatic.html"
end
g_curr_version = box.query("logic:status/nspver")
if g_state == "11" then
g_new_version = box.query("updatecheck:status/version")
g_info_url = box.query("updatecheck:status/info_url")
g_download_url = box.query("updatecheck:status/download_url")
g_hint_url = box.query("updatecheck:status/hint_url")
g_features_url = get_features_url(g_info_url)
else
g_new_version = "#ver#"
g_info_url = "#info#"
g_download_url = "#down#"
g_hint_url = "#hint#"
g_features_url = get_features_url("#info#")
end
g_expert = (box.query("box:settings/expertmode/activated")=="1")
g_block_noupdate = [[
<p class="topstatus">{?72:323?}</p>
<p class="waitimg"><img src="/css/default/images/finished_ok_green.gif" alt="{?72:791?}"></p>
]]
g_block_error = [[
<p class="topstatus">{?72:112?}</p>
<p class="waitimg"><img src="/css/default/images/finished_error.gif" alt="{?72:394?}"></p>
]]
g_block_update_version = [[
<p>{?72:611?}</p>
<div class="formular">
<label>{?72:692?}:</label>
<span>]]..g_curr_version:gsub("^(.-%.)", "")..[[</span>
<br>
<label>{?72:338?}:</label>
<span>]]..g_new_version:gsub("^(.-%.)", "")..[[</span>
</div>
<br>
]]
g_block_update_features = [[
<iframe src="]]..g_features_url..[[" seamless height="200"></iframe>
]]
g_block_update_info = [[
<p><a href="]]..g_info_url..[[" target="_blank">{?72:287?}</a></p>
<br>
<p id="uiTextDoUpdate">
{?72:799?}
</p>
]]
g_block_update_hint = [[
<h4>{?72:510?}</h4>
<iframe src="]]..g_hint_url..[[" seamless></iframe>
<input type="checkbox" id="uiHint"> <label for="uiHint">{?72:742?}</label>
]]
g_block_update_form = [[
<form method="POST" action="/cgi-bin/firmwarecfg" enctype="multipart/form-data" id="uiUpdateForm">
<p class="innerbutton" id="uiUpdate">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<input type="hidden" name="update_url" value="]]..box.tohtml(g_download_url)..[[">
</p>
</form>
]]
g_button_noupdate = [[
<button type="submit" name="home">{?txtApplyOk?}</button>
]]
g_button_error = [[
<button type="submit" name="cancel">{?txtBack?}</button>
]]
g_button_update = [[
<button id="uiStartUpdate" type="button" onclick="uiDoOnUpdateSubmit()">{?72:8282?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
]]
function jsstr(str)
require"js"
box.out(js.quoted(str))
end
g_tab_options.notabs = g_state ~= "0"
function show_act_calls()
local str = ""
if config.FON then
require"foncalls"
local calls = foncalls.get_activecalls()
if #calls > 0 then
str =[[<div id="uiActiveWarning">
<strong>{?txtHinweis?}</strong>
<p>{?72:8411?}]]
str = str..[[</p><table class="zebra"><tr><th></th>]]
str = str..[[<th>{?72:872?}</th><th>{?72:741?}</th><th>{?72:425?}</th></tr>]]
for i, call in ipairs(calls) do
local symbol = foncalls.get_callsymbol(call.call_type)
str = str..[[
<tr><td class="]]..box.tohtml(symbol.class or "")..[["></td>
<td class="]]..box.tohtml(symbol.dirclass or "")..[[">]]..box.tohtml(foncalls.number_shortdisplay(call))..[[</td>
<td>]]..box.tohtml(foncalls.port_display(call))..[[</td>
<td>]]..box.tohtml(call.duration or "")..[[</td>
</tr>]]
end
str = str..[[</table></div>]]
end
end
return str
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<link rel="stylesheet" type="text/css" href="/css/default/update.css"/>
<style type="text/css">
#uiActiveWarning table {
white-space: nowrap;
}
</style>
<?include "templates/page_head.html" ?>
<div id="uiVersion">
<?lua
if g_state~="11" then
local nspver = box.query("logic:status/nspver")
nspver = nspver:gsub("^(.-%.)", "")
if config.LABOR_ID_NAME and config.LABOR_ID_NAME ~= "" then
nspver = nspver.." "..config.LABOR_ID_NAME
end
box.out([[
<p>{?72:982?}</p>
<p>{?72:404?}<span class="fake_text_input auto_size">]], box.tohtml(nspver), [[</span></p>
<hr/>
]])
end
?>
</div>
<div id="uiState">
<?lua
if g_state=="0" then
box.out([[
<p>{?72:370?}</p>
<p>{?72:176?}</p>
<p>]], general.sprintf([[{?72:227?}]], [[<a href="]] .. href.get("/system/push_list.lua") .. [[">]],[[</a>]]), [[</p>
]])
box.out([[
<form method="POST" action="/system/update.lua?check=1">
<input type="hidden" name="sid" value="]]..box.tohtml(box.glob.sid)..[[">
<p class="innerbutton">
<button type="submit" name="start">{?72:571?}</button>
</p>
</form>
]])
elseif g_state=="1" then
box.out(show_act_calls())
box.out([[
<p class="topstatus">{?72:23?}</p>
<p class="waitimg"><img src="/css/default/images/wait.gif" alt="{?72:314?}"></p>
]])
elseif g_state=="10" then
box.out(g_block_noupdate)
elseif g_state=="11" then
box.out(g_block_update_version)
if g_info_url and #g_info_url > 0 then
box.out(g_block_update_features)
end
box.out(g_block_update_info)
if string.len(g_hint_url) > 0 then
box.out(g_block_update_hint)
end
box.out(show_act_calls())
box.out(g_block_update_form)
else
box.out(g_block_error)
end
?>
</div>
<form method="POST" action="/system/update.lua?check=1">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<?lua
if g_state~="0" then
box.out([[<div id="btn_form_foot">]])
if g_state=="1" then
box.out([[
<button type="submit" name="refresh">{?txtRefresh?}</button>
]])
elseif g_state=="10" then
box.out(g_button_noupdate)
elseif g_state=="11" then
box.out(g_button_update)
else
box.out(g_button_error)
end
box.out([[</div>]])
end
?>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var gQueryVars = {
state: { query: "updatecheck:status/state" },
version: { query: "updatecheck:status/version" },
info: { query: "updatecheck:status/info_url" },
download: { query: "updatecheck:status/download_url" },
hint: { query: "updatecheck:status/hint_url" },
infotext: { query: "updatecheck:status/info_text" }
};
function cbWait() {
var state = parseInt(gQueryVars.state.value, 10);
if (state <= 1) {
/* continue polling */
return false;
}
switch (state) {
case 10:
jxl.setHtml("uiState", <?lua jsstr(g_block_noupdate) ?>);
jxl.setHtml("btn_form_foot", <?lua jsstr(g_button_noupdate) ?>);
break;
case 11:
jxl.hide("uiVersion");
var withHint = (gQueryVars.hint.value && gQueryVars.hint.value.length > 0);
var withFeatures = gQueryVars.info.value && gQueryVars.info.value.length;
var content = <?lua jsstr(g_block_update_version) ?>.replace(/#ver#/,gQueryVars.version.value.replace(/^[^\.]*\./, ""));
if (withFeatures) {
content += <?lua jsstr(g_block_update_features) ?>.replace(/#info#/, gQueryVars.info.value);
}
content += <?lua jsstr(g_block_update_info) ?>.replace(/#info#/, gQueryVars.info.value);
if (withHint) {
content += <?lua jsstr(g_block_update_hint) ?>.replace(/#hint#/,gQueryVars.hint.value);
}
content += <?lua jsstr(show_act_calls()) ?>;
content += <?lua jsstr(g_block_update_form) ?>.replace(/#down#/,gQueryVars.download.value);
jxl.setHtml("uiState", content);
jxl.setHtml("btn_form_foot", <?lua jsstr(g_button_update) ?>);
if (withHint) {
jxl.hide("uiUpdate");
jxl.addEventHandler("uiHint", "change", function() { jxl.show("uiUpdate"); });
}
break;
default:
jxl.setHtml("uiState", <?lua jsstr(g_block_error) ?>);
jxl.setHtml("btn_form_foot", <?lua jsstr(g_button_error) ?>);
break;
}
jxl.show('btn_form_foot');
/* stop polling */
return true;
}
function delayedSubmit() {
var form = jxl.get("uiUpdateForm");
if (form) {
form.submit();
}
}
function uiDoOnUpdateSubmit() {
jxl.hide("uiTextDoUpdate");
jxl.disable("uiHint");
jxl.disable("uiStartUpdate");
var wait = document.createElement("div");
jxl.setHtml(wait,
"<p>{?72:123?}</p>" +
"<p class='waitimg'><img src='/css/default/images/wait.gif'></p>" +
"<p>{?72:212?}</p>" +
"<br><p class='attention'>{?72:171?}</p>" +
"<p>{?72:156?}</p>"
);
var parent = jxl.get("uiState");
parent.appendChild(wait);
setTimeout(delayedSubmit, 1000);
return false;
}
<?lua
if g_state=="1" then
box.out([[
function init() {
jxl.hide('btn_form_foot');
ajaxWait(gQueryVars, "]]..box.tojs(box.glob.sid)..[[", 5000, cbWait);
}
ready.onReady(init);
]])
end
?>
</script>
<?include "templates/html_end.html" ?>
