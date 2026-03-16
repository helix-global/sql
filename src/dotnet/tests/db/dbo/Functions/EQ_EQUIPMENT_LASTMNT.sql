create function [dbo].[EQ_EQUIPMENT_LASTMNT](@EqID int)
returns datetime as 
begin

  declare @res datetime;
  select @res = max(GG.COMPLETED_DT) from PR_OPERATION GG with (nolock) where GG.EQID = @EqID
  return @res;  

end