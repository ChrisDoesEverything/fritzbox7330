<?lua
g_page_type = "all"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("general")
require("bit")
require("ir_pc_rss_data")
require("http")
g_back_to_page = http.get_back_to_page( "/dect/internetradio.lua" )
g_ctlmgr = {}
if box.get.SrcId then
g_ctlmgr.newSrc = box.get.newSrc
g_ctlmgr.SrcId = box.get.SrcId
g_ctlmgr.SrcType = box.get.SrcType
if box.get.RssId then
g_ctlmgr.free_EntryID = box.get.RssId
end
end
if box.post.SrcId then
g_ctlmgr.newSrc = box.post.newSrc
g_ctlmgr.SrcId = box.post.SrcId
g_ctlmgr.SrcType = box.post.SrcType
if box.post.RssId then
g_ctlmgr.free_EntryID = box.post.RssId
end
end
if box.post.btn_cancel or not g_ctlmgr.SrcId or not g_ctlmgr.SrcType or not g_ctlmgr.newSrc then
http.redirect(href.get(g_back_to_page))
end
g_menu_active_page = g_back_to_page
g_val = {}
g_query = ""
if g_ctlmgr.SrcType == "ir" then
g_page_title = [[{?1523:185?}]]
g_query = "WEBRADIO"
g_val = {
prog = [[
not_empty(uiViewSrcName/src_name, srcname)
char_range_regex(uiViewSrcName/src_name, dectchar, srcname)
not_empty(uiViewSrcUrl/src_url, srcurl)
char_range_regex(uiViewSrcUrl/src_url, url, srcurl)
]]
}
val.msg.srcname = {
[val.ret.empty] = [[{?1523:680?}]],
[val.ret.outofrange] = [[{?1523:323?}]]
}
val.msg.srcurl = {
[val.ret.empty] = [[{?1523:888?}]],
[val.ret.outofrange] = [[{?1523:369?}]]
}
txt_main_explain = [[{?1523:899?}]]
txt_src_head = [[{?1523:91?}]]
txt_src_explain = [[{?1523:836?}]]
txt_time_explain = [[]]
txt_note_explain = [[]]
txt_tel_explain = [[{?1523:878?}]]
g_page_help = [[hilfe_dect_internetradio-quelle.html]]
elseif g_ctlmgr.SrcType == "pc" then
g_page_title = [[{?1523:944?}]]
g_query = "PODCAST"
g_val = {
prog = [[
not_empty(uiViewSrcUrl/src_url, srcurl)
char_range_regex(uiViewSrcUrl/src_url, url, srcurl)
not_empty(uiViewSrcUpdateIntervalHours/src_update_interval_hours, srctime)
char_range_regex(uiViewSrcUpdateIntervalHours/src_update_interval_hours, decimals, srctime)
not_empty(uiViewSrcUpdateIntervalMinutes/src_update_interval_minutes, srctime)
char_range_regex(uiViewSrcUpdateIntervalMinutes/src_update_interval_minutes, decimals, srctime)
]]
}
val.msg.srcname = {
[val.ret.empty] = [[{?1523:192?}]],
[val.ret.outofrange] = [[{?1523:446?}]]
}
val.msg.srcurl = {
[val.ret.empty] = [[{?1523:22?}]],
[val.ret.outofrange] = [[{?1523:303?}]]
}
val.msg.srctime = {
[val.ret.empty] = [[{?1523:6464?}]],
[val.ret.outofrange] = [[{?1523:238?}]]
}
txt_main_explain = [[{?1523:777?}]]
txt_src_head = [[{?1523:283?}]]
txt_src_explain = [[{?1523:697?}]]
txt_time_explain = [[{?1523:716?}]]
txt_note_explain = [[{?1523:0?}]]
txt_tel_explain = [[{?1523:467?}]]
g_page_help = [[hilfe_dect_podcast-quelle.html]]
elseif g_ctlmgr.SrcType == "rss" then
g_page_title = [[{?1523:624?}]]
g_query = "RSS"
g_val = {
prog = [[
not_empty(uiViewSrcUrl/src_url, srcurl)
char_range_regex(uiViewSrcUrl/src_url, url, srcurl)
not_empty(uiViewSrcUpdateIntervalHours/src_update_interval_hours, srctime)
char_range_regex(uiViewSrcUpdateIntervalHours/src_update_interval_hours, decimals, srctime)
not_empty(uiViewSrcUpdateIntervalMinutes/src_update_interval_minutes, srctime)
char_range_regex(uiViewSrcUpdateIntervalMinutes/src_update_interval_minutes, decimals, srctime)
]]
}
val.msg.srcname = {
[val.ret.empty] = [[{?1523:620?}]],
[val.ret.outofrange] = [[{?1523:112?}]]
}
val.msg.srcurl = {
[val.ret.empty] = [[{?1523:280?}]],
[val.ret.outofrange] = [[{?1523:832?}]]
}
val.msg.srctime = {
[val.ret.empty] = [[{?1523:533?}]],
[val.ret.outofrange] = [[{?1523:460?}]]
}
txt_main_explain = [[{?1523:707?}]]
txt_src_head = [[{?1523:70?}]]
txt_src_explain = [[{?1523:140?}]]
txt_time_explain = [[{?1523:30?}]]
txt_note_explain = [[{?1523:958?}]]
txt_tel_explain = [[{?1523:509?}]]
g_page_help = [[hilfe_dect_rss-quelle.html]]
end
function get_phones()
local tmp = general.listquery("dect:settings/Handset/list(Name,Subscribed,Manufacturer,User)")
local phones = {}
local cnt = 0
local cnt_all = 0
for i,v in ipairs(tmp) do
cnt_all = cnt_all + 1
if v.Name ~= "" and v.Subscribed == "1" and v.Manufacturer=="AVM" then
cnt = cnt + 1
phones[cnt] = {}
phones[cnt].name = v.Name
phones[cnt].subscribed = v.Subscribed
phones[cnt].manu = v.Manufacturer
phones[cnt].id = tonumber(v.User) or 0
end
end
return phones, cnt, cnt_all
end
function get_page_var()
if g_ctlmgr.newSrc == "1" then
g_ctlmgr.src_name = ""
g_ctlmgr.src_addr = ""
g_ctlmgr.src_bitmap = 1023
g_ctlmgr.src_notification = "0"
g_ctlmgr.src_poll = 1200
else
g_ctlmgr.src_name = box.query("configd:settings/"..g_query..g_ctlmgr.SrcId.."/Name")
g_ctlmgr.src_addr = box.query("configd:settings/"..g_query..g_ctlmgr.SrcId.."/URL")
g_ctlmgr.src_bitmap = tonumber(box.query("configd:settings/"..g_query..g_ctlmgr.SrcId.."/Bitmap")) or 0
g_ctlmgr.src_notification = box.query("configd:settings/"..g_query..g_ctlmgr.SrcId.."/MWI","0")
g_ctlmgr.src_poll = tonumber(box.query("configd:settings/"..g_query..g_ctlmgr.SrcId.."/PollInterval")) or 0
end
g_ctlmgr.phones, g_ctlmgr.phones_cnt, g_ctlmgr.phones_cnt_all = get_phones()
g_ctlmgr.src_all = general.listquery("configd:settings/"..g_query.."/list(Name,URL,Bitmap)")
end
function get_bitmap()
local bitmask = 0
local bit_set_cnt = 0
local cnt_all = tonumber(box.post.src_fon_cnt_all) or 0
local cnt_fon = tonumber(box.post.src_fon_cnt) or 0
if cnt_fon < 2 then
return 1023
end
for cnt = 0, cnt_all, 1 do
if box.post["src_fon_"..cnt] then
bitmask = bitmask + math.pow(2, cnt)
bit_set_cnt = bit_set_cnt + 1
end
end
if bit_set_cnt == cnt_fon then
bitmask = 1023
end
return bitmask
end
function refill_user_input()
if box.post.src_name then
g_ctlmgr.src_name = box.post.src_name
end
if box.post.src_url then
g_ctlmgr.src_addr = box.post.src_url
end
g_ctlmgr.src_bitmap = get_bitmap()
if g_ctlmgr.SrcType ~= "ir" then
if box.post.src_notification then
g_ctlmgr.src_notification = "1"
else
g_ctlmgr.src_notification = "0"
end
if box.post.src_update_interval_hours or box.post.src_update_interval_minutes then
g_ctlmgr.src_poll = (tonumber(box.post.src_update_interval_hours) * 3600) + (tonumber(box.post.src_update_interval_minutes) * 60)
end
end
end
get_page_var()
g_name_double_err_txt = [[{?1523:603?}]]
g_url_double_err_txt = [[{?1523:996?}]]
g_no_phone_err_txt = [[{?1523:314?}]]
function check_local_conditions()
for idx, src in ipairs(g_ctlmgr.src_all) do
if tostring(idx-1)~=box.post.SrcId and box.post.src_name and box.post.src_name~="" and src.Name==box.post.src_name then
g_val.error_ids = {}
g_val.error_ids["uiViewSrcName"] = true
g_val.error_msg = box.tohtml(g_name_double_err_txt)
return false, "name"
elseif tostring(idx-1)~=box.post.SrcId and src.URL==box.post.src_url then
g_val.error_ids = {}
g_val.error_ids["uiViewSrcUrl"] = true
g_val.error_msg = box.tohtml(g_url_double_err_txt)
return false, "url"
end
end
local bitmask = get_bitmap()
if bitmask == 0 then
g_ctlmgr.local_error = "phone"
return false, g_ctlmgr.local_error
end
return true
end
if next(box.post) and box.post.btn_save then
local ctlmgr_save={}
if val.validate(g_val) == val.ret.ok and check_local_conditions() then
if not(box.post.src_name) or box.post.src_name == "" then
box.post.src_name = box.post.src_url
end
cmtable.add_var(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/Name", box.post.src_name)
cmtable.add_var(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/URL", box.post.src_url)
cmtable.add_var(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/Bitmap", get_bitmap())
if g_ctlmgr.SrcType ~= "ir" then
cmtable.save_checkbox(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/MWI", "src_notification")
local interval = (box.post.src_update_interval_hours*3600)+(box.post.src_update_interval_minutes*60)
if interval > 86400 then
interval = 86400
end
if interval < 300 then
interval = 300
end
cmtable.add_var(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/PollInterval", tostring(interval))
end
if g_ctlmgr.free_EntryID then
cmtable.add_var(ctlmgr_save, "configd:settings/"..g_query..box.post.SrcId.."/EntryID", g_ctlmgr.free_EntryID)
end
local err,msg = box.set_config(ctlmgr_save)
if err == 0 then
http.redirect(href.get(g_back_to_page))
else
local criterr = general.create_error_div(err,msg)
box.out(criterr)
end
refill_user_input()
else
refill_user_input()
end
end
function get_time(hours)
if g_ctlmgr.SrcType ~= "ir" then
local time = g_ctlmgr.src_poll
if time > 0 then
if hours then
time = (time - (time % 3600)) / 3600
else
time = (time % 3600) / 60
end
end
return time
end
end
function choose_phone()
local str = ""
local bitmask = bit.issetlist(g_ctlmgr.src_bitmap)
str = str..[[<input type="hidden" name="src_fon_cnt" id="uiViewFonCnt" value="]]..g_ctlmgr.phones_cnt..[[" />]]
str = str..[[<input type="hidden" name="src_fon_cnt_all" id="uiViewFonCntAll" value="]]..g_ctlmgr.phones_cnt_all..[[" />]]
for i,v in ipairs(g_ctlmgr.phones) do
str = str..[[<input type="checkbox" id="uiViewFon]]..v.id..[[" name="src_fon_]]..v.id..[["]]
for j, val in ipairs(bitmask) do
if val == v.id then
str = str..[[ checked ]]
end
end
str = str..[[> <label for="uiViewFon]]..v.id..[[">]]..box.tohtml(v.name)..[[</label><br>]]
end
return str
end
function get_src_note()
if g_ctlmgr.src_notification=="1" then
return [[checked]]
end
return [[]]
end
function convert_src_all_to_js_array()
local str = [[]]
for idx, src in ipairs(g_ctlmgr.src_all) do
if src.Name~="" and src.URL~="" and tostring(idx-1)~=g_ctlmgr.SrcId then
if str == [[]] then
str = [[{ ]]
else
str = str..[[, ]]
end
str = str..[["]]..(idx-1)..[[" : { "name" : "]]..src.Name..[[", "url" : "]]..src.URL..[[" }]]
end
end
if str == [[]] then
str = [[{]]
end
return str..[[ }]]
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onSrcSubmit()
{
var srcType = "<?lua box.js(g_ctlmgr.SrcType) ?>";
var srcAll = <?lua box.out(convert_src_all_to_js_array()) ?>;
var phoneCnt = <?lua box.out(g_ctlmgr.phones_cnt) ?>;
if (val.active)
{
if (srcType != "ir")
{
var hour = parseInt(jxl.getValue("uiViewSrcUpdateIntervalHours"));
var minu = parseInt(jxl.getValue("uiViewSrcUpdateIntervalMinutes"));
if (isNaN(hour) && minu > 0)
{
jxl.setValue("uiViewSrcUpdateIntervalHours", "0");
hour = 0;
}
if (isNaN(minu) && hour > 0)
{
jxl.setValue("uiViewSrcUpdateIntervalMinutes", "0");
minu = 0;
}
if ( ((hour * 60) + minu) < 5 )
{
if (!confirm("{?1523:7889?}"))
{
val.markError("uiViewSrcUpdateIntervalMinutes");
val.active = false;
return false;
}
else
{
jxl.setValue("uiViewSrcUpdateIntervalHours", "0");
jxl.setValue("uiViewSrcUpdateIntervalMinutes", "5");
}
}
if ( ((hour * 60) + minu) > 1440)
{
if (!confirm("{?1523:605?}"))
{
val.markError("uiViewSrcUpdateIntervalMinutes");
val.markError("uiViewSrcUpdateIntervalHours");
val.active = false;
return false;
}
else
{
jxl.setValue("uiViewSrcUpdateIntervalHours", "24");
jxl.setValue("uiViewSrcUpdateIntervalMinutes", "0");
}
}
}
var akt_name = jxl.getValue("uiViewSrcName");
var akt_url = jxl.getValue("uiViewSrcUrl");
for (var x in srcAll)
{
if (srcAll[x].name == akt_name)
{
val.markError("uiViewSrcName");
alert("<?lua box.js(g_name_double_err_txt) ?>");
val.active = false;
return false;
}
if (srcAll[x].url == akt_url)
{
val.markError("uiViewSrcUrl");
alert("<?lua box.js(g_url_double_err_txt) ?>");
val.active = false;
return false;
}
}
var akt_cnt = 0;
if (phoneCnt>1)
{
var nodes = jxl.walkDom("uiViewTelOption", "input", function(elem){ return (elem.type == "checkbox")&&(elem.checked)});
for (var node in nodes)
akt_cnt++;
if (akt_cnt == 0)
{
alert("<?lua box.js(g_no_phone_err_txt) ?>");
val.active = false;
return false;
}
}
}
<?lua
val.write_js_checks(g_val)
?>
}
ready.onReady(val.init(onSrcSubmit, "btn_save", "main_form" ));
</script>
<?include "templates/page_head.html" ?>
<form name="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<p>
<?lua box.html(txt_main_explain) ?>
</p>
<hr>
<h4><?lua box.html(txt_src_head) ?></h4>
<div class="formular">
<p>
<?lua box.html(txt_src_explain) ?>
</p>
<label for="uiViewSrcName">{?1523:719?}:</label>
<input type="text" size="70" maxlength="60" id="uiViewSrcName" name="src_name" value="<?lua box.html(g_ctlmgr.src_name) ?>" <?lua val.write_attrs(g_val, "uiViewSrcName") ?>>
<?lua val.write_html_msg(g_val, "uiViewSrcName") ?>
<br>
<label for="uiViewSrcUrl">{?1523:544?}:</label>
<input type="text" size="70" maxlength="128" id="uiViewSrcUrl" name="src_url" value="<?lua box.html(g_ctlmgr.src_addr) ?>" <?lua val.write_attrs(g_val, "uiViewSrcUrl") ?>>
<?lua val.write_html_msg(g_val, "uiViewSrcUrl") ?>
<?lua
if g_ctlmgr.SrcType ~= "ir" then
box.out([[<p>]]..box.tohtml(txt_time_explain)..[[</p>
<label for="uiViewSrcUpdateIntervalHours">]]..box.tohtml([[{?1523:285?}]])..[[:</label>
<input type="text" size="1" maxlength="2" id="uiViewSrcUpdateIntervalHours" name="src_update_interval_hours" value="]]..get_time(true)..[[" ]]..val.get_attrs(g_val, "uiViewSrcUpdateIntervalHours")..[[>
<label for="uiViewSrcUpdateIntervalHours">]]..box.tohtml([[{?1523:183?}]])..[[</label>
<input type="text" size="1" maxlength="2" id="uiViewSrcUpdateIntervalMinutes" name="src_update_interval_minutes" value="]]..get_time(false)..[[" ]]..val.get_attrs(g_val, "uiViewSrcUpdateIntervalMinutes")..[[>
<label for="uiViewSrcUpdateIntervalMinutes">]]..box.tohtml([[{?1523:782?}]])..[[</label>
]]..val.get_html_msg(g_val, "uiViewSrcUpdateIntervalHours")..val.get_html_msg(g_val, "uiViewSrcUpdateIntervalMinutes")..[[
<br>
<input type="checkbox" id="uiViewSrcNotification" name="src_notification" ]]..get_src_note()..[[>
<label for="uiViewSrcNotification">]]..box.tohtml(txt_note_explain)..[[</label>]])
end
?>
</div>
<div id="uiViewTelOption" <?lua if g_ctlmgr.phones_cnt < 2 then box.out("style='display:none;'") end?>>
<hr>
<h4>{?1523:63?}</h4>
<div class="formular">
<p>
<?lua box.html(txt_tel_explain) ?>
</p>
<?lua
if g_ctlmgr.local_error and g_ctlmgr.local_error=="phone" then
box.out([[<p class="ErrorMsg">]])
box.html(g_no_phone_err_txt)
box.out([[</p>]])
end
?>
<?lua box.out(choose_phone()) ?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="SrcId" value="<?lua box.html(g_ctlmgr.SrcId)?>" />
<?lua
if g_ctlmgr.free_EntryID then
box.out([[<input type="hidden" name="RssId" value="]]..box.tohtml(g_ctlmgr.free_EntryID)..[[" />]])
end
?>
<input type="hidden" name="newSrc" value="<?lua box.html(g_ctlmgr.newSrc)?>" />
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page)?>" />
<input type="hidden" name="SrcType" value="<?lua box.html(g_ctlmgr.SrcType)?>" />
<button type="submit" name="btn_save" id="btnSave">{?txtOK?}</button>
<button type="submit" name="btn_cancel" id="btnCancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
