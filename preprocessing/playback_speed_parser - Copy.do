clear all


local files " Education_EDUC115-S_Spring2014 Engineering_Compilers_Fall2014 Engineering_IntroChE_SelfStudy Engineering_QMSE-02_Winter2015 Engineering_QMSE01._Autumn2015 Education_OpenKnowledge_Fall2014 English_DiggingDeeper1_Winter2015 English_diggingdeeper2_Spring2015 Medicine_MolFoundations_SelfPaced EarthSciences_ResGeo202_Spring2015 GlobalHealth_IntWomensHealth_Jan2015 HumanitiesSciences_Econ-1_Summer2014 HumanitiesSciences_Econ_1_Summer2015 HumanitiesSciences_EP-101_Spring2015 GlobalHealth_INT.WomensHealth_July2015 HumanitiesandScience_StatLearning_Winter2015 Education_115SP_2015 SelfPaced_Haptics_2014 GSB_StocksBonds_SelfPaced Medicine_ANES204_Fall2014 Medicine_ANES205_Fall2014 Engineering_Nano_Summer2014 Medicine_Sci-Write_Fall2014 Medicine_SciWrite._Fall2015 Engineering_CS101_Summer2014 Engineering_QMSE-01_Fall2014 Medicine_MedStats_Summer2014 GlobalHealth_IWHHR_Summer2014 Medicine_MedStats._Summer2015 "
*local files " Education_EDUC115-S_Spring2014 "
*local files "Education_115SP_2015_VideoEvents.csv" // SelfPaced_Haptics_2014_VideoEvents.csv GSB_StocksBonds_SelfPaced_VideoEvents.csv Medicine_ANES204_Fall2014_VideoEvents.csv Medicine_ANES205_Fall2014_VideoEvents.csv Engineering_Nano_Summer2014_VideoEvents.csv Medicine_Sci-Write_Fall2014_VideoEvents.csv Medicine_SciWrite._Fall2015_VideoEvents.csv Engineering_CS101_Summer2014_VideoEvents.csv Engineering_QMSE-01_Fall2014_VideoEvents.csv Medicine_MedStats_Summer2014_VideoEvents.csv GlobalHealth_IWHHR_Summer2014_VideoEvents.csv Medicine_MedStats._Summer2015_VideoEvents.csv Education_EDUC115-S_Spring2014_VideoEvents.csv Engineering_Compilers_Fall2014_VideoEvents.csv Engineering_IntroChE_SelfStudy_VideoEvents.csv Engineering_QMSE-02_Winter2015_VideoEvents.csv Engineering_QMSE01._Autumn2015_VideoEvents.csv Education_OpenKnowledge_Fall2014_VideoEvents.csv English_DiggingDeeper1_Winter2015_VideoEvents.csv English_diggingdeeper2_Spring2015_VideoEvents.csv Medicine_MolFoundations_SelfPaced_VideoEvents.csv EarthSciences_ResGeo202_Spring2015_VideoEvents.csv GlobalHealth_IntWomensHealth_Jan2015_VideoEvents.csv HumanitiesSciences_Econ-1_Summer2014_VideoEvents.csv HumanitiesSciences_Econ_1_Summer2015_VideoEvents.csv HumanitiesSciences_EP-101_Spring2015_VideoEvents.csv GlobalHealth_INT.WomensHealth_July2015_VideoEvents.csv HumanitiesandScience_StatLearning_Winter2015_VideoEvents.csv"
cd "C:\Users\DavidsSurface4\Dropbox\MS&E231\Final_Project\RAW-DATA\datastage.stanford.edu\researcher\EDUC_353A\exports_5-12\raws"


