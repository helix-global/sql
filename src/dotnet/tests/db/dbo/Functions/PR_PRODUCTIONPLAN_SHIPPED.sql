create function [dbo].[PR_PRODUCTIONPLAN_SHIPPED](@aOrderID int,@aModelID int,@aRevID int,@aCustID int,@aSOrderID int)
returns int
as
begin

  declare @res int
  
	SELECT @res = COUNT(DDD.ID) 
	FROM PR_DEVICE DDD with (nolock, index(IX_PR_DEVICE_ORDERID) )
	left JOIN PR_PRORDER OOO with (nolock) ON DDD.ORDERID = OOO.ID
	LEFT JOIN PR_SUPPLY SSS with (nolock) ON DDD.SORDERID = SSS.ID
	WHERE DDD.ORDERID = @aOrderID
	  and DDD.SHIPPED_DT IS NOT NULL
	  and DDD.MODELID = @aModelID 
	  and DDD.REVID = @aRevID 
	  and ISNULL(SSS.CUSTOMERID, OOO.CUSTOMERID) = @aCustID
	  and DDD.SORDERID = @aSOrderID
		      
  return @res;
  
end;