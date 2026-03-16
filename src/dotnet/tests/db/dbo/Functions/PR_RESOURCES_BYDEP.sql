CREATE function [dbo].[PR_RESOURCES_BYDEP](@aDepID int, @aDBeg datetime,@aDEnd datetime)
returns decimal(18,2) as
begin
  
  declare @res decimal(18,2)
  
  select @res = sum(dbo.PR_RESOURCES_BYEMPL(A.ID,@aDBeg,@aDEnd,0))
  from COM_EMPLOYEE A with (nolock)
  where A.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@aDepID,1))

  return @res 
end