create PROCEDURE [dbo].MSG_SETLASTDELIVERY_DATE 
  @aDeliveryType int,@DepID int, @newDate datetime
AS
BEGIN
set nocount on

update MSG_LAST_DELIVERY_DATES set DD = cast(@newDate as date) where DELIVERYTYPE = @aDeliveryType and DEPID = @DepID
if @@rowcount = 0
 insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@aDeliveryType,@DepID,cast(@newDate as date))
     
set nocount off
END