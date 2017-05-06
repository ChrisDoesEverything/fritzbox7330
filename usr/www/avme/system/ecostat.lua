<?lua
g_page_type = "all"
g_page_title = [[]]
g_page_help = 'hilfe_system_energiestatistik.html'
dofile("../templates/global_lua.lua")
?>
<?include "templates/html_head.html" ?>
<link rel="stylesheet" type="text/css" href="/css/default/statistik.css"/>
<script type="text/javascript" src="/js/statistik.js"></script>
<script type="text/javascript">
var g_ieVers="";
var g_CurrentHour= "<?lua box.js(box.query([[cpu:status/StatCurrentInterval]])) ?>";
g_CurrentHour = Math.floor((Number(g_CurrentHour) || 0) / 10);
function GetMaximum(Values)
{
var Max = Values[0];
for (var Index = 1; Index < Values.length; Index++)
{
if (Values[Index] > Max)
{
Max = Values[Index];
}
}
Max+=10;
return Max;
}
function GetMinimumMinus10(Values)
{
var Min = GetMaximum(Values);
for (var Index = 0; Index < Values.length; Index++)
{
if ((Values[Index] > 0) && (Min > Values[Index]))
{
Min = Values[Index];
}
}
if (Min > 10)
{
Min -= 10;
}
return Min;
}
function KonvertToNum(Result, BarInfo, BarId, Query)
{
BarInfo[BarId].PerCentList = Query.split(",");
Result.Available = false;
var Length = BarInfo[BarId].PerCentList.length;
for (var Tupel = 0; Tupel < Length; Tupel++)
{
BarInfo[BarId].PerCentList[Tupel] = parseInt(BarInfo[BarId].PerCentList[Tupel]) || 0;
if (BarInfo[BarId].PerCentList[Tupel] != 0)
{
Result.Available = true;
}
}
return Length;
}
function QueryNotSuccess(Query)
{
return (Query == "er") || (Query == "err") || (Query == "");
}
function Statistik24CPUFrequency()
{
var Query1 = "<?lua box.js(box.query([[cpu:status/StatCPU]])) ?>";
var Query2 = "<?lua box.js(box.query([[cpu:status/StatCPUFrequency]])) ?>";
var BarInfo = Statistik_SetDefault(2, "t24StundenDiagramCpu");
BarInfo["MasterClass"] = "MasterBarCpu";
BarInfo["YMaxRelPos"] = -32;
BarInfo["YMaxValue"] = "100";
BarInfo["YMinValue"] = "0";
if (QueryNotSuccess(Query1) || QueryNotSuccess(Query2))
{
jxl.hide("uiViewCpu");
return "";
}
var Result = new Object();
BarInfo["CountValues"] = KonvertToNum(Result, BarInfo, "Val2", Query1);
if (! Result.Available)
{
jxl.hide("uiViewCpu");
return "";
}
Query2 = Query2.split(",");
for (var Tupel = 0; Tupel < BarInfo["Val2"].PerCentList.length; Tupel++)
{
BarInfo["Val2"].Hints.push("");
}
BarInfo["Val2"].PerCentList = BarInfo["Val2"].PerCentList.reverse();
BarInfo["Val2"].Hints = BarInfo["Val2"].Hints.reverse();
BarInfo["Val2"].IconClass = "Bar_black";
BarInfo["Val2"].BarWidth = BarInfo["BarWidth"];
Statistik_GetHiddenBar(BarInfo, "Val1", "Val2");
BarInfo["XAxisVal"] = Statistik_GetHourValues(g_CurrentHour, 24);
var Result = Statistik_GetHtmlCode(BarInfo);
jxl.show("uiViewCpu", true);
return Result;
}
function Statistik24Temperature()
{
var Query2 = "<?lua box.js(box.query([[cpu:status/StatTemperature]])) ?>";
var BarInfo = Statistik_SetDefault(2, "t24StundenDiagramTemperature");
BarInfo["MasterClass"] = "MasterBarTemperature";
BarInfo["YMaxValue"] = "140";
BarInfo["YMinValue"] = "40";
BarInfo["YMaxRelPos"] = -32;
if (QueryNotSuccess(Query2))
{
jxl.hide("uiViewTemperature");
return "";
}
var Result = new Object();
BarInfo["CountValues"] = KonvertToNum(Result, BarInfo, "Val2", Query2);
if (!Result.Available)
{
jxl.hide("uiViewTemperature");
return "";
}
var MinValue = 40;
var MaxValue = 140;
for (var i = 0; i < BarInfo.Val2.PerCentList.length; i++)
{
var val = BarInfo.Val2.PerCentList[i];
BarInfo.Val2.PerCentList[i] = Math.min(MaxValue, Math.max(MinValue, val)) - MinValue;
BarInfo["Val2"].Hints.push("");
}
BarInfo["Val2"].PerCentList = BarInfo["Val2"].PerCentList.reverse();
BarInfo["Val2"].Hints = BarInfo["Val2"].Hints.reverse();
BarInfo["Val2"].IconClass = "Bar_black";
BarInfo["Val2"].BarWidth = BarInfo["BarWidth"];
Statistik_GetHiddenBar(BarInfo, "Val1", "Val2");
BarInfo["XAxisVal"] = Statistik_GetHourValues(g_CurrentHour, 24)
var Result = '<div style="position:relative;">';
Result += Statistik_GetHtmlCode(BarInfo);
Result += '<span class="redline" style="top:23px;left:30px;"></span>';
Result += '</div>';
jxl.show("uiViewTemperature");
return Result;
}
function Statistik24RamValue()
{
var Tmp = { "Query1" : "<?lua box.js(box.query([[cpu:status/StatRAMPhysFree]])) ?>",
"Query2" : "<?lua box.js(box.query([[cpu:status/StatRAMCacheUsed]])) ?>",
"Query3" : "<?lua box.js(box.query([[cpu:status/StatRAMStrictlyUsed]])) ?>",
"Val1" : new Array(),
"Val2" : new Array(),
"Val3" : new Array(),
"MaxList1" : new Array(),
"MaxList2" : new Array(),
"MaxList3" : new Array(),
"Hints1" : "% {?8645:697?}",
"Hints2" : "% {?8645:86?}",
"Hints3" : "% {?8645:572?}",
"CountCombine" : 10,
"CountMaxTupel" : 24,
"IconClass1" : "Bar1",
"IconClass2" : "Bar2",
"IconClass3" : "Bar3"
};
var BarInfo = Statistik_SetDefault(3, "t24StundenDiagramRam");
BarInfo["MasterClass"] = "MasterBarRam";
BarInfo["YMaxRelPos"] = -32;
BarInfo["YMaxValue"] = "100";
BarInfo["YMinValue"] = "0";
BarInfo["CountBars"] = 3;
BarInfo["BarWidth"] = 20;
BarInfo["EmptyBarWidth"] = 0;
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
if (QueryNotSuccess(Tmp["Query" + BarNr]))
{
jxl.hide("uiViewRamValue");
return "";
}
}
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
Tmp["Val" + BarNr] = Tmp["Query" + BarNr].split(",");
for (var Tupel = 0; Tupel < Tmp["Val" + BarNr].length; Tupel++)
{
Tmp["Val" + BarNr][Tupel] = parseInt(Tmp["Val" + BarNr][Tupel]);
}
}
BarInfo["CountValues"] = Tmp["Val1"].length;
for (var BarNr = 2; BarNr <= BarInfo["CountBars"]; BarNr++)
{
if (Tmp["Val" + BarNr].length != BarInfo["CountValues"])
{
jxl.hide("uiViewRamValue");
return "";
}
}
for (var Tupel = 0; Tupel < Tmp["Val1"].length; Tupel++)
{
if ((Tmp["Val1"][Tupel] + Tmp["Val2"][Tupel] + Tmp["Val3"][Tupel]) != 100)
{
jxl.hide("uiViewRamValue");
return "";
}
}
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
BarInfo["Val" + BarNr].PerCentList = Statistik_Combine(Tmp["Val" + BarNr], "Max", Tmp["CountCombine"], 100);
Tmp["MaxList" + BarNr] = Statistik_CombineListe(Tmp["Val" + BarNr], Tmp["CountCombine"]);
BarInfo["Val" + BarNr].IconClass = Tmp["IconClass" + BarNr];
BarInfo["Val" + BarNr].BarWidth = BarInfo["BarWidth"];
for (var Tupel = 0; Tupel < BarInfo["Val" + BarNr].PerCentList.length; Tupel++)
{
BarInfo["Val" + BarNr].Hints.push("");
}
}
var TotalHigh = 0;
for (var Tupel = 0; Tupel < BarInfo["Val1"].PerCentList.length; Tupel++)
{
TotalHigh = BarInfo["Val1"].PerCentList[Tupel] + BarInfo["Val2"].PerCentList[Tupel]
+ BarInfo["Val3"].PerCentList[Tupel];
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
BarInfo["Val" + BarNr].PerCentList[Tupel] = Math.floor( (BarInfo["Val" + BarNr].PerCentList[Tupel] * 100) / TotalHigh);
}
Statistik_StretchTupel(BarInfo, Tupel, 100);
}
BarInfo["CountValues"] = BarInfo["CountValues"] / Tmp["CountCombine"];
if (BarInfo["CountValues"] > Tmp["CountMaxTupel"])
{
BarInfo["CountValues"] = Tmp["CountMaxTupel"];
}
for (var BarNr = 1; BarNr <= BarInfo["CountBars"]; BarNr++)
{
BarInfo["Val" + BarNr].PerCentList = BarInfo["Val" + BarNr].PerCentList.reverse();
BarInfo["Val" + BarNr].Hints = BarInfo["Val" + BarNr].Hints.reverse();
}
BarInfo["XAxisVal"] = Statistik_GetHourValues(g_CurrentHour, BarInfo["CountValues"])
var Result = Statistik_GetHtmlCode(BarInfo);
jxl.show("uiViewRamValue");
return Result;
}
</script>
<?include "templates/page_head.html" ?>
<p>{?8645:478?}</p>
<hr />
<div id="uiViewCpu">
<h4>{?8645:355?}</h4>
<div class="formular">
<p>{?8645:141?}</p>
<p class="stat_top">{?8645:62?}</p>
<script type="text/javascript">document.write(Statistik24CPUFrequency());</script>
<p class="stat_bottom">{?8645:551?}</p>
</div>
</div>
<div id="uiViewTemperature">
<h4>{?8645:663?}</h4>
<div class="formular">
<p>{?8645:476?}</p>
<p class="stat_top">{?8645:427?}</p>
<script type="text/javascript">document.write(Statistik24Temperature());</script>
<p class="stat_bottom">{?8645:623?}</p>
</div>
</div>
<div id="uiViewRamValue">
<h4>{?8645:0?}</h4>
<div class="formular">
<p>{?8645:293?}</p>
<p class="stat_top">{?8645:595?}</p>
<script type="text/javascript">document.write(Statistik24RamValue());</script>
<table class="ram_legend">
<tr><td class="tdRamLegende"><img src="/css/default/images/balkeneinheit24-blau.gif"> {?8645:675?}</td></tr>
<tr><td class="tdRamLegende"><img src="/css/default/images/balkeneinheit24.gif"> {?8645:884?}</td></tr>
<tr><td class="tdRamLegende"><img src="/css/default/images/balkeneinheit24-gruen.gif"> {?8645:65?}</td></tr>
</table>
<p class="stat_bottom">{?8645:946?}</p>
</div>
</div>
<form method="POST" action="/system/ecostat.lua">
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<button type="submit" name="reload">{?txtRefresh?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
