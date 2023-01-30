////////////////////////////////////////////////////////////////////////////////
// Paper 1
// Renae Loh Sze Ming, Gerbert Kraaykamp, Margriet van Hek
// Data Cleaning
////////////////////////////////////////////////////////////////////////////////

clear all
set more off
//	cd "/Users/renae/surfdrive/Documents/OECD PISA/Analyses Files/2020_P1"
	cd "C:\Users\U526178\surfdrive\Documents\OECD PISA\Analyses Files\2020_P1"

////////////////////////////////////////////////////////////////////////////////

// 1. Cleaning PISA 2018 file

	// use "/Users/renae/surfdrive/Documents/OECD PISA/Analyses Files/PISA_2018.dta"
	use PISA_2018_full.dta
	
	//FYI: UK Scotland and UK excluding Scotland are merged
	//FYI: Russian Federation and Tatarstan (Russian) are merged
	
// 1a. Keeping countries that PARTICIPATED in the ICT Familiarity Questionnaire

	// Based on whether questionnaire is included in country's package
	keep if CNT == "ALB" | CNT == "AUS" | CNT == "AUT" | CNT == "BEL" | ///
			CNT == "BRA" | CNT == "BRN" | CNT == "BGR" | CNT == "CHL" | ///
			CNT == "TAP" | CNT == "CRI" | CNT == "HRV" | CNT == "CZE" | ///
			CNT == "DNK" | CNT == "DOM" | CNT == "EST" | CNT == "FIN" | ///
			CNT == "FRA" | CNT == "GEO"	| CNT == "GRC" | CNT == "HKG" | ///
			CNT == "HUN" | CNT == "ISL" | CNT == "IRL" | CNT == "ISR" | ///
			CNT == "ITA" | CNT == "JPN" | CNT == "KAZ" | CNT == "KOR" | ///
			CNT == "LVA" | CNT == "LTU" | CNT == "LUX" | CNT == "MAC" | ///
			CNT == "MLT" | CNT == "MEX" | CNT == "MAR" | CNT == "NZL" | ///
			CNT == "PAN" | CNT == "POL" | CNT == "RUS" | CNT == "SRB" | ///
			CNT == "SGP" | CNT == "SVK" | CNT == "SVN" | CNT == "ESP" | ///
			CNT == "SWE" | CNT == "CHE"	| CNT == "THA" | CNT == "TUR" | ///
			CNT == "GBR" | CNT == "URY" | CNT == "USA"
			
	// 51 countries, N = 384,437
	
	// Further clearing based on participation rate (at country & school level)
	
// 1b. Keeping the variables of interest
		
	keep CNTRYID CNT CNTSCHID CNTSTUID OECD IMMIG					///
		 ST001D01T ST004D01T ST005Q01TA ST006Q01TA ST006Q02TA 		///
		 ST006Q03TA  ST006Q04TA ST007Q01TA ST008Q01TA ST008Q02TA  	///
		 ST008Q03TA ST008Q04TA ST013Q01TA ST012Q* ST011Q*			///
		 IC* 														///
		 OCOD1 OCOD2 OCOD3 AGE GRADE REPEAT ST062Q01TA ST062Q02TA	///
		 ISCEDL ISCEDD ISCEDO MISCED FISCED HISCED PARED 			///
		 MISCED_D FISCED_D HISCED_D PAREDINT BMMJ1 BFMJ2 HISEI 		///
		 ESCS ICTHOME ICTSCH HOMEPOS CULTPOSS HEDRES WEALTH 		///
		 ICTRES ENTUSE HOMESCH USESCH INTICT COMPICT AUTICT SOIAICT ///
		 ICTCLASS ICTOUTSIDE CURSUPP PA042Q01TA						///
		 PV*MATH PV*READ PV*SCIE
		 
	save PISA_2018_ICT.dta, replace
	
////////////////////////////////////////////////////////////////////////////////
	
// 2. Generating Variables - ICT x 5, SES, EP

	use PISA_2018_ICT.dta
			 
