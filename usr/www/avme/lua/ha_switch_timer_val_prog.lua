if newval.radio_check("switch_on_timer","weekly") then
end
if newval.radio_check("switch_on_timer","daily") then
if newval.checked("switch_on_action_daily") then
newval.num_range_integer("daily_from_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("daily_from_mm", 0, 59,"num_range_min")
newval.is_valid_time("daily_from_hh","daily_from_mm","is_valid_time_msg")
end
if newval.checked("switch_off_action_daily") then
newval.num_range_integer("daily_to_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("daily_to_mm", 0, 59,"num_range_min")
newval.is_valid_time("daily_to_hh","daily_to_mm","is_valid_time_msg")
end
if newval.checked("switch_on_action_daily") and newval.checked("switch_off_action_daily") then
newval.time_not_equal("daily_from_hh", "daily_from_mm", "daily_to_hh", "daily_to_mm", "daily_times_are_equal")
end
newval.least_one_checked("switch_on_action_daily","switch_off_action_daily","least_one_check_daily_msg")
end
if newval.radio_check("switch_on_timer","zufall") then
newval.is_num_in("zufall_from_date_day","is_num_in_day")
newval.is_num_in("zufall_from_date_month","is_num_in_month")
newval.is_num_in("zufall_from_date_year","is_num_in_year")
newval.is_num_in("zufall_to_date_day","is_num_in_day")
newval.is_num_in("zufall_to_date_month","is_num_in_month")
newval.is_num_in("zufall_to_date_year","is_num_in_year")
newval.is_valid_date("zufall_from_date_day","zufall_from_date_month","zufall_from_date_year","is_valid_date_msg")
newval.is_valid_date("zufall_to_date_day","zufall_to_date_month","zufall_to_date_year","is_valid_date_msg")
newval.num_range_integer("zufall_from_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("zufall_from_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("zufall_from_time_hh","zufall_from_time_mm","is_valid_time_msg")
newval.num_range_integer("zufall_to_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("zufall_to_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("zufall_to_time_hh","zufall_to_time_mm","is_valid_time_msg")
newval.value_unallowable("zufall_duration_switch",0,"select_not_set")
newval.time_not_equal("zufall_from_time_hh", "zufall_from_time_mm", "zufall_to_time_hh", "zufall_to_time_mm", true, "random_times_are_equal")
end
if newval.radio_check("switch_on_timer","countdown") then
if newval.radio_check("countdown_manuell_on","1") then
newval.num_range_integer("countdown_time_dd_on", 0, 999, "num_range_count_hour")
newval.num_range_integer("countdown_time_mm_on", 0, 59, "num_range_count_min")
newval.is_valid_countdown_time("countdown_time_dd_on","countdown_time_mm_on","is_valid_countdown_time_msg")
end
if newval.radio_check("countdown_manuell_on","0") then
newval.num_range_integer("countdown_time_dd_off", 0, 999,"num_range_count_hour")
newval.num_range_integer("countdown_time_mm_off", 0, 59,"num_range_count_min")
newval.is_valid_countdown_time("countdown_time_dd_off","countdown_time_mm_off","is_valid_countdown_time_msg")
end
end
if newval.radio_check("switch_on_timer","rythmisch") then
newval.value_unallowable("rythmisch_switch_state_on",0,"select_not_set")
newval.value_unallowable("rythmisch_switch_state_off",0,"select_not_set")
end
if newval.radio_check("switch_on_timer","single") then
newval.is_num_in("single_date_day","is_num_in_day")
newval.is_num_in("single_date_month","is_num_in_month")
newval.is_num_in("single_date_year","is_num_in_year")
newval.is_valid_date("single_date_day","single_date_month","single_date_year","is_valid_date_msg")
newval.num_range_integer("single_time_hh", 0, 24,"num_range_hour_24")
newval.num_range_integer("single_time_mm", 0, 59,"num_range_min")
newval.is_valid_time("single_time_hh","single_time_mm","is_valid_time_msg")
newval.value_unallowable("single_switch_duration",0,"select_not_set")
end
if newval.radio_check("switch_on_timer","sun_calendar") then
newval.is_valid_float_degree("sun_latitude_degree",4,90,"lati_90")
newval.is_valid_float_degree("sun_longitude_degree",4,180,"longi_180")
if newval.checked("sun_checkbox_sunrise") then
newval.value_unallowable("sunrise_duration","u#0","select_not_astro")
end
if newval.checked("sun_checkbox_sunset") then
newval.value_unallowable("sunset_duration","u#0","select_not_astro")
end
newval.least_one_checked("sun_checkbox_sunrise","sun_checkbox_sunset","least_one_check_msg_2")
end
if newval.radio_check("switch_on_timer","calendar") then
newval.not_empty("calendar_google_calendarname","calender_empty")
end
