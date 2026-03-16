CREATE function [dbo].[PR_IS_MY_CURRENT_OPERATION](@OperID int, @OperState int, @OperLock int, @UserID int,@OnDate datetime)
returns int as 
begin

  declare @deviceState int
  
  select @deviceState = D.S_S
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  where A.ID = @OperID

  if @deviceState not in (1000008,1000011,1000029) /*in production, in service, pending production*/
    return 0

  if @deviceState = 1000069 /*postponed*/
    return 0

  if @OperState in (1000031,1000033,1000032) and @OperLock = @UserID
    return 1
  
  if (@OperState = 1000032) and (@OperLock is not null) and (@OperLock <> @UserID)
    return 0
  
  if @OperState in (1000032) /*Pending*/
  begin
	  declare @DeviceID int
	  declare @OrderID int
	  declare @RevOperID int
	  declare @GrOper int
	  declare @mapID int  
	  declare @visType int
	  declare @todoID int
	  declare @operGRID int
	  
	  select 
		@DeviceID = B.DEVICEID
	   ,@RevOperID = B.REVOPERID 
	   ,@OrderID = B.ORDERID
	   ,@mapID = D.MAPID
	   ,@visType = ISNULL(F.VISTYPE,0)
	   ,@todoID = isnull(B.TODOID,0)
	   ,@operGRID = E.OPERGRID
	  from PR_OPERATION B with (nolock) 
	  left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID 
	  left join PR_REVISION D with (nolock) on D.ID = C.REVID 
	  left join PR_OPERATIONS E with (nolock) on E.ID = B.OPERTYPEID
	  left join PR_OPERATIONS_GR F with (nolock) on F.ID = E.OPERGRID
	  where B.ID = @OperID

      if @visType = 1
        return 0;
	  
	  select @GrOper = A.SCHEME_GROUP from PR_MAP_OPER A with (nolock) where A.ID = @RevOperID
	  
	  if (@GrOper > 0)
	  begin
	    
		 if exists (select A.ID from PR_OPERATION A with (nolock)
					 where A.DEVICEID = @DeviceID 
					   and A.ORDERID = @OrderID
					   and A.REVOPERID in (select B.ID from PR_MAP_OPER B with (nolock)
											where B.MAPID = @mapID and B.SCHEME_GROUP = @GrOper)
					   and A.USERINPROGRESS <> @UserID)
			return 0;
	  
	  end

      /*если есть операции по внут. ремонту, то обычные операции не показывать */
      /*
 	  if @todoID = 0 and exists (select A.ID from PR_OPERATION A with (nolock)
				                  where A.DEVICEID = @DeviceID 
				                    and A.ORDERID = @OrderID
				                    and A.COMPLETED_DT is null
				                    and A.TODOID is not null
				                    and A.S_S not in (1000023)
				                 )
		return 0;
	  */

    /*if dbo.PR_OPER_QUALIFICATION(@OperID,@UserID,getdate()) = 1 */
    if dbo.PR_OPERGR_QUALIFICATION(@operGRID,@UserID,getdate()) = 1
      return 1
	  
  end

  
  if @OperState in (1000018) 
  begin
    if exists(select B.ID from PR_OPERATION_TIME B with (nolock) where B.OPERID = @OperID and B.USERID = @UserID)
      return 1
  end
  
  return 0

end