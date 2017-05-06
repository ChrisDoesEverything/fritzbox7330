<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_dect.html"
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("config")
require("general")
require("fon_devices")
require("fon_devices_html")
require("fon_book")
require("http")
g_back_to_page = http.get_back_to_page( "/dect/dect_list.lua" )
g_menu_active_page = g_back_to_page
if (string.find(g_back_to_page,"assi")) then
g_page_type = "wizard"
end
popup_url=""
if config.oem == '1und1' then
if box.get.popup_url then
popup_url = box.get.popup_url
elseif box.post.popup_url then
popup_url = box.post.popup_url
end
end
function redirect_back()
http.redirect(href.get(g_back_to_page, http.url_param('popup_url', popup_url)))
end
g_ctlmgr = {}
function get_var()
g_ctlmgr.idx = ""
if box.post.idx and box.post.idx ~= "" then
g_ctlmgr.idx = box.post.idx
elseif box.get.idx and box.get.idx ~= "" then
g_ctlmgr.idx = box.get.idx
end
g_ctlmgr.device = {}
g_ctlmgr.device.incoming = {}
local fon_control_list = fon_devices.read_fon_control(true)
local l, device = fon_devices.find_elem(fon_control_list, "foncontrol", "idx", tonumber(g_ctlmgr.idx))
if not device then
redirect_back()
else
g_ctlmgr.device = device
end
g_ctlmgr.incoming_html_string = fon_devices_html.get_avail_numbers(g_ctlmgr.device)
g_page_title = [[{?8617:195?} ]]..g_ctlmgr.device.name
end
get_var()
g_val = {
prog = [[
not_empty(uiViewName/name, name_error)
char_range_regex(uiViewName/name, dectchar, name_error)
not_empty(uiViewFonbook/fonbook, name_error)
not_equals(uiOutNum/out_num, tochoose, outgoing_err)
]]
}
val.msg.name_error = {
[val.ret.notfound] = [[{?583:925?}]],
[val.ret.empty] = [[{?583:209?}]],
[val.ret.outofrange] = [[{?583:916?}]]
}
val.msg.outgoing_err = {
[val.ret.notfound] = [[{?583:96?}]],
[val.ret.equalerr] = [[{?583:982?}]]
}
if next(box.post) then
if box.post.button_save and val.validate(g_val) == val.ret.ok then
local saveset = {}
local msn_tbl = {}
msn_tbl[1] = ""
local out_nr = box.post.out_num
if out_nr ~= "tochoose" and out_nr ~= "" then
msn_tbl[1] = out_nr.."#"
end
if box.post.num_selection and box.post.num_selection == "all_nums" then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/RingOnAllMSNs", "1")
local inc_ind = 2
for i, number in ipairs(g_ctlmgr.device.incoming) do
if out_nr == number then
msn_tbl[1] = number
else
msn_tbl[inc_ind] = number
inc_ind = inc_ind + 1
end
end
else
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/RingOnAllMSNs", "0")
local inc_ind = 2
for i, number in ipairs(fon_devices_html.g_numbers) do
local incoming_nr = box.post["num_"..i]
if out_nr == incoming_nr then
msn_tbl[1] = incoming_nr
elseif incoming_nr and incoming_nr ~= "" then
msn_tbl[inc_ind] = incoming_nr
inc_ind = inc_ind + 1
end
end
end
for k=1, 10, 1 do
if msn_tbl[k] then
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MSN"..(k - 1).."/Number", msn_tbl[k])
else
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/MSN"..(k - 1).."/Number", "")
end
end
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Type", "0")
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Name", box.post.name)
cmtable.add_var(saveset, "telcfg:settings/Foncontrol/User"..g_ctlmgr.idx.."/Phonebook", box.post.fonbook)
local err, msg = box.set_config(saveset)
if err == 0 then
redirect_back()
else
box.out(general.create_error_div(err,msg))
end
get_var()
elseif box.post.button_cancel then
redirect_back()
end
end
function write_books()
local books = fon_book.get_book_list()
for i, book in ipairs(books) do
if book.name and book.id then
local selected = [[]]
if tostring(book.id) == g_ctlmgr.device.phonebook then
selected = [[ selected = "selected"]]
end
box.out([[<option value="]]..book.id..[["]]..selected..[[>]]..book.name..[[</option>]])
end
end
end
function write_name()
box.out(fon_devices_html.get_ipphone_name(g_data.device))
end
function write_numbers_out()
box.out(fon_devices_html.get_outgoing_numbers(g_ctlmgr.device.outgoing))
end
function write_numbers_in()
box.out(g_ctlmgr.incoming_html_string)
end
g_local_tabs = fon_devices_html.get_edit_dect_tabs(g_ctlmgr.idx, {back_to_page=g_back_to_page, popup_url=popup_url})
?>
<?include "templates/html_head.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<link rel="stylesheet" type="text/css" href="/css/default/wizard.css">]])
end
?>
<style type="text/css">
.extremnarrow .formular label { width: 100px; }
.extremnarrow .formular select,
.extremnarrow .formular input[type=text]{ width: 150px; }
.extremnarrow .formular input + label {
width: auto;
}
</style>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
end
?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/cookie.js"></script>
<script type="text/javascript">
<?lua
require("val")
val.write_js_error_strings()
?>
var g_all_ids = <?lua box.out(js.table(fon_devices_html.g_numbers))?>;
function uiDoOnMainFormSubmit()
{
<?lua
require("val")
val.write_js_checks(g_val)
?>
return true;
}
<?lua box.out(fon_devices_html.write_fon_js(fon_devices_html.get_num_by_id(g_ctlmgr.device.outgoing))) ?>
ready.onReady(val.init(uiDoOnMainFormSubmit, "button_save", "uiMainForm" ));
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div id="uiShowRufnummerKonfig" class="extremnarrow">
<p>
{?8617:174?}
</p>
<div id="uiShowUserName" class="formular">
<div>
<label for="uiViewName">{?8617:117?}</label>
<input type="text" value="<?lua box.out(g_ctlmgr.device.name) ?>" id="uiViewName" name="name" maxlength="19">
</div>
<div>
<label for="uiViewFonbook">{?txtTelefonbuch?}</label>
<select size="1" id="uiViewFonbook" name="fonbook">
<?lua write_books() ?>
</select>
</div>
</div>
<h4>{?g_txtOutgoingCalls?}</h4>
<div id="uiViewOutgoingNr" class="formular">
<label for="uiViewOutNr"></label>
<?lua write_numbers_out() ?>
</div>
<h4>{?g_txtIncomingCalls?}</h4>
<div id="uiViewIncomingNr" class="formular">
<?lua write_numbers_in() ?>
</div>
</div>
<div id="btn_form_foot">
<button type="submit" name="button_save" >{?txtApplyOk?}</button>
<button type="submit" name="button_cancel">{?txtCancel?}</button>
<input type="hidden" name="idx" value="<?lua box.html(g_ctlmgr.idx) ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<input type="hidden" name="popup_url" value="<?lua box.html(popup_url) ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
