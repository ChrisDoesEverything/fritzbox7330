<?lua
g_page_type = "all"
g_page_title = [[{?46:154?}]]
g_page_help = "hilfe_fon_telefonbuch_wechseln.html"
g_menu_active_page = "/fon_num/fonbook_list.lua"
dofile("../templates/global_lua.lua")
require"http"
require"html"
require"fon_book"
require"general"
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_list.lua" )
local function name2id(name, value)
local id = "ui" .. name:at(1):upper() .. name:sub(2)
if value then id = id .. ":" .. value end
return id
end
function write_books()
local books = fon_book.get_book_list()
local curr = fon_book.get_book_id()
for i, book in ipairs(books) do
if book.name then
local id = name2id("bookid", book.id)
html.div{
class="formular",
html.input{type="radio", name="bookid", id=id, value=book.id, checked = book.id == curr},
html.label{["for"]=id, book.name or ""}
}.write()
end
end
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
if box.post.apply then
local id = tonumber( box.post.bookid )
if id then
fon_book.select_book(id)
end
http.redirect( g_back_to_page )
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
</style>
<script type="text/javascript">
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<p>
{?46:265?}
</p>
<?lua write_books() ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
