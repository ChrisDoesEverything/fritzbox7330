<?lua
if not gl or not gl.logged_in then
box.end_page()
end
?>
<div id="uiDoubleMon" class="formular small_indent">
<div class="row">
{?35:444?}
</div>
<div id="uiDoubleMon_NonExpert" class="" style="<?lua write_non_expert_features() ?>">
<div class="row <?lua write_wlan_failed()?>">
<input type="checkbox" onclick="OnActivated('both',this.checked)" id="uiView_Active" name="active" <?lua write_active('both')?>>&nbsp;<label for="uiView_Active">{?g_txtWlanActive?}</label>
</div>
<div id="uiOption" class="formular">
<div class="row">
<label for="uiView_SSID">{?35:423?}</label>
<input type="text" size="33" maxlength="32" id="uiView_SSID" name="SSID" value="<?lua box.html(g_ssid)?>">
</div>
</div>
</div>
<div style="<?lua write_expert_features() ?>">
<div id="uiDoubleMon_24" class="tborder" >
<h4>{?35:899?}</h4>
<div class="row <?lua write_wlan_failed()?>" >
<input type="checkbox" onclick="OnActivated('24',this.checked)" id="uiView_Active_24" name="active_24" <?lua write_active()?>>&nbsp;<label for="uiView_Active_24">{?g_txtWlanActive?}</label>
</div>
<div id="uiOption_24" class="formular">
<div class="row">
<label for="uiView_SSID_24">{?35:788?}</label>
<input type="text" size="33" maxlength="32" id="uiView_SSID_24" name="SSID_24" value="<?lua box.html(g_ssid)?>">
</div>
<div class="row">
<label>{?35:997?}</label>
<span><?lua box.out(box.query("wlan:settings/wlanmac_ap")) ?></span>
</div>
</div>
</div>
<div id="uiDoubleMon_5" class="tborder2">
<h4>{?35:34?}</h4>
<div class="row <?lua write_wlan_failed()?>" >
<input type="checkbox" onclick="OnActivated('5',this.checked)" id="uiView_Active_5" name="active_5" <?lua write_active_scnd()?>>&nbsp;<label for="uiView_Active_5">{?g_txtWlanActive?}</label>
</div>
<div id="uiOption_5" class="formular">
<div class="row">
<label for="uiView_SSID_5">{?35:469?}</label>
<input type="text" size="33" maxlength="32" id="uiView_SSID_5" name="SSID_5" value="<?lua box.html(g_ssid_scnd)?>">
</div>
<div class="row">
<label>{?35:114?}</label>
<span><?lua box.out(box.query("wlan:settings/wlanmac_ap_scnd")) ?></span>
</div>
</div>
</div>
<div id="uiExpertFeatures" class="formular">
<div class="row">
<input type="checkbox" id="uiView_HiddenSSID" name="hidden_ssid" <?lua write_hidden()?>>&nbsp;<label for="uiView_HiddenSSID">{?35:896?}</label>
</div>
</div>
</div>
</div>
