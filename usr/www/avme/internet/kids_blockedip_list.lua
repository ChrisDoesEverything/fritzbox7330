<?lua
g_page_type = "all"
g_page_title = [[{?6496:390?}]]
g_page_help = "hilfe_internet_filter_erlaubte_ip_adressen.html"
dofile("../templates/global_lua.lua")
require"general"
require"html"
require"cmtable"
require"http"
g_back_to_page = http.get_back_to_page( "/internet/trafficappl.lua" )
g_menu_active_page = g_back_to_page
g_err = {}
local list
if box.post.cancel then
http.redirect(g_back_to_page)
elseif box.post.clear then
local saveset = {}
cmtable.add_var(saveset, "blocked_ip:settings/clear", "")
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
elseif box.post.apply then
local saveset = {}
list = general.listquery("blocked_ip:settings/list/ip/list(UID,ip,name,allowed)")
local webvar = "blocked_ip:settings/list/ip[%s]/allowed"
for i, elem in ipairs(list) do
cmtable.add_var(saveset, webvar:format(elem.UID), box.post[elem.UID] and "1" or "0")
end
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(g_back_to_page)
end
end
list = general.listquery("blocked_ip:settings/list/ip/list(UID,ip,name,allowed)")
function write_list()
if #list == 0 then
html.tr{class="emptylist",
html.td{colspan=3,
[[{?6496:579?}]]
}
}.write()
else
for i, elem in ipairs(list) do
html.tr{
html.td{class="iconrow",
html.input{type="checkbox", name=elem.UID, checked=elem.allowed == "1"}
},
html.td{class="ipcell", elem.ip or ""},
html.td{elem.name or ""}
}.write()
end
end
end
function write_list_print()
local towrite = array.filter(list, func.eq("1", "allowed"))
if #towrite == 0 then
html.tr{class="emptylist",
html.td{colspan=2,
[[{?6496:614?}]]
}
}.write()
else
for i, elem in ipairs(towrite) do
html.tr{
html.td{elem.ip or ""},
html.td{elem.name or ""}
}.write()
end
end
end
function write_clear_link()
if #list > 0 then
html.br{}.write()
html.div{class="btn_form",
html.input{type="hidden", id="uiClear", name="clear", value="", disabled=true},
html.a{class="textlink", href=" ", onclick="return onClear();",
[[{?6496:931?}]]
}
}.write()
end
end
function write_save_error()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
function write_class()
if box.get.popupwnd then
box.out("popup")
else
box.out("edit")
end
end
function write_printurl()
href.write(box.glob.script)
end
function write_table_header()
local str_class=""
local str_span=""
if not g_print_mode then
str_class=[[sortable]]
str_span=[[<span class="sort_no">&nbsp;</span>]]
end
box.out([[<table class="zebra" id="uiListhead">
<tr class="thead">
<th class="iconrow">{?6496:131?}</th>
<th class="ipcell ]]..str_class..[[">{?6496:560?}]]..str_span..[[</th>
<th class="]]..str_class..[[">{?6496:162?}]]..str_span..[[</th>
</tr>
</table>]])
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
table#uiListhead {
margin-bottom: 0;
border-width: 1px 1px 0 1px;
}
div#uiScroll {
height: 300px;
overflow-y: auto;
overflow-x: hidden;
border: solid #c6c7be;
border-width: 0 1px 1px 1px;
background-color: #ffffff;
}
table#uiList {
margin-top: 0;
margin-bottom: 0;
border-width: 0;
}
table#uiListhead th:first-child,
table#uiList td:first-child {
width: 55px;
}
table#uiListhead th.ipcell,
table#uiList td.ipcell {
width: 300px;
}
.popup #uiEdit,
.edit #uiPopup {
display: none;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onClear() {
var txt = "{?6496:543?}";
if (confirm(txt)) {
jxl.enable("uiClear");
jxl.submitForm("mainform");
}
return false;
}
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
function initTableSorter() {
sort.init("uiListhead");
sort.addTbl(uiList);
//sort.sort_table(0);
}
<?lua
if not box.get.popupwnd then
box.out([[ready.onReady(initTableSorter);]])
box.out([[ready.onReady(addPopupOpener);]])
end
?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" class="<?lua write_class() ?>">
<div id="uiEdit">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_save_error() ?>
<p>
{?6496:759?}
</p>
<?lua
write_table_header()
?>
<div id="uiScroll">
<table class="zebra_reverse" id="uiList">
<?lua write_list() ?>
</table>
</div>
<?lua write_clear_link() ?>
<br>
<div class="btn_form">
<button style="display:none;" id="uiPrint" type="button" name="print">{?6496:206?}</button>
</div>
</div>
<div id="uiPopup">
<table class="zebra">
<tr>
<th>{?6496:450?}</th>
<th>{?6496:296?}</th>
</tr>
<?lua write_list_print() ?>
</table>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
