CREATE OR REPLACE FUNCTION COMPLAINTS_UNIT_TEST1 (p_expected_value NUMBER) RETURN BOOLEAN IS

  l_result BOOLEAN ;

BEGIN
  
  -- DML here

  IF SQL%ROWCOUNT = p_expected_value THEN 
     l_result := TRUE ;
  ELSE
     l_result := FALSE ;
  END IF ;
  
  RETURN l_result ;
  
  EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL ;
        
END COMPLAINTS_UNIT_TEST1 ;
