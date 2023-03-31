
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: titles
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
24FEB2016 (v1.2)  output_mode=LST is added.
28OCT2016 (v2.0)  Removed style for output_mode=ODS_RTF.
				  Create output_mode=ODS_RTF with title in header of word document
				  Create output_mode=INTEXT with study title in header of word document 
						and report title in header of table
----------------------------------------------------------------------------------------------------------------------
          Modification Code: 001
                Modified By: Elena Berdichevskaya
       Date of Modification: 20-Dec-2016
         Description/Reason: First title ('Protocol: ...' adapted for 0049/0313 study acc. to
                             sponsor requirements
----------------------------------------------------------------------------------------------------------------------
         Modification Code: 002
                Modified By: Elena Berdichevskaya
       Date of Modification: 18-Apr-2017
         Description/Reason: Bold font setting added for second title.
----------------------------------------------------------------------------------------------------------------------
****************************************************************************************************;

****************************************************************************************************;


%macro titles(
  title_ver=&tit_ver,
  no_line=0,
  just=c,
  titles_extra_line=
  );

%if &output_mode=TXT_RTF or &output_mode=LST %then
  %do;

    %local string line nb i;

    /*ICON standard*/
    %if &title_ver = ICON %then %do;

       %let line=%sysfunc(repeat(_,&&&orient._LS-1));

       %let t1=Protocol No.: &protocol.;
       %let string =&t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 15)) Page §X of §Y;
       title1 "&string";
  /*Mod. 001*/   
 /*      %let t1=ICON Study No.: &icon_study.;
       %let string = &t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 3))§1;
       title2 "&string";
        
       title3 " "; 
*/
       %let t1=Protocol: &protocol.;
       %let string =&t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 15)) Page §X of §Y;
       title1 "&string";
     
       title2 " ";
  /* End of Mod. 001*/   

       *** Tables and Listings specific titles;
     %if %upcase(%substr(&rep,1,1)) = T or %upcase(%substr(&rep,1,1)) = L or %upcase(%substr(&rep,1,2)) = AT %then %do;  
      %if &just=l or &just=L %then %do;
         %let string = &table. &tit1.%sysfunc(repeat(%str( ),%eval(&&&Orient._LS - %length(%trim(&table)) - %length(%trim(&tit1))) ));
         title4 "&string"; 
      %end;
      %else %if &just=c or &just=C %then %do;
	    %let len = %eval(&&&Orient._LS - %length(%trim(&table)) - %length(%trim(&tit1.)) - 4 - 1);
        %let string = %sysfunc(repeat(%str( ),%eval(&len/2)))&table. &tit1.%sysfunc(repeat(%str( ),%eval(&len/2)))§1;
        title4 "&string"; 
	  %end;

       %let nb=3;
       %do i=2 %to 6;  
          %if %length(&&tit&i) ne 0 %then %do;
             %let nb=%eval(&nb+1);
             %if &just=l or &just=L %then %do;
               %let string = &&tit&i.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&&tit&i)) ))§1;
               title&nb "&string";
             %end;
             %else %if &just=c or &just=C %then %do;
 	    	   %let len = %eval(&&&Orient._LS - %length(%trim(&&tit&i)) - 4);
      		   %let string = %sysfunc(repeat(%str( ),%eval(&len/2))) &&tit&i. %sysfunc(repeat(%str( ),%eval(&len/2)));
               title&nb "&string";
             %end;
          %end;
       %end;
       %if &no_line ne 1 %then %do; 
          %let nb=%eval(&nb+1);
          title&nb "&line";  
       %end;
    %end;

    %end;

    /*Other*/
    %else %do;
  /*Mod. 001*/   
   /*   %if &just=l or &just=L %then %do;            
            %let string = &table. &tit1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&table)) + %length(%trim(&tit1))));
            title1 "&string"; 
            %let nb=1;
            %do i=2 %to 6;
                %if %length(&&tit&i) ne 0 %then
                  %do;
                    %let nb=%eval(&nb+1);
                    %let string = &&tit&i.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&&tit&i)) ));
                    title&nb "&string";
                  %end;
            %end;
       %end;      
      %else %if &just=c or &just=C %then %do;
            title1 "&table &tit1.";
            %let nb=1;
            %do i=2 %to 6;
                %if %length(&&tit&i) ne 0 %then
                  %do;
                    %let nb=%eval(&nb+1);
                    title&nb "&&tit&i";
                  %end;
            %end;
          %end;
      %end;*/
 %let line=%sysfunc(repeat(_,&&&orient._LS-1));

       %let t1=Protocol: &protocol.;
       %let string =&t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 15)) Page §X of §Y;
       title1 "&string";
        
       title2 " ";

       %let nb=2;
       %do i=1 %to 9;  
          %if %length(&&tit&i) ne 0 %then %do;
             %let nb=%eval(&nb+1);
             %if &just=l or &just=L %then %do;
                %let string = &&tit&i.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&&tit&i)) ))§1;
                title&nb "&string";
             %end;
             %else %if &just=c or &just=C %then %do;
               %if &&&Orient._LS eq %length(%trim(&&tit&i))
                 %then %do;
                   title&nb &&tit&i.;
                 %end;
                 %else %do;
 	    	      %let len = %eval(&&&Orient._LS - %length(%trim(&&tit&i)) - 4);
      		      %let string = %sysfunc(repeat(%str( ),%eval(&len/2))) &&tit&i. %sysfunc(repeat(%str( ),%eval(&len/2)));
                  title&nb "&string";
                %end;
             %end;
          %end;
       %end;

       %if &no_line ne 1 %then %do; 
          %let nb=%eval(&nb+1);
          title&nb "&line";  
       %end;

  /*End Mod. 001*/   
    %end;
  %end;
