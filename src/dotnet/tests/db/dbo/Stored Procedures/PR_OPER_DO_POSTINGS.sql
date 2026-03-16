CREATE procedure [dbo].[PR_OPER_DO_POSTINGS] @OperID int, @UserID int
as 
SET nocount on

	declare @now datetime
	set @now = getdate()

	declare @pmode int
	set @pmode = dbo.PR_IS_OPER_POSTED2NAVI(@OperID,@now)

	if @pmode = 1
	begin
	  exec PR_OPER2NAVI @OperID,@UserID,@now
	  exec PR_TIME2NAVI @OperID,1,@UserID,@now
	end
	else if @pmode = 2
	begin
	  exec PR_BIND2NAVI @OperID,1,@UserID,@now
	end
	else if @pmode = 3
	begin
	  exec PR_OPER2NAVI @OperID,@UserID,@now
	end
	else if @pmode = 44
	begin
	  exec PR_TIME2NAVI @OperID,1,@UserID,@now
	end
	else if @pmode = 100
	begin
	  exec PR_OPER2NAVI @OperID,@UserID,@now
	  exec PR_TIME2NAVI @OperID,1,@UserID,@now
	end
	else if @pmode = 66
	begin
	  exec PR_OPER2NAVI @OperID,@UserID,@now
	end
	 
	exec PR_INCOMINGINSPECT_2NAVI @OperID,@UserID 
	
	declare @RevID int
	declare @DeviceID int
	declare @MapOperID int
	declare @MultiplyQty int  /*KB3744*/
	
	select @DeviceID = A.DEVICEID
	,@RevID = B.REVID
	,@MapOperID = A.REVOPERID
	,@MultiplyQty = (case when D.MULTREVADDTIMES = 1 then isnull(A.PREP_RESULT,1) else 1 end)
	from PR_OPERATION A with(nolock)
	left join PR_DEVICE B with(nolock) on B.ID = A.DEVICEID
	left join PR_MODELS C with(nolock) on C.ID = B.MODELID
	left join PR_MODELTYPE D with(nolock) on D.ID = C.TYPEID
	where A.ID = @OperID
	
	if not exists (select P.ID from PR_DEVICE_PROD_SUPP_H P where P.DEVICEID = @DeviceID and P.MAPOPERID = @MapOperID)
	begin
		insert into PR_DEVICE_PROD_SUPP_H (DEVICEID,QUALIFICATION,ELAPSED,MAPOPERID)
		select @DeviceID, A.QUALIFICATION, A.ADDVALUE * isnull(@MultiplyQty,1), A.MAPOPERID
		from PR_REV_ADD_TIMES A with (nolock)
		where A.REVID = @RevID
		  and A.MAPOPERID = @MapOperID
	end	  
	

SET nocount off