<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_dect_podcast.html"
dofile("../templates/global_lua.lua")
require("general")
require("bit")
require("cmtable")
require("ir_pc_rss_data")
g_ctlmgr = {}
function get_data()
g_ctlmgr.pc_data = ir_pc_rss_data.get_pc_data()
g_ctlmgr.pc_accounts = general.listquery("configd:settings/PODCAST/list(Name,URL,Bitmap)")
end
get_data()
if box.post.savesort then
local ctlmgr_save = {}
cmtable.add_var(ctlmgr_save, "configd:settings/PODCASTSort", box.post.sorted or "")
local err,msg = box.set_config(ctlmgr_save)
get_data()
end
if next(box.post) and not box.post.savesort and not box.post.cancelsort and not(box.post.delete) and not(box.post.edit) and box.post.pc_id and box.post.free_id~="-1" then
local id = tonumber(box.post.pc_id)
if g_ctlmgr.pc_data[id].url == "" then
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.free_id, 'newSrc=1', 'SrcType=pc'))
else
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.free_id.."/Name", g_ctlmgr.pc_data[id].name)
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.free_id.."/URL", g_ctlmgr.pc_data[id].url)
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.free_id.."/Bitmap", g_ctlmgr.pc_data[id].bitmap)
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.free_id.."/PollInterval", g_ctlmgr.pc_data[id].poll)
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.free_id.."/MWI", "1")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg)
box.out(criterr)
else
get_data()
end
end
end
if next(box.post) and box.post.edit and box.post.edit~="" then
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.edit, 'newSrc=0', 'SrcType=pc'))
end
if next(box.post) and box.post.delete and box.post.delete~="" then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.delete.."/Name", "")
cmtable.add_var(ctlmgr_save, "configd:settings/PODCAST"..box.post.delete.."/URL", "")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=[[<div class="LuaSaveVarError">]]..box.tohtml([[{?9556:772?}.]])
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>]]..box.tohtml([[{?9556:266?}: ]])..box.tohtml(msg)
else
criterr = criterr..[[<br>]]..box.tohtml([[{?9556:11?}: ]])..box.tohtml(err)
end
criterr = criterr..[[<br>]]..box.tohtml([[{?9556:628?}]])..[[</div>]]
box.out(criterr)
else
get_data()
end
end
function get_buttons(pc)
local onclick = "showDeleteConfirm()"
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..pc.id, "edit", pc.id, [[{?txtIconBtnEdit?}]])..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..pc.id, "delete", pc.id, [[{?txtIconBtnDelete?}]], onclick)..[[</td>]]
end
g_akt_pc_cnt = 0
g_first_free_id = -1
for idx, pc in ipairs(g_ctlmgr.pc_accounts) do
if pc.Name~="" and pc.URL~="" then
g_akt_pc_cnt = g_akt_pc_cnt + 1
end
end
function show_pc_accounts()
local str = ""
if g_akt_pc_cnt == 0 then
str = [[<tr><td colspan="4" class="txt_center">]]..box.tohtml([[{?9556:843?}]])..[[</td></tr>]]
g_first_free_id = 0
else
for idx, pc in ipairs(g_ctlmgr.pc_accounts) do
pc.id = idx - 1
if pc.Name~="" and pc.URL~="" then
str = str .. [[<tr id="uiSort_]] .. pc.id .. [[">]]
str = str..[[<td>]]..box.tohtml(pc.Name)..[[</td>]]
str = str..[[<td>]]..box.tohtml(pc.URL)..[[</td>]]
str = str..get_buttons(pc)..[[</tr>]]
elseif pc.Name=="" and pc.URL=="" and g_first_free_id == -1 then
g_first_free_id = idx - 1
end
end
end
return str
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/tablesort.css">
<script type="text/javascript" src="/js/tablesort.js?lang=<?lua box.out(config.language) ?>"></script>
<script type="text/javascript">
var gSorter = createSorter({
tableId: "pc_accounts",
sortedId: "uiSorted",
listLength: "<?lua box.js(box.query('configd:settings/PODCAST/count')) ?>",
hideOnStart: "uiStartsort",
showOnStart: "uiCancelsort,uiSavesort",
disableOnStart: "uiSelectPodcast",
beforeSave: function(){alert(
"{?9556:576?}"
);}
});
function showDeleteConfirm()
{
return confirm("{?9556:596?}");
}
function onChangeStream(value)
{
if (value!="")
{
jxl.setValue("uiPcId", value);
jxl.get("main_form_pc").submit();
}
}
</script>
<?include "templates/page_head.html" ?>
<form id="main_form_pc" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<p>
{?9556:611?}
</p>
<hr>
<h4>{?9556:31?}</h4>
<?lua
if config.MEDIASRV and box.query("mediasrv:settings/enabled") ~= "1" then
box.out([[
<span class="hintMsg">{?txtHinweis?}</span>
<p>
]]..general.sprintf(
[[{?9556:615?}]],
[[<a href=']]..href.get("/storage/media_settings.lua")..[['>]], [[</a>]]
)..[[
</p>]])
end
?>
<div class="formular">
<table id="pc_accounts" class="zebra">
<tr>
<th>{?9556:805?}</th>
<th>{?9556:892?}</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(show_pc_accounts()) ?>
</table>
<p class="innerbutton" <?lua if g_akt_pc_cnt < 2 then box.out([[style="display:none;"]]) end ?>>
<button id="uiStartsort" type="button" name="startsort" onclick="gSorter.start();">
{?9556:151?}
</button>
<button id="uiCancelsort" type="submit" name="cancelsort" onclick="gSorter.cancel();" style="display:none;">
{?9556:14?}
</button>
<button id="uiSavesort" type="submit" name="savesort" onclick="return gSorter.save();" style="display:none;">
{?9556:701?}
</button>
<input type="hidden" name="sorted" value="" id="uiSorted">
</p>
</div>
<hr>
<h4>{?9556:976?}</h4>
<p>
{?9556:970?}
</p>
<div class="formular" id="uiSelectPodcast">
<label for="uiViewPcStream">
{?9556:265?}
</label>
<select id="uiViewPcStream" onchange="onChangeStream(value)" <?lua if g_first_free_id < 0 then box.out([[disabled]]) end ?>>
<option value="" selected>{?9556:408?}</option>
<?lua
local double = false
for id,val in ipairs(g_ctlmgr.pc_data) do
double = false
for idx, pc in ipairs(g_ctlmgr.pc_accounts) do
if val.name == pc.Name or val.url == pc.URL then
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
<input type="hidden" id="uiPcId" name="pc_id" value="" />
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
