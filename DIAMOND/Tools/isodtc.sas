
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: isodtc
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


%macro isodtc(ret,y=,m=,d=,h=,min=) ;

  length _y_ $4 _m_ $3 _d_ _h_ _min_ $2;

  %if &y = %then %let y = " ";
  %if &m = %then %let m = " ";
  %if &d = %then %let d = " ";
  %if &h = %then %let h = " ";
  %if &min = %then %let min = " ";

  _d_ = upcase(compress(&d));
  _m_ = upcase(compress(&m));
  _y_ = upcase(compress(&y));
  _h_ = upcase(compress(&h));
  _min_ = upcase(compress(&min));

  if _m_ in ("1","01","JAN") then _m_ = "01";
  else if _m_ in ("2","02","FEB") then _m_ = "02";
  else if _m_ in ("3","03","MAR") then _m_ = "03";
  else if _m_ in ("4","04","APR") then _m_ = "04";
  else if _m_ in ("5","05","MAY") then _m_ = "05";
  else if _m_ in ("6","06","JUN") then _m_ = "06";
  else if _m_ in ("7","07","JUL") then _m_ = "07";
  else if _m_ in ("8","08","AUG") then _m_ = "08";
  else if _m_ in ("9","09","SEP") then _m_ = "09";
  else if _m_ in ("10","OCT") then _m_ = "10";
  else if _m_ in ("11","NOV") then _m_ = "11";
  else if _m_ in ("12","DEC") then _m_ = "12";
  else _m_ = " ";
  
  if indexc(_d_,"QWERTZUIOPASDFGHJKLYXCBVNM") then _d_ = " ";
  if indexc(_y_,"QWERTZUIOPASDFGHJKLYXCBVNM") then _y_ = " ";
  if indexc(_h_,"QWERTZUIOPASDFGHJKLYXCBVNM") then _h_ = " ";
  if indexc(_min_,"QWERTZUIOPASDFGHJKLYXCBVNM") then _min_ = " ";    

  if not missing(_d_) then _d_ = put(input(_d_,best.),z2.);
  if not missing(_h_) then _h_ = put(input(_h_,best.),z2.);
  if not missing(_min_) then _min_ = put(input(_min_,best.),z2.);
  
  if length(_y_) ne 4 and not missing(_y_) then do;
    if length(_y_) eq 2 then do;
      if input(_y_,best.) <= input(substr(getoption("yearcutoff"),3,2),2.) then _y_ = compress("20" !! _y_);
      else _y_ = compress("19" !! _y_);
      put "Note: year has been imputed as " _y_;
    end;
    else _y_ = " ";
  end;
  
  if not missing(_min_) then do;
    if missing(_y_) then _y_ = "-";
    if missing(_m_) then _m_ = "-";
    if missing(_d_) then _d_ = "-";
    if missing(_h_) then _h_ = "-";
    &ret = compress(_y_ !! "-" !! _m_ !! "-" !! _d_ !! "T" !! _h_ !! ":" !! _min_);
  end;
  else if not missing(_h_) then do;
    if missing(_y_) then _y_ = "-";
    if missing(_m_) then _m_ = "-";
    if missing(_d_) then _d_ = "-";
    &ret = compress(_y_ !! "-" !! _m_ !! "-" !! _d_ !! "T" !! _h_);
  end;
  else if not missing(_d_) then do;
    if missing(_y_) then _y_ = "-";
    if missing(_m_) then _m_ = "-";
    &ret = compress(_y_ !! "-" !! _m_ !! "-" !! _d_);
  end;
  else if not missing(_m_) then do;
    if missing(_y_) then _y_ = "-";
    &ret = compress(_y_ !! "-" !! _m_);
  end;
  else if not missing(_y_) then do;
    &ret = compress(_y_);
  end;
  else do;
    &ret = " ";
  end;

  drop _y_ _h_ _d_ _m_ _min_;

%mend isodtc;

/* EXAMPLES 


options yearcutoff = 1920;

data _null_;
  length dsdtc $20;
  %isodtc(dsdtc, d="1", m= "5", y="1995", min = "25");
  put dsdtc;
  %isodtc(dsdtc, h="06",  min = "25");
  put dsdtc;
  %isodtc(dsdtc, d="01", m= "MAY", y="25", h = "19", min = "25");
  put dsdtc;
  %isodtc(dsdtc, d="01", m = "XXX", y="05");
  put dsdtc;
run;

options yearcutoff = 1940;

data _null_;
  length dsdtc $20;
  %isodtc(dsdtc, d="01", m= "MAY", y="25", h = "19", min = "25");
  put dsdtc;
run;

*/
  
