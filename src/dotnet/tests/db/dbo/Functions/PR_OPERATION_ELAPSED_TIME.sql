
CREATE function [dbo].[PR_OPERATION_ELAPSED_TIME] (@OperationID int)
returns @res table (EMPLID int, ELAPSED decimal(12,2))
as 
begin

  declare @AdditionMode int
  declare @TimeToAdd decimal(12,2)
  declare @TimeShiftParamID int
  declare @OperationState int
  declare @RevID int

  select 
     @OperationState=O.S_S
    ,@AdditionMode=isnull(MO.TC_ACTION,0)
    ,@TimeToAdd=isnull(MO.TC_MINUTE,0)
    ,@TimeShiftParamID = isnull(MO.TC_PARAMID,0)
    ,@RevID=D.REVID
  from PR_OPERATION O with (nolock)
  left join PR_MAP_OPER MO with (nolock) on MO.ID = O.REVOPERID
  left join PR_DEVICE D with (nolock) on O.DEVICEID = D.ID
  where O.ID=@OperationID

--  if (@OperationState <> 1/*Completed*/)
--  begin
--    raise error
--    return
--  end

  insert into @res (EMPLID, ELAPSED)
  select TT.EMPID, sum(coalesce(TT.ELAPSEDCORR,TT.ELAPSED_D,0))
  from PR_OPERATION A with (nolock)
	left join PR_OPERATION_TIME TT with (nolock) on A.ID = TT.OPERID
  where A.ID=@OperationID
  group by TT.EMPID

  if not exists (select * from @res)
  begin
    return
  end

  if (@AdditionMode = 1 /* = */) 
  begin
    update @res set ELAPSED = @TimeToAdd / (select count(*) from @res)
  end
    
  if (@AdditionMode = 2 /* plus */) 
  begin
    update @res set ELAPSED = ELAPSED + (@TimeToAdd / (select count(*) from @res))
  end
    
  if (@AdditionMode = 3 /* plus by parameter */) 
  begin
    if exists (select G.ID from PR_OPERATION_PARAMS G with (nolock) where G.OPERID = @OperationID and G.PARAMID=@TimeShiftParamID and dbo.DEF_VARIANT2BOOL(G.PVALUE)=1)
    begin 
      update @res set ELAPSED = ELAPSED + (@TimeToAdd / (select count(*) from @res))
    end
  end
  
  if (@AdditionMode = 4 /*KB1670*/) 
  begin
  
    update @res set ELAPSED = ELAPSED + (@TimeToAdd / (select count(*) from @res))
  
	declare @addFromParam decimal(16,2)
	set @addFromParam = dbo.PR_OPER_RAW_ADDFROMPARAM_TIME(@OperationID,@TimeShiftParamID)
	if @addFromParam is not null
	begin
		update @res set ELAPSED = ELAPSED + (@addFromParam / (select count(*) from @res))
	end
	
  end

  declare @AddedTime table (QUALIFICATION int, ADDEDTIME decimal(10,1))
  insert into @AddedTime (QUALIFICATION, ADDEDTIME)
  select A.QUALIFICATION, sum(isnull(A.ADDVALUE,0))
  from PR_REV_ADD_TIMES A with (nolock)
  left join PR_MAP_OPER MO with (nolock) on A.MAPOPERID = MO.ID
  where A.REVID = @RevID
    and MO.OPERID=@OperationID
    and A.PRODSUPPORT<>1
  group by A.QUALIFICATION

  if exists (select * from @AddedTime)
  begin
    update R
      set 
        R.ELAPSED = 
          R.ELAPSED + 
          ((select sum(T.ADDEDTIME) from @AddedTime T where T.QUALIFICATION=E.QUALIFICATION) / (select count(*) from @res R2 left join COM_EMPLOYEE E2 on E2.ID=R2.EMPLID where E.QUALIFICATION=E2.QUALIFICATION))
    from @res R
    left join COM_EMPLOYEE E with (nolock) on E.ID=R.EMPLID
    where exists (select * from @AddedTime T where T.QUALIFICATION=E.QUALIFICATION)
  end

  return

end