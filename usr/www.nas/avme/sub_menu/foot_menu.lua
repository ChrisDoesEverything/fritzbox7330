<?lua
if not gl or not gl.logged_in then
box.end_page()
end
?>
<div id="foot_menue_box">
<?lua
if not gl.filelink_mode then
box.out([[<a href="javascript:showWhatsNewInfo();">]]..box.tohtml([[{?258:156?}]])..[[</a> | ]])
end
box.out([[<a href="http://www.avm.de" target="_blank">]]..box.tohtml([[{?258:375?}]])..[[</a>]])
?>
</div>
<script type="text/javascript">
function showWhatsNewInfo()
{
if ( "first" == gDisableMainPageBox_whatis )
{
gDisableMainPageBox_whatis = createModalBox( createBoxContent( "all", "whatsnew" ) );
}
var head = '<b>{?258:695?}</b>';
var content = '<div><ul>';
content += '<li>{?258:464?}</li>';
content += '<li>{?258:280?}</li>';
content += '<li>{?258:996?}</li>';
content += '<li>{?258:515?}</li>';
content += '<li>{?258:409?}</li>';
content += '<li>{?258:78?}</li>';
content += '</ul>';
content += '<b>{?258:112?}</b>';
content += '<p><b>{?258:318?}</b><br>{?258:474?}</p>';
content += '<p><b>{?258:35?}</b><br>{?258:749?}</p>';
content += '<p><b>{?258:338?}</b><br>{?258:172?}</p>';
content += '</div>';
var foot = '<button tabindex="1" id="idBtnOk" type="button" onclick="gDisableMainPageBox_whatis.close()">{?258:558?}</button>';
fillBoxContent( head, content, foot, "_whatsnew" );
gDisableMainPageBox_whatis.open();
}
</script>
