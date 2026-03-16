create function [dbo].[PRR_ISDEP_KB4664](@aDepID int)
returns int
as
begin

  /*выдает 1 если Avilable Time по сотрудникам подразделения берутся из COM_IMPORTED_WORKTIME */

  if exists (select B.ID
               from dbo.COM_GETPARENT_DEPARTMENTS(@aDepID,1) A
               left join COM_DEPARTMENTS B with(nolock) on B.ID = A.ID
               where isnull(B.IMPORTED_WTIMES,0) = 1)
  begin               
	return 1                 
  end	
  
  
  return 0  
  
end;