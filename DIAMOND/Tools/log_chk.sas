
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: log_chk
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
03MAR2016 (v1.2)  Remove the "kill" in the proc datasets.
28OCT2016 (v2.0)  Changed completely the code to use new process
*************************************************************************************************;


%macro log_chk (file= ) ;


options noxwait;

/*** Reassign macro-variables to be consitent with current process
	%macro log_check(log_path=,out_path=,out_excel=log_check,subfolder=,logfile=);*/
%local log_path out_path out_excel subfolder logfile;
%let log_path=;
%let out_path=;
%let out_excel=&rep.;
%let subfolder=0;
%let logfile=&file.;


/*** checking for window environment.***/

%if %upcase(&sysscp) ne WIN %then %do;
    %put %str(NO)TE: <&sysmacroname>: Macro will work only under Windows environment.;     
    %goto Exitmacro;  
%end;


/*** checking existance of logfile if it is non missing***/

  %if %nrbquote(&logfile) ne %then %do;
    %let logfile = %sysfunc(lowcase(&logfile));
    %if %sysfunc(fileexist(&logfile)) = 0 %then %do;
      %put %str(ER)ROR: <&sysmacroname>: Logfile does not exist.;        
      %put %str(NO)TE: <&sysmacroname>: User note Macro expecting a valid .log file with full path and extension.;           
      %goto Exitmacro; 
    %end; 
    data list_all;
      filename = lowcase(compress("&logfile"));
      date = "";
      time = "";
      size = "";
    run;    
   %end;
  %else %do;

/*** checking for blank/ non existance of the input directory***/

  %if %nrbquote(&log_path) = %then %do;
    %put %str(ER)ROR: <&sysmacroname>: Directory can not be blank or missing.;        
    %put %str(NO)TE: <&sysmacroname>: User note Macro expecting a valid directory path.;           
    %goto Exitmacro;  
  %end;

   %local rc fileref ; 
   %let rc = %sysfunc(filename(fileref,&log_path)) ; 
   %if %sysfunc(fexist(&fileref)) = 0 %then %do;
    %put %str(ER)ROR: <&sysmacroname>: Directory does not exist.;        
    %put %str(NO)TE: <&sysmacroname>: User note Macro expecting a valid log_path directory path.;           
    %goto Exitmacro;  
  %end;
  
  
  %if %nrbquote(&out_path) ne %then %do;
   %let rc = %sysfunc(filename(fileref,&out_path)) ; 
   %if %sysfunc(fexist(&fileref)) = 0 %then %do;
    %put %str(ER)ROR: <&sysmacroname>: Directory does not exist.;        
    %put %str(NO)TE: <&sysmacroname>: User note Macro expecting a valid out_path directory path.;           
    %goto Exitmacro;  
  %end;
  %end;
    
/*** calculation required by program to run***/

