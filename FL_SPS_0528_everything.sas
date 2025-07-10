1    DM 'CLEAR LOG';
2
3    /*********************************************************************************
3  ! ***********/
4    /*  CLIENT NAME:    NAVY FINANCIAL MANAGEMENT OPERATIONS
4  !           */
5    /*                  DEPARTMENT OF THE NAVY (DoN), DEPARTMENT OF DEFENSE (DoD)
5  !           */
6    /*
6  !           */
7    /*  PROJECT:        NAVY FINANCIAL MANAGEMENT OPERATIONS (FMO-4)
7  !           */
8    /*
8  !           */
9    /*  PROGRAM NAME:   comfisc Reconciliation.sas
9  !           */
10   /*
10 !           */
11   /*  PURPOSE:        THE PURPOSE OF THIS PROGRAM IS TO TRACE THE JAN&FEB FY13
11 ! comfisc            */
12   /*                  CVP FEEDER SYSTEM TRANSACTIONS TO STARS_FL
12 !           */
13   /*
13 !           */
14   /*********************************************************************************
14 ! ***********/
15   /*  PROGRAMMER:     PAUL SEEL                   
15 !           */
16   /*********************************************************************************
16 ! ***********/
17   /*  MODIFIED:       JACOB CAREY                 
17 !           */
18   /*  CHANGES MADE:   ADDED CODE FOR ROOT CAUSE ANALYSIS
18 !           */
19   /*  MODIFIED:       TARAESA TONEY               
19 !           */
20   /*  CHANGES MADE:   MODIFIED TO APPLY TO SPS
20 !           */
21   /*  MODIFIED:       PAUL SEEL                   
21 !           */
22   /*  CHANGES MADE:   MODIFIED TO INCLUDE LINKING TO DOCUMENT NUMBER
22 !           */
23   /*********************************************************************************
23 ! ***********/
24   /*  RUN TIME:       APPROX 1 HOUR
24 !           */
25   /*********************************************************************************
25 ! ***********/
26
27   %LET DATE = %SYSFUNC(TODAY(),YYMMDDN8.);
28   %LET LOG_NAME = FL_comfisc_RECONCILIATION;
29   %LET LOG_PATH = H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
29 ! Reconciliation\SPS\COMFISC\SAS Codes and Logs;
30   %LET OUTPATH = H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
30 ! Reconciliation\SPS\COMFISC\Outputs\Output_&date..xls;
31
32   LIBNAME FL_DEC 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\DEC\SAS
32 ! Datasets';
NOTE: Libref FL_DEC was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\DEC\SAS
      Datasets
33   LIBNAME FL_JAN 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\JAN\SAS
33 ! Datasets';
NOTE: Libref FL_JAN was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\JAN\SAS
      Datasets
34   LIBNAME FL_FEB 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\FEB\SAS
34 ! Datasets';
NOTE: Libref FL_FEB was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\FEB\SAS
      Datasets
35   LIBNAME FL_MAR 'H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\MAR\SAS
35 ! Datasets';
NOTE: Libref FL_MAR was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SOURCE DATA\STARS-FL\FY13\MAR\SAS
      Datasets
36
37   LIBNAME comfisc 'H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
37 ! Reconciliation\SPS\COMFISC\SAS Datasets';
NOTE: Libref COMFISC was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
      Reconciliation\SPS\COMFISC\SAS Datasets
38   LIBNAME navsup 'H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
38 ! Reconciliation\SPS\NAVSUP\SAS Datasets';
NOTE: Libref NAVSUP was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
      Reconciliation\SPS\NAVSUP\SAS Datasets
39   LIBNAME MATCH 'H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
39 ! Reconciliation\Matched Data Sets';
NOTE: Libref MATCH was successfully assigned as follows:
      Engine:        V9
      Physical Name: H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
      Reconciliation\Matched Data Sets
40
41   /*********************************************************************************
41 ! ***********/
42   /* MACRO TO SUMMARIZE DATASET AND PROVIDE CONTROL TOTALS.
42 !           */
43   /*********************************************************************************
43 ! ***********/
44   %MACRO CONTROL_TOTALS(DSN, VAR_LIST);
45                   PROC SUMMARY DATA=&DSN. NWAY MISSING;
46                           VAR &VAR_LIST.;
47                           OUTPUT OUT=SUMM SUM=;
48                   RUN;
49                   %LET CNT =
49 ! %EVAL(%SYSFUNC(LENGTH(%SYSFUNC(COMPBL("&VAR_LIST."))))-%SYSFUNC(LENGTH(%SYSFUNC(CO
49 ! MPRESS("&VAR_LIST."))))+1);
50                   %PUT "COUNT OF VARIABLES: &CNT.";
51                   DATA _NULL_;
52                           SET SUMM;
53                           FORMAT _FREQ_ COMMA20.;
54                           FORMAT &VAR_LIST. COMMA30.2;
55                           PUT @3
55 ! '----------------------------------------------------'/;
56                           PUT @5 "CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN
56 ! &DSN."/;
57                           PUT @10 'TOTAL NUMBER OF RECORDS = ' _FREQ_/;
58                           %DO I = 1 %TO &CNT.;
59                                   %LET VAR = %SCAN(&VAR_LIST.,&I.);
60                                   PUT @10 "TOTAL OF &VAR. = " &VAR./;
61                           %END;
62                           PUT @3
62 ! '----------------------------------------------------'/;
63                   RUN;
64   %MEND;
65   /*********************************************************************************
65 ! ***********/
66   /* MACROS TO EXPORT A DATASET.
66 !                                                                       */
67   /*********************************************************************************
67 ! ***********/
68   %MACRO EXPORT_XLS(DATASET);
69           PROC EXPORT DATA = &DATASET. DBMS = EXCEL
70                   FILE = "&OUTPATH." REPLACE;
71                   SHEET = "&DATASET.";
72           RUN;
73   %MEND;
74
75   *%CONTROL_TOTALS(FL_JAN.FL_FY13_JAN,AMOUNT_USSGL_FINAL);
76   /*UTILIZE THE STARS-FL JAN&FEB FY13 POPULATION AND LIMIT TO TRANSACTIONS TO
76 ! CERTAIN GL4'S BASED ON CFMS EXECUTION CODES*/
77
78   DATA FL_RECON;
79       SET FL_JAN.FL_FY13_JAN FL_FEB.FL_FY13_FEB;
80   where APN_BEG_FIS_YR IN ('13')and
81       SUBSTR(GL4,1,1)='4' and
82       GA='17';
83
84   RUN;

NOTE: There were 7569388 observations read from the data set FL_JAN.FL_FY13_JAN.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1)='4') and (GA='17');
NOTE: There were 7844462 observations read from the data set FL_FEB.FL_FY13_FEB.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1)='4') and (GA='17');
NOTE: The data set WORK.FL_RECON has 15413850 observations and 123 variables.
NOTE: DATA statement used (Total process time):
      real time           11:49.66
      cpu time            4:12.93


85
86   DATA FL_RECON_DEC;
87       SET FL_DEC.FL_FY13_DEC;
88       where APN_BEG_FIS_YR IN ('13') and
89       SUBSTR(GL4,1,1)='4'
90       and GA='17';
91   RUN;

NOTE: There were 6826264 observations read from the data set FL_DEC.FL_FY13_DEC.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1)='4') and (GA='17');
NOTE: The data set WORK.FL_RECON_DEC has 6826264 observations and 123 variables.
NOTE: DATA statement used (Total process time):
      real time           4:15.31
      cpu time            1:34.40


92
93   /*SORT AND INDEX THE FL DATA*/
94   PROC SORT DATA =fl_recon;
95       BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
96   RUN;

NOTE: There were 15413850 observations read from the data set WORK.FL_RECON.
NOTE: The data set WORK.FL_RECON has 15413850 observations and 123 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           12:55.06
      cpu time            4:42.64


97
98   DATA FL_RECON_INDEX;
99       SET FL_RECON;
100
101      INDEX + 1;
102      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
103      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
103! THEN INDEX = 1;
104      fl_gl=gl4;
105  RUN;

NOTE: There were 15413850 observations read from the data set WORK.FL_RECON.
NOTE: The data set WORK.FL_RECON_INDEX has 15413850 observations and 125 variables.
NOTE: DATA statement used (Total process time):
      real time           4:47.76
      cpu time            1:53.81


106
107  DATA SPS_IN_SCOPE SPS_OUT_OF_SCOPE;
108      SET comfisc.comfisc_all (RENAME=(BASIC_PIIN=PIIN)) navsup.nav_all
108! (RENAME=(BASIC_PIIN=PIIN));
109      AMOUNT_USSGL_FINAL=Final_Net_Amt2;
110      where GA='17';
111      IF AMOUNT_USSGL_FINAL NE . THEN ABS_AMT=abs(Final_Net_Amt2);
112      IF LEDGER ^='FL' or FY NE '3' THEN OUTPUT SPS_OUT_OF_SCOPE;
113      ELSE OUTPUT SPS_IN_SCOPE;
114  RUN;

NOTE: There were 7129 observations read from the data set COMFISC.COMFISC_ALL.
      WHERE GA='17';
NOTE: There were 4795 observations read from the data set NAVSUP.NAV_ALL.
      WHERE GA='17';
NOTE: The data set WORK.SPS_IN_SCOPE has 9987 observations and 75 variables.
NOTE: The data set WORK.SPS_OUT_OF_SCOPE has 1937 observations and 75 variables.
NOTE: DATA statement used (Total process time):
      real time           0.61 seconds
      cpu time            0.07 seconds


115
116  /*SORT AND INDEX CFMS TRANSACTIONS THAT HAVE A DOCUMENT NUMBER*/
117  PROC SORT DATA = SPS_IN_SCOPE;
118      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
119  RUN;

NOTE: There were 9987 observations read from the data set WORK.SPS_IN_SCOPE.
NOTE: The data set WORK.SPS_IN_SCOPE has 9987 observations and 75 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.07 seconds
      cpu time            0.06 seconds


120
121  DATA SPS_INDEX;
122      SET SPS_IN_SCOPE;
123
124      INDEX + 1;
125      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
126      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
126! THEN INDEX = 1;
127
128  RUN;

NOTE: There were 9987 observations read from the data set WORK.SPS_IN_SCOPE.
NOTE: The data set WORK.SPS_INDEX has 9987 observations and 76 variables.
NOTE: DATA statement used (Total process time):
      real time           0.06 seconds
      cpu time            0.04 seconds


129
130  *Sort SPS dataset;
131  PROC SORT DATA = SPS_INDEX;
132      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
133  RUN;

NOTE: There were 9987 observations read from the data set WORK.SPS_INDEX.
NOTE: The data set WORK.SPS_INDEX has 9987 observations and 76 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.09 seconds
      cpu time            0.06 seconds


134
135  DATA FL_AND_SPS
136       FL_ONLY
137       SPS_ONLY;
138
139      MERGE FL_RECON_INDEX (IN = A)
140            SPS_INDEX (IN = B); *keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
140! ABS_AMT DOCUMENT_NR);
141
142      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
143
144      IF A AND B THEN OUTPUT FL_AND_SPS;
145      IF A AND NOT B THEN OUTPUT FL_ONLY;
146      IF B AND NOT A THEN OUTPUT SPS_ONLY;
147  RUN;

