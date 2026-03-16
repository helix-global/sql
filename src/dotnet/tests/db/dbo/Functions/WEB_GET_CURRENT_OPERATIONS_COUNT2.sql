CREATE function [dbo].[WEB_GET_CURRENT_OPERATIONS_COUNT2](@UserID int, @aModelCode nvarchar(50), @aPrOrderNumber nvarchar(20), @aOperationCode nvarchar(50))
returns int
as 
begin

declare @cnt int

select @cnt = count(A.ID)
	from PR_OPERATION A with (nolock) 
		left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
		left join PR_DEVICE T1000241 with (nolock) on T1000241.ID = A.DEVICEID
		left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID
		left join PR_MODELS T1000224 with (nolock) on T1000224.ID = T1000241.MODELID
		left join PR_OPERATIONS_GR T1000341 with (nolock) on T1000341.ID = T1000242.OPERGRID
	 where (dbo.PR_OPER_ACCESS2(@UserID,T1000242.OPERGRID,T1000240.DEPARTMENTID,T1000341.DEPARTMENTID,getdate()) = 1 or A.USERINPROGRESS = @UserID )
	   and (A.ID in (select BB.ID from dbo.PR_IS_MY_CO_NEW(@UserID,GETDATE()) BB))
	   and (@aModelCode = '%' or @aModelCode = '*' or T1000224.CODE like @aModelCode)
	   and (@aOperationCode = '%' or @aOperationCode = '*' or T1000242.CODE like @aOperationCode)
	   and (@aPrOrderNumber = '%' or @aPrOrderNumber = '*' or  T1000240.NN=@aPrOrderNumber)

return @cnt

end