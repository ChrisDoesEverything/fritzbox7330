<?lua
require"general"
require("fon_numbers_html")
box.out([[<div>]])
if TXT_CHANGE then
box.out([[{?648:82?}]])
else
box.out([[{?648:819?}]])
end
box.out([[</div>]])
box.out([[<hr>]])
box.out([[<h4 id="uiTitleLogonData" class=" titlemark DontShow">]]) box.out([[{?648:2706?}]]) box.out([[</h4>
<div id="uiLogonData">
<div id="uiShowSipActiv">]])
if not g_num.new and not g_num.is_assi then
box.out([[<input type="checkbox" id="uiSipActiv" name="sip_activ" onclick="DeactivateAll(this.checked)"><label for="uiSipActiv">]])
if TXT_CHANGE then
box.html([[{?648:241?}]])
else
box.html([[{?648:71?}]])
end
box.out([[</label>]])
end
box.out([[</div><!--uiShowSipActiv-->
<div id="uiLogonInputArea">]])
box.out([[<div id="uiShowProvider" class="formular titlemark DontShow">
<label for="uiSipProvider">{?648:49?}</label>]])
require ("isp")
local is_provider_ui=false
if isp.show_1und1_select() then
is_provider_ui=true
box.out([[<select class="SelProvider" id="uiSipProviderUI" name="sipprovider_ui" onchange="onProviderChange(g_ProviderList, value,]]..tostring(is_provider_ui)..[[)">]])
if g_num.new then
box.out(sip_providerlist.get_option_ui("1und1",false))
else
box.out(sip_providerlist.get_option_ui(g_num.fondata[1].provider_id, false))
end
box.out([[</select>]])
local visible="display:none"
if (provider=="other") then
visible=""
end
box.out([[<div id="uiOtherProvider" style="]]..visible..[[">]]) box.out([[<label for="uiSipProvider"></label><select class="SelProvider" id="uiSipProvider" name="sipprovider" onchange="onProviderChange(g_ProviderList, value,]]..tostring(is_provider_ui)..[[)">]])
if g_num.new then
box.out(sip_providerlist.get_option_non_ui("other",false))
else
box.out(sip_providerlist.get_option_non_ui(g_num.fondata[1].provider_id, false))
end
box.out([[</select></div><!--uiOtherProvider-->]])
else
box.out([[<select class="SelProvider" id="uiSipProvider" name="sipprovider" onchange="onProviderChange(g_ProviderList, value,]]..tostring(is_provider_ui)..[[)">]])
if g_num.new then
box.out(sip_providerlist.get_option("other",false))
else
box.out(sip_providerlist.get_option(g_num.fondata[1].provider_id, false))
end
box.out([[</select>]])
end
box.out([[</div><!--uiShowProvider-->]])
box.out(fon_numbers_html.show_dialdirectin_input_html())
box.out(fon_numbers_html.show_number_input_html())
box.out([[
<div id="uiShowTOnlineHint" class="formular titlemark DontShow">
<input type="checkbox" id="uiTcomActiv" name="tcom_activ" onclick="onUserInputActivated(this.checked)"><label id="labeltcom" for="uiTcomActiv">]]) box.out([[{?648:827?}]]) box.out([[</label>
<div id = "T1" class="formular">]]) box.html([[{?648:140?}]]) box.out([[</div>
</div><!--uiShowTOnlineHint-->
<div id="uiShowUsername" class="formular titlemark DontShow">
<label id="uiLabelUsername" for="uiUsername"></label><span id="uiUserprefix" ></span><input type="text" value="" name="username" id="uiUsername"><span id="uiUserPostfix" ></span>
</div><!--uiShowUsername-->
<div id="uiShowPassword" class="formular titlemark DontShow">
<label id="uiLabelPwd" for="uiPwd"></label><input type="text" name="pwd" id="uiPwd" value="" autocomplete="off">
</div><!--uiShowPassword-->]])
if config.annex == "A" then
box.out([[
<div id="Trunk" class="formular">
<label for="uiTrunk">]]) box.html([[{?648:641?}]]) box.out([[</label>
<input type="text" value="]]) box.html(g_num.fondata[1].Trunk) box.out([[name="trunk" id="uiTrunk">
</div>]])
end
box.out([[
<div id="uiShowRegistrar" class="formular titlemark DontShow">
<label for="uiRegistrar">]]) box.out([[{?648:895?}]]) box.out([[</label><input type="text" value="" name="registrar" id="uiRegistrar">
</div>
<div id="uiShowProxy" class="formular titlemark DontShow">
<label for="uiOutboundproxy">]]) box.out([[{?648:572?}]]) box.out([[</label><input type="text" value="" name="outboundproxy" id="uiOutboundproxy">
</div>
<div id="uiShowStun" class="formular titlemark DontShow">
<label for="uiStun">]]) box.out([[{?648:87?}]]) box.out([[</label><input type="text" value="" name="stunserver" id="uiStunserver">
</div>
</div><!--uiLogonInputArea-->
</div><!--uiLogonData-->
<hr id="uiLine" class="DontShow">
<h4 id="uiTitleNumFormat" class=" titlemark DontShow">]]) box.html([[{?648:503?}]]) box.out([[</h4>
<div id="uiNumberFormat">]])
if g_num.is_expert then
box.out([[<div id="uiShowExp" class="formular titlemark DontShow"><p>]])
box.html([[{?648:903?}]]) box.out([[</p>]])
box.out([[
<table id="uiPreFixTbl">]])
box.out([[<tr>
<td><span>]]) box.html([[{?648:482?}]]) box.out([[</span></td>
<td><input type="radio" id="uiLkz1" name="lkz" value="0"></td>
<td><label for="uiLkz1">]]) box.html([[{?648:9879?}]]) box.out([[</label></td>]])
box.out([[<td><input type="radio" id="uiLkz2" name="lkz" value="1" ></td>]])
box.out([[<td><label for="uiLkz2">]]) box.html([[{?648:181?}]])
if tostring(g_num.lkz) ~= "" then
box.out([[ (]]..tostring(g_num.lkz)..[[)]])
end
box.out([[</label></td>]])
box.out([[<td><input type="radio" id="uiLkz3" name="lkz" value="2" ></td><td><label for="uiLkz3">]]) box.html([[{?648:550?}]])
if tostring(g_num.lkzprefix) ~= "" then
box.out([[ (]]..tostring(g_num.lkzprefix)..tostring(g_num.lkz)..[[)]])
end
box.out([[</label></td>]])
box.out([[</tr>]])
box.out([[<tr><td><span>{?648:922?}</span></td>
<td><input type="radio" id="uiOkz1" name="okz" value="0"></td><td><label for="uiOkz1">]]) box.html([[{?648:378?}]]) box.out([[</label></td>
<td><input type="radio" id="uiOkz2" name="okz" value="1"></td><td><label for="uiOkz2">]]) box.html([[{?648:342?}]])
if tostring(g_num.okz) ~= "" then
box.out([[ (]]..tostring(g_num.okz)..[[)]])
end
box.out([[</label></td>]])
box.out([[<td><input type="radio" id="uiOkz3" name="okz" value="2"></td><td><label for="uiOkz3">]]) box.html([[{?648:403?}]])
if g_num.okzprefix ~= "" then
box.out([[ (]]..tostring(g_num.okzprefix)..tostring(g_num.okz)..[[)]])
end
box.out([[</label></td>]])
box.out([[</tr>]])
box.out([[</table>
</div><!--uiShowExp-->]])
end
box.out([[<div id="uiShowEmergency" class="formular titlemark DontShow">
<input type="checkbox" name="emergencyrule" id="uiEmergencyRule">
<label for="uiEmergencyRule" >]]) box.html([[{?648:56?}]]) box.out([[</label>
</div><!--uiShowEmergency-->
<div id="uiShowSipAKN" class="formular titlemark DontShow">
<input type="checkbox" name="akn" id="uiAKN">
<label for="uiAKN" >]]) box.html([[{?648:30?}]]) box.out([[</label>
</div><!--uiShowSipAKN-->
<div id="uiShowAlternatePrefix_USA" class="formular titlemark DontShow">
<input type="checkbox" name="alternateprefix" id="uiAlternatePrefix_USA"><label for="uiAlternatePrefix_USA" >]])
box.html([[{?648:6519?}]])
box.out([[</label><div class="form_checkbox_explain">]]) box.html([[{?648:396?}]]) box.out([[</div>
</div><!--uiShowAlternatePrefix_USA-->
<div id="uiShowUseinternatcalling_numbe" class="formular titlemark DontShow">
<input type="checkbox" id="uiUse_Internat_Calling_Numb" name="use_internat_calling_numb"><label for="uiUse_Internat_Calling_Numb">]]) box.html([[{?648:329?}]]) box.out([[</label>
</div><!--uiShowUseinternatcalling_numbe-->
<div id="uiShowSuffixBlock" class="formular titlemark DontShow">
<label for="uiSuffix">]])
if TXT_CHANGE then
box.html([[{?648:216?}]])
else
box.html([[{?648:607?}]])
end
box.out([[</label>
<input type="text" value="" name="Suffix" id="uiSuffix" var="">
</div><!--uiShowSuffixBlock-->
</div><!--uiNumberFormat-->]])
box.out([[<hr id="uiLine2" class="DontShow">]])
box.out([[<h4 id="uiTitlePerf" class=" titlemark DontShow">]]) box.html([[{?648:315?}]]) box.out([[</h4>]])
box.out([[<div id="uiPerformanceFeatures">]])
box.out([[<div id="uiShowDtmf" class="formular titlemark DontShow">
<label for="uiDtmfcfg">]]) box.html([[{?648:983?}]]) box.out([[</label>
<select id="uiDtmfcfg" name="dtmfcfg">
<option value="0">]]) box.html([[{?648:50?}]]) box.out([[</option>
<option value="1">]]) box.html([[{?648:531?}]]) box.out([[</option>
<option value="2">]]) box.html([[{?648:297?}]]) box.out([[</option>
<option value="3">]]) box.html([[{?648:782?}]]) box.out([[</option>
</select>
</div><!--uiShowDtmf-->
<div id="uiShowClir" class="formular titlemark DontShow">
<label for="uiClirtype" >]]) box.html([[{?648:613?}]]) box.out([[</label>
<select id="uiClirtype" name="clirtype">
<option value="0" >]]) box.html([[{?648:116?}]]) box.out([[</option>
<option value="1" >]]) box.html([[{?648:266?}]]) box.out([[</option>
<option value="2" >]]) box.html([[{?648:671?}]]) box.out([[</option>
<option value="7" >]]) box.html([[{?648:357?}]]) box.out([[</option>
<option value="8" >]]) box.html([[{?648:386?}]]) box.out([[</option>
<option value="4" >]]) box.html([[{?648:337?}]]) box.out([[</option>
<option value="5" >]]) box.html([[{?648:721?}]]) box.out([[</option>
<option value="6" >]]) box.html([[{?648:351?}]]) box.out([[</option>
</select>
</div><!--uiShowClir-->
<div id="uiShowDditype" class="formular titlemark DontShow">
<label for="uiDdiType">]]) box.html([[{?648:585?}]]) box.out([[</label>
<select id="uiDdiType" name="dditype">
<option value="0" >]]) box.html([[{?648:293?}]]) box.out([[</option>
<option value="1" >]]) box.html([[{?648:438?}]]) box.out([[</option>
<option value="2" >]]) box.html([[{?648:961?}]]) box.out([[</option>
<option value="3" >]]) box.html([[{?648:3411?}]]) box.out([[</option>
<option value="4" >]]) box.html([[{?648:912?}]]) box.out([[</option>
</select>
</div><!--uiShowDditype-->
<div id="uiShowSipUri" class="formular titlemark DontShow">
<input type="checkbox" id="uiAuthname_Needed" name="authname_needed" var="">
<label for="uiAuthname_Needed">]])
if TXT_CHANGE then
box.html([[{?648:3740?}]])
else
box.html([[{?648:461?}]])
end
box.out([[
</label>
</div><!--uiShowSipUri>]])
box.out([[
<div id="uiShowG726NACHRFC3551" class="formular titlemark DontShow">
<input type="checkbox" name="g726_via_3551rfc" id="uiG726_via_3551rfc"><label for="uiG726_via_3551rfc">]]) box.html([[{?648:475?}]]) box.out([[</label>
</div><!--uiShowG726NACHRFC3551-->
<div id="uiShowCCBS" class="formular titlemark DontShow">
<input type="checkbox" name="ccbs_supported" id="uiCcbs_Supported"><label for="uiCcbs_Supported">]]) box.html([[{?648:186?}]]) box.out([[</label>
</div><!--uiShowCCBS-->]])
if g_num.is_expert then
box.out([[
<div id="uiShowOverInternet" class="formular titlemark DontShow"><input type="checkbox" name="route_always_over_internet" id="uiRoute_Always_Over_Internet"><label for="uiRoute_Always_Over_Internet" >]]) box.out([[{?648:379?}]]) box.out([[</label><br>
<div class="form_checkbox_explain">]]) box.html([[{?648:640?}]]) box.out([[</div>
</div><!--uiShowOverInternet-->]])
end
if general.is_ipv6_active() then
if g_num.is_expert then
box.out([[
<div id="uiShowIp" class="formular titlemark DontShow">
<label for="uiPrefer">]]) box.html([[{?648:106?}]]) box.out([[</label><select id="uiPrefer" name="prefer" >
<option value="2">]]) box.html([[{?648:950?}]]) box.out([[</option><option value="3">]]) box.html([[{?648:887?}]]) box.out([[</option>
<option value="0">]]) box.html([[{?648:133?}]]) box.out([[</option>
<option value="1">]]) box.html([[{?648:830?}]]) box.out([[</option></select>
</div><!--uiShowIp-->]])
end
else
box.out([[<input type="hidden" id="uiPrefer" name="prefer" value="0">]])
end
if g_num.is_expert or g_num.is_assi then
box.out([[
<div id="uiShowOKZ" class="formular titlemark DontShow">
<input type="checkbox" ]]) box.out([[fon_numbers_html.checkOKZNoPrefix()]]) box.out([[ id="uiUseOKZProvider" name="useokzprovider"><label for="uiUseOKZProvider">]]) box.html([[{?648:487?}]]) box.out([[</label>]])
if g_num.okz=="" and g_num.is_assi then
box.out(general.sprintf([[<p>%1</p>]],box.tohtml([[{?648:58?}]])))
box.out(general.sprintf(
[[<div class="formular">
<label for="uiOKZ">%1</label>
<input type="text" id="uiOKZ" name="okz" value="%2">
</div>]], box.tohtml([[{?648:65?}]]),g_num.okz))
end
box.out([[</div><!--uiShowOKZ-->]])
end
box.out([[
<div id="uiShowSpit" class="formular titlemark DontShow">
<div >]]) box.html([[{?648:8800?}]]) box.out([[</div>
<input type="text" id="uiSpit" name="spit" value=""><label for="uiSpit">]]) box.html([[{?648:663?}]]) box.out([[</label>
</div><!--uiShowSpit-->
</div><!--uiPerformanceFeatures-->
<h4 id="uiTitleCustom" class=" titlemark DontShow">{?648:43?}</h4>
<div id="uiAssistanceCustomerCenters">
<div name="tcomlinks" id="uiShowTComLinks" class=" titlemark DontShow">]])
box.html([[{?648:934?}]])
box.out([[
<div class="formular">
<label>]]) box.html([[{?648:5612?}]]) box.out([[</label>
<button name="button_pushbutton" id="uibutton_Pushbutton" onclick="OnCallSettings()">]]) box.html([[{?648:442?}]]) box.out([[</button>
</div>
<div class="formular">
<label>]]) box.html([[{?648:3830?}]]) box.out([[</label>
<button name="button_emailadresse" id="uibutton_EMailAdresse" onclick="OnEMailAdresse()" >]]) box.html([[{?648:760?}]]) box.out([[</button>
</div>
<div class="formular">
<label>]]) box.html([[{?648:595?}]]) box.out([[</label>
<button name="button_passwort" id="uibutton_Passwort" onclick="OnPasswort()">]]) box.html([[{?648:8468?}]]) box.out([[</button>
</div>
</div><!--uiShowTComLinks-->
</div><!--uiAssistanceCustomerCenters-->]])
if g_num.lkz == "" then
box.out([[<p>]]) box.html([[{?648:593?}]]) box.out([[</p>]])
end
?>
