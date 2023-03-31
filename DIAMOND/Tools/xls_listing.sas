
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: xls_listing
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


%macro xls_listing
  (title1=,
   title2=,
   title3=,
   title4=, 
   title5=, 
   title6=, 
   header_dataset=,
   header_varlabels=1,
   header_varnames=1, 
   in_dataset=,
   columns_width=AUTO,
   incomp_formats_solving=0,  
     /*Incompatibile with XLS formats resolving way: 
          0 - no action; 
          1 - add formatted column; 
          2 - replace column with formatted one and modifying label and varname;
          3 - replace column with formatted one keeping label and varname not changed
       time format is always converted to character regardles seting of option incomp_formats_solving 
     */
   rowformat_info_var=,
   footnote1=,
   footnote2=,
   footnote3=, 
   footnote4=, 
   footnote5=, 
   out_dir=,
   out_file=
  );

  %let in_dataset=%sysfunc(upcase(&in_dataset)); 

  %let columns_width=%sysfunc(upcase(&columns_width)); 


  %local 
    nb_of_columns 
    nb_of_rows_title
    nb_of_rows_header
    nb_of_rows_data
    nb_of_rows_footnote;

  options noxwait xsync;
  
  %local lib dataset;
  %if %index(&in_dataset,.) ne 0 %then
    %do;
      %let lib=%substr(&in_dataset,1,%index(&in_dataset,.)-1);
      %let dataset=%substr(&in_dataset,%index(&in_dataset,.)+1);
    %end;  
  %else
    %do;
      %let lib=WORK;
      %let dataset=&in_dataset;
    %end;  

  proc sql;
    create table __columns as
      select *
      from dictionary.columns
      where libname="&lib" 
        and memname="&dataset"
        and memtype in ('DATA','VIEW')
      order by varnum;
  quit;

  filename temp catalog 'work.temp.temp1.source';

  %local out_dataset;
  %let out_dataset=&dataset._EXPORT;

  %macro _check_format;
    _format=compress(format,'$1234567890.');
    if _format='' then 
      _format_ok=1;
    else
      do;
        _format=trim(translate(substr(format,1,index(format,'.')-1),repeat(' ',10),'0123456789'));  
        if _format in ('BEST','DATE','') then
          _format_ok=1;
        if _format in ('TIME') then
          do;
            _format_ok=1;
            _time_format=1;
          end;
      end;
  %mend;

  data _null_;
    set __columns end=_end;
    length line $1000;
    file temp;
    if _n_=1 then
      do;
        put 'proc sql;';
        put "  create table &out_dataset as";
        put '    select ';
      end;
    %_check_format;
    if _format_ok then
      do;
        if _time_format then
          line='put('!!trim(name)!!','!!trim(format)!!') as '!! trim(name)
             !! ' label='''!!trim(label)!!'''';
        else  
          line= trim(name);
        if not _end then 
           line=trim(line)!!',';
        put '      ' line; 
      end;
    else
      select(&incomp_formats_solving);
        when(0) 
          do;
            line=trim(name);
            if not _end then 
              line=trim(line)!!',';
            put '      ' line; 
          end;
        when(1) 
          do;
            line=trim(name)!!',';
            put '      ' line; 
            line='put('!!trim(name)!!','!!trim(format)!!') as '!! trim(name)!!'_tx_'
              !! ' label='!!quote(trim(label)!!' (char)');
            if not _end then
              line=trim(line)!!',';
            put '      ' line;                
          end;
        when(2) 
          do;
            line='put('!!trim(name)!!','!!trim(format)!!') as '!! trim(name)!!'_tx_'
              !! ' label='!!quote(trim(label)!!' (char)');
            if not _end then
              line=trim(line)!!',';
            put '      ' line;                
          end;
        when(3) 
          do;
            line='put('!!trim(name)!!','!!trim(format)!!') as '!! trim(name)
              !! ' label='!!quote(trim(label));
            if not _end then
              line=trim(line)!! ',';
            put '      ' line;                
          end;
      end; 

    if _end then
      do;
        put "    from &in_dataset;";
        put 'quit;';
      end;
  run;
  %include temp /source2;   

  %local full_path;
  data _null_;
    dir=&out_dir;
    file=&out_file;
    x=tranwrd(dir!!'\'!!file,'%','%nrstr(%%)');
    full_path=tranwrd(x,'&','%nrstr(&)');
    call symput('full_path',quote(trim(full_path)));
  run;

  
  data _null_;
    if 0 then set &out_dataset nobs=nobs;
    if nobs>65536-20/* 20 reserved for header and footnote*/ then
      put 'ER' 'ROR: CHECK: Dataset has to many observations. Export will be incorrect';
  run;

  data &out_dataset.xls;
    set &out_dataset %if "&rowformat_info_var" ne "" %then %str((drop=&rowformat_info_var));;
  run;

  
  %local x_command;
  data null;
    call symput('x_command',quote('del ' !! quote(trim(&full_path)) !! ' /Q'));
  run;
  %put OS command: &x_command;
  x &x_command;
  
  filename fref_del &full_path; 
  %if %sysfunc(fexist(fref_del)) %then
    %do;
      %if %sysfunc(fdelete(fref_del)) %then
        %do;
          %put %str(ERR)OR: Unable to delete file;
        %end;
    %end;
  filename fref_del clear;


  proc export
    data=&out_dataset.xls
    outfile=&full_path 
    dbms=excel
    replace;
  run;


  proc sql noprint;
    select count(*) into: nb_of_columns 
      from dictionary.columns
      where libname='WORK' 
        and memname="&out_dataset"
        and memtype='DATA'
        and upcase(name) ne upcase("&rowformat_info_var");
  quit; 

  data _null_;
    if 0 then set &out_dataset nobs=nobs;
    call symput('nb_of_rows_data',compress(put(nobs,best.))); 
  run;
    
  /*------open Excel environment*/
*options noxsync;
*x """&excel_path""";
data _null_;
  rc=system("Start Excel");
run;
*options xsync;  
data _null_;
    x=sleep(5);
  run;
  filename sas2xls dde 'excel|system';
  data _null_;
    file sas2xls;
    put '[e' 'rror(false)]';
  run;
  
  /*------open file in Excel*/
  data _null_;
    file sas2xls;
    ddecmd='[open("'!! &full_path !! '")]';
    put ddecmd;
  run;

  *adding header rows;
  %let nb_of_rows_header=1;
  %if &header_varnames=0  %then
    %do;
      data _null_;
        file sas2xls;
        put '[select("R1C1")]';
        put '[EDIT.DELETE(3)]';
      run;
      %let nb_of_rows_header=%eval(&nb_of_rows_header-1);
    %end;
  %if &header_varlabels=1 %then
    %do;
      data _null_;
        file sas2xls;
        put '[select("R1C1")]';
        put '[insert(3)]';
      run;
      /*Updating labels*/
      proc sql; 
        create table labels as
          select label
          from dictionary.columns
          where libname='WORK' 
            and memname="&out_dataset"
            and memtype='DATA'
            and upcase(name) ne upcase("&rowformat_info_var")
          order by varnum;
      quit;
      data _null_;
        set labels end=_end;
        file sas2xls;
        length ddecmd $1000;
        retain col_nb 0;
        length ddecmd $1000;
        col_nb+1;
        ddecmd ='[select("R1C'!! trim(left(put(col_nb,best8.))) !!'")]';
        put ddecmd;
        ddecmd='[FORMULA("'''!! trim(label) !!'")]';
        put ddecmd;
      run;
      %let nb_of_rows_header=%eval(&nb_of_rows_header+1);
    %end;
  %if &header_dataset ne %then
    %do;
       %local i;
     %put &header_dataset;
       data _null_;
         file sas2xls;
         set &header_dataset end=end;
         length ddecmd $1000;
         ddecmd='[select("R'!! compress(put(_n_,best.)) !! 'C1")]';
         put ddecmd;
         put '[insert(3)]';
       %do i=1 %to &nb_of_columns;
         ddecmd ='[select("R'!! compress(put(_n_,best.)) !! 'C'!! trim(left(put(&i,best8.))) !!'")]';
         put ddecmd;
         ddecmd='[FORMULA("'''!! trim(col&i) !!'")]';
         put ddecmd;
       %end;
         if end then
           call symput('nb_of_rows_header',compress(put(&nb_of_rows_header+_n_,best.)));
       run; 
    %end;
  
  *Adding title rows;
  %let nb_of_rows_title=0;
  %local i;
  %do i=6 %to 1 %by -1;
    %if &&title&i ne %then
      %do;
        data _null_;
          file sas2xls;
          length ddecmd $1000;
          put '[select("R1C1")]';
          put '[insert(3)]';
          put '[select("R1C1")]';
          ddecmd='[FORMULA("'''!! &&title&i !!'")]';
          put ddecmd;
        run;
        %let nb_of_rows_title=%eval(&nb_of_rows_title+1);
      %end;
  %end;

  *Adding footnote rows;
  %let nb_of_rows_footnote=0;
  %local i;
  %do i=1 %to 5;
    %if &&footnote&i ne %then
      %do;
        data _null_;
          file sas2xls;
          length ddecmd $1000;
          ddecmd= '[select("R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header+&nb_of_rows_data+&nb_of_rows_footnote+1,best.))!!'C1")]';
          put ddecmd;
          ddecmd='[FORMULA("'''!! &&footnote&i !!'")]';
          put ddecmd;
        run;
        %let nb_of_rows_footnote=%eval(&nb_of_rows_footnote+1);
      %end;
  %end;
  
  *font size;
  data _null_;
    file sas2xls;
    length ddecmd $1000;
    ddecmd='[select("R1C1:R'
      !!compress(put(&nb_of_rows_title+&nb_of_rows_header+&nb_of_rows_data+&nb_of_rows_footnote,best.))
      !!'C'!!compress(put(&nb_of_columns,best8.))!!'")]';
    put ddecmd;
    put '[FONT.PROPERTIES(,,8)]';
  run;
   
  
  *title formating;
  %if &nb_of_rows_title ne 0 %then
    %do;
      data _null_;
        file sas2xls;
        length ddecmd $1000;
        ddecmd='[select("R1C1:R' !! compress(put(&nb_of_rows_title,best.)) !! 'C1")]';
        put ddecmd;
        put '[FONT.PROPERTIES(,"bold")]';
      run;
    %end;

  *header font and background formating;
  %if &nb_of_rows_header ne 0 %then
    %do;
      data _null_;
        file sas2xls;
        length ddecmd $1000;
        ddecmd='[select("R' !! compress(put(&nb_of_rows_title+1,best.)) 
          !! 'C1:R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.))
          !! 'C' !! compress(put(&nb_of_columns,best.)) !! '")]';
        put ddecmd;
        put '[FONT.PROPERTIES(,"bold")][PATTERNS(1,,15)]';
      run;
    %end;

  
  *header and data border;
  data _null_;
    file sas2xls;
    length ddecmd $1000;
    ddecmd='[select("R' !! compress(put(&nb_of_rows_title+1,best.)) 
      !! 'C1:R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header+&nb_of_rows_data,best.))
      !! 'C' !! compress(put(&nb_of_columns,best.)) !! '")]';
    put ddecmd;
    put '[border(1,1,1,1,1,,0,0,0,0,0)]';  run;
  run;


  *COLUMN WIDTH;
  proc sql;
    create table __columns as
      select *
      from dictionary.columns
      where libname="WORK" 
        and memname="&out_dataset"
        and memtype ='DATA'
        and upcase(name) ne upcase("&rowformat_info_var")
      order by varnum;
  quit;
  
  data &out_dataset.2;
    if nobs ne 0 then set &out_dataset nobs=nobs;
  run;

  filename temp catalog 'work.temp.temp2.source';

  data _null_;
    set __columns end=_end;
    length line $1000;
    file temp;
    if _n_=1 then
      do;
        put 'proc sql;';
        put "  create table __column_width as";
        put '    select ';
      end;
    %_check_format;

    if format ne '' and _format_ok then
      line='max(length(put('!!trim(name)!!','!!trim(format)!!')))';
    else if type='char' then
      line='max(length('!!trim(name)!!'))';
    else
      line='max(length(left(put('!!trim(name)!!',best20.))))';

    line=trim(line)!!' as C'!!left(put(_n_,best12.));
    if not _end then
      line=trim(line)!!',';
    put '      ' line; 

    if _end then
      do;
        put "    from &out_dataset.2;";
        put 'quit;';
      end;
  run;

  data __columns_header_width(keep=varnum ch_length);
    set __columns;
    ch_length=0;
    %if &header_varlabels=1 %then
      %str(ch_length=max(ch_length,length(label)););
   %if &header_varnames=1 %then 
      %str(ch_length=max(ch_length,length(name)););
  run;
  proc transpose prefix=ch
    data= __columns_header_width
    out= __columns_header_width;
    var ch_length;
    id varnum;
  run;

  %include temp /source2;   

  %local i;
  *setting width of columns;
  data _null_;
    file sas2xls;
    set __column_width;
    set __columns_header_width;

    array c[&nb_of_columns];
    array ch[&nb_of_columns];

    %do i=1 %to &nb_of_columns;
      %if %scan(&columns_width,&i) eq A 
        or %scan(&columns_width,&i) eq AUTO
        or %scan(&columns_width,&i) eq %then 
        %do;  
          if c[&i]<10 then
            width=min(max(c[&i],ch[&i],2),10);
          else if c[&i]>25 then width=25;
          else width=c[&i];
        %end;
      %else
        %do;
          width=%scan(&columns_width,&i);
        %end;
      ddecmd= '[COLUMN.WIDTH('!!compress(put(width,best8.))!!',"C'!!compress(put(&i,best8.))!!'")]';
      put ddecmd; 
    %end; 
  run;
 
  *formatting rows according to rowformat_info_var parameter;
  %if "&rowformat_info_var" ne "" %then
    %do;
      %if "&header_dataset" ne "" %then
        %do;
           data _null_;
             file sas2xls;
             set &header_dataset;
             ddecmd='[select("R' !! compress(put(&nb_of_rows_title+_n_,best.)) 
               !! 'C1:R' !! compress(put(&nb_of_rows_title+_n_,best.))
               !! 'C' !! compress(put(&nb_of_columns,best.)) !! '")]';
             put ddecmd;
             put &rowformat_info_var;
           run; 
        %end; 
       data _null_;
         file sas2xls;
         set &in_dataset;
         ddecmd='[select("R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header+_n_,best.)) 
           !! 'C1:R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header+_n_,best.))
           !! 'C' !! compress(put(&nb_of_columns,best.)) !! '")]';
         put ddecmd;
         put &rowformat_info_var;
       run; 
    %end;

  *allignment and wrapping of contents;
  data _null_;
    file sas2xls;
    length ddecmd $1000;
    ddecmd='[select("R' !! compress(put(&nb_of_rows_title+1,best.)) !! 'C1:R'
      !!compress(put(&nb_of_rows_title+&nb_of_rows_header+&nb_of_rows_data,best.))
            !!'C'!!compress(put(&nb_of_columns,best8.))!!'")]';
    put ddecmd;
    put '[ALIGNMENT(,1,1)]';
  run;

  *---- autofilter, freeze panels;
  data _null_;
    file sas2xls;
    length ddecmd $1000;
    ddecmd='[select("R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.)) 
      !! 'C1:R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.)) 
      !! 'C'!!compress(put(&nb_of_columns,best8.))!!'")]';
    put ddecmd;
    put '[filter()]'; 
    ddecmd='[FREEZE.PANES("true",0,'!! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.)) !!')]';
    put ddecmd;
  run;
 
  *------- printing setting ;
  data _null_;
    file sas2xls;
    length ddecmd $1000;
    orient='2';
    ddecmd='[PAGE.SETUP("","&L&IFile: &F&R&IPage &P of &N",0.25,0.25,0.25,0.5,,,,,'!!orient!!',9,,,2,,,,0)]';
    put ddecmd;
    ddecmd= '[SET.PRINT.TITLES("R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.)) 
      !! ':R' !! compress(put(&nb_of_rows_title+&nb_of_rows_header,best.)) !! '","")]';
    put ddecmd;
  run;


  *saving and closing;
  data _null_;
    file sas2xls;
    put '[select("R1C1:R1C1")][save()][close()][quit()]';
  run;
  
  %exit:

%mend; 
