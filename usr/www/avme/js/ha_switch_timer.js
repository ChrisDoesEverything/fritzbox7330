function whileNetDeviceNoCal( bIsNetDevice) {
if ( bIsNetDevice == true) {
jxl.disable( "uiView_SwitchOnTimeUse_calendar");
jxl.disable( "LabeluiView_SwitchOnTimeUse_calendar");
}
}
function insideInit( nGroupID, szAutoTimerUsed, szTimerCtrlID, timerCtrlDatas, szLastCalState) {
if (szTimerCtrlID != "") {
if ( timerCtrlDatas.length > 0) {
g_timer = new Timer( szTimerCtrlID, timerCtrlDatas);
} else {
g_timer = new Timer( szTimerCtrlID, new Array());
}
}
OnChange_SwitchOnTimeUse( szAutoTimerUsed);
if ( ( nGroupID.toString() != "nil") && (szAutoTimerUsed == "calender") && ( szLastCalState == "2") ) {
setTimeout( "PollCalenderState("+nGroupID+")", 1000 );
}
}
function GetGoogleStatusText( szStatus) {
var szRetCode = "{?2754:673?}"+szStatus+"{?2754:514?}";
switch( szStatus) {
case "1":
szRetCode = "{?2754:778?}";
break;
case "2":
szRetCode = "{?2754:105?}";
break;
case "11":
szRetCode = "{?2754:512?}";
break;
case "10":
szRetCode = "{?2754:1?}";
break;
case "8":
case "12":
szRetCode = "{?2754:827?}";
break;
case "16":
case "17":
case "18":
case "19":
case "20":
case "21":
case "22":
szRetCode = "{?2754:8715?}"+szStatus+"{?2754:573?}";
break;
}
return szRetCode
}
function PollCalenderState( szDeviceID) {
// Ajax get zum Abfragen.
var url = encodeURI("/net/home_auto_query.lua");
url += "?" + sidParam;
url += "&" + buildUrlParam( "command", "CalendarState");
url += "&" + buildUrlParam( "id", szDeviceID);
ajaxGet( url, cb_Receive_Outlet_State_Values)
}
function cb_Receive_Calendar_State(xhr) {
var response = json(xhr.responseText || "null");
if ( response && (response.RequestResult != "0")) {
if ( response.LastState == "2") {
setTimeout( "PollCalenderState("+response.DeviceID+")", 1000)
} else {
if ( response.LastState == "0") {
jxl.setHtml( "uiView_calendar_google_NextSwitch", response.LastSwitch);
jxl.setHtml( "uiView_calendar_google_LastSync", response.LastSync);
jxl.addClass( "uiView_calendar_google_LastSync", "output");
jxl.setStyle( "uiView_calendar_google_LastSync", "width: 200px;");
jxl.display( "uiShow_GoogleState_Error", false);
jxl.display( "uiShow_GoogleState_OK", true);
} else {
szStatusText = GetGoogleStatusText( response.LastState);
jxl.setHtml( "uiView_calendar_google_CurrentStatus", szStatusText);
jxl.display( "uiShow_GoogleState_OK", false);
jxl.display( "uiShow_GoogleState_Error", true);
}
}
}
}
function OnChange_SwitchOnTimeUse( szValue) {
if ( "daily" == szValue) {
OnChange_SwitchOnActionDaily( jxl.getChecked( "uiView_SwitchOnAction_Daily"));
OnChange_SwitchOffActionDaily( jxl.getChecked( "uiView_SwitchOffAction_Daily"));
}
if ( "countdown" == szValue) {
if ( jxl.getChecked("uiView_Countdown_Manuell_Off")) {
OnChange_Countdown_Manuell_On( "0");
} else {
OnChange_Countdown_Manuell_On( "1");
}
}
if ( "sun_calendar" == szValue) {
jxl.display( "uiView_StartGeoLocation", navigator.geolocation);
jxl.display( "uiBtn_StartGeoLocation", navigator.geolocation);
OnChange_Sunrise( jxl.getChecked( "uiView_CheckboxSunrise"));
OnChange_Sunset( jxl.getChecked( "uiView_CheckboxSunset"));
}
if ( g_IsNetworkDevice == true) {
jxl.disable( "uiView_SwitchOnTimeUse_calendar");
jxl.disable( "LabeluiView_SwitchOnTimeUse_calendar");
}
jxl.enableNode( "uiView_calendar_google_Text_1", ( g_IsNetworkDevice != true));
// jxl.enableNode( "uiView_calendar_google_Text_2", ( g_IsNetworkDevice == true));
jxl.enableNode( "Label_calendar_google_calendarname", ( g_IsNetworkDevice != true));
jxl.enableNode( "uiView_calendar_google_calendarname", ( g_IsNetworkDevice != true));
jxl.display( "uiShow_TimerSetup_daily", ("daily" == szValue));
jxl.display( "uiShow_TimerSetup_weekly", ("weekly" == szValue));
jxl.display( "uiShow_TimerSetup_zufall", ("zufall" == szValue));
jxl.display( "uiShow_TimerSetup_countdown", ("countdown" == szValue));
jxl.display( "uiShow_TimerSetup_rythmisch", ("rythmisch" == szValue));
jxl.display( "uiShow_TimerSetup_single", ("single" == szValue));
jxl.display( "uiShow_TimerSetup_astro", ("sun_calendar" == szValue));
jxl.display( "uiShow_TimerSetup_calendar", ("calendar" == szValue));
g_szTimerUse = szValue;
}
function OnChange_SwitchOnActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_from_hh");
jxl.enable( "uiView_daily_from_mm");
} else {
jxl.disable( "uiView_daily_from_hh");
jxl.disable( "uiView_daily_from_mm");
}
}
function OnChange_SwitchOffActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_to_hh");
jxl.enable( "uiView_daily_to_mm");
} else {
jxl.disable( "uiView_daily_to_hh");
jxl.disable( "uiView_daily_to_mm");
}
}
function OnChange_Countdown_Manuell_On( szValue) {
if ( szValue != "0") {
jxl.enable( "uiView_countdown_time_dd_on");
jxl.enable( "uiView_countdown_time_mm_on");
jxl.disable( "uiView_countdown_time_dd_off");
jxl.disable( "uiView_countdown_time_mm_off");
} else {
jxl.enable( "uiView_countdown_time_dd_off");
jxl.enable( "uiView_countdown_time_mm_off");
jxl.disable( "uiView_countdown_time_dd_on");
jxl.disable( "uiView_countdown_time_mm_on");
}
}
function OnChange_SwitchOnActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_from_hh");
jxl.enable( "uiView_daily_from_mm");
} else {
jxl.disable( "uiView_daily_from_hh");
jxl.disable( "uiView_daily_from_mm");
}
}
function OnChange_SwitchOffActionDaily( bValue) {
if ( bValue) {
jxl.enable( "uiView_daily_to_hh");
jxl.enable( "uiView_daily_to_mm");
} else {
jxl.disable( "uiView_daily_to_hh");
jxl.disable( "uiView_daily_to_mm");
}
}
function OnChange_Countdown_Manuell_On( szValue) {
if ( szValue != "0") {
jxl.enable( "uiView_countdown_time_dd_on");
jxl.enable( "uiView_countdown_time_mm_on");
jxl.disable( "uiView_countdown_time_dd_off");
jxl.disable( "uiView_countdown_time_mm_off");
} else {
jxl.enable( "uiView_countdown_time_dd_off");
jxl.enable( "uiView_countdown_time_mm_off");
jxl.disable( "uiView_countdown_time_dd_on");
jxl.disable( "uiView_countdown_time_mm_on");
}
}
function OnChange_SwitchOnActionSingle( szValue) {
}
function OnChange_Sunrise( bValue) {
jxl.enableNode( "uiShow_Sunrise", bValue);
}
function OnChange_Sunset( bValue) {
jxl.enableNode( "uiShow_Sunset", bValue);
}
function OnClick_ShowResetGoogleArea() {
g_ShowResetGoogleArea =! g_ShowResetGoogleArea;
jxl.display( "uiView_ResetGoogleArea", g_ShowResetGoogleArea);
var img = jxl.get( "uiLink_ResetGoogleArea_Img")
if ( img) {
img.src = g_ShowResetGoogleArea ? '/css/default/images/link_closed.gif' : '/css/default/images/link_open.gif';
}
}
function OnClick_ResetGoogleCal() {
var bRetCode = confirm('{?2754:288?}');
return bRetCode;
}
function Extended_Validation_Automatic_Timer() {
if ( jxl.getChecked( "uiView_SwitchOnTimeUse_zufall")) {
if ( ( Number(g_current_zufall_from_date_year) != Number( jxl.getValue( "uiView_zufall_from_date_year"))) ||
( Number(g_current_zufall_from_date_month) != Number( jxl.getValue( "uiView_zufall_from_date_month"))) ||
( Number(g_current_zufall_from_date_day) != Number( jxl.getValue( "uiView_zufall_from_date_day"))) ||
( Number(g_current_zufall_from_time_hh) != Number( jxl.getValue( "uiView_zufall_from_time_hh"))) ||
( Number(g_current_zufall_from_time_mm) != Number( jxl.getValue( "uiView_zufall_from_time_mm"))) ||
( Number(g_current_zufall_to_date_year) != Number( jxl.getValue( "uiView_zufall_to_date_year"))) ||
( Number(g_current_zufall_to_date_month) != Number( jxl.getValue( "uiView_zufall_to_date_month"))) ||
( Number(g_current_zufall_to_date_day) != Number( jxl.getValue( "uiView_zufall_to_date_day"))) ||
( Number(g_current_zufall_to_time_hh) != Number( jxl.getValue( "uiView_zufall_to_time_hh"))) ||
( Number(g_current_zufall_to_time_mm) != Number( jxl.getValue( "uiView_zufall_to_time_mm"))) ) {
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"));
oDate_Now = new Date()
oDate_DayNow = new Date( oDate_Now.getFullYear(), oDate_Now.getMonth(), oDate_Now.getDate());
if ( oDate_From.getTime() < oDate_DayNow.getTime()) {
val.markError("uiView_zufall_from_date_year");
val.markError("uiView_zufall_from_date_month");
val.markError("uiView_zufall_from_date_day");
var szErrorText = "{?2754:911?}";
alert( szErrorText);
return false;
}
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"));
oDate_To = new Date(jxl.getValue("uiView_zufall_to_date_year"),jxl.getValue("uiView_zufall_to_date_month")-1,jxl.getValue("uiView_zufall_to_date_day"));
if ( oDate_From.getTime() > oDate_To.getTime()) {
val.markError("uiView_zufall_from_date_year");
val.markError("uiView_zufall_from_date_month");
val.markError("uiView_zufall_from_date_day");
val.markError("uiView_zufall_to_date_year");
val.markError("uiView_zufall_to_date_month");
val.markError("uiView_zufall_to_date_day");
var szErrorText = "{?2754:217?}";
alert( szErrorText);
return false;
} else if ( oDate_From.getTime() == oDate_To.getTime()) {
oDate_From = new Date(jxl.getValue("uiView_zufall_from_date_year"),jxl.getValue("uiView_zufall_from_date_month")-1,jxl.getValue("uiView_zufall_from_date_day"),jxl.getValue("uiView_zufall_from_time_hh"),jxl.getValue("uiView_zufall_from_time_mm"));
oDate_To = new Date(jxl.getValue("uiView_zufall_to_date_year"),jxl.getValue("uiView_zufall_to_date_month")-1,jxl.getValue("uiView_zufall_to_date_day"),jxl.getValue("uiView_zufall_to_time_hh"),jxl.getValue("uiView_zufall_to_time_mm"));
if ( oDate_From.getTime() > oDate_To.getTime()) {
val.markError("uiView_zufall_from_time_hh");
val.markError("uiView_zufall_from_time_mm");
val.markError("uiView_zufall_to_time_hh");
val.markError("uiView_zufall_to_time_mm");
var szErrorText = "{?2754:859?}";
alert( szErrorText);
return false;
}
}
}
}
if ( jxl.getChecked( "uiView_SwitchOnTimeUse_weekly")) {
nWeeklySwitchCount = g_timer.ha_save("uiMainForm");
if ((nWeeklySwitchCount < 2) || (nWeeklySwitchCount > 100)) {
val.markError("uiMainForm");
var szErrorText = "{?2754:74?}";
if (nWeeklySwitchCount == 1) {
szErrorText = "{?2754:364?}";
}
if (nWeeklySwitchCount > 100) {
szErrorText = "{?2754:27?}"+nWeeklySwitchCount+"{?2754:664?}";
}
alert( szErrorText);
return false;
}
}
if (jxl.getChecked("uiView_SwitchOnTimeUse_single")) {
if ( ( Number(g_current_single_date_year) != Number( jxl.getValue( "uiView_single_date_year"))) ||
( Number(g_current_single_date_month) != Number( jxl.getValue( "uiView_single_date_month"))) ||
( Number(g_current_single_date_day) != Number( jxl.getValue( "uiView_single_date_day"))) ||
( Number(g_current_single_time_hh) != Number( jxl.getValue( "uiView_single_time_hh"))) ||
( Number(g_current_single_time_mm) != Number( jxl.getValue( "uiView_single_time_mm"))) ) {
var oDate_Single = new Date(jxl.getValue("uiView_single_date_year"),jxl.getValue("uiView_single_date_month")-1,jxl.getValue("uiView_single_date_day"),jxl.getValue("uiView_single_time_hh"),jxl.getValue("uiView_single_time_mm"));
var oDate_Now = new Date()
if ( oDate_Single.getTime() < oDate_Now.getTime()) {
val.markError("uiView_single_date_year");
val.markError("uiView_single_date_month");
val.markError("uiView_single_date_day");
val.markError("uiView_single_time_hh");
val.markError("uiView_single_time_mm");
var szErrorText = "{?2754:696?}";
alert( szErrorText);
return false;
}
}
}
if ( g_szTimerUse == "") {
var szErrorText = "{?2754:124?}";
alert( szErrorText);
return false;
}
return true;
}
function OnClick_StartGeoLocation() {
if (navigator.geolocation) {
navigator.geolocation.getCurrentPosition( cb_GetPosition, cb_GetPositionError);
}
}
function cb_GetPosition( oPosition) {
var nDirecetion_Lat = 1;
var nDirecetion_Long = 1;
if ( oPosition.coords.latitude < 0 ) {
nDirecetion_Lat = -1;
}
if ( oPosition.coords.longitude < 0 ) {
szDirecetion_Long = -1;
}
var nLatitude = (Math.abs(Number(oPosition.coords.latitude)))*3600;
var nLongitude = (Math.abs(Number(oPosition.coords.longitude)))*3600;
var nLati_Degree = Math.floor( nLatitude/3600);
var nLongi_Degree = Math.floor( nLongitude/3600);
var nLatitude_MinDez = nLatitude/60 - nLati_Degree*60;
var nLongitude_MinDez = nLongitude/60 - nLongi_Degree*60;
var nLatitude_Min = Math.floor( nLatitude_MinDez);
var nLongitude_Min = Math.floor( nLongitude_MinDez);
var nLatitude_Sec = Math.floor( (nLatitude_MinDez - nLatitude_Min)*60*1000000);
var nLongitude_Sec = Math.floor( (nLongitude_MinDez - nLongitude_Min)*60*1000000);
var nLatitude_Sec = Math.round( nLatitude_Sec/1000000);
var nLongitude_Sec = Math.round( nLongitude_Sec/1000000);
jxl.setValue("uiView_sun_latitude_degree", ha_sets.formatAsFloat(Number(oPosition.coords.latitude).toFixed(4)));
jxl.setValue("uiView_sun_longitude_degree", ha_sets.formatAsFloat(Number(oPosition.coords.longitude).toFixed(4)));
}
function cb_GetPositionError( error) {
switch(error.code) {
case error.PERMISSION_DENIED:
alert( "{?2754:807?}");
break;
case error.POSITION_UNAVAILABLE:
alert( "{?2754:719?}");
break;
case error.TIMEOUT:
alert( "{?2754:79?}");
break;
default:
alert( "{?2754:274?}"+error.code);
break;
}
}
