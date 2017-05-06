<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_dect_rss.html"
dofile("../templates/global_lua.lua")
require("general")
require("bit")
require("cmtable")
require("ir_pc_rss_data")
g_ctlmgr = {}
function get_data()
g_ctlmgr.rss_data = ir_pc_rss_data.get_rss_data()
g_ctlmgr.rss_feeds = general.listquery("configd:settings/RSS/list(Name,URL,Bitmap,EntryID)")
end
if next(box.post) then
local ctlmgr_save={}
if box.post.edit and box.post.edit~="" then
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.edit, 'newSrc=0', 'SrcType=rss'))
elseif box.post.delete and box.post.delete~="" then
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/Name", "")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/URL", "")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/Bitmap", "0")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/PollInterval", "0")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/MWI", "0")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.delete.."/EntryID", "")
cmtable.add_var(ctlmgr_save, "configd:command/RSS"..box.post.delete, "delete")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
elseif box.post.savesort then
cmtable.add_var(ctlmgr_save, "configd:settings/RSSSort", box.post.sorted or "")
local err,msg = box.set_config(ctlmgr_save)
elseif not box.post.savesort and not box.post.cancelsort and not box.post.delete and not box.post.edit and box.post.rss_id and box.post.rss_id~="" and box.post.free_id and box.post.free_id~="" then
get_data()
local id = tonumber(box.post.rss_id)
if g_ctlmgr.rss_data[id].url == "" then
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.free_id, 'RssId='..box.post.free_EntryID, 'newSrc=1', 'SrcType=rss'))
else
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/Name", g_ctlmgr.rss_data[id].name)
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/URL", g_ctlmgr.rss_data[id].url)
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/Bitmap", g_ctlmgr.rss_data[id].bitmap)
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/PollInterval", g_ctlmgr.rss_data[id].poll)
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/MWI", "1")
cmtable.add_var(ctlmgr_save, "configd:settings/RSS"..box.post.free_id.."/EntryID", box.post.free_EntryID)
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=[[<div class="LuaSaveVarError">]]..box.tohtml([[{?516:97?}.]])
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>]]..box.tohtml([[{?516:734?}: ]])..box.tohtml(msg)
else
criterr = criterr..[[<br>]]..box.tohtml([[{?516:975?}: ]])..box.tohtml(err)
end
criterr = criterr..[[<br>]]..box.tohtml([[{?516:414?}]])..[[</div>]]
box.out(criterr)
end
end
end
end
get_data()
function get_buttons(rss)
local onclick = "showDeleteConfirm()"
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..rss.id, "edit", rss.id, [[{?txtIconBtnEdit?}]])..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..rss.id, "delete", rss.id, [[{?txtIconBtnDelete?}]], onclick)..[[</td>]]
end
g_akt_rss_cnt = 0
for idx, rss in ipairs(g_ctlmgr.rss_feeds) do
if rss.Name~="" and rss.URL~="" then
g_akt_rss_cnt = g_akt_rss_cnt + 1
end
end
g_first_free_id = 0
g_first_free_EntryID = -1
function show_rss_feeds()
local str = ""
local EntryID_tab = {}
for idx, rss in ipairs(g_ctlmgr.rss_feeds) do
rss.id = idx - 1
if rss.Name~="" and rss.URL~="" then
str = str .. [[<tr id="uiSort_]] .. rss.id .. [[">]]
str = str..[[<td>]]..box.tohtml(rss.Name)..[[</td>]]
str = str..[[<td>]]..box.tohtml(rss.URL)..[[</td>]]
str = str..get_buttons(rss)..[[</tr>]]
EntryID_tab[idx] = rss.EntryID
end
end
if g_akt_rss_cnt == 0 then
str = [[<tr><td colspan="4" class="txt_center">]]..box.tohtml([[{?516:557?}]])..[[</td></tr>]]
g_first_free_id = 0
end
local tmp = 0
local found = true
while g_first_free_EntryID < 0 do
for i, id in pairs(EntryID_tab) do
if tostring(tmp) == id then found = false end
end
if found then
g_first_free_EntryID = tmp
else
tmp = tmp + 1
found = true
end
end
g_first_free_id = g_akt_rss_cnt
return str
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/tablesort.css">
<script type="text/javascript" src="/js/tablesort.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript">
var gSorter = createSorter({
tableId: "rss_feeds",
sortedId: "uiSorted",
listLength: "<?lua box.out(box.query('configd:settings/RSS/count')) ?>",
hideOnStart: "uiStartsort",
showOnStart: "uiCancelsort,uiSavesort",
disableOnStart: "uiSelectRss",
beforeSave: function(){alert(
"{?516:266?}"
);}
});
function showDeleteConfirm()
{
return confirm("{?516:109?}");
}
function onChangeStream(value)
{
if (value!="")
{
jxl.setValue("uiRssId", value);
jxl.get("main_form_rss").submit();
}
}
</script>
<?include "templates/page_head.html" ?>
<form id="main_form_rss" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<p>
{?516:584?}
</p>
<hr>
<h4>{?516:636?}</h4>
<div class="formular">
<table id="rss_feeds" class="zebra">
<tr>
<th>{?516:881?}</th>
<th>{?516:850?}</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(show_rss_feeds()) ?>
</table>
<p class="innerbutton" <?lua if g_akt_rss_cnt < 2 then box.out([[style="display:none;"]]) end ?>>
<button id="uiStartsort" type="button" name="startsort" onclick="gSorter.start();">
{?516:15?}
</button>
<button id="uiCancelsort" type="submit" name="cancelsort" onclick="gSorter.cancel();" style="display:none;">
{?516:18?}
</button>
<button id="uiSavesort" type="submit" name="savesort" onclick="return gSorter.save();" style="display:none;">
{?516:954?}
</button>
<input type="hidden" name="sorted" value="" id="uiSorted">
</p>
</div>
<hr>
<h4>{?516:376?}</h4>
<p>
{?516:928?}
</p>
<div class="formular" id="uiSelectRss">
<label for="uiViewRssStream">
{?516:999?}
</label>
<select id="uiViewRssStream" onchange="onChangeStream(value)">
<option value="" selected>{?516:509?}</option>
<?lua
local double = false
for id,val in ipairs(g_ctlmgr.rss_data) do
double = false
for idx, rss in ipairs(g_ctlmgr.rss_feeds) do
if val.name == rss.Name or val.url == rss.URL then
double = true
end
end
if not(double) or val.url == "" then
box.out([[<option value="]]..id..[[">]]..box.tohtml(val.name)..[[</option>]])
end
end
?>
</select>
</div>
<input type="hidden" name="free_id" value="<?lua box.html(g_first_free_id)?>" />
<input type="hidden" name="free_EntryID" value="<?lua box.html(g_first_free_EntryID)?>" />
<input type="hidden" id="uiRssId" name="rss_id" value="" />
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