foreach file of local files{
di "`file'"
import delimited "`file'_VideoEvents.csv" , clear // rowrange(1:100000)

*keep if mod(_n,20)==0

drop resource  video_id video_speed
destring video*time,replace force
destring video*speed*,replace force
capture tabout video_old_speed video_new_speed  using speed_transition_matrix.txt, cells(cell) replace
bysort anon_screen_name  video_codec: gen video_loads_temp=_N if event_type=="load_video"
bysort anon_screen_name  video_codec: egen video_loads=max(video_loads_temp)


drop if inlist(event_type,"edx.forum.searched","load_video")
gen day=substr(time,1,10)
gen date=date(day,"YMD")
gen pauses_per_video=event_type=="pause_video"
gen seeks_back=video_new_time<video_old_time if event_type=="seek_video" 
gen seeks_forward=video_new_time>video_old_time if event_type=="seek_video" 

gen seeks_back_time=video_new_time-video_old_time if seeks_back 
gen seeks_forward_time=video_new_time-video_old_time if seeks_forward 

bysort anon_screen: egen min_date=min(date)
bysort anon_screen: egen max_date=max(date)

bysort anon_screen video_codec: egen min_date_video=min(date)
bysort anon_screen video_codec: egen max_date_video=max(date)

bysort anon_screen video_codec: egen mode_new_speed=mode(video_new_speed)
bysort anon_screen video_codec: egen mode_old_speed=mode(video_old_speed)
sort anon_screen_name time
by anon_screen_name: carryforward video_new_speed, gen(video_impute_alt)
replace video_impute_alt=1 if video_impute_alt==.


gen days_in_course=max_date-min_date
tab video_new_speed, gen(new_speed)
destring video_current_time, force replace
destring video_old_time video_new_time, replace force
bysort video_codec: egen video_end_time=max(video_new_time) 
by video_codec: egen video_mode_time=mode(video_current_time) if event_type=="stop_video"
by video_codec: egen video_mean_time=mean(video_current_time) if event_type=="stop_video"

destring mode*, replace
destring video_old*,replace
collapse (mean) video_loads video_new_speed video_old_speed video_impute_alt pauses_per_video  mode_old_speed mode_new_speed  days_in_course seeks_back seeks_forward seeks_back_time seeks_forward_time (max) max_date_video video_current_time video_old_time video_new_time video_end_time  (min) min_date min_date_video (sum) sum_pauses=pauses_per_video sum_seeks_back=seeks_back sum_seeks_bt=seeks_back_time  ,by(anon_screen   video_codec)
by  anon_screen: gen video_ints=_N
by  anon_screen: gen speed_ints=_N if video_new_speed!=.
sort video_codec
egen videos_total=group(video_codec)
egen temp=max(videos_total)
replace videos_total=temp
drop temp
gen video_share= video_ints/videos_total 

destring mode*, replace

gen finished_90=(video_current_time>=.9*video_end_time & video_current_time!=.)|(video_old_time>=.9*video_end_time & video_old_time!=.)
gen days_in_course_video_alt=max_date_video -min_date_video
gen video_impute_speed=video_new_speed
replace video_impute_speed=1 if video_new_speed==.

encode video_codec, gen(video_code)

gen days_in_course_video=log(max_date_video -min_date +1)

replace seeks_back=0 if seeks_back ==.
replace seeks_forward=0 if seeks_forward ==.

/*gen pass_notification= min_date_video >passdate
gen highpass_notification= min_date_video >highpassdate
gen progress_pass=min_date_video>=progress_check_pass */

sort anon_screen_name  min_date_video
*egen speed_change=rowtotal(new_speed1 new_speed2 new_speed3 new_speed4 -new_speed6)
*replace speed_change= speed_change>0
*egen tag=tag(speed_change anon_screen_name ) if speed_change ==1
gen log_days=(days_in_course_video)
*hist tag
*gen day_of_speed_change=days_in_course_video if speed_change ==1
*label var day_of_speed_change "Day of Speed Change"
*cdfplot  day_of_speed_change if tag, title(Time of First Speed Change) xscale(log)
*binscatter fast_alt log_days,reportreg linetype(lfit) title(Proportion of Users Going Faster Than 1x) absorb(person_code)
*areg video_new_speed  ln_video_days  i.video_id , absorb(anon_screen_name)
*binscatter ln_video_days video_impute_speed ,absorb(anon_screen_name)
/*
replace new_speed1=1 if video_impute_speed==.5| new_speed1>0
replace new_speed2=1 if video_impute_speed==.75| new_speed2>0
replace new_speed3=1 if video_impute_speed==.75| new_speed2>0
gen slow= new_speed1|new_speed2

replace new_speed4=1 if video_impute_speed==1.25| new_speed4>0
replace new_speed5=1 if video_impute_speed==1.5| new_speed5>0
replace new_speed6=1 if video_impute_speed==2| new_speed6>0
egen speed_toggle=rowmax(new_speed1-new_speed6)
gen fast= new_speed4|new_speed5|new_speed6
*/
gen fast_alt=video_impute_alt>1
gen slow_alt=video_impute_alt<1

*label var pass "Pass Notification"
label var video_impute_alt "Playback Speed"

label var pauses_per_video "Paused Video %" 
label var seeks_back  "Rewind %" 
label var seeks_forward  "Fast Forward %"
label var days_in_course "Days in Course"
label var finished_90 "Videos Completed"

egen video_tag=tag(video_codec)
egen total_length= sum(video_end_time) if video_tag
egen total_video_length_final=max(total_length)
egen average_length= mean(video_end_time) if video_tag
egen average_video_length= mean(video_end_time) if video_tag


collapse (mean) video_loads video_impute_alt pauses_per_video seeks_back seeks_forward  finished_90 fast_alt slow_alt (max) days_in_course video_ints videos_total video_share total_video_length_final average_video_length (min) min_date  , by(anon_screen_name)
gen course_id=lower("`file'")
*export delimited using "C:\Users\DavidsSurface4\Dropbox\MS&E231\Final_Project\transformed_data\\`file'_VideoEvents.csv", replace

export delimited using "C:\Users\DavidsSurface4\Dropbox\MOOCs\Stata\data\\`file'playback_collapsed.csv",replace
gen course_name="`file'"
save "C:\Users\DavidsSurface4\Dropbox\MOOCs\Stata\data\\`file'playback_collapsed.dta",replace
}