NOTE: There were 15413850 observations read from the data set WORK.FL_RECON_INDEX.
NOTE: There were 9987 observations read from the data set WORK.SPS_INDEX.
NOTE: The data set WORK.FL_AND_SPS has 6833 observations and 194 variables.
NOTE: The data set WORK.FL_ONLY has 15407017 observations and 194 variables.
NOTE: The data set WORK.SPS_ONLY has 3154 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           8:30.03
      cpu time            4:31.79


148  %CONTROL_TOTALS(FL_AND_SPS_doc,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.06 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable _FREQ_ is uninitialized.
NOTE: Variable AMOUNT_USSGL_FINAL is uninitialized.
NOTE: Variable ABS_AMT is uninitialized.
NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.01 seconds


149  %CONTROL_TOTALS(SPS_ONLY_doc,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable _FREQ_ is uninitialized.
NOTE: Variable AMOUNT_USSGL_FINAL is uninitialized.
NOTE: Variable ABS_AMT is uninitialized.
NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


150
151  /****DELETE TABLES USE DIN MERGE*/
152  proc datasets;
                                       Directory

                               Libref         WORK
                               Engine         V9
                               Physical Name  F:\_TD9956
                               File Name      F:\_TD9956
                             Member
        #  Name              Type         File Size  Last Modified

        1  FL_AND_SPS        DATA          11224064  28May13:12:21:06
        2  FL_ONLY           DATA       25242878976  28May13:12:21:06
        3  FL_RECON          DATA        9353380864  28May13:12:07:42
        4  FL_RECON_DEC      DATA        4142302208  28May13:11:54:52
        5  FL_RECON_INDEX    DATA        9713124352  28May13:12:12:35
        6  PROFILE           CATALOG           5120  28May13:09:01:47
        7  REGSTRY           ITEMSTOR         13312  28May13:09:01:47
        8  SASMACR           CATALOG           5120  28May13:11:38:47
        9  SPS_INDEX         DATA           9651200  28May13:12:12:36
       10  SPS_IN_SCOPE      DATA           9634816  28May13:12:12:35
       11  SPS_ONLY          DATA           5194752  28May13:12:21:06
       12  SPS_OUT_OF_SCOPE  DATA           1885184  28May13:12:12:35
       13  SUMM              DATA              5120  28May13:12:21:06
153  delete  FL_RECON
154          FL_RECON_INDEX
155          SPS_IN_SCOPE
156          SPS_OUT_OF_SCOPE
157          SPS_INDEX;
158  quit;

NOTE: Deleting WORK.FL_RECON (memtype=DATA).
NOTE: Deleting WORK.FL_RECON_INDEX (memtype=DATA).
NOTE: Deleting WORK.SPS_IN_SCOPE (memtype=DATA).
NOTE: Deleting WORK.SPS_OUT_OF_SCOPE (memtype=DATA).
NOTE: Deleting WORK.SPS_INDEX (memtype=DATA).
NOTE: PROCEDURE DATASETS used (Total process time):
      real time           2.90 seconds
      cpu time            0.92 seconds


159
160  /***Query Dec data***/
161  PROC SORT DATA =FL_RECON_DEC;
162      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
163  RUN;

NOTE: There were 6826264 observations read from the data set WORK.FL_RECON_DEC.
NOTE: The data set WORK.FL_RECON_DEC has 6826264 observations and 123 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           4:23.34
      cpu time            1:31.54


164
165  DATA FL_RECON_INDEX2;
166      SET FL_RECON_DEC;
167
168      INDEX + 1;
169      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
170      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
170! THEN INDEX = 1;
171      fl_gl=gl4;
172  RUN;

NOTE: There were 6826264 observations read from the data set WORK.FL_RECON_DEC.
NOTE: The data set WORK.FL_RECON_INDEX2 has 6826264 observations and 125 variables.
NOTE: DATA statement used (Total process time):
      real time           2:00.46
      cpu time            39.49 seconds


173
174  DATA SPS_INDEX2;
175      SET SPS_ONLY(drop=index);
176
177      INDEX + 1;
178      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
179      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
179! THEN INDEX = 1;
180
181  RUN;

NOTE: There were 3154 observations read from the data set WORK.SPS_ONLY.
NOTE: The data set WORK.SPS_INDEX2 has 3154 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           0.26 seconds
      cpu time            0.00 seconds


182
183  DATA FL_AND_SPS2
184       FL_ONLY2
185       SPS_ONLY2;
186
187      MERGE FL_RECON_INDEX2 (IN = A)
188            SPS_INDEX2 (IN = B keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
188! SUPPLMTRY_PIIN TOTAL_AMT_OF_CONT ADMIN_CONT_FOR_RESP
189            PAYING_OFFICE CONTRACT_TYPE_CODE VARIANCE_PCT_AUTH PROMPT_PAY_TERMS_CODE
189!  DISCOUNT_TERMS
190            CONTRACT_AWARD_DATE VENDOR_NAME_AND_ADDR COMPLETION_DATE ACCEPTANCE_CODE
190!  CONTRACT_DESCRIPTION
191            CLIN_SUBCLIN DOCUMENT_NR RQN_CUR_LN_NR CLIN_QUANTITY  SUBCLIN_QUANTITY
191! EXTENDED_AMOUNT UNIT_OF_ISSUE
192            SIGNAL_CODE JOB_ORDER_NR COG_SYMBOL FUND_CODE ORIGL_FUND_CODE
192! FUNDING_MODFD_IND ACRN STANDARD_ACCOUNTING
193            COST_CODE FSCM DUNS_NR REMIT_FSCM REMIT_DUNS_NR FIN_UNIT_PRICE
193! CST_PRC_CODE NET_AMOUNT TRADE_DISCT_PCT
194            SERVICE_START_DATE FOB_SITE_CODE INSPECTION_SITE_CODE INSPECTOR_CODE
194! ACCEPTER_CODE INVOICE_TO_UIC
195            ACCTG_FREE_TEXT_LN TRANSPORTATION_ACCOUNT_CODE TRANSPORTATION_AMOUNT
195! FIN_CMDY_CD FIN_SHIP_MODE_CD
196            FIN_RFRNC_ACRN FIN_CNTRCT_MOD_NR FIN_CRNCY_CD FIN_EXCHNG_RT
196! FIN_INT_DBOF_LONG_LINE
197            FIN_INT_DBOF_JOB_ORDER_NR FIN_INT_DBOF_ACNTNG_DCMNT_NR FINAL_NET_AMT
197! FINAL_TOTAL_AMT_OF_CONT
198            FINAL_EXTENDED_AMOUNT FINAL_FIN_UNIT_PRICE FINAL_TRANSPORTATION_AMOUNT
198! FINAL_NET_AMT2 FY OBJ_CLSS BCN
199            SUB AAA TRANS_CODE LEDGER ABS_AMT);
200
201      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
202
203      IF A AND B THEN OUTPUT FL_AND_SPS2;
204      IF A AND NOT B THEN OUTPUT FL_ONLY2;
205      IF B AND NOT A THEN OUTPUT SPS_ONLY2;
206  RUN;

NOTE: There were 6826264 observations read from the data set WORK.FL_RECON_INDEX2.
NOTE: There were 3154 observations read from the data set WORK.SPS_INDEX2.
NOTE: The data set WORK.FL_AND_SPS2 has 188 observations and 194 variables.
NOTE: The data set WORK.FL_ONLY2 has 6826076 observations and 194 variables.
NOTE: The data set WORK.SPS_ONLY2 has 2966 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           3:20.55
      cpu time            1:26.09


207  %CONTROL_TOTALS(FL_AND_SPS2,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 188 observations read from the data set WORK.FL_AND_SPS2.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.06 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS2

         TOTAL NUMBER OF RECORDS = 188

         TOTAL OF AMOUNT_USSGL_FINAL = 2,623,491.31

         TOTAL OF ABS_AMT = 2,623,491.31

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


208  %CONTROL_TOTALS(SPS_ONLY2,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 2966 observations read from the data set WORK.SPS_ONLY2.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_ONLY2

         TOTAL NUMBER OF RECORDS = 2,966

         TOTAL OF AMOUNT_USSGL_FINAL = 10,259,889.92

         TOTAL OF ABS_AMT = 10,259,889.92

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


209
210  /****DELETE TABLES USE DIN MERGE*/
211  PROC DATASETS;
                                       Directory

                               Libref         WORK
                               Engine         V9
                               Physical Name  F:\_TD9956
                               File Name      F:\_TD9956


                            Member
        #  Name             Type         File Size  Last Modified

        1  FL_AND_SPS       DATA          11224064  28May13:12:21:06
        2  FL_AND_SPS2      DATA            345088  28May13:12:30:53
        3  FL_ONLY          DATA       25242878976  28May13:12:21:06
        4  FL_ONLY2         DATA       11183866880  28May13:12:30:53
        5  FL_RECON_DEC     DATA        4142302208  28May13:12:25:31
        6  FL_RECON_INDEX2  DATA        4301620224  28May13:12:27:32
        7  PROFILE          CATALOG           5120  28May13:09:01:47
        8  REGSTRY          ITEMSTOR         13312  28May13:09:01:47
        9  SASMACR          CATALOG           5120  28May13:11:38:47
       10  SPS_INDEX2       DATA           5194752  28May13:12:27:33
       11  SPS_ONLY         DATA           5194752  28May13:12:21:06
       12  SPS_ONLY2        DATA           4883456  28May13:12:30:53
       13  SUMM             DATA              5120  28May13:12:30:53
212  DELETE  FL_RECON_DEC
213          FL_RECON_INDEX2
214          SPS_INDEX2;
215  QUIT;

NOTE: Deleting WORK.FL_RECON_DEC (memtype=DATA).
NOTE: Deleting WORK.FL_RECON_INDEX2 (memtype=DATA).
NOTE: Deleting WORK.SPS_INDEX2 (memtype=DATA).
NOTE: PROCEDURE DATASETS used (Total process time):
      real time           1.34 seconds
      cpu time            0.51 seconds


216
217  /******Use Doc_key in FL and DOCUMENT_NR in SPS from remaining population*****/
218  PROC SORT DATA=SPS_ONLY2;
219  BY DOCUMENT_NR APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
220  RUN;

NOTE: There were 2966 observations read from the data set WORK.SPS_ONLY2.
NOTE: The data set WORK.SPS_ONLY2 has 2966 observations and 194 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.04 seconds
      cpu time            0.03 seconds


221
222  DATA SPS_INDEX3;
223      SET SPS_ONLY2(drop=index rename=(DOCUMENT_NR=doc_num));
224
225      INDEX + 1;
226      BY doc_num APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
227      IF FIRST.doc_num OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
227!  THEN INDEX = 1;
228
229  RUN;

NOTE: There were 2966 observations read from the data set WORK.SPS_ONLY2.
NOTE: The data set WORK.SPS_INDEX3 has 2966 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.01 seconds


230  /*COMBINE THE FL_ONLY POPULATION FROM JAN AND FEB WITH DEC*/
231  DATA FL_ONLY_ALL;
232  SET FL_ONLY
233      FL_ONLY2;
234  RUN;

NOTE: There were 15407017 observations read from the data set WORK.FL_ONLY.
NOTE: There were 6826076 observations read from the data set WORK.FL_ONLY2.
NOTE: The data set WORK.FL_ONLY_ALL has 22233093 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           21:25.30
      cpu time            9:18.70


235  PROC SORT DATA=FL_ONLY_ALL;
236  BY DOC_KEY APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
237  RUN;

NOTE: There were 22233093 observations read from the data set WORK.FL_ONLY_ALL.
NOTE: The data set WORK.FL_ONLY_ALL has 22233093 observations and 194 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           1:25:42.12
      cpu time            24:06.93


238
239  DATA FL_RECON_INDEX_doc;
240      SET FL_ONLY_ALL(drop=index rename=(DOC_key=doc_num));
241
242      INDEX + 1;
243      BY doc_num APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
244      IF FIRST.doc_num OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
244!  THEN INDEX = 1;
245      fl_gl=gl4;
246  RUN;

NOTE: There were 22233093 observations read from the data set WORK.FL_ONLY_ALL.
NOTE: The data set WORK.FL_RECON_INDEX_DOC has 22233093 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           1:15:47.42
      cpu time            13:09.98


247
248  DATA FL_AND_SPS_doc
249       FL_ONLY3
250       SPS_ONLY_doc;
251
252      MERGE FL_RECON_INDEX_doc (IN = A)
253            SPS_INDEX3 (IN = B  keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
253! SUPPLMTRY_PIIN TOTAL_AMT_OF_CONT ADMIN_CONT_FOR_RESP
254            PAYING_OFFICE CONTRACT_TYPE_CODE VARIANCE_PCT_AUTH PROMPT_PAY_TERMS_CODE
254!  DISCOUNT_TERMS
255            CONTRACT_AWARD_DATE VENDOR_NAME_AND_ADDR COMPLETION_DATE ACCEPTANCE_CODE
255!  CONTRACT_DESCRIPTION
256            CLIN_SUBCLIN doc_num RQN_CUR_LN_NR CLIN_QUANTITY  SUBCLIN_QUANTITY
256! EXTENDED_AMOUNT UNIT_OF_ISSUE
257            SIGNAL_CODE JOB_ORDER_NR COG_SYMBOL FUND_CODE ORIGL_FUND_CODE
257! FUNDING_MODFD_IND ACRN STANDARD_ACCOUNTING
258            COST_CODE FSCM DUNS_NR REMIT_FSCM REMIT_DUNS_NR FIN_UNIT_PRICE
258! CST_PRC_CODE NET_AMOUNT TRADE_DISCT_PCT
259            SERVICE_START_DATE FOB_SITE_CODE INSPECTION_SITE_CODE INSPECTOR_CODE
259! ACCEPTER_CODE INVOICE_TO_UIC
260            ACCTG_FREE_TEXT_LN TRANSPORTATION_ACCOUNT_CODE TRANSPORTATION_AMOUNT
260! FIN_CMDY_CD FIN_SHIP_MODE_CD
261            FIN_RFRNC_ACRN FIN_CNTRCT_MOD_NR FIN_CRNCY_CD FIN_EXCHNG_RT
261! FIN_INT_DBOF_LONG_LINE
262            FIN_INT_DBOF_JOB_ORDER_NR FIN_INT_DBOF_ACNTNG_DCMNT_NR FINAL_NET_AMT
262! FINAL_TOTAL_AMT_OF_CONT
263            FINAL_EXTENDED_AMOUNT FINAL_FIN_UNIT_PRICE FINAL_TRANSPORTATION_AMOUNT
263! FINAL_NET_AMT2 FY OBJ_CLSS BCN
264            SUB AAA TRANS_CODE LEDGER ABS_AMT);
265
266      BY doc_num APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
267
268      IF A AND B THEN OUTPUT FL_AND_SPS_doc;
269      IF A AND NOT B THEN OUTPUT FL_ONLY3;
270      IF B AND NOT A THEN OUTPUT SPS_ONLY_doc;
271  RUN;

NOTE: There were 22233093 observations read from the data set WORK.FL_RECON_INDEX_DOC.
NOTE: There were 2966 observations read from the data set WORK.SPS_INDEX3.
NOTE: The data set WORK.FL_AND_SPS_DOC has 41 observations and 194 variables.
NOTE: The data set WORK.FL_ONLY3 has 22233052 observations and 194 variables.
NOTE: The data set WORK.SPS_ONLY_DOC has 2925 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           1:08:26.10
      cpu time            12:49.04


272  %CONTROL_TOTALS(FL_AND_SPS_doc,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 41 observations read from the data set WORK.FL_AND_SPS_DOC.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.31 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS_doc

         TOTAL NUMBER OF RECORDS = 41

         TOTAL OF AMOUNT_USSGL_FINAL = 731,202.92

         TOTAL OF ABS_AMT = 731,202.92

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.01 seconds


273  %CONTROL_TOTALS(SPS_ONLY_doc,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 2925 observations read from the data set WORK.SPS_ONLY_DOC.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           1.18 seconds
      cpu time            0.09 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_ONLY_doc

         TOTAL NUMBER OF RECORDS = 2,925

         TOTAL OF AMOUNT_USSGL_FINAL = 9,528,687.00

         TOTAL OF ABS_AMT = 9,528,687.00

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.06 seconds
      cpu time            0.03 seconds


274
275  /****DELETE TABLES USE DIN MERGE*/
276  PROC DATASETS;
                                       Directory

                               Libref         WORK
                               Engine         V9
                               Physical Name  F:\_TD9956
                               File Name      F:\_TD9956


                              Member
       #  Name                Type         File Size  Last Modified

       1  FL_AND_SPS          DATA          11224064  28May13:12:21:06
       2  FL_AND_SPS2         DATA            345088  28May13:12:30:53
       3  FL_AND_SPS_DOC      DATA             99328  28May13:16:42:16
       4  FL_ONLY             DATA       25242878976  28May13:12:21:06
       5  FL_ONLY2            DATA       11183866880  28May13:12:30:53
       6  FL_ONLY3            DATA       36426662912  28May13:16:42:16
       7  FL_ONLY_ALL         DATA       36426728448  28May13:14:18:00
       8  FL_RECON_INDEX_DOC  DATA       36426728448  28May13:15:33:50
       9  PROFILE             CATALOG           5120  28May13:09:01:47
      10  REGSTRY             ITEMSTOR         13312  28May13:09:01:47
      11  SASMACR             CATALOG           5120  28May13:11:38:47
      12  SPS_INDEX3          DATA           4883456  28May13:12:30:55
      13  SPS_ONLY            DATA           5194752  28May13:12:21:06
      14  SPS_ONLY2           DATA           4883456  28May13:12:30:55
      15  SPS_ONLY_DOC        DATA           4817920  28May13:16:42:16
      16  SUMM                DATA              5120  28May13:16:42:18
277  DELETE  FL_RECON_INDEX_doc
278          SPS_INDEX3
279          FL_ONLY
280          FL_ONLY2;
281  QUIT;

NOTE: Deleting WORK.FL_RECON_INDEX_DOC (memtype=DATA).
NOTE: Deleting WORK.SPS_INDEX3 (memtype=DATA).
NOTE: Deleting WORK.FL_ONLY (memtype=DATA).
NOTE: Deleting WORK.FL_ONLY2 (memtype=DATA).
NOTE: PROCEDURE DATASETS used (Total process time):
      real time           8.48 seconds
      cpu time            4.75 seconds


282
283  /********************************************************************/
284  /****THE REMAINING CODE IS A SERIES OF TESTS TO EXPLAIN VARIANCES****/
285  /********************************************************************/
286
287  /***Query March data***/
288
289  DATA FL_RECON_MAR;
290        SET FL_MAR.fl_fy13_mar;
291        where APN_BEG_FIS_YR IN ('13') and
292        SUBSTR(GL4,1,1)='4'
293        and GA='17';
294  RUN;

NOTE: There were 7940668 observations read from the data set FL_MAR.FL_FY13_MAR.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1)='4') and (GA='17');
NOTE: The data set WORK.FL_RECON_MAR has 7940668 observations and 123 variables.
NOTE: DATA statement used (Total process time):
      real time           4:12.44
      cpu time            1:32.07


295
296    PROC SORT DATA =FL_RECON_MAR;
297        BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
298    RUN;

NOTE: There were 7940668 observations read from the data set WORK.FL_RECON_MAR.
NOTE: The data set WORK.FL_RECON_MAR has 7940668 observations and 123 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           20:55.99
      cpu time            1:32.39


299
300
301  DATA FL_RECON_INDEX3;
302      SET FL_RECON_MAR;
303      INDEX + 1;
304      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
305      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
305! THEN INDEX = 1;
306      fl_gl=gl4;
307  RUN;

NOTE: There were 7940668 observations read from the data set WORK.FL_RECON_MAR.
NOTE: The data set WORK.FL_RECON_INDEX3 has 7940668 observations and 125 variables.
NOTE: DATA statement used (Total process time):
      real time           1:11.35
      cpu time            35.93 seconds


308
309  PROC SORT DATA=SPS_ONLY_doc;
310      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
311  RUN;

NOTE: There were 2925 observations read from the data set WORK.SPS_ONLY_DOC.
NOTE: The data set WORK.SPS_ONLY_DOC has 2925 observations and 194 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           1.06 seconds
      cpu time            0.03 seconds


312
313  DATA SPS_INDEX4;
314      SET SPS_ONLY_doc(drop=index);
315      INDEX + 1;
316      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
317      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
317! THEN INDEX = 1;
318  RUN;

NOTE: There were 2925 observations read from the data set WORK.SPS_ONLY_DOC.
NOTE: The data set WORK.SPS_INDEX4 has 2925 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.03 seconds


319
320
321    DATA FL_AND_SPS4
322         FL_ONLY4
323         SPS_ONLY4;
324
325       MERGE FL_RECON_INDEX3 (IN = A)
326              SPS_INDEX4 (IN = B  keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
326!  SUPPLMTRY_PIIN TOTAL_AMT_OF_CONT ADMIN_CONT_FOR_RESP
327            PAYING_OFFICE CONTRACT_TYPE_CODE VARIANCE_PCT_AUTH PROMPT_PAY_TERMS_CODE
327!  DISCOUNT_TERMS
328            CONTRACT_AWARD_DATE VENDOR_NAME_AND_ADDR COMPLETION_DATE ACCEPTANCE_CODE
328!  CONTRACT_DESCRIPTION
329            CLIN_SUBCLIN DOCUMENT_NR doc_num RQN_CUR_LN_NR CLIN_QUANTITY
329! SUBCLIN_QUANTITY EXTENDED_AMOUNT UNIT_OF_ISSUE
330            SIGNAL_CODE JOB_ORDER_NR COG_SYMBOL FUND_CODE ORIGL_FUND_CODE
330! FUNDING_MODFD_IND ACRN STANDARD_ACCOUNTING
331            COST_CODE FSCM DUNS_NR REMIT_FSCM REMIT_DUNS_NR FIN_UNIT_PRICE
331! CST_PRC_CODE NET_AMOUNT TRADE_DISCT_PCT
332            SERVICE_START_DATE FOB_SITE_CODE INSPECTION_SITE_CODE INSPECTOR_CODE
332! ACCEPTER_CODE INVOICE_TO_UIC
333            ACCTG_FREE_TEXT_LN TRANSPORTATION_ACCOUNT_CODE TRANSPORTATION_AMOUNT
333! FIN_CMDY_CD FIN_SHIP_MODE_CD
334            FIN_RFRNC_ACRN FIN_CNTRCT_MOD_NR FIN_CRNCY_CD FIN_EXCHNG_RT
334! FIN_INT_DBOF_LONG_LINE
335            FIN_INT_DBOF_JOB_ORDER_NR FIN_INT_DBOF_ACNTNG_DCMNT_NR FINAL_NET_AMT
335! FINAL_TOTAL_AMT_OF_CONT
336            FINAL_EXTENDED_AMOUNT FINAL_FIN_UNIT_PRICE FINAL_TRANSPORTATION_AMOUNT
336! FINAL_NET_AMT2 FY OBJ_CLSS BCN
337            SUB AAA TRANS_CODE LEDGER ABS_AMT);
338
339       BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
340
341        IF A AND B THEN OUTPUT FL_AND_SPS4;
342        IF A AND NOT B THEN OUTPUT FL_ONLY4;
343        IF B AND NOT A THEN OUTPUT SPS_ONLY4;
344    RUN;

NOTE: There were 7940668 observations read from the data set WORK.FL_RECON_INDEX3.
NOTE: There were 2925 observations read from the data set WORK.SPS_INDEX4.
NOTE: The data set WORK.FL_AND_SPS4 has 53 observations and 195 variables.
NOTE: The data set WORK.FL_ONLY4 has 7940615 observations and 195 variables.
NOTE: The data set WORK.SPS_ONLY4 has 2872 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           3:42.05
      cpu time            1:15.93


345  %CONTROL_TOTALS(FL_AND_SPS4,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 53 observations read from the data set WORK.FL_AND_SPS4.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.09 seconds
      cpu time            0.01 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS4

         TOTAL NUMBER OF RECORDS = 53

         TOTAL OF AMOUNT_USSGL_FINAL = 508,789.49

         TOTAL OF ABS_AMT = 508,789.49

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


346  %CONTROL_TOTALS(SPS_ONLY4,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 2872 observations read from the data set WORK.SPS_ONLY4.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_ONLY4

         TOTAL NUMBER OF RECORDS = 2,872

         TOTAL OF AMOUNT_USSGL_FINAL = 9,019,897.51

         TOTAL OF ABS_AMT = 9,019,897.51

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


347  /****DELETE TABLES USE DIN MERGE*/
348  PROC DATASETS;
                                       Directory

                               Libref         WORK
                               Engine         V9
                               Physical Name  F:\_TD9956
                               File Name      F:\_TD9956


                            Member
        #  Name             Type         File Size  Last Modified

        1  FL_AND_SPS       DATA          11224064  28May13:12:21:06
        2  FL_AND_SPS2      DATA            345088  28May13:12:30:53
        3  FL_AND_SPS4      DATA            115712  28May13:17:12:29
        4  FL_AND_SPS_DOC   DATA             99328  28May13:16:42:16
        5  FL_ONLY3         DATA       36426662912  28May13:16:42:16
        6  FL_ONLY4         DATA       13009929216  28May13:17:12:29
        7  FL_ONLY_ALL      DATA       36426728448  28May13:14:18:00
        8  FL_RECON_INDEX3  DATA        5003871232  28May13:17:08:46
        9  FL_RECON_MAR     DATA        4818535424  28May13:17:07:34
       10  PROFILE          CATALOG           5120  28May13:09:01:47
       11  REGSTRY          ITEMSTOR         13312  28May13:09:01:47
       12  SASMACR          CATALOG           5120  28May13:11:38:47
       13  SPS_INDEX4       DATA           4817920  28May13:17:08:47
       14  SPS_ONLY         DATA           5194752  28May13:12:21:06
       15  SPS_ONLY2        DATA           4883456  28May13:12:30:55
       16  SPS_ONLY4        DATA           4736000  28May13:17:12:29
       17  SPS_ONLY_DOC     DATA           4817920  28May13:17:08:47
       18  SUMM             DATA              5120  28May13:17:12:30
349  DELETE  FL_RECON_INDEX3
350          SPS_INDEX4;
351  QUIT;

NOTE: Deleting WORK.FL_RECON_INDEX3 (memtype=DATA).
NOTE: Deleting WORK.SPS_INDEX4 (memtype=DATA).
NOTE: PROCEDURE DATASETS used (Total process time):
      real time           0.81 seconds
      cpu time            0.39 seconds


352
353  /******Prepare data for merge between remaining non-matches and NON-BUDGETARY FL
353! data for all 4 months*****/
354
355  DATA FL_NON_BUD;
356      SET FL_JAN.FL_FY13_JAN FL_FEB.FL_FY13_FEB FL_DEC.FL_FY13_DEC
356! FL_MAR.fl_fy13_mar;
357      where APN_BEG_FIS_YR IN ('13') and
358      SUBSTR(GL4,1,1) NE '4'
359      and GA='17';
360  RUN;

NOTE: There were 12393788 observations read from the data set FL_JAN.FL_FY13_JAN.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1) not = '4') and (GA='17');
NOTE: There were 12921672 observations read from the data set FL_FEB.FL_FY13_FEB.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1) not = '4') and (GA='17');
NOTE: There were 11089951 observations read from the data set FL_DEC.FL_FY13_DEC.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1) not = '4') and (GA='17');
NOTE: There were 13220263 observations read from the data set FL_MAR.FL_FY13_MAR.
      WHERE (APN_BEG_FIS_YR='13') and (SUBSTR(GL4, 1, 1) not = '4') and (GA='17');
