//-----------------------------------------------------------------------
//Explanations
//-----------------------------------------------------------------------

*this syntax was written for application of the ACES Framework to SHIP-TREND data (see PMID 25496455 for desciption of SHIP-TREND)
*SHIP-TREND Methods: a halfmouth protocol with 4 sites (mesiobuccal, buccal, distobuccal, midlingual/midpalatinal) per tooth was performed
*PD and CAL were measured; BOP was measured at tooth positions 1-4,6,7 (excluding tooth position 5) at identical sites (mb-b-db-ml/mp)
*Adaption of the ACES framework to SHIP-TREND was done according to Holtfreter et al. 2024 (JCPE); according to flowcharts for completed surveys
*this file includes Stata syntax for application of the gingivitis and peridontitis schemes according to the ACES Framework; including syntax for Staging, Extent, Grading
*syntax to evaluate treatment success according to Sanz et al. (2020) is additionally provided
*the syntax has been kept simple so that the reader understands what has been done 

//-----------------------------------------------------------------------
//Preparation of SHIP-TREND-0 data
//-----------------------------------------------------------------------
 
/////////////set directory and read data
cd "XXX"
use "XXX.dta",clear

//////////////////Number of teeth, halfmouth, excluding third molars
egen t0_teeth14_Q14=anycount(dex_prosthes_zb11 dex_prosthes_zb12 dex_prosthes_zb13 dex_prosthes_zb14 dex_prosthes_zb15 dex_prosthes_zb16 dex_prosthes_zb17 dex_prosthes_zb41 dex_prosthes_zb42 dex_prosthes_zb43 dex_prosthes_zb44 dex_prosthes_zb45 dex_prosthes_zb46 dex_prosthes_zb47), values(0,2,4,5,6,10,12,81,98,99)
replace t0_teeth14_Q14=. if inlist(dex_prosthes_zb11,.o,.p,.u,.y,.z)

egen t0_teeth14_Q23=anycount(dex_prosthes_zb21 dex_prosthes_zb22 dex_prosthes_zb23 dex_prosthes_zb24 dex_prosthes_zb25 dex_prosthes_zb26 dex_prosthes_zb27 dex_prosthes_zb31 dex_prosthes_zb32 dex_prosthes_zb33 dex_prosthes_zb34 dex_prosthes_zb35 dex_prosthes_zb36 dex_prosthes_zb37), values(0,2,4,5,6,10,12,81,98,99)
replace t0_teeth14_Q23=. if inlist(dex_prosthes_zb21,.o,.p,.u,.y,.z)

label var t0_teeth14_Q14 "T0: Number of teeth, halfmouth, Q14"
label var t0_teeth14_Q23 "T0: Number of teeth, halfmouth, Q23"

gen t0_teeth14=t0_teeth14_Q14 if dex_oralbase_quadrant==1
replace t0_teeth14=t0_teeth14_Q23 if dex_oralbase_quadrant==2
label var t0_teeth14 "T0: Number of teeth, halfmouth, Q14 or Q23 (same as for periodontal exam)"

gen t0_mteeth14=14-t0_teeth14
label var t0_mteeth14 "T0: Number of missing teeth, halfmouth, Q14 or Q23 (same as for periodontal exam)"

/////////////////Number of teeth, fullmouth, excluding third molars
egen t0_teeth28=anycount(dex_prosthes_zb11 dex_prosthes_zb12 dex_prosthes_zb13 dex_prosthes_zb14 dex_prosthes_zb15 dex_prosthes_zb16 dex_prosthes_zb17 dex_prosthes_zb41 dex_prosthes_zb42 dex_prosthes_zb43 dex_prosthes_zb44 dex_prosthes_zb45 dex_prosthes_zb46 dex_prosthes_zb47 dex_prosthes_zb21 dex_prosthes_zb22 dex_prosthes_zb23 dex_prosthes_zb24 dex_prosthes_zb25 dex_prosthes_zb26 dex_prosthes_zb27 dex_prosthes_zb31 dex_prosthes_zb32 dex_prosthes_zb33 dex_prosthes_zb34 dex_prosthes_zb35 dex_prosthes_zb36 dex_prosthes_zb37), values(0,2,4,5,6,10,12,81,98,99)
egen t0_teeth32=anycount(dex_prosthes_zb11 dex_prosthes_zb12 dex_prosthes_zb13 dex_prosthes_zb14 dex_prosthes_zb15 dex_prosthes_zb16 dex_prosthes_zb18 dex_prosthes_zb41 dex_prosthes_zb42 dex_prosthes_zb43 dex_prosthes_zb44 dex_prosthes_zb45 dex_prosthes_zb46 dex_prosthes_zb48 dex_prosthes_zb21 dex_prosthes_zb22 dex_prosthes_zb23 dex_prosthes_zb24 dex_prosthes_zb25 dex_prosthes_zb26 dex_prosthes_zb28 dex_prosthes_zb31 dex_prosthes_zb32 dex_prosthes_zb33 dex_prosthes_zb34 dex_prosthes_zb35 dex_prosthes_zb36 dex_prosthes_zb38), values(0,2,4,5,6,10,12,81,98,99)

replace t0_teeth28=. if inlist(dex_prosthes_zb21,.o,.p,.u,.y,.z) //code for missing values
replace t0_teeth32=. if inlist(dex_prosthes_zb21,.o,.p,.u,.y,.z) //code for missing values

/////////////////Number of missing teeth, fullmouth, excluding third molars
gen t0_mteeth28=28-t0_teeth28
label var t0_mteeth28 "T0: Number of missing teeth (Basis 28)"

////////////////maximum PD, all sites
egen t0_maxPD=rowmax(dex_parodont_okdiss1- dex_parodont_okmips4 dex_parodont_okmips5- dex_parodont_ukmils7)
label var t0_maxPD "T0: Max PD, mm"
ta t0_maxPD,mi

////////////////mean PD, all sites
egen t0_meanPD=rowmean(dex_parodont_okdiss1- dex_parodont_okmips4 dex_parodont_okmips5- dex_parodont_ukmils7)
label var t0_meanPD "T0: Mean PD, mm"

////////////PD ≥6 mm at ≥2 non-adjacent teeth; disregard probing depths at 3rd molars and at distal surfaces of 2nd molars
*1. calculate max PD per tooth in upper and lower quadrants (halfmouth)
forvalues i = 1(1)6 {
	egen t0_maxPD_OK`i'=rowmax(dex_parodont_okdiss`i' dex_parodont_okmebs`i' dex_parodont_okmibs`i' dex_parodont_okmips`i')
	egen t0_maxPD_UK`i'=rowmax(dex_parodont_ukdiss`i' dex_parodont_ukmebs`i' dex_parodont_ukmibs`i' dex_parodont_ukmils`i')
}
egen t0_maxPD_OK7=rowmax(dex_parodont_okmebs7 dex_parodont_okmibs7 dex_parodont_okmips7)
egen t0_maxPD_UK7=rowmax(dex_parodont_ukmebs7 dex_parodont_ukmibs7 dex_parodont_ukmils7)

forvalues i = 1(1)7 {
label var t0_maxPD_UK`i' "T0: maximum PD per tooth, lower jaw, position `i'"
label var t0_maxPD_OK`i' "T0: maximum PD per tooth, upper jaw, position `i'"
}

*2. PD 6+ mm at 2+ non-adjacent teeth? Test all possible combinations of non-adjacent teeth and check if PD 6+ mm at all possible pairs of non-adjacent teeth
gen PD6_2NAteeth=.
replace PD6_2NAteeth=1 if (t0_maxPD_OK1>=6 & t0_maxPD_OK1<.) & (t0_maxPD_OK3>=6 & t0_maxPD_OK3<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK1>=6 & t0_maxPD_OK1<.) & (t0_maxPD_OK4>=6 & t0_maxPD_OK4<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK1>=6 & t0_maxPD_OK1<.) & (t0_maxPD_OK5>=6 & t0_maxPD_OK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK1>=6 & t0_maxPD_OK1<.) & (t0_maxPD_OK6>=6 & t0_maxPD_OK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK1>=6 & t0_maxPD_OK1<.) & (t0_maxPD_OK7>=6 & t0_maxPD_OK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK2>=6 & t0_maxPD_OK2<.) & (t0_maxPD_OK4>=6 & t0_maxPD_OK4<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK2>=6 & t0_maxPD_OK2<.) & (t0_maxPD_OK5>=6 & t0_maxPD_OK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK2>=6 & t0_maxPD_OK2<.) & (t0_maxPD_OK6>=6 & t0_maxPD_OK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK2>=6 & t0_maxPD_OK2<.) & (t0_maxPD_OK7>=6 & t0_maxPD_OK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK3>=6 & t0_maxPD_OK3<.) & (t0_maxPD_OK5>=6 & t0_maxPD_OK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK3>=6 & t0_maxPD_OK3<.) & (t0_maxPD_OK6>=6 & t0_maxPD_OK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK3>=6 & t0_maxPD_OK3<.) & (t0_maxPD_OK7>=6 & t0_maxPD_OK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK4>=6 & t0_maxPD_OK4<.) & (t0_maxPD_OK6>=6 & t0_maxPD_OK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK4>=6 & t0_maxPD_OK4<.) & (t0_maxPD_OK7>=6 & t0_maxPD_OK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_OK5>=6 & t0_maxPD_OK5<.) & (t0_maxPD_OK7>=6 & t0_maxPD_OK7<.)

