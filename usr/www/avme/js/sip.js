var g_safeProvider = "";
var g_mode = "";
var gAvaibleSipCount = 0;
var gUsbaleSipCounts = 0;
var gResetedData = false;
var gIsWizard = true;
var gShowMSN = false;
function setCheckedJS(idOrElement, value)
{
bool = false;
if (value == "1")
{
bool = true;
}
jxl.setChecked(idOrElement,bool);
}
function setFonData(fondata, isFromBox)
{
var curProviderDetails = new Array();
var curProviderTelcfg = new Array();
var mode = "";
if (isFromBox)
{
curProviderDetails = fondata.dataValues.details;
curProviderTelcfg = fondata.dataValues.telcfg;
mode = fondata.mode;
jxl.setValue("uiRegistrar",curProviderDetails.registrar[0]);
}
else
{
curProviderDetails = fondata[0].dataValues.details;
curProviderTelcfg = fondata[0].dataValues.telcfg;
mode = fondata[0].mode;
gShowMSN = (fondata[0].msnnum != fondata[0].number)?true:false;
setCheckedJS("uiSipActiv", curProviderDetails.activated);
jxl.setValue("uiRegistrar",curProviderDetails.registrar);
jxl.setValue("uiPwd",curProviderDetails.password);
}
var UseLKZ = curProviderTelcfg.UseLKZ;
var UseOKZ = curProviderTelcfg.UseOKZ;
var KeepLKZPrefix = curProviderTelcfg.KeepLKZPrefix;
var KeepOKZPrefix = curProviderTelcfg.KeepOKZPrefix;
var countTrunk = 1;
jxl.setValue("uiUsername", curProviderDetails.username);
setCheckedJS("uiRoute_Always_Over_Internet", curProviderDetails.route_always_over_internet);
setCheckedJS("uiG726NACHRFC3551", curProviderDetails.g726_via_3551rfc);
setCheckedJS("uiSpit", curProviderDetails.only_call_from_registrar);
setCheckedJS("uiCcbs_Supported", curProviderDetails.ccbs_supported);
setCheckedJS("uiUseOKZProvider", curProviderTelcfg.UseOKZ);
setCheckedJS("uiUseinternatcallingnumbe", curProviderDetails.use_internat_calling_numb);
jxl.setValue("uiOutboundproxy", curProviderDetails.outboundproxy);
jxl.setValue("uiStunserver", curProviderDetails.stunserver);
jxl.setChecked("uiAlternatePrefix_USA", (curProviderTelcfg.AlternatePrefix == "011"));
jxl.setValue("uiSuffix", curProviderTelcfg.Suffix);
jxl.setValue("uiClirtype", curProviderDetails.clirtype);
jxl.setValue("uiDdiType", curProviderDetails.dditype);
jxl.setValue("uiDtmfcfg", curProviderDetails.dtmfcfg);
setCheckedJS("uiAuthname_Needed", curProviderDetails.authname_needed);
setCheckedJS("uiEmergencyRule", curProviderTelcfg.EmergencyRule);
setCheckedJS("uiAKN", curProviderTelcfg.AKN);
jxl.setChecked("uiLkz1",UseLKZ == "0");
jxl.setChecked("uiLkz2",KeepLKZPrefix == "0" && UseLKZ == "1");
jxl.setChecked("uiLkz3",KeepLKZPrefix == "1" && UseLKZ == "1");
jxl.setChecked("uiOkz1",KeepOKZPrefix == "1" && UseOKZ == "0");
jxl.setChecked("uiOkz2",KeepOKZPrefix == "0" && UseOKZ == "1");
jxl.setChecked("uiOkz3",KeepOKZPrefix == "1" && UseOKZ == "1");
if (jxl.get("uiPrefer"))
{
jxl.setSelection("uiPrefer", curProviderDetails.protocolprefer);
}
if (!isFromBox)
{
countTrunk = fondata[0].count_trunk;
if (mode == "normal")
{
jxl.setValue("uiNumberInput1_1",fondata[0].number1);
jxl.setValue("uiNumberInput2_1",fondata[0].number2);
jxl.setValue("uiMSN", fondata[0].msnnum);
jxl.setValue("uiSipName_1",fondata[0].name);
}
else if (mode == "directdialin")
{
jxl.setValue("uiSerialNumber",fondata[0].number1);
jxl.setValue("uiCentralPhoneExtension",fondata[0].number2);
jxl.setSelection("uiLengthSerialNumber", curProviderDetails.ExtensionLength);
for (var i = 1; i < fondata[0].count_trunk; i++)
{
jxl.setValue("uiNumberInput1_trunk_"+i,fondata[i].number1);
jxl.setValue("uiSipName_trunk_"+i,fondata[i].name);
jxl.removeClass("uiNumberLine_"+i, "DontShow");
}
}
else if (mode == "differenttrunk")
{
for (var i = 0; i < fondata[0].count_trunk; i++)
{
j = i+1;
jxl.setValue("uiNumberInput1_trunk_"+j,fondata[i].number1);
jxl.setValue("uiSipName_trunk_"+j,fondata[i].name);
jxl.removeClass("uiNumberLine_"+j, "DontShow");
}
}
gUsbaleSipCounts = fondata[0].count_trunk + gAvaibleSipCount;
gIsWizard = false;
}
else
{
if (gResetedData && gIsWizard)
{
gUsbaleSipCounts = gAvaibleSipCount +1;
gResetedData = false;
}
else
{
gUsbaleSipCounts = gAvaibleSipCount;
}
}
if (mode == "directdialin")
{
gUsbaleSipCounts = gAvaibleSipCount - 1;
}
if (curProviderDetails.def_user)
{
jxl.setValue("uiUsername",curProviderDetails.def_user);
}
jxl.setValue("countTrunk", countTrunk);
}
function clearInput(input)
{
if((input.type == "checkbox") || (input.type == "radio"))
{
jxl.setChecked(input, false);
}
else
{
jxl.setValue(input,"");
}
}
function showData(id, value)
{
if (value == "" || value == false)
{
jxl.display(id, false);
}
else
{
if (typeof value != 'boolean')
jxl.setText(id, value);
jxl.display(id, true);
}
}
function onUserInputActivated(checked)
{
jxl.setDisabled("uiUsername",!checked);
jxl.setDisabled("uiPwd",!checked);
}
function anyDisplayed(parent, headingElement)
{
var parentBox = jxl.get(parent);
var childrendDivs = parentBox.getElementsByTagName("div");
for (var i = 0; i < childrendDivs.length; i++)
{
if (!jxl.hasClass(childrendDivs[i],"DontShow") && jxl.hasClass(childrendDivs[i],"titlemark"))
{
jxl.removeClass(headingElement,"DontShow");
return;
}
}
jxl.addClass(headingElement,"DontShow");
return;
}
function showDisplay(providerlist,provider, is_ui)
{
var displayList = providerlist[provider]["display"];
for (var display in displayList)
{
var element = "ui"+display;
if(displayList[display])
{
jxl.removeClass(element,"DontShow");
jxl.addClass(element,display);
}
else
{
jxl.removeClass(element,display);
jxl.addClass(element,"DontShow");
}
}
anyDisplayed("uiLogonData","uiTitleLogonData");
anyDisplayed("uiNumberFormat","uiTitleNumFormat");
anyDisplayed("uiPerformanceFeatures","uiTitlePerf");
anyDisplayed("uiAssistanceCustomerCenters","uiTitleCustom");
if (!jxl.hasClass("uiTitlePerf", "DontShow") || !jxl.hasClass("uiTitleNumFormat","DontShow") || !jxl.hasClass("uiTitleCustom","DontShow"))
{
jxl.removeClass("uiLine","DontShow");
}
else
{
jxl.addClass("uiLine","DontShow");
}
if (!jxl.hasClass("uiTitlePerf", "DontShow") && !jxl.hasClass("uiTitleNumFormat","DontShow"))
{
jxl.removeClass("uiLine2","DontShow");
}
else
{
jxl.addClass("uiLine2","DontShow");
}
if (is_ui)
{
var selectUiValue = jxl.getValue("uiSipProviderUI");
jxl.display("uiOtherProvider",!(selectUiValue=="1und1" || selectUiValue=="gmx"));
if (selectUiValue=="other_non_ui")
{
jxl.setValue("uiSipProvider", provider);
}
}
showUserInterface(providerlist, provider);
showDivTrunkAll(providerlist[provider].mode);
}
function showUserInterface(providerlist,provider_id)
{
var userInterface = providerlist[provider_id]["userInterface"]
var secondInput = providerlist[provider_id]["display"]["ShowSecondInput"]
jxl.addClass("uiNumberInput2_1","DontShow");
jxl.clearClass("uiInput");
if (secondInput)
{
jxl.removeClass("uiNumberInput2_1","DontShow");
if (userInterface["uiNumberMiddleSpan"].length == 0)
{
jxl.overwriteClass("uiInput","TrunkInputOutSpanTwo");
}
else
{
jxl.overwriteClass("uiInput","TrunkInputTwo");
}
}
if(userInterface["uiNumberFirstSpan"].length == 2)
{
jxl.overwriteClass("uiInput","TrunkInputOneWithPrefix2");
}
else if(userInterface["uiNumberFirstSpan"].length == 4)
{
jxl.overwriteClass("uiInput","TrunkInputOneWithPrefix4");
}
if (userInterface["uiUserprefix"].length == 6)
{
jxl.addClass("ShowUsername","IsUserprefix6");
}
else
{
jxl.removeClass("ShowUsername", "IsUserprefix6");
}
for (var id in userInterface)
{
showData(id, userInterface[id]);
tif = id + "_1";
showData(tif, userInterface[id]);
for(i = 1; i <= gUsbaleSipCounts; i++)
{
tif = id + "_trunk_" + i;
showData(tif, userInterface[id]);
}
}
jxl.setValue("SeparatedNumbers",secondInput ? "2": "1");
if (providerlist[provider_id]["display"]["ShowUsername"] && provider_id != "other")
{
if (provider_id == "tonline")
{
jxl.setValue("IsUsername","2");
}
else
{
jxl.setValue("IsUsername","1");
}
}
else
{
jxl.setValue("IsUsername","0");
}
if (userInterface["uiRegistrar"] && provider_id != "other")
{
jxl.setValue("IsRegistrar","1");
}
else
{
jxl.setValue("IsRegistrar","0");
}
}
function setSafeProvider(provider_id, is_ui)
{
if(g_safeProvider == "" || (is_ui && g_safeProvider=="other_non_ui") || (g_safeProvider != jxl.getValue("uiSipProvider")))
{
g_safeProvider = provider_id;
}
}
function resetTable()
{
for (i = jxl.getValue("countTrunk"); i > 1 ; i--)
{
jxl.addClass("uiNumberLine_"+i, "DontShow");
}
jxl.setDisabled("uiAddnumber",false);
}
function onProviderChange(providerlist, provider_id, is_ui)
{
var isTonline = false;
if (provider_id == "tonline")
{
isTonline = true;
}
if (provider_id=="other_non_ui" && is_ui)
{
if (g_safeProvider == jxl.getValue("uiSipProvider"))
{
provider_id = g_safeProvider;
}
}
if (!providerlist[provider_id])
{
provider_id="other";
}
g_mode = providerlist[provider_id].mode;
showDisplay(providerlist, provider_id, is_ui);
if(g_safeProvider != provider_id && provider_id != "other")
{
jxl.walkDom("uiLogonInputArea","input", clearInput);
jxl.walkDom("uiNumberFormat","input", clearInput);
jxl.walkDom("uiPerformanceFeatures","input", clearInput);
jxl.walkDom("uiAssistanceCustomerCenters","input", clearInput);
resetTable();
gResetedData = true;
}
if((g_safeProvider == provider_id) || (g_safeProvider!="" && provider_id=="other"))
{
setFonData(g_fondata, false);
}
else
{
setFonData(g_ProviderList[provider_id], true);
}
if (provider_id == "other" && jxl.get("uiSipActiv") && g_fondata[0])
{
jxl.setValue("uiNumberInput1_1", g_fondata[0].number);
}
if (provider_id.indexOf("unknown_") == 0)
{
jxl.setValue("uiRegistrar",providerlist[provider_id]["dataValues"]["registrar"][0]);
jxl.setValue("uiProxy", providerlist[provider_id]["dataValues"]["outboundproxy"]);
}
onViewMSN();
var elem=jxl.get("uiSipActiv");
var enable=true;
if (elem)
{
enable=elem.checked;
}
jxl.setChecked("uiTcomActiv",jxl.getValue("uiUsername") != "anonymous@t-online.de");
if (enable)
{
if (isTonline)
{
if (jxl.getValue("uiUsername") == "anonymous@t-online.de")
{
onUserInputActivated(false);
}
else
{
onUserInputActivated(true);
}
}
else
{
onUserInputActivated(true);
}
}
}
function showDivTrunkAll(mode)
{
var countTrunk = jxl.getValue("countTrunk");
jxl.addClass("uiShowDirectDialIn", "DontShow");
jxl.addClass("uiNameExplainTextForTrunk", "DontShow");
jxl.addClass("uiTrunkAll", "DontShow");
jxl.removeClass("uiNoTrunk", "DontShow");
jxl.removeClass("uiNameExplainText", "DontShow");
jxl.addClass("uiNameExplainTextForTrunk", "DontShow");
if (mode == "directdialin" || mode == "differenttrunk")
{
jxl.removeClass("uiTrunkAll", "DontShow");
jxl.addClass("uiNoTrunk", "DontShow");
jxl.addClass("uiNameExplainText", "DontShow");
if (mode == "directdialin")
{
jxl.removeClass("uiShowDirectDialIn", "DontShow");
}
else
{
jxl.removeClass("uiNameExplainTextForTrunk", "DontShow");
}
for(i = 1; i <= countTrunk;i++)
{
jxl.removeClass("uiNumberLine_"+i, "DontShow");
}
}
jxl.setValue("uiTrunkActive",(mode == "directdialin" || mode == "differenttrunk")?"1":"0");
}
function doAddTrunkNumber()
{
var countTrunk = jxl.getValue("countTrunk");
var newCountTrunk = parseInt(countTrunk)+1;
jxl.removeClass("uiNumberLine_"+newCountTrunk, "DontShow");
jxl.setValue("countTrunk", newCountTrunk);
setEnableAddnumber();
}
function noZero (str) {
if (str.substr(0,1) != "0") return str;
return str.substr(1, str.length-1);
}
function GetOKZohneNull(id)
{
var h = document.getElementById(id);
if (h == null) return "";
var nr = jslDoEliminateBlanks(h.value);
return noZero(nr);
}
function GetOKZDisplay(id)
{
var h = document.getElementById(id);
if (h == null) return "";
var nr = h.value;
if (nr.length == 0) return nr;
if (nr.substr(0,1) == "0") return nr;
return "0"+nr;
}
function OnEMailAdresse()
{
var pp = window.open("https://kundencenter.telekom.de/kundencenter/dienste-abos/email-sms/e-mail-adresse-einrichten.html", "_blank");
}
function OnPasswort()
{
var pp = window.open("https://kundencenter.telekom.de/festnetz/services/recovery/password/index.xhtml", "_blank");
}
function OnCallSettings()
{
var pp = window.open("https://telweb.t-online.de/telcenter/", "_blank");
}
function DeactivateAll(checked)
{
var addNumberButton = jxl.get("uiAddnumber");
jxl.enableNode("uiLogonInputArea", checked);
jxl.enableNode("uiNumberFormat", checked);
jxl.enableNode("uiPerformanceFeatures", checked);
jxl.enableNode("uiAssistanceCustomerCenters", checked);
if (checked)
{
setEnableAddnumber();
}
}
function clearPasswordfield()
{
if (jxl.getValue("uiPwd") == "****")
{
jxl.setValue("uiPwd", "");
}
}
function isTrunkActivated(providerList)
{
var cur_provider=jxl.getValue("uiSipProvider")
if (!providerList[cur_provider])
{
cur_provider="other";
}
var isTrunk = false
if (providerList[cur_provider].mode == "directdialin" || providerList[cur_provider].mode == "differenttrunk")
{
isTrunk = true;
}
return (isTrunk);
}
function isFonumber (number) {
if (number.match("[^0-9\*\#]") != null) return false;
return true;
}
function onViewMSN()
{
var show=gShowMSN;
var cur_provider = ""
if (!isTrunkActivated(g_ProviderList))
{
var internetNumber = jxl.getValue("uiNumberInput1_1")
cur_provider=jxl.getValue("uiSipProvider")
if (!g_ProviderList[cur_provider])
{
cur_provider="other";
}
if (g_ProviderList[cur_provider].uiNumberInput2)
{
internetNumber = jxl.getValue("uiNumberInput2_1")
}
if (!isFonumber(internetNumber))
{
internetNumber.replace("+","");
internetNumber.replace("(","");
internetNumber.replace(")","");
internetNumber.replace("/","");
internetNumber.replace("-","");
if (!isFonumber(internetNumber))
{
show=true;
}
}
}
jxl.setDisabled("uiMSN",!show);
jxl.display("ShowMSN",show);
jxl.setValue("uiIsMsnVisible",show?"1":"0");
}
function setEnableAddnumber()
{
jxl.setDisabled("uiAddnumber", jxl.getValue("countTrunk") >= gUsbaleSipCounts);
}
function initFormHandler()
{
var form = document.forms.MainForm;
var nextIdx = {};
addChangeHandler();
jxl.addEventHandler(form, "click", clickHandler);
var countTrunk = jxl.getValue("countTrunk");
var prioSelect = null;
function doDeleteNumber(idx)
{
countTrunk = jxl.getValue("countTrunk");
var input1 = "";
var input2 = "";
idx = Number(idx);
for (var i = idx; i < countTrunk; i++)
{
jxl.setValue("uiNumberInput1_trunk_"+String(i),jxl.getValue("uiNumberInput1_trunk_"+String(i+1)));
jxl.setValue("uiSipName_trunk_"+String(i),jxl.getValue("uiSipName_trunk_"+String(i+1)));
}
jxl.setValue("uiNumberInput1_trunk_"+countTrunk,"");
jxl.setValue("uiNumberInput2_trunk_"+countTrunk,"");
jxl.setValue("uiSipName_trunk_"+countTrunk,"");
jxl.addClass("uiNumberLine_"+countTrunk, "DontShow");
jxl.setValue("countTrunk",countTrunk-1);
setEnableAddnumber();
}
function clickHandler(evt) {
var tgt = jxl.evtTarget(evt);
var id = tgt.id || "";
if (id.indexOf("uiDeletenumber") < 0)
{
tgt = jxl.evtTarget(evt, "submit");
if (tgt)
{
id = tgt.id || "";
}
}
if (id.indexOf("uiDeletenumber") == 0)
{
doDeleteNumber(id.substr(14));
return jxl.cancelEvent(evt);
}
}
function changeHandler(evt) {
var tgt = jxl.evtTarget(evt);
var name = tgt.name || "";
}
function addChangeHandler(newDiv) {
if (form.addEventListener) {
if (!newDiv) {
jxl.addEventHandler(form, "change", changeHandler);
}
}
else {
if (newDiv) {
var elems = jxl.walkDom(newDiv, "input");
}
else {
var elems = form.elements;
}
for (var i = 0, len = elems.length; i < len; i++) {
jxl.addEventHandler(elems[i], "change", changeHandler);
}
}
}
}
ready.onReady(initFormHandler);
