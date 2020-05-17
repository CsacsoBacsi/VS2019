CREATE OR REPLACE PROCEDURE C10879.SP_GEN_XML_3D (p_start_date DATE, p_end_date DATE, p_dir VARCHAR2, p_file VARCHAR2) 
IS
-- Purpose:        To generate an XML document template of pre-defined format for the users to fill in.
--                 Creates an XML file in a user specified directory and name
-- Created by:     Csaba Riedlinger
-- Date:           04/09/2008
-- Change history: 

cr67Doc          ExcelDocumentType ;
documentArray    ExcelDocumentLine := ExcelDocumentLine () ;
clobDocument     CLOB ;
v_file           UTL_FILE.FILE_TYPE ;
col_index        PLS_INTEGER ;
props            PLS_INTEGER ;
i                PLS_INTEGER ;
attached         BOOLEAN := FALSE ;

CURSOR pc   IS SELECT xid as pid, xdesc as pdesc 
               FROM TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
               ,' DIMENSION xid FROM elec_product ' ||
                ' WITH ATTRIBUTE xdesc FROM elec_product_long_description '
               ) AS ID_DESC_TAB)) ;

CURSOR bsc  IS SELECT distinct xid as sid, xdesc as sdesc
               FROM TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
               ,' DIMENSION xid FROM business_structure ' ||
                ' WITH ATTRIBUTE xdesc FROM business_structure_long_description '
               ) AS ID_DESC_TAB)) ;
              
CURSOR tc   IS SELECT to_char (to_date (xid, 'MM/DD/YYYY'), 'DD/MM/YYYY') as did,
                      to_char (to_date (xdesc, 'DD-MM-YY'), 'DD/MM/YYYY') as ddesc
               FROM TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
               ,' DIMENSION xid FROM time ' ||
                ' WITH ATTRIBUTE xdesc FROM time_long_description ' 
               ) AS ID_DESC_TAB))
               WHERE to_date (xid, 'MM/DD/YYYY') between p_start_date AND p_end_date ;                
--               WHERE to_date (xid, 'MM/DD/YYYY') between to_date ('01/01/2008', 'DD/MM/YYYY') AND to_date ('31/01/2008', 'DD/MM/YYYY') ;