replace PD6_2NAteeth=1 if (t0_maxPD_UK1>=6 & t0_maxPD_UK1<.) & (t0_maxPD_UK3>=6 & t0_maxPD_UK3<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK1>=6 & t0_maxPD_UK1<.) & (t0_maxPD_UK4>=6 & t0_maxPD_UK4<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK1>=6 & t0_maxPD_UK1<.) & (t0_maxPD_UK5>=6 & t0_maxPD_UK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK1>=6 & t0_maxPD_UK1<.) & (t0_maxPD_UK6>=6 & t0_maxPD_UK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK1>=6 & t0_maxPD_UK1<.) & (t0_maxPD_UK7>=6 & t0_maxPD_UK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK2>=6 & t0_maxPD_UK2<.) & (t0_maxPD_UK4>=6 & t0_maxPD_UK4<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK2>=6 & t0_maxPD_UK2<.) & (t0_maxPD_UK5>=6 & t0_maxPD_UK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK2>=6 & t0_maxPD_UK2<.) & (t0_maxPD_UK6>=6 & t0_maxPD_UK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK2>=6 & t0_maxPD_UK2<.) & (t0_maxPD_UK7>=6 & t0_maxPD_UK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK3>=6 & t0_maxPD_UK3<.) & (t0_maxPD_UK5>=6 & t0_maxPD_UK5<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK3>=6 & t0_maxPD_UK3<.) & (t0_maxPD_UK6>=6 & t0_maxPD_UK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK3>=6 & t0_maxPD_UK3<.) & (t0_maxPD_UK7>=6 & t0_maxPD_UK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK4>=6 & t0_maxPD_UK4<.) & (t0_maxPD_UK6>=6 & t0_maxPD_UK6<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK4>=6 & t0_maxPD_UK4<.) & (t0_maxPD_UK7>=6 & t0_maxPD_UK7<.)
replace PD6_2NAteeth=1 if (t0_maxPD_UK5>=6 & t0_maxPD_UK5<.) & (t0_maxPD_UK7>=6 & t0_maxPD_UK7<.)

