var ha_sets = ha_sets || (function() {
"use strict"
var lib = {};
var doc = window.document;
var szImage_Path = "/css/default/images"
var szLed_On_Path = szImage_Path + "/led_green.gif"
var szLed_Off_Path = szImage_Path + "/led_gray.gif"
var szImage_Switch_On = "/icon_schalter_on.png";
var szImage_Switch_Off = "/icon_schalter_off.png";
var szImage_Switch_On_Mobile = "/buttons_ein.png";
var szImage_Switch_Off_Mobile = "/buttons_aus.png";
var szText_Connected = "{?4284:775?}";
var szText_Not_Connected = "{?4284:556?}";
var szText_Switch_On = "{?4284:244?}";
var szText_Switch_Off = "{?4284:790?}";
var szText_TitleAddon = "{?4284:387?}";
lib.is_mobile = false;
lib.connect_State_Img_Id = "uiDeviceConnectState_";
lib.connect_State_Text_Id = "uiDeviceConnectStateText_";
// used at **_overview
lib.switch_Img_Id = "uiView_Img_";
lib.switch_Value_Id = "uiView_ImageSwitch_";
lib.temperature_Id = "uiView_Temperature_",
// used at ** tab-pages
lib.switch_State_Img_Id = "uiDeviceSwitchState_";
lib.switch_State_Text_Id = "uiDeviceSwitchStateText_";
lib.setMobile = function( bValue) {
lib.is_mobile = bValue;
}
lib.is_Mobile = function() {
return lib.is_mobile;
}
lib.setConnectStateOf = function( szID, szValue) {
var szSrc = "";
var szTitle = "";
if ( szValue == "2") {
szSrc = szLed_On_Path;
szTitle = szText_Connected;
} else {
szSrc = szLed_Off_Path;
szTitle = szText_Not_Connected;
}
jxl.changeImage( lib.connect_State_Img_Id + szID, szSrc, szTitle);
jxl.setText( lib.connect_State_Text_Id + szID, szTitle);
}
lib.setSwitchStateOf = function( szID, szValue) {
var szSrc = "";
var szTitle = "";
if ( szValue == "1") {
szSrc = szLed_On_Path;
szTitle = szText_Switch_On;
} else {
szSrc = szLed_Off_Path;
szTitle = szText_Switch_Off;
}
jxl.changeImage( lib.switch_State_Img_Id + szID, szSrc, szTitle);
jxl.setText( lib.switch_State_Text_Id + szID, szTitle);
}
lib.setOutletSwitchOf = function( szID, szValue, szLock) {
var szSrc = "";
var szTitle = "";
if ( szValue == "1") {
if ( lib.is_mobile == true) {
szSrc = szImage_Switch_On_Mobile;
} else {
szSrc = szImage_Switch_On;
}
szTitle = szText_Switch_On;
} else {
if ( lib.is_mobile == true) {
szSrc = szImage_Switch_Off_Mobile;
} else {
szSrc = szImage_Switch_Off;
}
szTitle = szText_Switch_Off;
}
if ( szLock == "7") {
szTitle = szTitle + szText_TitleAddon;
}
jxl.changeImage( lib.switch_Img_Id+szID, szImage_Path + szSrc, szTitle);
jxl.setValue( lib.switch_Value_Id+szID, szValue);
var a_Tag=jxl.get("uiView_SwitchOnOff"+szID);
if (a_Tag) {
var parentTd=a_Tag.parentElement;
jxl.removeClass(parentTd,"on");
jxl.removeClass(parentTd,"off");
jxl.addClass(parentTd,szValue=="1"?"on":"off");
}
};
lib.setTemperature = function( szID, nValue) {
nValue = nValue/10;
nValue = nValue.toFixed(1);
var szValue = lib.formatAsFloat( nValue.toString());
jxl.setText( lib.temperature_Id+szID, (szValue+" °C") );
};
lib.formatAsFloat = function( szValue) {
var szRet = szValue;
szRet = szRet.replace( ".", ",");
return szRet;
};
return lib;
})();