/*********************************************************************/

%else %if &output_mode=ODS_RTF %then
  %do;				/* Titles will be in the header of the word document */

    %local string line nb i;

    %if &title_ver = ICON %then 
      %do;
        %let t1=Protocol No.: &protocol.;
        %let string =&t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 22)) Page §X of §Y;
        title1 "&string";

        title2 "ICON Study No.: &icon_study.";
        title3 " ";

        title4 j=c "&table &tit1.";

		%let nb=4;
        %do i=2 %to 10;
          %if %length(&&tit&i) ne 0 %then
            %do;
               %let nb=%eval(&nb+1);
               title&nb j=c "&&tit&i";
            %end;
        %end;

        %if %length(&titles_extra_line) ne 0 %then
          %do;
		    %let nb=%eval(&nb+1);
            title&nb &titles_extra_line $&&&orient._LS..;
          %end;
      %end; 
  /*Mod. 001*/   
    %else %if &title_ver = AZ %then
      %do;
        %let t1=Protocol: &protocol.;
        %let string =&t1.%sysfunc(repeat(%str( ),&&&Orient._LS - %length(%trim(&t1)) - 6)) Page §X of §Y;
        title1 "&string";
        title2 " ";

        title3 j=c bold "&tit1.";

		%let nb=3;
        %do i=2 %to 10;
          %if %length(&&tit&i) ne 0 %then
            %do;
               %let nb=%eval(&nb+1);
               title&nb j=c bold "&&tit&i"; /*Mod. 001*/ 
            %end;
        %end;

        %if %length(&titles_extra_line) ne 0 %then
          %do;
		    %let nb=%eval(&nb+1);
            title&nb &titles_extra_line $&&&orient._LS..;
          %end;
      %end; 
  /*End Mod. 001*/  

  %end;

/*********************************************************************/

%else %if &output_mode=INTEXT %then
  %do;			/* Study titles will be in the header of the word document,
  				   Report titles will be in the header of the table */

    %local string line nb i;

    %if &title_ver = ICON %then 
      %do;
        title1 "Protocol No.: &protocol."; 
        title2 "ICON Study No.: &icon_study.";
        title3 " ";

        compute before _page_ /style=[BORDERTOPSTYLE=SOLID /*=NONE*/ BORDERTOPWIDTH=1pt];
               line @1 "&table &tit1.";

        %do i=2 %to 10;
          %if %length(&&tit&i) ne 0 %then
            %do;
               line @1 "&&tit&i";
            %end;
        %end;
        %if %length(&titles_extra_line) ne 0 %then
          %do;
            line @1 &titles_extra_line $&&&orient._LS..;
          %end;

        endcomp;
      %end;

  %end;

%else
  %put %str(E)RROR: Missing or incorrect OUTPUT_MODE;

%exit:
%mend;