forvalues i = 1(1)7 {
	forvalues j = 1(1)7 {
		replace PD6_2NAteeth=1 if (t0_maxPD_OK`i'>=6 & t0_maxPD_OK`i'<.) & (t0_maxPD_UK`j'>=6 & t0_maxPD_UK`j'<.)
}
}

list t0_maxPD_* PD6_2NAteeth if PD6_2NAteeth==1
ta PD6_2NAteeth,mi
label var PD6_2NAteeth "T0: equals 1 if PD 6+ mm at 2+ non-adjacent teeth (staging)"

//////////////BOP
egen bop01=anycount(dex_parodont_pbokdib1- dex_parodont_pbukmil7),values(0 1)
egen bop1 =anycount(dex_parodont_pbokdib1- dex_parodont_pbukmil7),values(1)
replace bop01=. if inlist(dex_parodont_pbokdib1,.o,.p,.q,.y,.z)
replace bop1=. if inlist(dex_parodont_pbokdib1,.o,.p,.q,.y,.z) //544 missing
gen t0_bop=100*bop1/bop01
label var t0_bop "T0: BOP, %"
drop bop01 bop1

/////////////Number of opposing pairs (including positions with gap closure)
forvalues j = 1(1)4 {
	forvalues i = 1(1)7 {
		gen     t0_tooth`j'`i'=1 if inlist(dex_prosthes_zb`j'`i',0,2,4,5,6,7,12)
		replace t0_tooth`j'`i'=0 if inlist(dex_prosthes_zb`j'`i',1,3,8,9,10,11,13,14,98,99)
		replace t0_tooth`j'`i'=. if inlist(dex_prosthes_zb`j'`i',.o,.p,.u,.y,.z)
	}
}

forvalues i = 1(1)7 {
gen t0_occl_1`i'=1 if t0_tooth1`i'==1 & t0_tooth4`i'==1
gen t0_occl_2`i'=1 if t0_tooth2`i'==1 & t0_tooth3`i'==1
}

egen t0_opp_pairs=anycount(t0_occl_11-t0_occl_27),values(1)
replace t0_opp_pairs=. if t0_teeth28>=. //99 participatns with missing dental examination
label var t0_opp_pairs "T0: Number of opposing pairs of natural teeth"
ta t0_opp_pairs,mi

//////////////////maximum CAL, nonapproximal sites
egen maxCALnonappr=rowmax(dex_parodont_okmiba1 dex_parodont_okmiba2 dex_parodont_okmiba3 dex_parodont_okmiba4 dex_parodont_okmiba5 dex_parodont_okmiba6 dex_parodont_okmiba7 dex_parodont_ukmiba1 dex_parodont_ukmiba2 dex_parodont_ukmiba3 dex_parodont_ukmiba4 dex_parodont_ukmiba5 dex_parodont_ukmiba6 dex_parodont_ukmiba7 dex_parodont_okmipa1 dex_parodont_okmipa2 dex_parodont_okmipa3 dex_parodont_okmipa4 dex_parodont_okmipa5 dex_parodont_okmipa6 dex_parodont_okmipa7 dex_parodont_ukmila1 dex_parodont_ukmila2 dex_parodont_ukmila3 dex_parodont_ukmila4 dex_parodont_ukmila5 dex_parodont_ukmila6 dex_parodont_ukmila7)
label var maxCALnonappr "T0: Maximum CAL, nonapproximal sites"
ta maxCALnonappr,mi

//////////////////maximum CAL, all sites
egen maxCAL=rowmax(dex_parodont_okmiba1 dex_parodont_okmiba2 dex_parodont_okmiba3 dex_parodont_okmiba4 dex_parodont_okmiba5 dex_parodont_okmiba6 dex_parodont_okmiba7 dex_parodont_ukmiba1 dex_parodont_ukmiba2 dex_parodont_ukmiba3 dex_parodont_ukmiba4 dex_parodont_ukmiba5 dex_parodont_ukmiba6 dex_parodont_ukmiba7 dex_parodont_okmipa1 dex_parodont_okmipa2 dex_parodont_okmipa3 dex_parodont_okmipa4 dex_parodont_okmipa5 dex_parodont_okmipa6 dex_parodont_okmipa7 dex_parodont_ukmila1 dex_parodont_ukmila2 dex_parodont_ukmila3 dex_parodont_ukmila4 dex_parodont_ukmila5 dex_parodont_ukmila6 dex_parodont_ukmila7 dex_parodont_okdisa1 dex_parodont_okdisa2 dex_parodont_okdisa3 dex_parodont_okdisa4 dex_parodont_okdisa5 dex_parodont_okdisa6 dex_parodont_okdisa7 dex_parodont_ukdisa1 dex_parodont_ukdisa2 dex_parodont_ukdisa3 dex_parodont_ukdisa4 dex_parodont_ukdisa5 dex_parodont_ukdisa6 dex_parodont_ukdisa7 dex_parodont_okmeba1 dex_parodont_okmeba2 dex_parodont_okmeba3 dex_parodont_okmeba4 dex_parodont_okmeba5 dex_parodont_okmeba6 dex_parodont_okmeba7 dex_parodont_ukmeba1 dex_parodont_ukmeba2 dex_parodont_ukmeba3 dex_parodont_ukmeba4 dex_parodont_ukmeba5 dex_parodont_ukmeba6 dex_parodont_ukmeba7)
label var maxCAL "T0: Maximum CAL, all sites"
ta maxCAL,mi

///////////////////maximum CAL, approximal sites
egen maxCALappr=rowmax(dex_parodont_okdisa1 dex_parodont_okdisa2 dex_parodont_okdisa3 dex_parodont_okdisa4 dex_parodont_okdisa5 dex_parodont_okdisa6 dex_parodont_okdisa7 dex_parodont_ukdisa1 dex_parodont_ukdisa2 dex_parodont_ukdisa3 dex_parodont_ukdisa4 dex_parodont_ukdisa5 dex_parodont_ukdisa6 dex_parodont_ukdisa7 dex_parodont_okmeba1 dex_parodont_okmeba2 dex_parodont_okmeba3 dex_parodont_okmeba4 dex_parodont_okmeba5 dex_parodont_okmeba6 dex_parodont_okmeba7 dex_parodont_ukmeba1 dex_parodont_ukmeba2 dex_parodont_ukmeba3 dex_parodont_ukmeba4 dex_parodont_ukmeba5 dex_parodont_ukmeba6 dex_parodont_ukmeba7)
label var maxCALappr "T0: Maximum CAL, approximal sites"
ta maxCALappr,mi


//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
//Variables to calculate Extent
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/////////////////Number and percentage of teeth with CAL 1-2/3-4/5+mm - Extent; localized versus generalized	
*1. Define maximum CAL per tooth, including only approximal sites
forvalues i=1(1)7 {
egen maxCAL_OK`i'=rowmax(dex_parodont_okdisa`i' dex_parodont_okmeba`i')
egen maxCAL_UK`i'=rowmax(dex_parodont_ukdisa`i' dex_parodont_ukmeba`i') 
}

*2. Count the number of teeth with CAL measurements (approximal sites)
egen nTCALappr=anycount(maxCAL_OK1 maxCAL_UK1 maxCAL_OK2 maxCAL_UK2 maxCAL_OK3 maxCAL_UK3 maxCAL_OK4 maxCAL_UK4 maxCAL_OK5 maxCAL_UK5 maxCAL_OK6 maxCAL_UK6 maxCAL_OK7 maxCAL_UK7), values(0 1 2 to 30)
replace nTCALappr=.e if maxCALappr==.e
replace nTCALappr=.f if maxCALappr==.f
replace nTCALappr=.o if maxCALappr==.o
replace nTCALappr=.p if maxCALappr==.p
replace nTCALappr=.q if maxCALappr==.q
replace nTCALappr=.s if maxCALappr==.s
replace nTCALappr=.y if maxCALappr==.y
replace nTCALappr=.z if maxCALappr==.z
label var nTCALappr "T0: Number of teeth with approximal CAL measurements"

*3. Count the number of teeth with CAL 1-2 mm, 3-4 mm, and 5+ mm (approximal sites); restricting non-missing entries to participants with the respective Stage
egen nTCAL12appr=anycount(maxCAL_OK1 maxCAL_UK1 maxCAL_OK2 maxCAL_UK2 maxCAL_OK3 maxCAL_UK3 maxCAL_OK4 maxCAL_UK4 maxCAL_OK5 maxCAL_UK5 maxCAL_OK6 maxCAL_UK6 maxCAL_OK7 maxCAL_UK7) if inlist(maxCALapp,1,2), values(1 2)
replace nTCAL12appr=. if maxCALappr>2 
replace nTCAL12appr=. if maxCALappr==0
label var nTCAL12appr "T0: Number of teeth with approximal CAL of 1-2 mm; if stage I"

egen nTCAL34appr=anycount(maxCAL_OK1 maxCAL_UK1 maxCAL_OK2 maxCAL_UK2 maxCAL_OK3 maxCAL_UK3 maxCAL_OK4 maxCAL_UK4 maxCAL_OK5 maxCAL_UK5 maxCAL_OK6 maxCAL_UK6 maxCAL_OK7 maxCAL_UK7) if inlist(maxCALapp,3,4), values(3 4)
replace nTCAL34appr=. if maxCALappr!=3 & maxCALappr!=4
label var nTCAL34appr "T0: Number of teeth with approximal CAL of 3-4 mm; if stage II"

egen nTCAL5appr=anycount(maxCAL_OK1 maxCAL_UK1 maxCAL_OK2 maxCAL_UK2 maxCAL_OK3 maxCAL_UK3 maxCAL_OK4 maxCAL_UK4 maxCAL_OK5 maxCAL_UK5 maxCAL_OK6 maxCAL_UK6 maxCAL_OK7 maxCAL_UK7) if maxCALapp>=5 & maxCALapp<. , values(5 6 to 30)
replace nTCAL5appr=. if maxCALappr<5
replace nTCAL5appr=. if maxCALappr>=.
label var nTCAL5appr "T0: Number of teeth with approximal CAL of 5+ mm; if stage III or IV"

list maxCAL_OK* maxCAL_UK* maxCALappr nTCAL12appr nTCAL34appr nTCAL5appr if inlist(maxCALappr,1,2)
list maxCAL_OK* maxCAL_UK* maxCALappr nTCAL12appr nTCAL34appr nTCAL5appr if inlist(maxCALappr,3,4)
list maxCAL_OK* maxCAL_UK* maxCALappr nTCAL12appr nTCAL34appr nTCAL5appr if maxCALappr>=5 & maxCALappr<.

*4. Calculate the percentage of teeth with CAL 1-2, 3-4, or 5+ mm; restricting non-missing entries to participants with the respective Stage
gen pcTCAL12appr=100*nTCAL12appr/nTCALappr if nTCAL12appr<.
label var pcTCAL12appr "Percentage of teeth with CAL 1-2 mm, if max CAL is 1-2 mm"
gen pcTCAL34appr=100*nTCAL34appr/nTCALappr if nTCAL34appr<.
label var pcTCAL34appr "Percentage of teeth with CAL 3-4 mm, if max CAL is 3-4 mm"
gen pcTCAL5appr=100*nTCAL5appr/nTCALappr if nTCAL5appr<.
label var pcTCAL5appr "Percentage of teeth with CAL 5+ mm, if max CAL is 5+ mm"


//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
// Variables to 1. assess assessability of the perio case definition (part 1 and 2) and 2. evaluate the perio case criteria
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

/////////////////Number of teeth with buccal or oral CAL and PD
gen NBteeth_CALbo_PD=0
forvalues i=1(1)7 {
replace NBteeth_CALbo_PD=NBteeth_CALbo_PD+1 if (dex_parodont_okmiba`i'<. & dex_parodont_okmibs`i'<.) | (dex_parodont_okmipa`i'<. & dex_parodont_okmips`i'<.)
replace NBteeth_CALbo_PD=NBteeth_CALbo_PD+1 if (dex_parodont_ukmiba`i'<. & dex_parodont_ukmibs`i'<.) | (dex_parodont_ukmila`i'<. & dex_parodont_ukmils`i'<.)
}
label var NBteeth_CALbo_PD "Number of teeth with buccal CAL/PD or oral CAL/PD measurements"
ta NBteeth_CALbo_PD,mi //0 und 1 -> periodontitis case criterion is not assessible

/////////////////Presence of buccal or oral CAL >=3mm with PD >3mm at >=2 teeth 
forvalues i=1(1)7 {
gen CALbo3_PD4_OK`i'=0 
gen CALbo3_PD4_UK`i'=0 
}

forvalues i=1(1)7 {
replace CALbo3_PD4_OK`i'=1 if ((dex_parodont_okmiba`i'>=3 & dex_parodont_okmiba`i'<.) & (dex_parodont_okmibs`i'>3 & dex_parodont_okmibs`i'<.))|((dex_parodont_okmipa`i'>=3 & dex_parodont_okmipa`i'<.) & (dex_parodont_okmips`i'>3 & dex_parodont_okmips`i'<.))
replace CALbo3_PD4_UK`i'=1 if ((dex_parodont_ukmiba`i'>=3 & dex_parodont_ukmiba`i'<.) & (dex_parodont_ukmibs`i'>3 & dex_parodont_ukmibs`i'<.))|((dex_parodont_ukmila`i'>=3 & dex_parodont_ukmila`i'<.) & (dex_parodont_ukmils`i'>3 & dex_parodont_ukmils`i'<.))
}

forvalues i=1(1)7 {
replace CALbo3_PD4_OK`i'=. if (dex_parodont_okmiba`i'>=. | dex_parodont_okmibs`i'>=.) & (dex_parodont_okmipa`i'>=. | dex_parodont_okmips`i'>=.)
replace CALbo3_PD4_UK`i'=. if (dex_parodont_ukmiba`i'>=. | dex_parodont_ukmibs`i'>=.) & (dex_parodont_ukmila`i'>=. | dex_parodont_ukmils`i'>=.)
}

egen CALbo3_PD4=anycount(CALbo3_PD4_OK1 CALbo3_PD4_UK1 CALbo3_PD4_OK2 CALbo3_PD4_UK2 CALbo3_PD4_OK3 CALbo3_PD4_UK3 CALbo3_PD4_OK4 CALbo3_PD4_UK4 CALbo3_PD4_OK5 CALbo3_PD4_UK5 CALbo3_PD4_OK6 CALbo3_PD4_UK6 CALbo3_PD4_OK7 CALbo3_PD4_UK7),values(1)

egen CAL2MISS=rowmiss(CALbo3_PD4_OK1 CALbo3_PD4_UK1 CALbo3_PD4_OK2 CALbo3_PD4_UK2 CALbo3_PD4_OK3 CALbo3_PD4_UK3 CALbo3_PD4_OK4 CALbo3_PD4_UK4 CALbo3_PD4_OK5 CALbo3_PD4_UK5 CALbo3_PD4_OK6 CALbo3_PD4_UK6 CALbo3_PD4_OK7 CALbo3_PD4_UK7)
ta CAL2MISS
replace CALbo3_PD4=. if inlist(CAL2MISS,14) //0 teeth with buccal/oral CAL
label var CALbo3_PD4 "Number of teeth with buccal or oral CAL >=3mm with PD >3mm"
//(>=2 teeth needed for periodontitis case classification): CALbo3_PD4>=2 & CALbo3_PD4<.
ta CALbo3_PD4,mi
*set missing if less than 2 teeth have PD/CAL measurements; criterion is not assessible; non-classified participants
replace CALbo3_PD4=. if NBteeth_CALbo_PD<2
ta CALbo3_PD4 NBteeth_CALbo_PD,mi

