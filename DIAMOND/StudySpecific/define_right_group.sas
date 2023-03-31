
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: define_right_group
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


	/*#################################################*/
	/*### In ADSL, TRTA and TRTP need to be created ###*/
	/*### Create only 1 time at beginning of study  ###*/
	/*#################################################*/

								*update, remove or add the parameters according to your study;
%macro define_right_group(with_total=&totals.,type=ADSL);


/*** Single dose ***/
  if "&group."="TRTA" then &group.=TRT01A;
  if "&group."="TRTP" then &group.=TRT01P;
  output;

%if &with_total=1 %then
  %do;
  &group.="Total";
  output;
  %end;


/*** Cross-over study ***

  if "&group."="TRTA" then do;
		&group.=TRT01A; output;
		&group.=TRT02A; output;
		&group.=TRT03A; output;
  end;
  if "&group."="TRTP" then do;
		&group.=TRT01P; output;
		&group.=TRT02P; output;
		&group.=TRT03P; output;
  end;

%if &with_total=1 %then
  %do;
  &group.="TOTAL"; output; output; output;
  %end;
  */

%mend;


