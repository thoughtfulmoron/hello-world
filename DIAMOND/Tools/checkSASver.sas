
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: checkSASver
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


%macro checkSASver(expected_SASver=) ;
/*
PARAMETERS:
expected_SASver - expected SAS version 
  values can be for example:
  X        - any version, 
  X.X      - any version, 
  8.X      - any release of ver.8, 
  9.1      - exactly version 9.1
  UP8.1    - 8.1 or higher
*/

data _null_;
  sysver=symget('sysver');
  expected=upcase(symget('expected_SASver'));
  if expected='' then
    goto problem;
  if length(expected)>2 then
    do;
      if substr(expected,1,2)='UP' then
        do;
          n_expected=input(substr(expected,3),? best.); 
          if _error_ then 
            goto problem;
          if n_expected ne . and n_expected<=input(sysver,best.) then
            goto ok;
        end;    
    end;

  sys_ver=scan(sysver,1,'.');
  sys_rel=scan(sysver,2,'.');
  exp_ver=scan(expected,1,'.');
  exp_rel=scan(expected,2,'.');
  if not(exp_ver='X' or exp_ver=sys_ver) then
    goto problem;
  if not(exp_rel in ('X','') or exp_rel=sys_rel) then
    goto problem;
  goto ok;
ok:
  put 'SAS version confirmed';
  return;
problem:
  put 'ER' 'ROR: WRONG SAS VERSION FOR THIS STUDY! SAS version is: ' sysver 
      '. SAS version expected for this study is: ' expected 'Environment will be closed ';
  window ERROR color=grey 
    #5 @10 'WRONG SAS VERSION FOR THIS STUDY!' color=red   
    #8 @10 'SAS version is: ' sysver color=red PROTECT=YES 
    #9 @10 'SAS version expected for this study is: ' expected color=red PROTECT=YES 
    #12 @10 'Environment will be closed (press ENTER)' color=black;  
  display ERROR bell; 
  abort abend;
  *stop;
run;
%mend;

/*Example of usage:
%checkSASver(expected_SASver=9.2);
*/
