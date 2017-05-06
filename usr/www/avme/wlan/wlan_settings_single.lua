<?lua
if not gl or not gl.logged_in then
box.end_page()
end
?>
<div id="uiSingleMon" >
<div class="row <?lua write_wlan_failed()?>">
<input type="checkbox" onclick="OnActivated('both',this.checked)" id="uiView_Active" name="active" <?lua write_active()?>>&nbsp;<label for="uiView_Active">{?g_txtWlanActive?}</label>
</div>
<div id="uiOption" class="formular">
<div class="row">
{?782:340?}
</div>
<div class="row">
<label for="uiView_SSID">{?782:619?}</label>
<input type="text" size="33" maxlength="32" id="uiView_SSID" name="SSID" value="<?lua box.html(g_ssid)?>">
</div>
<div id="uiExpertFeatures" class="" style="<?lua write_expert_features() ?>">
<div class="row">
<input type="checkbox" id="uiView_HiddenSSID" name="hidden_ssid" <?lua write_hidden()?>>&nbsp;<label for="uiView_HiddenSSID" <?lua write_hidden()?>>{?782:516?}</label></td>
</div>
<div class="row">
<label>{?782:708?}</label>
<span><?lua box.out(box.query("wlan:settings/wlanmac_ap")) ?></span>
</div>
</div>
</div>
</div>
