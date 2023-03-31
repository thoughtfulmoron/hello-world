
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: add_seq
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

*************************************************************************************************;


%macro add_seq(domain,keys,dsin=,dsout=);

  %if &dsin = %then %let dsin = &syslast;
  %if &dsout = %then %let dsout = &dsin;

  proc sort data = &dsin out = &dsout;
    by &keys;
  run;
  
  data &dsout;
    set &dsout;
    by &keys;
    retain &domain.SEQ_TMP;
    if first.usubjid then &domain.SEQ_TMP = 1;
    else &domain.SEQ_TMP + 1;
    &domain.SEQ = &domain.SEQ_TMP;
    drop &domain.SEQ_TMP;
  run;

%mend add_seq;
  
