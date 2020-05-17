function get_xlsx_column_ref (p_column_number in varchar2) return varchar2
as
  l_offset number;
  l_returnvalue varchar2(2);
begin
  
  /*
 
  Purpose:      get column reference from column number
 
  Remarks:      
 
  Who     Date        Description
  ------  ----------  --------------------------------
  MBR     11.07.2011  Created
 
  */

  if p_column_number < 27 then
    l_returnvalue := chr(p_column_number + 64);
  else
    l_offset := trunc(p_column_number/26.5); -- Bug fix to handle more than 52 columns
    l_returnvalue := chr(l_offset + 64);
    l_returnvalue := l_returnvalue || chr(p_column_number - (l_offset * 26) + 64);
  end if; 
  
  return l_returnvalue;

end get_xlsx_column_ref;
