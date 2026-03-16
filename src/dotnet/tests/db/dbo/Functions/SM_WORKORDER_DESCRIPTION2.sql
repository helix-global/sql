CREATE FUNCTION [dbo].[SM_WORKORDER_DESCRIPTION2]
(
	@woId int
)
RETURNS nvarchar(max)
AS
BEGIN
	/*KB2776*/
	
	DECLARE @ret nvarchar(max) =''
	

	SELECT @ret = @ret + T.NAME  + char(13)+ char(10)+dbo.SM_OPER_DESCRIPTION(S.OPERID,0) 
	from SM_WORKORDER_TASKS S with(nolock)
	left join SM_SERVICETASKS T with(nolock) on T.ID=S.TASKID
	left join PR_OPERATION O with(nolock) on O.ID = S.OPERID
	left join PR_OPERATIONS G with(nolock) on G.ID = O.OPERTYPEID
	where S.VNESHID=@woId	
	  and G.OPERTYPE in (22,2,4,5) 
	
	
	
	RETURN @ret

END