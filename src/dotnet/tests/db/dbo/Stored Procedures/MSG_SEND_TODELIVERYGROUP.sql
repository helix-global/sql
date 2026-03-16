CREATE PROCEDURE [dbo].[MSG_SEND_TODELIVERYGROUP] 
  @aUserID int, @aDeliveryType int, @aDepID int, @aSubj nvarchar(1024), @aBoby varchar(max)
AS
BEGIN
  set nocount on  
  exec MSG_SEND_TODELIVERYGROUP2 @aUserID, @aDeliveryType, @aDepID, @aSubj, @aBoby, null
  set nocount off
END