
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: set_formats
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
03MAR2016 (v1.2)  Added f_dimensions_L4
                  Fixed issue for f_stats_MEAN_STD where SD had only 1 decimal
----------------------------------------------------------------------------------------------------------------------
          Modification Code: 001
                Modified By: Elena Berdichevskaya
       Date of Modification: 30-Jun-2016
         Description/Reason: Q1 and Q3 formats added, STDERR format updated for 0049/0313 study acc. to
                             sponsor requirements
----------------------------------------------------------------------------------------------------------------------
        Modification Code: 002
                Modified By: Hagen Reis
       Date of Modification: 25-Jun-2016
         Description/Reason: extend F_STATS_MIN / F_STATS_MAX 
----------------------------------------------------------------------------------------------------------------------
************************************************************************************************;


%macro set_formats;

*** Formats used in presentation data; 
proc format library=work;
  picture pval3v (round)
    low-<0.001='<0.001' (noedit)
    0.001-0.999='9.999'
    0.999-high='>0.999' (noedit);
/* 
  picture pctp (round)
    0            = " " 
    0  <-< .0995 = "009.0%)" (prefix='(' multiplier=1000)
    .0995 -< 1   = " 09.0%)" (prefix='(' multiplier=1000)
    1 - high     = "00000%)" (prefix='(' multiplier=100)
    other = " ";
*/
  picture pctp (round)
    0               = " " 
    0  <-< .0995    = "009.0%" (multiplier=1000)
    .0995 -< .09995 = " 09.0%" (multiplier=1000)
    .09995 - high   = "00000%" (multiplier=100)
    other = " ";

  picture pct (round)
    0               = " " 
    0  <-< .0995    = "0009.0)" (prefix='(' multiplier=1000)
    .0995 -< .09995 = "0 09.0)" (prefix='(' multiplier=1000)
    .09995 - high   = "0000.0)" (prefix='(' multiplier=1000) 
    other = " ";

  picture newpct (round)
    0               = " " 
	0 < -< 0.0995 ="<0009.0)" (prefix='(' multiplier=1000)
    /*0.1  <-< .0995    = "0009.0)" (prefix='( ' multiplier=1000)*/
    .0995 -< .09995 = "0 09.0)" (prefix='(' multiplier=1000)
    .09995 - high   = "0000.0)" (prefix='(' multiplier=1000) 
    other = " ";
run;

*** Formating expressions;
%macro _set_format(name=,from_format=,value=);
  %global &name;
  %if &from_format ne  %then
    %let &name=&&&from_format;
  %else  
    %let &name=&value;
%mend;

*** Default formating expressions;
%_set_format(name=f_nobsnew         ,value='put(n1#,5.)!!" "!!put(n3#,newpct.)' )
%_set_format(name=f_nobs_pct         ,value='put(n1#,5.)!!" "!!put(n3#,pct.)' )
%_set_format(name=f_nobs_nopct       ,value='put(n1#,5.)')

%_set_format(name=f_stats_N            ,value='put(n1#,5.)');
%_set_format(name=f_stats_MEAN         ,value='put(n1#,%eval(7+&decimal).%eval(1+&decimal))');
%_set_format(name=f_stats_STD          ,value='put(n1#,%eval(8+&decimal).%eval(2+&decimal))');
*%_set_format(name=f_stats_STDERR       ,from_format=f_stats_STD);
%_set_format(name=f_stats_STDERR       ,value='put(n1#,%eval(9+&decimal).%eval(3+&decimal))');
%_set_format(name=f_stats_MEDIAN       ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_MIN          ,value='put(n1#,%eval(6+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))');
%_set_format(name=f_stats_MAX          ,from_format=f_stats_MIN);
%_set_format(name=f_stats_Q1           ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_Q3           ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_MEAN_STD     ,value='put(n1#,%eval(6+&decimal).%eval(1+&decimal))!!" ("!!compress(put(n2#,%eval(7+&decimal).%eval(2+&decimal))!!")")');
%_set_format(name=f_stats_MIN_MAX      ,value='put(n1#,%eval(5+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))!!", "!!put(n2#,%eval(5+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))');
%_set_format(name=f_stats_LCLM         ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_UCLM         ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_LCLM_UCLM    ,value='put(n1#,%eval(6+&decimal).%eval(1+&decimal))!!"; "!!put(n2#,%eval(6+&decimal).%eval(1+&decimal))')
%_set_format(name=f_stats_GMT          ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_GMTLCLM      ,from_format=f_stats_MEAN);
%_set_format(name=f_stats_GMTUCLM      ,from_format=f_stats_MEAN);

