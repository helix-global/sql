CREATE FUNCTION [dbo].[SM_SERVICEORDER_DESCRIPTION2](@soId int, @deviceID int)
RETURNS nvarchar(max)
AS
BEGIN
	/*KB2776*/
	declare @soId2 int = @soId
	declare @tempId int = null
	
	DECLARE @ret nvarchar(max) =''
	
	/*иногда встречается что в service case указан сервисный заказ SG и он пустой,
	 а операции в другом заказе HPLA с таким-же номером*/
	if not exists (select J.ID from PR_OPERATION J with(nolock) where J.ORDERID = @soId)
	begin
	  select top 1 @tempId = A.ORDERID 
	  from PR_PRORDER_SERVICE A with(nolock)
	  left join PR_PRORDER B with(nolock) on B.ID = A.ORDERID
	  where A.DEVICEID = @deviceID
	    and B.ORDERTYPE = 1
	    and B.NN = (select J.NN from PR_PRORDER J with(nolock) where J.ID = @soId)
	    and exists (select U.ID from PR_OPERATION U with(nolock) where U.ORDERID = B.ID)
	  
	  set @soId2 = isnull(@tempId,@soId2)
	    
	end 
	

	SELECT @ret = @ret + G.NAME  + char(13)+ char(10)+dbo.SM_OPER_DESCRIPTION(O.ID,0) 
	from PR_OPERATION O with(nolock) 
	left join PR_OPERATIONS G with(nolock) on G.ID = O.OPERTYPEID
	where O.ORDERID=@soId2
	  and G.OPERTYPE in (22,2,4,5) 
	  and O.COMPLETED_DT is not null
	order by O.COMPLETED_DT
	
	
	
	RETURN @ret

END