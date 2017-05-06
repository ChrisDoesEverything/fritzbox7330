var gDisableMainPageBox_rename = "first";
var gDisableMainPageBox_newdir = "first";
var gDisableMainPageBox = "first";
var gDisableMainPageBox_whatis = "first";
var gDisableMainPageFormBox = "first";
function createBoxContent( aktion, customStyle )
{
var content = '';
if ( !aktion )
{
aktion = "all";
}
if ( !customStyle )
{
customStyle = "";
}
if ( "rename" == aktion || "newdir" == aktion )
{
content = '<div class="disable_main_page_content_box ' + customStyle + '">';
if ( "rename" == aktion )
{
content += '<div>{?249:394?}</div>';
}
else
{
content += '<div>{?249:24?}</div>';
}
content += '<input type="text" tabindex="1" class="cl_disable_page_new_name_input" id="disable_page_new_name_'+aktion+'" ';
content += 'onkeyup="checkFileOrDirForForbiddenChar(\'' + aktion + '\')" ';
content += 'onchange="checkFileOrDirForForbiddenChar(\'' + aktion + '\')" ';
content += '>';
content += '<div class="error_text" id="check_file_or_dir_for_forbidden_char_error_'+aktion+'"></div>'
content += '<hr>';
content += '<div class="disable_main_page_content_foot"><button type="button" tabindex="20" class="disable_main_page_content_box_btn" id="idBtnOk'+aktion+'" onclick="sendRenameNewDir(\'' + aktion + '\')" disabled>{?249:38?}</button>';
content += '<button type="button" tabindex="30" class="disable_main_page_content_box_btn" id="idBtnCancel" onclick="enablePage()">{?249:533?}</button>';
content += '</div></div>';
}
else
{
var customId = "";
if ( customStyle )
{
customId = "_" + customStyle;
}
content = '<div id="disable_main_page_content_box' + customId + '" class="disable_main_page_content_box ' + customStyle + '">';
if( "form" == aktion )
{
content += '<form method="POST" action="/nas/cgi-bin/nasupload_notimeout" enctype="multipart/form-data" id="disableBoxForm' + customId + '" >';
}
content += '<div id="disable_main_page_content_head' + customId + '" class="disable_main_page_content_head"></div>';
content += '<div id="disable_main_page_content_middle' + customId + '" class="disable_main_page_content_middle"></div>';
content += '<hr>';
content += '<div id="disable_main_page_content_foot' + customId + '" class="disable_main_page_content_foot"></div>';
if( "form" == aktion )
{
content += '</form>';
}
content += '</div>';
}
return content;
}
function fillBoxContent( head, middle, foot, customId )
{
if ( "undefined" == typeof customId )
{
customId = "";
}
jxl.setHtml( "disable_main_page_content_head" + customId, head );
jxl.setHtml( "disable_main_page_content_middle" + customId, middle );
jxl.setHtml( "disable_main_page_content_foot" + customId, foot );
}
function createModalBox(boxHtml) {
var container;
var tabOne;
var doIgnoreTab;
var ignoreElem;
function addFocusHandler(handler) {
if (document.addEventListener) {
document.addEventListener("focus", handler, true);
}
else if (document.attachEvent) {
document.attachEvent("onfocusin", handler);
}
}
function removeFocusHandler(handler) {
if (document.removeEventListener) {
document.removeEventListener("focus", handler, true);
}
else if (document.detachEvent) {
document.detachEvent("onfocusin", handler);
}
}
function createContainer() {
var container = document.createElement('div');
container.className = "disablePageContainer";
container.style.display = "none";
var overlay = document.createElement('div');
overlay.className = "disablePage";
overlay.id = "theDisableDiv";
container.appendChild(overlay);
var boxDiv = document.createElement('div');
boxDiv.className = "modalBox";
boxDiv.id = "theModalBox";
boxDiv.innerHTML = boxHtml;
container.appendChild(boxDiv);
return container;
}
function findTabOne() {
var elems = container.getElementsByTagName('*');
var i = elems.length;
while (i > 0) {
i -= 1;
if (elems[i].tabIndex == 1) {
return elems[i];
}
}
return null;
}
function init() {
if (!boxHtml) {
return false;
}
container = createContainer();
if (!container) {
return false;
}
var body = document.getElementsByTagName('body')[0];
body.appendChild(container);
tabOne = findTabOne();
doIgnoreTab = false;
return true;
}
function handleFocus(evt) {
evt = evt || window.event;
var elem = evt.target || evt.srcElement;
if (doIgnoreTab)
{
ignoreElem.focus();
}
else if (elem && elem.nodeType == 1) {
var t = parseInt(elem.tabIndex,10) || 0;
if (t < 1 && container.style.display != "none") {
setTimeout(function(){tabOne.focus();},0);
}
}
}
function openBox() {
if (container) {
container.style.display = "";
tabOne = findTabOne();
if (tabOne) {
tabOne.focus();
addFocusHandler(handleFocus);
}
}
}
function disableModalBox(disable)
{
if (!ignoreElem)
{
var btn = document.createElement('button');
btn.className = "hideIgnoreTabBtn";
container.appendChild(btn);
ignoreElem=btn;
}
if (disable)
{
doIgnoreTab = true;
jxl.enable(ignoreElem);
tabOne.tabIndex = "99";
ignoreElem.tabIndex = "1";
ignoreElem.focus();
jxl.addClass("theDisableDiv", "disable_all");
}
else
{
doIgnoreTab = false;
ignoreElem.tabIndex = "99";
tabOne.tabIndex = "1";
jxl.disable(ignoreElem);
jxl.removeClass("theDisableDiv", "disable_all");
}
}
function closeBox()
{
if ( tabOne )
{
removeFocusHandler( handleFocus );
}
if ( container )
{
container.style.display = "none";
}
}
init();
return {
open: openBox,
close: closeBox,
disableThisBox: disableModalBox
};
}
