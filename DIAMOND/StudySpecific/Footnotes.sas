
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: footnotes
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
09FEB2016 (v1.1)  Path in &fname was corrected when output_mode=ODS_RTF.
03MAR2016 (v1.2)  output_mode=LST is added.
28OCT2016 (v2.0)  Add &file_prefix before output name to prefix file name
				  Create output_mode=ODS_RTF with footnote in footer of word document
				  Create output_mode=INTEXT with study footnote in footer of word document 
						and report footnote in footer of table
----------------------------------------------------------------------------------------------
          Modification Code: 001
                Modified By: Elena Berdichevskaya
       Date of Modification: 20-Dec-2016
         Description/Reason: Last footnote (Program source) adapted for 0049-0313 study
                             acc. to AZ requirements
----------------------------------------------------------------------------------------------
          Modification Code: 002
                Modified By: Elena Berdichevskaya
       Date of Modification: 24-May-2017
         Description/Reason: Description of source datasets used in Program are added to the 
                             last footnote acc. to AZ requirements
----------------------------------------------------------------------------------------------
          Modification Code: 003
                Modified By: Elena Berdichevskaya
       Date of Modification: 04-Oct-2018
         Description/Reason: Additional output mode AZ1 added for footnotes with more than 3 
                              source datasets.
----------------------------------------------------------------------------------------------
          Modification Code: 004
                Modified By: Anke Grohl
       Date of Modification: 31-Oct-2018
         Description/Reason: Use macro variable &env. instead of "dev"
----------------------------------------------------------------------------------------------
*************************************************************************************************;


%macro footnotes(
  footnote_ver=&foot_ver
  ) ;

%if &output_mode=TXT_RTF or &output_mode=LST %then
  %do;
    %local string line nb i f1 len;

    /*ICON standard*/
    %if &footnote_ver=ICON or &footnote_ver=ICONL %then %do;    

    %let line=%sysfunc(repeat(_,&&&orient._LS-1));   
      %let nb=1;
      Compute after _page_;
      line @1 "&line";        

        %do i=1 %to 20;
          %if %length(&&foot&i) ne 0 %then %do;
            %let nb=%eval(&nb+1);
            %let len = %eval(&&&Orient._LS - %length(&&foot&i) - 3);
            %if &len > -1 %then
            %let string = &&foot&i%sysfunc(repeat(%str( ),&len))§1;
            %else %if &len = -1 %then
            %let string = &&foot&i..§1;
            %else %let string = &&foot&i..;              
            line @1 "&string";              
          %end;
        %end; 
/* Mod. 001*/
        %let nb=%eval(&nb+1);
        %let string1 = Program Source: &path.\&env.\programs\&output_subfolder.%str(&rep.).sas ; /* Mod. 001 */
        %let string2 = %sysfunc(putn(%sysfunc(today()),date9.)):%sysfunc(putn(%sysfunc(time()),time5.));
        %let len = %eval(&&&orient._LS - %length(&string1.) - %length(&string2.) - 1);
        %let string = &string1.%sysfunc(repeat(%str( ),&len))&string2.§1;    
        line @1 "&string";          
        endcomp;
        %let string = &string1.%sysfunc(repeat(%str( ),&len))&string2.§1;    
        line @1 "&string";          
        endcomp;
  %end;

      /*Other*/
    %if %upcase(&footnote_ver)=VX_IN_REPORT %then %do;

        compute after _page_;
        line @1 &&&orient._LS*'_';
        %let nb=1;
        %do i=1 %to 20;
          %if %length(&&foot&i) ne 0 %then %do;
              %let nb=%eval(&nb+1);
              line @1 "&&foot&i";
          %end;
        %end; 

        %if &nb>1 %then %do;
             line " ";
        %end;

        %let fname = &path\tablib\&draft\&file_prefix.&rep..sas;
        %let fpre =;
        %do %while(%length(Program Name: &fpre&fname) > %eval(&&&orient._LS - 40));
           %let fpre =...;
           %let fname = %substr(&fname,%index(&fname,\)+1,%length(&fname) - %index(&fname,\)  );
           %let fname = %substr(&fname,%index(&fname,\)  ,%length(&fname) - %index(&fname,\)+1);
        %end;
        %let string = Program Name: &fpre&fname;
        %let string = &string%sysfunc(repeat(%str( ),%eval(&&&orient._LS - %length(&string) - 40)))Creation Date and Time: %sysfunc(putn(%sysfunc(today()),date9.)) %sysfunc(putn(%sysfunc(time()),time5.));
        line @1 "&string";
        endcomp;
        footnote;

    %end;
 %if &footnote_ver=AZ %then %do;    

    %let line=%sysfunc(repeat(-,&&&orient._LS-1));   
      %let nb=1;
      Compute after _page_;
      line @1 "&line";        

        %do i=1 %to 20;
          %if %length(&&foot&i) ne 0 %then %do;
            %let nb=%eval(&nb+1);
            %let len = %eval(&&&Orient._LS - %length(&&foot&i) - 3);
            %if &len > -1 %then
            %let string = &&foot&i%sysfunc(repeat(%str( ),&len))§1;
            %else %if &len = -1 %then
            %let string = &&foot&i..§1;
            %else %let string = &&foot&i..;              
            line @1 "&string";              
          %end;
        %end; 
        %let nb=%eval(&nb+1);
        %let string1 = Program Source: \%str(&env.)\programs\&output_subfolder.\%str(&rep.).sas;/* Mod. 001 */
        %let string2 = %sysfunc(putn(%sysfunc(today()),date9.)):%sysfunc(putn(%sysfunc(time()),time5.));
        %let len = %eval(&&&orient._LS - %length(&string1.) - %length(&string2.) - 1);
        %let string = &string1.%sysfunc(repeat(%str( ),&len-2))&string2.§1;    
        line @1 "&string";          
        endcomp;
  %end;
  %end;