NOTE: The data set WORK.FL_NON_BUD has 49625674 observations and 123 variables.
NOTE: DATA statement used (Total process time):
      real time           17:11.25
      cpu time            8:30.01


361
362  /*SORT AND INDEX THE FL DATA*/
363  PROC SORT DATA =FL_NON_BUD;
364      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
365  RUN;

NOTE: There were 49625674 observations read from the data set WORK.FL_NON_BUD.
NOTE: The data set WORK.FL_NON_BUD has 49625674 observations and 123 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           29:58.03
      cpu time            17:18.75


366
367  DATA FL_RECON_INDEX;
368      SET FL_NON_BUD;
369
370      INDEX + 1;
371      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
372      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
372! THEN INDEX = 1;
373      fl_gl=gl4;
374  RUN;

NOTE: There were 49625674 observations read from the data set WORK.FL_NON_BUD.
NOTE: The data set WORK.FL_RECON_INDEX has 49625674 observations and 125 variables.
NOTE: DATA statement used (Total process time):
      real time           14:57.07
      cpu time            8:11.62


375
376  PROC SORT DATA=SPS_ONLY4;
377      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
378  RUN;

NOTE: There were 2872 observations read from the data set WORK.SPS_ONLY4.
NOTE: The data set WORK.SPS_ONLY4 has 2872 observations and 195 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.54 seconds
      cpu time            0.25 seconds