%_set_format(name=f_dimensions_L0_0    ,value='put(n1#,5.)!!" "!!put(n3#,pct.)');
%_set_format(name=f_dimensions_L0_0S   ,value='put(n1#,5.)!!" "!!put(n3#,pct.)');
%_set_format(name=f_dimensions_L0_0E   ,value='put(n4#,8.)');
%_set_format(name=f_dimensions_L0_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L1_0    ,value='put(n1#,5.)!!" "!!put(n3#,pct.)')
%_set_format(name=f_dimensions_L1_0S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L1_0E   ,from_format=f_dimensions_L0_0E)
%_set_format(name=f_dimensions_L1_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L2_0    ,value='put(n1#,5.)!!" "!!put(n3#,pct.)')
%_set_format(name=f_dimensions_L2_0S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L2_0E   ,from_format=f_dimensions_L0_0E)
%_set_format(name=f_dimensions_L2_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L3_0    ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L3_0S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L3_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L3_0E   ,from_format=f_dimensions_L0_0E)
%_set_format(name=f_dimensions_L4_0    ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L4_0S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L4_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimensions_L4_0E   ,from_format=f_dimensions_L0_0E)
%_set_format(name=f_dimensions_L0_1   ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L1_1   ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L2_1   ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L3_1   ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimensions_L4_1   ,from_format=f_dimensions_L0_0)
*** END - Default formating expressions;

*** Additional formating expressions;
%_set_format(name=f_dimINT3T_L0_0   ,value='%fmt_repeat(expression=%str(put(n1#,5.)!!" "!!put(n3#,pct.)),nb=4,overlay=6,separator=" ")');
%_set_format(name=f_dimINT3T_L0_0S  ,value='""');
%_set_format(name=f_dimINT3T_L1_0   ,from_format=f_dimINT3T_L0_0);
%_set_format(name=f_dimINT3T_L2_0   ,from_format=f_dimINT3T_L0_0);
%_set_format(name=f_dimINT3T_L3_0   ,from_format=f_dimINT3T_L0_0);
%_set_format(name=f_dimINT3T_L1_0S  ,from_format=f_dimINT3T_L0_0S);
%_set_format(name=f_dimINT3T_L2_0S  ,from_format=f_dimINT3T_L0_0S);
%_set_format(name=f_dimINT3T_L3_0S  ,from_format=f_dimINT3T_L0_0S);

%_set_format(name=f_dimSEV5N_L0_0   ,value='%fmt_repeat(expression=%str(put(n1#,5.)!!" "!!put(n3#,pct.)),nb=5,overlay=6,separator="")');
%_set_format(name=f_dimSEV5N_L0_0S  ,value='""');
%_set_format(name=f_dimSEV5N_L1_0   ,from_format=f_dimSEV5N_L0_0);
%_set_format(name=f_dimSEV5N_L2_0   ,from_format=f_dimSEV5N_L0_0);
%_set_format(name=f_dimSEV5N_L3_0   ,from_format=f_dimSEV5N_L0_0);
%_set_format(name=f_dimSEV5N_L1_0S  ,from_format=f_dimSEV5N_L0_0S);
%_set_format(name=f_dimSEV5N_L2_0S  ,from_format=f_dimSEV5N_L0_0S);
%_set_format(name=f_dimSEV5N_L3_0S  ,from_format=f_dimSEV5N_L0_0S);
%_set_format(name=f_dimSEV5N_L1_1   ,from_format=f_dimSEV5N_L0_0);
%_set_format(name=f_dimSEV5N_L2_1   ,from_format=f_dimSEV5N_L0_0);

%_set_format(name=f_dimSUBJEV_L0_0   ,value='put(n1#,5.)!!" "!!put(n3#,pct.)!!" "!!put(n4#,4.)');
%_set_format(name=f_dimSUBJEV_L0_0S  ,value='""');
%_set_format(name=f_dimSUBJEV_L1_0   ,from_format=f_dimSUBJEV_L0_0);
%_set_format(name=f_dimSUBJEV_L2_0   ,from_format=f_dimSUBJEV_L0_0);
%_set_format(name=f_dimSUBJEV_L3_0   ,from_format=f_dimSUBJEV_L0_0);
%_set_format(name=f_dimSUBJEV_L1_0S  ,from_format=f_dimSUBJEV_L0_0S);
%_set_format(name=f_dimSUBJEV_L2_0S  ,from_format=f_dimSUBJEV_L0_0S);
%_set_format(name=f_dimSUBJEV_L3_0S  ,from_format=f_dimSUBJEV_L0_0S);