/**********************************************************************************/
%else %if &output_mode=ODS_RTF %then
  %do;					/* Footnotes will be in the footer of the word document */

    %local string line nb i;

    %if &footnote_ver=ICON %then 
      %do;
        %let line=%sysfunc(repeat(_,&&&orient._LS-1));
        footnote1 "&line";

        %let nb=1;
        %do i=1 %to 20;
          %if %length(&&foot&i) ne 0 %then
            %do;
              %let nb=%eval(&nb+1);
              footnote&nb. "&&foot&i";
            %end;
        %end; 

        %let nb=%eval(&nb+1);
        footnote&nb. "Source: &table";
        %if &nb>2 %then 
          %do;
             footnote&nb. " "; 
          %end;

        %let fname = &path\&env.\programs\tables\&file_prefix.&rep..sas;
        %let fpre =;
        %do %while(%length(Program Name: &fpre&fname) > %eval(&&&orient._LS - 40));
           %let fpre =...;
           %let fname = %substr(&fname,%index(&fname,\)+1,%length(&fname) - %index(&fname,\)  );
           %let fname = %substr(&fname,%index(&fname,\)  ,%length(&fname) - %index(&fname,\)+1);
        %end;

        %let string = Program Name: &fpre&fname;
        %let string = &string%sysfunc(repeat(%str( ),%eval(&&&orient._LS - %length(&string) - 40)))Creation Date and Time: %sysfunc(putn(%sysfunc(today()),date9.)) %sysfunc(putn(%sysfunc(time()),time5.));
        %let nb=%eval(&nb+1);
        footnote&nb. "&string";
      %end;
    %else %if &footnote_ver=AZ %then 
      %do;
        %let line=%sysfunc(repeat(_,&&&orient._LS-3));

        %let nb=0;
        %do i=1 %to 11;
          %if %length(&&foot&i) ne 0 %then
            %do;
              %let nb=%eval(&nb+1);
              footnote&nb. "&&foot&i";
            %end;
        %end; 
        %let nb=%eval(&nb+1);
        %let string1 = Program Source: \%str(&env.)\programs\%lowcase(&type.)\%str(&rep.).sas  Source Data: %str(&source_listing.);/* Mod. 001  and 002 */
        %let string2 = %sysfunc(putn(%sysfunc(today()),date9.)):%sysfunc(putn(%sysfunc(time()),time5.));
        %let len = %eval(&&&orient._LS - %length(&string1.) - %length(&string2.) - 3);
        %let string = &string1.%sysfunc(repeat(%str( ),&len))&string2.;    
        footnote&nb. "&string";
      %end;
  /* Mod. 003*/
%else %if &footnote_ver=AZ1 %then
      %do;
        %let line=%sysfunc(repeat(_,&&&orient._LS-3));

        %let nb=0;
        %do i=1 %to 11;
          %if %length(&&foot&i) ne 0 %then
            %do;
              %let nb=%eval(&nb+1);
              footnote&nb. "&&foot&i";
            %end;
        %end; 
        %let nb=%eval(&nb+1);
        %let string1 = Program Source: \%str(&env.)\programs\%lowcase(&type.)\%str(&rep.).sas  Source Data: %str(&source_listing.);/* Mod. 001  and 002 */
        %let string2 = %sysfunc(putn(%sysfunc(today()),date9.)):%sysfunc(putn(%sysfunc(time()),time5.));
        %let len = %eval(&&&orient._LS - %length(&string1.) - %length(&string2.) - 8);
        %let string = &string1.%sysfunc(repeat(%str( ),&len))&string2.;    
        footnote&nb. "&string";
      %end;
  %end;


/**********************************************************************************/
%else %if &output_mode=INTEXT %then
  %do;            /* Study footnotes will be in the footer of the word document,
  				   Report footnotes will be in the footer of the table */

    %local string line nb i;

    %if &footnote_ver=ICON %then 
      %do;
        compute after/style=[BORDERTOPSTYLE=SOLID BORDERTOPWIDTH=1pt];
        %let nb=0;
        %do i=1 %to 10;
          %if %length(&&foot&i) ne 0 %then
            %do;
              %let nb=%eval(&nb+1);
              line @1 "&&foot&i";
            %end;
        %end; 
        %let nb=%eval(&nb+1);
        line @1 "Source: &table";
        %if &nb>1 %then 
          %do;
             line " ";
          %end;

        %let fname = &path\dev\programs\tables\&file_prefix.&rep..sas;
        %let fpre =;
        %do %while(%length(Program Name: &fpre&fname) > %eval(&&&orient._LS - 40));
           %let fpre =...;
           %let fname = %substr(&fname,%index(&fname,\)+1,%length(&fname) - %index(&fname,\)  );
           %let fname = %substr(&fname,%index(&fname,\)  ,%length(&fname) - %index(&fname,\)+1);
        %end;
        endcomp;

        %let line=%sysfunc(repeat(_,&&&orient._LS-1));
        footnote1 "&line";
        %let string = Program Name: &fpre&fname;
        %let string = &string%sysfunc(repeat(%str( ),%eval(&&&orient._LS - %length(&string) - 40)))Creation Date and Time: %sysfunc(putn(%sysfunc(today()),date9.)) %sysfunc(putn(%sysfunc(time()),time5.));
        footnote2 "&string";
      %end;

  %end;
/**********************************************************************************/

%else
  %put %str(E)RROR: Missing or incorrect OUTPUT_MODE;


%exit:
%mend;
