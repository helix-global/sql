CREATE PROCEDURE [dbo].[FC_ANALYZE_BATCH_REPORTS] 
  @failureAnalysisStr nvarchar(1024), 
  @correctiveActionStr nvarchar(1024), 
  @correctiveActionDate datetime, 
  @actionPointsStr nvarchar(1024), 
  @ids varchar(max), 
  @failureAnalysisDetails varchar(max),
  @UserID int
AS
BEGIN

    declare @idst table (ID int not null)

	insert into @idst (ID)
	select distinct A.ID
	from dbo.COM_STR2TABLE_INT(@ids) A
	left join FC_REPORT B with (nolock) on B.ID = A.ID
	where B.S_S = 1

	declare @failureAnalysis table (failureCodeId int not null,
									analysisCodeId int not null,
									isMainReasonCodeId int not null,
									optionsCodeId int null)

	insert into @failureAnalysis (failureCodeId, analysisCodeId, isMainReasonCodeId, optionsCodeId)
	select distinct A.ID, A.ID2, A.ID3, case when A.ID4 = 0 then NULL else A.ID4 end
	from dbo.COM_STR2TABLE_INT_4COL(@failureAnalysisDetails) A

	/*TODO access check */

	declare @now datetime
	set @now = getdate()
	declare @nowD date
	set @nowD = cast(@now as date)

	update FC_REPORT 
		set FAILURE_ANALYSIS = @failureAnalysisStr,
			CORRECTIVE_ACTION = @correctiveActionStr,
			CORR_ACTION_DATE = @correctiveActionDate,
			ACTIONPOINTS = @actionPointsStr
	where FC_REPORT.ID in (select H.ID from @idst H)

	update FC_REPORT 
	set REPAIRDATE = @nowD 
	where FC_REPORT.ID in (select H.ID from @idst H) and FC_REPORT.REPAIRDATE is null

	delete from FC_REPORT_ANALYSIS_CODES where VNESHID in (select H.ID from @idst H)
	
	insert into FC_REPORT_ANALYSIS_CODES (S_CR, S_CDT, GID, VNESHID, ANALYSISCODEID, FCODE, OPTS, INITI)
	select @UserID, @now, newid(), RC.VNESHID, FA.analysisCodeId, RC.ID, FA.optionsCodeId, FA.isMainReasonCodeId
	from dbo.FC_REPORT_CODES RC 
	inner join @failureAnalysis FA on FA.failureCodeId = RC.REPCODEID
	where RC.VNESHID in (select H.ID from @idst H)

END