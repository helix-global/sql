create function [dbo].[PR_PLACEDORDER_HASSHIPPED](@aParentOrderID int, @aPlacedOrderSettingID int)
returns int as 
begin
/* 
возвращает 1 если есть готовые к установке компоненты, заказанные по дочерним заказам по отношению к @aParentOrderID
*/

  if exists (select B.ID 
               from PR_PRORDER A with (nolock)
               left join PR_DEVICE B with (nolock) on B.ORDERID = A.ID
              where A.PARENTORDER = @aParentOrderID
                and A.PLACEDSETTINGID = @aPlacedOrderSettingID
                and B.S_S in (1000010,1000030))
                return 1
    
  return null  

end