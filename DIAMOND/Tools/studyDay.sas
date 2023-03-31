
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: studyDay
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


%macro studyDay(date=, datenum=0, ref=, refnum=0, studyday=);

  %if &refnum eq 0 %then %do;
    if length(&ref)>=10 then _dateref = input(substr(&ref,1,10),yymmdd10.);
    else _dateref = .;
  %end;
  %if &datenum eq 0 %then %do;
    if length(&date)>=10 then _date = input(substr(&date,1,10),yymmdd10.);
    else _date = .;
  %end;
  if not missing (_dateref) and not missing(_date) then 
    &studyday = _date - _dateref + (_date >= _dateref);

  drop _date _dateref;

%mend studyDay;
