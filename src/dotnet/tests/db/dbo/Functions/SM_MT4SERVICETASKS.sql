CREATE function [dbo].[SM_MT4SERVICETASKS](@aDepID int,@aMode int)
returns @res table (ID int) as 
begin
/*KB1046
 возвращает типы моделей по которым можно создать service task
*/
  insert into @res (ID)
  select A.ID from PR_MODELTYPE A with (nolock) where A.DEPARTMENTID = @aDepID
  union
  select B.MTID from SM_PERM2MT B with (nolock) where B.DEPID = @aDepID and B.ALLOW_SERVTASK = 1
  
  return

end