declare

x boolean ;
y boolean ;
z boolean ;

begin

      x := NULL ; y := NULL ;
      dbms_output.put_line ('x = NULL, y = NULL') ;
      z := (x or y) ;
      dbms_output.put_line ('x or y:  ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      z := (x and y) ;
      dbms_output.put_line ('x and y: ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      
      x := NULL ; y := FALSE ;
      dbms_output.put_line (chr (13) || chr (10) || 'x = NULL, y = FALSE') ;
      z := (x or y) ;
      dbms_output.put_line ('x or y:  ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      z := (x and y) ;
      dbms_output.put_line ('x and y: ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;

      x := FALSE ; y := NULL ;
      dbms_output.put_line (chr (13) || chr (10) || 'x = FALSE, y = NULL') ;
      z := (x or y) ;
      dbms_output.put_line ('x or y:  ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      z := (x and y) ;
      dbms_output.put_line ('x and y: ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;

      x := NULL ; y := TRUE ;
      dbms_output.put_line (chr (13) || chr (10) || 'x = NULL, y = TRUE') ;
      z := (x or y) ;
      dbms_output.put_line ('x or y:  ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      z := (x and y) ;
      dbms_output.put_line ('x and y: ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;

      x := TRUE ; y := NULL ;
      dbms_output.put_line (chr (13) || chr (10) || 'x = TRUE, y = NULL') ;
      z := (x or y) ;
      dbms_output.put_line ('x or y:  ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;
      z := (x and y) ;
      dbms_output.put_line ('x and y: ' || CASE WHEN z THEN 'TRUE' WHEN z IS NULL THEN 'NULL' ELSE 'FALSE' END) ;

end ;
