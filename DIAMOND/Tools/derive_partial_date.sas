
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: derive_partial_date
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


%macro derive_partial_date(dropTimePart=0,inDTC=,outDTC=,outDT=,outDTF=,algorythm=DEFAULT);
  
  length __outDTC_ $20 __outDT_ 8 __outDTF_ $2 __y_ $4 __m_ __d_ $2 __timepart_ $10 __move_to_the_end 8;  
 *drop __outDTC_ __outDT_  __outDTF_  __y  __m_ __d_ __timepart_;   

  __outDTC_='';
  __outDT_=.;
  __outDTF_='';
  __y_='';
  __m_='';
  __d_='';
  __timepart_='';
  __move_to_the_end=0;

  if length(&inDTC)>=4 then
    do;
      __y_=substr(&inDTC,1,4);  
      
      if length(&inDTC)>=7 then
        do;
          __m_=substr(&inDTC,6,2);
          
          if length(&inDTC)>=10 then
            do;
              __d_=substr(&inDTC,9,2);
              if length(&inDTC)>10 and &dropTimePart=0 then
                __timepart_=substr(&inDTC,11);
            end;
          else
            do;
  %if &algorythm=DEFAULT %then
    %do;     
              __d_='15';
    %end;
  %if &algorythm=FIRST %then
    %do;     
              __d_='01';
    %end;
  %if &algorythm=LAST %then
    %do;
              __d_='01';
              __move_to_the_end=1;
    %end;
              __outDTF_='D'; 
            end; 
        end; 
      else
        do;
  %if &algorythm=DEFAULT %then
    %do;
          __m_='06';
          __d_='30';
    %end;
  %if &algorythm=FIRST %then
    %do;   
          __m_='01';
          __d_='01';
    %end;
  %if &algorythm=LAST %then
    %do;   
          __m_='12';
          __d_='31';
    %end;
          __outDTF_='M'; 
        end;
      __outDTC_=substr(__y_,4)!!'-'!!substr(__m_,2)!!substr(__d_,2)!!__timepart_;
      __outDT_=mdy(input(__m_,best.),input(__d_,best.),input(__y_,best.));
      if __move_to_the_end=1 then
        do;
          __outDT_=INTNX('MONTH',__outDT_,0,'END');
          if __outDT_ ne . then
            __outDTC_=put(__outDT_,yymmdd10.);
          else
            __outDTC_='';
        end;
    end;
  %if &outDTC ne %then
    %str(&outDTC=__outDTC_;);
  %if &outDT ne %then
    %str(&outDT=__outDT_;);
  %if &outDTF ne %then
    %str(&outDTF=__outDTF_;);
%mend derive_partial_date;