data _null_;
  length log_path out_path out_excel subfolder $1000;

  log_path = "&log_path";
  out_path = "&out_path";
  out_excel = "&out_excel";
  if missing(out_path) then out_path = log_path;
  if missing(out_excel) then out_excel = "log_check";
 
  if index(reverse(strip(log_path)),"\") = 1 then log_path = substr(strip(log_path),1,length(strip(log_path))-1);
  if index(reverse(strip(out_path)),"\") = 1 then out_path = substr(strip(out_path),1,length(strip(out_path))-1);
  call symput("log_path",strip(log_path));
  call symput("out_path",strip(out_path));
  call symput("out_excel",strip(out_excel));
    
  subfolder = "&subfolder";
  i = 0;    
    do while(scan(subfolder,i+1 ) ne "");
      i+1;
      temp = strip(scan(subfolder,i," " ));
      call symput("sub" || strip(put(i,2.)), strip(temp));
    end;
    call symputx("sub_cnt",i);
run;

/*** getting list of log files***/

%macro list_all(loc_path=,ext=,outds=);

   %let rc = %sysfunc(filename(fileref,&loc_path)) ; 
   %if %sysfunc(fexist(&fileref)) = 0 %then %do;    
    %put %str(ER)ROR: Subfolder ( &&sub&i. ) does not exist.;        
    %put %str(NO)TE: &loc_path is not a valid directory path.;   
    
    data &outds.;
	  delete;
    run;  
   %end;
   %else %do;

     filename dirlist pipe "dir /a:-d &loc_path.\*.&ext."; /*dir command*/

     data &outds.(where=(index(name,".&ext") > 0));
       length date time size name $100 filename $1000;
       infile dirlist truncover end=eof;
       input date time $11-20 size name ;
       name = lowcase(strip(name)); 
       filename = "&loc_path.\" || strip(name);
       ord = "&outds";
     run;

     %if &sysnobs = 0 %then %do;
	    %put %str(NO)TE: &loc_path does not contain any valid log file(s).;  
		%put ;
     %end;
   %end;
%mend list_all;

%list_all(loc_path=&log_path.,ext=log,outds=list_all0);
%do i = 1 %to &sub_cnt;
  %list_all(loc_path=&log_path.\&&sub&i.,ext=log,outds=list_all&i);
%end;

data list_all;
  set %do i = 0 %to &sub_cnt; list_all&i %end;;
run;
%let cnt_logfile = &sysnobs;
%end;
/*** end of if condition is logfile ne missing ***/


/*** defining the path of logcheck_rules file***/

 %let log_mode = production;

 %let rc = %sysfunc(filename(server_eu,%str(O:\remote\sas_icr_bio_eu\))) ; 
 %let rc = %sysfunc(filename(server_am,%str(O:\remote\sas_icr_bio_am\))) ; 

 %if %sysfunc(fexist(&server_eu)) = 1 %then %do;
    %let server_loc = sas_icr_bio_eu;
 %end;
 %else %if %sysfunc(fexist(&server_am)) = 1 %then %do;
    %let server_loc = sas_icr_bio_am;
 %end;

data _null_;
  logcheck_rules_path = "O:\remote\&server_loc.\shared\docs\&log_mode.";
  call symput("logcheck_rules_path",compress(logcheck_rules_path));
run; 

/*** Reading external file for the list of all the unwanted messages that will be searched***/
data logcheck_rules;
  infile "&logcheck_rules_path.\logcheck_rules.txt" length=linelength missover end=eof;
  format msg $char200.;
  length msg $200 ;
  input msg $varying200. linelength;
run;

/*** creating macro for each unwanted message***/
data logcheck_rules;
  set logcheck_rules end=eof;
  where msg ne "";
  length rule rule_type $200;
  
  cnt=_n_;
  msg = upcase(msg);
  rule = strip(scan(msg,1,"("));
  rule_type = strip(scan(msg,2,"("));
  if not missing(rule_type) then rule_type = "(" || strip(rule_type);

  call symput('rule' || strip(put(_n_,3.0)),strip(rule));
  call symput('rule_type' || strip(put(_n_,3.0)),strip(rule_type));
  if eof then call symputx('tot_rule',_n_);
run;

/*** inputing log files and checking unwanted messages in them***/
data all_message(drop = temp:  size);
  set list_all end=lastobs;
  f_name = filename;
  infile logfile filevar=f_name length=linelength missover end=eof;

  format line $char1000.;
  length line $1000 rule rule_type $200 temp temp1 $20;
  label line='Messages from LOG';

        line_num = 0;
        rule_found = 0;
        do while (eof ne 1);
            input line $varying200. linelength;
            line = upcase(strip(line));
            line_num + 1;
                do cnt = 1 to &tot_rule;
                    temp = compress('&rule' || put(cnt,3.));
                    rule = resolve(temp); 
                    temp1 = compress('&rule_type' || put(cnt,3.));
                    rule_type = resolve(temp1); 
                    if index(line,strip(rule)) > 0 then do;
                        if (index(strip(line), "ERROR") in (1 2) or
                            index(strip(line), "NOTE") in (1 2)  or
                            index(strip(line), "WARNING") in (1 2) or
                            index(strip(line), ") ERROR:") > 0 or
                            index(strip(line), ") NOTE:") > 0 or
                            index(strip(line), ") WARNING:") > 0 or
                            index(strip(line), "_ERROR_=1") > 0) then do;
                            if (index(strip(line), "NOTE") in (1 2) and index(strip(line), "WITHOUT ERROR"))then do;
							end;
							else do;							
							  rule_found = 1;  output; 
							end;
                        end;
                    end;
                end ;
            end;
        
        if eof and rule_found = 0 then do;
            line = 'NO ERRORS OR WARNINGS WERE FOUND';
            line_num = .;
            rule = "";
            output;
        end;
run;

/*** removing duplicates***/
proc sql noprint;
  create table no_dup_message as select filename,line,date,time,min(line_num) as line_num,min(cnt) as cnt,count(*) as count
  from all_message group by filename,line,date,time ;

  create table freq as select filename,cnt,rule,rule_type,count(*) as count
  from all_message group by filename,cnt,rule,rule_type ;
  select max(line_num) into: max_err from no_dup_message;
quit;

data no_dup_message;
  set no_dup_message;
  if line_num = . then count = .;
  length rule_ $200 temp temp1 $20;
  temp = compress('&rule' || put(cnt,3.));
  temp1 = compress('&rule_type' || put(cnt,3.));
  if cnt <= &tot_rule then rule_ = strip(resolve(temp)) || " " || strip(resolve(temp1)) ;
run;  

proc sort data = no_dup_message;
  by filename line_num line;
run;

%if %nrbquote(&logfile) = and %nrbquote(&out_path) ne %then %do;

title1 "There are some unwanted messages as per the Log Check Rules";
%if %sysevalf(&max_err <= 0) %then %do;
  title1  "All logs are clear as per the Log Check Rules";
%end;

ods noresults;

  /*** Reporting all findings in an excel sheet ***/
  ods listing close;
  ods tagsets.excelxp file="&out_path.\&out_excel..xls" style=sasweb 
        options(
            sheet_name='Log Findings' 
            absolute_column_width='35,50,40,10,10,10,10'
            orientation='landscape' 
            frozen_rowheaders='2'
            frozen_headers='3'
            autofit_height = 'yes'
            autofilter='A1:G1'
            embedded_titles='yes');
  
  proc Report data=No_dup_message  missing nowindows ;
  columns filename line rule_ count line_num date time;
  define filename / display  "File Name" flow width=35 ;
  define line/ display "Unwanted Message" flow width=50 ;
  define rule_/ display "Log check rule" flow width=40 ;
  define count/ display "Total count of occurrences" flow width=10 center f=6.;
  define line_num / "Line number of first occurrence  " flow width=10 ;
  define date / "File Modification date" flow width=10 ;
  define time / "File Modification time" flow width=10 ;

      compute line;
          if index(line,'NO ERRORS OR WARNINGS WERE FOUND') then do;
              call define('line','style','style={foreground=green}');
          end;
          else if index(line,'WARNING') then do;
              call define('line','style','style={foreground=brown}');
          end;
          else if index(line,'ERROR') then do;
              call define('line','style','style={foreground=red}');
          end;
          else if index(line,'NOTE') then do;
              call define('line','style','style={foreground=blue}');
          end;
      endcomp;
  run;

title;
  ods tagsets.excelxp 
    options(sheet_name='Log Check Rules' 
            absolute_column_width='50,30'
            orientation='landscape' 
            frozen_rowheaders='2'
            frozen_headers='1'
            autofit_height = 'yes'
            autofilter='A1:B1'
            embedded_titles='no');
  
  proc Report data= logcheck_rules missing nowindows ;

  columns cnt rule rule_type;
  define cnt/order order = data noprint;
  define rule / display  "Log Check Rules searched in the log" flow width=50 ;
  define rule_type / display  "Log Check Rules type" flow width=30 ;
  run;


  ods tagsets.excelxp close;
  ods listing;

%end;
%else %if %nrbquote(&logfile) ne %then %do;

/*** reporting for single log file***/
  data _null_;
    set freq(in=a) no_dup_message(in=b);
    file "&logfile._chk";

    retain flag;
    if a and not missing(rule) then do;
      if _n_ = 1 then do; put @30 "Below messages found in the log"; put; put; end;
      put @3 rule_type @30 rule @95 count;
      flag = 0;
    end;
    if b and line_num ne . then do;
      if flag = 0 then do; put @3 130*"-"; put @3 "Line #" @15 "Message"; end;
      if b then do; put; put @3 line_num @15 line; end;
      flag = 1;
    end;
  run; 
%end;
%else %do;
    %put &logfile;
    %put %str(ER)ROR: <&sysmacroname>: Macro not executed properly;   
%end;
 
  %Exitmacro:;

%mend log_chk;