///////////////////////Having >=2 non-adjacent teeth with approximal CAL (>=0 mm) measurements
gen CALappr_2NAteeth=.

forvalues i=1(1)7 {
replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK5>=0&maxCAL_OK5<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK6>=0&maxCAL_OK6<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK7>=0&maxCAL_OK7<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
}

replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK3>=0 & maxCAL_OK3<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK4>=0 & maxCAL_OK4<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK4>=0 & maxCAL_OK4<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_OK5>=0&maxCAL_OK5<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)

replace CALappr_2NAteeth=1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK3>=0 & maxCAL_UK3<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK4>=0 & maxCAL_UK4<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK4>=0 & maxCAL_UK4<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK4>=0&maxCAL_UK4<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK4>=0&maxCAL_UK4<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_2NAteeth=1 if (maxCAL_UK5>=0&maxCAL_UK5<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)

label var CALappr_2NAteeth "Having >=2 NA teeth with appr CAL measurements"

///////////////////////Number of non-adjacent teeth with approximal CAL measurements (>=0 mm)
gen CALappr_NbNAteeth=0

forvalues i=1(1)7 {
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK5>=0&maxCAL_OK5<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK6>=0&maxCAL_OK6<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK7>=0&maxCAL_OK7<.) & (maxCAL_UK`i'>=0 & maxCAL_UK`i'<.)
}

replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK3>=0 & maxCAL_OK3<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK4>=0 & maxCAL_OK4<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK1>=0&maxCAL_OK1<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK4>=0 & maxCAL_OK4<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK2>=0&maxCAL_OK2<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK5>=0 & maxCAL_OK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK3>=0&maxCAL_OK3<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_OK6>=0 & maxCAL_OK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK4>=0&maxCAL_OK4<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_OK5>=0&maxCAL_OK5<.) & (maxCAL_OK7>=0 & maxCAL_OK7<.)

replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK3>=0 & maxCAL_UK3<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK4>=0 & maxCAL_UK4<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK1>=0&maxCAL_UK1<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK4>=0 & maxCAL_UK4<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK2>=0&maxCAL_UK2<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK5>=0 & maxCAL_UK5<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK3>=0&maxCAL_UK3<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK4>=0&maxCAL_UK4<.) & (maxCAL_UK6>=0 & maxCAL_UK6<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK4>=0&maxCAL_UK4<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)
replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (maxCAL_UK5>=0&maxCAL_UK5<.) & (maxCAL_UK7>=0 & maxCAL_UK7<.)

replace CALappr_NbNAteeth=CALappr_NbNAteeth+1 if (CALappr_NbNAteeth>=1 & CALappr_NbNAteeth<.)

ta CALappr_NbNAteeth if maxCALappr>=.,mi
replace CALappr_NbNAteeth=. if maxCALappr>=. //N=989

label var CALappr_NbNAteeth "Number of non-adjacent teeth (pairs) with approximal CAL measurements"
ta CALappr_NbNAteeth,mi //N=189 with no non-adjacent teeth with CAL measurements; 989 missing CAL measurements

//////////////////////Having approximal CAL >=1mm at 2+ non-adjacent teeth
gen CALappr_present=.a

forvalues i=1(1)7 {
replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK2>=1&maxCAL_OK2<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK3>=1&maxCAL_OK3<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK4>=1&maxCAL_OK4<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK5>=1&maxCAL_OK5<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK6>=1&maxCAL_OK6<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
replace CALappr_present=1 if (maxCAL_OK7>=1&maxCAL_OK7<.) & (maxCAL_UK`i'>=1 & maxCAL_UK`i'<.)
}

replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_OK3>=1 & maxCAL_OK3<.)
replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_OK4>=1 & maxCAL_OK4<.)
replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_OK5>=1 & maxCAL_OK5<.)
replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_OK6>=1 & maxCAL_OK6<.)
replace CALappr_present=1 if (maxCAL_OK1>=1&maxCAL_OK1<.) & (maxCAL_OK7>=1 & maxCAL_OK7<.)
replace CALappr_present=1 if (maxCAL_OK2>=1&maxCAL_OK2<.) & (maxCAL_OK4>=1 & maxCAL_OK4<.)
replace CALappr_present=1 if (maxCAL_OK2>=1&maxCAL_OK2<.) & (maxCAL_OK5>=1 & maxCAL_OK5<.)
replace CALappr_present=1 if (maxCAL_OK2>=1&maxCAL_OK2<.) & (maxCAL_OK6>=1 & maxCAL_OK6<.)
replace CALappr_present=1 if (maxCAL_OK2>=1&maxCAL_OK2<.) & (maxCAL_OK7>=1 & maxCAL_OK7<.)
replace CALappr_present=1 if (maxCAL_OK3>=1&maxCAL_OK3<.) & (maxCAL_OK5>=1 & maxCAL_OK5<.)
replace CALappr_present=1 if (maxCAL_OK3>=1&maxCAL_OK3<.) & (maxCAL_OK6>=1 & maxCAL_OK6<.)
replace CALappr_present=1 if (maxCAL_OK3>=1&maxCAL_OK3<.) & (maxCAL_OK7>=1 & maxCAL_OK7<.)
replace CALappr_present=1 if (maxCAL_OK4>=1&maxCAL_OK4<.) & (maxCAL_OK6>=1 & maxCAL_OK6<.)
replace CALappr_present=1 if (maxCAL_OK4>=1&maxCAL_OK4<.) & (maxCAL_OK7>=1 & maxCAL_OK7<.)
replace CALappr_present=1 if (maxCAL_OK5>=1&maxCAL_OK5<.) & (maxCAL_OK7>=1 & maxCAL_OK7<.)

replace CALappr_present=1 if (maxCAL_UK1>=1&maxCAL_UK1<.) & (maxCAL_UK3>=1 & maxCAL_UK3<.)
replace CALappr_present=1 if (maxCAL_UK1>=1&maxCAL_UK1<.) & (maxCAL_UK4>=1 & maxCAL_UK4<.)
replace CALappr_present=1 if (maxCAL_UK1>=1&maxCAL_UK1<.) & (maxCAL_UK5>=1 & maxCAL_UK5<.)
replace CALappr_present=1 if (maxCAL_UK1>=1&maxCAL_UK1<.) & (maxCAL_UK6>=1 & maxCAL_UK6<.)
replace CALappr_present=1 if (maxCAL_UK1>=1&maxCAL_UK1<.) & (maxCAL_UK7>=1 & maxCAL_UK7<.)
replace CALappr_present=1 if (maxCAL_UK2>=1&maxCAL_UK2<.) & (maxCAL_UK4>=1 & maxCAL_UK4<.)
replace CALappr_present=1 if (maxCAL_UK2>=1&maxCAL_UK2<.) & (maxCAL_UK5>=1 & maxCAL_UK5<.)
replace CALappr_present=1 if (maxCAL_UK2>=1&maxCAL_UK2<.) & (maxCAL_UK6>=1 & maxCAL_UK6<.)
replace CALappr_present=1 if (maxCAL_UK2>=1&maxCAL_UK2<.) & (maxCAL_UK7>=1 & maxCAL_UK7<.)
replace CALappr_present=1 if (maxCAL_UK3>=1&maxCAL_UK3<.) & (maxCAL_UK5>=1 & maxCAL_UK5<.)
replace CALappr_present=1 if (maxCAL_UK3>=1&maxCAL_UK3<.) & (maxCAL_UK6>=1 & maxCAL_UK6<.)
replace CALappr_present=1 if (maxCAL_UK3>=1&maxCAL_UK3<.) & (maxCAL_UK7>=1 & maxCAL_UK7<.)
replace CALappr_present=1 if (maxCAL_UK4>=1&maxCAL_UK4<.) & (maxCAL_UK6>=1 & maxCAL_UK6<.)
replace CALappr_present=1 if (maxCAL_UK4>=1&maxCAL_UK4<.) & (maxCAL_UK7>=1 & maxCAL_UK7<.)
replace CALappr_present=1 if (maxCAL_UK5>=1&maxCAL_UK5<.) & (maxCAL_UK7>=1 & maxCAL_UK7<.)

ta CALappr_NbNAteeth CALappr_present,mi
replace CALappr_present=0 if CALappr_present==.a&(CALappr_NbNAteeth>=2&CALappr_NbNAteeth<.) & maxCALappr<. //2+ non-adjacent teeth with approximal CAL measurements; N=178
*replace CALappr_present=. if (CALappr_NbNAteeth<2) //ist schon missing
*replace CALappr_present=. if (CALappr_NbNAteeth<2) & maxCALappr>=. //ist schon missing

ta CALappr_present,mi
label define CALappr_present 0 "0: 2+ NA teeth with CAL, no perio case" 1 "1: 2+ NA teeth with CAL, perio case" .a ".a: less than 2 NA teeth with CAL"
label value CALappr_present CALappr_present
label var CALappr_present "appr CAL >=1mm at >=2 non-adjacent teeth"

ta  CALappr_NbNAteeth if maxCALappr>=. //all missing; OKAY


