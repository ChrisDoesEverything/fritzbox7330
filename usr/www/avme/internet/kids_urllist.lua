<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"general"
require"cmtable"
require"html"
require"http"
g_menu_active_page = "/internet/trafficappl.lua"
local listtype = nil
if box.get.listtype then
listtype = box.tohtml(box.get.listtype)
elseif box.post.listtype then
listtype = box.tohtml(box.post.listtype)
end
if not listtype or listtype == "" then
http.redirect(g_menu_active_page)
end
local title = {
black = [[{?5797:18?}]],
white = [[{?5797:905?}]]
}
if listtype then
g_page_title = title[listtype]
g_page_help = "hilfe_internet_filter_" .. listtype .. "list.html"
end
local err = {code = 0}
if box.post.apply and box.post.urllist then
local listcount = box.query("parental_control:settings/" .. listtype .. "list/url/count")
listcount = tonumber(listcount) or 0
local saveset = {}
local values = string.split(box.post.urllist, "%s+", true)
local n = 0
local prefix = "parental_control:settings/" .. listtype .. "list/url"
local postfix = "/url"
for i, url in ipairs(values) do
if #url > 0 then
cmtable.add_var(saveset, prefix .. n .. postfix, url)
n = n + 1
end
end
prefix = "parental_control:command/" .. listtype .. "list/url"
for i = listcount - 1, n, -1 do
cmtable.add_var(saveset, prefix .. i, "delete")
end
err.code, err.msg = box.set_config(saveset)
end
if box.post.cancel or box.post.apply and err.code == 0 then
local url = href.get("/internet/trafficappl.lua", "listtype=" .. listtype)
http.redirect(url)
end
local list = general.listquery("parental_control:settings/" .. listtype .. "list/url/list(url)")
function write_list()
for i, url in ipairs(list) do
box.html(url.url)
box.out("\n")
end
end
local explain = {
black = [[{?5797:201?}]],
white = [[{?5797:420?}]]
}
function write_explain()
if listtype then
box.html(explain[listtype])
end
end
function write_hidden_vars()
if listtype then
html.input{type="hidden", name="listtype", value=listtype}.write()
end
end
function write_class()
if box.get.popupwnd then
box.out("popup")
else
box.out("edit")
end
end
local list_empty = {
white = [[{?5797:66?}]],
black = [[{?5797:678?}]]
}
function write_list_table()
local tbl = html.table{class="zebra"}
if #list == 0 then
tbl.add(html.tr{
html.td{list_empty[listtype]}
})
else
for i, url in ipairs(list) do
tbl.add(html.tr{
html.td{url.url}
})
end
end
tbl.write()
end
function write_printurl()
href.write("/internet/kids_urllist.lua", "listtype=" .. listtype)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
textarea {
width: 90%;
padding: 5px;
font: inherit;
resize: vertical;
}
.popup #uiEdit,
.edit #uiPopup {
display: none;
}
</style>
<script type="text/javascript">
function addPopupOpener() {
var popupWin = null;
var opts = "width=520,height=560,statusbar,resizable=yes,scrollbars=yes"
var url = "<?lua write_printurl() ?>";
url += "&stylemode=print&popupwnd=1";
function openPopup(evt) {
var elem = jxl.evtTarget(evt);
if (!popupWin || popupWin.closed) {
popupWin = open(url, "Zweitfenster", opts);
}
else {
popupWin.location.href = url;
}
if (popupWin) {
popupWin.focus();
}
return jxl.cancelEvent(evt);
}
jxl.show("uiPrint");
jxl.addEventHandler("uiPrint", 'click', openPopup);
}
<?lua
if not box.get.popupwnd then
box.out([[ready.onReady(addPopupOpener);]])
end
?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="<?lua write_class() ?>">
<div id="uiEdit">
<?lua href.default_submit('apply') ?>
<p><?lua write_explain() ?></p>
<div class="formular">
<textarea id="uiUrllist" name="urllist" cols="30" rows="10"><?lua write_list() ?>
</textarea>
</div>
<div class="btn_form">
<button style="display:none;" id="uiPrint" type="button" name="print">{?5797:699?}</button>
</div>
</div>
<div id="uiPopup">
<?lua write_list_table() ?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_hidden_vars() ?>
<button type="submit" name="apply" id="uiApply">{?txtApplyOk?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
