--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("elem")
require("general")
require("date")
function is_valid_uleid( n_ule_id)
if ( n_ule_id == nil ) then
return false
end
if ( tonumber( n_ule_id) == nil ) then
return false;
end
if (( tonumber( n_ule_id) < 15) or ((tonumber(n_ule_id) > 416) and (tonumber(n_ule_id) < 900))) then
return false
end
return true
end
function get_time_as_min_of( n_year, n_month, n_day, n_hour, n_min)
local l_start_time = os.time{year=2010, month=1, day=1, hour=0, min=0}
local l_end_time = 0
if ( n_year ~= nil and n_month ~= nil and n_day ~= nil and n_hour ~= nil and n_min ~= nil) then
l_end_time = os.time{year=n_year, month=n_month, day=n_day, hour=n_hour, min=n_min}
else
l_end_time = os.time()
end
return tonumber( math.floor((os.difftime( l_end_time, l_start_time))/60))
end
function is_timer_active( t_timer_state)
if (t_timer_state ~= nil) then
if (type(t_timer_state)=="table") then
for k, v in pairs(t_timer_state) do
if ((type(v)=="table") and (v.enabled == 1)) then
return true, k, "1"
end
end
end
end
return false, "", "0"
end
function is_local( id)
id=tonumber(id) or 0
return id>=1 and id<=416
end
function is_network_device( id)
id=tonumber(id) or 0
return id>=20000
end
function is_outlet( n_funtion_bit_mask)
require "bit"
return bit.isset( tonumber(n_funtion_bit_mask), tonumber(9))
end
function has_energy_monitor( n_funtion_bit_mask)
require "bit"
return bit.isset( tonumber(n_funtion_bit_mask), tonumber(7))
end
function is_hkr( n_funtion_bit_mask)
require "bit"
return bit.isset( tonumber(n_funtion_bit_mask), tonumber(6))
end
function can_temperature( n_funtion_bit_mask)
require "bit"
return bit.isset( tonumber(n_funtion_bit_mask), tonumber(8))
end
function is_repeater_only( n_function_mask)
return ( tonumber( n_function_mask) == 1024)
end
function is_repeater( n_function_bit_mask)
return bit.isset( tonumber(n_function_bit_mask), tonumber(10))
end
function is_dect_repeater_enabled()
return (box.query("dect:settings/DECTRepeaterEnabled") == "1")
end
function is_unerasable_device( n_ule_id, valid)
if (( tonumber(n_ule_id) >= 900 and tonumber(n_ule_id) < 20000) or
( tonumber(n_ule_id) >= 20000 and (tostring(valid) ~= "1" and tostring(valid) ~= "0")) )then
return true
end
return false
end
function group_switched_by_master( n_ule_id)
if ((tonumber(n_ule_id) ~= nil) and (tonumber(n_ule_id) >= 900) and (tonumber(n_ule_id) < 1000)) then
require("libaha")
l_group = aha.GetGroup( tonumber( n_ule_id))
if ( l_group ~= nil) then
return is_valid_uleid( l_group.MasterDeviceID)
end
end
return false
end
function is_virtual_group_device( n_device_type, n_function_mask)
return ( tonumber( n_device_type) == 11) and ( tonumber( n_function_mask) == 512)
end
function is_group_member( t_group_list, sz_device_hash)
if ( t_group_list ~= nil) and ( #t_group_list > 0) then
for i=1, #t_group_list do
if ( tostring( sz_device_hash) == tostring( t_group_list[i].GroupHash) ) then
return true, t_group_list[i].GroupName, t_group_list[i].GroupHash
end
end
end
return false, [[]], [[0]]
end
function is_group_member_of( sz_group_hash, sz_device_hash)
return ( tostring( sz_group_hash) == tostring( sz_device_hash))
end
function get_group_member_IDs_of( t_devicelist, sz_group_hash)
local l_t_retcode = {}
if ((t_devicelist ~= nil) and (#t_devicelist > 0 )) then
for i,device in ipairs( t_devicelist) do
if ( not( is_virtual_group_device( device.DeviceType, device.FunctionBitMask))) and
( tostring( device.GroupHash) == sz_group_hash) then
table.insert( l_t_retcode, { MemberID=tostring(device.ID), MemberName=tostring(device.Name)} )
end
end
end
return l_t_retcode
end
function get_leading_zero( n_value)
return date.get_leading_zero( n_value)
end
function update_oncal_by_group_member( own_id, t_group_member_list, oncal_device_IDs, b_append)
local l_sz_retcode = oncal_device_IDs
if ((t_group_member_list ~= nil) and (#t_group_member_list > 0)) then
for i=1, #t_group_member_list do
if ( tonumber(t_group_member_list[i].MemberID) ~= tonumber(own_id) ) then
local sz_to_find = tostring(t_group_member_list[i].MemberID)..[[;]]
if ( b_append == true) then
local nBegin = string.find( l_sz_retcode, sz_to_find)
if ( tostring(nBegin) == tostring(nil) ) then
l_sz_retcode = l_sz_retcode..tostring(t_group_member_list[i].MemberID)..[[;]]
end
else
l_sz_retcode = string.gsub( l_sz_retcode, sz_to_find, [[]])
end
end
end
end
return l_sz_retcode
end
function update_oncal_by_group_member_2( oncal_device_IDs, t_group_member_list)
local l_sz_retcode = oncal_device_IDs
if ((t_group_member_list ~= nil) and (#t_group_member_list > 0)) then
for i=1, #t_group_member_list do
if ( tonumber(t_group_member_list[i].IsMember) == true) then
l_sz_retcode = append_to_oncal_devices( t_group_member_list[i].ID, l_sz_retcode)
else
l_sz_retcode = remove_from_oncal_devices( t_group_member_list[i].ID, l_sz_retcode)
end
end
end
return l_sz_retcode
end
function convert_to_german( sz_date)
if ((sz_date == nil) or (sz_data == "")) then
return [[]],TXT([[{?797:584?}]])
end
require "string_op"
local t_date_time = string_op.split2table( sz_date,[[ ]], 0)
local t_date = string_op.split2table( t_date_time[1],[[-]], 0)
if ((t_date ~= nil) and ( #t_date == 3)) then
sz_new_date = t_date[3]..[[.]]..t_date[2]..[[.]]..t_date[1]
sz_new_date = sz_new_date..[[ ]]..tostring( t_date_time[2])
else
sz_new_date = tostring( t_date_time[1])..[[ ]]..tostring( t_date_time[2])
end
return [[ class="output" style="width: 200px;"]], tostring( sz_new_date)
end
function get_calendar_name( n_device_id)
require("libaha")
l_ret_code = ""
if ( n_device_id ~= nil) then
l_t_timer = aha.GetSwitchTimer( tonumber( n_device_id))
if ( l_t_timer ~= nil) then
l_ret_code = l_t_timer.Calname
end
end
return l_ret_code
end
function append_to_oncal_devices( n_device_id, sz_devices)
local l_ret_code = sz_devices
local sz_to_find = tostring(n_device_id)..[[;]]
local nBegin = string.find( sz_devices, sz_to_find)
if ( tostring(nBegin) == tostring(nil) ) then
l_ret_code = sz_devices..tonumber(device.ID)..[[;]]
end
end
function remove_from_oncal_devices( n_device_id, sz_devices)
local sz_to_find = tostring(n_device_id)..[[;]]
local l_retcode, n_how_many = string.gsub( sz_devices, sz_to_find, "")
return l_retcode
end
function get_standby_state( n_device_id)
require("libaha")
local l_standby_state = aha.GetSwitchStandbyOffRule( tonumber(n_device_id))
local l_power = 0
local l_seconds = 0
if ( l_standby_state ~= nil) then
local l_is_active = true
local l_power = l_standby_state.Power
local l_seconds = l_standby_state.Seconds
if ( l_power == 0 ) or (l_power == 65535 ) then
l_is_active = false
l_power = 0
else
l_power = l_power/100
end
if ( l_seconds == 0 ) or ( l_seconds == 65535 ) then
l_is_active = false
l_seconds = 0
end
return l_is_active, l_power, l_seconds
end
return false, l_power, l_seconds
end
function calendar_always_exist( sz_calendar)
require("general")
local l_retcode = false
local l_sz_devices = ""
local l_sz_node = tostring(box.query( [[oncal:settings/oncal/newid]]))
local l_szListQuery = [[oncal:settings/oncal/list(enabled,deviceid,calid,calname,verification_url,usercode,rtok,laststatus)]]
local l_t_oncal_list = general.listquery( l_szListQuery)
if ((l_t_oncal_list ~= nil) and (#l_t_oncal_list > 0)) then
for i=1, #l_t_oncal_list do
if ( tostring(l_t_oncal_list[i].calname) == tostring(sz_calendar) ) then
l_sz_node = tostring(l_t_oncal_list[i]._node)
l_sz_devices = tostring(l_t_oncal_list[i].deviceid)
l_retcode = true
break
end
end
end
return l_retcode, l_sz_node, l_sz_devices
end
function get_device_model( model_id, sub_model_id)
if ( model_id == "0x0006") then
return TXT([[{?797:266?}]])
elseif ( model_id == "0x0007" ) then
if ( sub_model_id == "0x0001") then
return TXT([[{?797:22?}]])
elseif ( sub_model_id == "0x0002" ) then
return TXT([[{?797:650?}]])
elseif ( sub_model_id == "0x0003" ) then
return TXT([[{?797:963?}]])
else
return TXT([[{?797:722?}]])
end
elseif ( model_id == "0x0100" ) then
return TXT([[{?797:56?}]])
else
return TXT([[{?797:58?}]])
end
end
function get_switch( szID)
require("libaha")
local l_switch = aha.GetSwitch( tonumber( szID))
if ( l_switch == nil) or ( (l_switch ~= nil) and ( (tostring(l_switch.Options) == "65535") or (tostring(l_switch.LEDState) == "65535") or (tostring(l_switch.SwitchLock) == "65535"))) then
if ( l_switch == nil) then
l_switch = {}
l_switch.Options = "2"
l_switch.LEDState = "2"
l_switch.SwitchLock = "0"
l_switch.SwitchOn = "0"
else
if ( tostring(l_switch.Options) == "65535") then
l_switch.Options = "2"
end
if ( tostring(l_switch.LEDState) == "65535") then
l_switch.LEDState = "2"
end
if ( tostring(l_switch.SwitchLock) == "65535") then
l_switch.SwitchLock = "0"
end
end
end
return l_switch
end
function get_countdown_rule( nID)
require("libaha")
if ( nID == nil) then
nID = 0
end
local l_countdown_rule = aha.GetSwitchCountdownRule( tonumber(nID))
if ( l_countdown_rule == nil) or
( (l_countdown_rule ~= nil) and ( (tonumber(l_countdown_rule.OnOff) == 65535))) then
if ( l_countdown_rule == nil) then
l_countdown_rule = {}
l_countdown_rule.OnOff = 0
l_countdown_rule.Seconds = 0
l_countdown_rule.ID = 0
else
if ( tonumber(l_countdown_rule.OnOff) == 65535) then
l_countdown_rule.OnOff = 0
if ( tonumber(l_countdown_rule.Seconds) == 65535) then
l_countdown_rule.Seconds = 0
end
end
end
end
return l_countdown_rule
end
function get_switch_state( szID)
require("libaha")
l_switch_state = get_switch( szID)
return tostring(l_switch_state.SwitchOn)
end
function value_as_float( n_value, n)
local l_sz_format = [[%.]]..tostring(n)..[[f]]
local l_sz_as_float = string.format( l_sz_format, tonumber(n_value))
l_sz_as_float = string.gsub( l_sz_as_float, [[%.]], [[,]])
return tostring(l_sz_as_float)
end
function get_connect_state( bConnect_state)
if ( bConnect_state == true) then
return [[/css/default/images/led_green.gif]], TXT([[{?797:667?}]]), [[]]
else
return [[/css/default/images/led_gray.gif]], TXT([[{?797:672?}]]), [[]]
end
end
function get_switch_state_image( bConnect_state)
if ( bConnect_state == true) then
return [[/css/default/images/led_green.gif]], TXT([[{?797:208?}]]), [[]]
else
return [[/css/default/images/led_gray.gif]], TXT([[{?797:356?}]]), [[]]
end
end
function get_clickable_image( node, nIdx, szValue, szLock)
local l_szRet = [[<a id="uiView_SwitchOnOff]]..tostring(node)..[[" ]]
local l_title_Lock = TXT([[]])
if ( tostring(szLock) == "7") then
l_szRet = l_szRet..[[ class="disableNode" ]]
l_title_Lock = TXT([[{?797:713?}]])
end
l_szRet = l_szRet..[[ href="javascript:OnClick_ImageSwitch(']]..tostring( node)..[[',']]..tostring( nIdx)..[[',']]..tostring( szLock)..[[')">]]
l_szRet = l_szRet..[[<img id="uiView_Img_]]..tostring(node)..[[" name="img_]]..tostring(node)..[["]]
local l_title_Value = TXT([[{?797:594?}]])
if ( tostring(szValue) == "1") then
l_szRet = l_szRet..[[ src="/css/default/images/icon_schalter_on.png"]]
l_title_Value = TXT([[{?797:497?}]])
else
l_szRet = l_szRet..[[ src="/css/default/images/icon_schalter_off.png"]]
end
l_szRet = l_szRet..[[ title="]]..tostring(l_title_Value)..tostring(l_title_Lock)..[["></a>]]
l_szRet = l_szRet..elem._input( "hidden", "image_switch_"..node, "uiView_ImageSwitch_"..node, szValue, "3", "3")
return l_szRet
end
function get_clickable_image_mobile( node, nIdx, szValueOnOff, szLock)
local l_szRet = [[<a id="uiView_SwitchOnOff]]..tostring(node)..[[" ]]
if ( szLock == "7") then
l_szRet = l_szRet..[[ class="disableNode" ]]
end
l_szRet = l_szRet..[[ href="javascript:OnClick_ImageSwitch(']]..tostring( node)..[[',']]..tostring( nIdx)..[[')" >]]
l_szRet = l_szRet..[[<img id="uiView_Img_]]..tostring(node)..[[" name="img_]]..tostring(node)..[["]]
if ( szValueOnOff == "1") then
l_szRet = l_szRet..[[ src="/css/default/images/buttons_ein.png"]]
else
l_szRet = l_szRet..[[ src="/css/default/images/buttons_aus.png"]]
end
l_szRet = l_szRet..[[ ></a>]]
l_szRet = l_szRet..elem._input( "hidden", "image_switch_"..node, "uiView_ImageSwitch_"..node, szValue, "3", "3")
return l_szRet
end
function get_minute_quarter_string( n_mins)
if ( n_mins < 15) then
return {[[:15]],[[:30]],[[:45]],[[:00]]}
elseif ( n_mins < 30) then
return {[[:30]],[[:45]],[[:00]],[[:15]]}
elseif ( n_mins < 45) then
return {[[:45]],[[:00]],[[:15]],[[:30]]}
end
return {[[:00]],[[:15]],[[:30]],[[:45]]}
end
function get_month_count_of( n_month)
if ( n_month == 2) then
return 28
elseif ( n_month == 4) or ( n_month == 6) or ( n_month == 9) or ( n_month == 11) then
return 30
else
return 31
end
end
function get_current_date( n_time)
if ( n_time ~= nil) then
local l_null_time = os.time{year=2010, month=1, day=1, hour=0, min=0}
n_time = n_time + l_null_time
return os.date( "*t", n_time)
else
return os.date("*t")
end
end
function get_id_of_existing_group( t_group_list, group_name)
if ((t_group_list ~= nil) and (#t_group_list > 0 )) then
for i,group_member in ipairs( t_group_list) do
if ( tostring(group_member.GroupName) == tostring(group_name)) then
return group_member.MemberID
end
end
end
return 0
end
function initialize_group_name_list( t_devicelist, bPlusNoActive)
local l_t_retcode = {}
if ((t_devicelist ~= nil) and (#t_devicelist > 0 )) then
if ( bPlusNoActive == true) then
l_t_retcode = { { [[0]], TXT([[{?797:196?}]]) }}
end
for i,device in ipairs( t_devicelist) do
if ( is_virtual_group_device( device.DeviceType, device.FunctionBitMask)) then
if ( bPlusNoActive == true) then
table.insert( l_t_retcode, { tostring(device.Name), tostring(device.Name)} )
else
local l_group_member_count, l_another_id = get_group_member_count_of( t_devicelist, device.GroupHash)
table.insert( l_t_retcode, { GroupHash=tostring(device.GroupHash), GroupName=tostring(device.Name), ID=tonumber(device.ID), MemberID=tonumber(l_another_id), GroupCount=tonumber(l_group_member_count) })
end
end
end
end
return l_t_retcode
end
function get_groupname_by_hash( sz_device_hash)
require("libaha")
local l_groupname_list = initialize_group_name_list( aha.GetDeviceList(), false)
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if ( tostring(group.GroupHash) == tostring(sz_device_hash) ) then
return group.GroupName
end
end
end
return [[0]]
end
function get_groupname_by_hash_2( sz_device_hash)
require("libaha")
local l_groupname_list = aha.GetGroupList()
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if ( tostring(group.GroupHash) == tostring(sz_device_hash) ) then
return group.GroupName
end
end
end
return [[0]]
end
function get_group_id_by_name( sz_group_name)
require("libaha")
local l_groupname_list = aha.GetGroupList()
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if ( tostring(group.Name) == tostring(sz_group_name) ) then
return group.ID --, group.GroupHash
end
end
end
return 0, 0
end
function group_name_always_exists( sz_group_name)
require("libaha")
local l_groupname_list = aha.GetGroupList()
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if ( tostring(group.Name) == tostring(sz_group_name) ) then
return true
end
end
end
return false
end
function get_virtual_id_by_hash( sz_device_hash)
require("libaha")
local l_groupname_list = aha.GetGroupList()
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if ( tostring(group.GroupHash) == tostring(sz_device_hash)) then
return group.ID
end
end
end
return nil
end
function get_another_group_member( sz_device_hash)
require("libaha")
local l_groupname_list = aha.GetGroupList()
if ( (l_groupname_list ~= nil) and (#l_groupname_list > 0)) then
for i,group in ipairs( l_groupname_list) do
if (( not(is_virtual_group_device( device.DeviceType, device.FunctionBitMask))) and
( tostring(device.GroupHash) == tostring(sz_device_hash)) ) then
return group.ID
end
end
end
return [[]]
end
function get_group_member_count_of( t_device_list, sz_device_hash)
local l_ret_code_count = 0
local l_ret_code_id = 0
if ( (t_device_list ~= nil) and (#t_device_list > 0)) then
for i,device in ipairs( t_device_list) do
if (( not(is_virtual_group_device( device.DeviceType, device.FunctionBitMask))) and
( tostring(device.GroupHash) == tostring(sz_device_hash)) ) then
l_ret_code_count = l_ret_code_count + 1
l_ret_code_id = device.ID
end
end
end
return l_ret_code_count, l_ret_code_id
end
function get_time_as_min_of( n_year, n_month, n_day, n_hour, n_min)
local l_start_time = os.time{year=2010, month=1, day=1, hour=0, min=0}
local l_end_time = 0
if ( n_year ~= nil and n_month ~= nil and n_day ~= nil and n_hour ~= nil and n_min ~= nil) then
l_end_time = os.time{year=n_year, month=n_month, day=n_day, hour=n_hour, min=n_min}
else
l_end_time = os.time()
end
return tonumber( math.floor((os.difftime( l_end_time, l_start_time))/60))
end
function get_device_counts( t_devicelist)
local n_all_devices = 0
local n_all_switch_devices = 0
local n_all_connected_switch_devices = 0
if ( t_devicelist ~= nil) then
for i,device in ipairs( t_devicelist) do
--nur existierende Geräte zählen, keine virtuellen "Gruppengeräte" (DeviceType==11)
if ( ( device ~= nil) and (tonumber(device.DeviceType) ~= 11) ) then
n_all_devices = n_all_devices + 1
if ( not( is_repeater_only( device.FunctionBitMask)) ) then
n_all_switch_devices = n_all_switch_devices + 1
if ( tostring( device.Valid) == "2") then
n_all_connected_switch_devices = n_all_connected_switch_devices + 1
end
end
end
end
end
return n_all_devices, n_all_switch_devices, n_all_connected_switch_devices
end
function get_device_tab_head( device_id, b_show_fw, b_input)
if nil == device_id or nil == tonumber( device_id ) then
return
end
local l_device = aha.GetDevice(tonumber(device_id))
local l_str = [[<h4>]]..TXT([[{?797:44?}]])..[[</h4>]]
l_str = l_str..[[<div class="formular widetext">]]
l_str = l_str..elem._label( "uiULEDeviceUleID", "LabeluiULEDeviceUleID", TXT([[{?797:108?}]]), nil,[[ha_tab_head]])
l_str = l_str..[[<span class="output"><nobr>]]..get_device_model( tostring(l_device.Model), tostring(l_device.SubModel))..[[</nobr></span>]]
l_str = l_str..[[</div>]]
l_str = l_str..[[<div class="formular widetext">]]
l_str = l_str..elem._label( "uiULEDeviceUleID", "LabeluiULEDeviceUleID", TXT([[{?797:982?}]]), nil,[[ha_tab_head]])
l_str = l_str..[[<span class="output"><nobr>]]..l_device.Identifyer..[[</nobr></span>]]
l_str = l_str..[[</div>]]
if ( b_show_fw) then
l_str = l_str..[[<div class="formular widetext">]]
l_str = l_str..elem._label( "uiULEDeviceUleID", "LabeluiULEDeviceUleID", TXT([[{?797:853?}]]), nil,[[ha_tab_head]])
l_str = l_str..[[<span class="output"><nobr>]]..l_device.FWVersion..[[</nobr></span>]]
l_str = l_str..[[</div>]]
end
l_str = l_str..[[<div class="formular widetext" id="uiShow_Description">]]
l_str = l_str..elem._label( "uiULEDeviceName", "LabeluiULEDeviceName", TXT([[{?797:718?}]]), nil,[[ha_tab_head]])
if ( b_input) then
l_str = l_str..elem._input( "text", "ule_device_name", "uiULEDeviceName", l_device.Name, "39", "35", [[]])
else
l_str = l_str..[[<span class="output"><nobr>]]..box.tohtml(l_device.Name)..[[</nobr></span>]]
end
l_str = l_str..[[</div>]]
l_str = l_str..[[<div class="formular widetext" id="uiShow_Connection">]]
l_str = l_str..elem._label( "uiULEDeviceConnectState", "LabeluiULEDeviceConnectState", TXT([[{?797:188?}]]), nil,[[ha_tab_head]])
szImageSource, szTitelText, szAltText = get_connect_state( (tostring(l_device.Valid) == "2"))
l_str = l_str..elem._image( "uiDeviceConnectState_"..tostring(l_device.ID), szImageSource, szTitelText, szAltText, [[vertical-align: middle;]],true)
l_str = l_str..[[<span id="uiDeviceConnectStateText_"]]..tostring(l_device.ID)..[[ style="padding: 0px 100px 0px 5px;vertical-align: middle;">]]..szTitelText..[[</span>]]
if is_outlet( l_device.FunctionBitMask) then
local l_SwitchState = get_switch_state( l_device.ID)
l_str = l_str..[[<span style="padding-right: 20px;vertical-align: middle;">]]..TXT([[{?797:996?}]])..[[</span>]]
szImageSource, szTitelText, szAltText = get_switch_state_image( (tostring(l_SwitchState) == "1"))
l_str = l_str..elem._image( "uiDeviceSwitchState_"..tostring(l_device.ID), szImageSource, szTitelText, szAltText, [[vertical-align: middle;]],true)
l_str = l_str..[[<span id="uiDeviceSwitchStateText_]]..tostring(l_device.ID)..[[" style="padding-left: 5px;vertical-align: middle;">]]..string.lower(szTitelText)..[[</span>]]
end
l_str = l_str..[[</div>]]
box.out( l_str)
end
