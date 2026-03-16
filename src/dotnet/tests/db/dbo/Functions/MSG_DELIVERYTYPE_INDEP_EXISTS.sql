create function [dbo].[MSG_DELIVERYTYPE_INDEP_EXISTS](@aDeliveryType int,@aDepID int)
returns int
as
begin

  if exists (select A.ID  
               from MSG_DELIVERYLIST A with (nolock)
              where A.DELIVERYTYPE = @aDeliveryType 
                and A.DEPID = @aDepID
            )
            return 1;    

    
  return 0;
end;