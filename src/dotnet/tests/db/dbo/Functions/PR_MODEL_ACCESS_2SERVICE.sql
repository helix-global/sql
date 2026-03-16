create function [dbo].[PR_MODEL_ACCESS_2SERVICE] (@aModelID int,@aUserID int,@aMode int,@aDate datetime)
returns int
as 
begin

  declare @mDepID int
  declare @mtypeDepID int 
  declare @mtID int
  
  select @mDepID = A.DEPID
        ,@mtypeDepID = B.DEPARTMENTID
        ,@mtID = A.TYPEID
  from PR_MODELS A with (nolock) 
  left join PR_MODELTYPE B on B.ID = A.TYPEID
  where A.ID = @aModelID
  
  if dbo.COM_DEP_ACCESS(null,@mDepID,@aMode,@aUserID,@aDate) = 1
     return 1
     
  if dbo.COM_DEP_ACCESS(null,@mtypeDepID,@aMode,@aUserID,@aDate) = 1
     return 1
     

  if exists ( 
    select B.ID 
	from PR_SERVICE_DEPARTMENTS B with (nolock) 
	where B.MTID = @mtID
	  and dbo.COM_DEP_ACCESS(null,B.DEPID,@aMode,@aUserID,@aDate) = 1
	  )
	  return 1


return 0

end