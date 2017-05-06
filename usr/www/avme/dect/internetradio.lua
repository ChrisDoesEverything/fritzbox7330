<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_dect_internetradio.html"
dofile("../templates/global_lua.lua")
require("general")
require("bit")
require("cmtable")
require("ir_pc_rss_data")
g_ctlmgr = {}
function get_data()
g_ctlmgr.ir_data = ir_pc_rss_data.get_ir_data()
g_ctlmgr.ir_streams = general.listquery("configd:settings/WEBRADIO/list(Name,URL,Bitmap)")
end
get_data()
if box.post.savesort then
local ctlmgr_save = {}
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIOSort", box.post.sorted or "")
local err,msg = box.set_config(ctlmgr_save)
get_data()
end
if next(box.post) and not box.post.savesort and not box.post.cancelsort and not(box.post.delete) and not(box.post.edit) and box.post.ir_id and box.post.free_id~="-1" then
local id = tonumber(box.post.ir_id)
if g_ctlmgr.ir_data[id].url == "" then
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.free_id, 'newSrc=1', 'SrcType=ir'))
else
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIO"..box.post.free_id.."/Name", g_ctlmgr.ir_data[id].name)
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIO"..box.post.free_id.."/URL", g_ctlmgr.ir_data[id].url)
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIO"..box.post.free_id.."/Bitmap", g_ctlmgr.ir_data[id].bitmap)
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
http.redirect(href.get("/dect/source_edit.lua", 'back_to_page='..box.glob.script, 'SrcId='..box.post.edit, 'newSrc=0', 'SrcType=ir'))
end
if next(box.post) and box.post.delete and box.post.delete~="" then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIO"..box.post.delete.."/Name", "")
cmtable.add_var(ctlmgr_save, "configd:settings/WEBRADIO"..box.post.delete.."/URL", "")
box.query("telcfg:settings/Foncontrol")
fcuser = general.listquery("telcfg:settings/Foncontrol/User/list(RadioRingID,AlarmRingTone)")
for idx, user in ipairs(fcuser) do
if user.AlarmRingTone=="33" and user.RadioRingID==box.post.delete then
local userid = idx - 1
local irfound = false
local firstirid = 0
for idx, ir in ipairs(g_ctlmgr.ir_streams) do
ir.id = idx - 1
if tonumber(box.post.delete) ~= tonumber(ir.id) and ir.Name~="" and ir.URL~="" then
irfound = true
firstirid = ir.id
break
end
end
if (irfound) then
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..userid.."/RadioRingID", firstirid)
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..userid.."/RadioRingID", "0")
cmtable.add_var(ctlmgr_save, "telcfg:settings/Foncontrol/User"..userid.."/AlarmRingTone", "0")
end
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr=[[<div class="LuaSaveVarError">]]..box.tohtml([[{?379:336?}.]])
if msg ~= nil and msg ~= "" then
criterr = criterr..[[<br>]]..box.tohtml([[{?379:125?}: ]])..box.tohtml(msg)
else
criterr = criterr..[[<br>]]..box.tohtml([[{?379:945?}: ]])..box.tohtml(err)
end
criterr = criterr..[[<br>]]..box.tohtml([[{?379:795?}]])..[[</div>]]
box.out(criterr)
else
get_data()
end
end
function get_buttons(ir)
local onclick = "showDeleteConfirm()"
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..ir.id, "edit", ir.id, [[{?txtIconBtnEdit?}]])..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..ir.id, "delete", ir.id, [[{?txtIconBtnDelete?}]], onclick)..[[</td>]]
end
g_akt_ir_cnt = 0
g_first_free_id = -1
for idx, ir in ipairs(g_ctlmgr.ir_streams) do
if ir.Name~="" and ir.URL~="" then
g_akt_ir_cnt = g_akt_ir_cnt + 1
end
end
function show_ir_streams()
local str = ""
if g_akt_ir_cnt == 0 then
str = [[<tr><td colspan="4" class="txt_center">]]..box.tohtml([[{?379:108?}]])..[[</td></tr>]]
g_first_free_id = 0
else
for idx, ir in ipairs(g_ctlmgr.ir_streams) do
ir.id = idx - 1
if ir.Name~="" and ir.URL~="" then
str = str .. [[<tr id="uiSort_]] .. ir.id .. [[">]]
str = str..[[<td>]]..box.tohtml(ir.Name)..[[</td>]]
str = str..[[<td>]]..box.tohtml(ir.URL)..[[</td>]]
str = str..get_buttons(ir)..[[</tr>]]
elseif ir.Name=="" and ir.URL=="" and g_first_free_id == -1 then
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
tableId: "email_accounts",
sortedId: "uiSorted",
listLength: "<?lua box.js(box.query('configd:settings/WEBRADIO/count')) ?>",
hideOnStart: "uiStartsort",
showOnStart: "uiCancelsort,uiSavesort",
disableOnStart: "uiSelectStream"
});
function showDeleteConfirm()
{
return confirm("{?379:282?}");
}
function onChangeStream(value)
{
if (value!="")
{
jxl.setValue("uiIrId", value);
jxl.get("main_form_ir").submit();
}
}
</script>
<?include "templates/page_head.html" ?>
<form id="main_form_ir" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<p>
{?379:860?}
</p>
<hr>
<h4>{?379:991?}</h4>
<?lua
if config.MEDIASRV and box.query("mediasrv:settings/enabled") ~= "1" then
box.out([[
<span class="hintMsg">{?txtHinweis?}</span>
<p>
]]..general.sprintf(
[[{?379:992?}]],
[[<a href=']]..href.get("/storage/media_settings.lua")..[['>]], [[</a>]]
)..[[
</p>]])
end
?>
<div class="formular">
<table id="email_accounts" class="zebra">
<tr>
<th>{?379:234?}</th>
<th>{?379:897?}</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(show_ir_streams()) ?>
</table>
<p class="innerbutton" <?lua if g_akt_ir_cnt < 2 then box.out([[style="display:none;"]]) end ?>>
<button id="uiStartsort" type="button" name="startsort" onclick="gSorter.start();">
{?379:723?}
</button>
<button id="uiCancelsort" type="submit" name="cancelsort" onclick="gSorter.cancel();" style="display:none;">
{?379:122?}
</button>
<button id="uiSavesort" type="submit" name="savesort" onclick="return gSorter.save();" style="display:none;">
{?379:237?}
</button>
<input type="hidden" name="sorted" value="" id="uiSorted">
</p>
</div>
<hr>
<h4>{?379:533?}</h4>
<p>
{?379:341?}
</p>
<div class="formular" id="uiSelectStream">
<label for="uiViewIrStream">
{?379:639?}
</label>
<select id="uiViewIrStream" onchange="onChangeStream(value)" <?lua if g_first_free_id < 0 then box.out([[disabled]]) end ?>>
<option value="" selected>{?379:936?}</option>
<?lua
local double = false
for id,val in ipairs(g_ctlmgr.ir_data) do
double = false
for idx, ir in ipairs(g_ctlmgr.ir_streams) do
if val.name == ir.Name or val.url == ir.URL then
double = true
end
end
if not(double) or val.url == "" then
box.out([[<option value="]]..id..[[">]])
box.html(val.name)
box.out([[</option>]])
end
end
?>
</select>
</div>
<input type="hidden" name="free_id" value="<?lua box.html(g_first_free_id)?>" />
<input type="hidden" id="uiIrId" name="ir_id" value="" />
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