379
380  DATA SPS_INDEX5;
381      SET SPS_ONLY4(drop=index);
382      INDEX + 1;
383      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
384      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
384! THEN INDEX = 1;
385  RUN;

NOTE: There were 2872 observations read from the data set WORK.SPS_ONLY4.
NOTE: The data set WORK.SPS_INDEX5 has 2872 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


386
387
388
389    DATA FL_AND_SPS5
390         FL_ONLY5
391         SPS_ONLY5;
392
393       MERGE FL_RECON_INDEX (IN = A)
394              SPS_INDEX5 (IN = B  keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
394!  SUPPLMTRY_PIIN TOTAL_AMT_OF_CONT ADMIN_CONT_FOR_RESP
395            PAYING_OFFICE CONTRACT_TYPE_CODE VARIANCE_PCT_AUTH PROMPT_PAY_TERMS_CODE
395!  DISCOUNT_TERMS
396            CONTRACT_AWARD_DATE VENDOR_NAME_AND_ADDR COMPLETION_DATE ACCEPTANCE_CODE
396!  CONTRACT_DESCRIPTION
397            CLIN_SUBCLIN DOCUMENT_NR doc_num RQN_CUR_LN_NR CLIN_QUANTITY
397! SUBCLIN_QUANTITY EXTENDED_AMOUNT UNIT_OF_ISSUE
398            SIGNAL_CODE JOB_ORDER_NR COG_SYMBOL FUND_CODE ORIGL_FUND_CODE
398! FUNDING_MODFD_IND ACRN STANDARD_ACCOUNTING
399            COST_CODE FSCM DUNS_NR REMIT_FSCM REMIT_DUNS_NR FIN_UNIT_PRICE
399! CST_PRC_CODE NET_AMOUNT TRADE_DISCT_PCT
400            SERVICE_START_DATE FOB_SITE_CODE INSPECTION_SITE_CODE INSPECTOR_CODE
400! ACCEPTER_CODE INVOICE_TO_UIC
401            ACCTG_FREE_TEXT_LN TRANSPORTATION_ACCOUNT_CODE TRANSPORTATION_AMOUNT
401! FIN_CMDY_CD FIN_SHIP_MODE_CD
402            FIN_RFRNC_ACRN FIN_CNTRCT_MOD_NR FIN_CRNCY_CD FIN_EXCHNG_RT
402! FIN_INT_DBOF_LONG_LINE
403            FIN_INT_DBOF_JOB_ORDER_NR FIN_INT_DBOF_ACNTNG_DCMNT_NR FINAL_NET_AMT
403! FINAL_TOTAL_AMT_OF_CONT
404            FINAL_EXTENDED_AMOUNT FINAL_FIN_UNIT_PRICE FINAL_TRANSPORTATION_AMOUNT
404! FINAL_NET_AMT2 FY OBJ_CLSS BCN
405            SUB AAA TRANS_CODE LEDGER ABS_AMT);
406
407       BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
408
409        IF A AND B THEN OUTPUT FL_AND_SPS5;
410        IF A AND NOT B THEN OUTPUT FL_ONLY5;
411        IF B AND NOT A THEN OUTPUT SPS_ONLY5;
412    RUN;

NOTE: There were 49625674 observations read from the data set WORK.FL_RECON_INDEX.
NOTE: There were 2872 observations read from the data set WORK.SPS_INDEX5.
NOTE: The data set WORK.FL_AND_SPS5 has 115 observations and 195 variables.
NOTE: The data set WORK.FL_ONLY5 has 49625559 observations and 195 variables.
NOTE: The data set WORK.SPS_ONLY5 has 2757 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           52:10.10
      cpu time            43:42.18


