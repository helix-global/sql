create function [dbo].[MSG_TICKET_URL_HTML](@aMask nvarchar(250),@aDeviceID int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max);
  
  declare @ticketN nvarchar(50)
  select top 1 @ticketN = A.TN 
  from CP_TICKETS A with (nolock)
  where A.DEVICEID = @aDeviceID
    and A.AUTOCREATED = 1
  
  if @ticketN is null
    return 'NA'
    
  if @aMask is null
    return @ticketN
    
  set @res = replace(@aMask,'%1',@ticketN)
  set @res = '<a href='+@res+'>'+@ticketN+'</a>'
 
  return @res;
  
end