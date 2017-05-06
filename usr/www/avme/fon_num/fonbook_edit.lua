<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_fon_telefonbuch_neu.html'
dofile("../templates/global_lua.lua")
require"cmtable"
require"val"
require"fon_book"
require"general"
require"http"
g_back_to_page = http.get_back_to_page( "/fon_num/fonbook_list.lua" )
g_menu_active_page=g_back_to_page
g_show_online_pb=false
if config.ONLINEPB then
g_show_online_pb=true
end
if box.post.cancel then
http.redirect(g_back_to_page)
end
g_val = {
prog = [[
not_empty(uiName/book_name, book_name_txt)
if __checked(uiViewCopyFrom/copy_from) then
if __value_equal(uiViewFonbooks/fonbook_entry, tochoose) then
const_error(uiViewFonbooks/fonbook_entry, wrong, selection_fonbook)
end
end
]]
}
function get_group_data()
local uid = g_data.uid
local groupdata={}
if (fon_book.is_online(uid)) then
local online_pb=fon_book.read_online_book()
local elem, idx=fon_book.find_item(online_pb,"id",uid)
if (g_data.provider=="google") then
groupdata=general.listquery("ontel:settings/ontel"..tostring(idx-1).."/gcgroup/entry/list(enabled,id,selfId,name)")
end
end
return groupdata
end
function validate_group_checks(radio)
if box.post[radio] and box.post[radio] == value then
local groups_selected = false
for k,group in ipairs(get_group_data()) do
if box.post["addtogroup_" .. k] then
groups_selected = true
end
end
return not groups_selected
else
return false
end
end
if config.ONLINEPB then
g_val = {
prog = [[
not_empty(uiName/book_name, book_name_txt)
if __radio_check(uiActionNew/action,userdef) then
if __checked(uiViewCopyFrom/copy_from) then
if __value_equal(uiViewFonbooks/fonbook_entry, tochoose) then
const_error(uiViewFonbooks/fonbook_entry, wrong, selection_fonbook)
end
end
end
if __radio_check(uiActionOnline/action,online) then
if __value_equal(uiProvider/provider, tochoose) then
const_error(uiProvider/provider, wrong, selection_provider)
end
if __value_not_equal(uiProvider/provider, google) then
char_range_regex(uiViewEmailAddress/email_address, email, email_txt)
not_empty(uiViewEmailPassword/email_password, password_txt)
end
end
if __callfunc(uiGroupSelect/groups_select,validate_group_checks) then
const_error(uiGroupSelect/groups_select, wrong, selection_groups)
end
]]
}
end
val.msg.selection_fonbook = {
[val.ret.wrong] = [[{?752:34?}]]
}
val.msg.selection_provider = {
[val.ret.wrong] = [[{?752:454?}]]
}
val.msg.selection_groups = {
[val.ret.wrong] = [[{?752:141?}]]
}
val.msg.book_name_txt = {
[val.ret.notfound] = [[book_name_txt.notfound]],
[val.ret.empty] = [[{?752:512?}]]
}
val.msg.email_txt = {
[val.ret.notfound] = [[email_txt.notfound]],
[val.ret.outofrange] = [[{?752:395?}]]
}
val.msg.password_txt = {
[val.ret.notfound] = [[password_txt.notfound]],
[val.ret.empty] = [[{?752:556?}]]
}
g_showError=0
g_errcode = 0
g_errmsg = [[]]
g_data={}
local function read_foncontrol()
box.query("telcfg:settings/Foncontrol")
local foncontrol = general.listquery("telcfg:settings/Foncontrol/User/list(Name,Type,Id,Phonebook)")
for i = #foncontrol, 1, -1 do
local f = foncontrol[i]
if f.Type == "1" or f.Name == "" then
table.remove(foncontrol, i)
end
end
return foncontrol
end
function read_data()
g_data.uid="-1"
if box.get.uid then
g_data.uid = box.tohtml(box.get.uid)
elseif box.post.uid then
g_data.uid = box.tohtml(box.post.uid)
end
if g_data.uid == "new" then
g_data.uid="-1"
end
g_data.is_new = (g_data.uid == "-1" or (box.post.is_new and box.post.is_new == "true") or (box.get.is_new and box.get.is_new == "true") or false)
g_data.online_test="0"
g_data.online_state="0"
if box.get.online_state then
g_data.online_test="1"
g_data.online_state = box.tohtml(box.get.online_state)
elseif box.post.online_state then
g_data.online_test="1"
g_data.online_state = box.tohtml(box.post.online_state)
end
g_data.fonbooks = fon_book.get_fonbooks()
g_data.book = nil
if not g_data.is_new or (g_data.is_new and g_data.online_test=="1") then
g_data.book = fon_book.find_book_by_id(g_data.fonbooks, g_data.uid)
if (g_data.book~=nil) then
g_data.book.org_name = g_data.book.name
g_data.book.org_email_address = g_data.book.username
g_data.book.org_email_password = g_data.book.password
g_data.book.email_address = g_data.book.username
g_data.book.email_password = g_data.book.password
local id,provider_obj=fon_book.get_provider_by_serviceid(g_data.book.serviceid)
g_data.provider=""
if id then
g_data.provider=id
end
end
end
if type(g_data.book) ~= "table" then
g_data.book={}
g_data.book.name=""
g_data.book.email_address=""
g_data.book.email_password=""
g_data.book.uid="-1"
g_data.provider=""
end
if box.post.book_name then
g_data.book.name = box.post.book_name
g_data.book.email_address = box.post.email_address
g_data.book.email_password = box.post.email_password
g_data.provider=box.post.provider
end
if g_data.is_new then
g_data.foncontrol = read_foncontrol()
end
end
function get_radio_checked(checked)
if checked then
return [[checked="checked"]]
else
return ""
end
end
function get_checkbox(k,group)
local name = "addtogroup_" .. k
local id = "uiAddtogroup_" .. k
local checked = group.enabled == "1"
local str=[[<input type="checkbox" name="]]..name..[[" id="]]..id..[[" value="]]..k..[["]]
if checked then
str=str..[[ checked]]
end
str=str..[[><label for="]]..id..[[">]]..box.tohtml(group.name)..[[</label><br>]]
return str
end
g_sameFonbookName = box.tohtml([[{?752:194?}]])
g_pb_err_no_memory = box.tohtml([[{?752:302?}]])
g_ajax = box.get.useajax or box.post.useajax or false
g_which= (box.get.which or box.post.which) or ""
if g_ajax then
if g_which==[[onlinetest]] then
local book=fon_book.read_online_book()
box.out(js.table(book))
elseif(g_which==[[group_init]]) then
read_data()
local online_pb=fon_book.read_online_book()
local elem, idx=fon_book.find_item(online_pb,"id",g_data.uid)
local saveset={}
cmtable.add_var(saveset,"ontel:settings/ontel"..tostring(idx-1).."/gcgroup_retrieve" ,"1")
err, msg = box.set_config(saveset)
elseif(g_which==[[group]]) then
read_data()
local online_pb=fon_book.read_online_book()
local elem, idx=fon_book.find_item(online_pb,"id",g_data.uid)
local groupdata={
state=box.query("ontel:settings/ontel"..tostring(idx-1).."/status"),
groups={}
}
if (groupdata.state=="0") then
groupdata.groups=general.listquery("ontel:settings/ontel"..tostring(idx-1).."/gcgroup/entry/list(enabled,id,selfId,name)")
g_groups = groupdata.groups
local str=""
local groups_selected = false
for k,group in ipairs(groupdata.groups) do
str=str..get_checkbox(k,group)
if (group.enabled == "1") then
groups_selected = true
end
end
groupdata.html =
[[
<input type="radio" name="groups_select" id="uiAllContacs" onclick="jxl.disableNode('uiGroups', true)" ]]..get_radio_checked(not groups_selected)..[[>
<label for="uiAllContacs">]]..box.tohtml([[{?752:760?}]])..[[</label>
<br>
<input type="radio" name="groups_select" value="groups" id="uiGroupSelect" onclick="jxl.disableNode('uiGroups', false)" ]]..get_radio_checked(groups_selected)..[[>
<label for="uiGroupSelect">]]..box.tohtml([[{?752:114?}]])..[[</label>
<div class="formular" id="uiGroups">
]]..str..
[[
</div>
]]
end
box.out(js.table(groupdata))
end
box.end_page()
end
read_data()
local function any_changes()
return (box.post.book_name ~= g_data.book.org_name) or (fon_book.is_online(g_data.uid) and ( box.post.email_address~=g_data.book.org_email_address or box.post.email_password~=g_data.book.org_email_password or g_data.provider=="google"))
end
local function add_save_foncontrol(saveset, bookid)
if g_data.foncontrol then
local webvar = "telcfg:settings/Foncontrol/%s/Phonebook"
for i, f in ipairs(g_data.foncontrol) do
local id = f.Id
if box.post["addtofon_" .. id] == id then
cmtable.add_var(saveset, webvar:format(f._node), bookid)
end
end
end
end
local function add_save_groups(saveset, idx)
if (g_data.provider=="google") then
local groupdata=general.listquery("ontel:settings/ontel"..idx.."/gcgroup/entry/list(enabled,id,selfId,name)")
for k,group in ipairs(groupdata) do
is_checked="0"
if box.post["addtogroup_"..k] then
is_checked="1"
end
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/gcgroup/entry"..tostring(k-1).."/enabled",is_checked)
end
end
end
if next(box.post) and (box.post.apply) then
if val.validate(g_val) == val.ret.ok then
local otherBook=fon_book.find_book_by_name(g_data.fonbooks,box.post.book_name,g_data.uid)
if otherBook then
g_errcode=1
else
--if (not g_data.is_new and
-- g_data.is_new=true
--end
if g_data.is_new then
if (box.post.action=="online") then
if g_data.online_test=="0" then
g_data.online_test="1"
elseif g_data.online_test=="1" then
if (g_data.online_state~="0") then
g_data.online_test="1"
else
g_data.online_test="0"
end
end
if box.post.book_name~=g_data.book.org_name then
g_data.online_test="1"
end
if box.post.email_address~=g_data.book.org_email_address then
g_data.online_test="1"
end
if box.post.email_password~=g_data.book.org_email_password then
g_data.online_test="1"
end
local saveset={}
local provider=fon_book.get_provider_by_id(box.post.provider)
if not provider then
http.redirect(href.get(g_back_to_page))
end
local err=0
local msg=""
local online_pb=fon_book.read_online_book()
local idx=0
if g_data.uid == "-1" or g_data.uid == -1 then
g_data.uid,idx=fon_book.Ontel_get_next_free_idx()
else
local elem, idx=fon_book.find_item(online_pb,"id",g_data.uid)
idx = idx - 1
end
if g_data.uid~=-1 then
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/enabled" ,"1")
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/id" ,g_data.uid)
if provider == "google" then
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/username", "")
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/password", "")
else
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/username" ,g_data.book.email_address)
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/password" ,g_data.book.email_password)
end
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/serviceid" ,provider.serviceId)
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/url" ,provider.url)
cmtable.add_var(saveset,"ontel:settings/ontel"..idx.."/pbname" ,g_data.book.name)
fon_book.set_akt_fonbook(g_data.uid)
add_save_foncontrol(saveset, tostring(g_data.uid))
err, msg = box.set_config(saveset)
else
err=1
msg=[[{?752:294?}]]
end
if err ~= 0 then
g_errmsg=general.create_error_div(err,msg)
else
if (g_data.online_test=="1") then
if g_data.provider == "google" then
http.redirect(href.get("/fon_num/fonbook_google_oauth2.lua",
http.url_param("ontelnode", "ontel" .. idx),
http.url_param("back_to_page", g_back_to_page)
))
else
local param = {}
param[1]="uid="..g_data.uid
param[2]='back_to_page='..box.glob.script
param[3]="is_new="..tostring(g_data.is_new)
http.redirect(href.get("/fon_num/fonbook_onlinetest.lua",unpack(param)))
end
else
http.redirect(href.get(g_back_to_page))
end
end
else
local copy_from="-1"
if (box.post.fonbook_entry and box.post.fonbook_entry~="" and tonumber(box.post.fonbook_entry)) then
copy_from=box.post.fonbook_entry
end
local new_uid = -1
g_errcode, new_uid = fon_book.create_fonbook(box.post.book_name,copy_from)
if g_errcode <= 0 then
fon_book.set_akt_fonbook(new_uid)
local saveset = {}
add_save_foncontrol(saveset, tostring(new_uid))
box.set_config(saveset)
http.redirect(href.get(g_back_to_page))
end
end
else
g_errcode = 0
if any_changes() then
g_errcode = fon_book.set_book_name(tonumber(g_data.uid), box.post.book_name)
if (fon_book.is_online(g_data.uid)) then
local online_pb=fon_book.read_online_book()
local elem, idx=fon_book.find_item(online_pb,"id",g_data.uid)
local saveset = {}
cmtable.add_var(saveset,"ontel:settings/ontel"..tostring(idx-1).."/pbname" ,box.post.book_name)
if g_data.provider ~= "google" then
cmtable.add_var(saveset,"ontel:settings/ontel"..(idx-1).."/username" ,g_data.book.email_address)
cmtable.add_var(saveset,"ontel:settings/ontel"..(idx-1).."/password" ,g_data.book.email_password)
end
if (g_data.provider=="google") then
local groupdata=general.listquery("ontel:settings/ontel"..tostring(idx-1).."/gcgroup/entry/list(enabled,id,selfId,name)")
for k,group in ipairs(groupdata) do
is_checked="0"
if box.post["addtogroup_"..k] then
is_checked="1"
end
cmtable.add_var(saveset,"ontel:settings/ontel"..tostring(idx-1).."/gcgroup/entry"..tostring(k-1).."/enabled",is_checked)
end
add_save_groups(saveset,idx)
end
local err, err2 =
box.set_config(saveset)
local param = {}
param[1]="uid="..g_data.uid
param[2]='back_to_page=/fon_num/fonbook_list.lua'
param[3]="is_new=false"
http.redirect(href.get("/fon_num/fonbook_onlinetest.lua",unpack(param)))
end
end
if g_errcode <= 0 then
http.redirect(href.get(g_back_to_page))
end
end
end
else
end
end
if (g_data.is_new) then
g_page_title = [[{?752:186?}]]
else
g_page_title = general.sprintf([[{?752:698?}]], box.tohtml(g_data.book.org_name))
end
function write_fonbooks_to_select()
box.out([[<select id="uiViewFonbooks" name="fonbook_entry">
<option value="tochoose" >]]..box.tohtml([[{?txtPleaseSelect?}]])..[[</option>]])
for i, elem in ipairs(g_data.fonbooks) do
if (not fon_book.is_online(elem.id)) then
box.out([[<option value="]]..box.tohtml(elem.id)..[["]])
if box.post.copy_from and box.post.fonbook_entry == tostring(elem.id) then
box.out([[ selected="selected"]])
end
box.out([[>]]..box.tohtml(elem.name)..[[</option>]])
end
end
box.out([[</select>]])
if (g_showError==1) then
box.out([[<p class="LuaSaveVarError">{?752:4?}</p>]])
end
end
function get_checked(which)
if which==[[online]] and (fon_book.is_online(g_data.uid) or box.post.action=="online") then
return [[checked="checked"]]
end
if which==[[userdef]] and (not fon_book.is_online(g_data.uid)or box.post.action=="userdef") then
return [[checked="checked"]]
end
return ""
end
function get_visible(visible)
if (not visible) then
return [[display:none]]
end
return ""
end
function get_copy_from_checked()
if box.post.copy_from then
return [[checked="checked"]]
end
return ""
end
function is_selected(which)
if (g_data.provider=="" and which=="none") or g_data.provider==which then
return [[ selected="selected"]]
end
return ""
end
function get_hidden(which)
local res=false
if which==[[online]] and (fon_book.is_online(g_data.uid) or box.post.action=="online") then
res=true
end
if which==[[userdef]] and (not fon_book.is_online(g_data.uid) or box.post.action=="userdef") then
res=true
end
return get_visible(res)
end
function write_fon_select()
if #g_data.foncontrol > 0 then
box.out([[<hr>]])
box.out([[<h4>]])
box.html([[{?752:762?}]])
box.out([[</h4>]])
box.out([[<div class="formular">]])
box.out([[<p>]])
box.html([[{?752:523?}]])
box.out([[</p>]])
for i, f in ipairs(g_data.foncontrol) do
if i > 1 then box.out([[<br>]]) end
local name = "addtofon_" .. f.Id
local id = "uiAddtofon_" .. f.Id
local checked = f.Phonebook == tostring(g_data.uid)
box.out([[<input type="checkbox"]])
box.out([[ name="]], name, [["]])
box.out([[ id="]], id, [["]])
box.out([[ value="]], f.Id, [["]])
if checked then box.out([[ checked]]) end
box.out([[>]])
box.out([[<label for="]], id, [[">]])
box.html(f.Name)
box.out([[</label>]])
end
box.out([[</div>]])
end
end
function is_diabled(val)
if val then
return [[disabled]]
end
return [[]]
end
function write_online(edit_provider)
if config.ONLINEPB then
if (fon_book.is_online(g_data.uid) or g_data.is_new) then
box.out([[
<div class="formular">
<div>
<input type="radio" name="action" value="online" id="uiActionOnline" onclick="OnChangeAction('online')" ]]..get_checked('online')..[[>
<label for="uiActionOnline">]]..box.tohtml([[{?752:769?}]])..[[</label>
</div>
</div>]])
local class=""
if g_data.is_new then
class="formular"
end
box.out([[<div class="]]..class..[["><div class="formular" id="uiBlockOnline" style="]]..get_hidden('online')..[[">]])
if (edit_provider) then
box.out([[<label for="uiProvider">]]..box.tohtml([[{?752:633?}]])..[[</label>]])
box.out([[<select size="1" id="uiProvider" name="provider">
<option ]]..is_selected('none') ..[[ value="tochoose">]]..box.tohtml([[{?txtPleaseSelect?}]])..[[</option>
<option ]]..is_selected('1u1') ..[[ value="1u1">1&amp;1 Internet</option>
<option ]]..is_selected('gmx') ..[[ value="gmx">GMX</option>
<option ]]..is_selected('google')..[[ value="google">Google</option>]])
if (config.oem=="kdg" and config.is_6360) then
box.out([[<option ]]..is_selected('kdg') ..[[ value="kdg">Kabelmail</option>]])
end
box.out([[<option ]]..is_selected('web') ..[[ value="web">WEB.DE</option>
</select>]])
else
box.out([[<label for="uiProvider" class="ShowPathLabel">]]..box.tohtml([[{?752:132?}]])..[[</label>]])
local provider = {
["gmx"]="GMX",
["1u1"]="1&amp;1 Internet",
["google"]="Google",
["web"]="WEB.DE",
["kdg"]="Kabelmail"
}
box.out([[<span class="ShowPathSmaller">]]..(provider[g_data.provider] or "&nbsp;")..[[</span><input type="hidden" id="uiProvider" name="provider" value="]]..(g_data.provider or "")..[[">]])
end
local hide_email = g_data.provider == "" or g_data.provider == "google"
box.out([[
<div id="uiShowEmailBlock"]]..(hide_email and [[ style="display:none;"]] or "")..[[>
<label for="uiViewEmailAddress">]]..box.tohtml([[{?752:162?}]])..[[:</label>
<input type="text" size="32" id="uiViewEmailAddress" name="email_address" value="]]..box.tohtml(g_data.book.email_address)..[[" ]]..val.get_attrs(g_val, "uiViewEmailAddress")..[[>]]
..val.get_html_msg(g_val, "uiViewEmailAddress")..[[
<br><label for="uiViewEmailPassword">]]..box.tohtml([[{?752:897?}]])..[[:</label>
<input type="text" size="32" id="uiViewEmailPassword" name="email_password" value="]]..box.tohtml(g_data.book.email_password)..[[" ]]..val.get_attrs(g_val, "uiViewEmailPassword")..[[ autocomplete="off">]]
..val.get_html_msg(g_val, "uiViewEmailPassword")..[[
</div>
</div></div>]])
end
end
end
function write_name()
box.out([[<label for="uiName">]]..box.tohtml([[{?752:439?}]])..[[</label><input id="uiName" name="book_name" value="]]..box.tohtml(g_data.book.name)..[[" size="32" ]]..val.get_attrs(g_val, "uiName")..[[>]]..val.get_html_msg(g_val, "uiName"))
if g_errcode > 0 then
local msg = g_sameFonbookName
if g_errcode == 7 then
msg = g_pb_err_no_memory
end
box.out([[<div class="form_input_note ErrorMsg">]]..msg..[[</div>]])
end
end
function write_contacts()
if (g_data.provider~="google") then
return
end
box.out([[<hr><h4>{?752:634?}</h4>
<p>{?752:997?}</p>]])
box.out([[<div id="uiGroupState" class="wait">
<div id="uiWaitTop">&nbsp;</div>
<p id="uiWaitCtrl" class="waitimg" title="{?752:809?}"><img id='uiImage' src='/css/default/images/wait.gif'></p>
<div id="uiWaitBottom">{?752:342?}</div>
</div>]])
box.out([[<p class="hintMsg">{?752:965?}</p><p>{?752:136?}</p>]])
end
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css">
<style>
.ShowPathSmaller {
width:202px;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<?lua
if not g_data.is_new then
box.out([[<div id="uiEditBlock">]])
if (fon_book.is_online(g_data.uid)) then
box.out([[<p>{?752:791?}</p>]])
else
box.out([[<p>]]..box.tohtml([[{?752:50?}]])..[[</p>]])
end
box.out([[<hr><div class="formular">]])
write_name()
box.out([[</div>]])
write_online(false)
box.out([[</div>]])
write_contacts()
else
box.out([[
<div id="uiNewBlock">
<p>]]..box.tohtml([[{?752:19?}]])..[[</p>]])
if (g_show_online_pb) then
box.out([[<p>]]..box.tohtml([[{?752:443?}]])..[[</p>]])
else
box.out([[<p>]]..box.tohtml([[{?752:55?}]]))
end
box.out([[<hr><div class="formular">]])
write_name()
if (g_show_online_pb) then
box.out([[<div>
<input type="radio" name="action" value="userdef" id="uiActionNew" onclick="OnChangeAction('userdef')" ]]..get_checked('userdef')..[[>
<label for="uiActionNew">]]..box.tohtml([[{?752:441?}]])..[[</label>
</div>
]])
else
box.out([[<div>
<input type="hidden" name="action" value="userdef" id="uiActionNew">
</div>
]])
end
box.out([[<div class="formular" id="uiBlockUserDef" style="]]..get_hidden('userdef')..[[">
<input type="checkbox" onclick="OnCopyFrom(this.checked)" id="uiViewCopyFrom" name="copy_from" ]]..get_copy_from_checked()..[[>
<label for="uiViewCopyFrom">]]..box.tohtml([[{?752:950?}]])..[[</label>
<br>
<div class="formular" id="uiFonBooks">
<label for="uiViewFonbooks">]]..box.tohtml([[{?752:944?}]])..[[</label>
]])
write_fonbooks_to_select()
box.out([[</div>
</div>
</div>]])
write_online(true)
box.out([[
</div>]])
write_fon_select()
end
if (g_errmsg) then
box.html(g_errmsg)
end
?>
<div id="btn_form_foot">
<input type="hidden" name="is_new" value="<?lua box.html(g_data.is_new) ?>">
<input type="hidden" name="uid" value="<?lua box.html(g_data.uid) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<button type="submit" name="apply" style="">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
box.out([[
var g_isNew = ]]..box.tojs(g_data.is_new)..[[;
var g_isOnline = ]]..box.tojs(fon_book.is_online(g_data.uid))..[[;
var g_Uid = ]]..box.tojs(g_data.uid)..[[;
var g_Provider = "]]..box.tojs(g_data.provider)..[[";
]])
?>
var g_cbCount=0;
var g_cbMaxCount=45;
var json = makeJSONParser();
var g_groupCount = <?lua box.js(#get_group_data()) ?>;
function OnChangeAction(action)
{
switch (action)
{
case "userdef":
break;
case "online":
break;
}
jxl.display("uiBlockUserDef",action=="userdef");
jxl.display("uiBlockOnline" ,action=="online");
return true;
}
function onProviderChange(evt) {
var p = jxl.getValue("uiProvider");
jxl.display("uiShowEmailBlock", p != "google" && p != "tochoose");
}
var g_txtWaiting = "{?752:999?}";
var g_txtSuccess="{?752:26?}";
var g_txtFault ="{?752:401?}";
var g_txtFault_Func ="{?752:563?}";
function cbRefresh(response)
{
if (response && response.status == 200)
{
var groupdata = json(response.responseText || "null");
if (groupdata)
{
var state=parseInt(groupdata.state,10);
var obj=jxl.get("uiWaitCtrl");
switch (state)
{
case 0:
//jxl.changeImage("uiImage","/css/default/images/finished_ok_green.gif");
if (obj)
{
obj.title=g_txtSuccess;
}
g_groupCount=0;
if (groupdata.groups && groupdata.groups.length>0)
{
g_groupCount=groupdata.groups.length;
jxl.removeClass("uiGroupState","wait");
jxl.addClass("uiGroupState","formular");
jxl.setHtml("uiGroupState",groupdata.html);
jxl.disableNode('uiGroups', !jxl.getChecked("uiGroupSelect"))
}
else
{
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
jxl.setText("uiWaitBottom", "{?752:8790?}");
}
return true;
case 2:
jxl.changeImage("uiImage","/css/default/images/wait.gif");
if (obj)
{
obj.title="{?752:398?}";
}
jxl.setText("uiWaitBottom", g_txtWaiting);
break;
case 13 :
case 14 :
case 15 :
case 16 :
case 17 :
case 18 :
case 19 :
case 20 :
case 21 :
case 22 :
case 127:
case 23 :
case 24 :
case 25 :
case 26 :
case -13:
case -12:
case -11:
case -10:
case -9 :
case -8 :
case -7 :
case -6 :
case -5 :
case -4 :
case -3 :
case -2 :
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=jxl.sprintf("{?752:843?}",state);
}
jxl.setText("uiWaitBottom", g_txtFault_Func);
return false;
case 1 : timeout
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=jxl.sprintf("{?752:363?}",state);
}
jxl.setText("uiWaitBottom", g_txtFault_Func);
return false;
case -1 :
case 8 :
case 9 :
case 10 :
case 11 :
case 12 :
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=jxl.sprintf("{?752:911?}",state);
}
jxl.setText("uiWaitBottom", g_txtFault_Func);
return false;
}
}
}
if (g_cbCount <= g_cbMaxCount)
{
window.setTimeout(GetGroupState, 1000);
}
else
{
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
if (obj)
{
obj.title=jxl.sprintf("{?752:616?}","TIMEOUT");
}
jxl.setText("uiWaitBottom", g_txtFault_Func);
return false;
}
g_cbCount++;
}
function GetGroupState(){
var my_url = "/fon_num/fonbook_edit.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&which=group&uid="+g_Uid;
ajaxGet(my_url, cbRefresh);
}
function OnCopyFrom(is_checked)
{
jxl.disableNode("uiFonBooks",!is_checked);
}
function validateGroupChecks(radio)
{
if (jxl.getChecked("uiGroupSelect"))
{
var groupsSelected = false;
for (var i = 1; i <= g_groupCount; i++)
{
if (jxl.getChecked("uiAddtogroup_" + i))
groupsSelected = true;
}
return !groupsSelected;
}
else
{
return false;
}
}
function uiDoOnMainFormSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
return true;
}
function cbWaitInit(response)
{
window.setTimeout(GetGroupState, 2000);
}
function GetContacts()
{
var my_url = "/fon_num/fonbook_edit.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&which=group_init&uid="+g_Uid;
ajaxGet(my_url, cbWaitInit);
}
function init()
{
jxl.addEventHandler("uiProvider", "change", onProviderChange);
if (!g_isNew && g_isOnline && g_Provider=="google")
{
GetContacts();
}
jxl.disableNode("uiFonBooks", !jxl.getChecked("uiViewCopyFrom"));
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
