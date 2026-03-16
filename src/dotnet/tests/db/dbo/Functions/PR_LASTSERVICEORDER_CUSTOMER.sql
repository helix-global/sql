create function [dbo].[PR_LASTSERVICEORDER_CUSTOMER](@deviceId int)
returns int
as
begin

      declare @res int
      
      select top 1 @res = P.CUSTOMERID
        from PR_PRORDER_SERVICE O with (nolock) 
        left join PR_PRORDER P with (nolock) on P.ID = O.ORDERID
        where O.DEVICEID = @deviceId
        order by P.ID desc
      
      return @res
end;