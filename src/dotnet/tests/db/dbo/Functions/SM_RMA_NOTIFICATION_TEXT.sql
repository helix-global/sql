CREATE function [dbo].[SM_RMA_NOTIFICATION_TEXT](@nid int,@aUser int,@aMode int)
returns nvarchar(max) as 
begin
  declare @res nvarchar(max)
  
  declare @caseN nvarchar(12)
  declare @custName nvarchar(250)
  declare @requestID int
  declare @result int
  declare @resultRMA nvarchar(50) 
  declare @resultError nvarchar(110) 
  
  select @caseN = isnull(B.ND,'NA')
        ,@custName = isnull(C.NAME,'NA')
        ,@requestID = A.REQUESTID
        ,@result = A.RESULT
        ,@resultRMA = isnull(A.RESULTRMA,'NA')
        ,@resultError = isnull(A.RESULTERROR,'NA')
    from SM_RMA_NOTIFICATIONS A with (nolock)
    left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
    left join COM_CUSTOMER C with (nolock) on C.ID = B.CUSTID
   where A.ID = @nid
   
  
  set @res = 'Dear All<br><br>RMA/SC request was processed in Navision<br>Service case:'+@caseN+'<br>Customer:'+@custName+'<br>Items:<br>'
  
  declare @table nvarchar(max)
  select @table = isnull(@table,'') + isnull(A.SERIALNO,'NA') + '  '+isnull(A.ITEMNO,'NA')+'<br>'
  from PDB_BUFFER..SERVICEREQUESTLINES A with (nolock)
  where A.HEADERID = @requestID
  
  set @res = @res + isnull(@table,'<br>') 
  
  if (@result = 1)
  begin
     set @res = @res + 'Result: Service number created.<br>Service number:'+@resultRMA+'<br>' 
  end
  else
  begin
    set @res = @res + 'Result: Error.<br>Error text:'+@resultError+'<br>' 
  end
  
  set @res = @res + '<br><br>Please do not reply.<br>Production Database'
  
  return @res
end