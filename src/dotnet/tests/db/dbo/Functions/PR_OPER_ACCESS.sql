CREATE function [dbo].[PR_OPER_ACCESS](@aUserID int,@aOperGrID int,@aOrderDepID int,@aDate datetime)
returns int as 
begin

  if dbo.COM_DEP_ACCESS(null,@aOrderDepID,1,@aUserID,@aDate) = 1
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