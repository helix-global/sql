create function [dbo].[WEB_OPER_ACCESS2](@aUserID int,@aOperGrID int,@aOrderDepID int,@aMTypeDepID int,@aDate datetime)
returns int as 
begin

/* копия PR_OPER_ACCESS2 для использования в PDBWEBAPI */

  declare @depID int
  set @depID = @aOrderDepID
  if @depID is null /* для подготовительных операций (нет заказ) используется подразделение с типа модели*/
    set @depID = @aMTypeDepID
    

  if dbo.COM_DEP_ACCESS(null,@depID,1,@aUserID,@aDate) = 1
     return 1
  
  if exists (select A.ID 
               from PR_EMPL_TO_OPERGR A with (nolock) 
              where A.EMPLOYEEID = (select U.EMPLOYEEID from DEF_USERS U with (nolock) where U.ID = @aUserID)
                and A.DEPID = @aOrderDepID
                and A.GROUPID = @aOperGrID
                and isnull(A.DBEG,'19100101') < @aDate
                and isnull(A.DEND,'40000101') > @aDate
             )   
     return 1
  
  return 0
end