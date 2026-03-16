
CREATE FUNCTION dbo.EQ_ADD_CUSTOM_REPORTS
(
	@eqId int, @UserID int
)
RETURNS nvarchar(4000)
AS
BEGIN
	
	DECLARE @ret nvarchar(4000) = ''

	declare @mtid int
	declare @mtid2 int

	select @mtid = max(C.MTID),@mtid2 = min(C.MTID) 
	from EQ_EQUIPMENT A with (nolock) 
	left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
	left join EQ_TYPES C with (nolock) on C.ID = B.EQTYPEID
	where A.ID=@eqId


	if isnull(@mtid,-1) <> isnull(@mtid2,-2)
	  set @mtid = null
  
	declare @depid int 

	if @mtid is not null
	  set @depid = dbo.COM_USER_DEPARTMENT(@UserID)  
  

	select @ret = @ret + cast(A.ID as nvarchar(20)) + ','
	from PR_REPORTS A with (nolock) 
	where A.MTID = @mtid
	  and A.S_S = 1000075 /* Approved */
	  and A.USEINEQUIPMENT = 1
	  and (A.USE_ONLYINDEP = @depid or A.USE_ONLYINDEP is null)
	  and (isnull(A.USE_IN_ASSEMBLY,0) = 1 or dbo.COM_USER_IN_DEPARTMENT2(@UserID, A.DEPID, 1) = 1)


	RETURN @ret

END