413  %CONTROL_TOTALS(FL_AND_SPS5,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 115 observations read from the data set WORK.FL_AND_SPS5.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.09 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS5

         TOTAL NUMBER OF RECORDS = 115

         TOTAL OF AMOUNT_USSGL_FINAL = 222,714.42

         TOTAL OF ABS_AMT = 222,714.42

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


414  %CONTROL_TOTALS(SPS_ONLY5,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 2757 observations read from the data set WORK.SPS_ONLY5.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_ONLY5

         TOTAL NUMBER OF RECORDS = 2,757

         TOTAL OF AMOUNT_USSGL_FINAL = 8,797,183.09

         TOTAL OF ABS_AMT = 8,797,183.09

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


415
416  /******Prepare data for merge between remaining non-matches summarized by
416! AMOUNT_USSGL_FINAL and FL data for all 4 months*****/
417  /*COMBINE THE FL_ONLY POPULATION FROM JAN AND FEB WITH DEC*/
418  DATA FL_ONLY_4MNTHS;
419  SET FL_ONLY_ALL
420      FL_ONLY4;
421  RUN;

NOTE: There were 22233093 observations read from the data set WORK.FL_ONLY_ALL.
NOTE: There were 7940615 observations read from the data set WORK.FL_ONLY4.
NOTE: The data set WORK.FL_ONLY_4MNTHS has 30173708 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           53:17.50
      cpu time            15:02.14


422
423  PROC SORT DATA =FL_ONLY_4MNTHS;
424    BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
425  RUN;

NOTE: There were 30173708 observations read from the data set WORK.FL_ONLY_4MNTHS.
NOTE: The data set WORK.FL_ONLY_4MNTHS has 30173708 observations and 195 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           1:03:49.24
      cpu time            36:30.51


426
427  DATA FL_RECON_INDEX4;
428      SET FL_ONLY_4MNTHS;
429      INDEX + 1;
430      BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
431      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
431! THEN INDEX = 1;
432      fl_gl=gl4;
433  RUN;

NOTE: There were 30173708 observations read from the data set WORK.FL_ONLY_4MNTHS.
NOTE: The data set WORK.FL_RECON_INDEX4 has 30173708 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           1:05:01.11
      cpu time            19:20.01


434    *Summarize by AMOUNT_USSGL_FINAL;
435    PROC SUMMARY DATA = SPS_ONLY5 NWAY MISSING;
436        CLASS PIIN APN_SBH APN_SYM;
437        VAR AMOUNT_USSGL_FINAL;
438        OUTPUT OUT = SPS_ONLY5_SUM (DROP=_TYPE_) SUM=;
439    RUN;

NOTE: There were 2757 observations read from the data set WORK.SPS_ONLY5.
NOTE: The data set WORK.SPS_ONLY5_SUM has 287 observations and 5 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.48 seconds
      cpu time            0.09 seconds


440
441
442    DATA SPS_INDEX6;
443        SET SPS_ONLY5_SUM /*(drop=index);*/
444        INDEX + 1;
445        BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL;
446      IF FIRST.PIIN OR FIRST.APN_SBH OR FIRST.APN_SYM OR FIRST.AMOUNT_USSGL_FINAL
446! THEN INDEX = 1;
447  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.00 seconds


448
449
450    DATA FL_AND_SPS6
451         FL_ONLY6
452         SPS_ONLY6;
453
454       MERGE FL_RECON_INDEX4 (IN = A)
455              SPS_INDEX6 (IN = B  keep=PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX
455!  SUPPLMTRY_PIIN TOTAL_AMT_OF_CONT ADMIN_CONT_FOR_RESP
456            PAYING_OFFICE CONTRACT_TYPE_CODE VARIANCE_PCT_AUTH PROMPT_PAY_TERMS_CODE
456!  DISCOUNT_TERMS
457            CONTRACT_AWARD_DATE VENDOR_NAME_AND_ADDR COMPLETION_DATE ACCEPTANCE_CODE
457!  CONTRACT_DESCRIPTION
458            CLIN_SUBCLIN DOCUMENT_NR doc_num RQN_CUR_LN_NR CLIN_QUANTITY
458! SUBCLIN_QUANTITY EXTENDED_AMOUNT UNIT_OF_ISSUE
459            SIGNAL_CODE JOB_ORDER_NR COG_SYMBOL FUND_CODE ORIGL_FUND_CODE
459! FUNDING_MODFD_IND ACRN STANDARD_ACCOUNTING
460            COST_CODE FSCM DUNS_NR REMIT_FSCM REMIT_DUNS_NR FIN_UNIT_PRICE
460! CST_PRC_CODE NET_AMOUNT TRADE_DISCT_PCT
461            SERVICE_START_DATE FOB_SITE_CODE INSPECTION_SITE_CODE INSPECTOR_CODE
461! ACCEPTER_CODE INVOICE_TO_UIC
462            ACCTG_FREE_TEXT_LN TRANSPORTATION_ACCOUNT_CODE TRANSPORTATION_AMOUNT
462! FIN_CMDY_CD FIN_SHIP_MODE_CD
463            FIN_RFRNC_ACRN FIN_CNTRCT_MOD_NR FIN_CRNCY_CD FIN_EXCHNG_RT
463! FIN_INT_DBOF_LONG_LINE
464            FIN_INT_DBOF_JOB_ORDER_NR FIN_INT_DBOF_ACNTNG_DCMNT_NR FINAL_NET_AMT
464! FINAL_TOTAL_AMT_OF_CONT
465            FINAL_EXTENDED_AMOUNT FINAL_FIN_UNIT_PRICE FINAL_TRANSPORTATION_AMOUNT
465! FINAL_NET_AMT2 FY OBJ_CLSS BCN
466            SUB AAA TRANS_CODE LEDGER ABS_AMT);
467
468       BY PIIN APN_SBH APN_SYM AMOUNT_USSGL_FINAL INDEX;
469
470        IF A AND B THEN OUTPUT FL_AND_SPS6;
471        IF A AND NOT B THEN OUTPUT FL_ONLY6;
472        IF B AND NOT A THEN OUTPUT SPS_ONLY6;
473    RUN;

NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.01 seconds


474  %CONTROL_TOTALS(FL_AND_SPS6,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: No observations in data set WORK.FL_AND_SPS6.
NOTE: The data set WORK.SUMM has 0 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.06 seconds
      cpu time            0.01 seconds


"COUNT OF VARIABLES: 2"

NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


475  %CONTROL_TOTALS(SPS_ONLY6,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: No observations in data set WORK.SPS_ONLY6.
NOTE: The data set WORK.SUMM has 0 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


476
477  /*Collect all matches*/
478  DATA MATCH.FL_SPS_ALL (drop = DOCUMENT_NR);
479  SET FL_AND_SPS
480      FL_AND_SPS2
481      fl_and_sps_doc
482      FL_AND_SPS4
483      FL_AND_SPS5
484      FL_AND_SPS6;
485  RUN;

NOTE: There were 6833 observations read from the data set WORK.FL_AND_SPS.
NOTE: There were 188 observations read from the data set WORK.FL_AND_SPS2.
NOTE: There were 41 observations read from the data set WORK.FL_AND_SPS_DOC.
NOTE: There were 53 observations read from the data set WORK.FL_AND_SPS4.
NOTE: There were 115 observations read from the data set WORK.FL_AND_SPS5.
NOTE: There were 0 observations read from the data set WORK.FL_AND_SPS6.
NOTE: The data set MATCH.FL_SPS_ALL has 7230 observations and 194 variables.
NOTE: DATA statement used (Total process time):
      real time           1.25 seconds
      cpu time            0.03 seconds


486  %CONTROL_TOTALS(MATCH.FL_SPS_ALL,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 7230 observations read from the data set MATCH.FL_SPS_ALL.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN MATCH.FL_SPS_ALL

         TOTAL NUMBER OF RECORDS = 7,230

         TOTAL OF AMOUNT_USSGL_FINAL = 109,784,485.39

         TOTAL OF ABS_AMT = 109,784,485.39

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


487
488  *Merge SPS_IN_SCOPE with SPS_only6 that had zero amounts;
489
490  Data Sps_only6_AMT;
491  set Sps_only6;
492  where AMOUNT_USSGL_FINAL IN (0.00);
493  Run;

NOTE: There were 0 observations read from the data set WORK.SPS_ONLY6.
      WHERE AMOUNT_USSGL_FINAL=0;
NOTE: The data set WORK.SPS_ONLY6_AMT has 0 observations and 195 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


494
495  Proc Sort Data=Sps_index;
496  By PIIN;
497  Run;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

498


499  Proc Sort Data=Sps_only6_AMT;
500  By PIIN;
501  Run;

NOTE: Input data set is empty.
NOTE: The data set WORK.SPS_ONLY6_AMT has 0 observations and 195 variables.
NOTE: PROCEDURE SORT used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


502
503
504
505  DATA SPS_ZERO_AMT
506       SPS_ZERO_ONLY
507       SPS_only6_ONLY;
508
509      MERGE Sps_index (IN = A)
510           Sps_only6_AMT (IN = B);
511
512      BY PIIN;
513
514      IF A AND B THEN OUTPUT SPS_ZERO_AMT;
515      IF A AND NOT B THEN OUTPUT SPS_ZERO_ONLY ;
516      IF B AND NOT A THEN OUTPUT SPS_only6_ONLY;
517
518
519  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.00 seconds


520  %CONTROL_TOTALS(Sps_only6_AMT,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: No observations in data set WORK.SPS_ONLY6_AMT.
NOTE: The data set WORK.SUMM has 0 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


521  %CONTROL_TOTALS(SPS_ZERO_AMT,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: No observations in data set WORK.SPS_ZERO_AMT.
NOTE: The data set WORK.SUMM has 0 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


522
523
524  /*********************************************************************************
524! ***********/
525  /*                               OTHER CONTROL TOTALS
525!         */
526  /*********************************************************************************
526! ***********/
527
528  %CONTROL_TOTALS(SPS_INDEX,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


529  %CONTROL_TOTALS(FL_RECON_INDEX2,AMOUNT_USSGL_FINAL);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 1"



NOTE: There were 0 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


530  %CONTROL_TOTALS(FL_RECON_INDEX,AMOUNT_USSGL_FINAL);

NOTE: There were 49625674 observations read from the data set WORK.FL_RECON_INDEX.
NOTE: The data set WORK.SUMM has 1 observations and 3 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           10:47.96
      cpu time            35.89 seconds


"COUNT OF VARIABLES: 1"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_RECON_INDEX

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


531  %CONTROL_TOTALS(FL_AND_SPS_doc,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 41 observations read from the data set WORK.FL_AND_SPS_DOC.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS_doc

         TOTAL NUMBER OF RECORDS = 41

         TOTAL OF AMOUNT_USSGL_FINAL = 731,202.92

         TOTAL OF ABS_AMT = 731,202.92

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


532  %CONTROL_TOTALS(FL_AND_SPS2,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 188 observations read from the data set WORK.FL_AND_SPS2.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS2

         TOTAL NUMBER OF RECORDS = 188

         TOTAL OF AMOUNT_USSGL_FINAL = 2,623,491.31

         TOTAL OF ABS_AMT = 2,623,491.31

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


533  %CONTROL_TOTALS(FL_AND_SPS,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 6833 observations read from the data set WORK.FL_AND_SPS.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.78 seconds
      cpu time            0.07 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_AND_SPS

         TOTAL NUMBER OF RECORDS = 6,833

         TOTAL OF AMOUNT_USSGL_FINAL = 105,698,287.25

         TOTAL OF ABS_AMT = 105,698,287.25

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


534  %CONTROL_TOTALS(SPS_ONLY,AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: There were 3154 observations read from the data set WORK.SPS_ONLY.
NOTE: The data set WORK.SUMM has 1 observations and 4 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.23 seconds
      cpu time            0.00 seconds


"COUNT OF VARIABLES: 2"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_ONLY

         TOTAL NUMBER OF RECORDS = 3,154

         TOTAL OF AMOUNT_USSGL_FINAL = 12,883,381.23

         TOTAL OF ABS_AMT = 12,883,381.23

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


535  %CONTROL_TOTALS(FL_ONLY2,AMOUNT_USSGL_FINAL);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 1"



  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_ONLY2

         TOTAL NUMBER OF RECORDS = 3,154

         TOTAL OF AMOUNT_USSGL_FINAL = 12,883,381.23

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


536  %CONTROL_TOTALS(FL_ONLY,AMOUNT_USSGL_FINAL);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 1"



  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_ONLY

         TOTAL NUMBER OF RECORDS = 3,154

         TOTAL OF AMOUNT_USSGL_FINAL = 12,883,381.23

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


537  %CONTROL_TOTALS(FL_RECON_INDEX,AMOUNT_USSGL_FINAL);

NOTE: There were 49625674 observations read from the data set WORK.FL_RECON_INDEX.
NOTE: The data set WORK.SUMM has 1 observations and 3 variables.
NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           9:49.40
      cpu time            34.46 seconds


"COUNT OF VARIABLES: 1"

  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_RECON_INDEX

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


538
539
540
541  /*********************************************************************************
541! ***********/
542  /* APPLY INTERFACE LOGIC FOR STARS-FL.
542!           */
543  /*********************************************************************************
543! ***********/
544  DATA FL_INTERFACE;
545      SET FL_ONLY;
546      FORMAT FEEDER_SYSTEM $110.;
547      where datamonth not in ('DECFY')and
548      substr(EVENT_TSTMP,6,2) not in ('03');
549      IF DATA_SRC_CODE    = '8'
550          OR ((USR_ID = 'FASTDATA' OR SUBSTR(USR_ID,1,2) = 'FD') AND SCREEN_ID IN
550! ('LXT26S1','LXT25S1'))
551          OR SUBSTR(USR_ID,LENGTH(STRIP(USR_ID))-1,2) IN ('FD','WB') THEN
551! FEEDER_SYSTEM ='FASTDATA';
552
553      ELSE IF (DATA_SRC_CODE = 'M' AND USR_ID = 'COST')
554          OR (DATA_SRC_CODE   = 'c' AND APN_OB_OR_BCN IN
554! ('42158','39040','50054','4523A','32253'))
555          OR (USR_ID IN ('COSTSYS','00000000') AND APN_OB_OR_BCN IN
555! ('42158','39040','50054','4523A','32253')
556              AND SCREEN_ID IN ('LXT26S1','LXT25S1'))
557          OR  (SUBSTR(USR_ID,LENGTH(STRIP(USR_ID))-1,2) = 'CS' AND APN_OB_OR_BCN IN
557! ('42158','39040','50054','4523A','32253')) THEN FEEDER_SYSTEM = 'SYMIS (COST)';
558
559      ELSE IF (DATA_SRC_CODE  = 'c' AND APN_OB_OR_BCN IN ('4002A','55262','62758'))
560          OR (USR_ID IN ('COSTSYS','00000000') AND APN_OB_OR_BCN IN
560! ('4002A','55262','62758')
561              AND SCREEN_ID IN ('LXT26S1','LXT25S1'))
562          OR (SUBSTR(USR_ID,LENGTH(STRIP(USR_ID))-1,2) = 'CS' AND APN_OB_OR_BCN IN
562! ('4002A','55262','62758')) THEN FEEDER_SYSTEM = 'AIM (ADVANCED INFORMATION
562! MANAGEMENT)';
563
564      ELSE IF DATA_SRC_CODE   = '['
565          OR ((USR_ID = 'COSTSYS' OR SUBSTR(USR_ID,1,3) = 'CNI' OR
565! SUBSTR(USR_ID,1,2) = 'CF')
566              AND APN_OB_OR_BCN NOT IN
566! ('42158','39040','50054','4002A','55262','4523A','32253','62758')
567              AND SCREEN_ID IN ('LXT26S1','LXT25S1'))
568          OR SUBSTR(USR_ID,LENGTH(STRIP(USR_ID))-1,2) = 'CF' THEN FEEDER_SYSTEM =
568! 'CFMS';
569
570      ELSE IF DATA_SRC_CODE   = ')' THEN FEEDER_SYSTEM = 'FIS';
571
572      ELSE IF DATA_SRC_CODE   = '}' AND USR_ID = 'RESFMS' THEN FEEDER_SYSTEM = 'RIMS
572!  (REFMS)';
573
574      ELSE IF DATA_SRC_CODE   = '3' THEN FEEDER_SYSTEM = 'DCAS';/* PER KATIE's EMAIL
574!  ON 01-08-13, COMBINING SPS FROM DCAS WITH DCAS BUCKET */
575
576      ELSE IF DATA_SRC_CODE   = 'S' THEN FEEDER_SYSTEM = '1960 SUSPENSE RECYCLED
576! TRANSACTIONS';
577
578      ELSE IF DATA_SRC_CODE   = 'Y' AND SUBSTR(USR_ID,1,1) = 'K' THEN FEEDER_SYSTEM
578! = 'ONLINE - MANUAL';
579
580      ELSE IF (RGT_NR IN ('33','05',' ')
581              AND (SUBSTR(PY_VCH_NR,1,2) IN ('EC','ED','FC','FD','GC','GD')
582                  OR SUBSTR(PY_VCH_NR,1,1) IN ('W','S','N','E','F','G')))
583                      THEN FEEDER_SYSTEM = 'SPS TRANSACTIONS FROM DCAS';
584
585      ELSE IF USR_ID IN ('$PAYD','$PAYDISB','PEND1PAY') THEN FEEDER_SYSTEM = 'ONE
585! PAY INTERFACE';
586
587      ELSE IF USR_ID IN ('********') THEN FEEDER_SYSTEM = 'SYSTEM GENERATED -
587! LIQUIDATION OF AN OBLIGATION';
588
589      ELSE IF USR_ID IN ('DISCOUNT') THEN FEEDER_SYSTEM = '510 SYSTEM GENERATED,
589! ORIGINATING FROM A VENDOR PAY DISBURSEMENT ACTION';
590
591      ELSE IF USR_ID = 'DTSUSER' THEN FEEDER_SYSTEM = 'DTS (DEFENSE TRAVEL
591! SYSTEM)INTERFACE';
592
593      ELSE IF USR_ID = 'MSNAP' THEN FEEDER_SYSTEM = 'SHIPBOARD NON-TACTICAL
593! AUTOMATED DATA PROCESSING (SNAP) INTERFACE';
594
595      ELSE IF USR_ID = 'QB1OBLBS' THEN FEEDER_SYSTEM = 'PACIFIC MISSILE RANGE
595! FACILITY-BUSINESS INFORMATION SYSTEM (PMRF-BIS) INTERFACE';
596
597      ELSE IF USR_ID = 'QB1OBLNM' THEN FEEDER_SYSTEM = 'NEMAIS INTERFACE';
598
599      ELSE IF USR_ID = 'QB1OBLST' THEN FEEDER_SYSTEM = 'SALTS INTERFACE';
600
601      ELSE IF USR_ID = 'RSUPP' THEN FEEDER_SYSTEM = 'RSUPPLY TRANSACTION/INTERFACE';
602
603      ELSE IF USR_ID IN ('$PAYDIT') AND DATA_SRC_CODE = 'O' THEN FEEDER_SYSTEM =
603! 'ONE PAY INTERFACE';
604
605      ELSE IF SUBSTR(USR_ID,1,6) = 'VJSRC=' AND SUBSTR(USR_ID,LENGTH(USR_ID),1) =
605! '*' THEN FEEDER_SYSTEM = 'SYSTEM GENERATED TRANSACTION (VJSRC TRANSACTIONS)';
605! /*PER KATIE'S EMAIL ON 01/09/13 TO BUCKET ALL EUDS INTO TWO BUCKETS */
606
607      ELSE IF USR_ID  = 'ARBATCH' THEN FEEDER_SYSTEM = 'ACCOUNTS RECEIVABLE DUE FROM
607!  VENDORS';
608
609      ELSE IF USR_ID  = 'FLTRCD' AND DATA_SRC_CODE = '{' THEN FEEDER_SYSTEM = 'SALTS
609!  INTERFACE - TRANSMITTAL LETTER OBLIGS FROM FLEET (BATCH)';
610
611      ELSE IF USR_ID  = 'LXR2101' THEN FEEDER_SYSTEM = 'APPLICATION PROGRAM
611! GENERATED UP/DOWN ADJUSTMENT (GENERATED BY BATCH PROGRAM)';
612
613      ELSE IF USR_ID  = 'LXR4301' THEN FEEDER_SYSTEM = 'APPLICATION PROGRAM
613! GENERATED COMMITMENT LIQUIDATION';
614
615      ELSE IF USR_ID  = 'LXR5103' THEN FEEDER_SYSTEM = 'APPLICATION PROGRAM
615! GENERATED (BATCH POSTING TO RDT&E OVERHEAD)';
616
617      ELSE IF USR_ID   = 'SU0' AND DATA_SRC_CODE = '>' THEN FEEDER_SYSTEM =
617! 'INTERFACE TRANSACTIONS - STATION USE (ASHORE ONLY)'; /* CHANGED INTERFACE NAME
617! FROM SNAP2...PER KATIE'S EMAIL ON 01/08/ */
618
619      ELSE IF USR_ID = 'SU0' AND DATA_SRC_CODE = '8' THEN FEEDER_SYSTEM = 'FASTDATA
619! INTERFACE (NON-RWO SAMPLE)';
620
621      ELSE IF USR_ID  = 'VJSRC=B' THEN FEEDER_SYSTEM = 'MACHINE GENERATED 201/202
621! REIMBURSABLE (ALSO FUNDS WITHDRAWAL 122/121)';
622
623      ELSE IF USR_ID  = 'QB1OBL' THEN FEEDER_SYSTEM = 'SENT VIA MQ SERIES INTERFACE
623! (USR_ID = QB1OBL)';
624
625      ELSE IF USR_ID  = 'QB1OBLBP' THEN FEEDER_SYSTEM = 'NSIPS-POEMS INTERFACE';
626
627      ELSE IF USR_ID  = 'QB1OBLEP' THEN FEEDER_SYSTEM = 'NAVY ERP 1.1 INTERFACE';
628
629      ELSE IF USR_ID  IN ('LABOR=+') AND USR_ID NOT IN ('LABOR=+*') THEN
629! FEEDER_SYSTEM = 'FOREIGN NATIONAL LABOR-DIRECT: INTERFACE LOAD FILE PROVIDED ON
629! CUSTOMER-BY-CUSTOMER BASIS';
630
631      ELSE IF USR_ID  IN ('LABOR=#') AND USR_ID NOT IN ('LABOR=#*') THEN
631! FEEDER_SYSTEM = 'FOREIGN NATIONAL LABOR-INDIRECT: INTERFACE LOAD FILE PROVIDED ON
631! CUSTOMER-BY-CUSTOMER BASIS';
632
633      ELSE IF SUBSTR(USR_ID,1,6) = 'LABOR=' AND USR_ID NOT IN ('LABOR=#','LABOR=+')
633! AND SUBSTR(USR_ID,LENGTH(USR_ID),1) ^= '*'
634          AND SUBSTR(PY_VCH_NR,1,3) IN
634! ('CP1','OMA','ZFA','ZFR','ZGT','ZKA','ZKE','ZL0','ZPA','ZPB','ZPD','ZPH','ZPV')
634! THEN FEEDER_SYSTEM = 'DCPS INTERFACE'; /* CHANGES PER PHONE CONVERSATION WITH
634! KATIE, CHANGED 'OR' TO 'AND' - 01-08-13 */
635
636      ELSE IF SUBSTR (USR_ID,1,6) = 'LABOR=' AND SUBSTR(USR_ID,LENGTH(USR_ID),1) =
636! '*' THEN FEEDER_SYSTEM = 'SYSTEM GENERATED LABOR TRANSACTION';
637
638      ELSE IF DATA_SRC_CODE   = "'"
639          OR SUBSTR(USR_ID,LENGTH(STRIP(USR_ID))-1,2) IN ('WA','WM') THEN
639! FEEDER_SYSTEM = 'WAWF (WIDE AREA WORK FLOW)';
640
641      ELSE IF USR_ID = 'PCUSER' THEN FEEDER_SYSTEM = 'PURCHASE CARD (CITIDIRECT)';
642
643      ELSE IF DATA_SRC_CODE   = '0' AND USR_ID = 'SPS' THEN FEEDER_SYSTEM = 'SPS
643! (STANDARD PROCUREMENT SYSTEM)';
644
645      ELSE IF DATA_SRC_CODE   = '0' AND USR_ID IN ('EDI850','EDI860') THEN
645! FEEDER_SYSTEM = 'EDS/NMCI EMARKETPLACE INTERFACE';
646
647      ELSE IF DATA_SRC_CODE IN ('V','W') AND NOT (SUBSTR(USR_ID,1,6) = 'VJSRC=' AND
647! SUBSTR(USR_ID,LENGTH(USR_ID),1) = '*') THEN FEEDER_SYSTEM = 'EUD'; /*PER KATIE'S
647! EMAIL ON 01/09/13 TO BUCKET ALL EUDS INTO TWO BUCKETS*/
648
649      ELSE IF SUBSTR(USR_ID,1,2) = 'SU' THEN FEEDER_SYSTEM = 'INTERFACE TRANSACTIONS
649!  - STATION USE (ASHORE ONLY)';
650
651      ELSE IF USR_ID IN ("$PAYDBA","$PAYDSP") THEN FEEDER_SYSTEM = 'ONE PAY
651! INTERFACE';
652
653      ELSE IF DATA_SRC_CODE = 'Q' THEN FEEDER_SYSTEM = 'IDABI INTERFACE';
654
655      ELSE IF USR_ID = 'ESC' THEN FEEDER_SYSTEM = 'SHIPBOARD NON-TACTICAL AUTOMATED
655! DATA PROCESSING (SNAP2) INTERFACE (PENDING)';
656
657      ELSE IF USR_ID = 'VJSRC=A' AND DATA_SRC_CODE = 'A' THEN FEEDER_SYSTEM = 'HCM
657! INTERFACE - EVENT DRIVEN (MECHANIZED AUTHORIZATIONS)';
658
659      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLBU' THEN FEEDER_SYSTEM =
659! 'NSIPS-POEMS INTERFACE';
660
661      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLEX' THEN FEEDER_SYSTEM =
661! 'EXPEDITIONARY MANAGEMENT INFORMATION SYSTEM(EXMIS) INTERFACE';
662
663      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLFS' THEN FEEDER_SYSTEM =
663! 'FUELS AUTOMATED SYSTEM (FAS) ENTERPRISE SERVER (FES) INTERFACE';
664
665      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLLD' THEN FEEDER_SYSTEM =
665! 'TRIDENT LOGISTICS DATA SYSTEM (LDS) INTERFACE';
666
667      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLMF' THEN FEEDER_SYSTEM =
667! 'MATERIAL FINANCIAL CONTROL SYSTEM (MFCS) INTERFACE';
668
669      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'QB1OBLSN' THEN FEEDER_SYSTEM =
669! 'SHIPBOARD NON-TACTICAL AUTOMATED DATA PROCESSING (SNAP) INTERFACE';
670
671      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'BIS00001' THEN FEEDER_SYSTEM =
671! 'PACIFIC MISSILE RANGE FACILITY-BUSINESS INFORMATION SYSTEM (PMRF-BIS) INTERFACE';
672
673      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'PTUSER' THEN FEEDER_SYSTEM =
673! 'POWERTRACK INTERFACE';
674
675      ELSE IF DATA_SRC_CODE = 'Y' AND USR_ID = 'RWOFREEZ' THEN FEEDER_SYSTEM =
675! 'SYSTEM GENERATED - PREVAL FOR STARS-TO-STARS REIMBURSABLES';
676
677      ELSE IF DATA_SRC_CODE = '6' THEN FEEDER_SYSTEM = 'STATION USE & R-SUPPLY
677! INTERFACE';
678
679      ELSE IF DATA_SRC_CODE = '>' THEN FEEDER_SYSTEM = 'SHIPBOARD NON-TACTICAL
679! AUTOMATED DATA PROCESSING (SNAP2) INTERFACE';
680
681      ELSE IF DATA_SRC_CODE = 'O' THEN FEEDER_SYSTEM = 'ONE PAY INTERFACE';
682
683      ELSE IF DATA_SRC_CODE = '\' THEN FEEDER_SYSTEM = 'INTERFACE FILE - PSEUDO
683! OBLIGATIONS (BOR ADJUST OR AV FUEL)';
684
685      ELSE IF DATA_SRC_CODE = 'N' AND USR_ID = 'SPR0058' AND MEMO = '02-11-040-CONV'
685!  THEN FEEDER_SYSTEM = 'SYSTEM GENERATED - DATABASE MAINTENANCE AUTHORIZATION
685! ADJUSTMENTS';
686
687      ELSE IF USR_ID = 'QB1OBLEP' AND DOC_PRCS_TYP = 'T' THEN FEEDER_SYSTEM =
687! 'ADJUSTMENTS FROM NAVY ERP 1.1';
688
689      ELSE IF USR_ID  = 'QB1OBLEP' AND DOC_PRCS_TYP ^= 'T' THEN FEEDER_SYSTEM =
689! 'TRANSACTIONS FROM NAVY ERP 1.1';
690
691      ELSE IF DATA_SRC_CODE = 'O' THEN FEEDER_SYSTEM = 'ONE PAY INTERFACE (FADA
691! 610)';
692
693      ELSE IF DATA_SRC_CODE = 'P' THEN FEEDER_SYSTEM = 'ONE PAY INTERFACE (ONE PAY
693! TENTATIVE PAYMENT - PREVAL FOR VENDOR PAYMENT)';
694
695      ELSE IF DATA_SRC_CODE = '/' THEN FEEDER_SYSTEM = 'BOR ADJUST OR AV FUEL
695! (Pseudo Obligations)';
696
697      ELSE IF DATA_SRC_CODE = '5' THEN FEEDER_SYSTEM = 'ZNW (B1 Interface)';
698
699      ELSE IF USR_ID = 'QB1OBLTR' THEN FEEDER_SYSTEM = 'TYCOM Readiness Management
699! System (TRMS) Interface';
700
701      ELSE FEEDER_SYSTEM = 'UNMAPPED';
702
703  RUN;

NOTE: Numeric values have been converted to character values at the places given by:
      (Line):(Column).
      581:25   582:27   634:20

NOTE: DATA statement used (Total process time):
      real time           0.03 seconds
      cpu time            0.00 seconds


704
705  /* SUMMARIZE BY DOCUMENT NUMBER. */
706  PROC SUMMARY DATA = FL_INTERFACE NWAY MISSING;
707      CLASS DOC_KEY;
708      VAR AMOUNT_USSGL_FINAL;
709      OUTPUT OUT = FL_DOCNO_SUM (DROP=_TYPE_) SUM=;
710  RUN;

      real time           0.03 seconds
      cpu time            0.00 seconds

711
712  /*********************************************************************************
712! ***********/
713  /* EXTRACT STARS-FL Q2 FY EUD FEEDER SYSTEM TRANSACTIONS & PERFORM SUMMARIES.
713!           */
714  /*********************************************************************************
714! ***********/
715


716  DATA FL_EUD;
717      SET FL_INTERFACE;
718      IF FEEDER_SYSTEM = 'SPS (STANDARD PROCUREMENT SYSTEM)';
719      ABS_AMT = ABS(AMOUNT_USSGL_FINAL);
720  RUN;

NOTE: Variable AMOUNT_USSGL_FINAL is uninitialized.
NOTE: There were 0 observations read from the data set WORK.FL_INTERFACE.
NOTE: The data set WORK.FL_EUD has 0 observations and 11 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


721
722  /* SUMMARIZE BY DOCUMENT NUMBER. */
723  PROC SUMMARY DATA = FL_EUD NWAY MISSING;
724      CLASS PIIN;
725      VAR AMOUNT_USSGL_FINAL ABS_AMT;
726      OUTPUT OUT = EUD_DOCNO_SUM (DROP=_TYPE_) SUM=;
727  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

728


729  PROC SORT DATA = SPS_IN_SCOPE OUT = SPS_SRT;
730      BY PIIN;
731  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

732


733  PROC SORT DATA = FL_EUD OUT = FL_EUD_SRT;
734      BY PIIN;
735  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

736


737  PROC SUMMARY DATA = SPS_SRT NWAY MISSING;
738      CLASS PIIN;
739      VAR AMOUNT_USSGL_FINAL ABS_AMT;
740      OUTPUT OUT = SPS_SRT_DOC_SUM SUM =;
741  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

742


743  DATA SPS_DOCNUM_IN_FL_EUD FL_EUD_NO_SPS;
744      MERGE SPS_SRT_DOC_SUM (IN = A) FL_EUD_SRT (IN = B);
745      BY PIIN;
746
747      IF B AND A THEN OUTPUT SPS_DOCNUM_IN_FL_EUD;
748      ELSE IF B AND NOT A THEN OUTPUT FL_EUD_NO_SPS;
749  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


750
751  PROC SUMMARY DATA = SPS_DOCNUM_IN_FL_EUD NWAY MISSING;
752      CLASS PIIN;
753      VAR AMOUNT_USSGL_FINAL ABS_AMT;
754      OUTPUT OUT = SPS_IN_FL_EUD_DOCNUM SUM =;
755  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

756
757


758  DATA APR_0400 APR_OTHER;
759      SET FL_EUD_NO_SPS;
760      IF APN_SYM = '0400' THEN OUTPUT APR_0400;
761      ELSE OUTPUT APR_OTHER;
762  RUN;

NOTE: Variable APN_SYM is uninitialized.
NOTE: There were 0 observations read from the data set WORK.FL_EUD_NO_SPS.
NOTE: The data set WORK.APR_0400 has 0 observations and 1 variables.
NOTE: The data set WORK.APR_OTHER has 0 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


763
764  PROC SUMMARY DATA = APR_0400 NWAY MISSING;
765      CLASS PIIN;
766      VAR AMOUNT_USSGL_FINAL;
767      OUTPUT OUT = APR_0400_DOCNUM SUM =;
768  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

769


770  PROC SUMMARY DATA = APR_OTHER NWAY MISSING;
771      CLASS PIIN;
772      VAR AMOUNT_USSGL_FINAL;
773      OUTPUT OUT = APR_OTHER_DOCNUM SUM =;
774  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

775


776  PROC SORT DATA = SPS_DOCNUM_IN_FL_EUD OUT = SPS_DOCNUM_IN_FL_EUD_SRT;
777      BY PIIN ABS_AMT;
778  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

779


780  PROC SUMMARY DATA = SPS_IN_SCOPE;
781      CLASS PIIN ABS_AMT;
782      OUTPUT OUT = SPS_SUM (KEEP = PIIN ABS_AMT);
783  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

784


785  PROC SORT DATA = SPS_SUM;
786      BY PIIN ABS_AMT;
787  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

788
789  /*********************************************************************************
789! ***********/
790  /* MERGE DATA
790!           */
791  /*********************************************************************************
791! ***********/
792


793  DATA SPS_DOC_AMT_IN_EUD EUD_DOC_ONLY_IN_SPS;
794      MERGE SPS_SUM (IN = A) SPS_DOCNUM_IN_FL_EUD_SRT (IN = B);
795      BY PIIN ABS_AMT;
796
797      IF A AND B THEN OUTPUT SPS_DOC_AMT_IN_EUD;
798      ELSE IF B AND NOT A THEN OUTPUT EUD_DOC_ONLY_IN_SPS;
799  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


800
801  PROC SUMMARY DATA = SPS_DOC_AMT_IN_EUD NWAY MISSING;
802      CLASS PIIN;
803      VAR AMOUNT_USSGL_FINAL ABS_AMT;
804      OUTPUT OUT = SPS_ALL_IN_EUD_SUM SUM =;
805  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

806


807  PROC SUMMARY DATA = EUD_DOC_ONLY_IN_SPS NWAY MISSING;
808      CLASS PIIN;
809      VAR AMOUNT_USSGL_FINAL ABS_AMT;
810      OUTPUT OUT = EUD_DOC_ONLY_SUM SUM =;
811  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

812
813  *Taraesa looks at nonmatches from first FL interface merge by document number;
814
815  /*********************************************************************************
815! ***********/
816  /* EXTRACT STARS-FL Q2 Fiscal Year EUD FEEDER SYSTEM TRANSACTIONS & PERFORM SUMMARIES.
816!           */
817  /*********************************************************************************
817! ***********/
818
819
820  /* SUMMARIZE BY DOCUMENT NUMBER. */
821


822  PROC SORT DATA = SPS_IN_SCOPE(RENAME=(DOCUMENT_NR=DOC_KEY)) OUT = SPS_SRT2;
823      BY DOC_KEY;
824  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

825


826  PROC SORT DATA = FL_EUD_NO_SPS OUT = FL_EUD_NO_SPS2;
827      BY DOC_KEY;
828  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

829


830  PROC SUMMARY DATA = SPS_SRT2 NWAY MISSING;
831      CLASS DOC_KEY;
832      VAR AMOUNT_USSGL_FINAL ABS_AMT;
833      OUTPUT OUT = SPS_SRT_DOC_SUM2 SUM =;
834  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

835


836  DATA SPS_DOCNUM_IN_FL_EUD2 FL_EUD_NO_SPS3;
837      MERGE SPS_SRT_DOC_SUM2 (IN = A) FL_EUD_NO_SPS2 (IN = B);
838      BY DOC_KEY;
839
840      IF B AND A THEN OUTPUT SPS_DOCNUM_IN_FL_EUD2;
841      ELSE IF B AND NOT A THEN OUTPUT FL_EUD_NO_SPS3;
842  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


843
844
845  PROC SUMMARY DATA = SPS_DOCNUM_IN_FL_EUD2 NWAY MISSING;
846      CLASS DOC_KEY;
847      VAR AMOUNT_USSGL_FINAL ABS_AMT;
848      OUTPUT OUT = SPS_IN_FL_EUD_DOCNUM2 SUM =;
849  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

850
851


852  DATA APR_04002 APR_OTHER2;
853      SET FL_EUD_NO_SPS3;
854      IF APN_SYM = '0400' THEN OUTPUT APR_04002;
855      ELSE OUTPUT APR_OTHER2;
856  RUN;

NOTE: Variable APN_SYM is uninitialized.
NOTE: There were 0 observations read from the data set WORK.FL_EUD_NO_SPS3.
NOTE: The data set WORK.APR_04002 has 0 observations and 1 variables.
NOTE: The data set WORK.APR_OTHER2 has 0 observations and 1 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


857
858  PROC SUMMARY DATA = APR_04002 NWAY MISSING;
859      CLASS DOC_KEY;
860      VAR AMOUNT_USSGL_FINAL;
861      OUTPUT OUT = APR_0400_DOCNUM2 SUM =;
862  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

863


864  PROC SUMMARY DATA = APR_OTHER2 NWAY MISSING;
865      CLASS DOC_KEY;
866      VAR AMOUNT_USSGL_FINAL;
867      OUTPUT OUT = APR_OTHER_DOCNUM2 SUM =;
868  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

869


870  PROC SORT DATA = SPS_DOCNUM_IN_FL_EUD2 OUT = SPS_DOCNUM_IN_FL_EUD_SRT2;
871      BY DOC_KEY ABS_AMT;
872  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

873


874  PROC SUMMARY DATA = SPS_SRT2;
875      CLASS DOC_KEY ABS_AMT;
876      OUTPUT OUT = SPS_SUM2 (KEEP = DOC_KEY ABS_AMT);
877  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

878


879  PROC SORT DATA = SPS_SUM2;
880      BY DOC_KEY ABS_AMT;
881  RUN;

NOTE: PROCEDURE SORT used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

882
883  /*********************************************************************************
883! ***********/
884  /* MERGE DATA
884!           */
885  /*********************************************************************************
885! ***********/
886


887  DATA SPS_DOC_AMT_IN_EUD2 EUD_DOC_ONLY_IN_SPS2;
888      MERGE SPS_SUM2 (IN = A) SPS_DOCNUM_IN_FL_EUD_SRT2 (IN = B);
889      BY DOC_KEY ABS_AMT;
890
891      IF A AND B THEN OUTPUT SPS_DOC_AMT_IN_EUD2;
892      ELSE IF B AND NOT A THEN OUTPUT EUD_DOC_ONLY_IN_SPS2;
893  RUN;

NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


894
895  PROC SUMMARY DATA = SPS_DOC_AMT_IN_EUD2 NWAY MISSING;
896      CLASS DOC_KEY;
897      VAR AMOUNT_USSGL_FINAL ABS_AMT;
898      OUTPUT OUT = SPS_ALL_IN_EUD_SUM2 SUM =;
899  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

900


901  PROC SUMMARY DATA = EUD_DOC_ONLY_IN_SPS2 NWAY MISSING;
902      CLASS DOC_KEY;
903      VAR AMOUNT_USSGL_FINAL ABS_AMT;
904      OUTPUT OUT = EUD_DOC_ONLY_SUM2 SUM =;
905  RUN;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

906
907
908  *Combine matches found by piin and amount with matches found by doc_key and amount
908! ;


909  data SPS_DOC_AMT_IN_EUD_ALL;
910  set SPS_DOC_AMT_IN_EUD SPS_DOC_AMT_IN_EUD2;
911  RUN;

NOTE: There were 0 observations read from the data set WORK.SPS_DOC_AMT_IN_EUD.
NOTE: There were 0 observations read from the data set WORK.SPS_DOC_AMT_IN_EUD2.
NOTE: The data set WORK.SPS_DOC_AMT_IN_EUD_ALL has 0 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds


912
913
914  *Combine nonmatches not found by piin and amount with nonmatches not found by
914! doc_key and amount;
915  data EUD_DOC_ONLY_IN_SPS_ALL;
916  set EUD_DOC_ONLY_IN_SPS EUD_DOC_ONLY_IN_SPS2;
917  run;

NOTE: There were 0 observations read from the data set WORK.EUD_DOC_ONLY_IN_SPS.
NOTE: There were 0 observations read from the data set WORK.EUD_DOC_ONLY_IN_SPS2.
NOTE: The data set WORK.EUD_DOC_ONLY_IN_SPS_ALL has 0 observations and 0 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


918
919
920  %CONTROL_TOTALS(FL_EUD_NO_SPS3, AMOUNT_USSGL_FINAL);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds

"COUNT OF VARIABLES: 1"



  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN FL_EUD_NO_SPS3

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


921  %CONTROL_TOTALS(SPS_DOC_AMT_IN_EUD_ALL, AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable ABS_AMT is uninitialized.
  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_DOC_AMT_IN_EUD_ALL

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

         TOTAL OF ABS_AMT = .

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


922  %CONTROL_TOTALS(SPS_DOC_AMT_IN_EUD2, AMOUNT_USSGL_FINAL ABS_AMT); *To see
922! individual data set not combined;

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable ABS_AMT is uninitialized.
  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN SPS_DOC_AMT_IN_EUD2

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

         TOTAL OF ABS_AMT = .

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds


923  %CONTROL_TOTALS(EUD_DOC_ONLY_IN_SPS_ALL, AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable ABS_AMT is uninitialized.
  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN EUD_DOC_ONLY_IN_SPS_ALL

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

         TOTAL OF ABS_AMT = .

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


924  %CONTROL_TOTALS(EUD_DOC_ONLY_IN_SPS2, AMOUNT_USSGL_FINAL ABS_AMT);

NOTE: PROCEDURE SUMMARY used (Total process time):
      real time           0.01 seconds
      cpu time            0.01 seconds

"COUNT OF VARIABLES: 2"



NOTE: Variable ABS_AMT is uninitialized.
  ----------------------------------------------------

    CONTROL TOTAL AND TOTAL NUMBER OF RECORDS IN EUD_DOC_ONLY_IN_SPS2

         TOTAL NUMBER OF RECORDS = 49,625,674

         TOTAL OF AMOUNT_USSGL_FINAL = 84,748,287,746.48

         TOTAL OF ABS_AMT = .

  ----------------------------------------------------
NOTE: There were 1 observations read from the data set WORK.SUMM.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds


925
926
927  /*********************************************************************************
927! ***********/
928  /*                                       EXPORTS
928!           */
929  /*********************************************************************************
929! ***********/
930
931  %EXPORT_XLS(sps_ONLY2);

NOTE: New file "H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
      Reconciliation\SPS\COMFISC\Outputs\Output_0528.xls" will be created if the
      export process succeeds.
NOTE: "sps_ONLY2" was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           2.04 seconds
      cpu time            0.60 seconds


932  %EXPORT_XLS(match.FL_sps_all);

NOTE: "match_FL_sps_all" was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           2.92 seconds
      cpu time            2.54 seconds


933  %EXPORT_XLS(SPS_sub);

NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.56 seconds
      cpu time            0.51 seconds

934  %EXPORT_XLS(SPS_ONLY_doc);



NOTE: "SPS_ONLY_doc" was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           2.82 seconds
      cpu time            1.73 seconds


935  %EXPORT_XLS(SPS_ONLY6);

NOTE: "SPS_ONLY6" was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           1.53 seconds
      cpu time            1.06 seconds


936  %EXPORT_XLS(Sps_only2_AMT ); *Sps_only2_AMT is the subset from SPS_ONLY_doc with
936! zero amounts;

NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.62 seconds
      cpu time            0.56 seconds

937  %EXPORT_XLS(SPS_ZERO_AMT ); *SPS_ZERO_AMT matched dataset  between Sps_only2_AMT
937! and "Sps_index" (aka: Sps_in_scope);



NOTE: "SPS_ZERO_AMT" was successfully created.
NOTE: PROCEDURE EXPORT used (Total process time):
      real time           1.54 seconds
      cpu time            1.09 seconds


938  %EXPORT_XLS(FL_EUD_NO_SPS3);

NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.59 seconds
      cpu time            0.53 seconds

939  %EXPORT_XLS(SPS_DOC_AMT_IN_EUD_ALL);

NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.62 seconds
      cpu time            0.59 seconds

940  %EXPORT_XLS(EUD_DOC_ONLY_IN_SPS_ALL);


NOTE: PROCEDURE EXPORT used (Total process time):
      real time           0.64 seconds
      cpu time            0.61 seconds

941
942  /*********************************************************************************
942! ***********/
943  /*                                       END OF PROGRAM
943!           */
944  /*********************************************************************************
944! ***********/
945  DM "LOG; FILE 'H:\navy_fmo\Audit Readiness\SEGMENTS\CVP\Feeder System
945! Reconciliation\SPS\comfisc\SAS Codes and Logs\sps_FL_RECON_&DATE..LOG' REPLACE";

