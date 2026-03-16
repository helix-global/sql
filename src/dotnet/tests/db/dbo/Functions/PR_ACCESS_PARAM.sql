create function [dbo].[PR_ACCESS_PARAM] (@aParamID int, @aUserID int,@aMode int,@aDate datetime)
returns int
as 
begin
/*
параметры изделий, которые может видеть пользователь
@aMode - 1 - по изделиям своего отдела все параметры, по другим отделам - только расшаренные
*/

declare @depID int
declare @shared int

select @depID = B.DEPARTMENTID
      ,@shared = isnull(A.SHAREPRM,0)
from PR_MODELTYPE_PARAMS A with (nolock)
left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
where A.ID = @aParamID

if @shared = 1
  return 1
  
if dbo.COM_DEP_ACCESS2(@depID,1,@aUserID,@aDate) = 1
  return 1  

return 0

end