CREATE function [dbo].[RO_RESTRICTED_MODELS](@UserID int,@aMode int)
returns @res table (ID int) as 
begin

/* возвращает список моделей которые ЗАКРЫТЫ сотруднику для просмотра через Items Overview*/

  if dbo.DEF_USERINGROUP7(@UserID,'ADM') = 1
     return
     
  
  declare @EmplDepID int
  select @EmplDepID = dbo.COM_USER_DEPARTMENT(@UserID)


                     

  insert into @res (ID)
  select G.ID 
  from PR_MODELS G with (nolock)
  where G.DEPID in ( select A.DEPID 
                     from RO_DEP_SETTINGS A with (nolock)
                    where not exists (select B.DEPID 
                                        from RO_DEP_SETTINGS B with (nolock)
                                       where dbo.COM_DEP_ACCESS2(B.EMPL_DEPID,1,@UserID,getdate()) = 1
                                         and B.DEPID = A.DEPID)
                   )
  
  
  return

end