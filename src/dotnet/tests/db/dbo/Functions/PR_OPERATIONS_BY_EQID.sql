CREATE function [dbo].[PR_OPERATIONS_BY_EQID] (@EqIDs nvarchar(max))
returns @res table (ID int)
as 
begin


  insert into @res (ID)
  select KL.ID 
  from PR_OPERATION KL with (nolock) 
  where KL.EQID in (select KK.ID from dbo.COM_STR2TABLE_INT(@EqIDs) KK)
  
  insert into @res (ID)
  select KL.OPERID 
  from PR_OPERATION_EQUIPMENT KL with (nolock)
  where KL.EQID in (select KK.ID from dbo.COM_STR2TABLE_INT(@EqIDs) KK)
  

return


end