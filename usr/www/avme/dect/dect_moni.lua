<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = "hilfe_fon_dect_moni.html"
dofile("../templates/global_lua.lua")
require("general")
require("js")
g_showHGIsSubs = false
g_showRepeaterIsSubs = false
function get_var()
for k = 0, 5, 1 do
local dect_subscribe = box.query("dect:settings/Handset"..k.."/Subscribed")
if (dect_subscribe == "1" ) then
g_showHGIsSubs = true
end
end
local repeater_list = general.listquery("dect:settings/Repeater/list(RFPI)")
for i,elem in ipairs(repeater_list) do
if elem.RFPI ~= "" then
g_showRepeaterIsSubs = true
end
end
end
function get_full_name(handset_user)
local foncontrol_user_list = general.listquery("telcfg:settings/Foncontrol/User/list(Id,Name)")
for j,user in ipairs(foncontrol_user_list) do
if handset_user == user.Id then
return user.Name
end
end
return nil
end
function get_handset_table(handset)
local handset_table = {}
handset_table.Subscribed = handset.Subscribed
handset_table.Name = handset.Name
handset_table.FullName = get_full_name(handset.User)
handset_table.IPU = handset.IPUI
handset_table.State = handset.State
handset_table.Codecs = handset.Codecs
handset_table.Manufacturer = handset.Manufacturer
handset_table.User = handset.User
handset_table.Slot = handset.Slot
handset_table.Channel = handset.Channel
handset_table.RSSI = handset.RSSI
handset_table.Quality = handset.Quality
handset_table.Mode = handset.Mode
handset_table.Frequency = handset.Frequency
handset_table.CurrentCodec = handset.CurrentCodec
handset_table.Encryption = handset.Encryption
handset_table.Model = handset.Model
handset_table.FWVersion = handset.FWVersion
return handset_table
end
function get_repeater_table(repeater, id)
local repeater_table = {}
repeater_table.RFPI = repeater.RFPI
repeater_table.Codecs = repeater.Codecs
repeater_table.Model = repeater.Model
repeater_table.Name = repeater.Name
repeater_table.FWVersion = repeater.FWVersion
repeater_table.id = id
repeater_table.nodeName = "DECTREP"
return repeater_table
end
function get_dect_state()
local handset_list = general.listquery("dect:settings/Handset/list(Subscribed,Name,IPUI,State,Codecs,Manufacturer,User,Slot,Channel,RSSI,Quality,Mode,Frequency,CurrentCodec,Encryption,Model,NoEmission,FWVersion)")
local state = {}
state.DectMoniInfo = {}
state.DectMoniInfo.DectExInit = {}
state.DectMoniInfo.DectExInit.init = {}
for i,handset in ipairs(handset_list) do
if handset.Subscribed == "1" then
table.insert(state.DectMoniInfo.DectExInit.init, box.query("dect:settings/"..handset._node.."/Basestatus"))
end
end
state.DectMoniInfo.DECTHG = {}
for i,handset in ipairs(handset_list) do
local handset_table = get_handset_table(handset)
handset_table.NoEmission = handset.NoEmission
table.insert(state.DectMoniInfo.DECTHG, handset_table)
end
state.DectMoniInfo.DECTREP = {}
if box.query("dect:settings/Repeater/count") == "6" then
local repeater_list = general.listquery("dect:settings/Repeater/list(RFPI,Codecs,Model,Name,FWVersion)")
for i,repeater in ipairs(repeater_list) do
table.insert(state.DectMoniInfo.DECTREP, get_repeater_table(repeater, i))
end
else
for variable = 0, 5, 1 do
local repeater_table = {}
repeater_table.RFPI = ""
repeater_table.Codecs = ""
repeater_table.Model = ""
repeater_table.Name = ""
repeater_table.FWVersion = ""
table.insert(state.DectMoniInfo.DECTREP, repeater_table)
end
end
state.DectMoniInfo.DectFBox = {}
state.DectMoniInfo.DectFBox.Slot = box.query("dect:settings/Dummybearer/Slot")
state.DectMoniInfo.DectFBox.Channel = box.query("dect:settings/Dummybearer/Channel")
state.DectMoniInfo.DectFBox.Frequency = box.query("dect:settings/Dummybearer/Frequency")
state.DectMoniInfo.DectFBox.Interference = box.query("dect:settings/Dummybearer/Interference")
state.DectMoniInfo.DectFBox.InterferenceRating = box.query("dect:settings/Dummybearer/InterferenceRating")
state.DectMoniInfo.DectFBox.RFPI = box.query("dect:settings/RFPI")
state.DectMoniInfo.DectFBox.Eco = box.query("dect:settings/Eco")
state.DectMoniInfo.DectFBox.Codecs = box.query("dect:settings/Codecs")
state.DectMoniInfo.DectFBox.Temperature = box.query("dect:settings/Temperature")
state.DectMoniInfo.DectFBox.BasisFW = box.query("logic:status/nspver")
state.DectMoniInfo.DectFBox.NoEmission = box.query("dect:settings/NoEmission")
state.DectMoniInfo.DectFBox.NoEmissionState = box.query("dect:settings/NoEmissionState")
return state
end
if box.get.useajax or box.post.useajax or false then
box.out(js.table(get_dect_state()))
box.end_page()
end
get_var()
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiViewDeleteRepeaterDevice{ vertical-align:top }
#BottomPfeilRowPfeile{height:30px;}
#TopPfeilRowPfeile{height:30px;}
#uiHGInfo2{left:0;}
#uiHGInfo1{left:207px;}
#uiHGInfo3{left:526px;}
.DectHGNameInfo{font-size:14px;font-weight:bold; white-space:nowrap;overflow:hidden;}
.dectiteminfo,
.dectiteminfoBig {
position: absolute;
top: 0;
background-color: rgb(144,190, 231);
margin: 0;
padding: 0;
width:202px;
border-radius: 4px;
}
.dectiteminfoBig {
margin: 0;
width:314px;
}
#uiNoHGPresentInfo{ position: absolute; top: 75px;left: 40px; width: 650px; }
.dectFBoxinfo {
background-color:rgb(144,190, 231);
margin: 0;
padding: 0;
clear:left;
width:390px;
border-radius: 4px;
}
.dectinfoinner { text-align: center; font-weight: bold; padding: 5px; height:250px; width: 185px;}
.dectinfoinnerBox { text-align: center; font-weight: bold; padding: 5px; height:250px; width: 362px;}
.dectFBoxinfoinner {
text-align: center;
font-weight: bold;
padding: 5px 10px;
height: 193px;
}
.DectInfoTable {
width: 710px;
height: 678px;
}
.DectInfoTable tr,
.DectInfoTable td {
margin: 0;
padding: 0;
position:relative;
top:0;
left:0;
vertical-align:top;
}
.HGRow { width: 710px; height: 254px; }
.HGInfoBackNext{ width: 730px; height: 20px; }
#uiNextHGInfoButton{position:absolute; top:0; left: 675px}
#uiBackHGInfoButton{position:absolute; top:0; left: 10px}
.SlotKanelRow{ width: 686px; height:174px;background: url("/css/default/images/dect_slot_mhzs.png") top left no-repeat; }
.DectFBoxBasis{text-align: center; width:600px;height:190px;}
.HGInfo{ width: 220px;}
#uiPfeilMainConnectHGMain{ position: absolute; top:15px; left: 110px; height: 6px; width: 590px; }
.PfeilConnectHRow{ background: url("/css/default/images/dect_arrow_hbar.png") top left repeat-x;}
.PfeilConnectVRow{ background: url("/css/default/images/dect_arrow_vbar.png") top left repeat-y;}
.PfeilBottom{ background: url("/css/default/images/dect_arrow_bottom.png") top left no-repeat;}
.PfeilTop{ background: url("/css/default/images/dect_arrow_top.png") top left no-repeat;}
#uiPfeilMainConnectHGMainDown{ position: absolute; top:15px; height: 15px; width: 6px;}
#uiPfeilMainConnectHGMainUp{ position: absolute; top:5px; left: 104px; height: 15px; width: 6px;}
#uiPfeilMainConnectHGMainUpImg{position: absolute; top:0; left: 100px; height: 16px; width: 14px;}
.TopPfeilRow{height:30px;vertical-align:top; padding:0;margin:0;}
.BottomPfeilRow{height:30px;vertical-align:top; padding:0;margin:0;}
#uiPfeilMainConnectFBoxMain{ position: absolute; top:12px; height: 6px;}
#uiPfeilMainConnectFBoxMainDownImg{ position: absolute; top:14px; left: 355px; height: 16px; width: 14px;}
#uiPfeilMainConnectFBoxMainUp{ position: absolute; top:0; height: 18px; width: 6px;}
#uiMHZSlotPfeilMain{ position: absolute; top:85px; height: 6px;}
#uiMHZSlotPfeilUpImg{position: absolute; top:72px; height: 16px; width: 14px;}
#uiMHZSlotPfeilUp{position: absolute; top:75px; height: 14px; width: 6px;}
#uiMHZSlotPfeilDownImg{position: absolute; top:86px; height: 16px; width: 14px;}
#uiMHZSlotPfeilDown{position: absolute; top:85px; height: 7px; width: 6px;}
#uiMHZSlotUnderPfeilDownImg{position: absolute; top:160px; height: 14px; width: 14px;}
#uiMHZSlotOverPfeilUpImg{position: absolute; top:-2px; height: 16px; width: 14px;}
.uiBlueAktivSlotClass{background: url("/css/default/images/dect_slot_used.gif") top left no-repeat;color: white}
.InterfImg { height: 58px; width: 63px;position: absolute; top:14px; background: url("/css/default/images/dect_channel_interf.gif") top left no-repeat; padding-top:5px; text-align:center; color: #e31f43}
.BlueAktivMhzBasic{position: absolute; top:14px; height: 58px; width: 63px;background: url("/css/default/images/dect_channel_used.gif") top left no-repeat;padding-top:5px; text-align:center; color: white}
.MhzTextSize{height: 58px; width: 63px;position: absolute; top:14px; padding-top:5px; color: #586D98;text-align:center;}
.SlotTextSize{position: absolute; top:102px; height: 58px; width: 53px; padding-top:12px; color: #3f96f3;text-align:center;}
.GraphicInfoTextMhz{position: absolute; top:54px; left: 15px; height: 16px; width: 54px;text-align:left;}
.GraphicInfoTextSlot{position: absolute; top:141px; left: 15px; height: 16px; width: auto;text-align:left;}
.MhzItem1{left:16px}
.MhzItem2{left:82px}
.MhzItem3{left:148px}
.MhzItem4{left:214px}
.MhzItem5{left:280px}
.MhzItem6{left:346px}
.MhzItem7{left:412px}
.MhzItem8{left:478px}
.MhzItem9{left:544px}
.MhzItem10{left:610px}
.SlotItem1{left:15px}
.SlotItem2{left:70px}
.SlotItem3{left:125px}
.SlotItem4{left:180px}
.SlotItem5{left:235px}
.SlotItem6{left:290px}
.SlotItem7{left:345px}
.SlotItem8{left:400px}
.SlotItem9{left:455px}
.SlotItem10{left:510px}
.SlotItem11{left:565px}
.SlotItem12{left:620px}
.SlotTextNumber{ color:#3F96F3 }
.MhzTextNumberBasic{font-family: Arial; font-size:16px;font-weight:bold;}
.InfoTextNumberBasic{font-family: Arial; font-size:16px; color:#98968A}
.SlotTextNumberBasic{font-family: Arial; font-weight:bold ;font-size:28px;}
.MhzTextNumber{font-family: Arial; font-size:16px; color:white }
.innerPfeil{ position: relative; top: 0; left: 0;}
div.DarkBluePfeil{ position: relative; top: 0; left: 0;}
table {background-color: transparent; border: none;}
button {font-size: 13px; min-width: 0; overflow: auto;}
table.ItemTableInfoSmall {font-size: 11px; font-weight: normal;table-layout:fixed;width:186px;}
table.ItemTableInfo {
font-size: 11px;
font-weight: normal;
table-layout:fixed;
width:283px;
}
table.ItemTableInfo tr,
table.ItemTableInfoSmall tr {height: 16px;}
td.TableInfoKeyNameBig {width: 115px;padding-left:2px;}
td.TableInfoKeyName {width: 92px;padding-left:2px;}
td.TableInfoValueName {width: 91px;}
td.TableImgRepeater {background-color: rgb(144,190, 231);}
tr.lightITableBg{background-color: rgb(254,246,213);}
tr.darkITableBg{background-color: rgb(254,248,229);}
div.HGTableInfo{position: absolute; top: 5px; left: 10px; height: 158px; width: 175px;}
div.ItemTableInfoBig{position: absolute; top: 5px; left: 15px; height: 225px; width: 190px;}
div.ItemTableInfoSmall{position: absolute; top: 5px; left: 5px; height: 200px; width: 190px;}
div.ItemTableInfoSmall:hover{cursor:pointer}
div.FBoxInfo{position: absolute; top: 10px; left: 10px; height: 180px; width: 370px;}
table.FBoxTableInfo {font-size: 11px; font-weight: normal;width:100%}
table.FBoxTableInfo tr {height: 20px;}
#uiDectEcoIcon{height:38px;width:38px; position: absolute; top: 65px; left:130px;}
#uiDectFBoxIcon{width:190px; position: absolute; top: 35px; left:5px;}
div.LightBluePfeil{ position: relative; top: 0; left: 0;}
div.LightBluePfeil .PfeilConnectHRow{ background: url("/css/default/images/dect_arrow_lightblue_hbar.png") top left repeat-x;}
div.LightBluePfeil .PfeilConnectVRow{ background: url("/css/default/images/dect_arrow_lightblue_vbar.png") top left repeat-y;}
div.LightBluePfeil .PfeilBottom{ background: url("/css/default/images/dect_arrow_bottom_lightblue.png") top left no-repeat;}
div.LightBluePfeil .PfeilTop{ background: url("/css/default/images/dect_arrow_top_lightblue.png") top left no-repeat;}
div.LightBluePfeil .uiBlueAktivSlotClass{background: url("/css/default/images/dect_slot_box.gif") top left no-repeat;color: white}
div.LightBluePfeil .BlueAktivMhzBasic{position: absolute; top:14px; height: 58px; width: 63px;background: url("/css/default/images/dect_channel_box.gif") top left no-repeat;padding-top:5px; text-align:center; color: white}
#uiSlotKanalRowDiv {margin-left:5px;}
</style>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript">
var g_initValues = <?lua box.out(js.table(get_dect_state())) ?>
var g_showHGIsSubs = <?lua general.box.js(tostring(g_showHGIsSubs)) ?>
var g_showRepeaterIsSubs = <?lua box.js(tostring(g_showRepeaterIsSubs)) ?>
var g_NoInfo="--";
var g_getrennt="{?5873:813?}";
var g_verbunden="{?5873:721?}";
var g_connecting="{?5873:477?}";
var g_paging="{?5873:344?}";
function init()
{
document.title = "{?5873:517?}";
SetPngImages();
ajaxDectMoniXMLCB(g_initValues);
}
function StartReadDectMoniInfo(){
var url = "/dect/dect_moni.lua?useajax=1";
url += "&sid=<?lua box.js(box.glob.sid) ?>";
ajaxGet(url, ajaxCallback);
}
function ajaxCallback(response)
{
if (response && response.readyState == 4 && response.status == 200) {
var json = makeJSONParser();
var dectInfo = json(response.responseText || "null");
ajaxDectMoniXMLCB(dectInfo)
}
}
function ajaxDectMoniXMLCB(dectInfo)
{
ResetNodeInfo();
g_DectXMLNode = dectInfo.DectMoniInfo;
var DectHGNodes = g_DectXMLNode.DECTHG;
var DectRepeaterNodes = g_DectXMLNode.DECTREP;
if(DectHGNodes==null && DectRepeaterNodes==null)
{
return;
}
g_DectFBoxNode = g_DectXMLNode.DectFBox;
if(g_DectFBoxNode==null)
{
return;
}
FillFBoxInfo();
g_DectHGNodes=DectHGNodes;
g_DectRepeaterNodes=DectRepeaterNodes;
if( (DectHGNodes.length > 0) || (DectRepeaterNodes.length > 0) )
{
FillHGNodes(DectHGNodes,DectRepeaterNodes);
FillInfos();
}
}
function IconBtn(btnId, clickFunc, btnValue, pic, invisible)
{
var str = '<button type="button" id="' + btnId + '"';
if (clickFunc) str += ' onclick="' + clickFunc + '"';
if (btnValue) str += ' value="' + btnValue + '" title="' + btnValue + '"';
if (invisible) str += ' style="visibility:hidden;"';
str += '>';
str += '<img src="' + '/css/default/images/' + pic + '" /></button>';
return str;
}
function SetPngImages(){
var imageStr="<img id='uiAVMHGIcon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiDectAVMCatiHGIcon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiDectAVMC3Icon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiDectAVMC4Icon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiOtherHGIcon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiAVMBobHGIcon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
imageStr+="<img id='uiAVMM2HGIcon' "+pngImgSrc('dect_other_hg_icon_small.png')+" style='display:none;'>";
document.getElementById('uiDectAVMHGIconDiv').innerHTML=imageStr
document.getElementById('uiDectFBoxIcon').innerHTML="<img "+pngImgSrc('dect_fbox_icon.png')+">";
del_btn=IconBtn("uiViewDeleteRepeaterDevice", "uiDoDeleteRepeaterDevice()", "{?txtIconBtnDelete?}", "loeschen.gif");
document.getElementById('uiHG1RepeaterImg').innerHTML="<img "+pngImgSrc('dect_fbox_icon.png')+">"+del_btn;
}
function uiDoRefresh() {
jxl.submitForm("uiMainForm");
}
function valIsZahl (nummer) {
if (nummer.match("[^0-9]") != null) return false;
return true;
}
function pngImgSrc(imgName)
{
var str = "src=\"/css/default/images/" + imgName + "\"";
return str;
}
var g_DectXMLNode=null;
var g_DectHGRepeaterNode1=null;
var g_DectHGRepeaterNode2=null;
var g_DectHGRepeaterNode3=null;
var g_FoundDectHGRepeaterNode1=null;
var g_FoundDectHGRepeaterNode2=null;
var g_FoundDectHGRepeaterNode3=null;
var g_FoundDectHGRepeaterNode4=null;
var g_FoundDectHGRepeaterNode5=null;
var g_FoundDectHGRepeaterNode6=null;
var g_FoundDectHGRepeaterNode7=null;
var g_FoundDectHGRepeaterNode8=null;
var g_FoundDectHGRepeaterNode9=null;
var g_FoundDectHGRepeaterNode10=null;
var g_FoundDectHGRepeaterNode11=null;
var g_FoundDectHGRepeaterNode12=null;
var g_HGRepAllFindCounter=0;
var g_DectHGNodes=null;
var g_DectRepeaterNodes=null;
var g_DectFBoxNode=null;
var g_HGFindCounter=0;
function ResetNodeInfo(){
g_FoundDectHGRepeaterNode1=null;
g_FoundDectHGRepeaterNode2=null;
g_FoundDectHGRepeaterNode3=null;
g_FoundDectHGRepeaterNode4=null;
g_FoundDectHGRepeaterNode5=null;
g_FoundDectHGRepeaterNode6=null;
g_FoundDectHGRepeaterNode7=null;
g_FoundDectHGRepeaterNode8=null;
g_FoundDectHGRepeaterNode9=null;
g_FoundDectHGRepeaterNode10=null;
g_FoundDectHGRepeaterNode11=null;
g_FoundDectHGRepeaterNode12=null;
g_HGRepAllFindCounter=0;
g_DectHGRepeaterNode1=null;
g_DectHGRepeaterNode2=null;
g_DectHGRepeaterNode3=null;
g_HGFindCounter=0;
}
function ajaxUnSubCB( textDocument )
{
uiDoRefresh();
}
function uiDoDeleteRepeaterDevice(){
if (IsRepeater(g_DectHGRepeaterNode1))
{
UnsubscribeId = parseInt(g_DectHGRepeaterNode1.id, 10);
var RFPI = "";
if( g_DectHGRepeaterNode1.RFPI &&
typeof g_DectHGRepeaterNode1.RFPI === "string")
{
RFPI = g_DectHGRepeaterNode1.RFPI;
}
var url = "/dect/dect_rep_unsub.lua?";
url += "sid=<?lua box.js(box.glob.sid) ?>";
url += "&unsubid=" + UnsubscribeId;
url += "&rfpi=" + RFPI;
ajaxGet(url, ajaxUnSubCB);
}
}
function HideAndReset(){
jxl.display( "uiHGInfo1", false);
jxl.display( "uiHGInfo2", false);
jxl.display( "uiHGInfo3", false);
jxl.display( "TopPfeilRowPfeile", false);
jxl.display( "SlotKanelRowPfeile", false);
jxl.display( "BottomPfeilRowPfeile", false);
jxl.display( "uiInterfImg1", false);jxl.display( "uiInterfImg2", false);jxl.display( "uiInterfImg3", false);jxl.display( "uiInterfImg4", false);jxl.display( "uiInterfImg5", false);
jxl.display( "uiInterfImg6", false);jxl.display( "uiInterfImg7", false);jxl.display( "uiInterfImg8", false);jxl.display( "uiInterfImg9", false);jxl.display( "uiInterfImg10", false);
}
var g_Show3DevicepageIndex = 1;
function FillHGNodes(DectHGNodes,DectRepeaterNodes){
g_HGRepAllFindCounter=0;
for(var i=0;i<DectHGNodes.length;i++){
var subscribedNode = DectHGNodes[i].Subscribed;
if (subscribedNode && subscribedNode == "1" && IsConnectedNode(DectHGNodes[i]))
{
g_HGRepAllFindCounter++;
if(g_HGRepAllFindCounter==1){
g_FoundDectHGRepeaterNode1=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==2){
g_FoundDectHGRepeaterNode2=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==3){
g_FoundDectHGRepeaterNode3=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==4){
g_FoundDectHGRepeaterNode4=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==5){
g_FoundDectHGRepeaterNode5=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==6){
g_FoundDectHGRepeaterNode6=DectHGNodes[i];
}
}
}
for(var i=0;i<DectHGNodes.length;i++){
var subscribedNode = DectHGNodes[i].Subscribed;
if (subscribedNode && subscribedNode == "1" && !IsConnectedNode(DectHGNodes[i])) {
g_HGRepAllFindCounter++;
if(g_HGRepAllFindCounter==1){
g_FoundDectHGRepeaterNode1=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==2){
g_FoundDectHGRepeaterNode2=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==3){
g_FoundDectHGRepeaterNode3=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==4){
g_FoundDectHGRepeaterNode4=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==5){
g_FoundDectHGRepeaterNode5=DectHGNodes[i];
}else if(g_HGRepAllFindCounter==6){
g_FoundDectHGRepeaterNode6=DectHGNodes[i];
}
}
}
for(var i=0;i<DectRepeaterNodes.length;i++){
var RFPINode = DectRepeaterNodes[i].RFPI;
if (RFPINode && RFPINode != "") {
g_HGRepAllFindCounter++;
if(g_HGRepAllFindCounter==1){
g_FoundDectHGRepeaterNode1=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==2){
g_FoundDectHGRepeaterNode2=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==3){
g_FoundDectHGRepeaterNode3=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==4){
g_FoundDectHGRepeaterNode4=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==5){
g_FoundDectHGRepeaterNode5=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==6){
g_FoundDectHGRepeaterNode6=DectRepeaterNodes[i];
} else if(g_HGRepAllFindCounter==7){
g_FoundDectHGRepeaterNode7=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==8){
g_FoundDectHGRepeaterNode8=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==9){
g_FoundDectHGRepeaterNode9=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==10){
g_FoundDectHGRepeaterNode10=DectRepeaterNodes[i];
}else if(g_HGRepAllFindCounter==11){
g_FoundDectHGRepeaterNode11=DectRepeaterNodes[i];
} else if(g_HGRepAllFindCounter==12){
g_FoundDectHGRepeaterNode12=DectRepeaterNodes[i];
}
}
}
if(g_HGRepAllFindCounter>3)
{
jxl.display('uiHGInfoBackNext',true);
ShowBackNextHGImg();
}
FillShownHGNodes();
}
function ShowBackNextHGImg()
{
if(g_HGRepAllFindCounter > (g_Show3DevicepageIndex * 3)){
jxl.display('uiNextHGInfoButton',true);
}else{
jxl.display('uiNextHGInfoButton',false);
}
if(g_Show3DevicepageIndex == 1){
jxl.display('uiBackHGInfoButton',false);
}else{
jxl.display('uiBackHGInfoButton',true);
}
}
function FillShownHGNodes(){
if(g_HGRepAllFindCounter<1)
{
return;
}
g_HGFindCounter=0;
switch(g_Show3DevicepageIndex){
case 1:
if(g_FoundDectHGRepeaterNode1){
g_HGFindCounter++;
g_DectHGRepeaterNode1=g_FoundDectHGRepeaterNode1;
}
if(g_FoundDectHGRepeaterNode2){
g_HGFindCounter++;
g_DectHGRepeaterNode2=g_FoundDectHGRepeaterNode2;
}
if(g_FoundDectHGRepeaterNode3){
g_HGFindCounter++;
g_DectHGRepeaterNode3=g_FoundDectHGRepeaterNode3;
}
break;
case 2:
if(g_FoundDectHGRepeaterNode4){
g_HGFindCounter++;
g_DectHGRepeaterNode1=g_FoundDectHGRepeaterNode4;
}
if(g_FoundDectHGRepeaterNode5){
g_HGFindCounter++;
g_DectHGRepeaterNode2=g_FoundDectHGRepeaterNode5;
}
if(g_FoundDectHGRepeaterNode6){
g_HGFindCounter++;
g_DectHGRepeaterNode3=g_FoundDectHGRepeaterNode6;
}
break;
case 3:
if(g_FoundDectHGRepeaterNode7){
g_HGFindCounter++;
g_DectHGRepeaterNode1=g_FoundDectHGRepeaterNode7;
}
if(g_FoundDectHGRepeaterNode8){
g_HGFindCounter++;
g_DectHGRepeaterNode2=g_FoundDectHGRepeaterNode8;
}
if(g_FoundDectHGRepeaterNode9){
g_HGFindCounter++;
g_DectHGRepeaterNode3=g_FoundDectHGRepeaterNode9;
}
break;
case 4:
if(g_FoundDectHGRepeaterNode10){
g_HGFindCounter++;
g_DectHGRepeaterNode1=g_FoundDectHGRepeaterNode10;
}
if(g_FoundDectHGRepeaterNode11){
g_HGFindCounter++;
g_DectHGRepeaterNode2=g_FoundDectHGRepeaterNode11;
}
if(g_FoundDectHGRepeaterNode12){
g_HGFindCounter++;
g_DectHGRepeaterNode3=g_FoundDectHGRepeaterNode12;
}
break;
}
}
function uiDoShowNext()
{
g_Show3DevicepageIndex ++;
HideAndReset();
ResetNodeInfo();
FillHGNodes(g_DectHGNodes,g_DectRepeaterNodes);
FillInfos();
}
function uiDoShowPrev()
{
g_Show3DevicepageIndex--
HideAndReset();
ResetNodeInfo();
FillHGNodes(g_DectHGNodes,g_DectRepeaterNodes);
FillInfos();
}
function DoSwitchShwonHGPositions(IdToCenter){
HideAndReset();
temp1=g_DectHGRepeaterNode1;
temp2=g_DectHGRepeaterNode2;
temp3=g_DectHGRepeaterNode3;
switch(IdToCenter){
case 2:g_DectHGRepeaterNode1=temp2;g_DectHGRepeaterNode2=temp1; break;
case 3:g_DectHGRepeaterNode1=temp3;g_DectHGRepeaterNode3=temp1; break;
}
FillInfos();
}
function FillInfos()
{
if (g_showHGIsSubs)
{
ShowAndPositionHGInfos();
SetSlotKanalInfos();
}
else
{
if (g_showRepeaterIsSubs)
{
ShowAndPositionHGInfos();
}
else
{
jxl.display('uiNoHGPresentInfo',true);
}
}
}
function IsEcoAktiv()
{
return false;
}
var g_PfeilImgBorderDiff=4;
var g_innerCornerMainMin=4;
function SetBottomPfeile(SlotId,bHGIsConnected){
if(bHGIsConnected)
{
document.getElementById('BottomPfeilRowPfeile').className="DarkBluePfeil";
}
else
{
document.getElementById('BottomPfeilRowPfeile').className="LightBluePfeil";
}
SlotLeft = 43 + ( ( SlotId - 1) * 55 );
var g_FBoxMainInfoLeft = 355;
MainWidth=Math.abs((g_FBoxMainInfoLeft+g_PfeilImgBorderDiff)- SlotLeft)+g_innerCornerMainMin;
MainLeft=Math.min(SlotLeft,g_FBoxMainInfoLeft+g_PfeilImgBorderDiff);
document.getElementById("uiPfeilMainConnectFBoxMainUp").style.left=SlotLeft+"px";
document.getElementById("uiPfeilMainConnectFBoxMain").style.left=MainLeft+"px";
document.getElementById("uiPfeilMainConnectFBoxMain").style.width=MainWidth+"px";
jxl.display('BottomPfeilRowPfeile',true);
}
function SetTopPfeile(MhzId, HGId){
TopLeft=0;
if ( HGId == 1 )
{
TopLeft=354;
}
else if ( HGId == 2 )
{
TopLeft=100;
}
else if ( HGId == 3 )
{
TopLeft=610;
}
else
{
return;
}
MhzLeft = 49 + ( ( MhzId - 1 ) * 66 );
MainWidth=Math.abs((TopLeft+g_PfeilImgBorderDiff)-MhzLeft)+g_innerCornerMainMin;
MainLeft=Math.min(TopLeft+g_PfeilImgBorderDiff,MhzLeft);
document.getElementById("uiPfeilMainConnectHGMainUpImg").style.left=TopLeft+"px";
document.getElementById("uiPfeilMainConnectHGMainUp").style.left=(TopLeft+g_PfeilImgBorderDiff)+"px";
document.getElementById("uiPfeilMainConnectHGMainDown").style.left=MhzLeft+"px";
document.getElementById("uiPfeilMainConnectHGMain").style.left=MainLeft+"px";
document.getElementById("uiPfeilMainConnectHGMain").style.width=MainWidth+"px";
jxl.display('TopPfeilRowPfeile',true);
}
function IsWideSlot(HGId)
{
var node=GetHGNode(HGId);
return ( node && "long slot" == node.Mode );
}
function SetSlotKanalInfos()
{
ShowSlot1=0;
ShowSlot2=0;
ShowSlot3=0;
ShowMhz1=-1;
ShowMhz2=-1;
ShowMhz3=-1;
var bHg1Connected=false;
var bHGIsConnected=false;
if(g_HGFindCounter>0 && IsConnected(1))
{
ShowSlot1=parseInt( g_DectHGRepeaterNode1.Slot, 10) + 1;
ShowMhz1=parseInt( g_DectHGRepeaterNode1.Channel, 10)+1;
bHg1Connected=true;
bHGIsConnected=true;
}
if(g_HGFindCounter>1 && IsConnected(2))
{
bHGIsConnected=true;
}
if(g_HGFindCounter>2 && IsConnected(3))
{
bHGIsConnected=true;
}
if(!bHg1Connected)
{
ShowSlot1=parseInt( g_DectFBoxNode.Slot, 10) + 1;
ShowMhz1=parseInt( g_DectFBoxNode.Channel, 10)+1;
}
HideAllDeepBlueImg();
SetInterfInfos(ShowMhz1,ShowMhz2,ShowMhz3);
if(bHg1Connected)
{
SetMhzSlotPfeil(ShowMhz1,ShowSlot1,bHg1Connected);
SetBottomPfeile(ShowSlot1,bHg1Connected);
SetTopPfeile(ShowMhz1,1);
jxl.display('uiBlueAktivMhz'+ShowMhz1,true);
jxl.display('uiBlueAktivSlot'+ShowSlot1,true);
if(IsWideSlot(1))
{
nextid=(ShowSlot1+1);
jxl.display('uiBlueAktivSlot'+nextid,true);
}
}else{
SetMhzSlotPfeil(ShowMhz1,ShowSlot1,bHg1Connected);
jxl.display('uiBlueAktivMhz'+ShowMhz1,true);
jxl.display('uiBlueAktivSlot'+ShowSlot1,true);
SetBottomPfeile(ShowSlot1,bHg1Connected);
}
jxl.display('SlotKanelRowPfeile',true);
}
function ShowAndPositionHGInfos(){
if(g_HGFindCounter>0){
FillHGInfo(1);
jxl.display('uiHGInfo1',true);
}
if(g_HGFindCounter>1){
FillHGInfo(2);
jxl.display('uiHGInfo2',true);
}
if(g_HGFindCounter>2){
FillHGInfo(3);
jxl.display('uiHGInfo3',true);
}
}
function IsConnected(HGId){
var node=GetHGNode(HGId);
return IsConnectedNode(node);
}
function IsRepeater(node){
return ( null != node && "DECTREP" == node.nodeName );
}
function IsConnectedNode(node){
return ( node && ("2" == node.State || "3" == node.State || "4" == node.State ) );
}
function GetHGNode(HGId){
var node=null;
if(HGId==1)
node=g_DectHGRepeaterNode1;
else if(HGId==2)
node=g_DectHGRepeaterNode2;
else if(HGId==3)
node=g_DectHGRepeaterNode3;
else
{
return null;
}
return node;
}
function GetStateInfo(StateValue){
if(StateValue==null || StateValue=="")
{
return g_NoInfo;
}
State=parseInt(StateValue);
if(State==0)
{
return g_getrennt;
}
else if(State==1)
{
return g_paging;
}
else if(State==2 || State==3)
{
return g_verbunden;
}
else if(State==4)
{
return g_connecting;
}
else
{
return g_NoInfo;
}
}
function GetNodeData(node,keyname){
if(node[keyname])
{
if(node==null)
return "";
if( node[keyname].length==0)
return "";
if( node[keyname]==null )
return "";
return node[keyname];
}
else
return "";
}
function ChangeHGRepeaterTrDisplay(node,HGId)
{
var Hide = true;
if (IsRepeater(node))
{
Hide = false;
}
jxl.display('uiHG'+HGId+'TableInfo',Hide);
jxl.display('uiHG'+HGId+'TableInfoRepeater',!Hide);
}
function FillHGInfo(HGId){
var node=GetHGNode(HGId);
if(node==null)
{
return;
}
var State=GetStateInfo(GetNodeData(node,'State'));
var Codecs=GetNodeData(node,'Codecs');
var UserName=GetNodeData(node,'FullName');
if (UserName=="er" || UserName=="")
{
UserName=GetNodeData(node,'Name');
}
var Rssi=g_NoInfo;
var Quality=g_NoInfo;
var Mode=g_NoInfo;
var Slot=g_NoInfo;
var Codec=g_NoInfo;
var Encryption = g_NoInfo;
var Freq=g_NoInfo;
var Manufacturer=GetNodeData(node,'Manufacturer');;
var Model=GetNodeData(node,'Model');;
var IPU=GetNodeData(node,'IPU') + "*";
var RFPI=GetNodeData(node,'RFPI');
var NoEmission = "";
var FWVersion = GetNodeData(node,'FWVersion');
if (FWVersion.length == 0)
{
FWVersion = g_NoInfo;
}
var NoEmissionState=GetNodeData(node,'NoEmission');
if (NoEmissionState=="1")
{
NoEmission="{?5873:45?}";
}
else
{
NoEmission="--";
}
ChangeHGRepeaterTrDisplay(node,HGId);
if(IsRepeater(node))
{
var rep_picture="";
var del_btn="";
if (node.Model == "128")
{
Model="FRITZ!Box";
rep_picture='dect_fbox_icon.png';
}
else
{
Model="FRITZ!Repeater";
rep_picture='dect_frep_icon.png';
del_btn=IconBtn("uiViewDeleteRepeaterDevice", "uiDoDeleteRepeaterDevice()", "{?txtIconBtnDelete?}", "loeschen.gif");
}
if(HGId==1){
jxl.get('uiHG'+HGId+'RepeaterImg').innerHTML="<img "+pngImgSrc(rep_picture)+">"+del_btn;
jxl.display('uiAVMBobHGIcon',false);
jxl.display('uiAVMM2HGIcon',false);
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiDectAVMC3Icon',false);
jxl.display('uiDectAVMC4Icon',false);
jxl.display('uiAVMHGIcon',false);
jxl.display('uiOtherHGIcon',false);
jxl.display('uiViewDeleteRepeaterDevice',true);
}
UserName=GetNodeData(node,'Name');
jxl.setHtml('uiHG'+HGId+'UsernameRepeater',UserName);
jxl.setText('uiHG'+HGId+'RFPIRepeater',RFPI);
jxl.setHtml('uiHG'+HGId+'CodecsRepeater',Codecs);
jxl.setText('uiHG'+HGId+'ModelRepeater',Model);
jxl.setText('uiHG'+HGId+'Firmware',FWVersion);
jxl.setText('uiHG'+HGId+'FirmwareRepeater',FWVersion);
}else{
if(IsConnected(HGId)){
Rssi=GetNodeData(node,'RSSI') + " dBm";
Quality=GetNodeData(node,'Quality')+"%";
Mode=GetNodeData(node,'Mode');
SlotStr=GetNodeData(node,'Slot');
if(SlotStr!="")
{
Slot=parseInt(SlotStr,10)+1;
}
Freq=GetNodeData(node,'Frequency');
Codec=GetNodeData(node,'CurrentCodec');
Encryption=GetNodeData(node,'Encryption');
if (Encryption=="0")
{
Encryption="{?txtAus?}";
}
else if (Encryption=="1")
{
Encryption="{?txtAn?}";
}
}
if(HGId==1)
{
if(Manufacturer=="AVM/Swissvoice")
{
jxl.display('uiViewDeleteRepeaterDevice',false);
jxl.display('uiAVMBobHGIcon',false);
jxl.display('uiDectAVMC3Icon',false);
jxl.display('uiDectAVMC4Icon',false);
jxl.display('uiOtherHGIcon',false);
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiAVMM2HGIcon',false);
jxl.display('uiAVMHGIcon',true);
}
else if(Manufacturer=="AVM")
{
jxl.display('uiViewDeleteRepeaterDevice',false);
jxl.display('uiAVMBobHGIcon',false);
jxl.display('uiDectAVMC3Icon',false);
jxl.display('uiDectAVMC4Icon',false);
jxl.display('uiOtherHGIcon',false);
jxl.display('uiAVMM2HGIcon',false);
jxl.display('uiAVMHGIcon',false);
jxl.display('uiDectAVMCatiHGIcon',true);
if (Model=="0x01") {
Model="MT-D";
}
else if (Model=="0x03") {
Model="MT-F";
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiAVMBobHGIcon',true);
}else if (Model=="0x04") {
Model="C3";
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiDectAVMC3Icon',true);
jxl.display('uiDectAVMC4Icon',false);
}else if (Model=="0x08") {
Model="C4";
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiDectAVMC3Icon',false);
jxl.display('uiDectAVMC4Icon',true);
}else if (Model=="0x05") {
Model="M2";
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiAVMM2HGIcon',true);
}
}
else
{
jxl.display('uiViewDeleteRepeaterDevice',false);
jxl.display('uiAVMBobHGIcon',false);
jxl.display('uiDectAVMC3Icon',false);
jxl.display('uiDectAVMC4Icon',false);
jxl.display('uiAVMM2HGIcon',false);
jxl.display('uiAVMHGIcon',false);
jxl.display('uiDectAVMCatiHGIcon',false);
jxl.display('uiOtherHGIcon',true);
}
}
jxl.setText('uiHG'+HGId+'IPU',IPU);
jxl.setHtml('uiHG'+HGId+'Username',UserName);
jxl.setText('uiHG'+HGId+'Pegel',Rssi);
jxl.setHtml('uiHG'+HGId+'Encrypt',Encryption);
jxl.setText('uiHG'+HGId+'Quality',Quality);
jxl.setHtml('uiHG'+HGId+'Mode',Mode);
jxl.setHtml('uiHG'+HGId+'Codecs',Codecs);
jxl.setHtml('uiHG'+HGId+'Verbindung',State);
jxl.setText('uiHG'+HGId+'Slot',Slot);
jxl.setText('uiHG'+HGId+'Codec',Codec);
jxl.setText('uiHG'+HGId+'Freq',Freq);
jxl.setText('uiHG'+HGId+'NoEmission',NoEmission);
if (Manufacturer=="AVM") {
if (Model=="0x01") {
Model="MT-D";
}
else if (Model == "0x03") {
Model="MT-F";
}
else if (Model == "0x04") {
Model="C3";
}
else if (Model == "0x08") {
Model="C4";
}
else if (Model == "0x05") {
Model="M2";
}
}
jxl.setText('uiHG'+HGId+'Model',Model);
jxl.setText('uiHG'+HGId+'Manufacturer',Manufacturer);
jxl.setText('uiHG'+HGId+'Firmware',FWVersion);
jxl.setText('uiHG'+HGId+'FirmwareRepeater',FWVersion);
}
}
function FillFBoxInfo(){
if(g_DectFBoxNode==null)
{
return;
}
node=g_DectFBoxNode;
var DummyBearer=g_NoInfo;
var DummyBearerMhz=g_NoInfo;
var EcoInfo=GetNodeData(node,'Eco');
if (EcoInfo=="0") {
EcoInfo="{?5873:909?}";
}
else {
EcoInfo="{?5873:790?}";
}
var BNoEmission=GetNodeData(node,'NoEmission');
if (BNoEmission=="0") {
BasisNoEmission="--";
}
else {
BasisNoEmission="{?5873:730?}";
}
var NoEmissionState=GetNodeData(node,'NoEmissionState');
var BasisNoEmissionState="{?txtAus?}";
if (NoEmissionState=="0") {
BasisNoEmissionState="{?txtAus?}";
} else if (NoEmissionState=="1") {
BasisNoEmissionState="{?txtActive?}";
} else if (NoEmissionState=="2") {
BasisNoEmissionState="{?5873:44?}";
}
var codecs=GetNodeData(node,'Codecs');
var FWInfo=GetNodeData(node,'BasisFW');
var rfpi=GetNodeData(node,'RFPI');
if (g_showHGIsSubs)
{
DummyBearerSlotStr=GetNodeData(node,'Slot');
DummyBearerMhz=GetNodeData(node,'Frequency');
if(DummyBearerSlotStr!="")
{
DummyBearer=parseInt(DummyBearerSlotStr,10)+1;
}
}
jxl.setText('uiFBoxRFPI',rfpi);
jxl.setText('uiFBoxCodecs',codecs);
jxl.setText('uiFBoxDummyBearer',DummyBearer);
jxl.setText('uiFBoxDummyBearerMhz',DummyBearerMhz);
jxl.setHtml('uiFBoxEcoInfo',EcoInfo);
jxl.setText('uiFBoxBasisFW',FWInfo);
jxl.setText('uiFBoxBasisNoEmission',BasisNoEmission);
jxl.setText('uiFBoxBasisNoEmissionState',BasisNoEmissionState);
if(IsEcoAktiv())
{
jxl.display("uiDectEcoIcon",true);
}
}
function HideAllDeepBlueImg(){
for(i=1;i<11;i++){
jxl.display("uiBlueAktivMhz"+i,false);
}
for(i=1;i<13;i++){
jxl.display("uiBlueAktivSlot"+i,false);
}
}
function SetMhzSlotPfeil(MhzId,SlotId,bHGIsConnected){
if(bHGIsConnected)
{
document.getElementById('SlotKanelRowPfeile').className="DarkBluePfeil";
}
else
{
document.getElementById('SlotKanelRowPfeile').className="LightBluePfeil";
}
SlotLeft=34+( (SlotId-1)*55);
MhzLeft=40+( (MhzId-1)*66);
MainWidth=Math.abs(SlotLeft-MhzLeft)+g_innerCornerMainMin;
MainLeft=Math.min(SlotLeft,MhzLeft)+g_PfeilImgBorderDiff;
document.getElementById("uiMHZSlotPfeilMain").style.left=MainLeft+"px";
document.getElementById("uiMHZSlotPfeilMain").style.width=MainWidth+"px";
document.getElementById("uiMHZSlotPfeilUpImg").style.left=MhzLeft+"px";
document.getElementById("uiMHZSlotPfeilUp").style.left=(MhzLeft+g_PfeilImgBorderDiff)+"px";
document.getElementById("uiMHZSlotOverPfeilUpImg").style.left=MhzLeft+"px";
if(!bHGIsConnected)
{
jxl.display('uiMHZSlotOverPfeilUpImg',false);
}
else
{
jxl.display('uiMHZSlotOverPfeilUpImg',true);
}
document.getElementById("uiMHZSlotPfeilDownImg").style.left=SlotLeft+"px";
document.getElementById("uiMHZSlotPfeilDown").style.left=(SlotLeft+g_PfeilImgBorderDiff)+"px";
document.getElementById("uiMHZSlotUnderPfeilDownImg").style.left=(SlotLeft)+"px";
}
function SetInterfInfos(ShowMhz1,ShowMhz2,ShowMhz3){
interference=GetNodeData(g_DectFBoxNode,'InterferenceRating');
if(interference==null || interference=="" || interference=="er")
return;
interferceArray=interference.split(",");
for(i=0;i<10;i++)
{
if(ShowMhz1!=-1 && ((ShowMhz1-1)==i || (ShowMhz2-1)==i || (ShowMhz3-1)==i))
{
continue;
}
if(IsInterferenceMhz(interferceArray[i]))
{
Index=i+1;
jxl.display("uiInterfImg"+Index,true);
}
}
}
function IsInterferenceMhz(interferenceValue){
return 1 == interferenceValue;
}
function uiDoDectMoniEx() {
jxl.submitForm("uiMainForm");
}
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form id="uiMainForm" method="POST" action="<?lua href.write(box.glob.script) ?>">
<div>
<p>{?5873:701?}</p>
<hr>
<table class="DectInfoTable" id="uiDectInfoTable">
<tr class="HGInfoBackNext">
<td>
<div style="position:relative; top:0; left: 0" id="uiHGInfoBackNext" class="HGInfoBackNext" style="display:none;">
<div id="uiNextHGInfoButton" style="display:none;"><a href="javascript:uiDoShowNext()">{?5873:392?}</a></div>
<div id="uiBackHGInfoButton" style="display:none;"><a href="javascript:uiDoShowPrev()">{?5873:711?}</a></div>
</div>
</td>
</tr>
<tr class="HGRow">
<td>&nbsp;
<div style="position:relative; top:0; left: 0">
<div id="uiNoHGPresentInfo" style="display:none">{?5873:10?}</div>
<div class="dectiteminfoBig" id="uiHGInfo1" style="display:none;">
<div class="dectinfoinner">
<div style="width:75px; position: absolute; top: 25px; left:5px; text-align: left;" id="uiDectAVMHGIconDiv"></div>
<div class="ItemTableInfoBig" id="uiHG1TableInfo" style="display:none;">
<table class="ItemTableInfo">
<tr ><td id="uiHG1Username" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1IPUTR"><td class='TableInfoKeyName'>{?5873:612?}</td><td class='TableInfoValueName' id="uiHG1IPU">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1VerbindungTR"><td class='TableInfoKeyName'>{?5873:278?}</td><td id="uiHG1Verbindung" >&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1ManufacturerTR"><td class='TableInfoKeyName'>{?5873:321?}</td>
<td><div id="uiHG1Manufacturer" style="width:91px;overflow:hidden; font-size: 11px; font-weight: normal;">&nbsp;</div></td>
</tr>
<tr class='darkITableBg' id="uiHG1ModelTR"><td class='TableInfoKeyName'>{?5873:879?}</td><td id="uiHG1Model">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1PegelTR"><td class='TableInfoKeyName'>{?5873:688?}</td><td id="uiHG1Pegel">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1QualityTR"><td class='TableInfoKeyName'>{?5873:333?}</td><td id="uiHG1Quality">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1ModeTR"><td class='TableInfoKeyName'>{?5873:558?}</td><td id="uiHG1Mode">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1FreqTR"><td class='TableInfoKeyName'>{?5873:19?}</td><td id="uiHG1Freq">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1SlotTR"><td class='TableInfoKeyName'>{?5873:3214?}</td><td id="uiHG1Slot">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1CodecsTR"><td class='TableInfoKeyName'>{?5873:897?}</td><td id="uiHG1Codecs">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1CodecTR"><td class='TableInfoKeyName'><span class='ml10'>{?5873:415?}</span></td><td id="uiHG1Codec">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1EncryptTR"><td class='TableInfoKeyName'>{?5873:708?}</td><td id="uiHG1Encrypt">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1FirmwareTR"><td class='TableInfoKeyName'>{?5873:780?}</td><td id="uiHG1Firmware">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1NoEmissionTR"><td class='TableInfoKeyName'>{?5873:323?}</td><td id="uiHG1NoEmission">&nbsp;</td></tr>
</table>
</div>
<div class="ItemTableInfoBig" id="uiHG1TableInfoRepeater" style="display:none;">
<table class="ItemTableInfo">
<tr ><td id="uiHG1UsernameRepeater" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1RFPIRepeaterTR"><td class='TableInfoKeyName'>{?5873:567?}</td><td class='TableInfoValueName' id="uiHG1RFPIRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1ModelRepeaterTR"><td class='TableInfoKeyName'>{?5873:796?}</td><td id="uiHG1ModelRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG1CodecsRepeaterTR"><td class='TableInfoKeyName'>{?5873:199?}</td><td id="uiHG1CodecsRepeater">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG1FirmwareRepeaterTR"><td class='TableInfoKeyName'>{?5873:67?}</td><td id="uiHG1FirmwareRepeater">&nbsp;</td></tr>
<tr id="uiHG1RepeaterImgRepeaterTR"><td class="TableImgRepeater" colspan="2"><br><div id="uiHG1RepeaterImg"></div></td></tr>
</table>
</div>
</div>
</div>
<div class="dectiteminfo" id="uiHGInfo2" style="display:none;">
<div class="dectinfoinner">
<div class="ItemTableInfoSmall" onclick="DoSwitchShwonHGPositions(2);" id="uiHG2TableInfo" style="display:none;">
<table class="ItemTableInfoSmall" id="uiHG2TableInfo">
<tr ><td id="uiHG2Username" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2IPUTR"><td class='TableInfoKeyName'>{?5873:428?}</td><td class='TableInfoValueName' id="uiHG2IPU">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2VerbindungTR"><td class='TableInfoKeyName'>{?5873:562?}</td><td id="uiHG2Verbindung" >&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2ManufacturerTR"><td class='TableInfoKeyName'>{?5873:143?}</td>
<td><div id="uiHG2Manufacturer" style="width:91px;overflow:hidden; font-size: 11px; font-weight: normal;">&nbsp;</div></td>
</tr>
<tr class='darkITableBg' id="uiHG2ModelTR"><td class='TableInfoKeyName'>{?5873:871?}</td><td id="uiHG2Model">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2PegelTR"><td class='TableInfoKeyName'>{?5873:474?}</td><td id="uiHG2Pegel">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2QualityTR"><td class='TableInfoKeyName'>{?5873:230?}</td><td id="uiHG2Quality">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2ModeTR"><td class='TableInfoKeyName'>{?5873:745?}</td><td id="uiHG2Mode">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2FreqTR"><td class='TableInfoKeyName'>{?5873:494?}</td><td id="uiHG2Freq">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2SlotTR"><td class='TableInfoKeyName'>{?5873:673?}</td><td id="uiHG2Slot">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2CodecsTR"><td class='TableInfoKeyName'>{?5873:2637?}</td><td id="uiHG2Codecs">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2CodecTR"><td class='TableInfoKeyName'><span class='ml10'>{?5873:359?}</span></td><td id="uiHG2Codec">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2EncryptTR"><td class='TableInfoKeyName'>{?5873:418?}</td><td id="uiHG2Encrypt">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2FirmwareTR"><td class='TableInfoKeyName'>{?5873:2?}</td><td id="uiHG2Firmware">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2NoEmissionTR"><td class='TableInfoKeyName'>{?5873:293?}</td><td id="uiHG2NoEmission">&nbsp;</td></tr>
</table>
</div>
<div class="ItemTableInfoSmall" onclick="DoSwitchShwonHGPositions(2);" id="uiHG2TableInfoRepeater" style="display:none;">
<table class="ItemTableInfoSmall">
<tr ><td id="uiHG2UsernameRepeater" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2RFPIRepeaterTR"><td class='TableInfoKeyName'>{?5873:999?}</td><td class='TableInfoValueName' id="uiHG2RFPIRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2ModelRepeaterTR"><td class='TableInfoKeyName'>{?5873:30?}</td><td id="uiHG2ModelRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG2CodecsRepeaterTR"><td class='TableInfoKeyName'>{?5873:923?}</td><td id="uiHG2CodecsRepeater">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG2FirmwareRepeaterTR"><td class='TableInfoKeyName'>{?5873:898?}</td><td id="uiHG2FirmwareRepeater">&nbsp;</td></tr>
</table>
</div>
</div>
</div>
<div class="dectiteminfo" id="uiHGInfo3" style="display:none;">
<div class="dectinfoinner">
<div class="ItemTableInfoSmall" onclick="DoSwitchShwonHGPositions(3);" id="uiHG3TableInfo" style="display:none;">
<table class="ItemTableInfoSmall" id="uiHG3TableInfo">
<tr ><td id="uiHG3Username" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3IPUTR"><td class='TableInfoKeyName'>{?5873:3909?}</td><td class='TableInfoValueName' id="uiHG3IPU">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3VerbindungTR"><td class='TableInfoKeyName'>{?5873:6006?}</td><td id="uiHG3Verbindung" >&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3ManufacturerTR"><td class='TableInfoKeyName'>{?5873:819?}</td>
<td><div id="uiHG3Manufacturer" style="width:91px;overflow:hidden; font-size: 11px; font-weight: normal;">&nbsp;</div></td>
</tr>
<tr class='darkITableBg' id="uiHG3ModelTR"><td class='TableInfoKeyName'>{?5873:983?}</td><td id="uiHG3Model">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3PegelTR"><td class='TableInfoKeyName'>{?5873:25?}</td><td id="uiHG3Pegel">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3QualityTR"><td class='TableInfoKeyName'>{?5873:385?}</td><td id="uiHG3Quality">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3ModeTR"><td class='TableInfoKeyName'>{?5873:233?}</td><td id="uiHG3Mode">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3FreqTR"><td class='TableInfoKeyName'>{?5873:792?}</td><td id="uiHG3Freq">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3SlotTR"><td class='TableInfoKeyName'>{?5873:93?}</td><td id="uiHG3Slot">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3CodecsTR"><td class='TableInfoKeyName'>{?5873:556?}</td><td id="uiHG3Codecs">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3CodecTR"><td class='TableInfoKeyName'><span class='ml10'>{?5873:6890?}</span></td><td id="uiHG3Codec">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3EncryptTR"><td class='TableInfoKeyName'>{?5873:108?}</td><td id="uiHG3Encrypt">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3FirmwareTR"><td class='TableInfoKeyName'>{?5873:460?}</td><td id="uiHG3Firmware">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3NoEmissionTR"><td class='TableInfoKeyName'>{?5873:491?}</td><td id="uiHG3NoEmission">&nbsp;</td></tr>
</table>
</div>
<div class="ItemTableInfoSmall" onclick="DoSwitchShwonHGPositions(3);" id="uiHG3TableInfoRepeater" style="display:none;">
<table class="ItemTableInfoSmall">
<tr ><td id="uiHG3UsernameRepeater" class="DectHGNameInfo" colspan="2">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3RFPIRepeaterTR"><td class='TableInfoKeyName'>{?5873:804?}</td><td class='TableInfoValueName' id="uiHG3RFPIRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3ModelRepeaterTR"><td class='TableInfoKeyName'>{?5873:603?}</td><td id="uiHG3ModelRepeater">&nbsp;</td></tr>
<tr class='darkITableBg' id="uiHG3CodecsRepeaterTR"><td class='TableInfoKeyName'>{?5873:363?}</td><td id="uiHG3CodecsRepeater">&nbsp;</td></tr>
<tr class='lightITableBg' id="uiHG3FirmwareRepeaterTR"><td class='TableInfoKeyName'>{?5873:671?}</td><td id="uiHG3FirmwareRepeater">&nbsp;</td></tr>
</table>
</div>
</div>
</div>
</div>
</td>
</tr>
<tr class="TopPfeilRow">
<td>
<div id="TopPfeilRowPfeile" style="display:none">
<div class="innerPfeil">
<div id="uiPfeilMainConnectHGMainUpImg" class="PfeilTop"></div>
<div id="uiPfeilMainConnectHGMainUp" class="PfeilConnectVRow"></div>
<div id="uiPfeilMainConnectHGMain" class="PfeilConnectHRow"></div>
<div id="uiPfeilMainConnectHGMainDown" class="PfeilConnectVRow"></div>
</div>
</div>
</td>
</tr>
<tr >
<td>
<div class="SlotKanelRow" id="uiSlotKanalRowDiv">
<div class="innerPfeil" style="z-index:0;">
<div class="MhzTextSize MhzTextNumberBasic MhzItem1">1897,3</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem2">1895,6</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem3">1893,9</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem4">1892,2</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem5">1890,4</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem6">1888,7</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem7">1887,0</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem8">1885,2</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem9">1883,5</div>
<div class="MhzTextSize MhzTextNumberBasic MhzItem10">1881,8</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem1">1</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem2">2</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem3">3</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem4">4</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem5">5</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem6">6</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem7">7</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem8">8</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem9">9</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem10">10</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem11">11</div>
<div class="SlotTextSize SlotTextNumberBasic SlotItem12">12</div>
</div>
<div class="innerPfeil" style="z-index:1;">
<div class="InterfImg MhzTextNumberBasic MhzItem1" id="uiInterfImg1" style="display:none">1897,3</div>
<div class="InterfImg MhzTextNumberBasic MhzItem2" id="uiInterfImg2" style="display:none">1895,6</div>
<div class="InterfImg MhzTextNumberBasic MhzItem3" id="uiInterfImg3" style="display:none">1893,9</div>
<div class="InterfImg MhzTextNumberBasic MhzItem4" id="uiInterfImg4" style="display:none">1892,2</div>
<div class="InterfImg MhzTextNumberBasic MhzItem5" id="uiInterfImg5" style="display:none">1890,4</div>
<div class="InterfImg MhzTextNumberBasic MhzItem6" id="uiInterfImg6" style="display:none">1888,7</div>
<div class="InterfImg MhzTextNumberBasic MhzItem7" id="uiInterfImg7" style="display:none">1887,0</div>
<div class="InterfImg MhzTextNumberBasic MhzItem8" id="uiInterfImg8" style="display:none">1885,2</div>
<div class="InterfImg MhzTextNumberBasic MhzItem9" id="uiInterfImg9" style="display:none">1883,5</div>
<div class="InterfImg MhzTextNumberBasic MhzItem10" id="uiInterfImg10" style="display:none">1881,8</div>
</div>
<div class="LightBluePfeil" id="SlotKanelRowPfeile" style="display:none;z-index:2;">
<div id="uiMHZSlotPfeilMain" class="PfeilConnectHRow"></div>
<div id="uiMHZSlotPfeilUpImg" class="PfeilTop"></div>
<div id="uiMHZSlotPfeilUp" class="PfeilConnectVRow"></div>
<div id="uiMHZSlotPfeilDownImg" class="PfeilBottom"></div>
<div id="uiMHZSlotPfeilDown" class="PfeilConnectVRow"></div>
<div id="uiMHZSlotOverPfeilUpImg" class="PfeilBottom"></div>
<div id="uiMHZSlotUnderPfeilDownImg" class="PfeilTop"></div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem1" id="uiBlueAktivMhz1" style="display:none">1897,3</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem2" id="uiBlueAktivMhz2" style="display:none">1895,6</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem3" id="uiBlueAktivMhz3" style="display:none">1893,9</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem4" id="uiBlueAktivMhz4" style="display:none">1892,2</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem5" id="uiBlueAktivMhz5" style="display:none">1890,4</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem6" id="uiBlueAktivMhz6" style="display:none">1888,7</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem7" id="uiBlueAktivMhz7" style="display:none">1887,0</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem8" id="uiBlueAktivMhz8" style="display:none">1885,2</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem9" id="uiBlueAktivMhz9" style="display:none">1883,5</div>
<div class="BlueAktivMhzBasic MhzTextNumberBasic MhzItem10" id="uiBlueAktivMhz10" style="display:none">1881,8</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem1" id="uiBlueAktivSlot1" style="display:none;color:white;">1</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem2" id="uiBlueAktivSlot2" style="display:none;color:white;">2</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem3" id="uiBlueAktivSlot3" style="display:none;color:white;">3</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem4" id="uiBlueAktivSlot4" style="display:none;color:white;">4</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem5" id="uiBlueAktivSlot5" style="display:none;color:white;">5</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem6" id="uiBlueAktivSlot6" style="display:none;color:white;">6</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem7" id="uiBlueAktivSlot7" style="display:none;color:white;">7</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem8" id="uiBlueAktivSlot8" style="display:none;color:white;">8</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem9" id="uiBlueAktivSlot9" style="display:none;color:white;">9</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem10" id="uiBlueAktivSlot10" style="display:none;color:white;">10</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem11" id="uiBlueAktivSlot11" style="display:none;color:white;">11</div>
<div class="uiBlueAktivSlotClass SlotTextSize SlotTextNumberBasic SlotItem12" id="uiBlueAktivSlot12" style="display:none;color:white;">12</div>
</div>
<div class="innerPfeil" style="z-index:3;">
<div class="GraphicInfoTextMhz InfoTextNumberBasic">{?5873:279?}</div>
<div class="GraphicInfoTextSlot InfoTextNumberBasic">{?gTxtDectMoniSlot?}</div>
</div>
<div class="innerPfeil" style="z-index:1;">
<div class="GraphicInfoTextSlot InfoTextNumberBasic" style="background-color:#F9E892;">{?gTxtDectMoniSlot?}</div>
</div>
</div>
</td>
</tr>
<tr class="BottomPfeilRow">
<td>
<div class="LightBluePfeil" id="BottomPfeilRowPfeile" style="display:none">
<div id="uiPfeilMainConnectFBoxMainUp" class="PfeilConnectVRow"></div>
<div id="uiPfeilMainConnectFBoxMain" class="PfeilConnectHRow"></div>
<div id="uiPfeilMainConnectFBoxMainDownImg" class="PfeilBottom"></div>
</div>
</td>
</tr>
<tr class="DectFBoxBasis">
<td style="text-align: center;">
<table>
<tr>
<td style="width:40%"></td>
<td style="width:350px;">
<div style="position:relative; top:0; left: 0">
<div class="dectFBoxinfo">
<div class="dectFBoxinfoinner">
<div class="dectinfoinnerBox">
<div id="uiDectFBoxIcon"></div>
<div id="uiDectEcoIcon" style="display:none"><img src="/css/default/images/ecomodus.gif"></div>
<div class="FBoxInfo">
<table class="FBoxTableInfo" id="uiFBoxTableInfo">
<tr><td colspan="2" class="DectHGNameInfo">{?5873:222?}</td></tr>
<tr class='lightITableBg'><td class='TableInfoKeyNameBig'>{?5873:5125?}</td><td class='TableInfoValueName' id="uiFBoxRFPI">&nbsp;</td></tr>
<tr class='darkITableBg'><td class='TableInfoKeyNameBig'>{?5873:859?}</td><td id="uiFBoxDummyBearer">&nbsp;</td></tr>
<tr class='lightITableBg'><td class='TableInfoKeyNameBig'>{?5873:690?}</td><td id="uiFBoxDummyBearerMhz">&nbsp;</td></tr>
<tr class='darkITableBg'><td class='TableInfoKeyNameBig'>{?5873:762?}</td><td id="uiFBoxCodecs">&nbsp;</td></tr>
<tr class='lightITableBg'><td class='TableInfoKeyNameBig'>{?5873:277?}</td><td id="uiFBoxEcoInfo">&nbsp;</td></tr>
<tr class='darkITableBg'>
<td class='TableInfoKeyNameBig'>{?5873:336?}</td>
<td><div id="uiFBoxBasisFW" style="width:85px; height:16px; overflow:hidden; font-size: 11px; font-weight: normal; white-space:nowrap">&nbsp;</div></td>
</tr>
<tr class='lightITableBg'>
<td class='TableInfoKeyNameBig'>{?5873:114?}</td>
<td><div id="uiFBoxBasisNoEmission" style="width:85px; height:16px; overflow:hidden; font-size: 11px; font-weight: normal; white-space:nowrap">&nbsp;</div></td>
</tr>
<tr class='darkITableBg'>
<td class='TableInfoKeyNameBig'>{?5873:307?}</td>
<td><div id="uiFBoxBasisNoEmissionState" style="width:85px; height:16px; overflow:hidden; font-size: 11px; font-weight: normal; white-space:nowrap">&nbsp;</div></td>
</tr>
</table>
</div>
</div>
</div>
</div>
</div>
</td>
<td style="width:40%;"></td>
</tr>
</table>
</td>
</tr>
</table>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="button" name="btn_refresh" id="btnRefresh" onclick="uiDoRefresh()">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
