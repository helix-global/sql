create function [dbo].[RO_HOSTS](@aCnxtIDs nvarchar(max),@UserID int,@TopMTID int)
returns @res table (ID int) as 
begin

  declare @items table (ID int primary key)
  insert into @items (ID)
  select distinct ID from dbo.COM_STR2TABLE_INT(@aCnxtIDs)

  insert into @res (ID)
  select distinct C.ID
  from @items A 
  outer apply dbo.PR_DEVICE_IN_TOPDEVICE_TAB2(A.ID,@TopMTID) C
  
  return

end