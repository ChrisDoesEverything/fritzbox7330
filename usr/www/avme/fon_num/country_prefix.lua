<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_wahlregeln.html'
dofile("../templates/global_lua.lua")
require"cmtable"
require"val"
require"fon_numbers"
require"country"
require"utf8"
require"general"
require"http"
g_back_to_page = http.get_back_to_page( "/fon_num/country_prefix.lua" )
if box.post.cancel then
http.redirect(g_back_to_page)
end
g_errcode = 0
g_errmsg = [[]]
g_data={}
function read_data()
g_data.countries=country.get_countrylist("KNOWN")
g_data.cur_country=box.query("box:settings/country")
end
read_data()
g_val = {
prog = [[
]]
}
val.msg.num_error = {
[val.ret.empty] = [[{?8227:718?}]],
[val.ret.outofrange] = [[{?8227:512?}]]
}
if (next(box.post) and (box.post.apply)) then
if (box.post.country~=g_data.cur_country) then
local result=val.validate(g_val)
if (result == val.ret.ok) then
local saveset={}
cmtable.add_var(saveset, "box:settings/country",box.post.country)
local err, msg = box.set_config( saveset)
if err == 0 and box.query("box:status/rebooting") ~= "0" then
http.redirect(href.get("/reboot.lua", 'extern_reboot=1'))
end
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
end
end
end
end
function get_countries()
local str=[[]]
local selected=[[]]
for i,country in ipairs(g_data.countries) do
selected=[[]]
if (g_data.cur_country==country.id) then
selected=[[selected]]
end
str=str..general.sprintf([[<option value="%1" %2>%3</option>]],box.tohtml(country.id),selected,box.tohtml(country.clearname))
end
return str
end
function write_countries()
local tmp_other
g_data.countries, tmp_other = array.filter(g_data.countries, function(el) return el.id ~= "99" end)
utf8.sort(g_data.countries, function(c) return c.clearname or c.name end)
g_data.countries = array.cat(g_data.countries, tmp_other)
local selected=[[]]
for i,country in ipairs(g_data.countries) do
selected=[[]]
if (g_data.cur_country==country.id) then
selected=[[selected]]
end
box.out(general.sprintf([[<option value="%1" %2>%3</option>]],box.tohtml(country.id),selected,box.tohtml(country.clearname)))
end
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
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
<div class="formular small_indent">
<p>{?8227:7?}</p>
</div>
<hr>
<div class="formular small_indent">
<label>{?8227:924?}</label>
<select id="uiViewCountry" name="country">
<?lua
write_countries()
?>
</select>
</div>
<div class="formular small_indent">
<h4>{?8227:953?}</h4>
<p >{?8227:898?}</p>
</div>
<?lua
if (g_errmsg~="") then
box.out(g_errmsg)
end
?>
</div>
<div id="btn_form_foot">
<button type="submit" name="apply" style="">{?txtApply?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
