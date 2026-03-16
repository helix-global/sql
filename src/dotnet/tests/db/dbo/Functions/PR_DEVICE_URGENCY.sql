CREATE function [dbo].[PR_DEVICE_URGENCY](@deviceU int, @supplyU int, @prorderU int, @DeviceID int, @ss int)
returns int with schemabinding as 
begin
  
  if @ss in (1000085,1000010) /*shipped.srv, shipped*/
    return null

  if @ss in (1000011,1000100,1000039)  /* in serv.,postponed.srv, srv.cmpl */
  begin
     
      declare @UfromLastServiceOrder int
      select top 1 @UfromLastServiceOrder = B.URGENCY 
      from dbo.PR_PRORDER_SERVICE AS A 
      LEFT JOIN dbo.PR_PRORDER AS B ON B.ID = A.ORDERID
      where A.DEVICEID = @DeviceID
      order by A.ID desc
      
      return @UfromLastServiceOrder
     
  end   
  
  return coalesce(@deviceU,@supplyU,@prorderU)

end