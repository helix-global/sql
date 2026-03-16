CREATE function [dbo].[RO_COMPONENTS](@aCnxtIDs nvarchar(max),@UserID int,@aMTID int)
returns @res table (ID int) as 
begin

  declare @items table (ID int primary key)
  insert into @items (ID)
  select distinct ID from dbo.COM_STR2TABLE_INT(@aCnxtIDs)

  insert into @res (ID)
  select distinct B.ID
  from @items A 
  cross apply dbo.RO_ITEM_COMPONENTS(A.ID,@aMTID) B
  
  return

end