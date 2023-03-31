
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: read_iso8601
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


%macro read_iso8601(datein=, dateout=, timeout=, dtoutfmt=date9., tmoutfmt=datetime15.);

  %if "&dateout" ne "" %then %do;
    *format &dateout &dtoutfmt;
    if length(&datein) >=10 then do;
      &dateout=input(substr(&datein,1,10), ? yymmdd10.);
      if _error_=1 then do;
        put "WARNING: Invalid date value " &datein=;
        _error_=0;
      end;
    end;
    else &dateout = .;
  %end;
  %if "&timeout" ne "" %then %do;
    *format &timeout &tmoutfmt;
    if length(&datein) >=16 then do;
      &timeout = input(compress(put(input(scan(&datein,1,'T'),yymmdd10.),&dtoutfmt)
						  	       ||":"
							         ||scan(&datein,2,'T')), ? &tmoutfmt);
      if _error_=1 then do;
        put "WARNING: Invalid datetime value " &datein=;
        _error_=0;
      end;
    end;
    else &timeout = .;
  %end;

%mend;
