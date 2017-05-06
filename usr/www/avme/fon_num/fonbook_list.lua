<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_telefonbuch.html"
dofile("../templates/global_lua.lua")
require("http")
require("general")
require("fon_book")
require("html")
if box.get.dial or box.get.hangup then
require("cmtable")
require("js")
local saveset = {}
if box.get.dial then
cmtable.add_var(saveset, "telcfg:command/Dial", box.get.dial)
else
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
end
local err, msg = box.set_config(saveset)
box.out(js.table({
dialing = box.get.dial or false
}))
box.end_page()
end
if g_print_mode then
g_page_title = [[{?3041:964?}: ]]..box.tohtml(fon_book.get_akt_fonbook().name)
g_tab_options.notabs = true
end
if next(box.post) then
if box.post.edit_entry and box.post.edit_entry~="" then
http.redirect(href.get('/fon_num/fonbook_entry.lua','uid='..box.post.edit_entry,'back_to_page='..box.glob.script))
elseif box.post.new_entry then
http.redirect(href.get('/fon_num/fonbook_entry.lua','uid=new','back_to_page='..box.glob.script))
elseif box.post.delete_entry and box.post.delete_entry~="" then
local err = fon_book.delete_entry(box.post.delete_entry)
if err ~= 0 then
local criterr = general.create_error_div(err,"")
box.out(criterr)
end
elseif box.post.select_fonbook and tonumber(box.post.select_fonbook) then
fon_book.set_akt_fonbook(tonumber(box.post.select_fonbook))
elseif box.post.sync_fonbook and box.post.sync_fonbook~="" then
require ("cmtable")
local saveset={}
cmtable.add_var(saveset,"ontel:command/do_sync", "1")
local err, msg = box.set_config(saveset)
http.redirect(href.get('/fon_num/fonbook_onlinetest.lua','uid='..box.post.sync_fonbook,'back_to_page='..box.glob.script))
elseif box.post.edit_fonbook and box.post.edit_fonbook~="" then
http.redirect(href.get('/fon_num/fonbook_edit.lua','uid='..box.post.edit_fonbook,'back_to_page='..box.glob.script))
elseif box.post.delete_fonbook and tonumber(box.post.delete_fonbook) then
local msg=""
local err=fon_book.delete_fonbook(tonumber(box.post.delete_fonbook))
if (fon_book.is_online(box.post.delete_fonbook)) then
require ("cmtable")
local saveset={}
local online_pb=fon_book.read_online_book()
local elem, idx=fon_book.find_item(online_pb,"id",box.post.delete_fonbook)
cmtable.add_var(saveset,"ontel:command/ontel"..tostring(idx-1) ,"delete")
err, msg = box.set_config(saveset)
end
fon_book.set_akt_fonbook(0)
elseif box.post.fonbook_restore then
http.redirect(href.get('/fon_num/fonbook_restore.lua', 'uid='..box.post.fonbook_restore, 'back_to_page='..box.glob.script))
elseif box.post.googleoauth2 then
local saveset = {}
local webvar = string.format([[ontel:settings/%s/]], box.post.googleoauth2)
cmtable.add_var(saveset, webvar .. "enabled", "0")
cmtable.add_var(saveset, webvar .. "username", "")
cmtable.add_var(saveset, webvar .. "password", "")
local err, msg = box.set_config(saveset)
saveset = {}
cmtable.add_var(saveset, webvar .. "enabled", "1")
err, msg = box.set_config(saveset)
if err == 0 then
http.redirect(href.get("/fon_num/fonbook_google_oauth2.lua",
http.url_param("ontelnode", box.post.googleoauth2),
http.url_param("back_to_page", box.glob.script)
))
end
end
end
g_selected_fonbook = {
id = fon_book.get_book_id(),
name = fon_book.bookname(),
type = fon_book.booktype(),
provider = fon_book.bookprovider()
}
function write_buttons(entry)
if entry == "book_ed" then
local onclick = [[bookDelConfirmation(']]..box.tohtml(box.tojs(g_selected_fonbook.name))..[[', ']]..box.tojs(fon_book.booktype(g_selected_fonbook.id))..[[')]]
local btn_disabled = g_selected_fonbook.type == 'standard'
box.out([[ <span class="btn_align">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_fonbook", "edit_fonbook", g_selected_fonbook.id, [[{?txtIconBtnEdit?}]], "", btn_disabled)
..[[</span> <span class="btn_align">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_fonbook", "delete_fonbook", g_selected_fonbook.id, [[{?txtIconBtnDelete?}]], onclick, btn_disabled)..[[</span>]])
elseif entry == "book_sync" then
box.out([[ <span class="btn_align">]]..general.get_icon_button("/css/default/images/aktualisieren.gif", "sync_fonbook", "sync_fonbook", g_selected_fonbook.id, [[{?3041:521?}]], "", false)..[[</span>]])
else
local btn_disabled_del = not(g_selected_fonbook.type ~= 'online' or (g_selected_fonbook.provider=="google" or g_selected_fonbook.provider=="kdg"))
local onclick = [[entryDelConfirmation(']]..box.tohtml(entry.name or "")..[[')]]
if (btn_disabled_del) then
box.out([[<td class="buttonrow"></td><td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..entry.uid, "edit_entry", entry.uid, [[{?txtIconBtnEdit?}]], "", false)..[[</td>]])
else
box.out([[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..entry.uid, "edit_entry", entry.uid, [[{?txtIconBtnEdit?}]], "", false)..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..entry.uid, "delete_entry", entry.uid, [[{?txtIconBtnDelete?}]], onclick, false)..[[</td>]])
end
end
end
local function show_clicktodial()
local right_to_dial = tonumber(box.query("rights:status/Dial",0)) > 0
local use_dial= box.query("telcfg:settings/UseClickToDial") == "1"
return use_dial and right_to_dial
end
g_clicktodial = show_clicktodial()
function write_fonbook_table()
local entries = fon_book.read_fonbook(0,0,"name")
if #entries > 0 then
for idx, entry in ipairs(entries) do
box.out([[<tr>]])
if entry.image and #entry.image > 0 then
box.out([[<td class="iconrow telbook_pic_icon"></td>]])
else
box.out([[<td class="iconrow"></td>]])
end
box.out([[<td class="tname" title="]]..box.tohtml(entry.name)..[[">]]..box.tohtml(entry.name)..[[</td>]])
box.out([[<td class="tnum">]])
for i, num in ipairs(entry.numbers or {}) do
if i > 1 then box.out("<br>") end
if g_clicktodial and num.number and num.number ~= "" then
box.out([[<a href=" " onclick="return onDial(']]..box.tohtml(num.number)..[[');" >]]..box.tohtml(num.number)..[[</a>]])
else
box.html(num.number)
end
end
box.out([[</td>]])
box.out([[<td class="ttype">]])
for i, num in ipairs(entry.numbers or {}) do
if i > 1 then box.out("<br>") end
box.html(fon_book.type_shortdisplay(num.type))
end
box.out([[</td>]])
box.out([[<td class="tcode">]])
for i, num in ipairs(entry.numbers or {}) do
local code = ""
if num.code then code = "**"..(700+num.code) end
if i > 1 then box.out("<br>") end
box.html(code)
end
box.out([[</td>]])
box.out([[<td class="tvanity">]])
for i, num in ipairs(entry.numbers or {}) do
local vanity = ""
if num.vanity and num.vanity~="" then vanity = "**8"..num.vanity end
if i > 1 then box.out("<br>") end
box.html(vanity)
end
box.out([[</td>]])
local impo = ""
if entry.category == 1 then impo = [[<img src="/css/default/images/ok.gif" alt="" width="13px" height="10px" />]] end
box.out([[<td class="timp">]]..impo..[[</td>]])
if not g_print_mode then
box.out([[<td class="fillup"></td>]])
write_buttons(entry)
end
box.out([[</tr>]])
end
box.out([[<tr id="no_search_result" class="zebraOdd" style="display: none;"><td colspan="10" class="txt_center">]]..box.tohtml([[{?3041:295?}]])..[[</td></tr>]])
else
local tmp_txt = box.tohtml([[{?3041:337?}]])
box.out([[<tr><td colspan="10" class="txt_center">]])
if fon_book.booktype(g_selected_fonbook.id) == "online" then
tmp_book = fon_book.find_book_by_id(fon_book.read_online_book(), g_selected_fonbook.id)
if tmp_book and (tmp_book.status == "-1" or tmp_book.status == "2") then
box.html([[{?3041:901?}]])
elseif not tmp_book or (tmp_book and tmp_book.status == "0") then
box.out(tmp_txt)
else
box.html([[{?3041:784?}]])
end
else
box.out(tmp_txt)
end
box.out([[</td></tr>]])
end
end
function write_book_name()
box.out([[<span class="btn_align">]])
box.html([[{?3041:294?}: ]])
box.out([[<strong>]])
box.html(g_selected_fonbook.name or "")
box.out([[</strong>]])
box.out([[</span>]])
end
function write_book_links()
if config.DECT2 then
box.out([[<a class="textlink link_align" href="]])
href.write("/fon_num/fonbook_edit.lua",
http.url_param("uid", "new"), http.url_param("back_to_page", box.glob.script)
)
box.out([[">]])
box.html([[{?3041:991?}]])
box.out([[</a>]])
if #fon_book.get_book_list() > 1 then
box.out([[<a class="textlink link_align" href="]])
href.write("/fon_num/fonbook_select.lua")
box.out([[">]])
box.html([[{?3041:135?}]])
box.out([[</a>]])
end
end
end
function write_dial_fondevice_js()
local port = box.query("telcfg:settings/DialPort")
require"fon_devices"
box.js(fon_devices.GetFonDeviceName(port))
end
function write_google_oauth2_migration()
if g_selected_fonbook.provider == "google" then
local book = fon_book.find_book_by_id(fon_book.get_fonbooks(), g_selected_fonbook.id)
local oauth2_needed
if book.rtok == "" then
if book.username ~= "" and book.password ~= "" then
oauth2_needed = "new"
elseif book.usercode ~= "" then
oauth2_needed = "again"
end
if oauth2_needed then
html.hr{}.write()
html.h4{
[[{?3041:393?}]]
}.write()
if oauth2_needed == "new" then
html.p{
[[{?3041:210?}]]
}.write()
else
html.p{
[[{?3041:7749?}]]
}.write()
end
html.div{class="btn_form",
html.button{type="submit", name="googleoauth2", value=book._node,
[[{?3041:81?}]]
}
}.write()
end
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.btn_align {
display: inline-block;
vertical-align: middle;
}
.btn_align strong {
margin-right: 6px;
}
.link_align {
float:right;
margin-left: 23px;
margin-right: 2px;
}
#uiTableHead {
table-layout:fixed;
margin-bottom: 0;
border-width: 1px 1px 0 1px;
}
#uiScroll {
<?lua
if g_print_mode then
box.out([[height: auto;]])
else
box.out([[max-height: 400px;]])
end
?>
overflow-y: auto;
overflow-x: hidden;
border: solid #c6c7be;
border-width: 0 1px 1px 1px;
background-color: #ffffff;
margin-bottom: 15px;
}
#uiInnerTable {
table-layout:fixed;
margin-top: 0;
margin-bottom: 0;
border-width: 0;
}
td {
vertical-align: top;
}
.tname,
.tnum {
overflow:hidden;
width: 130px;
}
.ttype,
.tcode,
.timp {
width: 65px;
}
.tvanity {
width: 100px;
}
.timp {
text-align: center;
}
table.zebra th.fillup,
table.zebra_reverse td.fillup {
padding: 0;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div <?lua if g_print_mode then box.out("style=display:none;") end ?>>
<?lua
write_book_name()
if g_selected_fonbook.type ~= 'standard' then
write_buttons("book_ed")
end
if g_selected_fonbook.type == 'online' then
write_buttons("book_sync")
end
write_book_links()
?>
</div>
<div style="clear:both;"></div>
<?lua write_google_oauth2_migration() ?>
<hr>
<?lua
if not g_print_mode then
g_search_word = ""
if box.post.search_word then g_search_word = box.post.search_word end
box.out([[<div>]]
..box.tohtml([[{?3041:330?}]])
..[[<input type="text" onkeyup="onChangeSearchWord();" id="search_word" name="search_word" value="]]..box.tohtml(g_search_word)..[[">]]
..[[<span class="btn_align"><button type="button" class="icon" name="delete_search" id="delete_search" onclick="delSearchWord();" title="]]..box.tohtml([[{?3041:840?}]])..[["><img src="/css/default/images/loeschen.gif" alt=""></button></span>]]
..[[<button style="float: right;" type="submit" name="new_entry" id="new_entry">]]..box.tohtml([[{?3041:847?}]])..[[</button>
</div>]])
end
?>
<div>
<table id="uiTableHead" class="zebra">
<tr class="thead">
<?lua
local str_class=[[]]
local str_span=[[]]
if not g_print_mode then
str_class=[[sortable]]
str_span=[[<span class="sort_no">&nbsp;</span>]]
end
box.out([[<th class="iconrow"></th>]])
box.out([[<th class="]]) box.out(str_class) box.out([[ tname">{?3041:650?}]]) box.out(str_span) box.out([[</th>]])
box.out([[<th class="]]) box.out(str_class) box.out([[ tnum">{?3041:189?}]]) box.out(str_span) box.out([[</th>]])
box.out([[<th class="ttype"></th>]])
box.out([[<th class="]]) box.out(str_class) box.out([[ tcode">{?3041:779?}]]) box.out(str_span) box.out([[</th>]])
box.out([[<th class="]]) box.out(str_class) box.out([[ tvanity">{?3041:1?}]]) box.out(str_span) box.out([[</th>]])
box.out([[<th class="]]) box.out(str_class) box.out([[ timp">{?3041:387?}]]) box.out(str_span) box.out([[</th>]])
if not g_print_mode then
box.out([[<th class="fillup"></th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>]])
end
?>
</tr>
</table>
<div id="uiScroll">
<table id="uiInnerTable" class="zebra_reverse">
<?lua write_fonbook_table() ?>
</table>
</div>
</div>
<?lua
if not g_print_mode then
box.out([[<div id="btn_form_foot">
<input type="hidden" id="select_fonbook" name="select_fonbook" value="" disabled>]])
if (g_selected_fonbook.type ~= 'online') then
box.out([[<button type="button" onclick="saveFonbookLokal()">]]..box.tohtml([[{?3041:508?}]])..[[</button>
<button type="submit" name="fonbook_restore" value="]]..box.tohtml(g_selected_fonbook.id)..[[">]]..box.tohtml([[{?3041:734?}]])..[[</button>]])
end
box.out([[<button type="button" name="print" onclick="showPrintView()">]]..box.tohtml([[{?3041:914?}]])..[[</button>
</div>]])
end
?>
</form>
<?lua
if not g_print_mode then
box.out([[<form method="POST" action="../cgi-bin/firmwarecfg" enctype="multipart/form-data" id="export_form" name="uiPostExportForm" onsubmit="return false">
<input type="hidden" id="sid_export" name="sid" value="]]..box.tohtml(box.glob.sid)..[[" disabled>
<input type="hidden" id="select_fonbook_id" name="PhonebookId" value="]]..box.tohtml(g_selected_fonbook.id)..[[" disabled>
<input type="hidden" id="select_fonbook_name" name="PhonebookExportName" value="]]..box.tohtml(g_selected_fonbook.name)..[[" disabled>
<input type="hidden" id="select_fonbook_export" name="PhonebookExport" value="" disabled>
</form>]])
end
?>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/zebra.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onDial(num)
{
var dialFondevice = "<?lua write_dial_fondevice_js() ?>";
var url = encodeURI("<?lua box.js(box.glob.script) ?>") +
"?" + buildUrlParam("sid", "<?lua box.js(box.glob.sid) ?>");
var json = makeJSONParser();
if (!num || !confirm("{?3041:574?}")) {
return false;
}
function cbDial(xhr) {
var answer = json(xhr.responseText || "null");
var txt = [
jxl.sprintf(
"{?3041:777?}",
num
),
jxl.sprintf(
"{?3041:613?}",
dialFondevice
),
"{?3041:740?}"
];
if (!confirm(txt.join("\n\n"))) {
ajaxGet(url + "&" + buildUrlParam("hangup", ""), cbHangup);
}
}
function cbHangup(xhr) {
alert("{?3041:384?}");
}
ajaxGet(url + "&" + buildUrlParam("dial", num), cbDial);
return false;
}
function onChangeFonbook(id)
{
var akt_fonbook = "<?lua box.js(g_selected_fonbook.id) ?>";
if (akt_fonbook == id) return;
jxl.enable("select_fonbook");
jxl.setValue("select_fonbook", id);
jxl.submitForm("main_form");
}
function bookDelConfirmation(name, b_type)
{
var confirm_txt = ""
if (b_type == "online")
confirm_txt = jxl.sprintf("{?3041:795?}", name);
else
confirm_txt = jxl.sprintf("{?3041:314?}", name);
return confirm(confirm_txt);
}
function entryDelConfirmation(name)
{
return confirm('{?3041:997?} "'+name+'" {?3041:217?}');
}
function saveFonbookLokal()
{
jxl.enable("sid_export");
jxl.enable("select_fonbook_id");
jxl.enable("select_fonbook_name");
jxl.enable("select_fonbook_export");
jxl.submitForm("export_form");
}
function showPrintView()
{
var url = "<?lua href.write( box.glob.script,'stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=815,height=600,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
function showRow(rowNameContent, rowNumbersContent, searchWord)
{
var tmpSearchWord = searchWord.replace(/[, -]/g, " ");
rowNameContent = rowNameContent.replace(/[, -]/g, " ");
var nameParts = rowNameContent.split(" ");
var searchParts = tmpSearchWord.split(" ");
var allSearchPartsFound = true
for (var j=0; j < searchParts.length; j++)
{
var partFound = false;
for (var i=0; i < nameParts.length; i++)
if (nameParts[i].toLowerCase().indexOf(searchParts[j])==0)
{
partFound = true;
break;
}
if (!partFound)
{
allSearchPartsFound = false;
break;
}
}
if (allSearchPartsFound) return true;
var numbers = rowNumbersContent.split("<br>");
for (var i=0; i < numbers.length; i++)
{
var org_num = numbers[i];
var just_num = (numbers[i].replace(/[\+]/, "00")).replace(/[\D]/g, "");
var justNumbersSearchWord = (searchWord.replace(/[\+]/, "00")).replace(/[\D]/g, "");
if (org_num.indexOf(searchWord)>=0 || just_num.indexOf(searchWord)>=0 || (justNumbersSearchWord.length>0 && just_num.indexOf(justNumbersSearchWord)>=0))
{
return true;
}
}
return false;
}
function onChangeSearchWord()
{
var tab = jxl.get("uiInnerTable");
var tbody = tab.tBodies[0];
var rows = tbody.rows;
var searchWord = jxl.getValue("search_word").toLowerCase();
var odd = true;
var no_result = searchWord != "";
for (var r=0; r < rows.length; r++)
{
if (rows[r].cells.length == 10)
{
if (searchWord == "" || showRow(rows[r].cells[1].innerHTML, rows[r].cells[2].innerHTML, searchWord))
{
rows[r].style.display = "";
if (!((rows[r].className == "zebraEven" && !odd) || (rows[r].className == "zebraOdd" && odd)))
rows[r].className = (odd) ? "zebraOdd" : "zebraEven";
odd = !odd;
no_result = false;
}
else
rows[r].style.display = "none";
}
}
jxl.display("no_search_result", no_result);
}
function delSearchWord()
{
jxl.setValue("search_word", "");
onChangeSearchWord();
jxl.focus("search_word");
return false;
}
function init()
{
onChangeSearchWord();
jxl.focus("search_word");
}
function initTableSorter() {
sort.init("uiTableHead");
sort.addTbl(uiInnerTable);
sort.addPostFunc(onChangeSearchWord);
//sort.sort_table(0);
}
<?lua
if not g_print_mode then
box.out([[ready.onReady(initTableSorter);]])
box.out([[ready.onReady(init);]])
end
?>
</script>
<?include "templates/html_end.html" ?>
