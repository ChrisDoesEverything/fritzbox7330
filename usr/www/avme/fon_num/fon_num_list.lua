<?lua
g_page_type = "all"
--[=[
if box.post.fonNumMode == "asall" or box.get.fonNumMode == "asall" or
box.post.fonNumMode == "asint" or box.get.fonNumMode == "asint" then
g_page_type = "wizard"
end
]=]
g_page_title = ""
g_page_help = "hilfe_fon_internetliste.html"
dofile("../templates/global_lua.lua")
require("http")
require("fon_numbers")
require("general")
g_errormsg = nil
g_back_to_page = http.get_back_to_page([[/fon_num/fon_num_list.lua]])
g_page = {}
g_page.mode = box.post.fonNumMode or box.get.fonNumMode
if g_print_mode then
g_page.mode = "print"
end
g_page.mode = g_page.mode or "nor"
if g_page.mode == "asall" or g_page.mode == "asint" or g_page.mode == "asfirst" then
g_page_type = "wizard"
end
if g_page.mode == "print" then
g_page_title = box.tohtml([[{?990:80?}]])
g_page.head = ""
g_page.foot = ""
elseif g_page.mode == "asall" or g_page.mode == "asint" then
g_page_title = box.tohtml([[{?990:527?}]])
g_page.head = [[<div>
<p>]]..box.tohtml([[{?990:813?}]])..[[</p>
<hr>
</div>]]
g_page.foot = [[<div id="btn_form_foot">]]
local btn_txt = [[{?990:362?}]]
if g_page.mode == "asint" then
local txt_change = config.oem == "kdg" and config.DOCSIS
if not txt_change then
btn_txt = [[{?990:108?}]]
end
end
if fon_numbers.check_create_new_number_possible() then
g_page.foot = g_page.foot..[[<button type="submit" name="btn_new_num" id="btnNewNum">]]..box.tohtml(btn_txt)..[[</button>]]
end
g_page.foot = g_page.foot..[[<button type="submit" name="cancel" class="nocancel">]]..box.tohtml([[{?990:377?}]])..[[</button></div>]]
elseif g_page.mode == "asfirst" then
local show_wlan_first = config.WLAN and general.wlan_active()
if show_wlan_first then
g_page_title = box.tohtml([[{?990:432?}]])
else
g_page_title = box.tohtml([[{?990:517?}]])
end
local btn_txt = box.tohtml([[{?990:882?}]])
local desc_txt = box.tohtml([[{?990:806?}]])
g_page.head = [[<h4>]]..btn_txt..[[</h4>
<div class="formular">
<p>]]..desc_txt..[[</p>]]
if fon_numbers.check_create_new_number_possible() then
g_page.foot = [[<div class="btn_form"><button type="submit" name="btn_new_num" id="btnNewNum">]]..btn_txt..[[</button></div>]]
end
if show_wlan_first then
g_page.foot = g_page.foot..[[</div>
<div id="btn_form_foot">
<button type="submit" name="leave">]]
..box.tohtml([[{?990:407?}]])
..[[</button>
<button type="submit" name="cancel">]]
..box.tohtml([[{?txtCancel?}]])
..[[</button>
</div>]]
else
g_page.foot = g_page.foot..[[</div><hr>
<h4>]]..box.tohtml([[{?990:442?}]])..[[</h4>
<div class="formular">
<p>]]..box.tohtml([[{?990:230?}]])..[[</p>
<div class="btn_form"><button type="submit" name="cancel" class="nocancel">]]..box.tohtml([[{?990:177?}]])..[[</button></div>
</div>]]
end
else -- "nor"
g_page.head = [[<div>
<p>]]..box.tohtml([[{?990:228?}]])..[[</p>
<hr>
</div>]]
g_page.foot = [[<div id="btn_form_foot">
<button type="button" name="print" onclick="uiDoShowPrintView()">]]..box.tohtml([[{?990:338?}]])..[[</button>]]
if fon_numbers.check_create_new_number_possible() then
g_page.foot = g_page.foot..[[<button type="submit" name="btn_new_num" id="btnNewNum">]]..box.tohtml([[{?990:282?}]])..[[</button>]]
end
g_page.foot = g_page.foot..[[</div>]]
end
function get_var()
g_num_tab = fon_numbers.get_all_numbers()
g_phone_line_avail = fon_numbers.is_fixed_line_avail()
end
if next(box.post) then
if box.post.edit and box.post.edit~="" then
if string.find(box.post.edit, "msn", 1, true) == 1 or string.find(box.post.edit, "pots", 1, true) == 1 then
http.redirect(href.get('/fon_num/msn_pots_edit.lua', 'num_uid='..box.post.edit, 'fonNumMode='..g_page.mode))
elseif string.find(box.post.edit, "sip", 1, true) == 1 then
http.redirect(href.get('/fon_num/sip_edit.lua',
'fonNumMode='..g_page.mode,
'uid='..box.post.edit
))
elseif string.find(box.post.edit, "mobile_msn", 1, true) == 1 then
http.redirect(href.get('/internet/umts_settings.lua'))
end
elseif box.post.btn_new_num then
local configure="configure=all"
local parent = box.glob.script
local params={}
if "" ~= g_back_to_page then
parent = g_back_to_page
end
if g_page.mode == "asint" then
table.insert(params, http.url_param('configure', "inet"))
table.insert(params, http.url_param('pagemaster', "fondevices_list"))
end
if g_page.mode == "asfirst" then
table.insert(params, http.url_param('configure', "first"))
table.insert(params, http.url_param('pagemaster', "fondevices_list"))
end
table.insert(params, http.url_param('FonAssiFromPage', "fonerweitert"))
table.insert(params, http.url_param('page_mode',g_page.mode))
table.insert(params, http.url_param('back_to_page',parent))
http.redirect(href.get("/assis/assi_fon_nums.lua",unpack(params) ))
elseif box.post.delete and box.post.delete~="" then
local err,msg = fon_numbers.del_number_by_UID(box.post.delete)
if err ~= 0 then
g_errormsg = general.create_error_div(err,msg)
end
elseif box.post.cancel then
if "" == g_back_to_page and ( g_page.mode == "asall" or g_page.mode == "asint" or g_page.mode == "asfirst" ) then
g_back_to_page = '/assis/home.lua'
end
http.redirect(href.get( g_back_to_page ))
elseif box.post.leave then
http.redirect(href.get("/assis/wlan_first.lua"))
elseif box.post.btn_print then
end
end
get_var()
function tabi(tab)
for i, v in pairs(tab) do
if type(v) == "table" then
tabi(v)
else
if i == "idx" then
box.out("<br>")
end
box.out(tostring(i)..": "..tostring(v).."<br>")
end
end
end
require("fon_devices")
local devs, dev_cnt = fon_devices.get_all_fon_devices()
function check_active(num)
local tmp = [[<td class="iconrow_ext]]
if not num or (num.type == "sip" and ( not num.active or not num.registered )) or
((num.type == "msn" or num.type == "pots") and not g_phone_line_avail ) then
tmp = tmp..[[ led_gray">]]
else
tmp = tmp..[[ led_green">]]
end
return tmp..[[</td>]]
end
function get_ID(num)
local str = ""
local numid = ""
if num.type == "sip" and tonumber(num.telcfg_id) then
numid = tonumber(num.telcfg_id)
if numid == 9 then
numid = 0
else
numid = numid+1
end
str = "*12"..tostring(numid).."#"
elseif (num.type == "msn" or num.type == "pots") then
if num.type == "pots" then
str = "*10#"
elseif tonumber(string.sub(num.id, 4)) then
numid = tonumber(string.sub(num.id, 4))
if numid == 9 then
numid = 0
else
numid = numid+1
end
str = "*11"..tostring(numid).."#"
end
elseif num.type == "mobile_msn" then
str = "*13#"
end
return str
end
function get_provider(num)
local str = ""
if num.type == "sip" then
str = tostring(num.provider)
end
return str
end
function get_type(num)
local str = ""
if num.type == "sip" then
str = [[{?990:211?}]]
elseif num.type == "mobile_msn" then
str = [[{?990:957?}]]
else
str = [[{?990:424?}]]
end
return str
end
function get_buttons(num)
local delete_disabled = (num.type == "sip" or num.type == "mobile_msn") and not num.deletable
local edit_disabled = delete_disabled and not general.is_expert()
local onclick = [[delConfirmation(']]..box.tojs(box.tohtml(num.number))..[[')]]
if (delete_disabled and config.oem=="kdg") then
if (general.is_expert()) then
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..num.uid, "edit", num.uid, [[{?txtIconBtnEdit?}]], "", edit_disabled)..[[</td>
<td class="buttonrow">&nbsp</td>]]
end
return [[<td class="buttonrow">&nbsp</td><td class="buttonrow">&nbsp</td>]]
end
if (delete_disabled) then
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..num.uid, "edit", num.uid, [[{?txtIconBtnEdit?}]], "", edit_disabled)..[[</td>
<td class="buttonrow">&nbsp</td>]]
end
return [[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..num.uid, "edit", num.uid, [[{?txtIconBtnEdit?}]], "", edit_disabled)..[[</td>
<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..num.uid, "delete", num.uid, [[{?txtIconBtnDelete?}]], onclick, delete_disabled)..[[</td>]]
end
function create_fon_num_table()
local str = ""
if g_num_tab and g_num_tab.numbers and g_num_tab.number_count > 0 then
for idx, num in ipairs(g_num_tab.numbers) do
str = str..[[<tr>]]..check_active(num)
str = str..[[<td title="]]..box.tohtml(tostring(num.name))..[[">]]..box.tohtml(tostring(num.number))..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_type(num))..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_provider(num))..[[</td>]]
str = str..[[<td>]]..box.tohtml(get_ID(num))..[[</td>]]
if not g_print_mode then
str = str..get_buttons(num)
end
str = str..[[</tr>]]
end
else
str = [[<tr><td colspan="7" class="txt_center">]]..box.tohtml([[{?990:352?}]])..[[</td></tr>]]
end
return str
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
<?lua
box.out(g_page.head)
?>
<table id="uiViewFonNumTable" class="zebra">
<tr class="thead">
<th class="sortable sort_by_class iconrow_ext">{?990:931?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?990:724?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?990:922?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?990:81?}<span class="sort_no">&nbsp;</span></th>
<th class="sortable">{?990:84?}<span class="sort_no">&nbsp;</span></th>
<?lua
if not g_print_mode then
box.out([[<th class="buttonrow"></th>
<th class="buttonrow"></th>]])
end
?>
</tr>
<?lua box.out(create_fon_num_table()) ?>
</table>
<?lua
if g_errormsg ~= nil then
box.out([[<div>]]..g_errormsg..[[</div>]])
end
if box.post.fonNumMode or box.get.fonNumMode then
box.out([[<input type="hidden" name="fonNumMode" value="]]..box.tohtml(g_page.mode)..[[">]])
end
box.out([[<input type="hidden" name="back_to_page" value="]]..box.tohtml(g_back_to_page)..[[">]])
box.out(g_page.foot)
?>
</form>
<?include "templates/page_end.html" ?>
<?lua
if g_page_type == "wizard" then
box.out([[<script type="text/javascript" src="/js/wizard.js?lang="]],config.language,[["></script>]])
box.out([[<script type="text/javascript" src="/js/dialog.js"></script>]])
end
?>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
function delConfirmation(number)
{
return confirm('{?990:849?} "'+number+'" {?990:484?}');
}
function uiDoShowPrintView() {
var url = "<?lua href.write( box.glob.script,'stylemode=print','popupwnd=1') ?>";
var ppWindow = window.open(url, "Zweitfenster", "width=815,height=600,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
function initTableSorter() {
sort.init("uiViewFonNumTable");
sort.sort_table(0);
}
ready.onReady(initTableSorter);
</script>
<?include "templates/html_end.html" ?>