BEGIN

     BEGIN
     
         dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;
     
     EXCEPTION
         WHEN OTHERS THEN
             NULL ;     
     END ;

    -- Attach AW and impose limits
    dbms_aw.execute ('aw attach edf_nhh_aw.edf_nhh ro') ;
    attached := TRUE ;
    dbms_aw.execute ('lmt elec_product to elec_product_levelrel ''PROPOSITION''') ;
    dbms_aw.execute ('lmt business_structure to business_structure_levelrel ''SECTOR''') ;    
    dbms_aw.execute ('lmt time to time_levelrel ''DAY''') ;

     -- Get number of GSPs in dimension 
     SELECT count (*) INTO props
     FROM   (SELECT xid, xdesc
               FROM TABLE (CAST (OLAP_TABLE ('EDF_NHH_AW.EDF_NHH DURATION SESSION', 'ID_DESC_TAB', '' 
               ,' DIMENSION xid FROM elec_product ' ||
                ' WITH ATTRIBUTE xdesc FROM elec_product_long_description '               
            ) AS ID_DESC_TAB))) ;

     cr67Doc := ExcelDocumentType();

     -- Open the document
     cr67Doc.documentOpen;

     -- Define Styles
     cr67Doc.stylesOpen;

     -- Include Default Style
     cr67Doc.defaultStyle;

     -- Add Custom Styles
     /* Style for Column Header Row */
     cr67Doc.createStyle(p_style_id =>'ColumnHeader',
                               p_font     =>'Times New Roman',
                               p_ffamily  =>'Roman',
                               p_fsize    =>'10',
                               p_bold     =>'Y',
                               p_align_horizontal=>'Center',
                               p_align_vertical=>'Bottom');

    /* Styles for alternating row colors and borders */ 
    cr67Doc.createStyle(p_style_id=>'NumberStyleBlueCell',
                               p_cell_color=>'Cyan',
                               p_cell_pattern =>'Solid',
                               p_number_format => '###,###,###.00',
                               p_align_horizontal => 'Right');

    cr67Doc.createStyle(p_style_id=>'TextStyleGrayCell',
                               p_cell_color=>'#C0C0C0',
                               p_cell_pattern =>'Solid',
                               p_borders=>'8',
                               p_weight=>'1');
                               
    cr67Doc.createStyle(p_style_id=>'TextStyleGrayCellCenter',
                               p_cell_color=>'#C0C0C0',
                               p_cell_pattern =>'Solid',
                               p_align_horizontal=>'Center',
                               p_borders => '7',
                               p_weight => '1');                              

    cr67Doc.createStyle(p_style_id=>'TextStyleGrayCellB',
                               p_cell_color=>'#C0C0C0',
                               p_cell_pattern =>'Solid',
                               p_borders=>'12',
                               p_weight=>'1');

    /* Style for numbers */
    cr67Doc.createStyle(p_style_id => 'NumberStyle',
                              p_number_format => '###,###,###.00',
                              p_align_horizontal => 'Right');

   /* Style for Column Sum */
    cr67Doc.createStyle(p_style_id => 'ColumnSum',
                              p_number_format => '###,###,###.00',
                              p_align_horizontal => 'Right',
                              p_text_color => 'Blue') ; 

   /* Style for Column Sum */
    cr67Doc.createStyle(p_style_id => 'RowSum',
                              p_number_format => '###,###,###.00',
                              p_align_horizontal => 'Right',
                              p_text_color => 'Red') ;  

   /* Style for Right Border */
    cr67Doc.createStyle(p_style_id => 'RightBorder',
                              p_borders => '4',
                              p_weight => '1') ;  

     -- Close Styles
     cr67Doc.stylesClose ;

     -- Open Worksheet
     FOR bsc_rec IN bsc LOOP
      
         cr67Doc.worksheetOpen (bsc_rec.sdesc) ;
         col_index := 1 ;

         cr67Doc.defineColumn (p_index=>to_char (col_index), p_width=>20) ;

         -- Define Header Row
         cr67Doc.rowOpen ;      
         cr67Doc.addCell (p_style=>'ColumnHeader', p_data=>bsc_rec.sdesc) ;
         -- Set column count correctly                             
         FOR pc_rec IN pc LOOP   

                 cr67Doc.addCell (p_data=>NULL) ;
                             
         END LOOP ;       
        
         cr67Doc.rowClose ;          

         cr67Doc.rowOpen ;
         cr67Doc.addCell (p_data=>NULL) ;
         cr67Doc.rowClose ;         

         cr67Doc.rowOpen ;
         cr67Doc.addCell (p_data=>NULL) ;         
         -- Proposition label stretching over multiple cells
         cr67Doc.addCell (p_style=>'TextStyleGrayCellCenter', p_data=>'Proposition', p_merge=>props - 1) ;
         cr67Doc.rowClose ;         

         -- Propositions
         cr67Doc.rowOpen ;
         cr67Doc.addCell (p_style=>'RightBorder', p_data=>'Day') ;
         i := 1 ;         
         FOR pc_rec IN pc LOOP         
                          
             IF i = props THEN
                 cr67Doc.addCell (p_style=>'TextStyleGrayCellB', p_data=>pc_rec.pdesc) ;
             ELSE
                 cr67Doc.addCell (p_style=>'TextStyleGrayCell', p_data=>pc_rec.pdesc) ;
             END IF ;
             i := i + 1 ;
             
         END LOOP ;

         cr67Doc.rowClose ; 

         -- Days
         FOR tc_rec IN tc LOOP

             cr67Doc.rowOpen ;     
             cr67Doc.addCell (p_style=>'RightBorder', p_data=>tc_rec.ddesc) ;
             cr67Doc.rowClose; 

         END LOOP ;

         -- Close the Worksheet       
         cr67Doc.worksheetClose ;
         
    END LOOP ;

    -- Close the document.
    cr67Doc.documentClose ;

    -- Detach AW
    dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;

    -- Get CLOB Version
    clobDocument := cr67Doc.getDocument ;

    -- Write document to a file
    -- Assuming UTL file setting are setup in DB Instance.
    documentArray := cr67Doc.getDocumentData ;
    
--     v_file := UTL_FILE.fopen ('JOB_BOOK_DIR', 'MyTest2.xml', 'W', 4000) ;
     v_file := UTL_FILE.fopen (p_dir, p_file, 'W', 4000) ;

     FOR x IN 1 .. documentArray.COUNT LOOP
  
         UTL_FILE.put_line(v_file,documentArray (x)) ;
    
     END LOOP ;

     UTL_FILE.fclose (v_file) ;
     
EXCEPTION
  WHEN OTHERS THEN
      /* For displaying command line error */
      dbms_output.put_line (sqlerrm) ;
      IF attached THEN
         dbms_aw.execute ('aw detach edf_nhh_aw.edf_nhh') ;
      END IF ; 
      
      RAISE ;          

 END;
/
