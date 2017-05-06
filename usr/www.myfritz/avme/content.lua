<?lua
if not gl or not gl.logged_in then
box.end_page()
end
box.out([[<div id="page_content">]])
if gl.areas then
local areas_sorted = {}
for idx, area in pairs(gl.areas) do
if area.show then
areas_sorted[gl.areas[idx].pos] = gl.areas[idx]
areas_sorted[gl.areas[idx].pos].idx = idx
end
end
for i, area in pairs(areas_sorted) do
box.out([[
<div id="]], tostring(area.id), [[" class="]], tostring(area.idx), [[ area_box">
<div class="area_head" >
<div><h2>]], box.tohtml(area.label), [[</h2></div>
</div>
<div id="]], tostring(area.idx), [[Content" class="area_content wait_state">
</div>
<div class="area_foot">
</div>
<div class="area_overview">
<div class="area_ov_icon"></div>
<div class="area_ov_indicator"></div>
<div class="area_ov_name"><p>]], box.tohtml(area.label), [[</p></div>
<div id="]], tostring(area.idx), [[AreaOvContent" class="area_ov_content"></div>
</div>
</div>
]])
end
end
box.out([[</div>]])
?>
