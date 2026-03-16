CREATE function [dbo].[PR_PARENORDER_REFERENCE_TXT](@aOrderID int)
returns nvarchar(30) as 
begin

/* используется в [PR_CHECK_PLACED_ORDERS_2NAV] для заполнения поля ADDINFORMATION, куда передается номер исходного заказа и заказчик */

  declare @AddInfoMode int
  declare @ParentOrderID int
  declare @res nvarchar(250)
  
  select @AddInfoMode = isnull(B.ADDINFORMATIONMODE,0)
         ,@ParentOrderID = A.PARENTORDER
  from PR_PRORDER A with (nolock) 
  left join PR_PLACED_SETTINGS B with (nolock) on B.ID = A.PLACEDSETTINGID 
  where A.ID = @aOrderID
    
  if (@AddInfoMode = 1)  
  begin
     
     select @res = isnull(A.NN2,'')+' '+isnull(B.NAME,'')
     from PR_PRORDER A with (nolock) 
     left join COM_CUSTOMER B with (nolock) on B.ID = A.CUSTOMERID
     where A.ID = @ParentOrderID
     
     return @res
     
  end
    
  return null  

end