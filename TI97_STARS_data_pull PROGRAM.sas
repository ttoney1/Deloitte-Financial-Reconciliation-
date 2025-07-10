DM 'CLEAR LOG';

/********************************************************************************************/
/*  CLIENT NAME:	NAVY FINANCIAL MANAGEMENT OPERATIONS 		   							*/
/*					DEPARTMENT OF THE NAVY (DoN), DEPARTMENT OF DEFENSE (DoD)				*/
/*																							*/
/*  PROJECT:	  	NAVY FINANCIAL MANAGEMENT OPERATIONS (FMO-4)					 		*/
/*   																						*/
/*  PROGRAM NAME:   TI97_STARS_data_pull.sas						  						*/
/*																							*/
/*  PURPOSE:		THE PURPOSE OF THIS PROGRAM IS TO PULL ALL QUARTERS OF FY12 STARS_FL DATA
					AND APPLY SPECIFIED LOGIC
/*																				  			*/
/********************************************************************************************/
/*  PROGRAMMER: 	TARAESA TONEY					DATE:	2013.05.03							*/
/********************************************************************************************/
/*  MODIFIED: 					    DATE:   						*/
/*	CHANGES MADE:	ADDED CODE FOR ROOT CAUSE ANALYSIS										*/
/*  MODIFIED: 					    DATE:   						*/
/*	CHANGES MADE:	MODIFIED TO APPLY TO SPS												*/
/*  MODIFIED: 						    DATE:   							*/
/*	CHANGES MADE:	MODIFIED TO INCLUDE LINKING TO DOCUMENT NUMBER							*/
/********************************************************************************************/
/*  RUN TIME: 		APPROX 1 HOUR															*/
/********************************************************************************************/

%LET DATE = %SYSFUNC(TODAY(),YYMMDDN8.); 
%LET LOG_NAME = TI97_STARS_data_pull;
%LET LOG_PATH = H:\navy_fmo\Audit Readiness\SEGMENTS\AD HOC\FY12\ALL\SAS Codes and Logs;
%LET OUTPATH = H:\navy_fmo\Audit Readiness\SEGMENTS\AD HOC\FY12\ALL\Outputs\Output_&date..xls;

LIBNAME FL_OCT 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q1 FY12 NEW\SAS Datasets';
LIBNAME FL_NOV 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q1 FY12 NEW\SAS Datasets';
LIBNAME FL_DEC 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q1 FY12 NEW\SAS Datasets';
LIBNAME FL_Q2 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q2 FY12 NEW\SAS Datasets';
LIBNAME FL_APR 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q3 FY12 NEW\SAS Datasets';
LIBNAME FL_MAY 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q3 FY12 NEW\SAS Datasets';
LIBNAME FL_JUN 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q3 FY12 NEW\SAS Datasets';
LIBNAME FL_Q4 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY12\Q4_FY12\SAS Datasets';

*datasets to use
fl_oct
fl_nov
q2_fy12
fl_apr
fl_may
fl_jun
fl_q4fy12_adj


/********************************************************************************************/
/* MACRO TO SUMMARIZE DATASET AND PROVIDE CONTROL TOTALS.									*/
/********************************************************************************************/
%MACRO CONTROL_TOTALS(DSN, VAR_LIST);
                PROC SUMMARY DATA=&DSN. NWAY MISSING;
                        VAR &VAR_LIST.;
                        OUTPUT OUT=SUMM SUM=;
                RUN;
                %LET CNT = %EVAL(%SYSFUNC(LENGTH(%SYSFUNC(COMPBL("&VAR_LIST."))))-%SYSFUNC(LENGTH(%SYSFUNC(COMPRESS("&VAR_LIST."))))+1);
                %PUT "COUNT OF VARIABLES: &CNT.";
                DATA _NULL_;
                        SET SUMM;
                        FORMAT _FREQ_ COMMA20.;
                        FORMAT &VAR_LIST. COMMA30.2;
                        PUT @3 '----------------------------------------------------'/;
                        PUT @5 "CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN &DSN."/;
                        PUT @10 'TOTAL NUMBER OF RECORDS = ' _FREQ_/;
                        %DO I = 1 %TO &CNT.;
                                %LET VAR = %SCAN(&VAR_LIST.,&I.);
                                PUT @10 "TOTAL OF &VAR. = " &VAR./;
                        %END;
                        PUT @3 '----------------------------------------------------'/;
                RUN;
%MEND;
/********************************************************************************************/ 
/* MACROS TO EXPORT A DATASET.                                                                                                                          */ 
/********************************************************************************************/
%MACRO EXPORT_XLS(DATASET);     
        PROC EXPORT DATA = &DATASET. DBMS = EXCEL 
                FILE = "&OUTPATH." REPLACE;
				SHEET = "&DATASET."; 
        RUN; 
%MEND;

*%CONTROL_TOTALS(FL_OCT.FL_OCT,AMOUNT_USSGL_FINAL);
/*UTILIZE THE STARS-FL OCT, NOV &DEC FY12 POPULATION AND LIMIT TO TRANSACTIONS TO CERTAIN LOGIC*/

DATA FL_Q1; 
	SET FL_OCT.FL_OCT FL_NOV.FL_NOV FL_DEC.FL_DEC;
where APN_SYM='0100' and
	APN_BEG_FIS_YR='07' and
	GA='97' and
	SUBSTR(APN_SBH,1,3)in ('38S' '22S');
RUN;


/*UTILIZE THE STARS-FL Q2 FY12 POPULATION AND LIMIT TO TRANSACTIONS TO CERTAIN LOGIC*/

DATA FL_Q2; 
	SET FL_Q2.q2_fy12;
where APN_SYM='0100'and
	APN_BEG_FIS_YR='07' and
	GA='97' and
	SUBSTR(APN_SBH,1,3)in ('38S' '22S');
RUN;


/*UTILIZE THE STARS-FL APR, MAY & JUN FY12 POPULATION AND LIMIT TO TRANSACTIONS TO CERTAIN LOGIC*/

DATA FL_Q3; 
	SET FL_APR.FL_APR FL_MAY.FL_MAY FL_JUN.FL_JUN;
where APN_SYM='0100' and
	APN_BEG_FIS_YR='07' and
	GA='97' and
	SUBSTR(APN_SBH,1,3)in ('38S' '22S');
RUN;



/*UTILIZE THE STARS-FL Q4 FY12 POPULATION AND LIMIT TO TRANSACTIONS TO CERTAIN LOGIC*/

DATA FL_Q4; 
	SET FL_Q4.fl_q4fy12_adj;
where APN_SYM='0100'and
	APN_BEG_FIS_YR='07' and
	GA='97' and
	SUBSTR(APN_SBH,1,3)in ('38S' '22S');
RUN;

/******************************************************************************************** /*                                      
					 EXPORTS                                            */
/********************************************************************************************/

%EXPORT_XLS(FL_Q1);
%EXPORT_XLS(FL_Q2);
%EXPORT_XLS(FL_Q3);
%EXPORT_XLS(FL_Q4);


/********************************************************************************************/
 /*                                       END OF PROGRAM                                     */
 /********************************************************************************************/
  DM "LOG; FILE 'H:\navy_fmo\Audit Readiness\SEGMENTS\AD HOC\FY12\ALL\SAS Codes and Logs\TI97_STARS_data_pull_&DATE..LOG' REPLACE";

