CREATE function [dbo].[SM_RMA_NOTIFICATION_TEXT2](@nid int,@aUser int,@aMode int)
returns nvarchar(max) as 
begin
  /* v.2 KB809  */

  declare @res nvarchar(max)
  
  declare @caseN nvarchar(12)
  declare @caseID int
  declare @custName nvarchar(250)
  declare @requestID int
  declare @result int
  declare @resultRMA nvarchar(50) 
  declare @resultError nvarchar(110) 
  declare @requestor nvarchar(500)
  
  select @caseN = isnull(B.ND,'NA')
        ,@custName = isnull(C.NAME,'NA')
        ,@requestID = A.REQUESTID
        ,@result = A.RESULT
        ,@resultRMA = isnull(A.RESULTRMA,'NA')
        ,@resultError = isnull(A.RESULTERROR,'NA')
        ,@requestor = U.FULLNAME
        ,@caseID = A.SCASEID
    from SM_RMA_NOTIFICATIONS A with (nolock)
    left join SM_SERVICECASE B with (nolock) on B.ID = A.SCASEID
    left join COM_CUSTOMER C with (nolock) on C.ID = B.CUSTID
    left join DEF_USERS U with (nolock) on U.ID = A.REQUEST_CR
   where A.ID = @nid
  
  
  set @res = 'INT/RMA/SC/SCAFF request was processed in Navision<br>'
  set @res = @res + 'Service number: '+@resultRMA+'<br>'
  set @res = @res + 'Service case: '+@caseN+'<br>'
  set @res = @res + 'Requestor: '+@requestor+'<br><br>'
  
  set @res = @res + 'Items:<br>'
  
  declare @table nvarchar(max)
  select @table = isnull(@table,'') 
           + (select top 1 isnull(B.NAME,'NA') from PR_MODELS B with (nolock) where B.CODE = A.ITEMNO collate database_default)
           + ' - ' +isnull(A.SERIALNO,'NA') 
           + ' - '+isnull(A.ITEMNO,'NA')+'<br>'
  from PDB_BUFFER..SERVICEREQUESTLINES A with (nolock)
  where A.HEADERID = @requestID
  
  set @res = @res + isnull(@table,'<br>') 
  set @res = @res + '<br>'
  
  if (@result = 1)
  begin
     set @res = @res + 'Result: <b>Service number created</b>' 
  end
  else
  begin
    set @res = @res + 'Result: <b>Error</b><br>Error text:'+@resultError+'<br>' 
  end
  
  if @caseID > 0
  begin
     set @res = @res + '<br><br>PDB Link to <a href="a2l:\\Link=doc.sm_service_case.' + cast(@caseID as nvarchar(20)) + '">'+@caseN+'</a><br>'
  end
  
  if len(@resultRMA) > 3
  begin
     
     declare @navLinkMask nvarchar(500)
     
     if upper(@resultRMA) like 'SC-%'
     begin
        select @navLinkMask = A.LINK_SERV_SC from PR_NAV_URLS A with (nolock) where A.SERVERNAME = @@SERVERNAME
     end
     else if upper(@resultRMA) like 'RMA-%'
     begin
        select @navLinkMask = A.LINK_SERV_RMA from PR_NAV_URLS A with (nolock) where A.SERVERNAME = @@SERVERNAME
     end
     else if upper(@resultRMA) like 'SCAFF-%'
     begin
        select @navLinkMask = A.LINK_SERV_SCAFF from PR_NAV_URLS A with (nolock) where A.SERVERNAME = @@SERVERNAME
     end
     
     if @navLinkMask is not null
       if len(@navLinkMask) > 3
       begin
         
         set @navLinkMask = replace(@navLinkMask,'{0}',@resultRMA)
         set @res = @res + '<br>Navision Link to <a href="'+@navLinkMask+'">'+@resultRMA+'</a><br>'
       end
     
     
  end  
  
  return @res
end