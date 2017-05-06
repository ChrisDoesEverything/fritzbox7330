<?lua
g_page_type = "all"
g_page_help = "hilfe_system_user.html"
dofile("../templates/global_lua.lua")
g_page_title = ""
require"http"
require"href"
require"general"
require"html"
require"cmtable"
require"boxusers"
g_err = {}
g_auth_mode = boxusers.auth_mode()
g_password = boxusers.password
------------------------------------------------------------------------------
local function deletable(user)
if boxusers.is_myself(user) then
return false
end
return true
end
if box.post.cancel then
http.redirect(box.glob.script)
end
if box.post.edit then
http.redirect(
href.get("/system/boxuser_edit.lua", http.url_param("uid", box.post.edit))
)
end
if box.post.delete then
local i, user = array.find(boxusers.list, func.eq(box.post.delete, "UID"))
if i and user and deletable(user) then
local webvar = "boxusers:command/user[%s]"
local saveset = {}
cmtable.add_var(saveset, webvar:format(user.UID), "delete")
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(box.glob.script)
end
end
end
local function get_btn(which, user)
local btn = html.button{
type="submit", class="icon", name=which, value=user.UID or ""
}
local img = html.img{}
if which == 'edit' then
img.src = "/css/default/images/bearbeiten.gif"
btn.title = [[{?txtIconBtnEdit?}]]
elseif which == 'delete' then
img.src = "/css/default/images/loeschen.gif"
btn.title = [[{?txtIconBtnDelete?}]]
if deletable(user) then
btn.onclick = string.format([[return confirmDelete("\"%s\"");]], box.tojs(user.name or ""))
else
btn.style="visibility:hidden"
btn.disabled = true
end
end
btn.add(img)
return btn
end
function write_user_trs()
if #boxusers.list < 1 then
html.tr{class="emptylist",
html.td{colspan=3,
[[{?4416:753?}]]
}
}.write()
else
for i, user in ipairs(boxusers.list) do
html.tr{
html.td{user.name or ""},
html.td{user.email or ""},
html.td{class="btncolumn",
get_btn('edit', user),
get_btn('delete', user)
}
}.write()
end
end
end
function write_save_error()
if g_err.code and g_err.code ~= 0 then
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
function write_newuser_btn()
if #boxusers.list < 20 then
html.div{class="btn_form",
html.button{type="submit", name="edit", value="new",
[[{?4416:785?}]]
}
}.write()
end
end
function write_mode()
if g_auth_mode ~= "user" then
if not general.is_ip_client() then
html.p{html.strong{
[[{?4416:4262?}]]
}}.write()
end
else
html.p{
[[{?4416:566?}]]
}.write()
end
end
function write_safety_link()
require"helpurl"
html.p{html.a{
href=helpurl.get("hilfe_system_user_konzept"), target="_blank",
[[{?4416:803?}]]
}}.write()
end
function myfritz_shown()
return menu.exists_page("/internet/myfritz.lua") and menu.show_page("/internet/myfritz.lua")
end
function write_https_hint()
if myfritz_shown() and box.query("remoteman:settings/enabled") ~= "1" then
html.br{}.write()
html.strong{
[[{?txtHinweis?}]]
}.write()
html.p{
[[{?4416:758?}]]
}.write()
end
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/disable_page.css"/>
<style type="text/css">
.disable_main_page_content_box,
#disable_main_page_content_box {
width: 560px;
margin-left:auto;
margin-right:auto;
margin-top: 8%;
border: 1px solid #8da4a3;
background-color: #faf9f6;
padding: 4px 8px;
font-size: 13px;
font-family: Arial;
color: #3f464c;
}
#disable_main_page_content_foot {
text-align:right;
}
</style>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/disable_page.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function confirmDelete(username) {
var txt = "{?4416:262?}";
if (username) {
txt = jxl.sprintf("{?4416:47?}", username);
}
if (!confirm(txt)) {
return false;
}
}
function openVpnPopup() {
window.open(encodeURI("<?lua href.write([[/system/vpn_print.lua]],'uid='..box.tojs((box.get.vpn_popup or ''))) ?>"),'VPN','width=600,height=830,statusbar,scrollbars=yes,resizable=yes');
}
function init() {
if ("nil" != "<?lua box.js(tostring(box.get.vpn_popup)) ?>")
{
if (gDisableMainPageBox=="first") {
gDisableMainPageBox = createModalBox(createBoxContent("all"));
}
fillBoxContent('<h4>{?4416:517?}</h4>', '{?4416:767?}', '<button type="button" tabindex="1" id="idBtnOk" onclick="openVpnPopup(); gDisableMainPageBox.close();">{?4416:879?}</button><button type="button" tabindex="2" id="idBtnCancel" onclick="gDisableMainPageBox.close();">{?4416:834?}</button>');
gDisableMainPageBox.open();
}
}
function initTableSorter() {
sort.init("uiBoxUserList");
sort.setDirection(0,-1);
sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<?lua write_save_error() ?>
<p>
{?4416:729?}
</p>
<?lua
if not general.is_ip_client() then
box.out([[
<p>{?4416:757?}</p>
]])
end
?>
<?lua write_safety_link() ?>
<hr>
<table id="uiBoxUserList" class="zebra">
<tr class="thead">
<th class="sortable">{?4416:768?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?4416:888?}<span class="sort_no">&nbsp;</span></th>
<th class="btncolumn"></th>
</tr>
<?lua write_user_trs() ?>
</table>
<?lua write_newuser_btn() ?>
<br>
<?lua write_mode() ?>
<?lua write_https_hint() ?>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
