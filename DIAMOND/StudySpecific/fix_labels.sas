
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: fix_labels
           Program Location: 
                Description: 

             Program Author: ICON
              Creation Date: 23DEC2015 (v1.0)

    Name/Location of Output: 

     Location of Input Data: 
        Datasets/files Used: 
             Format Library: 
   External Macros Location: 

Modification Notes (include name of person modifying the program, date of modification 
and description/reason for the change):
23DEC2015 (v1.0)  1st release
*************************************************************************************************;


%macro fix_labels(ver=1, type=T);

%if &type=T %then
  %do;

  %if &ver=1 %then
  %do;
    %if %upcase(&group)=TRT01A or %upcase(&group)=TRTA  %then
      %do;
        %let group_list = %sysfunc(tranwrd(&group_list,150MG REGN668,REGN668~150 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,150MG PLACEBO,Placebo~150 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG REGN668,REGN668~300 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG PLACEBO,Placebo~300 mg));

        /*%let group_list = %sysfunc(tranwrd(&group_list,A1_FAST,Sequence A1~Fasting));
        %let group_list = %sysfunc(tranwrd(&group_list,A1_FED,Sequence A1~Fed));
        %let group_list = %sysfunc(tranwrd(&group_list,A2_FAST,Sequence A2~Fasting));
        %let group_list = %sysfunc(tranwrd(&group_list,A2_FED,Sequence A2~Fed));
        %let group_list = %sysfunc(tranwrd(&group_list,B1_FAST,Sequence B1~Fasting));
        %let group_list = %sysfunc(tranwrd(&group_list,B1_FED,Sequence B1~Fed));
        %let group_list = %sysfunc(tranwrd(&group_list,B2_FAST,Sequence B2~Fasting));
        %let group_list = %sysfunc(tranwrd(&group_list,B2_FED,Sequence B2~Fed));*/
      %end;

    %if %upcase(&group)=ARMCD or %upcase(&group)=ACTARMCD %then
      %do;
        %let group_list = %sysfunc(tranwrd(&group_list,809012A1,Sequence A1~Fasting/Fed));
        %let group_list = %sysfunc(tranwrd(&group_list,809012A2,Sequence A2~Fed/Fasting));
        %let group_list = %sysfunc(tranwrd(&group_list,809012B1,Sequence B1~Fasting/Fed));
        %let group_list = %sysfunc(tranwrd(&group_list,809012B2,Sequence B2~Fed/Fasting));
      %end;

  %end;

  %if &ver=2 %then
  %do;
    %if %upcase(&group)=TRT01A or %upcase(&group)=TRTA  %then
      %do;
        %let group_list = %sysfunc(tranwrd(&group_list,150MG REGN668,REGN668 150 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,150MG PLACEBO,Placebo 150 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG REGN668,REGN668 300 mg));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG PLACEBO,Placebo 300 mg));
	  %end;

  %end;

  %if &ver=3 %then
  %do;
    %if %upcase(&group)=TRT01A or %upcase(&group)=TRTA  %then
      %do;
        %let group_list = %sysfunc(tranwrd(&group_list,150MG REGN668CHG,Change~from~Baseline));
        %let group_list = %sysfunc(tranwrd(&group_list,150MG PLACEBOCHG,Change~from~Baseline));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG REGN668CHG,Change~from~Baseline));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG PLACEBOCHG,Change~from~Baseline));
        %let group_list = %sysfunc(tranwrd(&group_list,TOTALCHG,Change~from~Baseline));
        %let group_list = %sysfunc(tranwrd(&group_list,150MG REGN668,Lab~Result));
        %let group_list = %sysfunc(tranwrd(&group_list,150MG PLACEBO,Lab~Result));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG REGN668,Lab~Result));
        %let group_list = %sysfunc(tranwrd(&group_list,300MG PLACEBO,Lab~Result));
        %let group_list = %sysfunc(tranwrd(&group_list,TOTAL,Lab~Result));
	  %end;

  %end;
%end;
/**************************************/

%if &type=L %then
  %do;

  %if &ver=1 %then
  %do;

    data table;
	  set table;
	  format groupc $200.;
	       if &group.="FAIL"          then do; groupn=0; groupc="Screen failure"; end;
	  else if &group.="150MG REGN668" then do; groupn=1; groupc="150MG REGN668"; end;
	  else if &group.="150MG PLACEBO" then do; groupn=2; groupc="150MG Placebo"; end;
	  else if &group.="300MG REGN668" then do; groupn=3; groupc="300MG REGN668"; end;
	  else if &group.="300MG PLACEBO" then do; groupn=4; groupc="300MG Placebo"; end;
	  else do; groupn=0; groupc="#### Unknown group ####"; end;
	run;

  %end;
%end;

%mend;


