////////////////////////////////////////////////////////////////////////////////
// Paper 1
// Renae Loh Sze Ming, Gerbert Kraaykamp, Margriet van Hek
// Data Preparations for Analyses
////////////////////////////////////////////////////////////////////////////////

	clear all
	set more off
//	cd "/Users/renae/surfdrive/Documents/OECD PISA/Analyses Files/2020_P1/
	cd "C:\Users\U526178\surfdrive\Documents\OECD PISA\Analyses Files\2020_P1"
	use P1_PISA2018.dta
	
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////	

// KEEPING ONLY OCED + SCHOOL PARTICIPATION > 80% COUNTRIES

////////////////////////////////////////////////////////////////////////////////		
// 1a. OECD member + associates only
	keep if OECD==1 | CNT=="ALB" | CNT=="BRA" | CNT=="BRN" | CNT=="BGR" | ///
			CNT=="CRI" | CNT=="HRV" | CNT=="DOM" | CNT=="GEO" | CNT=="HKG"| ///
			CNT=="KAZ" | CNT=="MAC" | CNT=="MLT" | CNT=="MAR" | CNT=="PAN" | ///
			CNT=="RUS" | CNT=="SRB" | CNT=="SGP" | CNT=="THA" | CNT=="TAP" | ///
			CNT=="URY"

// 1c. OECD members only
	keep if OECD==1
	
// 1.b drop if no repeat measure or other scales

	drop if CNT=="JPN" // no repeat measure (because they dont repeat grades)
	drop if CNTRYID==40 // no skills measure
	drop if CNT=="ESP" // no reading measure
	
// 1c. >=80 school participation
	drop if school_part <.80
	
// Keeping natives only // 

	recode IMMIG (9=.) (8=.) 
	egen NATIVE = anymatch(IMMIG), values (1)
	replace NATIVE =. if IMMIG ==.

	keep if NATIVE==1


// 2. Variable generation

// 2a. ACCESS - simple aggregate on theoretical basis

	/* asdoc factor ACCESS*, save(factor_analyses_OECD.doc)
	egen stu_ACCESS_a = rowtotal(ACCESS*)
	// theoretical basis: USE ONLY ACCESS 1,2,3,4,5,7,9,11
	// ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS7 ACCESS11
	asdoc factor ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS5 ACCESS7 ACCESS9 ACCESS11, ///
				save(factor_analyses_OECD.doc)
	// eigenvalue of 1.30660
	
	// not doing cronbach alpha since we're not merging them but the factor
	// score indicates they all dance around the same factor
	alpha ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS5 ACCESS7 ACCESS9 ACCESS11
	*/
	
	egen missing = rowmiss(ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS7)
	tab missing
	
	drop if missing==4 | missing==5
	drop missing
	
	
	egen stu_ACCESS = rowtotal(ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS7)					   
	replace stu_ACCESS = . if ACCESS1==. & ACCESS2==. & ACCESS3 ==. & ///
							  ACCESS4 ==. & ACCESS7 ==.
							   
/*	replace stu_ACCESS = . if IC002Q01HA == 6
	replace stu_ACCESS = . if IC002Q01HA == . & stu_ACCESS==0
*/
	
// 2b. SKILL - average (?)

	/* asdoc alpha SKILL*, save(factor_analyses_OECD.doc)
	// average interitem covariance = .386791
	// scale reliability coefficient = .8705
	
	asdoc factor SKILL*, save(factor_analyses_OECD.doc)
	*/
	
	alpha SKILL*
	factor SKILL*
	egen stu_SKILL = rowmean(SKILL*)
	replace stu_SKILL = . if SKILL1==. & SKILL2==. & SKILL3==. & SKILL4 ==. & SKILL5 ==.


// 2c. EFFIC - average (?)

	/*asdoc alpha EFFIC*, save(factor_analyses_OECD.doc)
	// average interitem covariance = .3750521
	// scale reliability coefficient = .8703
	
	asdoc factor EFFIC*, save(factor_analyses_OECD.doc)
	*/
	alpha EFFIC*
	factor EFFIC*
	egen stu_EFFIC = rowmean(EFFIC*)
	replace stu_EFFIC = . if EFFIC1==.& EFFIC2==. & EFFIC3==. & EFFIC4 ==. & EFFIC5 ==.

	
