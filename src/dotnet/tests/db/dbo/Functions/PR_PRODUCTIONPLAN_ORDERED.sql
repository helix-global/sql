create function [dbo].[PR_PRODUCTIONPLAN_ORDERED](@aOrderID int,@aModelID int,@aRevID int,@aSOrderID int)
returns int
as
begin

  declare @res int
  
	SELECT @res = COUNT(DEV.ID) 
	FROM PR_DEVICE DEV with (nolock)
	left join PR_PRORDER OO with (nolock) on OO.ID = DEV.ORDERID
	where DEV.ORDERID = @aOrderID
	  and DEV.MODELID = @aModelID
	  and DEV.REVID = @aRevID
	  and DEV.SORDERID = @aSOrderID
		      
  return @res;
  
end;