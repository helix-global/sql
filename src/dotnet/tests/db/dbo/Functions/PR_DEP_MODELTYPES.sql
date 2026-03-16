CREATE function [dbo].[PR_DEP_MODELTYPES](@DepID int)  
 returns @res table(ID INT)
as 
begin  
  /* список типов моделей подразделения с учетом дочерних подразделений */  
  insert into @res (ID)
  select A.ID from PR_MODELTYPE A with (nolock) where A.DEPARTMENTID = @DepID
  
  insert into @res (ID)
  select B.ID
  from COM_DEPARTMENTS A with (nolock)
  cross apply dbo.PR_DEP_MODELTYPES(A.ID) B
  where A.PARENTDEPARTMENT = @DepID
  
  return
end