// 2extra. SKILL AND EFFIC 

	/*
	asdoc alpha SKILL* EFFIC*, save(factor_analyses_OECD.doc)
	asdoc corr SKILL* EFFIC*, save(factor_analyses_OECD.doc)
	asdoc factor SKILL* EFFIC*, factor(2) save(factor_analyses_OECD.doc)
	asdoc rotate, oblique oblimin save(factor_analyses_OECD.doc)
	asdoc factor SKILL* EFFIC*, factor(1) save(factor_analyses_OECD.doc)
	*/
	
// 2d. USAGE

	egen stu_GAME = rowmean(RECUSE1 RECUSE2 RECUSE6)
	egen stu_SOCIAL = rowmean(RECUSE3 RECUSE4 RECUSE5)
	egen stu_INFO = rowmean(RECUSE8 RECUSE9)
	
	replace stu_GAME = . if RECUSE1==. & RECUSE2==. & RECUSE6 ==.
	replace stu_SOCIAL = . if RECUSE3==. & RECUSE4==. & RECUSE5 ==.
	replace stu_INFO = . if RECUSE8==. & RECUSE9==. 
	
	/* asdoc alpha RECUSE1 RECUSE2 RECUSE6, item save(factor_analyses_OECD.doc)
	asdoc alpha RECUSE3 RECUSE4 RECUSE5, item save(factor_analyses_OECD.doc)
	asdoc alpha RECUSE8 RECUSE9, item save(factor_analyses_OECD.doc)
	*/

// 2e. age and PARED scaling

	replace PARED = PARED - 3
	replace age = age - 15
	
/* OLD	
// 2d. USAGE

	asdoc factor SCHUSE* RECUSE*, mine(1) save(factor_analyses_OECD.doc)
	asdoc rotate, oblique oblimin save(factor_analyses_OECD.doc)

		factor SCHUSE*, ml factor(1) 
		rotate, oblique oblimin
		predict ICT_SCH_f_a, regress
		egen ICT_SCH_m_a = rowmean(SCHUSE*)
		
		factor RECUSE*, ml factor(1) 
		rotate, oblique oblimin
		predict ICT_REC_f_a, regress
		egen ICT_REC_m_a = rowmean(RECUSE*)
		
		asdoc corr ICT_SCH_f_a ICT_REC_f_a, save(factor_analyses_OECD.doc)
		/* low correlation, reflects the factor analysis, also shows that
		the variance explained by both overlap but not by a lot */
		
		asdoc corr ICT_SCH_f_a ICT_SCH_m_a, save(factor_analyses_OECD.doc) // .9976
		asdoc corr ICT_REC_f_a ICT_REC_m_a, save(factor_analyses_OECD.doc)// .9863
		asdoc corr ICT_SCH_*_a ICT_REC_*_a, save(factor_analyses_OECD.doc)
	
	/*
	loadingplot, factors(2) mlabs(vsmall)
	eofplot, factors(1/2) number 
	*/
	
	// first looking at >=.3 factor loading
	
	/* factor 1: SCHUSE1 SCHUSE2 SCHUSE3 SCHUSE4 SCHUSE5 SCHUSE6 SCHUSE7 
				 SCHUSE8 SCHUSE9 SCHUSE10 SCHUSE11 SCHUSE12
				 RECUSE11
				 
				 ^ These are clearly for school
				 
	   factor 2: SCHUSE5
				 RECUSE3 RECUSE4 RECUSE5 RECUSE7 RECUSE8 RECUSE9 RECUSE10
				 
				 ^ somewhat ambiguious 
		
	   factor 3: RECUSE1 RECUSE2 RECUSE6 RECUSE10 RECUSE11 RECUSE12
	   
				^ these are for gaming for sure
	   */
	   
	   asdoc factor SCHUSE* RECUSE*, mine(1) factor(2) save(factor_analyses_OECD.doc) //forcing 2 factors
	   asdoc rotate, oblique oblimin save(factor_analyses_OECD.doc)
	   // here i was stricter, keeping only >=.5 loadings
	   /* factor 1: SCHUSE1 SCHUSE2 SCHUSE3 SCHUSE4 SCHUSE6 SCHUSE7 SCHUSE8
					SCHUSE9 SCHUSE10 SCHUSE11 SCHUSE12
					
		  factor 2: RECUSE1 RECUSE2 RECUSE4 RECUSE5 RECUSE7 RECUSE8 RECUSE9
					RECUSE10 RECUSE12
		*/
		
		global SCH_ACT ///
				SCHUSE1 SCHUSE2 SCHUSE3 SCHUSE4 SCHUSE6 SCHUSE7 SCHUSE8 ///
				SCHUSE9 SCHUSE10 SCHUSE11 SCHUSE12
				
		global REC_ACT ///
				RECUSE1 RECUSE2 RECUSE4 RECUSE5 RECUSE7 RECUSE8 RECUSE9 ///
				RECUSE10 RECUSE12
				
		factor $SCH_ACT, factor(1) 
		rotate, oblique oblimin
		predict ICT_SCH_f, regress
		egen ICT_SCH_m = rowmean($SCH_ACT)
		
		factor $REC_ACT, factor(1) 
		rotate, oblique oblimin
		predict ICT_REC_f, regress
		egen ICT_REC_m = rowmean($REC_ACT)
		
		asdoc corr ICT_SCH_f ICT_REC_f, save(factor_analyses_OECD.doc)
		/* low correlation, reflects the factor analysis, also shows that
		the variance explained by both overlap but not by a lot */
		
		asdoc corr ICT_SCH_f ICT_SCH_m, save(factor_analyses_OECD.doc) // .9976
		asdoc corr ICT_REC_f ICT_REC_m, save(factor_analyses_OECD.doc)// .9863
		/* factors and mean scores are highly correlated (~1) this means
		that the unweighted means are good approximates for the factor scores */
		
		rename ICT_SCH_m stu_SCHUSE
		rename ICT_REC_m stu_RECUSE
