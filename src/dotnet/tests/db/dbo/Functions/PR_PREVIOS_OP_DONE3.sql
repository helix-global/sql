CREATE function [dbo].[PR_PREVIOS_OP_DONE3](@DeviceID int ,@OrderID int, @DoneLevel int,@RevOperID int,@ParentID int ,@TrMapN int)
returns int
begin
	
	if (@OrderID is not null)
	begin
  
		if exists (select A.ID 
				   from PR_OPERATION A with (nolock) 
				  where A.DEVICEID = @DeviceID
					and A.ORDERID = @OrderID
					and A.OPLEVEL = @DoneLevel
					and A.REVOPERID = @RevOperID
					and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)
					and isnull(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
					and A.S_S in (1000013,1000019))
					return 1

		if exists (select A.DEVICEID
				   from PR_DEVICE_SKIPPED_OP A
				  where A.DEVICEID = @DeviceID
					and A.ORDERID = @OrderID
					and A.OPLEVEL = @DoneLevel
					and A.REVOPERID = @RevOperID                
					and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)                
					and isnull(A.TRMAP_N,0) = ISNULL(@TrMapN,0)                
				  )
				 return 1
			 
	end
	else
	begin
		if exists (select A.ID 
				   from PR_OPERATION A with (nolock) 
				  where A.DEVICEID = @DeviceID
					--and A.ORDERID = @OrderID
					and A.OPLEVEL = @DoneLevel
					and A.REVOPERID = @RevOperID
					and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)
					and isnull(A.TRMAP_N,0) = ISNULL(@TrMapN,0)
					and A.S_S in (1000013,1000019))
					return 1

		if exists (select A.DEVICEID
				   from PR_DEVICE_SKIPPED_OP A
				  where A.DEVICEID = @DeviceID
					--and A.ORDERID = @OrderID
					and A.OPLEVEL = @DoneLevel
					and A.REVOPERID = @RevOperID                
					and isnull(A.PARENTID,0) = ISNULL(@ParentID,0)                
					and isnull(A.TRMAP_N,0) = ISNULL(@TrMapN,0)                
				  )
				 return 1
	end
  return 0
end