
CREATE function [dbo].[PR_SORDER_ITEM_IF_ONE](@ServiceOrderID int)
returns int
as
begin

   if @ServiceOrderID is null
       return null

   declare @res int
     
   select top 1 @res = A.DEVICEID 
   from PR_PRORDER_SERVICE A with (nolock) 
   where A.ORDERID = @ServiceOrderID
     and (select count(*) from PR_PRORDER_SERVICE B with (nolock) where B.ORDERID = A.ORDERID) = 1
     
   return @res  

end;