*/

// 3. interaction terms

	gen ACCxSES = stu_ACCESS*PARED
	gen SKIxSES = stu_SKILL*PARED
	gen EFFxSES = stu_EFFIC*PARED
	gen GAMxSES = stu_GAME*PARED
	gen SOCxSES = stu_SOCIAL*PARED
	gen INFxSES = stu_INFO*PARED

// 4. Missing values and other variables?
	
	recode REPEAT (0=0)(1=1)(9=.)
	recode GRADE (999999=.)
	
	egen TRUANT = anymatch(skip_school), values (1 2 3)
	replace TRUANT = 0 if skip_school==0
	replace TRUANT =. if skip_school==.
	
	
	
// 5. WEALTH 

	/*egen missing = rowmiss(WEALTH1 WEALTH2 WEALTH3 WEALTH15 WEALTH16)
	tab missing
	
	drop if missing>=3 
	drop missing*/
	recode WEALTH14 WEALTH15 WEALTH16 (0 1 = 0) (2 3 = 1)
	
	egen WEALTH_agg = rowtotal(WEALTH14 WEALTH15 WEALTH16) 

// 5. WEALTH - z-scores by country	
	/*
	
	forval i = 1/21 {
		
		egen WEALTH`i'_mean = mean(WEALTH`i'), by(CNTRYID)
		egen WEALTH`i'_sd = sd(WEALTH`i'), by(CNTRYID)
 }

	forval i = 1/21 {
		
		gen zWEALTH`i' = (WEALTH`i'-WEALTH`i'_mean)/WEALTH`i'_sd
 }
 
	egen WEALTH_z = rowmean(zWEALTH1 zWEALTH2 zWEALTH3 zWEALTH14 ///
							zWEALTH15 zWEALTH16)
*/

	
////////////////////////////////////////////////////////////////////////////////	
 /*	
// 5. descriptive table

	capture noisily asdoc tab CNTRYID, ///
		 detail save(factor_analyses_OECD.doc)
		 
	capture noisily asdoc ///
	summ female age REPEAT WEALTH CULTPOSS  ///
		 PARED stu_ACCESS stu_SKILL stu_EFFIC stu_GAME stu_SOCIAL stu_INFO,  ///
		 detail save(factor_analyses_OECD.doc)
		 
	capture noisily asdoc ///
	summ stu_ACCESS ACCESS1 ACCESS2 ACCESS3 ACCESS4 ACCESS5 ///
					ACCESS7 ACCESS9 ACCESS11 ///
		 stu_SKILL SKILL* ///
		 stu_EFFIC EFFIC* ///
		 stu_GAME RECUSE1 RECUSE2 RECUSE6 ///
		 stu_SOCIAL RECUSE3 RECUSE4 RECUSE5 ///
		 stu_INFO RECUSE8 RECUSE9, ///
		 detail save(factor_analyses_OECD.doc)
		 
	
	capture noisily asdoc ///
	corr stu_ACCESS stu_SKILL stu_EFFIC stu_GAME stu_SOCIAL stu_INFO ///
		 PV1SCIE PV1MATH PV1READ, ///
		 detail save(factor_analyses_OECD.doc) 
	
*/
	save P1_PISA2018_SEMOECD_RR2.dta, replace 
	
