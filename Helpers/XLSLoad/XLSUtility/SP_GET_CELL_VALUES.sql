CREATE OR REPLACE PROCEDURE SP_GET_CELL_VALUES IS

l_blob       blob ;
l_sheet      ooxml_util_pkg.t_xlsx_sheet ;
l_cell_array t_str_array ;
p_from_cell  VARCHAR2 (10) ;
p_to_cell    VARCHAR2 (10) ;

BEGIN

    dbms_output.put_line ('*** Get cell values as a sheet ***') ;
    
    l_blob := file_util_pkg.get_blob_from_file ('C23833_DIR', 'CompComp.xlsx') ;
    p_from_cell := 'A1' ;
    p_to_cell   := 'BI2' ;
    l_cell_array := ooxml_util_pkg.get_xlsx_cell_array_by_range (p_from_cell, p_to_cell) ;
    
    l_sheet := ooxml_util_pkg.get_xlsx_cell_values_as_sheet (l_blob, 'owssvr(2)', l_cell_array) ;
    
    FOR i IN 1 .. l_sheet.count LOOP
      

        dbms_output.put_line ('Count: ' || i || ', ' ||
                              'Row: ' || l_sheet (l_cell_array(i)).row || ', ' ||
                              'Column: ' || l_sheet (l_cell_array(i)).column || ', ' || 
                              'Value: ' || l_sheet (l_cell_array(i)).value) ;
    
    END LOOP ;
end SP_GET_CELL_VALUES;