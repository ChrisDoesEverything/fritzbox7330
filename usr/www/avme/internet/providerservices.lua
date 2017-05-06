<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_netzwerk_providerservice.html"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"cmtable"
require"http"
require"tr069"
local gui_mode = tonumber(tr069.gui_mode)
local show, show_disabled
if gui_mode then
show = gui_mode > 0
show_disabled = gui_mode == 2
else
show = true
show_disabled = tr069.unprovisioned()
end
function writehtml_enabled()
if show then
local addclass = show_disabled and " disable_onload" or ""
html.div({class = "formular" .. addclass},
html.input({
type = "checkbox", name = "enabled", id = "uiEnabled",
disabled = show_disabled, checked = tr069.enabled == "1"
}),
html.label({["for"] = "uiEnabled"},
[[{?8636:5?}]]
),
html.p({class = "form_input_explain"},
[[{?8636:772?}]]
)
).write()
end
end
function writehtml_FWdownload_enable()
if show then
html.hr().write()
local disabled = tr069.enabled ~= "1"
local addclass = disabled and " disable_onload" or ""
html.div({class = "formular enableif_enabled" .. addclass},
html.input({
type = "checkbox", name = "FWdownload_enable", id = "uiFWdownload_enable",
checked = tr069.FWdownload_enable == "1", disabled = disabled
}),
html.label({["for"] = "uiFWdownload_enable"},
[[{?8636:317?}]]
),
html.p({class = "form_input_explain"},
[[{?8636:394?}]]
)
).write()
end
end
function writehtml_dhcp43_support()
if show then
html.hr().write()
local disabled = tr069.enabled ~= "1"
local addclass = disabled and " disable_onload" or ""
html.div({class = "formular enableif_enabled" .. addclass},
html.input({
type = "checkbox", name = "dhcp43_support", id = "uiDhcp43_support",
checked = tr069.dhcp43_support == "1", disabled = disabled
}),
html.label({["for"] = "uiDhcp43_support"},
[[{?8636:461?}]]
),
html.p({class = "form_input_explain"},
[[{?8636:837?}]]
)
).write()
end
end
function writehtml_tr069resetcfg()
if tr069.provisioned_by_kdg() then
html.hr().write()
html.div({class = "formular", id="uiKDGTr069"},
html.p({},
[[{?8636:145?}]]
),
html.p({},
[[{?8636:673?}]]
),
html.div({class = "btn_form"},
html.button({type = "submit", name = "tr069resetcfg", id = "uiTr069resetcfg"},
[[{?8636:202?}]]
)
)
).write()
end
end
function write_tr069resetcfg_confirm_js()
if tr069.provisioned_by_kdg() then
box.js([[{?8636:891?}]])
box.out([[\n\n]])
box.js([[{?8636:973?}]])
end
end
if box.post.apply then
local saveset = {}
if not show_disabled then
cmtable.add_var(saveset, "tr069:settings/enabled", box.post.enabled and "1" or "0")
end
cmtable.add_var(saveset, "tr069:settings/FWdownload_enable", box.post.FWdownload_enable and "1" or "0")
cmtable.add_var(saveset, "tr069:settings/dhcp43_support", box.post.dhcp43_support and "1" or "0")
local e, m = box.set_config(saveset)
elseif box.post.tr069resetcfg then
local saveset = {}
cmtable.add_var(saveset, "tr069:settings/tr069resetcfg", "1")
local e, m = {box.set_config(saveset)}
require("webuicookie")
saveset = {}
webuicookie.set_action_allowed_time()
cmtable.add_var(saveset, webuicookie.vars())
box.set_config(saveset)
http.redirect(href.get("/reboot.lua"))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript">
function disableNodesOnLoad() {
var classStr = "disable_onload";
var nodes = jxl.getByClass(classStr);
var i = nodes.length || 0;
while(i--) {
jxl.disableNode(nodes[i], true);
jxl.removeClass(nodes[i], classStr);
}
}
function pageInit() {
disableNodesOnLoad();
enableOnClick({
inputName: "enabled",
classString: "enableif_enabled"
});
}
function initKdgTr069Confirm() {
var txt = "<?lua write_tr069resetcfg_confirm_js() ?>";
function onKdgTr069Refresh(evt) {
if (!confirm(txt)) {
return jxl.cancelEvent(evt);
}
}
if (txt) {
jxl.addEventHandler("uiTr069resetcfg", "click", onKdgTr069Refresh);
}
}
ready.onReady(pageInit);
ready.onReady(initKdgTr069Confirm);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<?lua
writehtml_enabled()
writehtml_FWdownload_enable()
writehtml_dhcp43_support()
writehtml_tr069resetcfg()
?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
