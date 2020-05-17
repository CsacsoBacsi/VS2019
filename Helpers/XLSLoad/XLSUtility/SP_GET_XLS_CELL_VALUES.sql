CREATE OR REPLACE PROCEDURE SP_GET_XLS_CELL_VALUES
IS

l_blob       BLOB ;
l_names      t_str_array := t_str_array ('A1', 'B1', 'C1', 'D1', 'E1', 'A2', 'B2', 'C2', 'D2', 'E2');
l_values     t_str_array ;
l_cell_array t_str_array ;
p_from_cell  VARCHAR2 (10) ;
p_to_cell    VARCHAR2 (10) ;
l_sheet      ooxml_util_pkg.t_xlsx_sheet ;

BEGIN
--    debug_pkg.debug_on () ;
    dbms_output.put_line ('*** Get cell values for requested cell references ***') ;

    l_blob := file_util_pkg.get_blob_from_file ('C23833_DIR', 'CompComp.xlsx') ;
--    l_blob := file_util_pkg.get_blob_from_file ('C23833_DIR', 'Test.xlsx') ;
--    l_values := ooxml_util_pkg.get_xlsx_cell_values (l_blob, 'owssvr(2)', l_names) ;
--    FOR i IN 1 .. l_values.count LOOP

--      debug_pkg.printf ('Count: %1, Name: %2, Value: %3', i, l_names (i), l_values (i)) ;
--        dbms_output.put_line ('Count: ' || i || ', Name: ' || l_names (i) || ', Value: ' || l_values (i)) ;

--    END LOOP ;
    
    dbms_output.put_line ('*** Builds a cell array by given range ***') ;
    
    p_from_cell := 'A1001' ;
    p_to_cell   := 'BI1234' ;
    l_cell_array := ooxml_util_pkg.get_xlsx_cell_array_by_range (p_from_cell, p_to_cell) ;
/*    FOR i IN 1 .. l_cell_array.count LOOP

        dbms_output.put_line ('Count: ' || i || ', Value: ' || l_cell_array (i)) ;       
    
    END LOOP ; */

    dbms_output.put_line ('*** Get cell values as a sheet ***') ;
    
    l_sheet := ooxml_util_pkg.get_xlsx_cell_values_as_sheet (l_blob, 'owssvr(2)', l_cell_array) ;
    
    FOR i IN 1 .. l_sheet.count LOOP
      
/*        dbms_output.put_line ('Count: ' || i || ', ' ||
                              'Row: ' || l_sheet (l_cell_array(i)).row || ', ' ||
                              'Column: ' || l_sheet (l_cell_array(i)).column || ', ' || 
                              'Value: ' || l_sheet (l_cell_array(i)).value) ; */
    
        INSERT INTO STG_T_COMPL_COMPL_XLSX ("COL", "ROW", "VALUE")
               VALUES (l_sheet (l_cell_array(i)).column,
                       l_sheet (l_cell_array(i)).row,
                       l_sheet (l_cell_array(i)).value) ;
    
    END LOOP ;
    
    COMMIT ;

END SP_GET_XLS_CELL_VALUES ;
