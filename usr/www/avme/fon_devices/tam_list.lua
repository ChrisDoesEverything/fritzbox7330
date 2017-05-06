<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = 'hilfe_tam_list.html'
dofile("../templates/global_lua.lua")
require("http")
require("val")
require("general")
require("fon_devices")
require("foncalls")
require("cmtable")
if config.TIMERCONTROL then
require("timer")
g_timer_id = "uiTimer"
end
require("fon_devices_html")
require("menu")
if not menu.check_page("fon", "/fon_devices/tam_list.lua") then
require"http"
http.redirect("/home/home.lua")
end
g_val = {
prog = [[
end
]]
}
g_max_tam_cnt=5
g_data={}
g_data.has_timeplan={}
g_tab={
currtab = 1,
notabs = false,
pages = {{text = [[]],
shown = false,
tam_nr = 0,
tabid = "uiTab1",
enabled = false,
html = "",
html_content = ""},
{text = [[]],
shown = false,
tam_nr = 0,
tabid = "uiTab2",
enabled = false,
html = "",
html_content = ""},
{text = [[]],
shown = false,
tam_nr = 0,
tabid = "uiTab3",
enabled = false,
html = "",
html_content = ""},
{text = [[]],
shown = false,
tam_nr = 0,
tabid = "uiTab4",
enabled = false,
html = "",
html_content = ""},
{text = [[]],
shown = false,
tam_nr = 0,
tabid = "uiTab5",
enabled = false,
html = "",
html_content = ""}}
}
local filetype = {fax = "myfaxfile", tam = "myabfile"}
local function get_download_link(which, path)
return href.get([[/lua/photo.lua]], http.url_param(filetype[which], path))
end
function get_tabs(tab_idx,elem)
local str=""
if g_tab.notabs then return "" end
str=str..[[<ul class='tabs' id=']]..g_tab.pages[tab_idx].tabid..[['>]]
for i,p in ipairs(g_tab.pages) do
if (p.shown) then
if (p.enabled) then
if (i == tab_idx) then
str=str..[[<li class='active'>]]
else
str=str..[[<li>]]
end
str=str..[[<a href='javascript:onChangeView(]]..i..[[)'>]]
str=str..box.tohtml(p.text)
str=str..[[</a></li>]]
else
str=str..[[<li class='deactive'><span>]]
str=str..box.tohtml(p.text)
str=str..[[</span></li>]]
end
end
end
str=str..[[</ul><div class='clear_float'></div>]]
return str
end
function get_new(tam_msg)
if (tam_msg.new) then
return [[<img id="uiIsNew_]]..tostring(tam_msg.index)..[[" src="/css/default/images/tamcall_new.gif" >]]
end
return [[&nbsp;]]
end
function get_name(tam_msg)
return foncalls.number_display(tam_msg)
end
function get_msn_name(number)
return ""
end
function get_own_name(tam_msg)
local msn_name=get_msn_name(tam_msg.called_pty)
if msn_name~="" then
return tam_msg.msn_name
end
return tam_msg.called_pty
end
function get_play_btn(tam_msg)
local b_disabled=false
if tam_msg.path=="" then
b_disabled=true
end
return [[
<a href="]]..get_download_link("tam", tam_msg.path)..[[">]]..
general.get_icon_button("/css/default/images/icon_tamplay.png", "play_"..tam_msg.index, "play", tam_msg.index, [[{?1496:126?}]], [[onDownload(this);]], b_disabled)..
[[</a>]]
end
function get_buttons(tam_msg)
local str=[[<td class="buttonrow">]]
local onclick=""
local b_disabled=false
if (tam_msg.inBook==0 and tam_msg.number~="") then
onclick="OnAddToFonbook(this.value)"
str=str..general.get_icon_button("/css/default/images/icon_fonbook.gif", "fonbook_"..tam_msg.index, "fonbook", tam_msg.index, [[{?1496:215?}]], onclick, b_disabled)
end
str=str..[[</td><td class="buttonrow">]]
str=str..get_play_btn(tam_msg)
str=str..[[</td><td class="buttonrow">]]
onclick="OnDelete(this.value)"
str=str..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..tam_msg.index, "delete", tam_msg.index, TXT([[{?txtIconBtnDelete?}]]), onclick, b_disabled)
str=str..[[</td>]]
return str
end
function create_row(tam_msg)
local str=[[<tr>]]
str=str..[[<td>]]..get_new(tam_msg)..[[</td>]]
str=str..[[<td>]]..tam_msg.date..[[</td>]]
str=str..[[<td>]]..get_name(tam_msg)..[[</td>]]
str=str..[[<td>]]..get_own_name(tam_msg)..[[</td>]]
str=str..[[<td>]]..tam_msg.duration..[[</td>]]
str=str..get_buttons(tam_msg)
str=str..[[</tr>]]
return str
end
function add_tam_calls(elem)
local list,err=foncalls.GetTamCalls(elem.idx)
local str=[[<table id="uiTamCalls" class="zebra">]]
str=str..general.sprintf([[<tr class="thead"><th class="sortable"></th><th class="sortable">%1<span class="sort_no">&nbsp;</span></th><th class="sortable">%2<span class="sort_no">&nbsp;</span></th><th class="sortable">%3<span class="sort_no">&nbsp;</span></th><th class="sortable">%4<span class="sort_no">&nbsp;</span></th><th></th><th></th><th></th></tr>]],box.tohtml([[{?1496:457?}]]),
box.tohtml([[{?1496:40?}]]),
box.tohtml([[{?1496:179?}]]),
box.tohtml([[{?1496:434?}]])
)
elem.num_of_msg=#list
if #list==0 then
str=str..[[<tr><td colspan=8 class="txt_center">{?1496:351?}</td></tr>]]
else
for i,tam_msg in ipairs(list) do
str=str..create_row(tam_msg)
end
end
str=str..[[</table>]]
return str
end
function get_content(elem)
local str=[[]]
if (g_data.cnt==1) then
str=[[<h4>]]..box.tohtml(elem.name)..[[</h4>]]
else
str=[[<h4>]]..box.tohtml([[{?1496:539?}]])..[[</h4>]]
end
local led="switch_off"
local tam=[[{?1496:587?}, ]]
timer.read_tam(g_timer_id,elem.idx)
g_data.has_timeplan[elem.idx+1]=config.TIMERCONTROL and timer.is_tam_timeplan_enabled(g_timer_id)
if (g_data.has_timeplan[elem.idx+1]) then
tam=[[{?1496:564?}, ]]
if (elem.active) then
led="switch_on"
tam=tam..[[{?1496:632?}, ]]
else
tam=tam..[[{?1496:951?}, ]]
end
elseif (elem.active) then
led="switch_on"
tam=[[{?1496:562?}, ]]
elseif (elem.idx==255) then
led=""
tam=[[{?1496:622?}]]
end
local delay=[[{?1496:469?}]]
if (elem.ring_count==-1) then
delay=[[]]
elseif (elem.ring_count>0) then
delay=general.sprintf([[{?1496:58?}]],elem.ring_count)
end
local filetype, filepath = foncalls.get_path(elem)
str=str..[[<div>]]
if (elem.idx~=255) then
str=str..[[<a href="javascript:OnSwitch()">]]
end
str=str..[[<div id="uiSwitch]]..tostring(elem.idx+1)..[[" class="]]..led..[[ left">&nbsp;</div>]]
if (elem.idx~=255) then
str=str..[[</a>]]
end
str=str..[[<div><span id="uiTamState]]..tostring(elem.idx+1)..[[">]]..tam..[[</span><span>]]..delay..[[</span><div class="ShowBtnRight">]]
if (elem.idx~=255) then
str=str.. [[<button type="submit" name="option" value="]]..elem.idx..[[">]]..box.tohtml([[{?1496:147?}]])..[[</button>]]
end
str=str..[[</div></div></div>
<hr>
<h4>]]..
box.tohtml([[{?1496:970?}]])..
[[</h4>
<div>]]..
add_tam_calls(elem)
local is_disabled=[[]]
if elem.num_of_msg==0 then
is_disabled=[[disabled]]
end
str=str..[[<div class="btn_form"><button type="submit" name="delete_all" onclick="return OnDeleteAll();" ]]..is_disabled..[[ >]]..box.tohtml([[{?1496:804?}]])..[[</button></div>
</div>
]]
return str
end
function get_var()
fon_devices.create_tam_empty_timeplans()
g_tab.currtab = -1
g_tab.cur_tam_nr = -1
if (box.get and box.get["TamNr"]~=nil) then
g_tab.cur_tam_nr=tonumber(box.get["TamNr"]) or -1
elseif (box.post and box.post["TamNr"]~=nil) then
g_tab.cur_tam_nr=tonumber(box.post["TamNr"]) or -1
end
g_data.tamlist, g_data.cnt=fon_devices.read_tam(false,true)
if (g_data.cnt>1) then
for i,elem in ipairs(g_data.tamlist) do
g_tab.pages[i].enabled=true
g_tab.pages[i].shown=true
g_tab.pages[i].text=elem.name
g_tab.pages[i].tam_nr=elem.idx
if (g_tab.currtab==-1) then
g_tab.currtab=i
end
if (g_tab.cur_tam_nr == -1) then
g_tab.cur_tam_nr = elem.idx
end
if elem.idx==g_tab.cur_tam_nr then
g_tab.currtab = i
end
end
for i,elem in ipairs(g_data.tamlist) do
g_tab.pages[i].html=get_tabs(i,elem)
g_tab.pages[i].html_content=get_content(elem)
end
else
local elem = { active=false, ring_count=0, path="", idx=0 ,name=[[{?1496:142?}]]}
if (g_data.cnt==1) then
elem = g_data.tamlist[1]
end
g_tab.notabs = true
g_tab.currtab=1
g_tab.cur_tam_nr = elem.idx
g_tab.pages[1].tam_nr=elem.idx
g_tab.pages[1].text=elem.name
g_tab.pages[1].html_content=get_content(elem)
end
end
get_var()
function get_tam_entry_by_idx(list,idx)
for i,val in ipairs(list) do
if val.index==idx then
return val
end
end
return nil
end
if next(box.post) then
if box.post.btn_cancel then
elseif box.post.option then
http.redirect(href.get("/fon_devices/edit_tam.lua","TamNr="..box.post.option,"back_to_page=/fon_devices/tam_list.lua"))
elseif box.post.fonbook then
local list,err=foncalls.GetTamCalls(tonumber(box.post.TamNr))
local foncall=get_tam_entry_by_idx(list,tonumber(box.post.fonbook))
if foncall then
http.redirect(fon_book.addnum_link(foncall.number, foncall.name))
end
elseif box.post.play then
elseif box.post.delete then
local tam_nr=tonumber(box.post.TamNr) or -1
local del_idx=tonumber(box.post.delete) or -1
if (tam_nr>-1 and del_idx>-1) then
foncalls.DeleteTamCall(tam_nr,del_idx)
end
get_var()
elseif box.post.delete_all then
local tam_nr=tonumber(box.post.TamNr) or -1
if (tam_nr>-1) then
foncalls.DeleteTamCall(tam_nr,-1)
end
get_var()
end
end
function write_tabs(idx)
box.out(g_tab.pages[idx].html)
end
function write_page(idx)
box.out(g_tab.pages[idx].html_content)
end
function write_tam_pages()
box.out([[<input type="hidden" id="uiCurTab" name="TamNr" value="]])
box.html(math.max(g_tab.cur_tam_nr, 0))
box.out([[">]])
if (g_data.cnt==0) then
box.out([[<div id="uiTamPageEmpty">]])
local elem={active =false,
ring_count=-1,
idx =255
}
box.out(get_content(elem))
box.out([[</div>]])
return
end
for i=1,g_data.cnt,1 do
local str=[[<div id="uiTamPage]]..tostring(i)
if (g_tab.pages[i].tam_nr~=g_tab.cur_tam_nr) then
str=str..[[" style="display:none; ]]
end
str=str..[[">]]
box.out(str)
write_tabs(i)
write_page(i)
box.out([[</div>]])
end
end
g_ajax = false
g_cur_tab = -1
g_idx = -1
if box.get.useajax then
g_ajax = true
g_cur_tab=tonumber(box.get.TamNr) or -1
g_idx=tonumber(box.get.idx) or -1
end
if box.post.useajax then
g_ajax = true
g_cur_tab=tonumber(box.post.TamNr) or -1
g_idx=tonumber(box.post.idx) or -1
end
if g_ajax and g_cur_tab~=-1 and g_idx~=-1 then
foncalls.SetFlagOnTamCall(g_cur_tab,g_idx)
box.out([[{"state":1,"cur_idx":]]..box.tojs(g_cur_tab+1)..[[}]])
box.end_page()
elseif g_ajax and g_cur_tab~=-1 and box.get.switch=="toggle" then
local elem=fon_devices.get_tam_elem(g_data.tamlist,g_tab.pages[g_cur_tab+1].tam_nr)
local new_val=""
if (elem.active) then
new_val="0"
box.out([[{"switch_on":false,"cur_idx":]]..box.tojs(g_cur_tab+1)..[[}]])
else
new_val="1"
box.out([[{"switch_on":true,"cur_idx":]]..box.tojs(g_cur_tab+1)..[[}]])
end
local idx=tostring(g_tab.pages[g_cur_tab+1].tam_nr)
local saveset={}
cmtable.add_var(saveset,"tam:settings/TAM"..idx.."/Active",new_val)
local err, msg = box.set_config( saveset)
box.end_page()
elseif g_ajax then
box.out([[{"error":"wrong Parameter"}]])
box.end_page()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.left {
margin-right:10px;
float:left;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>">
<p>{?1496:364?}</p>
<?lua
if g_data.cnt >= 0 and g_data.cnt<g_max_tam_cnt then
local new_tam=[[{?1496:259?}]]
if g_data.cnt ==0 then
new_tam=[[{?1496:737?}]]
end
box.out([[
<div class="btn_form">
<a href="]]..href.get([[/assis/assi_tam_intern.lua]],[[New_DeviceTyp=IntTam]],[[HTMLConfigAssiTyp=FonOnly]],[[Submit_Next=]],[[FonAssiFromPage=tam_list]])..[[">]]..new_tam..[[</a>
</div>]]
)
end
box.out([[<hr>]])
?>
<div>
<?lua
write_tam_pages()
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/tamplay.js"></script>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript">
var sort=sorter();
<?lua
val.write_js_error_strings()
?>
var g_cur_idx=<?lua box.js(g_tab.currtab)?>;
var g_has_timeplan=<?lua box.out(js.table(g_data.has_timeplan))?>;
var g_idx=-1;
function onChangeView(new_idx)
{
jxl.hide("uiTamPage"+g_cur_idx);
jxl.show("uiTamPage"+new_idx);
g_cur_idx=new_idx;
jxl.setValue("uiCurTab",g_cur_idx-1);
}
function OnAddToFonbook(val)
{
}
var json_browse = makeJSONParser();
function cbToggle(response)
{
if (response && response.status == 200)
{
var resp = json_browse(response.responseText);
if (resp)
{
var idx = resp.cur_idx-1;
var new_class = "switch_off";
if (idx < 0) idx=0;
if (resp.switch_on)
{
new_class = "switch_on";
jxl.removeClass("uiSwitch"+resp.cur_idx,"switch_off");
var tam="{?1496:925?}, ";
if (g_has_timeplan[idx])
{
tam="{?1496:520?}, ";
tam=tam+"{?1496:196?}, ";
}
jxl.setText("uiTamState"+resp.cur_idx,tam);
}
else
{
jxl.removeClass("uiSwitch"+resp.cur_idx,"switch_on");
var tam="{?1496:49?}, ";
if (g_has_timeplan[idx])
{
tam="{?1496:193?}, ";
tam=tam+"{?1496:393?}, ";
}
jxl.setText("uiTamState"+resp.cur_idx,tam);
}
jxl.addClass("uiSwitch"+resp.cur_idx,new_class);
}
}
}
function OnSwitch()
{
var my_url = "/fon_devices/tam_list.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&TamNr="+(g_cur_idx-1)+"&switch=toggle";
ajaxGet(my_url, cbToggle);
}
function onNumEditSubmit()
{
<?lua
val.write_js_checks(g_val)
?>
}
function setTamFlag(btn) {
g_idx=btn.value;
jxl.hide("uiIsNew_"+g_idx);
window.setTimeout(doRequestSetFlag, 500);
}
function onDownload(btn) {
var a = jxl.findParentByTagName(btn, "a");
if (a) {
setTamFlag(btn);
if (jxl.hasClass(btn, "audio")) {
return false;
}
if (a.click) {
a.click();
return false;
}
}
}
function OnDelete(val)
{
if (confirm("{?1496:528?}"))
return true;
return false;
}
function OnDeleteAll()
{
if (confirm("{?1496:222?}"))
return true;
return false;
}
function cbAnswer(response)
{
}
function doRequestSetFlag()
{
var my_url = "/fon_devices/tam_list.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&TamNr="+(g_cur_idx-1)+"&idx="+g_idx;
g_idx=-1
ajaxGet(my_url, cbAnswer);
}
function initTableSorter() {
sort.init("uiTamCalls");
//sort.setDirection(0,-1);
//sort.sort_table(0);
}
ready.onReady(initTableSorter);
ready.onReady(function(){initAudio("play");});
ready.onReady(val.init(onNumEditSubmit, "btnSave", "main_form" ));
</script>
<?include "templates/html_end.html" ?>
