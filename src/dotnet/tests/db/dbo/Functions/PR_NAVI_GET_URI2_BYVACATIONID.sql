create function [dbo].[PR_NAVI_GET_URI2_BYVACATIONID](@VacationID int)
returns nvarchar(500) as 
begin
  /*на основе dbo.PR_NAVI_GET_URI2_BYDEPID для KB4728*/
  /*
  24.04.2024	KB4728	Efimov
  */
  declare @res nvarchar(500)
  declare @depID int = (select TOP 1 DEPID from COM_EMPLOYEE WHERE ID = (select TOP 1 EMPLID from COM_VACATION where ID = @VacationID))

  set @res = dbo.PR_NAVI_GET_URI2_BYDEPID(@depID)
  return @res
end