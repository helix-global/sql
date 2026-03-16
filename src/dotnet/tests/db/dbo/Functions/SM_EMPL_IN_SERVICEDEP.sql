create function [dbo].[SM_EMPL_IN_SERVICEDEP] (@ServDepID int, @UserID int, @mode int)
returns @res table (ID int)
as 
begin

  declare @depId int
  select @depId = A.DEPID from SM_EMAIL_BOXES A with (nolock) where A.ID = @ServDepID
  

  insert into @res (ID)
  select A.ID
  from COM_EMPLOYEE A with (nolock)
  where A.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@depId,1))
  
    
  return

end