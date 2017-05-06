<?lua
-- de-first -begin
g_page_type = "wizard"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"utf8"
do
if box.set_temporary_language then
local currlang = box.post.language or ""
if currlang ~= "" then
box.set_temporary_language(currlang)
utf8.set_language(currlang)
end
end
end
require"wizard"
require"general"
require"country"
require"html"
require"cmtable"
require"val"
g_val = {}
g_val.prog = ""
g_err = {}
function write_saveerror()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
local needed = array.truth(string.split(box.get.needed or box.post.needed or "", ","))
function write_needed()
local t = {}
if needed.language then
table.insert(t, "language")
end
if needed.country then
table.insert(t, "country")
end
if needed.annex then
table.insert(t, "annex")
end
html.input{type="hidden", name="needed", value=table.concat(t, ",")}.write()
end
local lang_org = {
de = [[Deutsch]],
en = [[English]],
es = [[Español]],
sp = [[Español]],
fr = [[Français]],
el = [[Griechisch]],
it = [[Italiano]],
nl = [[Nederlands]],
pt = [[Português]],
tr = [[Türkisch]],
pl = [[Polski]]
}
local lang = {
de = [[{?3340:14?}]],
en = [[{?3340:754?}]],
es = [[{?3340:575?}]],
sp = [[{?3340:884?}]],
fr = [[{?3340:276?}]],
el = [[{?3340:140?}]],
it = [[{?3340:611?}]],
nl = [[{?3340:261?}]],
pt = [[{?3340:926?}]],
tr = [[{?3340:930?}]],
pl = [[{?3340:425?}]]
}
function write_language_select()
if needed.language then
local names = lang_org
if box.post.language then
names = lang
end
local curr_lang = box.post.language or box.query("box:settings/language")
local ids = general.listquery("language:settings/language/list(id)")
local id
for i, item in ipairs(ids or {}) do
id = "uiLanguage:" .. item.id
html.div{class="formular",
html.input{type="radio", name="language", id=id, value=item.id, checked=item.id == curr_lang},
html.label{['for']=id, names[item.id] or [[{?3340:858?}]]}
}.write()
end
end
end
local function get_countryname(c)
--if c.name:find(c.id, 1, true) then
--return country.get_countryname(c.id)
--end
return c.clearname or c.name
end
local function get_annex_list()
local id = box.post.country
local annex
if id and id ~= 'tochoose' then
id = id:gsub("^0", "")
annex = country.get_annex(id)
annex = annex:gsub("%s+", "")
if annex == "" then
return nil
end
annex = string.split(annex, "")
end
return annex
end
function write_country_select()
if needed.country then
local list, other = country.get_countrylist("KNOWN")
list, other = array.filter(list, function(el) return el.id ~= "99" end)
utf8.sort(list, get_countryname)
list = array.cat(list, other)
local curr_country = box.post.country or box.query("box:settings/country")
local sel = html.select{
class = val.get_error_class(g_val, "uiCountry") or "",
id="uiCountry",
name="country",
html.option{value="tochoose", selected=curr_country == "tochoose",
[[{?txtPleaseSelect?}]]
}
}
for i, c in ipairs(list) do
sel.add(html.option{value=c.id, selected=curr_country == c.id, get_countryname(c)})
end
html.div{class="formular", sel}.write()
val.write_html_msg(g_val, "uiCountry")
end
end
function write_annex_select()
if needed.annex then
local annex_txt = {
A = [[{?3340:631?}]],
B = [[{?3340:279?}]]
}
local annex_list = get_annex_list() or {"A", "B"}
if #annex_list == 1 then
html.input{type="hidden", name="annex", value=annex_list[1]}.write()
else
local curr_annex = box.post.annex or box.query("sar:settings/Annex")
for i, annex in ipairs(annex_list) do
html.div{class="formular",
html.input{
id="uiAnnex:"..annex, type="radio", name="annex", value=annex, checked=curr_annex == annex
},
html.label{['for']="uiAnnex:"..annex, annex_txt[annex] or ""}
}.write()
end
end
end
end
local function skip_dlg_annex()
local list = get_annex_list()
return list and #list < 2
end
local function reboot_needed()
local rebooting = box.query("box:status/rebooting")
return rebooting ~= "0"
end
wizard.dialogs = {
'dlg_language',
'dlg_country',
'dlg_annex',
'dlg_end'
}
wizard.nocancel = true
wizard.title = {
dlg_language = [[{?3340:373?}]],
dlg_annex = [[{?3340:491?}]],
dlg_country = [[{?3340:267?}]]
}
wizard.start = function()
if needed.language then
return 'dlg_language'
end
if needed.country then
return 'dlg_country'
end
if needed.annex then
return 'dlg_annex'
end
return 'dlg_end'
end
wizard.dlg_language = {
forward = function()
if needed.country then
return 'dlg_country'
end
if needed.annex then
return 'dlg_annex'
end
return 'dlg_end'
end,
backward = function() end
}
wizard.dlg_country = {
forward = function()
if needed.annex and not skip_dlg_annex() then
return 'dlg_annex'
end
return 'dlg_end'
end,
backward = function()
if needed.language then
return 'dlg_language'
end
end
}
wizard.dlg_annex = {
forward = function() return 'dlg_end' end,
backward = function()
if needed.country then
return 'dlg_country'
end
if needed.language then
return 'dlg_language'
end
end
}
wizard.dlg_end = {
forward = function() end,
backward = function()
if needed.annex and not skip_dlg_annex() then
return 'dlg_annex'
end
if needed.country then
return 'dlg_country'
end
if needed.language then
return 'dlg_language'
end
end
}
wizard.init = function()
wizard.curr = wizard.start()
if box.post.prevdlg and box.post.prevdlg ~= "" then
if box.post.forward then
local res = val.validate(g_val)
if res ~= val.ret.ok then
wizard.curr = box.post.prevdlg
else
wizard.curr = wizard[box.post.prevdlg].forward()
end
elseif box.post.backward then
wizard.curr = wizard[box.post.prevdlg].backward()
end
end
wizard.wiztype = box.post.wiztype or box.get.wiztype
if wizard.title then
g_page_title = wizard.title[wizard.curr] or ""
end
end
local function nocountry_validation()
val.msg.nocountry = {
[val.ret.wrong] = [[{?3340:186?}]]
}
return [[
if __value_equal(uiCountry/country, tochoose) then
const_error(uiCountry/country, wrong, nocountry)
end
]]
end
if box.post.forward and box.post.prevdlg == 'dlg_country' then
g_val.prog = nocountry_validation()
end
wizard.init()
if wizard.curr == 'dlg_country' then
g_val.prog = nocountry_validation()
end
if box.post.forward and wizard.curr == 'dlg_end' then
local saveset = {}
if needed.language then
cmtable.add_var(saveset, "box:settings/language", box.post.language)
end
if needed.country then
cmtable.add_var(saveset, "box:settings/country", box.post.country)
end
if needed.annex then
local annex = box.post.annex
local list = get_annex_list()
if list then
if not annex then
annex = list[1]
end
if #list == 1 and annex ~= list[1] then
annex = list[1]
end
end
if annex then
cmtable.add_var(saveset, "sar:settings/Annex", annex)
end
end
g_err.code, g_err.msg = box.set_config(saveset)
local reboot = reboot_needed()
if reboot then
http.redirect(href.get("/reboot.lua", http.url_param("extern_reboot", "1")))
else
http.redirect("/logincheck.lua")
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">
<style type="text/css">
<?lua wizard.write_css() ?>
</style>
<script type="text/javascript" src="/js/dialog.js?lang=<?lua box.html(box.post.language or config.language) ?>"></script>
<script type="text/javascript" src="/js/wizard.js?lang=<?lua box.html(box.post.language or config.language) ?>"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua val.write_js_error_strings() ?>
function onForward() {
var result = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
return result;
}
<?lua if wizard.curr == 'dlg_country' then
box.out("\n" .. [[
ready.onReady(val.init(onForward, "forward"));
]])
end ?>
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('forward') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua wizard.write_hidden_params() ?>
<?lua write_needed() ?>
<div id="dlg_language">
<p>{?3340:842?}</p>
<?lua write_language_select() ?>
</div>
<div id="dlg_country">
<p>
{?3340:967?}
</p>
<?lua write_country_select() ?>
</div>
<div id="dlg_annex">
<p>
{?3340:829?}
</p>
<?lua write_annex_select() ?>
</div>
<div id="dlg_end">
<?lua write_saveerror() ?>
</div>
<div id="btn_form_foot">
<?lua wizard.write_buttons() ?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
