/*
*/
if (!ajaxGet) document.write('<script type="text/javascript" src="/js/ajax.js"></script>');
var abSwitch = abSwitch || (function() {
var lib = {};
var jsonObj = makeJSONParser();
lib.toggle = function(tamNr, sid)
{
var my_url = "/lua/tam_switch.lua?sid="+sid+"&TamNr="+tamNr;
ajaxGet(my_url, abSwitch.cbToggle);
};
lib.cbToggle = function(response)
{
if (response && response.status == 200)
{
var resp = jsonObj(response.responseText);
if (resp)
{
var new_class = "switch_off";
if (resp.switch_on)
{
new_class = "switch_on";
if (resp.allin && resp.cur_idx == 0)
{
jxl.get("uiIncommingNumberstam"+resp.cur_idx).innerHTML = "{?9563:282?}";
}
else
{
jxl.get("uiIncommingNumberstam"+resp.cur_idx).innerHTML = resp.numbers.replace(/;/g,"<br>");
}
jxl.removeClass("uiSwitch"+resp.cur_idx,"switch_off");
}
else
{
jxl.setHtml("uiIncommingNumberstam"+resp.cur_idx, "{?9563:928?}");
jxl.removeClass("uiSwitch"+resp.cur_idx,"switch_on");
}
jxl.addClass("uiSwitch"+resp.cur_idx,new_class);
}
}
}
return lib;
})();
