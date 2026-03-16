create function [dbo].[PR_DEP_MODELS](@DepID int)  
 returns @res table(ID INT)
as 
begin  
  /* список моделей подразделения с учетом дочерних подразделений */  
  insert into @res (ID)
  select A.ID from PR_MODELS A with (nolock) where A.DEPID = @DepID
  
  insert into @res (ID)
  select B.ID
  from COM_DEPARTMENTS A with (nolock)
  cross apply dbo.PR_DEP_MODELS(A.ID) B
  where A.PARENTDEPARTMENT = @DepID
  
  return
end