<?lua
g_page_type = "all"
g_page_title = "{?8217:926?}"
g_page_help = "hilfe_fonbook_addnum.html"
g_menu_active_page = "/fon_num/fonbook_list.lua"
dofile("../templates/global_lua.lua")
require("general")
require("fon_book")
require("http")
require("html")
require("val")
g_back_to_page = http.get_back_to_page()
if box.post.cancel or ( not box.get.number and not box.post.number ) then
http.redirect( href.get( g_back_to_page ) )
end
local pb = fon_book.read_fonbook(0, 0, "name")
local function get_uid()
if box.post.choose == "uid" then
return box.post.uid or ""
end
return box.post.choose or "new"
end
function write_explain()
local number = box.get.number or box.post.number or ""
html.p{general.sprintf(
[[{?8217:285?}]],
number, fon_book.bookname() or [[Standard]]
)}.write()
end
function write_radio_new()
local checked = get_uid() == "new"
html.input{
type = "radio", name = "choose", value = "new", id = "uiChoose_new", checked = checked
}.write()
html.label{["for"] = "uiChoose_new",
[[{?8217:796?}]]
}.write()
end
function get_entry_select(uid)
local sel = html.select{name = "uid", id = "uiUid"}
sel.value = uid ~= "new" and uid or ""
sel.add(
html.option{value = "", [[{?txtPleaseSelect?}]]}
)
for i, entry in ipairs(pb) do
sel.add(
html.option{value = entry.uid, entry.name}
)
end
return sel
end
function write_radio_uid_select()
local uid = get_uid()
html.input{
type = "radio", name = "choose", value = "uid", id = "uiChoose_uid", checked = uid ~= "new"
}.write()
html.label{["for"] = "uiChoose_uid",
[[{?8217:815?}]]
}.write()
html.div{class = "formular enableif_uid",
get_entry_select(uid)
}.write()
end
function write_hidden_values()
local number = box.get.number or box.post.number or ""
local numbername = box.get.numbername or box.post.numbername or ""
html.input{type = "hidden", name = "number", value = number}.write()
html.input{type = "hidden", name = "numbername", value = numbername}.write()
end
g_val = {}
g_val.prog = [[
if __radio_check(uiChoose_uid/choose, uid) then
not_empty(uiUid/uid, nouid)
end
]]
val.msg.nouid = {
[val.ret.empty] = [[{?8217:712?}]]
}
val.msg.nouid[val.ret.notfound] = val.msg.nouid[val.ret.empty]
if box.post.next and val.validate(g_val) == val.ret.ok then
http.redirect(
href.get("/fon_num/fonbook_entry.lua",
http.url_param("uid", get_uid()),
http.url_param("number", box.post.number),
http.url_param("numbername", box.post.numbername),
http.url_param("back_to_page", g_back_to_page)
)
)
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua val.write_js_error_strings() ?>
function onNext() {
var valResult = (function() {
var ret;
<?lua val.write_js_checks(g_val) ?>
})();
return valResult;
}
ready.onReady(val.init(onNext, "next"));
ready.onReady(function(){
enableOnClick({inputName: "choose", classString: "enableif_%1"});
});
</script>
<?include "templates/page_head.html" ?>
<form method="POST" name="mainform" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit("next") ?>
<?lua write_explain() ?>
<div class="formular">
<?lua write_radio_new() ?>
</div>
<div class="formular">
<?lua write_radio_uid_select() ?>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<?lua write_hidden_values() ?>
<div id="btn_form_foot">
<button type="submit" name="next">{?txtNext?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
