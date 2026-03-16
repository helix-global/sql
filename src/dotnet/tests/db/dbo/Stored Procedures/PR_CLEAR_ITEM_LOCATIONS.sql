CREATE procedure [dbo].[PR_CLEAR_ITEM_LOCATIONS] @aServOrderID int
as 
set nocount on

/* 
KB745
очищает информацию о "полках" хранения по изделиям в сервисном заказа
запускается при запуске заказа в сервис
*/

update PR_DEVICE set SHIPPINGSTOCK = null where ID in (select D.DEVICEID from PR_PRORDER_SERVICE D with (nolock) where D.ORDERID = @aServOrderID)

--update SH_ORDER_T set SHIPPINGSTOCK = null where DEVICEID in (select D.DEVICEID from PR_PRORDER_SERVICE D with (nolock) where D.ORDERID = @aServOrderID)

set nocount off