%_set_format(name=f_dimNDENOMPERC_L0_0   ,value='put(n7#,5.)!!"/"!!put(n13#,5.)!!" "!!put(n7#/n13#,pct.)');
%_set_format(name=f_dimNDENOMPERC_L0_0S  ,value='""');
%_set_format(name=f_dimNDENOMPERC_L1_0   ,from_format=f_dimNDENOMPERC_L0_0);
%_set_format(name=f_dimNDENOMPERC_L2_0   ,from_format=f_dimNDENOMPERC_L0_0);
%_set_format(name=f_dimNDENOMPERC_L3_0   ,from_format=f_dimNDENOMPERC_L0_0);
%_set_format(name=f_dimNDENOMPERC_L1_0S  ,from_format=f_dimNDENOMPERC_L0_0S);
%_set_format(name=f_dimNDENOMPERC_L2_0S  ,from_format=f_dimNDENOMPERC_L0_0S);
%_set_format(name=f_dimNDENOMPERC_L3_0S  ,from_format=f_dimNDENOMPERC_L0_0S);

%_set_format(name=f_dimGRADE4_L0_0    ,value='put(n1#,5.)!!" "!!put(n3#,pct.)');
%_set_format(name=f_dimGRADE4_L0_0S   ,value='put(n1#,5.)!!" "!!put(n3#,pct.)');
%_set_format(name=f_dimGRADE4_L0_0E   ,value='put(n4#,8.)');
%_set_format(name=f_dimGRADE4_L0_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimGRADE4_L1_0    ,value='put(n1#,4.)!!" "!!put(n3#,pct.)');
/*%_set_format(name=f_dimGRADE4_L1_0    ,value=' ')*/
%_set_format(name=f_dimGRADE4_L1_0T   ,value=' ')
%_set_format(name=f_dimGRADE4_L1_0S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimGRADE4_L1_0E   ,from_format=f_dimensions_L0_0E)
%_set_format(name=f_dimGRADE4_L1_1S   ,from_format=f_dimensions_L0_0S)
%_set_format(name=f_dimGRADE4_L0_1    ,from_format=f_dimensions_L0_0)
%_set_format(name=f_dimGRADE4_L1_1    ,from_format=f_dimensions_L0_0)
/*%_set_format(name=f_dimGRADE4_L1_9    ,from_format=f_dimensions_L0_0)*/
%_set_format(name=f_dimGRADE4_L2_1    ,from_format=f_dimensions_L0_0)


*** END - Additional formating expressions;

*** study related;
%_set_format(name=f_nobs_pct2         ,value='put(n1#,5.)!!" "!!put(n3#,pct.)' );
%_set_format(name=f_nobs_nopct2       ,value='put(n1#,5.)');

%_set_format(name=f_nobs2_pct         ,value='put(n1#,5.)!!" "!!put(n3#,pctp.)' );
%_set_format(name=f_nobs2_nopct       ,value='put(n1#,5.)');

%_set_format(name=f_dimQT_L0_0    ,value='put(n1#,5.)!!" "!!put(n3#,pct.)');
%_set_format(name=f_dimQT_L1_0    ,from_format=f_dimQT_L0_0)
%_set_format(name=f_dimQT_L1_1    ,from_format=f_dimQT_L0_0)

%_set_format(name=f_stats2_N            ,value='put(n1#,5.)')
%_set_format(name=f_stats2_MEAN         ,value='put(n1#,6.1)')
%_set_format(name=f_stats2_STD          ,value='put(n1#,6.1)')
%_set_format(name=f_stats2_MEDIAN       ,from_format=f_stats2_MEAN)
%_set_format(name=f_stats2_Q1           ,from_format=f_stats2_MEAN)
%_set_format(name=f_stats2_Q3           ,from_format=f_stats2_MEAN)
%_set_format(name=f_stats2_MIN          ,value='put(n1#,6.1)')
%_set_format(name=f_stats2_MAX          ,from_format=f_stats2_MIN)

