CREATE PROCEDURE [dbo].[PU_CHECK_BATCH_NUMBERS] @aOperID int
AS
BEGIN

    declare @ModelID int
    declare @BatchN nvarchar(200)
    
	declare cr cursor local read_only for 
		select B.MODELID
		      ,A.BATCHN
		from PR_OPERATION_INSTALL A with (nolock)
		left join PR_DEVICE B with (nolock) on B.ID = A.PARTID
		where A.OPERID = @aOperID
		  and exists (select N.ID from PU_BATCH_TR_MODELS N with (nolock) where N.MODELID = B.MODELID)
	open cr;
	WHILE 1=1
	BEGIN
	   FETCH NEXT FROM cr INTO @ModelID, @BatchN
	   IF @@FETCH_STATUS<>0 BREAK;
	   
	   exec PU_CHECK_BATCH_NUMBER @ModelID, @BatchN
	   
	END
	close cr;
	deallocate cr;

	declare cr2 cursor local read_only for 
		select B.ID
		      ,A.BATCHN
		from PR_OPERATION_MU A with (nolock)
		left join PR_MODELS B with (nolock) on B.CODE = A.CODE
		where A.OPERID = @aOperID
		  and exists (select N.ID from PU_BATCH_TR_MODELS N with (nolock) where N.MODELID = B.ID)
	open cr2;
	WHILE 1=1
	BEGIN
	   FETCH NEXT FROM cr2 INTO @ModelID, @BatchN
	   IF @@FETCH_STATUS<>0 BREAK;
	   
	   exec PU_CHECK_BATCH_NUMBER @ModelID, @BatchN
	   
	END
	close cr2;
	deallocate cr2;


END