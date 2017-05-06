<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require("http")
require("menu")
if not menu.check_page("fon", "/fon_devices/fax_send.lua") then
http.redirect(http.get_back_to_page())
end
require("val")
require("fon_book")
require("date")
require("html")
require("general")
fax = require ("libfaxsendlua")
g_ajax = box.get.useajax or box.post.useajax or false
if g_ajax then
if box.post.query=="refresh" or box.get.query=="refresh" then
local state=fax.get_send_fax_status()
if (state) then
box.out(js.table(state))
else
state={ state=-1,
progress=0
}
box.out(js.table(state))
end
elseif box.post.query=="KeepAlive" or box.get.query=="KeepAlive"then
box.out("keep waiting")
end
box.end_page()
end
g_val = {
prog = [[
not_empty(uiViewDestNum/dest_num, error_txt_num)
char_range_regex(uiViewDestNum/dest_num, fonnumex, error_txt_num)
end
]]
}
val.msg.error_txt_num = {
[val.ret.empty] = [[{?113:49?}]],
[val.ret.outofrange] = [[{?113:608?}]]
}
g_errormsg = nil
g_data={}
function get_var()
g_data.fax_number=""
g_data.headline=box.query([[telcfg:settings/FaxSenderShort]])
g_data.from_name=box.query([[telcfg:settings/FaxSenderLong]])
g_data.active=box.query([[telcfg:settings/FaxMailActive]])
require("fon_devices")
g_data.fax_device=fon_devices.read_fax_intern()
g_data.fax_receive=g_data.active~="0" and g_data.active~=""
g_data.fax_send=g_data.fax_receive
if (g_data.active~="0" and #g_data.fax_device>0 and #g_data.fax_device[1].incoming==0) then
g_data.fax_send=false
end
g_data.fax_progress=false
if (box.post.progress and box.post.progress=="start" )or (box.get.progress and box.get.progress=="start") then
g_data.fax_progress=true
g_tab_options.notabs = g_data.fax_progress
end
end
get_var()
if next(box.post) then
if box.post.btn_cancel then
http.redirect(href.get('/fon_devices/fax_send.lua'))
elseif box.post.btn_continue then
http.redirect(href.get('/fon_devices/fax_send.lua'))
elseif box.post.btn_send then
if (g_data.fax_progress) then
else
g_errormsg=general.create_error_div(100,[[{?113:443?}]])
end
end
end
g_pb = fon_book.read_fonbook(0, 0, "name")
local function get_uid()
if box.post.choose == "uid" then
return box.post.uid or ""
end
return box.post.choose or "new"
end
function get_entry_select(uid)
local sel = html.select{name = "fonbook", id = "uiFonbook", onchange="OnChange(this.value)", onblur="OnBlur(this)",style="display:none"}
sel.value = uid ~= "new" and uid or ""
sel.add(
html.option{value = "choose", selected="selected", [[{?113:32?}]]}
)
sel.add(
html.option{value = "manu", [[{?113:181?}]]}
)
if (g_pb~=nil) then
for i, entry in ipairs(g_pb) do
if (entry.numbers~=nil) then
for x, num in ipairs(entry.numbers) do
if (num.type=="fax_work" or num.type=="fax_home") then
sel.add(
html.option{value = entry.uid.."_"..tostring(x-1), entry.name}
)
end
end
end
end
end
return sel
end
local function get_book_btn()
local txt = [[{?113:774?}]]
return [[
<button type="button" class="icon" name="book" title="]]
.. box.tohtml(txt)
.. [[" onclick="OnViewFonbook(this);return false;">]]
.. [[<img src="/css/default/images/fonbuch.gif">]]
.. [[</button>
]]
end
function write_radio_uid_select()
local uid = get_uid()
html.div{class = "",
html.label{['for']="uiViewDest",[[{?113:947?}]]},
html.span{class="btn_align", html.raw(get_book_btn())},
html.br{},
html.label{['for']="uiViewDest",[[{?113:870?}]]},
get_entry_select(uid),
html.input{name="dest_name", id = "uiViewDest",type="text",size="30",maxlength="40",class=val.get_error_class(g_val,"uiViewDest")}
}.write()
end
function write_faxblock(faxblock)
if (faxblock==0 and g_data.fax_send) then
box.out([[display:none;]])
elseif (faxblock==1 and (not g_data.fax_send or g_data.fax_progress)) then
box.out([[display:none;]])
elseif (faxblock==2 and not g_data.fax_progress) then
box.out([[display:none;]])
end
end
function write_visible(buttonblock)
if (buttonblock==1 and ( not g_data.fax_send or g_data.fax_progress)) or
(buttonblock==0 and (not g_data.fax_send or not g_data.fax_progress)) then
box.out([[display:none]])
end
end
function write_mode()
if g_data.fax_progress then
box.out([[fax_progress]])
elseif g_data.fax_send then
box.out([[fax_write]])
else
box.out([[fax_not_configured]])
end
end
function write_configured_faxnr()
if g_data.fax_send then
local sel = html.select{name = "src_num", id = "uiViewFromNum"}
for i, num in ipairs(g_data.fax_device[1].incoming) do
sel.add(
html.option{value = num, num}
)
end
sel.write()
end
end
function get_link_to_edit_page()
return href.get("/fon_devices/edit_fax_num.lua","back_to_page=/fon_devices/fax_send.lua")
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.row {
padding-top:5px;
padding-bottom:5px;
}
.left {
float:left;
}
.wait_progress,
.right {
float:right;
margin-right:10px;
}
.left_and_right {
clear:both;
}
.formular .left_and_right input,
.formular .left_and_right textarea {
width:615px;
}
.formular label {
width:90px;
vertical-align:top;
}
.formular input,textarea {
width:230px;
}
.formular textarea {
font-family:"MS Shell Dlg";
font-size:13px;
}
.formular select {
width:235px;
}
#uiCanvasDiv {
display:none;
}
.btn_align {
display: inline-block;
vertical-align: middle;
}
.thumb {
height: 75px;
border: 1px solid #000;
margin: 10px 5px 0 0;
}
</style>
<?include "templates/page_head.html" ?>
<form id="main_form" method="POST" action="<?lua href.write(box.glob.script) ?>" >
<div class="formular" style="<?lua write_faxblock(0)?>" >
<p>
{?113:342?}
</p>
<p class="innerbutton">
<?lua
--local dest=href.get([[/fon/fondevices.lua]])
if (g_data.fax_send~=g_data.fax_receive) then
box.out(general.sprintf([[{?113:141?}]],[[<a href="]]..get_link_to_edit_page()..[[">]],[[</a>]]))
else
local dest=href.get([[/assis/assi_fax_intern.lua]],[[New_DeviceTyp=IntFax]],[[HTMLConfigAssiTyp=FonOnly]],[[Submit_Next=]],[[FonAssiFromPage=fax_send]])
box.out(general.sprintf([[{?113:13?}]],[[<a href="]]..dest..[[">]],[[</a>]]))
end
?>
</p>
</div>
<div style="<?lua write_faxblock(1)?>" >
<div class="formular" >
<div class="left">
<div>
<?lua
write_radio_uid_select()
?>
</div>
<div>
<label for="uiViewDestNum">{?113:909?}</label>
<input type="text" size="30" maxlength="40" id="uiViewDestNum" name="dest_num" value="" <?lua val.write_attrs(g_val, "uiViewDestNum") ?>>
<?lua val.write_html_msg(g_val, "uiViewDestNum") ?>
</div>
</div>
<div class="right">
<div>
<label for="uiViewFrom1">{?113:561?}</label>
<textarea cols="22" rows="3" maxlength="250" id="uiViewFrom1" name="from1"><?lua box.out(g_data.from_name)?></textarea>
</div>
<div>
<label for="uiViewsSendFrom">{?113:944?}</label>
<?lua
write_configured_faxnr()
?>
</div>
<div>
<label for="uiDate">{?113:179?}</label>
<input type="text" size="30" maxlength="40" id="uiDate" name="from_num" value="<?lua box.out(date.get_current_timestr())?>" disabled>
</div>
</div>
</div>
<div class="clear_float"></div>
<hr>
<div class="formular">
<div class="row">
<div class="left_and_right">
<label for="uiViewSubject">{?113:856?}</label>
<input type="text" size="30" maxlength="40" id="uiViewSubject" name="subject" value="">
</div>
</div>
<div class="row">
<div class="left_and_right">
<label for="uiViewFaxText">{?113:554?}</label>
<textarea cols="74" rows="20" maxlength="" id="uiViewFaxText" name="fax_text"></textarea>
<div id="uiCanvasDiv"><canvas id="uiCanvasContain" width="1728" height="2444"></canvas></div>
</div>
</div>
<div id="uiProgress" class="wait_progress">
&nbsp;
</div>
<div class="row" id="uiFileAttachment">
<div class="left_and_right">
<p>
<output id="uiThumbList"></output>
</p>
<label for="uiFile">{?113:716?}</label>
<input type="file" id="uiFile" size="70" accept="image/*">
</div>
</div>
</div>
<div class="clear_float"></div>
<?lua
if g_errormsg ~= nil then
box.out([[<div>]]..g_errormsg..[[</div>]])
end
?>
</div>
<div style="<?lua write_faxblock(2)?>" >
<div class="formular">
<p class="txt_center" id="uiView_FaxWaitText">{?113:915?}</p>
<p class="waitimg"><img id="uiImage" src="/css/default/images/wait.gif"></p>
<p class="txt_center" id="uiView_FaxState" >&nbsp;</p>
</div>
</div>
<div id="btn_form_foot">
<div style="<?lua write_visible(0)?>">
<button type="submit" name="btn_continue" id="btnContinue">{?txtNext?}</button>
</div>
<div style="<?lua write_visible(1)?>">
<button type="submit" name="btn_send" id="btnSave">{?113:398?}</button>
<button type="submit" name="btn_cancel">{?txtCancel?}</button>
</div>
</div>
</form>
<form name="uploadform" method="POST" action="../cgi-bin/firmwarecfg" target="_self" enctype="multipart/form-data">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="NumDest" id="uiNumDest">
<input type="hidden" name="NumSrc" id="uiNumSrc">
<input type="hidden" name="FaxUploadFile" id="uiHiddenData">
</form>
<?include "templates/page_end.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript" src="/js/sffcoder.js"></script>
<script type="text/javascript" src="/js/text2canvas.js"></script>
<script type="text/javascript">
<?lua
val.write_js_error_strings()
?>
var g_pb=<?lua box.out(js.table(g_pb))?>;
var g_mode="<?lua write_mode() ?>";
var g_max_poll=200;
var g_count=0;
var g_keep=0;
var g_show_fonbook=false;
function OnViewFonbook()
{
g_show_fonbook=!g_show_fonbook;
jxl.display("uiFonbook",g_show_fonbook);
jxl.display("uiViewDest",!g_show_fonbook);
}
function OnBlur()
{
g_show_fonbook=false;
jxl.show("uiViewDest");
jxl.setSelection("uiFonbook","choose");
jxl.hide("uiFonbook");
}
function OnChange(uid)
{
if (uid=="choose")
{
return;
}
if (uid=="manu")
{
jxl.setValue("uiViewDestNum","");
jxl.setValue("uiViewDest","");
jxl.setDisabled("uiViewDest",false);
}
else
{
var x=uid.split("_");
uid=x[0];
var num_idx=parseInt(x[1],10);
if (isNaN(num_idx))
{
num_idx=0;
}
var g_found=false;
for (var i=0;i<g_pb.length && !g_found;i++)
{
if (g_pb[i].uid==uid)
{
jxl.setValue("uiViewDestNum",g_pb[i].numbers[num_idx].number);
jxl.setValue("uiViewDest",g_pb[i].name);
g_found=true;
break;
}
}
}
g_show_fonbook=false;
jxl.show("uiViewDest");
jxl.setSelection("uiFonbook","choose");
jxl.hide("uiFonbook");
}
function get_fonbook_name(uid)
{
for (var i=0;i<g_pb.length;i++)
{
if (g_pb[i].uid==uid)
{
return g_pb[i].name;
}
}
return ""
}
var keyStr = "ABCDEFGHIJKLMNOP" +
"QRSTUVWXYZabcdef" +
"ghijklmnopqrstuv" +
"wxyz0123456789+/" +
"=";
function encode64(input) {
var str=""
for (var i=0;i<input.length;i++)
{
str += String.fromCharCode(input[i]);
}
input=str
var output = "";
var chr1, chr2, chr3 = "";
var enc1, enc2, enc3, enc4 = "";
var i = 0;
var input_as_str=input;
do {
chr1 = input.charCodeAt(i++);
chr2 = input.charCodeAt(i++);
chr3 = input.charCodeAt(i++);
enc1 = chr1 >> 2;
enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
enc4 = chr3 & 63;
if (isNaN(chr2)) {
enc3 = enc4 = 64;
} else if (isNaN(chr3)) {
enc4 = 64;
}
output = output +
keyStr.charAt(enc1) +
keyStr.charAt(enc2) +
keyStr.charAt(enc3) +
keyStr.charAt(enc4);
chr1 = chr2 = chr3 = "";
enc1 = enc2 = enc3 = enc4 = "";
} while (i < input.length);
return output;
}
function cbKeepAlive(response)
{
var json = makeJSONParser();
var go_on=g_count<g_max_poll;
if (response && response.status == 200)
{
var wait = new Array("-","/","-","\\");
jxl.setText("uiProgress",wait[g_keep%4]);
g_keep++;
}
if (g_keep<10)
{
window.setTimeout(KeepAlive, 1000);
}
}
function KeepAlive()
{
var my_url = "/fon_devices/fax_send.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&query=KeepAlive";
ajaxGet(my_url, cbKeepAlive);
}
function onNumEditSubmit()
{
var dosend=val.active;
<?lua
val.write_js_checks(g_val)
?>
if (dosend)
{
var data={};
data.dest_name = jxl.getValue("uiViewDest");
data.dest_fax =jxl.getValue("uiViewDestNum");
data.dest_tel ="+++";//jxl.getValue("---");
data.from_name =jxl.getValue("uiViewFrom1");
data.from_fax =jxl.getValue("uiViewFromNum");
data.from_num ="###";//jxl.getValue("---");
var d=new Date;
data.date =d.toLocaleString();
data.shortdate =d.toLocaleDateString();
data.identifier = "<?lua box.js(box.query([[telcfg:settings/FaxKennung]])) ?>";
data.send_short = "<?lua box.js(box.query([[telcfg:settings/FaxSenderShort]])) ?>";
data.subject =jxl.getValue("uiViewSubject");
data.text =jxl.getValue("uiViewFaxText");
var SffFile = CreateFaxPage("uiCanvasContain",data);
if( SffFile )
{
jxl.setValue("uiHiddenData",encode64(SffFile));
jxl.setValue("uiNumDest",data.dest_fax);
jxl.setValue("uiNumSrc",data.from_fax);
}
else
{
alert("{?113:444?}");
return false;
}
}
jxl.submitForm("uploadform");
return false;
}
function cbRefresh(response)
{
var err_txt="{?113:384?}";
var json = makeJSONParser();
var go_on=g_count<g_max_poll;
if (response && response.status == 200)
{
var faxinfo=json(response.responseText || "null");
if (!go_on)
{
faxinfo.status=-2;
}
switch (faxinfo.status)
{
case -2:
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
jxl.setText("uiView_FaxWaitText",err_txt);
jxl.setText("uiView_FaxState","{?113:924?}");
go_on=false;
break;
case -1:
case 0:
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
jxl.setText("uiView_FaxWaitText",err_txt);
jxl.setText("uiView_FaxState","{?113:844?}");
go_on=false;
break;
case 5:
case 1:
if (faxinfo.reason!=0)
{
jxl.changeImage("uiImage","/css/default/images/finished_error.gif");
var Link="<a href='"+"<?lua box.js(href.help_get([[hilfe_capi_]])) ?>"+faxinfo.reason.toString(16)+".html'>";
var Linktxt=jxl.sprintf("{?113:490?}",faxinfo.reason.toString(16),Link,"</a>");
jxl.setHtml("uiView_FaxWaitText" ,Linktxt);
}
else
{
jxl.changeImage("uiImage","/css/default/images/finished_ok_green.gif");
jxl.setText("uiView_FaxWaitText","{?113:951?}");
}
jxl.setText("uiView_FaxState","");
go_on=false;
break;
case 2:
case 3:
jxl.changeImage("uiImage","/css/default/images/wait.gif");
jxl.setText("uiView_FaxWaitText","{?113:288?}");
jxl.setText("uiView_FaxState","");
break;
case 4:
jxl.changeImage("uiImage","/css/default/images/wait.gif");
jxl.setText("uiView_FaxWaitText","{?113:960?}");
var cur=jxl.sprintf("{?113:574?}",faxinfo.progress);
jxl.setText("uiView_FaxState",cur);
break;
}
}
if (go_on)
{
window.setTimeout(GetFaxState, 1000);
}
else
{
jxl.enable("btnContinue");
}
}
function GetFaxState()
{
g_count++;
var my_url = "/fon_devices/fax_send.lua?sid=<?lua box.js(box.glob.sid) ?>&useajax=1&query=refresh";
ajaxGet(my_url, cbRefresh);
}
function init()
{
if (window.File && window.FileReader && window.FileList && window.Blob)
{
}
else
{
jxl.display("uiFileAttachment",false);
}
if (g_mode=="fax_progress")
{
jxl.disable("btnContinue");
window.setTimeout(GetFaxState, 500);
}
else
{
var d = new Date();
try
{
jxl.setText( "uiDate", d.toLocaleString() );
}
catch ( e )
{
}
init_txt2canvas("uiCanvasContain","uiCanvasDiv");
try
{
document.getElementById("uiFile").addEventListener("change", OnChangeFileSel, false);
}
catch ( e )
{
}
}
}
ready.onReady(val.init(onNumEditSubmit, "btnSave", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/html_end.html" ?>
