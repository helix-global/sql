CREATE function [dbo].[FC_DRILLDOWN_BY_CORRACTION]  (@aCorrActionID int, @aDate datetime, @aMode int)
returns @res table (ID int)
BEGIN

/*KB3851 расшифровка (выдает список ID)

@aMode:
1 - FRs 
2 - Items, produced in this period
*/

  declare @FACodeID int
  declare @FCodeID int
  declare @affectedModels int
  declare @mtid int
  declare @periodType int 
  
  declare @dbeg datetime
  declare @dend datetime
  
  select @FACodeID = A.ANALYSISCODEID
        ,@FCodeID = A.FAILURE_CODE
        ,@affectedModels = (select count(GG.MODELID) from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = A.ID)
        ,@mtid = B.MTID
        ,@periodType = isnull(A.PERIODTYPE,0)
    from FC_CORRACTIONS A with (nolock)
    left join FC_FAILUREANALYSISCODES B with(nolock) on B.ID = A.ANALYSISCODEID
   where A.ID = @aCorrActionID
   
  if @periodType in (0,2)  /*month*/
  begin
	set @dbeg = dbo.COM_ENCODE_DATE(datepart(year,@aDate),datepart(month,@aDate),1)
	set @dend = dateadd(month,1,@dbeg)  
  end
  else if @periodType in (1)  /*day*/
  begin
    set @dbeg = dbo.COM_ENCODE_DATE(datepart(year,@aDate),datepart(month,@aDate),datepart(day,@aDate))
    set @dend = dateadd(day,1,@dbeg)  
  end
   

  if @aMode = 1
  begin
	insert into @res (ID)
	select A.VNESHID 
	from FC_REPORT_ANALYSIS_CODES A with(nolock)
	left join FC_REPORT B with(nolock) on B.ID = A.VNESHID	
	left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
	where A.ANALYSISCODEID = @FACodeID
	  and (@FCodeID is null or exists (select J.ID from FC_REPORT_CODES J with(nolock) where J.VNESHID = B.ID and J.REPCODEID = @FCodeID))
	  and (@affectedModels = 0 or B.MODELID in (select L.MODELID from FC_CORRACTIONS_MODELS L with(nolock) where L.VNESHID = @aCorrActionID))
      and isnull(C.COMPLETED_DT,B.DATE_PRODUCT3) >= @dbeg
      and isnull(C.COMPLETED_DT,B.DATE_PRODUCT3) < @dend
	  and B.S_S in (1000103,1000104,1000123)
	
  end  

  if @aMode = 11  /*по дате отказа*/
  begin
	insert into @res (ID)
	select A.VNESHID 
	from FC_REPORT_ANALYSIS_CODES A with(nolock)
	left join FC_REPORT B with(nolock) on B.ID = A.VNESHID	
	left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
	where A.ANALYSISCODEID = @FACodeID
	  and (@FCodeID is null or exists (select J.ID from FC_REPORT_CODES J with(nolock) where J.VNESHID = B.ID and J.REPCODEID = @FCodeID))
	  and (@affectedModels = 0 or B.MODELID in (select L.MODELID from FC_CORRACTIONS_MODELS L with(nolock) where L.VNESHID = @aCorrActionID))
      and B.FAILUREDATE >= @dbeg
      and B.FAILUREDATE < @dend
	  and B.S_S in (1000103,1000104,1000123)
	
  end  

  
  if @aMode = 2
  begin

	insert into @res (ID)
	select A.ID
	from PR_DEVICE A with(nolock)
	left join PR_MODELS B with(nolock) on B.ID = A.MODELID
	where A.COMPLETED_DT is not null
		and A.COMPLETED_DT >= @dbeg
		and A.COMPLETED_DT < @dend
		and A.ORDERID is not null
		and B.TYPEID = @mtid
		and (@affectedModels = 0 or B.ID in (select L.MODELID from FC_CORRACTIONS_MODELS L with(nolock) where L.VNESHID = @aCorrActionID))
  
  end

  return

END