<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_anrufliste.html"
dofile("../templates/global_lua.lua")
require"http"
require"cmtable"
require"js"
require"general"
require"foncalls"
require"fon_book"
local function show_clicktodial()
local right_to_dial = tonumber(box.query("rights:status/Dial",0)) > 0
local use_dial= box.query("telcfg:settings/UseClickToDial") == "1"
return use_dial and right_to_dial
end
g_callstab = box.get.callstab or box.post.callstab or 'all'
g_calls = {}
local function get_fonbook_link(call)
return fon_book.addnum_link(call.number, call.name)
end
function write_tab_img(which)
local sym = foncalls.get_callsymbol(which)
if sym.img then
box.out("\n", [[<img src="]], sym.img, [[">]])
end
end
function write_use_label()
box.html(general.sprintf(
[[{?3310:518?}]],
foncalls.count_all()
))
end
function write_use_checked()
if foncalls.is_used() then
box.out([[ checked]])
end
end
function write_tab_classes(which)
local classes = {}
if which ~= 'all' then
table.insert(classes, "tabpic")
end
if which == g_callstab then
table.insert(classes, "active")
end
if #classes > 0 then
box.out([[ class="]], table.concat(classes, " "), [["]])
end
end
function write_main_class()
box.out([[ class="]])
box.html(g_callstab)
box.out(general.is_expert() and "" or " noexpert")
box.out([["]])
end
function write_emptylist()
if #g_calls == 0 then
local txt_empty = [[{?3310:301?}]]
if foncalls.is_used() then
txt_empty = [[{?3310:145?}]]
end
box.out(
[[<tr class="emptylist">]],
[[<td colspan="8">]]
)
box.html(txt_empty)
box.out([[</td></tr>]])
end
end
local function get_book_btn()
local txt = [[{?3310:476?}]]
return [[
<button type="button" class="icon" name="book" title="]]
.. box.tohtml(txt)
.. [[" onclick="onBook(this);return false;">]]
.. [[<img src="/css/default/images/fonbuch.gif">]]
.. [[</button>
]]
end
local function get_download_btn(which)
local data = {
fax = {
txt = [[{?3310:677?}]],
img = [[/css/default/images/icon_view_fax.gif]],
style = [[]],
onclick = [[ onclick="onDownload(this);" ]]
},
tam = {
txt = [[{?3310:120?}]],
img = [[/css/default/images/icon_tamplay.png]],
style = [[]],
onclick = [[ onclick="return onPlayOrDownload(this);" ]]
},
empty = {
txt = [[]],
img = [[]],
style = [[ style="visibility:hidden;" ]],
onclick = [[]]
}
}
return [[
<button type="button" class="icon"]] .. data[which].style .. [[ name="]] .. which .. [[" title="]]
.. box.tohtml(data[which].txt)
.. [[" ]] .. data[which].onclick .. [[ >]]
.. [[<img src="]] .. data[which].img .. [[">]]
.. [[</button>
]]
end
local filetype = {fax = "myfaxfile", tam = "myabfile"}
local function get_download_link(which, path)
return href.get([[/lua/photo.lua]], http.url_param(filetype[which], path))
end
function write_calls()
local show_dial = show_clicktodial()
local book_btn = get_book_btn()
local download_btn = {
fax = get_download_btn('fax'),
tam = get_download_btn('tam'),
empty = get_download_btn('empty')
}
local ctype, symbol, class, txt, tooltip, filetype, filepath, clicktodial
local photo_url, vcard_url
for i, call in ipairs(g_calls) do
ctype = foncalls.calltype(call)
symbol = foncalls.get_callsymbol(ctype)
class = "showif_" .. ctype
box.out("\n", [[<tr class="]], class, [[">]])
box.out("\n", [[<td class="]], symbol.class, [[" title="]])
box.html(symbol.txt)
box.out([["></td>]])
box.out("\n", [[<td>]])
box.html(call.date)
box.out([[</td>]])
txt, tooltip = foncalls.number_display(call)
clicktodial = show_dial and call.number and call.number ~= ""
box.out("\n", [[<td]])
if tooltip then
box.out([[ title="]])
box.html(tooltip)
box.out([["]])
end
box.out([[>]])
if clicktodial then
box.out([[<a href=" " onclick="return onDial(']],
box.tohtml(call.number),
[[');">]]
)
elseif photo_url then
box.out([[<a href="]],
box.tohtml(photo_url),
[[" target="_blank">]]
)
end
box.html(txt)
if clicktodial or photo_url then
box.out([[</a>]])
end
box.out([[</td>]])
box.out("\n", [[<td>]])
box.html(foncalls.port_display(call))
box.out([[</td>]])
txt, tooltip = foncalls.msn_display(call)
box.out("\n", [[<td]])
if tooltip then
box.out([[ title="]])
box.html(tooltip)
box.out([["]])
end
box.out([[>]])
box.html(txt)
box.out([[</td>]])
box.out("\n", [[<td>]])
box.html(call.duration)
box.out([[</td>]])
local btn_exist = false
filetype, filepath = foncalls.get_path(call)
box.out("\n", [[<td>]])
if filetype then
box.out([[
<a href="]], get_download_link(filetype, filepath), [[">]],
download_btn[filetype],
[[</a>]]
)
btn_exist = true
elseif vcard_url then
box.out([[<a href="]], vcard_url, [[" target="_blank">]], download_btn.vcard, [[</a>]])
btn_exist = true
end
box.out([[</td>]])
box.out("\n", [[<td>]])
if foncalls.addable_to_fonbook(call) then
box.out([[<a href="]], get_fonbook_link(call), [[">]], book_btn, [[</a>]])
btn_exist = true
end
if not btn_exist then
box.out(download_btn.empty)
end
box.out([[</td>]])
box.out([[</tr>]])
end
end
function write_dial_fondevice_js()
local port = box.query("telcfg:settings/DialPort")
require"fon_devices"
box.js(fon_devices.GetFonDeviceName(port))
end
local col_css = {
[1] = {width = "20px"},
[2] = {width = "90px"},
[3] = {width = "170px"},
[4] = {width = "140px"},
[5] = {width = "127px"},
[6] = {width = "60px", align = "center"},
[7] = {width = "auto", align = "center"},
[8] = {width = "auto", align = "center"}
}
function write_cols_css()
for i, col in ipairs(col_css) do
box.out("\n", [[table#uiCallshead tr th:nth-child(]], i, [[),]])
box.out("\n", [[table#uiCalls tr td:nth-child(]], i, [[) {]])
box.out("\n", [[width: ]], col.width, [[;]])
if col.align then
box.out("\n", [[text-align: ]], col.align, [[;]])
end
box.out("\n", [[}]])
end
end
function write_cols_ieold()
box.out([[<!--[if lt IE 9]>]])
box.out("\n", [[<colgroup>]])
for i, col in ipairs(col_css) do
box.out([[<col width="]], col.width, [["]])
if col.align then
box.out([[ align="]], col.align, [["]])
end
box.out([[>]])
end
box.out([[</colgroup>]], "\n")
box.out([[<![endif]-->]])
end
function write_csv_btn()
box.out([[
<a href="]],
href.get(box.glob.script, http.url_param("csv", "")),
[[">]],
[[<button type="button" name="export" onclick="onDownload(this);">]],
box.tohtml([[{?3310:161?}]]),
[[</button>]],
[[</a>
]])
end
function write_csv()
local sep = ";"
box.header(
"HTTP/1.0 200 OK\n"
.. "Content-Type: text/csv; charset=utf-8\n"
.. "Content-Disposition: attachment; filename={?3310:402?}.csv\n\n"
)
box.out([[sep=]], sep, "\n")
local line = {
[[{?3310:986?}]],
[[{?3310:661?}]],
[[{?3310:740?}]],
[[{?txtRufnummer?}]],
[[{?3310:572?}]],
[[{?3310:258?}]],
[[{?3310:544?}]]
}
box.out(table.concat(line, sep), "\n")
local txt_inet = [[{?txtINet?}: ]]
for i, call in ipairs(g_calls) do
line = {
call.call_type or "",
call.date or "",
call.name or "",
call.number or "",
foncalls.port_display(call),
(call.msn_type == 2 and txt_inet or "") .. (call.msn or ""),
call.duration or ""
}
box.out(table.concat(line, sep), "\n")
end
box.end_page()
end
if box.get.csv then
g_calls = foncalls.get_all()
write_csv()
end
if box.get.dial or box.get.hangup then
local saveset = {}
if box.get.dial then
cmtable.add_var(saveset, "telcfg:command/Dial", box.get.dial)
else
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
end
local err, msg = box.set_config(saveset)
box.out(js.table({
err = err, errmsg = msg,
dialing = box.get.dial or false
}))
box.end_page()
end
if box.post.apply then
if box.post.usejournal then
foncalls.SetActive(1)
else
foncalls.ClearList()
foncalls.SetActive(0)
end
elseif box.post.clear then
foncalls.ClearList()
end
g_calls = foncalls.get_all()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
ul.tabs li.tabpic img {
float:left;
padding-right: 5px;
}
ul.tabs li.tabpic a {
padding-left: 10px;
}
table#uiCallshead {
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
table#uiCalls {
margin-top: 0;
margin-bottom: 0;
border-width: 0;
}
.in table#uiCalls tr.showif_out,
.in table#uiCalls tr.showif_fail,
.in table#uiCalls tr.showif_rejected,
.in table#uiCalls tr.showif_out_active,
.in table#uiCalls tr.showif_,
.fail table#uiCalls tr.showif_in,
.fail table#uiCalls tr.showif_out,
.fail table#uiCalls tr.showif_in_active,
.fail table#uiCalls tr.showif_out_active,
.fail table#uiCalls tr.showif_,
.out table#uiCalls tr.showif_in,
.out table#uiCalls tr.showif_fail,
.out table#uiCalls tr.showif_rejected,
.out table#uiCalls tr.showif_in_active,
.out table#uiCalls tr.showif_ {
display: none;
}
table#uiCallshead,
table#uiCalls {
table-layout: fixed;
}
<?lua write_cols_css() ?>
.noexpert .showif_expert {
display: none;
}
.sortable.extra div{
float:left;
margin:0px;
padding:0px;
text-align:center;
}
.sortable.extra span{
padding-top:15px;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/tamplay.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<!-- sortieren -->
<script type="text/javascript">
var sort=sorter();
function initTableSorter() {
sort.init("uiCallshead");
sort.addTbl(uiCalls);
sort.addPostFunc(adjustZebra);
//sort.sort_table(0);
adjustZebra();
}
ready.onReady(initTableSorter);
</script>
<script type="text/javascript">
ready.onReady(function(){initAudio("tam");});
function onDial(num) {
var dialFondevice = "<?lua write_dial_fondevice_js() ?>";
var url = encodeURI("<?lua box.js(box.glob.script) ?>") +
"?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
var json = makeJSONParser();
if (!num || !confirm("{?3310:670?}")) {
return false;
}
function cbDial(xhr) {
var answer = json(xhr.responseText || "null");
var txt = [
jxl.sprintf(
"{?3310:136?}",
num
),
jxl.sprintf(
"{?3310:800?}",
dialFondevice
),
"{?3310:259?}"
];
if (!confirm(txt.join("\n\n"))) {
ajaxGet(url + "&" + buildUrlParam("hangup", ""), cbHangup);
}
}
function cbHangup(xhr) {
alert("{?3310:684?}");
}
ajaxGet(url + "&" + buildUrlParam("dial", num), cbDial);
return false;
}
function onBook(btn) {
var a = btn && btn.parentNode;
if (a && a.href) {
location.href = a.href;
}
}
function onDownload(btn) {
var a = jxl.findParentByTagName(btn, "a");
if (a && a.click) {
a.click();
}
}
function onPlayOrDownload(btn) {
if (jxl.hasClass(btn, "audio")) {
return false;
}
onDownload(btn);
}
function getCurrTab() {
var form = document.forms.mainform;
var allTabs = ["all", "in", "out", "fail"];
for (var i = 0; i < 4; i++) {
if (jxl.hasClass(form, allTabs[i])) {
return allTabs[i];
}
}
return allTabs[0];
}
function adjustZebra(tab) {
tab = tab || getCurrTab();
var table = jxl.get("uiCalls");
var trs = table.rows;
var even = true;
for (var i = 0; i < trs.length; i++) {
if (tab == 'all' || jxl.hasClass(trs[i], "showif_" + tab)) {
even = !even;
jxl.removeClass(trs[i], even ? "zebraOdd" : "zebraEven");
jxl.addClass(trs[i], even ? "zebraEven" : "zebraOdd");
}
}
}
function initTabHandlers() {
var allTabs = ["all", "in", "out", "fail"];
var scrollDiv = jxl.get("uiScroll");
var form = document.forms.mainform;
var inp = form.elements.callstab
function onCallsTab(evt) {
var tabLink = jxl.evtTarget(evt);
var which = (tabLink.id || "").replace("uiTablink:", "");
if (which) {
jxl.removeClass(form, allTabs.join(" "));
jxl.addClass(form, which);
}
for (var i = 0; i < allTabs.length; i++) {
if (allTabs[i] == which) {
jxl.addClass("uiTab:" + allTabs[i], "active");
}
else {
jxl.removeClass("uiTab:" + allTabs[i], "active");
}
}
if (scrollDiv) {
scrollDiv.scrollTop = 0;
}
jxl.cancelEvent(evt);
if (inp) {
jxl.setValue(inp, which);
}
adjustZebra(which);
return false;
}
for (var i = 0; i < allTabs.length; i++) {
jxl.addEventHandler("uiTablink:" + allTabs[i], "click", onCallsTab);
}
}
ready.onReady(initTabHandlers);
function onClear(evt) {
if (!confirm("{?3310:990?}")) {
return jxl.cancelEvent(evt || window.event);
}
}
function onUse(evt) {
var txt = [
"{?3310:702?}",
"{?txtContinue?}"
];
var checkbox = jxl.evtTarget(evt)
if (!checkbox.checked && !confirm(txt.join("\n"))) {
return jxl.cancelEvent(evt);
}
}
ready.onReady(function(){
var elems = jxl.getFormElements("clear");
for (var i = 0; i < elems.length; i++) {
jxl.addEventHandler(elems[i], 'click', onClear);
}
elems = jxl.getFormElements("usejournal");
for (var i = 0; i < elems.length; i++) {
jxl.addEventHandler(elems[i], 'click', onUse);
}
});
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>" <?lua write_main_class() ?>>
<?lua href.default_submit('apply') ?>
<p>{?3310:575?}</p>
<div class="formular showif_expert">
<input type="checkbox" name="usejournal" id="uiUsejournal" <?lua write_use_checked() ?>>
<label for="uiUsejournal"><?lua write_use_label() ?></label>
</div>
<br>
<ul class="tabs">
<li id="uiTab:all" <?lua write_tab_classes('all') ?>>
<a id="uiTablink:all" href="<?lua href.write(box.glob.script,'callstab=all') ?>">
{?3310:858?}
</a>
</li>
<li id="uiTab:out" <?lua write_tab_classes('out') ?>>
<a id="uiTablink:out" href="<?lua href.write(box.glob.script,'callstab=out') ?>">
<?lua write_tab_img('out') ?>
{?3310:848?}
</a>
</li>
<li id="uiTab:in" <?lua write_tab_classes('in') ?>>
<a id="uiTablink:in" href="<?lua href.write(box.glob.script,'callstab=in') ?>">
<?lua write_tab_img('in') ?>
{?3310:949?}
</a>
</li>
<li id="uiTab:fail" <?lua write_tab_classes('fail') ?>>
<a id="uiTablink:fail" href="<?lua href.write(box.glob.script,'callstab=fail') ?>">
<?lua write_tab_img('fail') ?>
{?3310:765?}
</a>
</li>
</ul>
<div class="clear_float"></div>
<table id="uiCallshead" class="zebra">
<?lua write_cols_ieold() ?>
<tr class="thead">
<th class="sortable sort_by_class"></th>
<th class="sortable">{?3310:63?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3310:909?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3310:752?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?3310:918?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable extra"><div>{?3310:817?}<br>(hh:mm)</div><span class="sort_no">&nbsp;</span></th>
<th></th>
<th></th>
</tr>
</table>
<div id="uiScroll">
<table id="uiCalls" class="zebra_reverse">
<?lua
write_cols_ieold()
write_emptylist()
write_calls()
?>
</table>
</div>
<br>
<div class="btn_form">
<?lua write_csv_btn() ?>
<button type="submit" name="clear">{?3310:625?}</button>
<button type="submit" name="refresh">{?txtRefresh?}</button>
</div>
<div id="btn_form_foot">
<button class="showif_expert" type="submit" name="apply">{?txtApply?}</button>
<button class="showif_expert" type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="callstab" value="<?lua box.html(g_callstab) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
