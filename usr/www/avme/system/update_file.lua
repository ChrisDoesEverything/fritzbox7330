<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_update.html"
g_page_needs_js = true
dofile("../templates/global_lua.lua")
require("href")
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/static.css"/>
<link rel="stylesheet" type="text/css" href="/css/default/update.css"/>
<style type="text/css">
#uiActiveWarning table {
white-space: nowrap;
}
#uiSteps {
margin-top: 15px;
}
#uiSteps input,
#uiSteps button {
margin: 1px 0 10px 15px;
}
#uiSteps .formular {
padding-left: 15px;
}
#uiSteps .formular label {
width: 100px;
}
#uiSteps label+input {
margin: 0;
}
#uiSteps .formular .form_input_note {
margin-left: 106px;
}
.paragraph {
margin: 0 0 10px 15px;
}
#uiSteps .hintMsg {
padding-bottom: 0;
}
</style>
<?include "templates/page_head.html" ?>
<div id="uiWholePage">
<p>{?2107:660?}</p>
<br>
<p>{?2107:616?}</p>
<p>
<?lua
box.out( [[{?2107:491?}<span class="fake_text_input auto_size">]], box.tohtml( box.query("logic:status/nspver") ), [[</span>]] )
?>
</p>
<hr/>
<p>
{?2107:998?}
</p>
<?lua
if config.FON then
require"foncalls"
local calls = foncalls.get_activecalls()
if #calls > 0 then
box.out([[
<div id="uiActiveWarning">
<strong>{?txtHinweis?}</strong>
<p>{?2107:163?}</p>
<table class="zebra">
<tr>
<th></th>
<th>{?2107:154?}</th>
<th>{?2107:38?}</th>
<th>{?2107:974?}</th>
</tr>
]])
for i, call in ipairs(calls) do
local symbol = foncalls.get_callsymbol(call.call_type)
box.out([[
<tr>
<td class="]]..box.tohtml(symbol.class or "")..[["></td>
<td class="]]..box.tohtml(symbol.dirclass or "")..[[">]]..box.tohtml(foncalls.number_shortdisplay(call))..[[</td>
<td>]]..box.tohtml(foncalls.port_display(call))..[[</td>
<td>]]..box.tohtml(call.duration or "")..[[</td>
</tr>
]])
end
box.out([[
</table>
</div>
]])
end
end
?>
<form method="POST" action="/cgi-bin/firmwarecfg" enctype="multipart/form-data" id="uiMainForm">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<div id="uiSteps">
<div id="uiStepFile">
<p>{?2107:483?}</p>
<input type="file" name="UploadFile" id="uiFile" size="70">
</div>
<div id="uiStepUpdate">
<p>{?2107:755?}</p>
</div>
<button type="submit" id="uiUpdate">{?2107:780?}</button>
</div>
</form>
<p id="uiRebootHint">
{?2107:697?}
</p>
</div>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
function init()
{
var form = jxl.get( "uiMainForm" );
if ( form )
{
showExportFirst();
form.onsubmit = uiDoOnMainFormSubmit;
}
}
function showExportFirst()
{
var stepsBox = jxl.get( "uiSteps" );
if ( stepsBox )
{
var div = document.createElement( "div" );
if ( div )
{
var txt_tmp = ""
txt_tmp = "<p>{?2107:116?}</p>";
div.innerHTML = txt_tmp +
"<div class='formular'>" +
"<label for='uiPass'>{?2107:357?}</label>" +
"<input type='text' name='ImportExportPassword' id='uiPass' autocomplete='off'>" +
"</div>" +
"<div class='paragraph'><h4 class='hintMsg'>{?2107:629?}</h4>" +
"<p>{?2107:256?}</p>" +
"</div><div>" +
"<input type='button' value='{?2107:871?}' onclick='uiDoExport()'>" +
"<input type='hidden' name='ConfigExport' id='uiExport'>" +
"</div>";
stepsBox.insertBefore( div, stepsBox.firstChild );
createPasswordChecker( "uiPass" );
setTimeout( function() {
jxl.hide( "uiStepFile" );
jxl.hide( "uiStepUpdate" );
jxl.hide( "uiUpdate" );
jxl.hide( "uiRebootHint" );
}, 0 );
}
}
}
function enableUpdate()
{
jxl.enable( "uiFile" );
jxl.enable( "uiUpdate" );
}
function uiDoExport()
{
jxl.disable( "uiFile" );
jxl.disable( "uiUpdate" );
jxl.show( "uiStepFile" );
jxl.show( "uiStepUpdate" );
jxl.show( "uiUpdate" );
jxl.show( "uiRebootHint" );
window.setTimeout( "enableUpdate()", 2000 );
var form = jxl.get( "uiMainForm" );
if ( form )
{
form.submit();
}
}
function uiDoOnMainFormSubmit()
{
if ( jxl.getEnabled( "uiUpdate" ) )
{
jxl.disable( "uiExport" );
jxl.disable( "uiUpdate" );
jxl.disableNode( "uiMainForm", true, true );
var wait = document.createElement( "div" );
var waitTxt = "{?2107:77?}";
jxl.setHtml( wait, [
'<p class="waitimg"><img src="/css/default/images/wait.gif"><\/p><p>',
waitTxt,
'<\/p>'
].join( "" )
);
var content = jxl.get( "uiWholePage" );
var bottom = jxl.get( "uiHelpForm" );
content.insertBefore( wait, bottom );
setTimeout( delayedSubmit, 1000 );
return false;
}
return true;
}
function delayedSubmit()
{
jxl.get( "uiMainForm" ).submit();
}
ready.onReady( init );
</script>
<?include "templates/html_end.html" ?>