////////////////////////////////////////////////////////////////////////////////

	
// 4. keeping and ordering of variables

/*
		keep CNTRYID proportion_q1 OECD CNTSCHID school_part ///
			 CNTSTUID female age REPEAT GRADE TRUANT skip* NATIVE ///
			 IC002Q01HA IC004Q01HA ///
			 stu_ACCESS stu_SKILL stu_EFFIC stu_GAME stu_SOCIAL stu_INFO ///
			 ACCESS* SKILL* EFFIC* SCHUSE* RECUSE* ///
			 HOMESCH ENTUSE ///
			 HISCED MISCED FISCED PARED Z_WEALTH WEALTH_z P_WEALTH ESCS INCOME /// 
			 CULTPOSS HOMEPOS CURSUPP ///
			 ACCxSES SKIxSES EFFxSES GAMxSES SOCxSES INFxSES  ///
			 PV*
			 
		order CNTRYID proportion_q1 OECD CNTSCHID school_part ///
			 CNTSTUID female age REPEAT GRADE TRUANT skip* NATIVE ///
			 IC002Q01HA IC004Q01HA ///
			 stu_ACCESS stu_SKILL stu_EFFIC stu_GAME stu_SOCIAL stu_INFO ///
			 ACCESS* SKILL* EFFIC* SCHUSE* RECUSE* ///
			 HOMESCH ENTUSE ///
			 HISCED MISCED FISCED PARED Z_WEALTH WEALTH_z P_WEALTH ESCS INCOME /// 
			 CULTPOSS HOMEPOS CURSUPP ///
			 ACCxSES SKIxSES EFFxSES GAMxSES SOCxSES INFxSES ///
			 PV*
		
	save P1_PISA2018_SEMOECD.dta, replace
*/

////////////////////////////////////////////////////////////////////////////////


	
	/*use P1_SEM_PISA_2018.dta
	
	
	gen SESxACCESS = PARED*stu_ACCESS
	gen SESxSKILL = PARED*stu_SKILL
	gen SESxEFFIC = PARED*stu_EFFIC
	gen SESxSCHUSE = PARED*stu_SCHUSE
	gen SESxRECUSE = PARED*stu_RECUSE
	
	
		capture noisily asdoc ///
	sem (stu_ACCESS -> PV1SCIE, ) ///
	    (stu_SKILL -> PV1SCIE, ) ///
		(stu_EFFIC -> PV1SCIE, ) ///
		(stu_SCHUSE -> PV1SCIE, ) ///
		(stu_RECUSE -> PV1SCIE, ) ///
		(PARED -> PV1SCIE, )	///
		(PARED -> stu_ACCESS, ) ///
		(PARED -> stu_SKILL, ) ///
		(PARED -> stu_EFFIC, ) ///
		(PARED -> stu_SCHUSE, ) ///
		(PARED -> stu_RECUSE, ) ///
		(SESxACCESS -> PV1SCIE) ///
		(SESxSKILL -> PV1SCIE) ///
		(SESxEFFIC -> PV1SCIE) ///
		(SESxSCHUSE -> PV1SCIE) ///
		(SESxRECUSE -> PV1SCIE) ///
		(female ->PV1SCIE) ///
		(female -> stu_ACCESS) /// 
		(female -> stu_SKILL, ) ///
		(female -> stu_EFFIC, ) ///
		(female -> stu_SCHUSE, ) ///
		(female -> stu_RECUSE, ) ///
		, method(mlmv) nocapslatent ///
		covstruct(e.stu_ACCESS e.stu_SKILL e.stu_EFFIC e.stu_RECUSE, unstructured)
	*/
