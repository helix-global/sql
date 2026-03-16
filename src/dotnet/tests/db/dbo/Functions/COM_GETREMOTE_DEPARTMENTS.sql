
CREATE function [dbo].[COM_GETREMOTE_DEPARTMENTS] (@aRemoteCode nvarchar(10))
returns @res table (ID int)
as 
begin
 
  insert into @res (ID)
  select A.ID from COM_DEPARTMENTS A with (nolock)
  left join COM_REMOTE B with (nolock) on B.ID = A.RSERVER
  where B.CODE = @aRemoteCode

  insert into @res (ID)
  select distinct B.ID
  from @res A
  cross apply dbo.COM_GETCHILD_DEPARTMENTS(A.ID) B
  where B.ID not in (select G.ID from @res G)
  
  return

end