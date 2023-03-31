
************************************************************************************************

          ICON Study Number: 0000 (Standard)
    Sponsor Protocol Number: 0001
                                                          
               Program Name: odsrtf_style
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
**************************************************************************************************;

%macro odsrtf_style;
ods rtf startpage=yes;* bodytitle;

  Proc template;

     Define style odsrtf;
     Parent = styles.rtf;

   *** Important thing to notice is the protectspecialchars, which allows us to push the RTF codes through ***;
   Style table from table / rules=groups frame=void cellspacing=0 fontweight=bold
                            outputwidth =_undef_ protectspecialchars=off;
            
   *** Margins for landscape ***;
   Replace Body from Document /
      bottommargin = 2.54cm
      topmargin    = 3.00cm
      rightmargin  = 3.00cm
      leftmargin   = 2.54cm;

   *** Fonts ***;
   Replace fonts /
      'CellFont'             = ("Times New Roman",10pt)
      'TitleFont2'           = ("Times New Roman",10pt)
      'TitleFont'            = ("Times New Roman",10pt)
      'StrongFont'           = ("Times New Roman",10pt)
      'EmphasisFont'         = ("Times New Roman",10pt)
      'FixedEmphasisFont'    = ("Times New Roman",10pt)
      'FixedStrongFont'      = ("Times New Roman",10pt)
      'FixedHeadingFont'     = ("Times New Roman",10pt)
      'BatchFixedFont'       = ("Times New Roman",10pt)
      'FixedFont'            = ("Times New Roman",10pt)
      'headingEmphasisFont'  = ("Times New Roman",10pt)
      'headingFont'          = ("Times New Roman",10pt)
      'docFont'              = ("Times New Roman",10pt)
      'footFont'             = ("Times New Roman",10pt);

   *** Set the header and cell styles ***;
   Replace headersAndFooters from cell /
      font       = fonts('HeadingFont')
      foreground = colors('headerfg')
      background = colors('contentbg');
   
   Replace data from cell /
      background = colors('contentbg');

	Replace Table from Output /
         cellspacing=1pt
		 cellpadding=1.5pt   
		 frame=hsides   
		 rules=groups   
		 borderwidth = 0.5pt
         outputwidth = 100%;

    style column /
	    just=center
        asis=on;

   Style PageNo /
       foreground=white
     font_size = 0.1pt;

   Style SystemFooter from SystemFooter                                
       "Controls system footer text." /                                     
       just = L
       font_weight = medium
		font_face = "Times New Roman"
		font_size = 10pt;  

   Style SystemTitle from SystemTitle /
        just = L
		font_weight = medium
		font_face = "Times New Roman"
		font_size = 10pt
		frame = below;

	style header /
	    just=center
		font_weight = bold
		font_face = "Times New Roman"
		font_size = 10pt
		frame = hsides
		;
	style data from cell / 
      protectspecialchars=OFF 
      nobreakspace=ON 
          /*fontwidth=EXPANDED*/ 
      asis=ON 
      just=center;

      style GraphData1 from GraphData1 / contrastcolor = black linestyle=1 markersymbol = "circlefilled";
      style GraphData2 from GraphData2 / contrastcolor = black linestyle=3 markersymbol = "square";
      class GraphFonts / 'GraphLabelFont'=("Times New Roman",8pt, bold)
                         'GraphValueFont'=("Times New Roman",8pt)
                         'GraphTitleFont'=("Times New Roman",8pt)
                         'GraphFootnoteFont'=("Times New Roman",8pt)
;
       style graphbackground from graphbackground / color=_undef_;

       end;
   quit;
%mend;
