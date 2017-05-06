<?lua
g_page_type = "all"
g_page_title = "{?1423:645?}"
g_page_help = 'hilfe_fon_vorwahlen.html'
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("fon_numbers")
require("general")
require("cmtable")
g_back_to_page = http.get_back_to_page( "/fon_num/dialrul_provider.lua" )
g_prog = [[
if __exists(uiPrefix%1/prefix%1) then
char_range_regex(uiPrefix%1/prefix%1, decimals, number_txt)
length(uiPrefix%1/prefix%1, 0, 20, empty_allowed, name_txt)
end
]]
g_val = {
prog = [[]]
}
for i=0,9 do
local id=tostring(i)
g_val.prog=g_val.prog..general.sprintf(g_prog,id)
end
val.msg.number_txt = {
[val.ret.empty] = [[{?1423:298?}]],
[val.ret.outofrange] = [[{?1423:246?}]]
}
val.msg.name_txt = {
[val.ret.toolong] = [[{?1423:1?}]]
}
g_errmsg=[[]]
g_data={}
if (next(box.post) and (box.post.cancel)) then
http.redirect(g_back_to_page)
end
function read_data()
g_data.provider_list=fon_numbers.get_prefix_list()
end
read_data()
if next(box.post) then
if box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
for i=0,9 do
local id=tostring(i)
cmtable.add_var(ctlmgr_save, "telcfg:settings/Routing/Provider"..id, box.post["prefix"..id] or "")
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
read_data()
end
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiMainPrefix {
margin-left: 25px;
}
#uiMorePrefixes {
margin-left: 10px;
}
</style>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function init()
{
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div class="close">
<p>{?1423:122?}</p>
<hr>
<div class="formular small_indent">
<h4>{?1423:212?}</h4>
<p>{?1423:930?}</p>
<div class="formular" id="uiMainPrefix">
<input type="text" id="uiPrefix0" name="prefix0" size="21" maxlength="20" value="<?lua box.html(g_data.provider_list[1])?>">
<?lua
if config.OEM=="arcor" then
box.out([[&nbsp;Arcor: 0 10 70]])
end
?>
</div>
</div>
</div>
<hr>
<div class="close">
<div class="formular small_indent">
<h4>{?1423:898?}</h4>
<p>{?1423:292?}</p>
<div class="formular" id="uiMorePrefixes">
<?lua
for i=1,9 do
local id=tostring(i)
local val=box.tohtml(g_data.provider_list[i+1])
box.out(general.sprintf([[<div><label for="uiPrefix%1" name="prefix%1">%1.</label><input type="text" id="uiPrefix%1" size="21" maxlength="20" name="prefix%1" value="%2"></div>]],id,val))
end
?>
</div>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="btn_save" id="btnSave">{?txtApply?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
ready.onReady(val.init(onNumEditSubmit, "btnSave", "main_form" ));
</script>
<?include "templates/html_end.html" ?>
