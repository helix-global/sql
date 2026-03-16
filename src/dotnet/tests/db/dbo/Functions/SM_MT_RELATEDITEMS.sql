CREATE function [dbo].[SM_MT_RELATEDITEMS](@UserID int,@aMode int)
returns @res table (ID int) as 
begin
/*
 возвращает типы моделей из service department пользователя 
*/
  insert into @res (ID)
  select M.MTID 
    from SM_EMAIL_BOXES_MT M with (nolock) 
    join SM_EMAIL_BOXES B with (nolock) on M.VNESHID=B.ID 	
    where dbo.COM_DEP_ACCESS(null,B.DEPID,1,@UserID,getdate()) = 1 /*B.DEPID = dbo.COM_USER_DEPARTMENT(@UserID)*/
      and ISNULL(M.SHOW_RELATED,0) = 1  
  
  return

end