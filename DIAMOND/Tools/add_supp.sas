
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: add_supp
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


%macro ADD_SUPP(domain,suppqual=,library=,dsout =) ;

  %if &library = %then %let library = libanal;
  %if &suppqual = %then %let suppqual = supp&domain;
  %if &dsout = %then %let dsout = full&domain;

  proc sql noprint;
    select distinct qnam , qlabel into :qnam1 - :qnam99  , :qlabel1 - :qlabel99 
    from &library..&suppqual(where = (upcase(rdomain) = upcase("&domain")));
  quit;

  %let N = &sqlobs;

  %if &N ne 0 %then %do;

  proc sort data = &library..&suppqual(where = (upcase(rdomain) = upcase("&domain"))) out = supp;
    by usubjid idvar idvarval;
  run;

  data trans;
    set supp;
    by usubjid idvar idvarval;
    length 
      %do i_qloop = 1 %to &n;
        &&qnam&i_qloop
      %end;
      $200;
    retain 
      %do i_qloop = 1 %to &n;
        &&qnam&i_qloop
      %end;
      ;
    if first.idvarval then do;
      %do i_qloop = 1 %to &n;
        &&qnam&i_qloop = " ";
      %end;
    end;

    %do i_qloop = 1 %to &n;
      if upcase(qnam) = upcase("&&qnam&i_qloop") then &&qnam&i_qloop = qval;
      label &&qnam&i_qloop = "&&qlabel&i_qloop";
    %end;

    if last.idvarval then output;
  run; 

  data trans;
    set trans;
    if idvar = " " then idvar = "USUBJID";
  run;

  proc sql noprint;
    select distinct idvar into :idvar1 - :idvar99 from trans;
  quit;

  %let N = &sqlobs;

  proc sort data = &library..&domain out = main;
    by usubjid;
  run;

  %do i_idloop = 1 %to &N;
    %if %upcase(&&idvar&i_idloop) = USUBJID %then %do;
      proc sort data = main;
        by usubjid;
      run;

      proc sort data = trans;
        by usubjid;
      run;

      data main;
        merge main trans(where = (upcase(idvar) eq upcase("USUBJID")));
        by usubjid;
      run;
    %end;
    %else %do;
      data trans;
        set trans;
        %if %upcase(&&idvar&i_idloop) = %upcase(&domain.SEQ) %then %do;
          /* need to convert char to numeric */
          &&idvar&i_idloop = input(idvarval,best.);
        %end;
        %else %do;
          &&idvar&i_idloop = idvarval;
        %end;
      run;
    
      proc sort data = main;
        by usubjid &&idvar&i_idloop;
      run;

      proc sort data = trans;
        by usubjid &&idvar&i_idloop; 
      run;

      data main;
        merge main trans(where = (upcase(idvar) eq upcase("&&idvar&i_idloop")));
        by usubjid &&idvar&i_idloop;
      run;
    %end;
  %end;

  data &dsout(drop = RDOMAIN IDVAR IDVARVAL QNAM QLABEL QVAL);
    set main;
  run;
  
  %end;
  %else %do;  
    %put NOTE: No supplemental qualifiers exist.;

    data &dsout;
      set &library..&domain;
    run;
  %end;

%mend;

/* EXAMPLES

%add_supp(DM);

%add_supp(DS, suppqual = SUPPQUAL, library = SDTMDATA, dsout = PRE_ADDS);

%add_supp(AE, suppqual = SUPPAE, library = WORK, dsout = REPORT);

*/
