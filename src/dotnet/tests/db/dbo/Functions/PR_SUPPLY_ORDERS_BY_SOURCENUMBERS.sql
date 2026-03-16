CREATE function [dbo].[PR_SUPPLY_ORDERS_BY_SOURCENUMBERS](@soIDs nvarchar(max))  
 returns @res table(ID INT)
as 
begin  

  insert into @res (ID)
  select ID from dbo.COM_STR2TABLE_INT(@soIDs)
  
  insert into @res (ID)
  select A.ID from PR_SUPPLY A with (nolock) 
  where A.ND in (select B.ND from PR_SUPPLY B with (nolock) where B.ID in (select ID from @res))
    and A.ID not in (select N.ID from @res N) 
  
  return

end