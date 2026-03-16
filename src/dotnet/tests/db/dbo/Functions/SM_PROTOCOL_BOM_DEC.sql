CREATE function [dbo].[SM_PROTOCOL_BOM_DEC](@aMode int, @aID int)
returns decimal(20,10) as 
begin

  declare @res decimal(20,10)
  
  if (@aMode = 10) /* Amount) */
  begin
     select @res = isnull(A.PARTQUANTITY,1)
     from PR_OPERATION_INSTALL A with (nolock)
     where A.ID = @aID
  end
  else if (@aMode = 1010) /* REMOVED Amount*/
  begin
     select @res = isnull(A.PARTQUANTITY,1)
     from PR_OPERATION_UNINSTALL AA with (nolock)
     left join PR_OPERATION_INSTALL A with (nolock) on A.ID = AA.INSTALLROWID
     where AA.ID = @aID
  end
  
  
  return @res
  
end