//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
//Classification according to Health - Gingivitis - Periodontitis, Staging, Extent, Grading
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

////////////////Selection of participants for evaluation of the gingivitis and periodontits schemes
*drop participants with missing data on tooth status, PD, approximal CAL, and BOP
keep if t0_teeth32<. //99 dropped; no dental examination
drop if t0_maxPD>=. &  maxCALappr>=. & t0_teeth32!=0 //429 dropped (SHIP-MOBIL); dentates with no PD and no CAL
drop if t0_bop>=. & t0_teeth32!=0 //276 deleted; dentates with no BOP
su zz //N=3889 total number of participants

/////////////////Step 1: Classification according to Health - Gingivitis - Periodontitis

*****Suspect periodontitis if:
*[buccal or oral CAL >=3 mm with PD >3 mm at >=2 NA teeth (CALbo3_PD4>=2)
*OR
*appr CAL >=1 mm at >=2 NA teeth (CALappr_present==1)]

*Periodontal health; periodontitis case criterion is negative
gen     step1=1 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & t0_maxPD<=3 & t0_bop<10

*Localized Gingivitis; perio case criterion is negative 
replace step1=2 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & t0_maxPD<=3 & (t0_bop>=10 & t0_bop<=30)

*Generalized Gingivitis; perio case criterion is negative
replace step1=3 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & t0_maxPD<=3 & (t0_bop>30 & t0_bop<.)

*Pseudo pockets; perio case criterion is negative; periodontal health
replace step1=1 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & (t0_maxPD>=4&t0_maxPD<.) & (t0_bop<10)

*Pseudo pockets; perio case criterion is negative; localized gingivitis
replace step1=2 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & (t0_maxPD>=4&t0_maxPD<.) & (t0_bop>=10 & t0_bop<=30)

*Pseudo pockets; perio case criterion is negative; generalized gingivitis
replace step1=3 if (CALappr_present==0 & CALbo3_PD4<2 & (NBteeth_CALbo_PD>=2 & NBteeth_CALbo_PD<.)) & (t0_maxPD>=4&t0_maxPD<.) & (t0_bop>=30 & t0_bop<.)

*Cases with i) <2 NA teeth with appr CAL measurements or ii) <2 b/o CAL/PD measurements are defined as "non-classified"

*Staging; perio case criterion negative or not assessible
replace step1=4 if (CALappr_present==.a & NBteeth_CALbo_PD<2) //not assessible AND not assessible 
replace step1=4 if (CALappr_present==0  & NBteeth_CALbo_PD<2) //no perio case AND not assessible
replace step1=4 if (CALappr_present==.a & ((NBteeth_CALbo_PD>=2&NBteeth_CALbo_PD<.) & CALbo3_PD4<2)) //not assessible AND no perio case

*Staging; periodontitis case
replace step1=5 if (CALappr_present==1 | (CALbo3_PD4>=2 & CALbo3_PD4<.))

*Edentulous; N=273
replace step1=0 if t0_teeth32==0

label define step1 0 "0: edentulous" 1 "1: Periodontal health" 2 "2: Localized gingivitis" 3 "3: Generalized gingivitis" 4 "4: Non-classified" 5 "5: Periodontitis cases -  Go for staging"

label value step1 step1
ta step1 //N=3889
ta step1,mi //N=3889


//////////////////////Staging, via approximal CAL, PD 6+ mm at 2+ non-adjacent teeth and number of opposing pairs of natural teeth

gen     t0_staging=.
replace t0_staging=1 if step1==5 & inlist(maxCALappr,1,2)
replace t0_staging=2 if step1==5 & inlist(maxCALappr,3,4) & PD6_2NAteeth==.
replace t0_staging=3 if step1==5 & inlist(maxCALappr,3,4) & PD6_2NAteeth==1
replace t0_staging=3 if step1==5 & (maxCALappr>=5&maxCALappr<.) & (t0_opp_pairs>=10 & t0_opp_pairs<.)
replace t0_staging=4 if step1==5 & (maxCALappr>=5&maxCALappr<.) & t0_opp_pairs<10
label var t0_staging "T0: staging for periodontitis cases, considering approximal CAL, PD6+mm, and opposing pairs"
label define staging 1 "1: Stage I" 2 "2: Stage II" 3 "3: Stage III" 4 "4: Stage IV" 
label value t0_staging staging
ta t0_staging

//////////////////////Staging, via approximal CAL only

gen     t0_staging_CAL=.
replace t0_staging_CAL=1 if step1==5 & inlist(maxCALappr,1,2)
replace t0_staging_CAL=2 if step1==5 & inlist(maxCALappr,3,4)
replace t0_staging_CAL=3 if step1==5 & (maxCALappr>=5&maxCALappr<.)
label var t0_staging_CAL "T0: t0_staging for periodontitis cases, considering approximal CAL only"
label define staging_CAL 1 "1: Stage I" 2 "2: Stage II" 3 "3: Stage III/IV" 
label value t0_staging_CAL staging_CAL
ta t0_staging_CAL

//////////////////////Staging, via approximal CAL, PD 6+ mm at 2+ non-adjacent teeth

gen     t0_staging_CAL_PD=.
replace t0_staging_CAL_PD=1 if step1==5 & inlist(maxCALappr,1,2)
replace t0_staging_CAL_PD=2 if step1==5 & inlist(maxCALappr,3,4) & PD6_2NAteeth==.
replace t0_staging_CAL_PD=3 if step1==5 & inlist(maxCALappr,3,4) & PD6_2NAteeth==1
replace t0_staging_CAL_PD=3 if step1==5 & (maxCALappr>=5&maxCALappr<.)
label var t0_staging_CAL_PD "T0: staging for periodontitis cases, considering approximal CAL and PD6+mm"
label define t0_staging_CAL_PD 1 "1: Stage I" 2 "2: Stage II" 3 "3: Stage III/IV" 
label value t0_staging_CAL_PD t0_staging_CAL_PD
ta t0_staging_CAL_PD


//////////////////////Staging, via approximal CAL, PD 6+ mm at 2+ non-adjacent teeth and number of opposing pairs of natural teeth

gen     t0_staging_CAL_OP=.
replace t0_staging_CAL_OP=1 if step1==5 & inlist(maxCALappr,1,2)
replace t0_staging_CAL_OP=2 if step1==5 & inlist(maxCALappr,3,4)
replace t0_staging_CAL_OP=3 if step1==5 & (maxCALappr>=5&maxCALappr<.) & (t0_opp_pairs>=10 & t0_opp_pairs<.)
replace t0_staging_CAL_OP=4 if step1==5 & (maxCALappr>=5&maxCALappr<.) & t0_opp_pairs<10
label var t0_staging_CAL_OP "T0: staging for periodontitis cases, considering approximal CAL and opposing pairs"
label define t0_staging_CAL_OP 1 "1: Stage I" 2 "2: Stage II" 3 "3: Stage III" 4 "4: Stage IV" 
label value t0_staging_CAL_OP t0_staging_CAL_OP
ta t0_staging_CAL_OP


/////////////////////////Complete classification scheme, including Staging of periodontitis cases (including CAL, PD and opposing pairs of natural teeth)

gen     EFP_AAP_classification=step1 
replace EFP_AAP_classification=5 if step1==5 & t0_staging==1
replace EFP_AAP_classification=6 if step1==5 & t0_staging==2
replace EFP_AAP_classification=7 if step1==5 & t0_staging==3
replace EFP_AAP_classification=8 if step1==5 & t0_staging==4

label define EFP_AAP_classification 0 "0: edentulous" 1 "1: healthy periodontium" 2 "2: localized gingivitis" 3 "3: generalized gingivitis" 4 "4: Non-classified" 5 "5: Stage I" 6 "6: Stage II" 7 "7: Stage III" 8 "8: Stage IV"
label value EFP_AAP_classification EFP_AAP_classification
ta EFP_AAP_classification,mi


/////////////////////////Extent (loc/gen)

ta EFP_AAP_classification

gen t0_extent=0 if pcTCAL12appr<30 & EFP_AAP_classification==5 //Stage I, localized
replace t0_extent=1 if (pcTCAL12appr>=30 & pcTCAL12appr<.) & EFP_AAP_classification==5 //Stage I, generalized
replace t0_extent=0 if pcTCAL34appr<30 & EFP_AAP_classification==6 //Stage II, localized
replace t0_extent=1 if (pcTCAL34appr>=30 & pcTCAL34appr<.) & EFP_AAP_classification==6 //Stage II, generalized
replace t0_extent=0 if pcTCAL5appr<30 & EFP_AAP_classification==7 //Stage III, localized
replace t0_extent=1 if (pcTCAL5appr>=30 & pcTCAL5appr<.) & EFP_AAP_classification==7 //Stage III, generalized
replace t0_extent=0 if pcTCAL34appr<30 & EFP_AAP_classification==7 & inlist(maxCALappr,3,4) //Stage III, localized; cases upstaged from Stage II to Stage III due to complexity factors; count teeth with approximal CAL 3-4 mm!
replace t0_extent=1 if (pcTCAL34appr>=30 & pcTCAL34appr<.) & EFP_AAP_classification==7 & inlist(maxCALappr,3,4) //Stage III, generalized; cases upstaged from Stage II to Stage III due to complexity factors; count teeth with approximal CAL 3-4 mm!
replace t0_extent=0 if pcTCAL5appr<30 & EFP_AAP_classification==8 //Stage IV, localized
replace t0_extent=1 if (pcTCAL5appr>=30 & pcTCAL5appr<.) & EFP_AAP_classification==8 //Stage IV, generalized
label var t0_extent "T0: Extent"
label define extent 0 "0: localized" 1 "1: generalized"
label value t0_extent extent

