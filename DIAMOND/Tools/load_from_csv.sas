
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: load_from_csv
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


%macro load_from_csv(
  in_file=,
  out_lib=WORK, 
  out_datset=
  );

%local 
  list_of_columns 
  list_of_types 
  quoted_list_of_columns 
  count_of_columns;

proc sql noprint;
  select 
    name,
    type,
    quote(name)
      into 
        :list_of_columns separated by ' ',
        :list_of_types separated by ' ',
        :quoted_list_of_columns separated by ' '
    from dictionary.columns
    where libname=upcase("&out_lib") and memname=upcase("&out_datset");
  select count(*) into :count_of_columns
    from dictionary.columns
    where libname=upcase("&out_lib") and memname=upcase("&out_datset");
quit;
***;

***Source data;
data &out_lib..&out_datset;
  if 0 then set &out_lib..&out_datset;
  infile &in_file dsd missover lrecl = 10000;
  
  array _names[&count_of_columns] $20 _temporary_ (&quoted_list_of_columns);
  *array _types[&count_of_columns] $20 _temporary_ (&list_of_types);
  array _tmp_col[&count_of_columns] $1000;
   
  if _n_=1 then
    do;
      do i=1 to &count_of_columns;
        input _tmp_col[i] @;
        if _tmp_col[i] ne _names[i] then
          put "ER" "ROR: CHECK: Wrong column " i ". Expected: " _names[i] ". Loaded: " _tmp_col[i];
      end;
      input;
      delete;
    end;
  else
    do;
%do i=1 %to &count_of_columns;
      input _tmp_col[&i] @;
  %if %scan(&list_of_types,&i)=char %then
    %do;
      %scan(&list_of_columns,&i)=_tmp_col[&i];
      if %scan(&list_of_columns,&i) ne _tmp_col[&i] then
        put "ER" "ROR: CHECK: Wrong length of column %scan(&list_of_columns,&i) " _n_=;
    %end; 
  %if %scan(&list_of_types,&i)=num %then
    %do;
      %scan(&list_of_columns,&i)=input(left(_tmp_col[&i]),best18.);
      if _error_ then
        put "ER" "ROR: CHECK: Wrong conversion to numeric format"  _tmp_col[&i]=;
    %end; 
%end;
      input;
    end;
run;
%mend;
