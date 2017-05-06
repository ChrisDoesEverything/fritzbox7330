var g_IeVers = "";
var g_Navigator = "";
function SetIeVersion()
{
var ieVers = navigator.appVersion;
var version = ieVers.substring(ieVers.search(';') + 1, ieVers.search('MSIE') + 8);
ieVers = version.substring(5);
if (navigator.appName == "Microsoft Internet Explorer")
{
g_IeVers = (ieVers.search("6.0") != -1) ? "6" : (ieVers.search("7.0") != -1) ? "7" : "";
g_Navigator = "IE";
return;
}
if (navigator.appName == "Netscape")
{
g_Navigator = "NS";
return;
}
if (navigator.appName == "Opera")
{
g_Navigator = "OP";
}
}
function Statistik_GetYAxisDescript(DescText, Pos, BarInfo)
{
return "<div style=\"position: relative; top: " + Pos + "px;left:" + BarInfo["YMaxRelPosAxisDist"]
+ "px; font-size: 80%; text-align: center;\">\n" + ((DescText == "") ? "&nbsp;" : DescText) + "\n</div>\n";
}
function Statistik_GetYAxisCol(BarInfo)
{
return "<td class=\"" + BarInfo["YAxisClass"] + "\" width=\"" + BarInfo["YAxisWidth"] + "px\" height=\""
+ BarInfo["YAxisHeight"] + "px\">\n"
+ Statistik_GetYAxisDescript(BarInfo["YMaxValue"], BarInfo["YMaxRelPos"], BarInfo)
+ Statistik_GetYAxisDescript(BarInfo["YMinValue"], BarInfo["YMinRelPos"], BarInfo)
+ "</td>\n";
}
function Statistik_GetColumns(BarInfo)
{
var ResultCode = "";
if (BarInfo["FrontBarWidth"] != 0)
{
ResultCode += "<td width=\"" + BarInfo["FrontBarWidth"] + "px\">\n</td>\n";
}
for (var Tupel = 0; Tupel < BarInfo["CountValues"]; Tupel++)
{
ResultCode += "<td valign=\"bottom\" width=\"" + BarInfo["BarWidth"] + "px\">\n";
ResultCode += "<div class=\"" + BarInfo["MasterClass"] + "\">\n";
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
var TitelCode = (BarInfo["Val" + BarNr].Hints[Tupel] == "")
? "" : " title=\"" + BarInfo["Val" + BarNr].Hints[Tupel] + "\"";
var ClassCode = (typeof(BarInfo["Val" + BarNr].IconClass) == "string")
? BarInfo["Val" + BarNr].IconClass : BarInfo["Val" + BarNr].IconClass[Tupel];
ClassCode = (ClassCode == "") ? "" : " class=\"" + ClassCode + "\"";
var BarWidth = (typeof(BarInfo["Val" + BarNr].BarWidth) == "number")
? BarInfo["Val" + BarNr].BarWidth : BarInfo["Val" + BarNr].BarWidth[Tupel];
var h = parseInt(BarInfo["Val" + BarNr].PerCentList[Tupel],10) || 0;
if (h > 0)
{
ResultCode += "<div" + ClassCode + " style=\"height:" + BarInfo["Val" + BarNr].PerCentList[Tupel] + "px; width:"
+ BarWidth + "px;\"" + TitelCode + "></div>\n";
}
}
ResultCode += "</div>\n</td>\n"
if (BarInfo["EmptyBarWidth"] != 0)
{
ResultCode += "<td width=\"" + BarInfo["EmptyBarWidth"] + "px\">\n</td>\n";
}
}
return ResultCode;
}
function Statistik_GetDiagram(BarInfo)
{
return "<tr>\n"
+ Statistik_GetYAxisCol(BarInfo)
+ Statistik_GetColumns(BarInfo)
+ "</tr>\n";
}
function Statistik_GetXAxis(BarInfo)
{
var ResultCode = "<tr>\n"
+ "<td class=\"" + BarInfo["XAxisClass"] + "\" width=\"" + BarInfo["YAxisWidth"] + "px\" height=\""
+ BarInfo["XAxisHeigth"] + "px\">\n</td>\n";
if (BarInfo["FrontBarWidth"] != 0)
{
ResultCode += "<td width=\"" + BarInfo["FrontBarWidth"] + "px\">\n</td>\n";
}
var XValCombine = BarInfo["CountValues"] / BarInfo["XValCount"];
if (BarInfo["EmptyBarWidth"] != 0)
{
XValCombine *= 2;
}
var ColSpanText = (XValCombine != 1) ? "colspan=\"" + XValCombine + "\"" : "";
for (var Index = 0; Index < BarInfo["XValCount"]; Index++)
{
ResultCode += "<td class=\"" + BarInfo["XAxisClass"] + "\" " + ColSpanText + ">"
+ BarInfo["XAxisVal"][Index] + "\n</td>\n";
}
return ResultCode + "</tr>\n";
}
function Statistik_PerCentToPixel(Data, MaxPixel)
{
var Pixels = new Array();
for (var Index = 0; Index < Data.length; Index++)
{
Pixels.push(Math.floor(MaxPixel * (Data[Index] / 100)));
}
return Pixels;
}
function Statistik_GetHtmlCode(BarInfo)
{
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
BarInfo["Val" + BarNr].PerCentList = Statistik_PerCentToPixel(BarInfo["Val" + BarNr].PerCentList, BarInfo["DrawTableHeight"]);
}
for (var Tupel = 0; Tupel < BarInfo["Val1"].PerCentList.length; Tupel++)
{
Statistik_StretchTupel(BarInfo, Tupel, BarInfo["DrawTableHeight"]);
}
return "<table style=\"margin-left:" + BarInfo["LeftMargin"] + "px;\" id=\"" + BarInfo["Id"]
+ "\" class=\"" + BarInfo["TableClass"] + "\">\n"
+ "<tbody>\n"
+ Statistik_GetDiagram(BarInfo) + Statistik_GetXAxis(BarInfo)
+ "</tbody>\n"
+ "</table>\n";
}
function Statistik_Combine(Data, Typ, ActionOnCount, MaxExclude)
{
var Values = new Array();
var Value = 0;
var Count = 0;
var Summe = 0;
var Init = true;
for (var Index = 0; Index < Data.length; Index++)
{
if (Init)
{
Value = (Typ == "Max") ? -1 : Data[Index];
Count = 0;
Init = false;
Summe = 0;
}
Count++;
if ((Typ == "Max") && (Data[Index] > Value))
{
if (Data[Index] < MaxExclude)
{
Value = Data[Index];
}
}
else if ((Typ == "Min") && (Data[Index] < Value))
{
Value = Data[Index];
}
else if (Typ == "Ave")
{
Summe += Data[Index];
if (Count == ActionOnCount)
{
Value = Math.floor(Summe / ActionOnCount);
}
}
if (Count >= ActionOnCount)
{
if (Value == -1)
{
Value = MaxExclude;
}
Values.push(Value);
Init = true;
}
}
return Values;
}
function Statistik_CombineListe(Data, ActionOnCount)
{
var Values = new Array();
var Value = "";
var Count = 0;
for (var Index = 0; Index < Data.length; Index++)
{
Count++;
Value += "," + Data[Index];
if (Count == ActionOnCount)
{
Values.push(Value.substring(1));
Value = "";
Count = 0;
}
}
return Values;
}
function Statistik_GetHourValues(CurrentHour, Count)
{
var Liste = new Array();
for (var Hour = Number(CurrentHour) + 1; Hour < (24 + Count); Hour++)
{
Liste.push(Hour % 24);
}
return Liste;
}
function Statistik_GetHiddenBar(BarInfo, HiddenId, ValId)
{
for (var Index = 0; Index < BarInfo["CountValues"]; Index++)
{
BarInfo[HiddenId].PerCentList.push(100 - BarInfo[ValId].PerCentList[Index]);
BarInfo[HiddenId].Hints.push("");
}
BarInfo[HiddenId].BarWidth = BarInfo["BarWidth"];
BarInfo[HiddenId].IconClass = "";
BarInfo["CountBars"]++;
}
function Statistik_StretchTupel(BarInfo, Tupel, MaxValue)
{
var Summe = 0;
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
Summe += BarInfo["Val" + BarNr].PerCentList[Tupel];
}
while (true)
{
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
if (Summe++ >= MaxValue)
{
return;
}
BarInfo["Val" + BarNr].PerCentList[Tupel]++;
}
}
}
function Statistik_SetDefault(MaxBarNr, Id)
{
SetIeVersion();
var BarInfo = {
"Id" : Id,
"TableClass" : "td24StundenDiagram",
"LeftMargin" : 10,
"YAxisHeight" : (g_Navigator == "NS") ? 94 : 90,
"DrawTableHeight" : 80,
"YAxisClass" : "tdYAchse",
"YAxisWidth" : 22,
"YMaxValue" : "",
"YMaxRelPosAxisDist" : -5,
"YMaxRelPos" : -25,
"YMinValue" : "",
"YMinRelPos" : 36,
"CountValues" : 0,
"CountBars" : 1,
"FrontBarWidth" : 0,
"BarWidth" : 1,
"EmptyBarWidth" : 1,
"IconStrategy" : "Top",
"MasterClass" : "",
"XAxisHeigth" : 6,
"XAxisClass" : "tdXAchse",
"XAxisVal" : new Array(),
"XValCount" : 24
};
for (var BarNr = 1; BarNr <= MaxBarNr; BarNr++)
{
BarInfo["Val" + BarNr] = {PerCentList : new Array(), Hints: new Array(), IconClass: new Array(), BarWidth: new Array()};
}
return BarInfo;
}