%_set_format(name=f_stats3_N            ,value='put(n1#,7.)')
%_set_format(name=f_stats3_MEAN         ,value='put(n1#,%eval(7+1+&decimal+1).%eval(1+&DECIMAL))')
%_set_format(name=f_stats3_STD          ,value='put(n1#,%eval(7+1+&decimal+2).%eval(2+&DECIMAL))')
%_set_format(name=f_stats3_MEDIAN       ,from_format=f_stats3_MEAN)
%_set_format(name=f_stats3_Q1           ,from_format=f_stats3_MEAN)
%_set_format(name=f_stats3_Q3           ,from_format=f_stats3_MEAN)
%_set_format(name=f_stats3_MIN          ,value='put(n1#,%eval(7+(&decimal ne 0)+&decimal).%eval(&DECIMAL))')
%_set_format(name=f_stats3_MAX          ,from_format=f_stats3_MIN)
%_set_format(name=f_stats_Q1_Q3         ,value='put(n1#,%eval(7+&decimal).%eval(1+&decimal))!!", "!!put(n2#,%eval(7+&decimal).%eval(1+&decimal))');

%_set_format(name=f_statsEG_N_MEAN_MBASE_MCHG  ,value='put(n1#,5.)!!put(n2#,8.1)!!put(n3#,7.1)!!put(n4#,7.1)');

%_set_format(name=f_events_N            ,value='put(n1#,5.)');
%_set_format(name=f_events_MEAN         ,value='put(n1#,%eval(6+&decimal).%eval(2+&decimal))');
%_set_format(name=f_events_STD          ,value='put(n1#,%eval(7+&decimal).%eval(3+&decimal))');
%_set_format(name=f_events_MEDIAN       ,from_format=f_events_MEAN);
%_set_format(name=f_events_MIN          ,value='put(n1#,%eval(5+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))');
%_set_format(name=f_events_MAX          ,from_format=f_events_MIN);
%_set_format(name=f_events_Q1           ,from_format=f_events_MEAN);
%_set_format(name=f_events_Q3           ,from_format=f_events_MEAN);
%_set_format(name=f_events_MIN_MAX      ,value='put(n1#,%eval(5+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))!!", "!!put(n2#,%eval(5+(&decimal+1)*(&decimal>0)).%eval(&DECIMAL))');
%_set_format(name=f_events_Q1_Q3         ,value='put(n1#,%eval(6+&decimal).%eval(2+&decimal))!!", "!!put(n2#,%eval(6+&decimal).%eval(2+&decimal))');

%_set_format(name=f_dimensions1_L0_0    ,value='put(n1#,4.)!!compbl(put(n3#,pctp.))');
%_set_format(name=f_dimensions1_L0_0S   ,value='put(n1#,4.)!!compbl(put(n3#,pctp.))');
%_set_format(name=f_dimensions1_L0_0E   ,value='put(n4#,8.)');
%_set_format(name=f_dimensions1_L0_1S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L1_0    ,value='put(n1#,4.)!!compbl(put(n3#,pctp.))')
%_set_format(name=f_dimensions1_L1_0S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L1_0E   ,from_format=f_dimensions1_L0_0E)
%_set_format(name=f_dimensions1_L1_1S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L2_0    ,value='put(n1#,4.)!!compbl(put(n3#,pctp.))')
%_set_format(name=f_dimensions1_L2_0S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L2_0E   ,from_format=f_dimensions1_L0_0E)
%_set_format(name=f_dimensions1_L2_1S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L3_0    ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L3_0S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L3_1S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L3_0E   ,from_format=f_dimensions1_L0_0E)
%_set_format(name=f_dimensions1_L4_0    ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L4_0S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L4_1S   ,from_format=f_dimensions1_L0_0S)
%_set_format(name=f_dimensions1_L4_0E   ,from_format=f_dimensions1_L0_0E)
%_set_format(name=f_dimensions1_L0_1   ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L1_1   ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L2_1   ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L3_1   ,from_format=f_dimensions1_L0_0)
%_set_format(name=f_dimensions1_L4_1   ,from_format=f_dimensions1_L0_0)

%_set_format(name=f_dimint_L1_0   ,value='%fmt_repeat(expression=%str(put(n1#,4.)!!" "!!put(n3#,pct.)),nb=6,overlay=6,separator=" ")');
%mend;
/*%set_formats;*/
