var g_scanList = [];
function OnChangeInput(value, id) {
jxl.setText(id, value.length + " ");
}
function resetPskvalue() {
jxl.setValue("uiPskvalue:oma_wlan", "");
OnChangeInput("", 'uiDezKeyWpa');
}
var wpa_convert = {
"wpa": "2", "wpa2": "3", "wpamixed": "4"
};
function syncHiddenInputs(idx) {
var dev = g_scanList[idx] || {};
jxl.setValue("uiStamac:oma_wlan", dev.mac || "");
jxl.setValue("uiStassid:oma_wlan", dev.ssid || "");
jxl.setValue("uiStaenc:oma_wlan", wpa_convert[dev.encStr] || "");
}
function syncSsid(idx) {
var dev = g_scanList[idx] || {};
jxl.setDisabled("uiHiddenssid:oma_wlan", dev.ssid);
jxl.display("uiSsid", !dev.ssid);
}
function UncheckAll(elem) {
jxl.walkDom("uiListOfAps", "tr", function(tr) {
jxl.walkDom(tr, "input", function(checkbox) {
if (elem != checkbox) {
jxl.removeClass(tr.id, "highlight");
checkbox.checked = false;
}
});
});
}
function OnChangeActive(elem, n) {
if (!elem.checked) {
return false;
}
UncheckAll(elem);
jxl.addClass("uiViewRow" + n, "highlight");
syncHiddenInputs(n);
resetPskvalue();
syncSsid(n);
return true;
}
function syncOnScanDone() {
var i = 0;
for (var i = 0; i < g_scanList.length; i++) {
if (g_scanList[i].checked) {
syncHiddenInputs(i);
syncSsid(i);
return;
}
}
}
var gUrl
function OnDoRefresh(sid) {
gUrl = encodeURI("/internet/internet_settings.lua")
gUrl += "?" + encodeURIComponent("sid") + "=" + encodeURIComponent(sid);
gUrl += "&" + encodeURIComponent("wlanscan") + "=";
doRequestRefreshData(true);
}
function wlanscanOnload(params) {
params = params || {};
var sid = params.sid;
var scan = params.scan;
gUrl = encodeURI(params.url || "/internet/internet_settings.lua")
gUrl += "?" + encodeURIComponent("sid") + "=" + encodeURIComponent(sid);
gUrl += "&" + encodeURIComponent("wlanscan") + "=";
if (params.stamac) {
gUrl += "&" + encodeURIComponent("stamac") + "=" + params.stamac;
}
doRequestRefreshData(!scan || scan.state == 'error');
}
function doRequestRefreshData(start) {
if (gUrl) {
var url = gUrl;
if (start === true) {
url += "&" + encodeURIComponent("startscan") + "=";
}
ajaxGet(url, cbRefresh);
}
}
var json = makeJSONParser();
function cbRefresh(response) {
var askAgain = true;
if (response && response.status == 200) {
var answer = json(response.responseText || "null");
if (answer && answer.state) {
jxl.setHtml("uiWlanCurList", answer.html);
if (answer.state != "busy") {
g_scanList = answer.scanlist || [];
syncOnScanDone();
askAgain = false;
if (jxl.get("uiScanResult"))
{
sort.init("uiScanResult");
if (jxl.get("uiListOfAps"))
{
sort.addTbl(uiListOfAps);
}
sort.sort_table(0);
}
zebra();
}
}
}
if (askAgain) {
setTimeout(doRequestRefreshData, 2000);
}
}
