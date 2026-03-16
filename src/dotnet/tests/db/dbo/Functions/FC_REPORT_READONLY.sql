CREATE function [dbo].[FC_REPORT_READONLY](@aRepID int,@aUserID int,@aDate datetime)
returns int as 
begin
  declare @fromDepRes int
  declare @toDepRes int
  declare @toModelID int
  declare @toDepID int
  declare @fromDepID int
  select 
     @fromDepRes = dbo.COM_DEP_ACCESS(null,A.FROMDEPID,1,@aUserID,@aDate) 
    ,@toDepRes = dbo.COM_DEP_ACCESS(null,B.DEPID,1,@aUserID,@aDate) 
    ,@toModelID = A.MODELID
    ,@toDepID = B.DEPID
    ,@fromDepID = A.FROMDEPID
  from FC_REPORT A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.ID = @aRepID

  if @fromDepRes = 0
  begin
    /*подразделение - автор FAR разрешает его править*/
    if exists(select A.ID from FC_DEPSETTINGS A with (nolock)
               where A.DEPID = @fromDepID
                 and isnull(A.ALLOWEDIT,0) = 1
                 and dbo.COM_DEP_ACCESS2(A.TODEPID,3,@aUserID,@aDate) = 1
                 )
                 set @fromDepRes = 1
  end

  if @toDepRes = 0
    if exists (select ID 
                 from FC_DEPSHARING A with (nolock)
                where A.DEPID = @toDepID 
                  and dbo.COM_DEP_ACCESS(null,A.ALLOW2DEPID,1,@aUserID,@aDate) = 1
                  and (A.ALLOW2EMPLID is null or A.ALLOW2EMPLID = dbo.DEF_EMPLOYEE(@aUserID))
                  )
      set @toDepRes = 1

  
  if @fromDepRes = 1 or @toDepRes = 1
    return 1
    
     
    
  return 0;
end