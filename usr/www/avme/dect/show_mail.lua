<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_dect_email.html"
dofile("../templates/global_lua.lua")
require("general")
require("bit")
require("cmtable")
if next(box.post) and box.post.btn_new then
http.redirect(href.get("/dect/mail_edit.lua", 'back_to_page='..box.glob.script, 'MailId='..box.post.free_mail_id, 'newMailAccount=1'))
end
if next(box.post) and box.post.edit and box.post.edit~="" then
http.redirect(href.get("/dect/mail_edit.lua", 'back_to_page='..box.glob.script, 'MailId='..box.post.edit, 'newMailAccount=0'))
end
if next(box.post) and box.post.delete and box.post.delete~="" then
local ctlmgr_save={}
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..box.post.delete.."/Name", "")
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..box.post.delete.."/Pass", "")
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..box.post.delete.."/User", "")
cmtable.add_var(ctlmgr_save, "configd:settings/Mail"..box.post.delete.."/Server", "")
local err,msg = box.set_config(ctlmgr_save)
if err ~= 0 then
local criterr = general.create_error_div(err,msg,[[{?104:600?}]])
box.out(criterr)
end
end
function get_smtp_activ(mail)
if mail.SMTPactive == "1" then
return [[{?104:304?}]]
end
return [[{?104:88?}]]
end
function get_mail_notification(mail)
if mail.MWI=="1" then
return [[{?104:136?}]]
end
return [[{?104:522?}]]
end
function get_phones()
local tmp = general.listquery("dect:settings/Handset/list(Name,Subscribed,Manufacturer,User)")
local phones = {}
local cnt = 0
for i,v in ipairs(tmp) do
if v.Name ~= "" and v.Subscribed == "1" and v.Manufacturer:find("AVM") then
cnt = cnt + 1
phones[cnt] = {}
phones[cnt].name = v.Name
phones[cnt].subscribed = v.Subscribed
phones[cnt].manu = v.Manufacturer
phones[cnt].id = tonumber(v.User) or 0
end
end
return phones
end
function get_mail_fon(mail)
local phones = get_phones()
local bitmask = bit.issetlist(mail.Bitmap)
local cnt = 0
local str = [[]]
for i,phone in ipairs(phones) do
for j, bit in ipairs(bitmask) do
if bit == phone.id then
if cnt > 0 then str = str..", " end
str = str..phone.name
cnt = cnt + 1
end
end
end
return str
end
function get_buttons(mail)
local onclick = "showDeleteConfirm()"
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..mail.id, "edit", mail.id, [[{?txtIconBtnEdit?}]])..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..mail.id, "delete", mail.id, [[{?txtIconBtnDelete?}]], onclick)..[[</td>]]
end
g_akt_mail_cnt = 0
g_first_free_id = -1
function show_email_accounts()
local str = ""
g_mail = general.listquery("configd:settings/Mail/list(Name,SMTPactive,MWI,Bitmap,Server)")
for idx, mail in ipairs(g_mail) do
mail.id = idx - 1
if mail.Name~="" and mail.Server~="" then
str = str..[[<td>]]..box.tohtml(mail.Name)..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_smtp_activ(mail))..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_mail_notification(mail))..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_mail_fon(mail))..[[</td>]]
str = str..get_buttons(mail)..[[</tr>]]
g_akt_mail_cnt = g_akt_mail_cnt + 1
elseif mail.Name=="" and mail.Server=="" and g_first_free_id == -1 then
g_first_free_id = idx - 1
end
end
if g_akt_mail_cnt == 0 then
str = [[<tr><td colspan="6" class="txt_center">]]..box.tohtml([[{?104:384?}]])..[[</td></tr>]]
end
return str
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript">
function showDeleteConfirm()
{
return confirm("{?104:145?}");
}
</script>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" autocomplete="off">
<p>
{?104:580?}
</p>
<hr>
<h4>{?104:177?}</h4>
<div class="formular">
<table id="email_accounts" class="zebra">
<tr>
<th>{?104:858?}</th>
<th>{?104:861?}</th>
<th>{?104:158?}</th>
<th>{?104:886?}</th>
<th class="buttonrow"></th>
<th class="buttonrow"></th>
</tr>
<?lua box.out(show_email_accounts()) ?>
</table>
</div>
<div id="btn_form_foot">
<input type="hidden" name="free_mail_id" value="<?lua box.html(g_first_free_id)?>" />
<button type="submit" name="btn_new" id="btnNew" <?lua if g_first_free_id == -1 then box.out("disabled") end ?>>{?104:38?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
