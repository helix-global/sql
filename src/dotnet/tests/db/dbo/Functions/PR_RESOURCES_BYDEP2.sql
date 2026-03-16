CREATE function [dbo].[PR_RESOURCES_BYDEP2](@aDepID int, @aYear int,@aMonth int,@aMode int)
returns decimal(18,2) as
begin
  
  declare @res decimal(18,2)
  
  declare @aDBeg datetime 
  declare @aDEnd datetime 
  
  set @aDBeg = dbo.COM_ENCODE_DATE(@aYear,@aMonth,1)
  set @aDEnd = dateadd(month,1,@aDBeg)  /*TODO check */
  
  select @res = sum(dbo.PR_RESOURCES_BYEMPL(A.ID,@aDBeg,@aDEnd,@aMode))
  from COM_EMPLOYEE A with (nolock)
  where A.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@aDepID,1))
    and isnull(A.ROLEINDEP,0) <> 100
    /*and A.ID not in (4,14,1781)*/

  return @res 
end