CREATE PROCEDURE [dbo].[CS_CS_YMA_MONTHLY_PROD_AND_REPAIR_RECALC] (@aMonths int)
AS
BEGIN
  set nocount on
  
  if @aMonths >= 0
  begin
    raiserror('Parameter @aMonths in CS_CS_YMA_MONTHLY_PROD_AND_REPAIR_RECALC should have negative value',16,0)
    return
  end

  declare @fromDate datetime = getdate()
  declare @toDate datetime = getdate()
  set @fromDate = dateadd( month, @aMonths, @fromDate)
  
  update CS_YMA_MONTHLY_PROD_AND_REPAIR set PRODUCED = null, REPAIRED = null where DBEG > @fromDate and MN is null

  declare @DateParamID int
  set @DateParamID = 4457 /* 'Date' in 'Fiber Module' */
  declare @fromDate2 datetime
  
  select @fromDate2 = max(A.DBEG) 
  from CS_YMA_MONTHLY_PROD_AND_REPAIR A 
  where A.PRODUCED is not null
  
  if @fromDate2 is null
    set @fromDate2 = @fromDate
  
  set @fromDate2 = dateadd( month, -1, @fromDate2)

  insert into CS_YMA_MONTHLY_PROD_AND_REPAIR (YY,MM,DBEG,DEND)
  select A.YY,A.MM,A.DBEG,A.DEND_NEXT from dbo.COM_MONTH_PERIOD(@fromDate2,@toDate) A
  where not exists (select B.YY from CS_YMA_MONTHLY_PROD_AND_REPAIR B where B.YY = A.YY and B.MM = A.MM)
  

  declare @dd table (DD datetime, ID int unique (DD,ID))
  insert into @dd (DD,ID)
  select distinct cast(A.PVALUE as date), B.DEVICEID
  from PR_OPERATION_PARAMS A with (nolock)
  left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
  where A.PARAMID = @DateParamID
	and cast(A.PVALUE as date) >= @fromDate2
	and B.COMPLETED_DT >= @fromDate2

  update CS_YMA_MONTHLY_PROD_AND_REPAIR set PRODUCED = (select sum(dbo.PR_DEVICE_PARAM_DEC(A.ID,228)) 
                             from PR_DEVICE A with (nolock)
						 left join PR_MODELS B with (nolock) on B.ID = A.MODELID
						     where B.TYPEID = 16
							   and A.ID in (select G.ID
                                              from @dd G
                                             where G.DD >= CS_YMA_MONTHLY_PROD_AND_REPAIR.DBEG
                                               and G.DD <  CS_YMA_MONTHLY_PROD_AND_REPAIR.DEND
											 )
							)
  where CS_YMA_MONTHLY_PROD_AND_REPAIR.PRODUCED is null


  set nocount off
END