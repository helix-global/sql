CREATE function [dbo].[SM_RMA_NOTIFICATION_SUBJ](@nid int,@aUser int,@aMode int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max)
  
  declare @requestID int
  declare @result int
  declare @resultRMA nvarchar(50) 
  declare @requestor nvarchar(500)
  
  select @requestID = A.REQUESTID
        ,@result = A.RESULT
        ,@resultRMA = isnull(A.RESULTRMA,'NA')
        ,@requestor = C.NAME/*U.FULLNAME  KB908*/
    from SM_RMA_NOTIFICATIONS A with (nolock)
    left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
    left join COM_CUSTOMER C with (nolock) on C.ID = B.CUSTID
    /*left join DEF_USERS U with (nolock) on U.ID = A.REQUEST_CR*/
   where A.ID = @nid
   
  declare @firstSN nvarchar(20)
  declare @firstPN nvarchar(20)
  declare @firstPNmodelname nvarchar(500)
  
  select top 1 @firstSN = isnull(A.SERIALNO,'NA')
              ,@firstPN = isnull(A.ITEMNO,'NA')
  from PDB_BUFFER..SERVICEREQUESTLINES A with (nolock)
  where A.HEADERID = @requestID
  order by A.ID
  
  select top 1 @firstPNmodelname = isnull(A.NAME,'NA') from PR_MODELS A with (nolock) where A.CODE = @firstPN
  
  
  set @res = @firstPNmodelname+' - '+@firstSN+' - '+@requestor
 
  if (@result = 1)
  begin
     set @res = 'Service number created - '+@resultRMA + ' - ' + @res 
  end
  else
  begin
    set @res = 'Error - ' + @res
  end
  
  return @res
end