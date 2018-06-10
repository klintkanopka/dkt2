
clear all
*import delimited C:\Users\DavidsSurface4\Dropbox\CS230\items_type_5_22.csv, clear 
*save  C:\Users\DavidsSurface4\Dropbox\CS230\items_type_5_22.dta, replace

import delimited C:\Users\DavidsSurface4\Dropbox\CS230\Item_Codec_Quiz_mapv2.csv, clear
save  C:\Users\DavidsSurface4\Dropbox\CS230\items_type_5_22.dta, replace 
use "C:\Users\DavidsSurface4\Dropbox\CS230\last_grade_long.dta" 
ren learner  anon_screen_name
tab item
replace item=item-1
gen correct=v=="correct" 
gen attempt=v!="NA"
gen max_item=item if attempt==1
bysort anon_screen_name: egen last_attempted=max(max_item)
joinby item using "C:\Users\DavidsSurface4\Dropbox\CS230\items_type_5_22.dta", unmatched(none)
ren codec video_codec

joinby video_codec anon_screen_name using "C:\Users\DavidsSurface4\Dropbox\CS230\all_video_playback_speeds.dta", unmatched(both) _merge(_merge)
bysort anon_screen_name: egen max_merge=max(_merge)
replace _merge=max_merge
replace seeks_back=0 if seeks_back==.
replace seeks_forward=0 if seeks_forward==.
replace video_impute_alt=0 if video_impute_alt==.
replace finished_90=0 if finished_90==.
replace pauses_per_video=0 if pauses_per_video==.
foreach var in seeks_back seeks_forward video_impute_alt finished_90 pauses_per_video{
bysort anon_screen_name chapterquiz: egen q`var'=mean(`var') 
replace `var' =q`var' if quiz==1
}
keep anon_screen_name item correct attempt video_impute_alt pauses_per_video  seeks_back  seeks_forward  finished_90 quiz max_merge last_attempted
save "C:\Users\DavidsSurface4\Dropbox\CS230\5_22_long_data.dta" ,replace

use  "C:\Users\DavidsSurface4\Dropbox\CS230\5_22_long_data.dta" ,clear 
egen rowmiss=rowmiss(item correct attempt video_impute_alt pauses_per_video seeks_back seeks_forward finished_90 quiz)
*drop if rowmiss
gen index=item
//replace index=. if attempt!=1
keep anon_screen_name item index max_merge last_attempted
drop if item==.
reshape wide index ,i(anon_screen_name max_merge last_attempted) j(item)
local i=1
/*
foreach var in index1 index2 index3 index4 index5 index6 index7 index8 index13 index14 index15 index16 index17 index18 index19 index20 index21 index22 index24 index25 index26 index27 index28 index29 index30 index31 index32 index33 index34 index36 index37 index38 index39 index40 index41 index42 index43 index44 index45 index48 index49 index50 index51 index52 index53 index54 index55 index56 index57 index58 index59 index60 index61 index67 index68 index69 index70 index71 index72 index73 index75 index76 index77 index78 index79 index80 index81 index82 index86 index87 index88 index89 index90 index91 index92 index93 index95 index96 index97 index98 index99 index100 index101 index102{
replace `var'=`i' if `var'==.
local i=`i'+1
}*/
gen feature="item_order"
order anon_screen feature
save C:\Users\DavidsSurface4\Dropbox\CS230\rows_items.dta,replace

foreach var in correct video_impute_alt pauses_per_video seeks_back seeks_forward finished_90 attempt quiz{
use  "C:\Users\DavidsSurface4\Dropbox\CS230\5_22_long_data.dta" ,clear 
drop if item==.
gen index=`var'
keep anon_screen_name item index max_merge last_attempted

reshape wide index ,i(anon_screen_name max_merge last_attempted) j(item)
gen feature="`var'"
save C:\Users\DavidsSurface4\Dropbox\CS230\rows_`var'.dta, replace
}

use  "C:\Users\DavidsSurface4\Dropbox\CS230\rows_items.dta" ,clear 
foreach var in correct video_impute_alt pauses_per_video seeks_back seeks_forward finished_90 attempt quiz{
append using "C:\Users\DavidsSurface4\Dropbox\CS230\rows_`var'.dta"
}

replace feature="1.item_order" if feature=="item_order"
replace feature="2.correct" if feature=="correct"
replace feature="3.playback_speed" if feature=="video_impute_alt"
replace feature="4.pauses" if feature=="pauses_per_video"
replace feature="5.seeks_back" if feature=="seeks_back"
replace feature="6.seeks_forward" if feature=="seeks_forward"
replace feature="7.video_completed" if feature=="finished_90"
replace feature="8.attempt" if feature=="attempt"
replace feature="9.quiz" if feature=="quiz"

sort anon_screen_name  feature
order anon_screen_name feature
encode anon_screen_name , gen(id)
encode feature, gen(feat)
tsset id feat
/*
forvalues i=1/103{
gen attempt=index`i'==1 if feat==8
bysort anon_screen:egen max_attempt=max(attempt)
replace index`i'=. if max_attempt==0
drop attempt max_attempt
}
*/
replace index1=last_attempt if feat==1
forvalues i=2/103{
replace index`i'=. if feat==1
}

drop last_attempt
egen user_tag=tag(anon_screen_name)
set seed 1
gen rand=runiform() if user_tag
gen train=inrange(rand,0,.8)
gen dev=inrange(rand,.8,.9)
gen test=inrange(rand,.9,1)
bysort anon_screen_name: egen max_train=max(train)
bysort anon_screen_name: egen max_dev=max(dev)
bysort anon_screen_name: egen max_test=max(test)
drop id 
drop feat
preserve 
drop max_merge
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_train80_all.csv" if max_train, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_dev10_all.csv" if max_dev, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_test10_all.csv" if max_test, replace

keep if inlist(feature,"1.item_order","2.correct","8.attempt")

export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_train80_allbaseline.csv" if max_train, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_dev10_allbaseline.csv" if max_dev, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_test10_allbaseline.csv" if max_test, replace

?
//export delimited using "C:\Users\DavidsSurface4\Dropbox\CS230\5_26_tuples.txt", replace
restore
keep if max_merge==3
drop max_merge

export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_train_active.csv" if max_train, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_dev_active.csv" if max_dev, replace
export delimited anon_screen_name-index103 using "C:\Users\DavidsSurface4\Dropbox\CS230\5_27_tuples_test_active.csv" if max_test, replace


reshape long index   , i(anon_screen_name feature)
capture graph drop *
binscatter index item if feature=="2.correct",  ytitle(Correct) xtitle(Item Index) linetype(connect) nquantile(25) title(Proportion of Items Correct) rd(24 30  48 54 88 94) name(pvalues)
graph export pvalues, as(jpg)