///////////////////////Grading
//calculate indirect evidence of progression by computing the ratio of radiographic BL, expressed as a percent of the root length at the worst affected tooth, over the participant's age in years
//Root lengths: for midbuccal and midlingual/midpalatinal sites, the average root length from distal and mesial sites were used

****1. calculate root length at the worst affected tooth, using root length data from Salonen et al. (1991); see Appendix Table 2

************Males
**Q1, tooth position 1, upper jaw, Q1
gen BL_okdisa1 = 100*dex_parodont_okdisa1 / 17.3 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba1 = 100*dex_parodont_okmiba1 / ((17.3+18.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba1 = 100*dex_parodont_okmeba1 / 18.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa1 = 100*dex_parodont_okmipa1 / ((17.3+18.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 1, upper jaw, Q2
replace BL_okdisa1 = 100*dex_parodont_okdisa1 / 17.3 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba1 = 100*dex_parodont_okmiba1 / ((17.3+18.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba1 = 100*dex_parodont_okmeba1 / 18.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa1 = 100*dex_parodont_okmipa1 / ((17.3+18.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 2
gen BL_okdisa2 = 100*dex_parodont_okdisa2 / 17.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba2 = 100*dex_parodont_okmiba2 / ((17.2+17.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba2 = 100*dex_parodont_okmeba2 / 17.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa2 = 100*dex_parodont_okmipa2 / ((17.2+17.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 2
replace BL_okdisa2 = 100*dex_parodont_okdisa2 / 17.3 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba2 = 100*dex_parodont_okmiba2 / ((17.3+17.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba2 = 100*dex_parodont_okmeba2 / 17.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa2 = 100*dex_parodont_okmipa2 / ((17.3+17.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 3
gen BL_okdisa3 = 100*dex_parodont_okdisa3 / 20.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba3 = 100*dex_parodont_okmiba3 / ((20.4+20.8)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba3 = 100*dex_parodont_okmeba3 / 20.8 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa3 = 100*dex_parodont_okmipa3 / ((20.4+20.8)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 3
replace BL_okdisa3 = 100*dex_parodont_okdisa3 / 20.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba3 = 100*dex_parodont_okmiba3 / ((20.2+20.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba3 = 100*dex_parodont_okmeba3 / 20.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa3 = 100*dex_parodont_okmipa3 / ((20.2+20.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 4
gen BL_okdisa4 = 100*dex_parodont_okdisa4 / 15.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba4 = 100*dex_parodont_okmiba4 / ((15.6+15.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba4 = 100*dex_parodont_okmeba4 / 15.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa4 = 100*dex_parodont_okmipa4 / ((15.6+15.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 4
replace BL_okdisa4 = 100*dex_parodont_okdisa4 / 15.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba4 = 100*dex_parodont_okmiba4 / ((15.5+15.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba4 = 100*dex_parodont_okmeba4 / 15.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa4 = 100*dex_parodont_okmipa4 / ((15.5+15.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 5
gen BL_okdisa5 = 100*dex_parodont_okdisa5 / 15.3 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba5 = 100*dex_parodont_okmiba5 / ((15.3+15.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba5 = 100*dex_parodont_okmeba5 / 15.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa5 = 100*dex_parodont_okmipa5 / ((15.3+15.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 5
replace BL_okdisa5 = 100*dex_parodont_okdisa5 / 15.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba5 = 100*dex_parodont_okmiba5 / ((15.6+15.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba5 = 100*dex_parodont_okmeba5 / 15.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa5 = 100*dex_parodont_okmipa5 / ((15.6+15.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 6
gen BL_okdisa6 = 100*dex_parodont_okdisa6 / 13.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba6 = 100*dex_parodont_okmiba6 / ((13.4+14.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba6 = 100*dex_parodont_okmeba6 / 14.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa6 = 100*dex_parodont_okmipa6 / ((13.4+14.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 6
replace BL_okdisa6 = 100*dex_parodont_okdisa6 / 13.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba6 = 100*dex_parodont_okmiba6 / ((13.1+14.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba6 = 100*dex_parodont_okmeba6 / 14.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa6 = 100*dex_parodont_okmipa6 / ((13.1+14.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q1, tooth position 7
gen BL_okdisa7 = 100*dex_parodont_okdisa7 / 12.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmiba7 = 100*dex_parodont_okmiba7 / ((14.9+12.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmeba7 = 100*dex_parodont_okmeba7 / 14.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_okmipa7 = 100*dex_parodont_okmipa7 / ((14.9+12.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q2, tooth position 7
replace BL_okdisa7 = 100*dex_parodont_okdisa7 / 13.0 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmiba7 = 100*dex_parodont_okmiba7 / ((13.0+14.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmeba7 = 100*dex_parodont_okmeba7 / 14.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_okmipa7 = 100*dex_parodont_okmipa7 / ((13.0+14.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2


**Q4, tooth position 1
gen BL_ukdisa1 = 100*dex_parodont_ukdisa1 / 15.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba1 = 100*dex_parodont_ukmiba1 / ((16.3+15.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba1 = 100*dex_parodont_ukmeba1 / 16.3 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa1 = 100*dex_parodont_ukmila1 / ((16.3+15.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 1
replace BL_ukdisa1 = 100*dex_parodont_ukdisa1 / 16.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba1 = 100*dex_parodont_ukmiba1 / ((16.1+16.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba1 = 100*dex_parodont_ukmeba1 / 16.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa1 = 100*dex_parodont_ukmila1 / ((16.1+16.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 2
gen BL_ukdisa2 = 100*dex_parodont_ukdisa2 / 17.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba2 = 100*dex_parodont_ukmiba2 / ((17.1+18.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba2 = 100*dex_parodont_ukmeba2 / 18.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa2 = 100*dex_parodont_ukmila2 / ((17.1+18.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 2
replace BL_ukdisa2 = 100*dex_parodont_ukdisa2 / 17.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba2 = 100*dex_parodont_ukmiba2 / ((17.2+17.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba2 = 100*dex_parodont_ukmeba2 / 17.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa2 = 100*dex_parodont_ukmila2 / ((17.2+17.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 3
gen BL_ukdisa3 = 100*dex_parodont_ukdisa3 / 19.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba3 = 100*dex_parodont_ukmiba3 / ((21.1+19.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba3 = 100*dex_parodont_ukmeba3 / 21.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa3 = 100*dex_parodont_ukmila3 / ((21.1+19.6)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 3
replace BL_ukdisa3 = 100*dex_parodont_ukdisa3 / 19.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba3 = 100*dex_parodont_ukmiba3 / ((19.6+20.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba3 = 100*dex_parodont_ukmeba3 / 20.7 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa3 = 100*dex_parodont_ukmila3 / ((19.6+20.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 4
gen BL_ukdisa4 = 100*dex_parodont_ukdisa4 / 17.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba4 = 100*dex_parodont_ukmiba4 / ((17.4+17.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba4 = 100*dex_parodont_ukmeba4 / 17.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa4 = 100*dex_parodont_ukmila4 / ((17.4+17.2)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 4
replace BL_ukdisa4 = 100*dex_parodont_ukdisa4 / 17.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba4 = 100*dex_parodont_ukmiba4 / ((17.2+17.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba4 = 100*dex_parodont_ukmeba4 / 17.5 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa4 = 100*dex_parodont_ukmila4 / ((17.2+17.5)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 5
gen BL_ukdisa5 = 100*dex_parodont_ukdisa5 / 17.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba5 = 100*dex_parodont_ukmiba5 / ((17.1+17.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba5 = 100*dex_parodont_ukmeba5 / 17.7 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa5 = 100*dex_parodont_ukmila5 / ((17.1+17.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 5
replace BL_ukdisa5 = 100*dex_parodont_ukdisa5 / 16.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba5 = 100*dex_parodont_ukmiba5 / ((16.9+17.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba5 = 100*dex_parodont_ukmeba5 / 17.7 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa5 = 100*dex_parodont_ukmila5 / ((16.9+17.7)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 6
gen BL_ukdisa6 = 100*dex_parodont_ukdisa6 / 14.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba6 = 100*dex_parodont_ukmiba6 / ((16.6+14.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba6 = 100*dex_parodont_ukmeba6 / 16.6 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa6 = 100*dex_parodont_ukmila6 / ((16.6+14.9)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 6
replace BL_ukdisa6 = 100*dex_parodont_ukdisa6 / 14.9 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba6 = 100*dex_parodont_ukmiba6 / ((14.9+16.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba6 = 100*dex_parodont_ukmeba6 / 16.4 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa6 = 100*dex_parodont_ukmila6 / ((14.9+16.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

**Q4, tooth position 7
gen BL_ukdisa7 = 100*dex_parodont_ukdisa7 / 14.0 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmiba7 = 100*dex_parodont_ukmiba7 / ((16.0+14.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmeba7 = 100*dex_parodont_ukmeba7 / 16.0 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
gen BL_ukmipa7 = 100*dex_parodont_ukmila7 / ((16.0+14.4)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==1
**Q3, tooth position 7
replace BL_ukdisa7 = 100*dex_parodont_ukdisa7 / 14.2 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmiba7 = 100*dex_parodont_ukmiba7 / ((14.2+16.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmeba7 = 100*dex_parodont_ukmeba7 / 16.1 if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2
replace BL_ukmipa7 = 100*dex_parodont_ukmila7 / ((14.2+16.1)/2) if SEX_SHIP_T0==1 & dex_oralbase_quadrant==2

******************Females
**Q1, tooth position 1
replace BL_okdisa1 = 100*dex_parodont_okdisa1 / 16.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba1 = 100*dex_parodont_okmiba1 / ((16.3+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba1 = 100*dex_parodont_okmeba1 / 17.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa1 = 100*dex_parodont_okmipa1 / ((16.3+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 1
replace BL_okdisa1 = 100*dex_parodont_okdisa1 / 16.4 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba1 = 100*dex_parodont_okmiba1 / ((16.4+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba1 = 100*dex_parodont_okmeba1 / 17.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa1 = 100*dex_parodont_okmipa1 / ((16.4+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 2
replace BL_okdisa2 = 100*dex_parodont_okdisa2 / 16.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba2 = 100*dex_parodont_okmiba2 / ((16.3+16.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba2 = 100*dex_parodont_okmeba2 / 16.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa2 = 100*dex_parodont_okmipa2 / ((13.6+16.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 2
replace BL_okdisa2 = 100*dex_parodont_okdisa2 / 16.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba2 = 100*dex_parodont_okmiba2 / ((16.3+16.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba2 = 100*dex_parodont_okmeba2 / 16.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa2 = 100*dex_parodont_okmipa2 / ((16.3+16.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 3
replace BL_okdisa3 = 100*dex_parodont_okdisa3 / 18.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba3 = 100*dex_parodont_okmiba3 / ((18.5+19.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba3 = 100*dex_parodont_okmeba3 / 19.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa3 = 100*dex_parodont_okmipa3 / ((18.5+19.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 3
replace BL_okdisa3 = 100*dex_parodont_okdisa3 / 18.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba3 = 100*dex_parodont_okmiba3 / ((19.4+18.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba3 = 100*dex_parodont_okmeba3 / 19.4 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa3 = 100*dex_parodont_okmipa3 / ((19.4+18.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 4
replace BL_okdisa4 = 100*dex_parodont_okdisa4 / 15.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba4 = 100*dex_parodont_okmiba4 / ((15.0+14.7)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba4 = 100*dex_parodont_okmeba4 / 14.7 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa4 = 100*dex_parodont_okmipa4 / ((15.0+14.7)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 4
replace BL_okdisa4 = 100*dex_parodont_okdisa4 / 14.6 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba4 = 100*dex_parodont_okmiba4 / ((14.3+14.6)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba4 = 100*dex_parodont_okmeba4 / 14.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa4 = 100*dex_parodont_okmipa4 / ((14.3+14.6)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 5
replace BL_okdisa5 = 100*dex_parodont_okdisa5 / 14.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba5 = 100*dex_parodont_okmiba5 / ((14.3+14.5)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba5 = 100*dex_parodont_okmeba5 / 14.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa5 = 100*dex_parodont_okmipa5 / ((14.3+14.5)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 5
replace BL_okdisa5 = 100*dex_parodont_okdisa5 / 14.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba5 = 100*dex_parodont_okmiba5 / ((14.5+14.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba5 = 100*dex_parodont_okmeba5 / 14.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa5 = 100*dex_parodont_okmipa5 / ((14.5+14.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 6
replace BL_okdisa6 = 100*dex_parodont_okdisa6 / 12.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba6 = 100*dex_parodont_okmiba6 / ((12.1+13.6)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba6 = 100*dex_parodont_okmeba6 / 13.6 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa6 = 100*dex_parodont_okmipa6 / ((12.1+13.6)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 6
replace BL_okdisa6 = 100*dex_parodont_okdisa6 / 11.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba6 = 100*dex_parodont_okmiba6 / ((13.5+11.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba6 = 100*dex_parodont_okmeba6 / 13.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa6 = 100*dex_parodont_okmipa6 / ((13.5+11.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q1, tooth position 7
replace BL_okdisa7 = 100*dex_parodont_okdisa7 / 12.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmiba7 = 100*dex_parodont_okmiba7 / ((13.8+12.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmeba7 = 100*dex_parodont_okmeba7 / 13.8 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_okmipa7 = 100*dex_parodont_okmipa7 / ((13.8+12.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q2, tooth position 7
replace BL_okdisa7 = 100*dex_parodont_okdisa7 / 11.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmiba7 = 100*dex_parodont_okmiba7 / ((13.2+11.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmeba7 = 100*dex_parodont_okmeba7 / 13.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_okmipa7 = 100*dex_parodont_okmipa7 / ((13.2+11.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 1
replace BL_ukdisa1 = 100*dex_parodont_ukdisa1 / 15.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba1 = 100*dex_parodont_ukmiba1 / ((15.4+15.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba1 = 100*dex_parodont_ukmeba1 / 15.4 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa1 = 100*dex_parodont_ukmila1 / ((15.4+15.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 1
replace BL_ukdisa1 = 100*dex_parodont_ukdisa1 / 15.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba1 = 100*dex_parodont_ukmiba1 / ((15.1+15.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba1 = 100*dex_parodont_ukmeba1 / 15.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa1 = 100*dex_parodont_ukmila1 / ((15.1+15.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 2
replace BL_ukdisa2 = 100*dex_parodont_ukdisa2 / 16.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba2 = 100*dex_parodont_ukmiba2 / ((16.2+17.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba2 = 100*dex_parodont_ukmeba2 / 17.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa2 = 100*dex_parodont_ukmila2 / ((16.2+17.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 2
replace BL_ukdisa2 = 100*dex_parodont_ukdisa2 / 16.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba2 = 100*dex_parodont_ukmiba2 / ((16.2+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba2 = 100*dex_parodont_ukmeba2 / 17.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa2 = 100*dex_parodont_ukmila2 / ((16.2+17.0)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 3
replace BL_ukdisa3 = 100*dex_parodont_ukdisa3 / 18.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba3 = 100*dex_parodont_ukmiba3 / ((18.0+19.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba3 = 100*dex_parodont_ukmeba3 / 19.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa3 = 100*dex_parodont_ukmila3 / ((18.0+19.2)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 3
replace BL_ukdisa3 = 100*dex_parodont_ukdisa3 / 18.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba3 = 100*dex_parodont_ukmiba3 / ((18.2+19.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba3 = 100*dex_parodont_ukmeba3 / 19.1 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa3 = 100*dex_parodont_ukmila3 / ((18.2+19.1)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 4
replace BL_ukdisa4 = 100*dex_parodont_ukdisa4 / 16.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba4 = 100*dex_parodont_ukmiba4 / ((16.5+16.8)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba4 = 100*dex_parodont_ukmeba4 / 16.8 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa4 = 100*dex_parodont_ukmila4 / ((16.5+16.8)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 4
replace BL_ukdisa4 = 100*dex_parodont_ukdisa4 / 16.4 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba4 = 100*dex_parodont_ukmiba4 / ((16.4+16.7)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba4 = 100*dex_parodont_ukmeba4 / 16.7 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa4 = 100*dex_parodont_ukmila4 / ((16.4+16.7)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 5
replace BL_ukdisa5 = 100*dex_parodont_ukdisa5 / 16.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba5 = 100*dex_parodont_ukmiba5 / ((16.5+16.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba5 = 100*dex_parodont_ukmeba5 / 16.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa5 = 100*dex_parodont_ukmila5 / ((16.5+16.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 5
replace BL_ukdisa5 = 100*dex_parodont_ukdisa5 / 16.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba5 = 100*dex_parodont_ukmiba5 / ((16.2+16.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba5 = 100*dex_parodont_ukmeba5 / 16.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa5 = 100*dex_parodont_ukmila5 / ((16.2+16.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 6
replace BL_ukdisa6 = 100*dex_parodont_ukdisa6 / 14.3 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba6 = 100*dex_parodont_ukmiba6 / ((16.0+14.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba6 = 100*dex_parodont_ukmeba6 / 16.0 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa6 = 100*dex_parodont_ukmila6 / ((16.0+14.3)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 6
replace BL_ukdisa6 = 100*dex_parodont_ukdisa6 / 14.2 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba6 = 100*dex_parodont_ukmiba6 / ((14.2+15.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba6 = 100*dex_parodont_ukmeba6 / 15.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa6 = 100*dex_parodont_ukmila6 / ((14.2+15.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

**Q4, tooth position 7
replace BL_ukdisa7 = 100*dex_parodont_ukdisa7 / 13.9 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmiba7 = 100*dex_parodont_ukmiba7 / ((15.6+13.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmeba7 = 100*dex_parodont_ukmeba7 / 15.6 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
replace BL_ukmipa7 = 100*dex_parodont_ukmila7 / ((15.6+13.9)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==1
**Q3, tooth position 7
replace BL_ukdisa7 = 100*dex_parodont_ukdisa7 / 13.8 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmiba7 = 100*dex_parodont_ukmiba7 / ((15.5+13.8)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmeba7 = 100*dex_parodont_ukmeba7 / 15.5 if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2
replace BL_ukmipa7 = 100*dex_parodont_ukmila7 / ((15.5+13.8)/2) if SEX_SHIP_T0==2 & dex_oralbase_quadrant==2

****2. calculate maximum bone loss over all sites
foreach var of varlist BL_okdisa1 BL_okmiba1 BL_okmeba1 BL_okmipa1 BL_okdisa2 BL_okmiba2 BL_okmeba2 BL_okmipa2 BL_okdisa3 BL_okmiba3 BL_okmeba3 BL_okmipa3 BL_okdisa4 BL_okmiba4 BL_okmeba4 BL_okmipa4 BL_okdisa5 BL_okmiba5 BL_okmeba5 BL_okmipa5 BL_okdisa6 BL_okmiba6 BL_okmeba6 BL_okmipa6 BL_okdisa7 BL_okmiba7 BL_okmeba7 BL_okmipa7 BL_ukdisa1 BL_ukmiba1 BL_ukmeba1 BL_ukmipa1 BL_ukdisa2 BL_ukmiba2 BL_ukmeba2 BL_ukmipa2 BL_ukdisa3 BL_ukmiba3 BL_ukmeba3 BL_ukmipa3 BL_ukdisa4 BL_ukmiba4 BL_ukmeba4 BL_ukmipa4 BL_ukdisa5 BL_ukmiba5 BL_ukmeba5 BL_ukmipa5 BL_ukdisa6 BL_ukmiba6 BL_ukmeba6 BL_ukmipa6 BL_ukdisa7 BL_ukmiba7 BL_ukmeba7 BL_ukmipa7 {
replace `var'=100 if `var'>100 & `var'<.
}

****3. calculate maximum bone loss over all sites
egen maxBL=rowmax(BL_okdisa1- BL_ukmipa7)
gen pc_BL_age=maxBL/AGE_SHIP_T0
su pc_BL_age maxBL maxCAL //N=3430

****4. calculate Grade for periodontitis cases (step1==6; Periodontitis cases only)
ta step1 //N=3070

gen t0_grade_salonen=2 if step1==5
replace t0_grade_salonen=1 if (pc_BL_age<0.25 & csmoking_t0==0 & diab_known_t0==0) & step1==5
replace t0_grade_salonen=3 if pc_BL_age>1 | (csmoking_t0==1 & (t0_rau_04>=10 & t0_rau_04<.)) | (diab_known_t0==1 & (hba1c>=7 & hba1c<.)) & step1==5
label define grade 1 "1: Grade A" 2 "2: Grade B" 3 "3: Grade C"
label values t0_grade_salonen grade
label var t0_grade_salonen "T0: Grade, using Salonen (1991) root length data"
ta t0_grade_salonen
ta t0_staging t0_grade_salonen, row


/////////////////////////////Treatment success according to Sanz et al. 2020

*Calculate the number of sites with comcomitant PD >=4 mm and BOP; BOP was recorded at tooth positions 1-4 and 6-7 (excluding 5)
forvalues i=1(1)4 {
gen t0_PD4BOP_okdis`i'=1 if (dex_parodont_okdiss`i'>=4 & dex_parodont_okdiss`i'<.) & dex_parodont_pbokdib`i'==1
gen t0_PD4BOP_ukdis`i'=1 if (dex_parodont_ukdiss`i'>=4 & dex_parodont_ukdiss`i'<.) & dex_parodont_pbukdib`i'==1
gen t0_PD4BOP_okmib`i'=1 if (dex_parodont_okmibs`i'>=4 & dex_parodont_okmibs`i'<.) & dex_parodont_pbokmib`i'==1
gen t0_PD4BOP_ukmib`i'=1 if (dex_parodont_ukmibs`i'>=4 & dex_parodont_ukmibs`i'<.) & dex_parodont_pbukmib`i'==1
gen t0_PD4BOP_okmeb`i'=1 if (dex_parodont_okmebs`i'>=4 & dex_parodont_okmebs`i'<.) & dex_parodont_pbokmeb`i'==1
gen t0_PD4BOP_ukmeb`i'=1 if (dex_parodont_ukmebs`i'>=4 & dex_parodont_ukmebs`i'<.) & dex_parodont_pbukmeb`i'==1
gen t0_PD4BOP_okmip`i'=1 if (dex_parodont_okmips`i'>=4 & dex_parodont_okmips`i'<.) & dex_parodont_pbokmip`i'==1
gen t0_PD4BOP_ukmil`i'=1 if (dex_parodont_ukmils`i'>=4 & dex_parodont_ukmils`i'<.) & dex_parodont_pbukmil`i'==1
}

forvalues i=6(1)7 {
gen t0_PD4BOP_okdis`i'=1 if (dex_parodont_okdiss`i'>=4 & dex_parodont_okdiss`i'<.) & dex_parodont_pbokdib`i'==1
gen t0_PD4BOP_ukdis`i'=1 if (dex_parodont_ukdiss`i'>=4 & dex_parodont_ukdiss`i'<.) & dex_parodont_pbukdib`i'==1
gen t0_PD4BOP_okmib`i'=1 if (dex_parodont_okmibs`i'>=4 & dex_parodont_okmibs`i'<.) & dex_parodont_pbokmib`i'==1
gen t0_PD4BOP_ukmib`i'=1 if (dex_parodont_ukmibs`i'>=4 & dex_parodont_ukmibs`i'<.) & dex_parodont_pbukmib`i'==1
gen t0_PD4BOP_okmeb`i'=1 if (dex_parodont_okmebs`i'>=4 & dex_parodont_okmebs`i'<.) & dex_parodont_pbokmeb`i'==1
gen t0_PD4BOP_ukmeb`i'=1 if (dex_parodont_ukmebs`i'>=4 & dex_parodont_ukmebs`i'<.) & dex_parodont_pbukmeb`i'==1
gen t0_PD4BOP_okmip`i'=1 if (dex_parodont_okmips`i'>=4 & dex_parodont_okmips`i'<.) & dex_parodont_pbokmip`i'==1
gen t0_PD4BOP_ukmil`i'=1 if (dex_parodont_ukmils`i'>=4 & dex_parodont_ukmils`i'<.) & dex_parodont_pbukmil`i'==1
}

forvalues i=1(1)4 {
label var t0_PD4BOP_okdis`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukdis`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmib`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmib`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmeb`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmeb`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmip`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmil`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
}

forvalues i=6(1)7 {
label var t0_PD4BOP_okdis`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukdis`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmib`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmib`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmeb`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmeb`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_okmip`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
label var t0_PD4BOP_ukmil`i' "T0: site with PD >=4 mm and BOP, yes [1 coded]"
}

*Count the number of sites with PD 4+ and comcomitant BOP
egen t0_PD4BOP_Nsites=anycount(t0_PD4BOP_ok* t0_PD4BOP_uk*), values(1)
label var t0_PD4BOP_Nsites "T0: number of sites with comcomitant PD >=4 mm and BOP"
replace t0_PD4BOP_Nsites=. if t0_meanPD>=. //271 changes
replace t0_PD4BOP_Nsites=. if t0_bop>=.
su t0_PD4BOP_Nsites, detail //N=3618

*determine treatment outcome in periodontitis cases
gen     t0_TXoutcome=0 if t0_PD4BOP_Nsites==0 & t0_bop<10 & t0_maxPD<6 
replace t0_TXoutcome=1 if t0_PD4BOP_Nsites==0 & (t0_bop>=10 & t0_bop<.) & t0_maxPD<6 
replace t0_TXoutcome=2 if (t0_PD4BOP_Nsites>=1 & t0_PD4BOP_Nsites<.) | (t0_maxPD>=6 & t0_maxPD<.) 
label define TX 0 "0-Successfully treated and stable periodontitis patients" 1 "1-Successfully treated and stable periodontitis patients with gingival inflammation" 2 "2-unstable periodontitis patients requiring further treatment"
label value t0_TXoutcome TX

save "C:\Users\holtfreterb\Documents\Eigene Dateien\Zahnmedizin\2018 classification in SHIP\Originaldaten\TREND_V2_FINAL.dta",replace
