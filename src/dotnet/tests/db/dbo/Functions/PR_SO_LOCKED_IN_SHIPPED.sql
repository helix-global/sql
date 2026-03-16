CREATE function [dbo].[PR_SO_LOCKED_IN_SHIPPED](@SOrderID int, @SOrderDepID int, @SOrderS_S int)
returns int as 
begin

/*
  KB375 (в последней редакции)
  функция возвращает 1 если supply order уже в статусе shipped и должен в нем оставаться не смотря ни на что
  условие что он должен остаться: заказ является заказом FOC или его дочерних подразделений
  TODO если еще кому-то понадобится такой режим, можно сделать настройку в подразделениях
*/

  if @SOrderS_S <> 1000072 /*shipped*/
     return 0
     

  declare @FOCdepID int
  
  select @FOCdepID = A.ID 
  from COM_DEPARTMENTS A with (nolock) 
  where A.GID = '009a5b84-f3fb-4c90-ba1e-b28670c7b09d' /*FOC_G*/
  
  if exists (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@FOCdepID,1) where ID = @SOrderDepID)
    return 1

  return 0

end