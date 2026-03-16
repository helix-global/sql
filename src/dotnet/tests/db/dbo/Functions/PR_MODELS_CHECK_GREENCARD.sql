CREATE function [dbo].[PR_MODELS_CHECK_GREENCARD](@UserID int)  
 returns @res table(ID INT)
as 
begin  
  declare @hasC int = dbo.COM_HASNOGC(@UserID)
  
  if @hasC = 0
  begin
  
    insert into @res (ID) select ID from PR_MODELS with (nolock)
  
  end
  else
  begin
  
	insert into @res (ID)
	select M.MODELID from PR_MODELS_NOGC_ACCESS M with (nolock) 
	where dbo.DEF_USERINGROUP(@UserID, M.USERGROUP, GETDATE())=1
  
  end
  
  
  
  return
end