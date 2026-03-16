create function [dbo].[PR_DEVICE_URGENCY2](@deviceU int, @supplyU int, @prorderU int, @lastSrvOrdU int, @DeviceID int, @ss int)
returns int with schemabinding as 
begin
  
  if @ss in (1000085,1000010) /*shipped.srv, shipped*/
    return null

  if @ss in (1000011,1000100,1000039)  /* in serv.,postponed.srv, srv.cmpl */
      return @lastSrvOrdU
  
  return coalesce(@deviceU,@supplyU,@prorderU)

end