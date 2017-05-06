var ha_draw = ha_draw || (function() {
"use strict"
var lib = {};
lib.CurrentDate = new Date();
var ar_ScaleText_0_005 = new Array( "0","0,001", "0,002", "0,003", "0,004", "0,005");
var ar_ScaleText_0_01 = new Array( "0","0,002", "0,004", "0,006", "0,008", "0,01");
var ar_ScaleText_0_05 = new Array( "0", "0,01", "0,02", "0,03", "0,04", "0,05");
var ar_ScaleText_0_1 = new Array( "0", "0,02", "0,04", "0,06", "0,08", "0,1");
var ar_ScaleText_0_5 = new Array( "0", "0,1", "0,2", "0,3", "0,4", "0,5");
var ar_ScaleText_1 = new Array( "0", "0,2", "0,4", "0,6", "0,8", "1,0");
var ar_ScaleText_2_5 = new Array( "0", "0,5", "1", "1,5", "2", "2,5");
var ar_ScaleText_5 = new Array( "0", "1", "2", "3", "4", "5");
var ar_ScaleText_12_5 = new Array( "0", "2,5", "5", "7,5", "10", "12,5");
var ar_ScaleText_25 = new Array( "0", "5", "10", "15", "20", "25");
var ar_ScaleText_50 = new Array( "0", "10", "20", "30", "40", "50");
var ar_ScaleText_100 = new Array( "0", "20", "40", "60", "80", "100");
var ar_ScaleText_250 = new Array( "0", "50", "100", "150", "200", "250");
var ar_ScaleText_500 = new Array( "0", "100", "200", "300", "400", "500");
var ar_ScaleText_1000 = new Array( "0", "200", "400", "600", "800", "1000");
var ar_ScaleText_2500 = new Array( "0", "500", "1000", "1500", "2000", "2500");
var ar_ScaleText_5000 = new Array( "0", "1000", "2000", "3000", "4000", "5000");
var ar_ScaleText_10000 = new Array( "0", "2000", "4000", "6000", "8000", "10000");
var ar_ScaleText_25000 = new Array( "0", "5000", "10000", "15000", "20000", "25000");
var ar_ScaleText_Year = new Array( "{?492:619?}" , "{?492:465?}",
"{?492:869?}" , "{?492:151?}",
"{?492:752?}" , "{?492:886?}",
"{?492:855?}" , "{?492:292?}",
"{?492:310?}" , "{?492:366?}",
"{?492:927?}" , "{?492:414?}");
var ar_ScaleText_Year_Sel = new Array( "{?492:955?}" , "{?492:792?}",
"{?492:968?}" , "{?492:322?}",
"{?492:2715?}" , "{?492:576?}",
"{?492:401?}" , "{?492:980?}",
"{?492:264?}" , "{?492:15?}",
"{?492:884?}" , "{?492:345?}");
var ar_Weekdays_Texts = new Array( "{?492:99?}", "{?492:189?}","{?492:400?}","{?492:129?}",
"{?492:298?}","{?492:166?}","{?492:614?}");
var ar_Weekdays_Texts_Long = new Array( "{?492:285?}", "{?492:170?}",
"{?492:442?}","{?492:105?}",
"{?492:919?}","{?492:1313?}",
"{?492:360?}");
var nChart_relation = 0.7;
lib.is_mobile = false;
lib.canCanvas = false,
lib.canvas_elem = new Object();
lib.canvas_context = new Object();
var g_canvasIdDefault = "avm";
lib.VoltScaleRange = 50;
lib.n_X_Left_Top = 35;
lib.n_Y_Left_Top = 40;
lib.n_X_Bottom_Right = 35;
lib.n_Y_Bottom_Right = 40;
lib.n_Monitor_Width = 700;
lib.n_Monitor_Height = 250;
lib.n_X_CanvasSize = lib.n_X_Left_Top + lib.n_Monitor_Width + lib.n_X_Bottom_Right; // Default-Ausgangswerte für <canvas>-Element
lib.n_Y_CanvasSize = lib.n_Y_Left_Top + lib.n_Monitor_Height + lib.n_Y_Bottom_Right; // für die Destop-Darstellung.
// vordefinierte Farbwerte
var szPowerLineColor = "#6EC462";
var szPowerFillColor = "#6EC462";
var szVoltLineColor = "#000000";
var szVoltFillColor = "#FFAA26";
var szChartLineColor = "#F5A828";
var sChartFillColor = "#F5A828";
var szDateLine_Color = "#8DBFEE";
lib.szColor_Backgrd = "#F8F8F0"; // canvas Background
lib.szColor_Backgrd_1 = "#8DA4A3"; // monitor Background colors
lib.szColor_Backgrd_2 = "#EFEFEF";
lib.szColor_Backgrd_3 = "#EFEFEF";
lib.szColor_HelpLine_Horz = "#D7E1E6";
lib.szColor_HelpLine_Vert = "#D7E1E6";
lib.szColor_ScaleLine = "#8DA4A3";
lib.szColor_ScaleText = "#7B8892";
lib.szColor_TextInfo = "#3F464C";
lib.szColor_TextInfoErr = "#FF0000";
lib.ar_EnergyValues = new Object();
lib.ar_RectValues = new Object();
lib.n_MaxValueToDraw = new Object();
lib.n_MaxEnergy_Amount = new Object();
lib.n_CurrentFactor = new Object();;
lib.n_perviousFactor = new Object();;
lib.b_Draw_Volt_Line = true;
lib.n_Tarif_Value = 0.0;
lib.n_CO2_Output = 0.0;
lib.n_EM_ValueType = "2";
lib.init = function( sz_Canvasname, nWidth, nHeight, canvasID) {
var retCode = false;
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.canvas_elem[canvasID] = jxl.get(sz_Canvasname);
lib.canvas_elem[canvasID].width = lib.n_X_CanvasSize;
lib.canvas_elem[canvasID].height = lib.n_Y_CanvasSize;
lib.ar_EnergyValues[canvasID] = new Array();
lib.n_MaxValueToDraw[canvasID] = 0;
lib.n_MaxEnergy_Amount[canvasID] = 0;
lib.n_CurrentFactor[canvasID] = 0;
lib.n_perviousFactor[canvasID] = -1;
if ((lib.canvas_elem[canvasID] != null) && (lib.canvas_elem[canvasID].getContext != null)) {
if (lib.is_Mobile()) {
lib.n_X_CanvasSize = nWidth;
lib.n_Y_CanvasSize = nHeight;
lib.canvas_elem[canvasID].width = lib.n_X_CanvasSize;
lib.canvas_elem[canvasID].height = lib.n_Y_CanvasSize;
}
lib.canvas_context[canvasID] = lib.canvas_elem[canvasID].getContext( "2d");
lib.canCanvas = true;
retCode = true;
}
lib.n_Monitor_Width = nWidth - lib.n_X_Left_Top - lib.n_X_Bottom_Right;
lib.n_Monitor_Height = nHeight - lib.n_Y_Left_Top - lib.n_Y_Bottom_Right;
return retCode;
}
lib.get_Context = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return lib.canvas_context[canvasID];
}
lib.set_EnergyValues = function( arValues, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.ar_EnergyValues[canvasID] = arValues;
if ( arValues.length == 0) {
lib.n_CurrentFactor[canvasID] = 0;
lib.n_perviousFactor[canvasID] = -1;
lib.n_MaxValueToDraw[canvasID] = 0;
}
}
lib.EnergyValuesSize = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return lib.ar_EnergyValues[canvasID].length;
}
lib.EnergyValueOf = function( szEnergyType, nIdx, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nRetValue = 0;
switch( szEnergyType) {
case "24h":
nRetValue = get_ShowFactor( "Wh", Number( lib.ar_EnergyValues[canvasID][nIdx].power));
break;
case "week":
case "month":
case "year":
nRetValue = get_ShowFactor( "kWh", ( Number( lib.ar_EnergyValues[canvasID][nIdx].power)/1000));
break;
}
if ( lib.EM_ValueType() == 1) {
nRetValue = nRetValue.toFixed(2);
} else {
nRetValue = nRetValue.toFixed(3);
}
return nRetValue;
}
lib.set_Date = function( oDate) {
if ( oDate == null) {
lib.CurrentDate = new Date();
} else {
lib.CurrentDate = oDate;
}
}
lib.Current_Date = function() {
return lib.CurrentDate;
}
lib.MinsTillNextQuarter = function() {
return (15-(lib.CurrentDate.getMinutes()%15));
}
lib.TimeTillNextWeekSkip = function() {
return (5-(lib.CurrentDate.getMinutes()%6));
}
lib.set_CanvasSize = function( nWidth, nHeight, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if (lib.is_Mobile()) {
lib.n_X_CanvasSize = nWidth;
lib.n_Y_CanvasSize = nHeight;
}
lib.canvas_elem[canvasID].width = lib.n_X_CanvasSize;
lib.canvas_elem[canvasID].height = lib.n_Y_CanvasSize;
lib.n_Monitor_Width = nWidth - lib.n_X_Left_Top - lib.n_X_Bottom_Right;
lib.n_Monitor_Height = nHeight - lib.n_Y_Left_Top - lib.n_Y_Bottom_Right;
}
lib.setMobile = function( bValue) {
lib.is_mobile = bValue;
}
lib.is_Mobile = function() {
return lib.is_mobile;
}
lib.set_Color_Backgrd = function( nValue) {
lib.szColor_Backgrd = nValue;
}
lib.Color_Backgrd = function() {
return lib.szColor_Backgrd;
}
lib.set_Tarif_Value = function( nValue) {
lib.n_Tarif_Value = nValue;
}
lib.Tarif_Value = function() {
return lib.n_Tarif_Value;
}
lib.Tarif_As_Euro = function() {
return lib.n_Tarif_Value;
}
lib.set_CO2_Ouput = function( nValue) {
lib.n_CO2_Output = nValue;
}
lib.CO2_Output = function() {
return (lib.n_CO2_Output/1000);
}
lib.CO2_As_Kilo = function() {
return lib.n_CO2_Output;
}
lib.set_CurrentFactor = function( nValue, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.n_perviousFactor[canvasID] = lib.n_CurrentFactor[canvasID];
lib.n_CurrentFactor[canvasID] = nValue;
}
lib.CurrentFactor = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return lib.n_CurrentFactor[canvasID];
}
lib.PerviousFactor = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return lib.n_perviousFactor[canvasID];
}
lib.set_MaxToDraw = function( nValue, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.n_MaxValueToDraw[canvasID] = nValue;
}
lib.MaxToDraw = function( szSubTab, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nRetCode = 0;
switch (szSubTab) {
case "10":
case "hour":
case "24h":
nRetCode = lib.n_MaxValueToDraw[canvasID];
break;
case "week":
case "month":
case "year":
nRetCode = (lib.n_MaxValueToDraw[canvasID]/1000);
break;
}
return nRetCode;
}
lib.set_MaxEnergy_Amount = function( nValue, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.n_MaxEnergy_Amount[canvasID] = nValue;
}
lib.MaxEnergy_Amount = function( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return lib.n_MaxEnergy_Amount[canvasID];
}
lib.set_EM_ValueType = function( nValue) {
lib.n_EM_ValueType = nValue;
}
lib.EM_ValueType = function() {
return lib.n_EM_ValueType;
}
lib.set_Draw_Volt_Line = function( bValue) {
lib.b_Draw_Volt_Line = bValue;
}
lib.draw_Volt_Line = function() {
return lib.b_Draw_Volt_Line;
}
lib.getDevicePower = function( nValue) {
var nRetCode = ( Number(nValue)/100);
return nRetCode;
}
lib.getDeviceVoltage = function( nValue) {
var nRetCode =(Math.round((Number(nValue)/1000)*10)/10);
return nRetCode;
}
lib.getDeviceAmpere = function( nValue) {
return (Math.round((Number(nValue)/10000)*1000)/1000);
}
lib.draw_Monitor_of = function(szType, canvasID) {
if ( lib.canCanvas == false)
return;
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nMaximunValue = lib.MaxToDraw( szType, canvasID);
switch (szType) {
case "10":
case "hour":
case "24h":
nMaximunValue = get_ShowFactor( "Wh", nMaximunValue);
break;
case "week":
case "month":
case "year":
nMaximunValue = get_ShowFactor( "kWh", nMaximunValue);
break;
}
lib.set_CurrentFactor( get_Y_coord_Factor( nMaximunValue), canvasID);
lib.drawMonitorBackground( szType, true, false, canvasID);
if ( lib.EnergyValuesSize(canvasID) > 0 ) {
switch (szType) {
case "10":
draw_CharacteristicLine_of(canvasID)
break;
case "hour":
draw_CharacteristicLine_of(canvasID)
break;
case "24h":
drawing_chart_of( canvasID, 1, 0.7, "left", lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
break;
case "week":
drawing_chart_of( canvasID, 1000, 0.8, "left", lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
break;
case "month":
drawing_chart_of( canvasID, 1000, 0.7, "center",lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
break;
case "year":
drawing_chart_of( canvasID, 1000, 0.5, "center", lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
break;
}
draw_DateLine_of( canvasID, szType);
} else {
var nX_Pos = (lib.n_X_CanvasSize/2);
var szFont = "13px Times New Roman bold";
if ( lib.is_Mobile() ) {
szFont = "1.05em Times New Roman";
}
var szText = "{?492:110?}";
drawText( szText, nX_Pos, 113, szFont, "center", "bottom", lib.szColor_TextInfoErr, canvasID)
}
}
lib.drawMonitorBackground = function( szSubTab, bOnlyMonitor, bShowText, canvasID) {
if ( lib.canCanvas == false)
return;
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
if ( (bOnlyMonitor != false) || ( lib.CurrentFactor() != lib.PerviousFactor())) {
lib.canvas_context[canvasID].clearRect(0,0,lib.n_X_CanvasSize,lib.n_Y_CanvasSize);
} else {
lib.canvas_context[canvasID].clearRect( lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
}
var szCurrentDateTitle = getTitleTextOf( szSubTab);
drawText( szCurrentDateTitle, (lib.n_X_CanvasSize/2), (lib.n_Y_Left_Top/2), "14px Times New Roman", "center", "middle", lib.szColor_TextInfo, canvasID);
var nX_Step = get_MonitorWidth( canvasID)/getBackgrdChartCount( szSubTab);
var n_Offset = 0;
switch (szSubTab) {
case "10":
case "hour":
case "month":
case "year":
break;
case "24h":
var nOffsetFactor = lib.getHourSkip();
n_Offset = Math.round((get_MonitorWidth( canvasID)/96)*nOffsetFactor);
break;
case "week":
var nOffsetFactor = lib.getDaySkip();
n_Offset = Math.round((get_MonitorWidth( canvasID)/28)*nOffsetFactor);
break;
}
fillingRect( canvasID, lib.szColor_Backgrd_3, lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
draw_vert_help_lines( canvasID, lib.szColor_HelpLine_Vert, n_Offset, nX_Step);
draw_horz_help_lines( canvasID, (get_MonitorHeight(canvasID)/10));
strokingRect( canvasID, lib.szColor_ScaleLine, lib.n_X_Left_Top, lib.n_Y_Left_Top, get_MonitorWidth( canvasID), get_MonitorHeight( canvasID));
// draw Scale and Scale-Texts
if ( (bOnlyMonitor != false) || ( lib.CurrentFactor() != lib.PerviousFactor())) {
drawLeftScaleLines( canvasID);
drawLeftScaleTexts( lib.CurrentFactor(), canvasID);
if ((szSubTab == "10") || ( szSubTab == "hour")) {
drawRightScaleLines( canvasID);
drawRightScaleTexts( canvasID);
} else {
lib.canvas_context[canvasID].clearRect( (lib.n_X_Left_Top+get_MonitorWidth( canvasID)+1),(lib.n_Y_Left_Top-10), lib.n_X_Bottom_Right, get_MonitorHeight( canvasID)+20);
}
drawBottomScaleLines( szSubTab, canvasID);
drawBottomScaleTexts( szSubTab, canvasID);
lib.drawSubTabsElements( szSubTab, canvasID);
}
if ((bShowText == true) && (lib.EnergyValuesSize() == 0)) {
var szFont1 = "13px Times New Roman bold";
if ( lib.is_Mobile() ) {
szFont1 = "1.05em Times New Roman";
}
var szText1 = "{?492:277?}";
var nTextWidth1 = measureText( szText1, szFont1, "center", "bottom", lib.szColor_TextInfo, canvasID)
var nX_Pos = (lib.n_X_CanvasSize/2);
drawText( szText1, nX_Pos, 112, szFont1, "center", "bottom", lib.szColor_TextInfo, canvasID)
var szFont2 = "13px Times New Roman bold";
if ( lib.is_Mobile() ) {
szFont1 = "1.05em Times New Roman";
}
var szText2 = "{?492:479?}";
var nTextWidth2 = measureText( szText2, szFont2, "center", "bottom", lib.szColor_TextInfo, canvasID)
drawText( szText2, nX_Pos, 135, szFont2, "center", "bottom", lib.szColor_TextInfo, canvasID)
}
}
}
lib.getSummaryOf = function(nFrom, nTo, canvasID)
{
if ( !canvasID )
{
canvasID = g_canvasIdDefault;
}
canvasID = canvasID.toString();
var nMonth_Amount = 0;
if ( lib.EnergyValuesSize( canvasID ) > 0 )
{
for ( var i = nFrom; i <= nTo; i++ )
{
var nTmpValue = get_ShowFactor( "kWh", getEnergyValueOf( "Wh", i, canvasID ) ) * 0.001;
nMonth_Amount = nMonth_Amount + nTmpValue;
}
}
return nMonth_Amount;
}
lib.getMonthSummary = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nMonth_Amount = 0;
if ( lib.EnergyValuesSize(canvasID) > 0) {
var nDay = Number(lib.CurrentDate.getDate());
var nStart = 31 - nDay + 1;
for ( var i = nStart; i < 31; i++) {
var nTmpValue = (get_ShowFactor( "kWh", getEnergyValueOf( "Wh", i, canvasID))*0.001);
nMonth_Amount = nMonth_Amount + nTmpValue;
}
}
return nMonth_Amount;
}
lib.getYearSummary = function(canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nYear_Amount = 0;
if ( lib.EnergyValuesSize(canvasID) > 0) {
var nMonth = Number( lib.CurrentDate.getMonth());
var nStart = 12 - nMonth - 1;
for ( var i = nStart; i < 12; i++) {
var nTmpValue = (get_ShowFactor( "kWh", getEnergyValueOf( "Wh", i, canvasID))*0.001);
nYear_Amount = nYear_Amount + nTmpValue;
}
}
return nYear_Amount;
}
lib.drawSubTabsElements = function( szSubTab, canvasID) {
if ( lib.canCanvas == false)
return;
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var szScaleText_Top = lib.getTopLeftScaleText( szSubTab);
lib.canvas_context[canvasID].fillStyle = lib.szColor_Backgrd;
switch (szSubTab) {
case "10":
drawText( "{?492:225?}", 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:938?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:230?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_Left_Top + get_MonitorHeight( canvasID)+11, "12px Times New Roman ", "right", "top", lib.szColor_ScaleText, canvasID);
drawText( "{?492:387?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_CanvasSize, "14px Times New Roman bold", "right", "bottom", lib.szColor_TextInfo, canvasID);
break;
case "hour":
drawText( szScaleText_Top, 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:804?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:126?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_Left_Top + get_MonitorHeight( canvasID)+11, "12px Times New Roman ", "right", "top", lib.szColor_ScaleText, canvasID);
drawText( "{?492:790?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_CanvasSize, "14px Times New Roman bold", "right", "bottom", lib.szColor_TextInfo, canvasID);
break;
case "24h":
drawText( szScaleText_Top, 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:244?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_CanvasSize, "14px Times New Roman bold", "right", "bottom", lib.szColor_TextInfo, canvasID);
break;
case "week":
drawText( szScaleText_Top, 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
break;
case "month":
drawText( szScaleText_Top, 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
drawText( "{?492:892?}", lib.n_X_Left_Top + get_MonitorWidth( canvasID), lib.n_Y_CanvasSize, "14px Times New Roman bold", "right", "bottom", lib.szColor_TextInfo, canvasID);
break;
case "year":
drawText( szScaleText_Top, 3, 25, "13px Times New Roman bold", "left", "bottom", lib.szColor_TextInfo, canvasID);
break;
}
}
lib.getTopLeftScaleText = function( szSubTabType) {
if ( lib.canCanvas == false)
return;
var szRetCode = "";
switch (szSubTabType) {
case "10":
case "hour":
szRetCode = "{?492:22?}";
break;
case "24h":
szRetCode = "Wh";
if ( lib.n_EM_ValueType == "1") {
szRetCode = "{?492:369?}";
} else if ( lib.n_EM_ValueType == "3") {
szRetCode = "{?492:861?}";
}
break;
case "week":
case "month":
case "year":
szRetCode = " kWh";
if ( lib.n_EM_ValueType == "1") {
szRetCode = "{?492:912?}";
} else if ( lib.n_EM_ValueType == "3") {
szRetCode = "{?492:640?}";
}
break;
}
return szRetCode;
}
lib.getBottomScaleTextOf = function( szSubTabType, bUseForSelect) {
if ( lib.canCanvas == false)
return;
var retCode = null;
switch (szSubTabType) {
case "10":
retCode = new Array( "-10", "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1", "");
break;
case "hour":
retCode = new Array( "-60", "-55", "-50", "-45", "-40", "-35", "-30", "-25", "-20", "-15", "-10", "-5", "");
break;
case "24h":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var szMins = getMinutesString( nMins);
var arScaleText = new Array();
var nStartHour = nHour;
for ( var i = nStartHour; i < 24; i++) {
var szElem = String(i);// +szMins;
arScaleText.push(szElem);
}
var nEndHour = nHour - 1;
if ( szMins == ":00") {
nEndHour = nHour;
}
for ( var j = 0; j <= nEndHour; j++) {
var szElem = String(j);//+szMins;;
arScaleText.push(szElem);
}
if ( szMins != ":00") {
arScaleText.push( String(nEndHour+1));
}
arScaleText.shift();
retCode = arScaleText;
break;
case "week":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var nDay = lib.CurrentDate.getDay();
var arDaySet = new Array( "", "", "12", "");
if ( (nHour <= 5 ) || ((nHour == 6) && (nMins == 0)) ) {
arDaySet = new Array( "", "12", "", "");
} else if ( (nHour <= 11 ) || ((nHour == 12) && (nMins == 0)) ) {
arDaySet = new Array( "12", "", "", "");
} else if ( (nHour <= 17 ) || ((nHour == 18) && (nMins == 0)) ) {
arDaySet = new Array( "", "", "", "12");
}
var arScaleText = new Array();
for( var i = (nDay+1); i <= 6; i++) {
for ( var j = 0; j < 4; j++) {
var szText = arDaySet[j];
if ( szText == "x") {
szText = ar_Weekdays_Texts[i];
}
arScaleText.push( szText);
}
}
for( var i = 0; i <= nDay; i++) {
for ( var j = 0; j < 4; j++) {
var szText = arDaySet[j];
if ( szText == "x") {
szText = ar_Weekdays_Texts[i];
}
arScaleText.push( szText);
}
}
retCode = arScaleText;
break;
case "week_day":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var nDay = lib.CurrentDate.getDay();
var arDaySet = new Array( "x", "", "", "");
if ( (nHour <= 5 ) || ((nHour == 6) && (nMins == 0)) ) {
arDaySet = new Array( "", "", "", "x");
} else if ( (nHour <= 11 ) || ((nHour == 12) && (nMins == 0)) ) {
arDaySet = new Array( "", "", "x", "");
} else if ( (nHour <= 17 ) || ((nHour == 18) && (nMins == 0)) ) {
arDaySet = new Array( "", "", "x", "12");
}
var arScaleText = new Array();
for ( var i = (nDay+1); i <= 6; i++) {
for ( var j = 0; j < 4; j++) {
var szText = arDaySet[j];
if ( szText == "x") {
szText = ar_Weekdays_Texts_Long[i];
arScaleText.push( szText);
}
}
}
for ( var i = 0; i <= nDay; i++) {
for ( var j = 0; j < 4; j++) {
var szText = arDaySet[j];
if ( szText == "x") {
szText = ar_Weekdays_Texts_Long[i];
arScaleText.push( szText);
}
}
}
retCode = arScaleText;
break;
case "month":
var nDay = Number(lib.CurrentDate.getDate());
var nMonth = Number(lib.CurrentDate.getMonth());
var nPreviousMonth = nMonth;
if ( nPreviousMonth == 0) {
nPreviousMonth = 12;
}
var nDays = getMonthCountOf( (nMonth));
var arScaleText = new Array();
var nStartDay = nDay + 1;
if ( nDays <= 29) {
nStartDay = nStartDay - ( 31 - nDays)
if ( nPreviousMonth == 2) {
if ((nDay == 1) && ( nDays == 28)) {
arScaleText.push("30");
arScaleText.push("31");
nStartDay = 1;
}
if ( nDay == 2) {
arScaleText.push("31");
nStartDay = 1;
}
}
} else {
nStartDay = nStartDay - ( 31 - nDays)
}
for ( var i = nStartDay; i <= nDays; i++) {
var szElem = String(i); //+"."+String(nPreviousMonth)+".";
arScaleText.push(szElem);
}
for ( var j = 1; j <= nDay; j++) {
var szElem = String(j); //+"."+String((nMonth+1))+".";
arScaleText.push(szElem);
}
retCode = arScaleText;
break;
case "year":
var ar_ScaleText_Tmp = ar_ScaleText_Year;
if ( bUseForSelect == true) {
ar_ScaleText_Tmp = ar_ScaleText_Year_Sel;
}
var nMonth = Number( lib.CurrentDate.getMonth());
var arScaleText2 = ar_ScaleText_Tmp.slice(0,(nMonth+1));
var arScaleText1 = ar_ScaleText_Tmp.slice((nMonth+1));
retCode = arScaleText1.concat( arScaleText2);
break;
default:
retCode = null;;
break;
}
return retCode;
}
lib.getTitleDates = function( szSubTabType, bUseForSelect) {
if ( lib.canCanvas == false)
return;
var retCode = null;
var nYear = 1900 + Number( lib.CurrentDate.getYear());
switch (szSubTabType) {
case "24h":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var szMins = getMinutesString( nMins);
var arScaleText = new Array();
var nStartHour = nHour;
for ( var i = nStartHour; i < 24; i++) {
var szElem = String(i);
arScaleText.push(szElem);
}
var nEndHour = nHour - 1;
if ( szMins == ":00") {
nEndHour = nHour;
}
for ( var j = 0; j <= nEndHour; j++) {
var szElem = String(j);
arScaleText.push(szElem);
}
if ( szMins != ":00") {
arScaleText.push( String(nEndHour+1));
}
arScaleText.shift();
retCode = arScaleText;
break;
case "week":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var nDay = lib.CurrentDate.getDay();
var arScaleText = new Array();
for ( var i = (nDay+1); i <= 6; i++) {
arScaleText.push( ar_Weekdays_Texts_Long[i]);
}
for ( var i = 0; i <= nDay; i++) {
arScaleText.push( ar_Weekdays_Texts_Long[i]);
}
retCode = arScaleText;
break;
case "month":
var nDay = Number(lib.CurrentDate.getDate());
var nMonth = Number(lib.CurrentDate.getMonth());
var nPreviousMonth = nMonth;
if ( nPreviousMonth == 0) {
nPreviousMonth = 12;
}
var sz_Year = "";
if ( bUseForSelect == true) {
sz_Year = String( nYear);
}
var nDays = getMonthCountOf( (nMonth));
var arScaleText = new Array();
var nStartDay = nDay + 1;
if ( nDays <= 29) {
nStartDay = nStartDay - ( 31 - nDays)
if ( nPreviousMonth == 2) {
if ((nDay == 1) && ( nDays == 28)) {
arScaleText.push("30.1."+sz_Year);
arScaleText.push("31.1."+sz_Year);
nStartDay = 1;
}
if ( nDay == 2) {
arScaleText.push("31.1."+sz_Year);
nStartDay = 1;
}
}
} else {
nStartDay = nStartDay - ( 31 - nDays)
}
if ( nPreviousMonth == 12) {
if ( bUseForSelect == true) {
sz_Year = String( nYear-1);
}
}
for ( var i = nStartDay; i <= nDays; i++) {
var szElem = String(i)+"."+String(nPreviousMonth)+"."+sz_Year;
arScaleText.push(szElem);
}
if ( nPreviousMonth == 12) {
if ( bUseForSelect == true) {
sz_Year = String( nYear);
}
}
for ( var j = 1; j <= nDay; j++) {
var szElem = String(j)+"."+String((nMonth+1))+"."+sz_Year;
arScaleText.push(szElem);
}
retCode = arScaleText;
break;
case "year":
var ar_ScaleText_Tmp = ar_ScaleText_Year;
if ( bUseForSelect == true) {
// ar_ScaleText_Tmp = ar_ScaleText_Year_Sel;
}
var nMonth = Number( lib.CurrentDate.getMonth());
var arScaleText2 = ar_ScaleText_Tmp.slice(0,(nMonth+1));
if ( bUseForSelect == true) {
var n_Length = arScaleText2.length;
for ( var i = 0; i < n_Length; i++) {
arScaleText2[i] = arScaleText2[i] + " " + String( nYear);
}
}
var arScaleText1 = ar_ScaleText_Tmp.slice((nMonth+1));
if ( bUseForSelect == true) {
var n_Length = arScaleText1.length;
for ( var i = 0; i < n_Length; i++) {
arScaleText1[i] = arScaleText1[i] + " " + String( nYear-1);
}
}
retCode = arScaleText1.concat( arScaleText2);
break;
}
return retCode;
}
lib.getSelectDates = function( szSubTabType, szRange) {
if (!lib.canCanvas) {
return;
}
var retCode = null;
var nYear = 1900 + Number(lib.CurrentDate.getYear());
switch (szSubTabType) {
case '10':
retCode = ["-10", "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1", ""];
break;
case 'hour':
retCode = ["-60", "-55", "-50", "-45", "-40", "-35", "-30", "-25", "-20", "-15", "-10", "-5", ""];
break;
case "24h":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var szMins = getMinutesString(nMins);
var arScaleText = new Array();
var nStartHour = nHour;
if (szMins == ":00") {
if (nStartHour == 24) {
nStartHour = 0;
} else {
nStartHour += 1;
}
}
for (var i = nStartHour; i < 24; i++) {
var szElem = String(i);
arScaleText.push(szElem);
}
var nEndHour = nStartHour;
for (var j = 0; j <= nEndHour; j++) {
var szElem = String(j);
arScaleText.push(szElem);
}
if (szMins == ":00") {
if (szRange == "From") {
arScaleText.pop();
}
}
retCode = arScaleText;
break;
case "week":
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var nDay = lib.CurrentDate.getDay();
var arScaleText = new Array();
for (var i = (nDay); i <= 6; i++) {
arScaleText.push(ar_Weekdays_Texts_Long[i]);
}
for (var i = 0; i <= nDay; i++) {
arScaleText.push(ar_Weekdays_Texts_Long[i]);
}
retCode = arScaleText;
break;
case "month":
var nDay = Number(lib.CurrentDate.getDate());
var nMonth = Number(lib.CurrentDate.getMonth());
var nPreviousMonth = nMonth;
if (nPreviousMonth == 0) {
nPreviousMonth = 12;
}
var sz_Year = "";
sz_Year = String(nYear);
var nDays = getMonthCountOf(nMonth);
var arScaleText = new Array();
var nStartDay = nDay + 1;
if (nDays <= 29) {
nStartDay = nStartDay - (31 - nDays);
if (nPreviousMonth == 2) {
if (nDay == 1 && nDays == 28) {
arScaleText.push("30.1." + sz_Year);
arScaleText.push("31.1." + sz_Year);
nStartDay = 1;
}
if (nDay == 2) {
arScaleText.push("31.1." + sz_Year);
nStartDay = 1;
}
}
} else {
nStartDay = nStartDay - (31 - nDays);
}
if (nPreviousMonth == 12) {
sz_Year = String(nYear - 1);
}
for (var i = nStartDay; i <= nDays; i++) {
var szElem = String(i) + "." + String(nPreviousMonth) + "." + sz_Year;
arScaleText.push(szElem);
}
if (nPreviousMonth == 12) {
sz_Year = String( nYear);
}
for (var j = 1; j <= nDay; j++) {
var szElem = String(j) + "." + String(nMonth + 1) + "." + sz_Year;
arScaleText.push(szElem);
}
retCode = arScaleText;
break;
case "year":
var ar_ScaleText_Tmp = ar_ScaleText_Year;
var nMonth = Number(lib.CurrentDate.getMonth());
var arScaleText2 = ar_ScaleText_Tmp.slice(0, nMonth + 1);
var n_Length = arScaleText2.length;
for (var i = 0; i < n_Length; i++) {
arScaleText2[i] = arScaleText2[i] + " " + String( nYear);
}
var arScaleText1 = ar_ScaleText_Tmp.slice(nMonth + 1);
var n_Length = arScaleText1.length;
for (var i = 0; i < n_Length; i++) {
arScaleText1[i] = arScaleText1[i] + " " + String( nYear-1);
}
retCode = arScaleText1.concat( arScaleText2);
break;
}
return retCode;
}
lib.getSubSelectDatas = function( szSubTabType, bUseForSelect) {
if ( lib.canCanvas == false)
return;
var retCode = null;
switch (szSubTabType) {
case "24h":
retCode = new Array( ":00",":15",":30",":45");
break;
case "week":
retCode = new Array( "0", "6", "12", "18");
break;
case "month":
break;
case "year":
break;
}
return retCode;
}
lib.isInChartOf = function( xPos, yPos, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
for ( var i = 0; i < lib.EnergyValuesSize(canvasID); i++) {
if ( isPointInChartOf( canvasID, i, xPos, yPos)) {
return i;
}
}
return -1;
}
lib.getHourSkip = function() {
var n_mins = lib.CurrentDate.getMinutes();
var nRetCode = 0; // ":00";
if ( n_mins < 15) {
nRetCode = 3; // "bis :15"
} else if ( n_mins < 30){
nRetCode = 2; // "bis :30";
} else if ( n_mins < 45){
nRetCode = 1; // "bis :45";
}
return nRetCode;
return nRetCode;
}
lib.getDaySkip = function() {
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
var nRetCode = 0; //( "", "", "12", "");
if ( (nHour <= 5 ) || ((nHour == 6) && (nMins == 0)) ) {
nRetCode = 3; // ( "", "12", "", "");
} else if ( (nHour <= 11 ) || ((nHour == 12) && (nMins == 0)) ) {
nRetCode = 2; // ( "12", "", "", "")
} else if ( (nHour <= 17 ) || ((nHour == 18) && (nMins == 0)) ) {
nRetCode = 1; // ( "", "", "", "12");
}
return nRetCode;
}
lib.getSelectSkip_24h = function() {
var n_mins = lib.CurrentDate.getMinutes();
var nRetCode = new Array( 0, 1, 2, 3); //( ":00", ":15", ":30", ":45");
if ( n_mins < 15) {
nRetCode = new Array( 0, 1, 2, 3); //( ":15", ":30", ":45", ":00");
} else if ( n_mins < 30) {
nRetCode = new Array( 0, 1, 2, 3); //( ":30", ":45", ":00", ":15");
} else if ( n_mins < 45) {
nRetCode = new Array( 0, 1, 2, 3); //( ":45", ":00", ":15", ":30");
}
return nRetCode;
}
lib.getSelectSkip_Week = function() {
var nHour = lib.CurrentDate.getHours();
var nMins = lib.CurrentDate.getMinutes();
// var nDay = lib.CurrentDate.getDay();
var nRetCode = new Array(-4,-3,-2,-1); //( "0", "6", "12", "18");
if ( (nHour <= 5 ) || ((nHour == 6) && (nMins == 0)) ) {
nRetCode = new Array(0,1,2,-1); //( "6", "12", "18", "0");
} else if ( (nHour <= 11 ) || ((nHour == 12) && (nMins == 0)) ) {
nRetCode = new Array(0,1,-2,-1) //( "12", "18", "0", "6");
} else if ( (nHour <= 17 ) || ((nHour == 18) && (nMins == 0)) ) {
nRetCode = new Array(0,1,2,-1); //( "18", "0", "6", "12");
}
return nRetCode;
}
function Grad_Value( Index, Color) {
this.pos = Index;
this.color = Color;
}
function draw_CharacteristicLine_of( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].lineJoin = "round";
var x_Step = (get_MonitorWidth( canvasID)/(lib.EnergyValuesSize(canvasID)));
var y_Step_Volt = (get_MonitorHeight( canvasID)/lib.VoltScaleRange); // der Wert "50" definiert da Spannungbereich nur zwischen 200 bis 250 angezeigt
var y_Step_Power = ( get_MonitorHeight( canvasID)/lib.CurrentFactor(canvasID));
drawLineOf( "power", true, szPowerLineColor, szPowerFillColor, x_Step, y_Step_Power, 0, 0, "discreet", "", "", canvasID);
if ( lib.b_Draw_Volt_Line == true ) {
// der Wert "200" definiert die untere Anzeigegrenze an.
drawLineOf( "volt", false, szVoltLineColor, szVoltFillColor, x_Step, y_Step_Volt, 200, 0, "discreet", "", "", canvasID);
}
}
}
function draw_ConsumptionLine_of( szSubType, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].lineJoin = "round";
var x_Step = (get_MonitorWidth( canvasID)/(lib.EnergyValuesSize(canvasID)));
var nFactor = get_Y_coord_Factor( get_ShowFactor( "Wh", lib.n_MaxEnergy_Amount));
var y_Step = (get_MonitorHeight( canvasID)/nFactor);
drawLineOf( "Wh", true, get_ShowTypeLineColor(), get_ShowTypeFillColor(), x_Step, y_Step, 0, 0, "analog", "add", "Wh", canvasID)
}
}
function drawLeftScaleLines( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].lineWidth = 1;
draw_scale_lines( canvasID, lib.szColor_ScaleLine, "left", 25, 10, 2, 5, false);
lib.canvas_context[canvasID].closePath();
}
}
function drawLeftScaleTexts( n_Factor, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].fillStyle = lib.szColor_ScaleText;
lib.canvas_context[canvasID].font = "12px Times New Roman";
if ((n_Factor <= 0.01) || (n_Factor >= 1000)) {
lib.canvas_context[canvasID].font = "10px Times New Roman";
if (n_Factor >= 10000) {
lib.canvas_context[canvasID].font = "8px Times New Roman";
}
}
lib.canvas_context[canvasID].textBaseline = "middle"; ;
var ar_scaleTexts = new Array();
ar_scaleTexts = getLeftScaleTexts( n_Factor).reverse();
drawing_scale_text( canvasID, ar_scaleTexts, "height", get_MonitorHeight( canvasID), (ar_scaleTexts.length-1),(lib.n_X_Left_Top-11), lib.n_Y_Left_Top, "middle", "right");
lib.canvas_context[canvasID].font = "12px Times New Roman";
lib.canvas_context[canvasID].closePath();
ar_scaleTexts.reverse();
}
}
function drawRightScaleLines( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].lineWidth = 1;
draw_scale_lines( canvasID, szVoltLineColor/*lib.szColor_ScaleLine*/, "right", 25, 10, 2, 5, false);
lib.canvas_context[canvasID].closePath();
}
}
function drawRightScaleTexts( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].fillStyle = szVoltLineColor/*lib.szColor_ScaleText*/;
lib.canvas_context[canvasID].font = "12px Times New Roman";
lib.canvas_context[canvasID].textBaseline = "middle"; ;
var ar_scaleTexts = new Array( "200","210", "220", "230", "240", "250");;
drawing_scale_text( canvasID, ar_scaleTexts.reverse(), "height", get_MonitorHeight( canvasID), (ar_scaleTexts.length-1),(lib.n_X_Left_Top+get_MonitorWidth( canvasID)+11), lib.n_Y_Left_Top, "middle", "left");
lib.canvas_context[canvasID].closePath();
}
}
function drawBottomScaleLines( szSubTab, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].lineWidth = 1;
var ar_scaleTexts = lib.getBottomScaleTextOf( szSubTab);
var nRange = get_MonitorWidth( canvasID);
var nStep_Count = ar_scaleTexts.length;
var nStep_Range = nRange/nStep_Count;
var n_line_width = 10;
var n_line_offset = 5;
var n_Offset_Step = 2;
var n_Offset_Shift = false;
var n_OffsetSkip = 0;
switch( szSubTab) {
case "10":
nStep_Count = ar_scaleTexts.length-1;
nStep_Range = nRange/nStep_Count;
n_line_width = 8;
n_line_offset = 0;
n_Offset_Step = 0;
n_Offset_Shift = false;
draw_scale_lines( canvasID, lib.szColor_ScaleLine, "down", nStep_Range, n_line_width, n_Offset_Step, n_line_offset, n_Offset_Shift, n_OffsetSkip);
break;
case "hour":
nStep_Count = 60;
nStep_Range = nRange/nStep_Count;
n_line_width = 8;
n_line_offset = 4;
n_Offset_Step = 5;
n_Offset_Shift = false;
draw_scale_lines( canvasID, lib.szColor_ScaleLine, "down", nStep_Range, n_line_width, n_Offset_Step, n_line_offset, n_Offset_Shift, n_OffsetSkip);
break;
case "24h":
nStep_Count = 96;
nStep_Range = nRange/nStep_Count;
n_line_width = 8;
n_line_offset = 4;
n_Offset_Step = 4;
n_Offset_Shift = false;
n_OffsetSkip = lib.getHourSkip();
draw_scale_lines( canvasID, lib.szColor_ScaleLine, "down", nStep_Range, n_line_width, n_Offset_Step, n_line_offset, n_Offset_Shift, n_OffsetSkip);
break;
case "week":
nStep_Count = 28;
nStep_Range = nRange/nStep_Count;
n_line_width = 25;
n_line_offset = 20;
n_Offset_Step = 4;
n_Offset_Shift = false;
n_OffsetSkip = lib.getDaySkip();
draw_scale_lines( canvasID, lib.szColor_ScaleLine, "down", nStep_Range, n_line_width, n_Offset_Step, n_line_offset, n_Offset_Shift, n_OffsetSkip);
break;
case "month":
break;
case "year":
break;
}
lib.canvas_context[canvasID].closePath();
}
}
function drawBottomScaleTexts( szSubTab, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].fillStyle = lib.szColor_ScaleText;
lib.canvas_context[canvasID].font = "12px Times New Roman";
lib.canvas_context[canvasID].textBaseline = "middle"; ;
var ar_scaleTexts = lib.getBottomScaleTextOf( szSubTab);
var nRange = get_MonitorWidth( canvasID);
var nSteps = ar_scaleTexts.length;
var nStep_Range = nRange/nSteps;
var n_X_Pos = lib.n_X_Left_Top + (nStep_Range/2);
var n_Y_Pos = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) + 11;
var sz_Align = "center";
var sz_Baseline = "top";
var nTextOffset = 0;
switch( szSubTab) {
case "10":
case "hour":
nSteps = (ar_scaleTexts.length-1);
n_X_Pos = lib.n_X_Left_Top;
n_Y_Pos = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) + 11;
sz_Align = "center";
sz_Baseline = "top";
break;
case "24h":
nSteps = ar_scaleTexts.length;
var nOffsetFactor = lib.getHourSkip();
if ( nOffsetFactor == 0) {
ar_scaleTexts.push("");
// nSteps = ar_scaleTexts.length;
}
nTextOffset = (get_MonitorWidth( canvasID)/96)*nOffsetFactor;
n_X_Pos = lib.n_X_Left_Top + nTextOffset;
n_Y_Pos = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) + 11;
sz_Align = "center";
sz_Baseline = "top";
break;
case "week":
nSteps = ar_scaleTexts.length;
var nOffsetFactor = lib.getDaySkip();
n_X_Pos = lib.n_X_Left_Top;
n_Y_Pos = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) + 8;
sz_Align = "center";
sz_Baseline = "top";
drawing_scale_text( canvasID, ar_scaleTexts, "width", get_MonitorWidth( canvasID), nSteps, n_X_Pos, n_Y_Pos, sz_Baseline, sz_Align, nTextOffset);
ar_scaleTexts = lib.getBottomScaleTextOf( "week_day");
nSteps = ar_scaleTexts.length;
var nOffsetFactor = lib.getDaySkip();
nTextOffset = (get_MonitorWidth( canvasID)/28)*nOffsetFactor;
n_X_Pos = lib.n_X_Left_Top + nTextOffset;
n_Y_Pos = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) + 25;
sz_Align = "left";
sz_Baseline = "top";
break;
case "month":
break;
case "year":
break;
}
drawing_scale_text( canvasID, ar_scaleTexts, "width", get_MonitorWidth( canvasID), nSteps, n_X_Pos, n_Y_Pos, sz_Baseline, sz_Align, nTextOffset);
lib.canvas_context[canvasID].closePath();
}
}
function draw_DateLine_of( canvasID, szSubTab) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].strokeStyle = szDateLine_Color;
lib.canvas_context[canvasID].lineWidth=1;
switch( szSubTab) {
case "10":
case "hour":
case "week;":
break;
case "24h":
var ar_scaleTexts = lib.getBottomScaleTextOf( szSubTab, false);
var nHour = Number( ar_scaleTexts[0]);
var n_X_Step = get_MonitorWidth(canvasID)/96;
var nFactor = 24 - nHour;
var nOffsetFactor = lib.getHourSkip();
var nX_Pos = Math.round(( 4*nFactor)*n_X_Step + (nOffsetFactor*n_X_Step));
drawingLine( canvasID, (lib.n_X_Left_Top+nX_Pos), lib.n_Y_Left_Top, (lib.n_X_Left_Top+nX_Pos), ( lib.n_Y_Left_Top+get_MonitorHeight(canvasID)+8), true, true);
break;
case "month":
var nDay = Number(lib.CurrentDate.getDate());
var n_X_Step = get_MonitorWidth(canvasID)/31;
var nFactor = 31 - nDay;
var nX_Pos = Math.round( nFactor*n_X_Step);
drawingLine( canvasID, (lib.n_X_Left_Top+nX_Pos), lib.n_Y_Left_Top, (lib.n_X_Left_Top+nX_Pos), ( lib.n_Y_Left_Top+get_MonitorHeight(canvasID)+25), true, true);
break;
case "year":
var nMonth = Number(lib.CurrentDate.getMonth())+1;
var n_X_Step = get_MonitorWidth(canvasID)/12;
var nFactor = 12 - nMonth;
var nX_Pos = Math.round( nFactor*n_X_Step);
drawingLine( canvasID, (lib.n_X_Left_Top+nX_Pos), lib.n_Y_Left_Top, (lib.n_X_Left_Top+nX_Pos), ( lib.n_Y_Left_Top+get_MonitorHeight(canvasID)+25), true, true);
break;
}
lib.canvas_context[canvasID].closePath();
}
function drawLineOf( szEnergyType, bFillBelow, szStrokeStyle, szFillStyle, x_step, y_step, nDrawLimt, nDrawMin, szDrawKind, szAdd, szWattSize, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var computeValue = get_ShowFactor( szWattSize, getEnergyValueOf( szEnergyType, 0, canvasID));
if ( computeValue <= nDrawLimt) {
computeValue = nDrawMin;
} else {
computeValue = computeValue - nDrawLimt;
}
var y_coord = lib.n_Y_Left_Top + ( get_MonitorHeight( canvasID) - ( computeValue * y_step) - 1);
if ( y_coord < lib.n_Y_Left_Top) {
y_coord = lib.n_Y_Left_Top;
} else {
if ( ( lib.n_Y_Left_Top + get_MonitorHeight( canvasID)) <= y_coord) {
y_coord = lib.n_Y_Left_Top + get_MonitorHeight( canvasID)-1;
}
}
var computeValue_prev = 0;
var y_coord_prev = 0;
var y_coord_0 = y_coord;
lib.canvas_context[canvasID].lineWidth=1;
lib.canvas_context[canvasID].beginPath();
drawingLine( canvasID, (lib.n_X_Left_Top+1), Math.round( y_coord), (lib.n_X_Left_Top+1), Math.round( y_coord), true, false);
if ( szDrawKind == "discreet") {
}
for ( var i = 0; i < lib.ar_EnergyValues[canvasID].length; i++) {
if ( szAdd == "add") {
computeValue = computeValue + get_ShowFactor( szWattSize, getEnergyValueOf( szEnergyType, i, canvasID));
} else {
computeValue = get_ShowFactor( szWattSize, getEnergyValueOf( szEnergyType, i, canvasID));
}
if ( computeValue <= nDrawLimt) {
computeValue = nDrawMin;
} else {
computeValue = computeValue - nDrawLimt;
}
y_coord = lib.n_Y_Left_Top + ( get_MonitorHeight( canvasID) - ( computeValue * y_step));
if ( y_coord < lib.n_Y_Left_Top) {
y_coord = lib.n_Y_Left_Top;
} else {
if ( (lib.n_Y_Left_Top + get_MonitorHeight( canvasID)) <= y_coord) {
y_coord = lib.n_Y_Left_Top + get_MonitorHeight( canvasID);
}
}
if ((szDrawKind == "discreet") && ( i > 0) && ( computeValue != computeValue_prev )) {
drawingLine( canvasID, Math.round(lib.n_X_Left_Top + ( (i) * x_step)), Math.round( y_coord-1), Math.round(lib.n_X_Left_Top + ( (i) * x_step)), Math.round( y_coord-1), false, false);
}
drawingLine( canvasID, Math.round(lib.n_X_Left_Top + ( (i+1) * x_step)), Math.round( y_coord-1), Math.round(lib.n_X_Left_Top + ( (i+1) * x_step)), Math.round( y_coord-1), false, false);
computeValue_prev = computeValue;
y_coord_prev = y_coord;
}
if ( bFillBelow) {
lib.canvas_context[canvasID].lineTo( Math.round( lib.n_X_Left_Top + ( lib.ar_EnergyValues[canvasID].length * x_step)-1), Math.round(lib.n_Y_Left_Top + get_MonitorHeight( canvasID) - 1));
lib.canvas_context[canvasID].lineTo( Math.round( lib.n_X_Left_Top+1), Math.round( lib.n_Y_Left_Top + get_MonitorHeight( canvasID) - 1));
lib.canvas_context[canvasID].lineTo( Math.round( lib.n_X_Left_Top+1), Math.round( y_coord_0));
lib.canvas_context[canvasID].fillStyle = szFillStyle;
lib.canvas_context[canvasID].fill();
}
lib.canvas_context[canvasID].strokeStyle = szStrokeStyle;
lib.canvas_context[canvasID].stroke();
lib.canvas_context[canvasID].closePath();
}
function drawText( szText, at_X, at_Y, szFont, szTextalign, szBaseline, szColor, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
if ( lib.canvas_context[canvasID] != null) {
//lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].font = szFont;
lib.canvas_context[canvasID].fillStyle = szColor;
lib.canvas_context[canvasID].textBaseline = szBaseline;
lib.canvas_context[canvasID].textAlign = szTextalign;
lib.canvas_context[canvasID].fillText( szText, at_X, at_Y);
//lib.canvas_context[canvasID].closePath();
}
}
function measureText( szText, szFont, szTextalign, szBaseline, szColor, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var retCode = -1;
if ( lib.canvas_context[canvasID] != null) {
var tmpObj = null;
lib.canvas_context[canvasID].font = szFont;
lib.canvas_context[canvasID].fillStyle = szColor;
lib.canvas_context[canvasID].textBaseline = szBaseline;
lib.canvas_context[canvasID].textAlign = szTextalign;
tmpObj= lib.canvas_context[canvasID].measureText( szText);
if ( tmpObj != null) {
retCode = tmpObj.width;
}
}
return retCode;
}
function get_MonitorWidth( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return (lib.canvas_elem[canvasID].width - lib.n_X_Left_Top - lib.n_X_Bottom_Right);
}
function get_MonitorHeight( canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
return (lib.canvas_elem[canvasID].height - lib.n_Y_Left_Top - lib.n_Y_Bottom_Right);
}
function isPointInChartOf( canvasID, nIdx, nX, nY) {
if (( lib.ar_RectValues[canvasID][nIdx].nX <= nX) && ( (lib.ar_RectValues[canvasID][nIdx].nX +lib.ar_RectValues[canvasID][nIdx].nWidth) >= nX) &&
( lib.ar_RectValues[canvasID][nIdx].nY <= nY) && ( (lib.ar_RectValues[canvasID][nIdx].nY +lib.ar_RectValues[canvasID][nIdx].nHeight) >= nY)) {
return true;
}
return false;
}
function getEnergyValueOf( szEnergyType, nIdx, canvasID) {
if (!canvasID) canvasID = g_canvasIdDefault;
canvasID = canvasID.toString();
var nRetValue = 0;
switch( szEnergyType) {
case "Wh":
nRetValue = Number( lib.ar_EnergyValues[canvasID][nIdx].power);
break;
case "power":
nRetValue = lib.getDevicePower( lib.ar_EnergyValues[canvasID][nIdx].power);
break;
case "volt":
nRetValue = lib.getDeviceVoltage( lib.ar_EnergyValues[canvasID][nIdx].voltage);
break;
}
return nRetValue;
}
function getMinutesString( n_mins) {
var szRet = ":00";
if ( n_mins < 15) {
szRet = ":15";
} else if ( n_mins < 30){
szRet = ":30";
} else if ( n_mins < 45){
szRet = ":45";
}
return szRet;
}
function get_ShowFactor( szWattSize, n_Value )
{
var nTarif = lib.Tarif_Value();
var nCO2 = lib.CO2_Output() * 1000;
if ( "Wh" == szWattSize )
{
nTarif = lib.Tarif_Value() * 0.001;
nCO2 = lib.CO2_Output() * 0.001;
}
if ( lib.n_EM_ValueType == "1" )
{
return n_Value * nTarif;
}
else if ( lib.n_EM_ValueType == "2" )
{
return n_Value;
}
else if ( lib.n_EM_ValueType == "3" )
{
return ( n_Value * nCO2 );
}
}
function get_ShowTypeLineColor() {
if ( lib.n_EM_ValueType == "1") {
return "#03A2C2";
} else if ( lib.n_EM_ValueType == "2") {
return szPowerLineColor;
} else if ( lib.n_EM_ValueType == "3") {
return "#E6E600";
}
}
function get_ShowTypeFillColor() {
if ( lib.n_EM_ValueType == "1") {
return "#70E3FC";
} else if ( lib.n_EM_ValueType == "2") {
return szPowerFillColor;
} else if ( lib.n_EM_ValueType == "3") {
return "#FFFF8A";
}
}
function get_Y_coord_Factor( nMaxValue) {
var nFactor = 0;
nMaxValue = nMaxValue * 1.025;
if ( nMaxValue == 0)
return 5;
if (( lib.n_EM_ValueType == "1") && ( nMaxValue < 0.05)) {
nFactor = 0.05;
} else if ( nMaxValue < 0.005){
nFactor = 0.005;
} else if ( nMaxValue < 0.01){
nFactor = 0.01;
} else if ( nMaxValue < 0.05){
nFactor = 0.05;
} else if ( nMaxValue < 0.1){
nFactor = 0.1;
} else if ( nMaxValue < 0.5){
nFactor = 0.5;
} else if ( nMaxValue < 1){
nFactor = 1;
} else if ( nMaxValue < 2.5){
nFactor = 2.5;
} else if ( nMaxValue < 5){
nFactor = 5;
} else if ( nMaxValue < 12.5){
nFactor = 12.5;
} else if ( nMaxValue < 25){
nFactor = 25;
} else if ( nMaxValue < 50){
nFactor = 50;
} else if ( nMaxValue < 100){
nFactor = 100;
} else if ( nMaxValue < 250){
nFactor = 250;
} else if ( nMaxValue < 500){
nFactor = 500;
} else if ( nMaxValue < 1000){
nFactor = 1000;
} else if ( nMaxValue < 2500){
nFactor = 2500;
} else if ( nMaxValue < 5000){
nFactor = 5000;
} else if ( nMaxValue < 10000){
nFactor = 10000;
} else {
nFactor = 25000;
}
return nFactor;
}
function getLeftScaleTexts( n_Factor) {
switch (n_Factor) {
case 0.005:
return ar_ScaleText_0_005;
break;
case 0.01:
return ar_ScaleText_0_01;
break;
case 0.05:
return ar_ScaleText_0_05;
break;
case 0.1:
return ar_ScaleText_0_1;
break;
case 0.5:
return ar_ScaleText_0_5;
break;
case 1:
return ar_ScaleText_1;
break;
case 2.5:
return ar_ScaleText_2_5;
break;
case 5:
return ar_ScaleText_5;
break;
case 12.5:
return ar_ScaleText_12_5;
break;
case 25:
return ar_ScaleText_25;
break;
case 50:
return ar_ScaleText_50;
break;
case 100:
return ar_ScaleText_100;
break;
case 250:
return ar_ScaleText_250;
break;
case 500:
return ar_ScaleText_500;
break;
case 1000:
return ar_ScaleText_1000;
break;
case 2500:
return ar_ScaleText_2500;
break;
case 5000:
return ar_ScaleText_5000;
break;
case 10000:
return ar_ScaleText_10000;
break;
case 25000:
return ar_ScaleText_25000;
break;
default:
return ar_ScaleText_50;
break;
}
}
function getMonthCountOf( nMonth) {
switch (nMonth) {
case 2:
return 28;
break;
case 4:
case 6:
case 9:
case 11:
return 30;
break;
default:
return 31;
}
}
function getBackgrdChartCount( showTab) {
switch (showTab) {
case "10":
return 10;
break;
case "hour":
return 12;
break;
case "24h":
return 24;
break;
case "week":
return 7;
break;
case "month":
return 31;
break;
case "year":
return 12;
break;
}
}
function getTitleTextOf(szShowTab) {
var ar_TitleDates = lib.getTitleDates("month", false);
switch (szShowTab) {
case "10":
return String( lib.CurrentDate.getDate()+"."+(lib.CurrentDate.getMonth()+1)+"."+(lib.CurrentDate.getYear()+1900));
break;
case "hour":
return String( lib.CurrentDate.getDate()+"."+(lib.CurrentDate.getMonth()+1)+"."+(lib.CurrentDate.getYear()+1900));
break;
case "24h":
var szFrom = ( ar_TitleDates[29]+String(lib.CurrentDate.getYear()+1900));
if ((lib.CurrentDate.getMonth() == 0) &&(lib.CurrentDate.getDate() == 1)){
szFrom = ( ar_TitleDates[29]+String(lib.CurrentDate.getYear()+1899));
}
var szTo = ( ar_TitleDates[30]+String(lib.CurrentDate.getYear()+1900));
return "{?492:820?}"+szFrom+"{?492:16?}" + szTo;
break;
case "week":
var szFrom = ( ar_TitleDates[24]+String(lib.CurrentDate.getYear()+1900));
if ((lib.CurrentDate.getMonth() == 0) &&(lib.CurrentDate.getDate() < 7)) {
szFrom = ( ar_TitleDates[24]+String(lib.CurrentDate.getYear()+1899));
}
var szTo = ( ar_TitleDates[30]+String(lib.CurrentDate.getYear()+1900));
return "{?492:334?}"+szFrom+"{?492:613?}" + szTo;
break;
case "month":
var szFrom = ( ar_TitleDates[0]+String(lib.CurrentDate.getYear()+1900));
if ((lib.CurrentDate.getMonth() == 0) ) {
szFrom = ( ar_TitleDates[0]+String(lib.CurrentDate.getYear()+1899));
}
var szTo = ( ar_TitleDates[30]+String(lib.CurrentDate.getYear()+1900));
return "{?492:165?}"+szFrom+"{?492:552?}" + szTo;
break;
case "year":
var szFrom = ar_ScaleText_Year[((lib.CurrentDate.getMonth())%12)+1]+" "+String(lib.CurrentDate.getYear()+1899);
var szTo = (ar_ScaleText_Year[((lib.CurrentDate.getMonth())%12)]+" "+String(lib.CurrentDate.getYear()+1900));
return "{?492:377?}"+szFrom+"{?492:350?}" + szTo;
break;
}
}
function draw_line_only( ctx, nX, nY) {
if ( ctx.lineWidth == 1) {
nX = nX + 0.5;
nY = nY + 0.5;
}
ctx.lineTo( nX, nY );
ctx.stroke();
}
function drawingLine( canvasID, start_X, start_Y, end_X, end_Y, bMoveTo, bStrokeTo) {
if ( lib.canvas_context[canvasID].lineWidth == 1) {
if ( start_X == end_X) {
start_X = start_X + 0.5;
end_X = end_X + 0.5;
}
if ( start_Y == end_Y) {
start_Y = start_Y + 0.5;
end_Y = end_Y + 0.5;
}
}
if ( bMoveTo == true) {
lib.canvas_context[canvasID].moveTo( start_X, start_Y );
}
lib.canvas_context[canvasID].lineTo( end_X, end_Y );
if ( bStrokeTo == true) {
lib.canvas_context[canvasID].stroke();
}
}
function strokingRect( canvasID, sz_color, start_X, start_Y, x_Width, y_Height) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].strokeStyle = sz_color;
if ( lib.canvas_context[canvasID].lineWidth == 1) {
start_X = start_X + 0.5;
start_Y = start_Y + 0.5;
}
lib.canvas_context[canvasID].strokeRect( start_X, start_Y, x_Width, y_Height);
lib.canvas_context[canvasID].stroke();
lib.canvas_context[canvasID].closePath();
}
function fillingRect( canvasID, sz_color, start_X, start_Y, X_Width, Y_Height) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].fillStyle = sz_color;
if ( lib.canvas_context[canvasID].lineWidth == 1) {
start_X = start_X + 0.5;
start_Y = start_Y + 0.5;
}
lib.canvas_context[canvasID].fillRect( start_X, start_Y, X_Width, Y_Height);
lib.canvas_context[canvasID].fill();
lib.canvas_context[canvasID].closePath();
}
function drawing_Chart_Bkgrd_of( canvasID, range, chart_count, ar_gradient, n_Chart_Offset) {
var step_range = range/chart_count;
if ( n_Chart_Offset != 0) {
fillingRect( canvasID, lib.szColor_Backgrd_3, lib.n_X_Left_Top, lib.n_Y_Left_Top, n_Chart_Offset, get_MonitorHeight( canvasID));
}
for ( var i = 0; i < chart_count; i++) {
var o_Grd =lib.canvas_context[canvasID].createLinearGradient( (lib.n_X_Left_Top+(i*step_range)+n_Chart_Offset), 0, lib.n_X_Left_Top+(i*step_range)+Math.round((step_range*0.995)), 0);
for ( var j = 0; j < ar_gradient.length; j++) {
o_Grd.addColorStop( ar_gradient[j].pos, ar_gradient[j].color);
}
fillingRect( canvasID, o_Grd, (lib.n_X_Left_Top+( i*step_range)+n_Chart_Offset), lib.n_Y_Left_Top, step_range, get_MonitorHeight( canvasID));
}
}
function draw_horz_help_lines( canvasID, step_range) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].lineWidth=1;
lib.canvas_context[canvasID].strokeStyle = lib.szColor_HelpLine_Horz;
var step_count = get_MonitorHeight( canvasID)/step_range;
for ( var i = (step_count-1); i > 0; i--) {
var nX = lib.n_X_Left_Top + get_MonitorWidth( canvasID);
var nY = lib.n_Y_Left_Top + get_MonitorHeight( canvasID) - ( step_range*(i));
drawingLine( canvasID, Math.round(lib.n_X_Left_Top), Math.round(nY), Math.round(nX), Math.round(nY), true, true);
}
lib.canvas_context[canvasID].closePath();
}
function draw_vert_help_lines( canvasID, sz_Color, start_pos, step_range) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].lineWidth=1;
lib.canvas_context[canvasID].strokeStyle = sz_Color;
var step_count = get_MonitorWidth( canvasID)/step_range;
for ( var i = step_count; i >= 0; i--) {
var nX = lib.n_X_Left_Top + start_pos+ get_MonitorWidth( canvasID) - ( step_range*(i));
var nY = lib.n_Y_Left_Top + get_MonitorHeight( canvasID);
if ( (nX > lib.n_X_Left_Top) && (nX < lib.n_X_Left_Top + get_MonitorWidth( canvasID))) {
drawingLine( canvasID, Math.round(nX), Math.round(lib.n_Y_Left_Top), Math.round(nX), Math.round(nY), true, true);
}
}
lib.canvas_context[canvasID].closePath();
}
function drawing_scale_text( canvasID, ar_scale_text, direction, range, n_count, start_pos_x, start_pos_y, h_pos, v_pos, text_offset) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].textBaseline = h_pos;
lib.canvas_context[canvasID].textAlign = v_pos;
var n_step = ( range/n_count)
for ( var i = 0; i < ar_scale_text.length; i++) {
var nX = start_pos_x;
var nY = start_pos_y;
// console.log( "==>> drawing_scale_text_1["+i+"] = ("+ar_scale_text[i]+" | "+nX+" | "+nY+" | "+n_step+" | ");
if ( direction == "width") {
nX = nX + ( n_step*i);
nY = nY ;
} else {
nX = nX;
nY = nY + ( n_step*i);
}
lib.canvas_context[canvasID].fillText( ar_scale_text[i], nX, nY);
}
lib.canvas_context[canvasID].closePath();
}
function draw_scale_lines( canvasID, sz_color, direction, step_range, line_width, step_diff, offset_diff, b_shift_offset, n_shift_step) {
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].strokeStyle = sz_color;
var step_count = get_MonitorHeight( canvasID)/step_range;
var factor = 1;
if ((direction == "left") || ( direction == "top")) {
factor = -1;
}
var start_pos_x = lib.n_X_Left_Top;
var start_pos_y = lib.n_Y_Left_Top + get_MonitorHeight( canvasID);
if ( b_shift_offset == true) {
step_range = step_range - 1;
}
var n_tmp = get_MonitorHeight( canvasID)/step_range;
if ( direction == "left") {
lib.canvas_context[canvasID].clearRect( 0, lib.n_Y_Left_Top-1, lib.n_X_Left_Top-1, lib.n_Y_Left_Top+lib.n_Monitorg_Height);
}
if ( direction == "top") {
start_pos_x = lib.n_X_Left_Top + get_MonitorWidth( canvasID);
start_pos_y = lib.n_Y_Left_Top;
n_tmp = get_MonitorWidth( canvasID)/step_range;
lib.canvas_context[canvasID].clearRect( lib.n_X_Left_Top-1, 0, lib.n_X_Left_Top-1, lib.n_Y_Left_Top-1);
}
if ( direction == "right") {
start_pos_x = lib.n_X_Left_Top + get_MonitorWidth( canvasID);
start_pos_y = lib.n_Y_Left_Top + get_MonitorHeight( canvasID);
n_tmp = get_MonitorHeight( canvasID)/step_range;
lib.canvas_context[canvasID].clearRect( start_pos_x-1, lib.n_Y_Left_Top+1, lib.n_X_Left_Top, lib.n_Monitorg_Height+2);
}
if ( direction == "down") {
start_pos_x = lib.n_X_Left_Top + get_MonitorWidth( canvasID);
start_pos_y = lib.n_Y_Left_Top + get_MonitorHeight( canvasID);
n_tmp = get_MonitorWidth( canvasID)/step_range;
lib.canvas_context[canvasID].clearRect( lib.n_X_Left_Top, start_pos_y+1, get_MonitorWidth( canvasID), (2*lib.n_Y_Left_Top)+lib.n_Monitorg_Height);
}
var step_count = parseInt( String(n_tmp), 10);
if ( b_shift_offset == true) {
step_count = step_count - 1;
}
var nX_1 = start_pos_x;
var nY_1 = start_pos_y;
var nX_2 = nX_1;
var nY_2 = nY_1;
for ( var i = step_count; i >= 0; i--) {
if ((direction == "down") || ( direction == "top")) {
nX_1 = start_pos_x - (step_range*i);
nX_2 = nX_1;
if ( i%step_diff) {
nY_1 = start_pos_y + (factor*(line_width-offset_diff));
} else {
if ( n_shift_step == 0) {
nY_1 = start_pos_y + (factor*line_width);
} else {
nY_1 = start_pos_y + (factor*line_width);
var nX_Skip1 = nX_1 + ( step_range * n_shift_step);
var nX_Skip2 = nX_Skip1;
if ( nX_Skip1 < (lib.n_X_Left_Top + get_MonitorWidth( canvasID))) {
lib.canvas_context[canvasID].strokeStyle = "#FF0000";
drawingLine( canvasID, Math.round( nX_Skip1), Math.round( nY_1), Math.round( nX_Skip2), Math.round( nY_2), true, true);
lib.canvas_context[canvasID].strokeStyle = sz_color;
}
nY_1 = start_pos_y + (factor*(line_width-offset_diff));
}
}
} else {
nY_1 = start_pos_y - (step_range*i);
nY_2 = nY_1;
if ( i%step_diff) {
nX_2 = start_pos_x + (factor*(line_width-offset_diff));
} else {
nX_2 = start_pos_x + (factor*line_width);
}
}
if ( b_shift_offset == true) {
nX_1 = nX_1 - (n_tmp/2);
nX_2 = nX_2 - (n_tmp/2);
}
drawingLine( canvasID, Math.round( nX_1), Math.round( nY_1), Math.round( nX_2), Math.round( nY_2), true, true);
}
lib.canvas_context[canvasID].closePath();
}
function chartRect( nX, nY, nWidth, nHeight) {
this.nX = nX;
this.nY = nY;
this.nWidth = nWidth;
this.nHeight = nHeight;
}
function drawing_chart_of( canvasID, factor_value, chart_relation, direction, n_X_start, n_Y_start, n_width, n_height) {
var szUnit = "Wh";
if ( factor_value == 1000) {
var szUnit = "kWh";
}
var nY_Step = n_height/lib.CurrentFactor(canvasID);
var nX_Step = n_width/lib.EnergyValuesSize(canvasID);
var n_ChartWidth = chart_relation * nX_Step;
var nX_Step_half = (nX_Step/2);
var n_ChartWidth_half = (n_ChartWidth/2);
var nX_Step_Offset = nX_Step_half - n_ChartWidth_half;
if ( direction == "left") {
nX_Step_Offset = 1;
}
if ( direction == "right") {
nX_Step_Offset = nX_Step - n_ChartWidth_half - 1;
}
lib.canvas_context[canvasID].beginPath();
lib.canvas_context[canvasID].globalAlpha = .8;
var ar_EnergyAreaRect = new Array();
for ( var i = 0; i < lib.EnergyValuesSize(canvasID); i++) {
var compute_value = ((getEnergyValueOf( "Wh", i, canvasID)/factor_value)*nY_Step);
compute_value = get_ShowFactor( szUnit, compute_value);
var nX_Start = n_X_start+(i*nX_Step) + nX_Step_Offset;
var nY_Start = n_Y_start + get_MonitorHeight( canvasID); // - compute_value;
if ( lib.EnergyValuesSize(canvasID)-1 == i) {
lib.canvas_context[canvasID].globalAlpha = 0.4;
}
ar_EnergyAreaRect[i] = new chartRect( Math.round(nX_Start), Math.round(nY_Start-compute_value)-1, Math.round(n_ChartWidth), Math.round(compute_value));
fillingRect( canvasID, sChartFillColor, Math.round(nX_Start), Math.round(nY_Start)-1, Math.round(n_ChartWidth), Math.round(-compute_value));
strokingRect( canvasID, sChartFillColor, Math.round(nX_Start), Math.round(nY_Start)-1, Math.round(n_ChartWidth), Math.round(-compute_value));
}
lib.ar_RectValues[canvasID] = ar_EnergyAreaRect;
lib.canvas_context[canvasID].globalAlpha = 1.0;
lib.canvas_context[canvasID].closePath();
}
return lib;
})();