// 2a. ACCESS: Rename and recode

	rename IC001Q* ACCESS#, renumber (1)
	recode ACCESS* (7=0) if IC002Q01HA==6
	
	/*NOTE: yielded no change. so where did the N/As come from??
			Assume the other interpretation of "N/A" as "the respondent was 
			never given the opportunity to answer this question, therefore
			missing.*/
	//recode ACCESS* (1=1) (2=0) (3=0) (7=.) (9=.) // if only "yes, and i use it" is considered as access
	recode ACCESS* (1=1) (2=1) (3=0) (7=.) (9=.) // both "yes" responses considered as access
			
	/* Where 1 = yes and i use it, is now 1
			 2 = yes but i dont use it, is now 1
			 3 = no, is now 0 
			 7 = not applicable (ie answered even though earlier answers
				 indicate otherwise or systematic missing ie never presented)
			 9 = no response despite being presented with question 
			 
			 QUESTION: Should 7=0 or missing as it's always the case that
			 the NA is NA for the whole list
			 2715 students in N/A so probably they indicated access, but the
			 subsequent indicated no access
			 Might be the same 2715 students later whose RECUSE AND SCHUSE
			 are also missing. Therefore systematic missing. Just remove 
			 the cases? */
	
	
	
// 2b. SKILL: Rename and check
	rename IC015Q* SKILL#, renumber (1)
	recode SKILL* (7=0) if IC002Q01HA==6 | IC004Q01HA==6

// 2c. SKILL: Recode
	recode SKILL* (1=0) (2=1) (3=2) (4=3) (5=0) (7=.) (9=.)

// 2d. EFFIC: Rename and check
	rename IC014Q* EFFIC#, renumber (1)
	recode EFFIC* (7=0) if IC002Q01HA==6 | IC004Q01HA==6

// 2e. EFFIC: Recode
	recode EFFIC* (1=0) (2=1) (3=2) (4=3) (5=0) (7=.) (9=.)
			 
// 2f. RECUSE and SCHUSE: Rename check
	rename IC008Q* RECUSE#, renumber (1) 
	recode RECUSE* (97=0) if IC002Q01HA==6 | IC004Q01HA==6
	
	rename IC010Q* SCHUSE#, renumber (1)
	recode SCHUSE* (97=0) if IC002Q01HA==6 | IC004Q01HA==6
	
// 2g. Dummy for systematic missings(?)
	/* gen ACCMISS = (ACCESS1-ACCESS11==7)
	gen RECMISS = (RECUSE1-RECUSE12==97)
	gen SCHMISS = (SCHUSE1-SCHUSE12==97)
	
	gen ICTMISS = (SCHUSE1-SCHUSE12==97 & RECUSE1-RECUSE12==97 & ACCESS1-ACCESS11==7)
	gen ICTMISS2 = (ACCMISS==1 & RECMISS==1 & SCHMISS ==1)
	*/
	
// 2h. RECUSE & SCHUSE: Recode

	recode RECUSE* (1=0) (2=1) (3=2) (4=3) (5=4) (95=0) (97=.) (99=.)
	recode SCHUSE* (1=0) (2=1) (3=2) (4=3) (5=4) (95=0) (97=.) (99=.)
	
	//mvdecode _all, mv(95 96 97 98 99 9999)
	// 95 = valid skip, 96 = not reached, 97 = N/A, 98 = invalid, 99 = No response
	
	
	// Note on 5/95 reponses: valid skips make up a small proportion.
	
	
// 2i. Parental Education: Generating highest parental edu

	recode HISCED (99=.)
	recode FISCED MISCED (99=.)
	
	/* gen HIEDU = FISCED if FISCED>MISCED
	replace HIEDU = MISCED if MISCED > FISCED
	replace HIEDU = FISCED if MISCED == FISCED
	*/
	
// 2j. Rename and recode demographics and identification
	
	rename ST004D01T gender
	gen female = 1 if gender ==1
	replace female = 0 if gender == 2
	
	rename AGE age
	
	rename ST062Q01TA skip_school
	rename ST062Q02TA skip_class 
	
	recode skip_school (1=0) (2=1) (3=2) (4=3) (7=0)(9=.)
	recode skip_class (1=0) (2=1) (3=2) (4=3) (7=0)(9=.)
	recode ISCEDO (1=1) (2 3 4 = 0) (8 9 =.), gen(GENERAL) 
	
	recode ST011* (1=1) (2=0) (7=.) (9=.)
	recode ST012* (1=0) (2=1) (3=2) (4=3) (7=.) (9=.)

	rename 	ST011* WEALTH#, renumber (1)
	rename 	ST012* WEALTH#, renumber (14)
	
	rename WEALTH P_WEALTH
	
	rename PA042Q01TA INCOME
	recode INCOME (99 98 97 =.)
	
	rename BMMJ1 ISEI_M
	rename BFMJ2 ISEI_F
	rename HISEI ISEI_HI
	recode ISEI* (999=.)
	
