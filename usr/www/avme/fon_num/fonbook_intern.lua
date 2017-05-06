<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_fon_interne_nummern.html"
dofile("../templates/global_lua.lua")
if g_print_mode then
g_tab_options.notabs = true
end
require"html"
require"fon_book"
local intern_type = array.truth{"intern", "memo"}
local add_name = {intern = "", memo = [[ (memo)]]}
local function read_numbers()
local pb = fon_book.read_fonbook(1, 0, "name")
local result = {}
for i, entry in ipairs(pb) do
if entry.name then
for k, num in ipairs(entry.numbers or {}) do
local t = num.type or ""
if num.number and intern_type[t] then
table.insert(result, {
name = entry.name .. add_name[t],
number = num.number
})
end
end
end
end
return result
end
function write_trs()
local nums = read_numbers()
for i, num in ipairs(nums) do
local number = num.number or ""
if number:find("%*%*") ~= 1 then
number = [[**]] .. number
end
html.tr{
html.td{num.name or ""},
html.td{number}
}.write()
end
if #nums == 0 then
html.tr{class="emptylist",
html.td{colspan=2,
[[{?5839:490?}]]
}
}.write()
end
end
function write_explain()
if not g_print_mode then
html.p{
[[{?5839:46?}]]
}.write()
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function onPrintView() {
var url = "<?lua href.write(box.glob.script,'stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=720,height=600,statusbar,resizable=yes,scrollbars=yes");
if (ppWindow) {
ppWindow.focus();
}
}
function initTableSorter() {
sort.init("uiInternalNums");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua write_explain() ?>
<table id="uiInternalNums" class="zebra">
<tr class="thead">
<th class="sortable">{?5839:468?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?5839:196?}<span class="sort_no">&nbsp;</span></th>
</tr>
<?lua write_trs() ?>
</table>
<div id="btn_form_foot">
<button type="submit" name="refresh">{?txtRefresh?}</button>
<button type="button" name="print" onclick="onPrintView()">{?5839:180?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
