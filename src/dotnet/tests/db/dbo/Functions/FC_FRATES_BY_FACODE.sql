create function [dbo].[FC_FRATES_BY_FACODE]  (@aFACodeID int, @dbeg datetime, @dend datetime, @aMode int)
returns @res table (MODELID int, FAILURES int, FCOUNT_INT int,FCOUNT_EXT int, PRODUCED int, ALLFAILURES int)
BEGIN

  insert into @res (MODELID,FAILURES,FCOUNT_INT,FCOUNT_EXT)
  select A.MODELID
        ,sum(isnull(A.QUANTITY,1))
        ,sum(case A.INT_EXT when 2 /*ext*/ then 0 else isnull(A.QUANTITY,1) end)
        ,sum(case A.INT_EXT when 2 /*ext*/ then isnull(A.QUANTITY,1) else 0 end)
  from FC_REPORT A with (nolock)
  left join FC_REPORT_ANALYSIS_CODES AA with (nolock) on AA.VNESHID = A.ID
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  where AA.ANALYSISCODEID = @aFACodeID
    and isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) > @dbeg
    and isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) < @dend
    and A.S_S in (1000103,1000104,1000123) /*analized,approved,closed*/
  group by A.MODELID
  

  declare @produced table (MODELID int not null primary key, PCOUNT int)

  insert into @produced (MODELID,PCOUNT)
  select A.MODELID,sum(isnull(A.RESQUANTITY,1))
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.COMPLETED_DT is not null
    and A.COMPLETED_DT > @dbeg
    and A.COMPLETED_DT < @dend
    and A.ORDERID is not null
    and A.MODELID in (select MODELID from @res)
  group by A.MODELID


  update @res set PRODUCED = (select B.PCOUNT from @produced B where B.MODELID = "@res".MODELID)

  return

END