// 2k. Missing values recode for everything else
	order *, sequential
	order PV*, after(skip_school)
	order CNTRYID CNT CNTSCHID OECD CNTSTUID 
	
	mvdecode ACCESS1-skip_school, mv(95 96 97 98 99 999 9999 9999999)
	
////////////////////////////////////////////////////////////////////////////////
	
// 3. Keeping the variables we need | SES, ICT, EP
		
	keep CNTRYID CNT CNTSCHID OECD 									///
		 CNTSTUID gender female age GRADE REPEAT ISCEDO GENERAL 	///
		 IMMIG FISCED MISCED HISCED PARED WEALTH* P_WEALTH INCOME 	///
		 IC002Q01HA IC004Q01HA skip*								///
		 ACCESS* SKILL* EFFIC* RECUSE* SCHUSE*						///
		 REPEAT ESCS ICTHOME ICTSCH HOMEPOS CULTPOSS HEDRES 	 	///
		 ICTRES ENTUSE HOMESCH USESCH INTICT COMPICT AUTICT SOIAICT ///
		 ICTCLASS ICTOUTSIDE CURSUPP ISEI*							///
		 PV*MATH PV*READ PV*SCIE

		 	
////////////////////////////////////////////////////////////////////////////////

// Further clearing based on participation rate (at country & school level)
	
	// COUNTRY
	// A) Q1 - Access to Desktop
		 
		gen ICT_check = ACCESS1
		//recode ICT_check (1=1) (2=1) (3=0) (7=.) (9=.)
		
		gen nmissing= cond(ICT_check!=., 1, 0, 0)

		bys CNTRYID: gen n=sum(nmissing)
		bys CNTRYID: gen proportion_q1= n[_N]/[_N]
		
		tabulate CNTRYID, summarize(proportion_q1)
		
		preserve
		drop if proportion_q1 <= .75
		codebook CNT
		drop if proportion_q1 <= .80
		codebook CNT
		drop if proportion_q1 <= .85
		codebook CNT
		drop if proportion_q1 <= .90
		codebook CNT
		drop if proportion_q1 <= .95
		codebook CNT
		restore
		
		drop ICT_check
		drop nmissing
		drop n
		
// SCHOOL		
// D) Q1 - Access 
	
		gen ICT_check = ACCESS1
		//recode ICT_check (1=1) (2=1) (3=0) (7=.) (9=.)
		
		gen nmissing= cond(ICT_check!=., 1, 0, 0)

		bys CNTSCHID: gen n=sum(nmissing)
		bys CNTSCHID: gen proportion_q4= n[_N]/[_N]
		
		tabulate CNTRYID, summarize(proportion_q4)
		bys CNTRYID: tabulate CNTSCHID if proportion_q4 == 0
		
		by CNTRYID CNTSCHID, sort: generate nvals = _n == 1
		by CNTRYID: count if nvals == 1 & proportion_q4 == 0
		by CNTRYID: tab CNTSCHID if nvals == 1 & proportion_q4 ==0
		tab CNTRYID nval if proportion_q4 ==0
		
		// where 1 indicates FIRST case in each school, 0 indicates the rest
		// of the cases but still participation in the school
		// ie: 49 (1) means 49 schools DID NOT participate, 799(0) means these are the
		// 799 students in those 49 schools.
		
		bys CNTRYID: gen nSCHOOL = sum(nval)
		bys CNTRYID: replace nSCHOOL = nSCHOOL[_N]
		
		bys CNTRYID: gen nnonpart = sum(nvals==1 & proportion_q4==0)
		bys CNTRYID: replace nnonpart = nnonpart[_N]
		
		bys CNTRYID: gen school_part = (nSCHOOL-nnonpart)/nSCHOOL
		
		drop ICT_check
		drop nmissing
		drop n
		drop nval

		 	
////////////////////////////////////////////////////////////////////////////////

		
	save P1_PISA2018.dta, replace
	
	// - eof - 
	
