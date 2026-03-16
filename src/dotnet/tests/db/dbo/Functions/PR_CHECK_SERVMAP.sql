create function [dbo].[PR_CHECK_SERVMAP](@aServMapID int, @itemMTID int)
returns int as 
begin
  /*  при подборе изделий в сервисный заказ проверяет,
   что если выбрана сервисная карта в заказе,
   то подбирать можно только изделия такого-же типа модели как у карты
   */
   
  if (@aServMapID is null)
    return 1
    
  declare @mapMTID int
  select @mapMTID = A.MTID from PR_MAP A with (nolock) where A.ID = @aServMapID
  
  if @mapMTID = @itemMTID
    return 1
   
  return 0 
  
end