CREATE function [dbo].PR_EMPL_IDS_IN_GROUP_STR(@GroupID int, @dBeg datetime, @dEnd datetime, @aMode int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max) = ''
  
  select @res = @res + ',' + cast(B.EMPLOYEEID as nvarchar)
    from PR_EMPL_TO_OPERGR B with (nolock) 
   where B.GROUPID = @GroupID
     and isnull(B.DBEG,'19900101') <= @dEnd
     and isnull(B.DEND,'40000101') >= @dBeg
    
  return @res
end