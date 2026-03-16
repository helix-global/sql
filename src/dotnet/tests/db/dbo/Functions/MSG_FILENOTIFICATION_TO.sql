CREATE function dbo.MSG_FILENOTIFICATION_TO(@aSbscID int, @aCustomerID int)
returns nvarchar(1024) as 
begin

  declare @res nvarchar(1024)
  
  select @res = isnull(@res,'') + B.EMAIL + ';'
  from MSG_FILENOTIFICATIONS_CONTACTS A with (nolock)
  left join COM_CUST_CONTACTS B with (nolock) on B.ID = A.CONTACTID
  where A.VNESHID = @aSbscID
    and B.CUSTOMERID = @aCustomerID
     
     
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)
    
  return @res
     
end