create function [dbo].[COM_DH_VP_CURRENT] (@aUserID int,@aMode int)
returns @res table (ID int)
as 
begin

  declare @dBeg date = getdate()

  insert into @res(ID)
  select A.ID
  from COM_VACATION A with (nolock)
  where isnull(A.DEND,A.DBEG) >= @dBeg 
    and A.ID in (select ID from dbo.COM_DH_VP_TAB(@aUserID,@dBeg,'40000101',@aMode))

return

end