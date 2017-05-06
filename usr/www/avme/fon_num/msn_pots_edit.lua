<?lua
g_page_type = "all"
if box.post.fonNumMode == "asall" or box.get.fonNumMode == "asall" or
box.post.fonNumMode == "asint" or box.get.fonNumMode == "asint" then
g_page_type = "wizard"
end
g_page_title = "{?2271:211?}"
g_page_help = "hilfe_fon_festnetz.html"
g_menu_active_page = "/fon_num/fon_num_list.lua"
g_fon_num_mode = ""
if box.get.fonNumMode then
g_fon_num_mode = box.get.fonNumMode
elseif box.post.fonNumMode then
g_fon_num_mode = box.post.fonNumMode
end
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("fon_numbers")
require("general")
require("cmtable")
g_val = {
prog = [[
not_empty(uiViewNumber/number, number_txt)
length(uiViewNumber/number, 0, 20, number_txt)
char_range_regex(uiViewNumber/number, decimals, number_txt)
length(uiViewName/name, 0, 16, name_txt)
]]
}
val.msg.number_txt = {
[val.ret.empty] = [[{?2271:936?}]],
[val.ret.toolong] = [[{?2271:523?}]],
[val.ret.outofrange] = [[{?2271:200?}]]
}
val.msg.name_txt = {
[val.ret.toolong] = [[{?2271:8905?}]]
}
g_errmsg=[[]]
function get_var()
local num_uid = box.get.num_uid
if box.post.num_uid then
num_uid = box.post.num_uid
end
g_num = fon_numbers.find_num_by_UID(num_uid)
if not g_num then
http.redirect(href.get('/fon_num/fon_num_list.lua','fonNumMode='..g_fon_num_mode))
end
end
get_var()
if next(box.post) then
if box.post.btn_cancel then
http.redirect(href.get('/fon_num/fon_num_list.lua','fonNumMode='..g_fon_num_mode))
elseif box.post.btn_save then
if val.validate(g_val) == val.ret.ok then
local ctlmgr_save={}
if g_num.type == "msn" then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/"..g_num.id , box.post.number)
if box.post.name then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/Name"..string.sub(g_num.id, 4) , box.post.name)
end
else
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/POTS" , box.post.number)
if box.post.name then
cmtable.add_var(ctlmgr_save, "telcfg:settings/MSN/POTSName" , box.post.name)
end
end
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
else
http.redirect(href.get('/fon_num/fon_num_list.lua','fonNumMode='..g_fon_num_mode))
end
get_var()
end
end
end
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>
<?lua
if g_num.type == "msn" then
box.html([[{?2271:759?}]])
else
box.html([[{?2271:198?}]])
end
?>
</p>
<hr>
<div class="formular">
<label for="uiViewNumber">{?2271:373?}</label>
<input type="text" size="30" maxlength="20" id="uiViewNumber" name="number" value="<?lua box.html(g_num.number) ?>" <?lua val.write_attrs(g_val, "uiViewNumber") ?>>
<?lua val.write_html_msg(g_val, "uiViewNumber") ?>
<div <?lua if box.query("box:settings/expertmode/activated") ~= "1" then style="display:none;" end ?>>
<label for="uiViewName">{?2271:838?}</label>
<input type="text" size="30" maxlength="16" id="uiViewName" name="name" value="<?lua box.html(g_num.name) ?>" <?lua val.write_attrs(g_val, "uiViewName") ?>>
<?lua val.write_html_msg(g_val, "uiViewName") ?>
</div>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<input type="hidden" name="num_uid" value="<?lua box.html(g_num.uid) ?>">
<input type="hidden" name="fonNumMode" value="<?lua box.html(g_fon_num_mode) ?>">
<button type="submit" name="btn_save" id="btnSave">{?txtOK?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
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
