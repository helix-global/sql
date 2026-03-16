CREATE PROCEDURE [dbo].[FC_RECALC_FAILURERATES2_test]  @aMonthDate datetime, @aOnlyModelID int, @aMode int
AS
BEGIN
  set nocount on

  declare @mm int
  declare @yy int
 
  set @yy = year(@aMonthDate)   
  set @mm = month(@aMonthDate)   
  
  declare @dbeg datetime
  declare @dend datetime
  
  set @dbeg = dbo.COM_ENCODE_DATE(@yy,@mm,1)
  set @dend = dateadd(month,1,@dbeg)
  
   /*
  delete from FC_FAILURERATES_PRODUCED where FYEAR = @yy and FMONTH = @mm and (MODELID = @aOnlyModelID or @aOnlyModelID is null)

  insert into FC_FAILURERATES_PRODUCED (FYEAR,FMONTH,MTID,MODELID,PCOUNT)
  select year(A.COMPLETED_DT),month(A.COMPLETED_DT),B.TYPEID,A.MODELID,sum(isnull(A.RESQUANTITY,1))
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.COMPLETED_DT is not null
    and A.COMPLETED_DT > @dbeg
    and A.COMPLETED_DT < @dend
    and A.ORDERID is not null
    and (A.MODELID = @aOnlyModelID or @aOnlyModelID is null)
  group by year(A.COMPLETED_DT),month(A.COMPLETED_DT),B.TYPEID,A.MODELID     
*/
  delete from FC_FAILURERATES2_FARS where FYEAR = @yy and FMONTH = @mm and (MODELID = @aOnlyModelID or @aOnlyModelID is null)

  insert into FC_FAILURERATES2_FARS (FYEAR,FMONTH,MTID,MODELID,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select year(isnull(C.COMPLETED_DT,A.DATE_PRODUCT3)),month(isnull(C.COMPLETED_DT,A.DATE_PRODUCT3))
        ,B.TYPEID,A.MODELID,AA.ANALYSISCODEID,BB.REPCODEID
        ,sum(isnull(A.QUANTITY,1))
        ,sum(case A.INT_EXT when 2 /*ext*/ then 0 else isnull(A.QUANTITY,1) end)
        ,sum(case A.INT_EXT when 2 /*ext*/ then isnull(A.QUANTITY,1) else 0 end)
  from FC_REPORT A with (nolock)
  left join FC_REPORT_ANALYSIS_CODES AA with (nolock) on AA.VNESHID = A.ID
  left join FC_REPORT_CODES BB with (nolock) on BB.ID = AA.FCODE
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  where (A.MODELID = @aOnlyModelID or @aOnlyModelID is null)
    and isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) > @dbeg
    and isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) < @dend
    and A.S_S in (1000103,1000104,1000123) /*analized,approved,closed*/
    and AA.ANALYSISCODEID is not null
  group by year(isnull(C.COMPLETED_DT,A.DATE_PRODUCT3)),month(isnull(C.COMPLETED_DT,A.DATE_PRODUCT3)),B.TYPEID,A.MODELID,AA.ANALYSISCODEID,BB.REPCODEID
  
 
  update FC_FAILURERATES2_FARS 
  set PRODUCED_COUNT = (select sum(isnull(B.PCOUNT,0))
                             from FC_FAILURERATES_PRODUCED B with (nolock) 
                            where B.FYEAR = FC_FAILURERATES2_FARS.FYEAR
                              and B.FMONTH = FC_FAILURERATES2_FARS.FMONTH
                              and B.MODELID = FC_FAILURERATES2_FARS.MODELID
                            )
   where FYEAR = @yy
     and FMONTH = @mm
     and (MODELID = @aOnlyModelID or @aOnlyModelID is null)
  
 
  update FC_FAILURERATES2_FARS 
     set FRATE = FCOUNT / PRODUCED_COUNT * 100  
   where FYEAR = @yy
     and FMONTH = @mm
     and (MODELID = @aOnlyModelID or @aOnlyModelID is null)
     and PRODUCED_COUNT > 0

  /*  ПОКА не нужно
  declare @aOnlyModelMTID int
  if @aOnlyModelID is not null
    select @aOnlyModelMTID from PR_MODELS with (nolock) where ID = @aOnlyModelID
  
  delete from FC_FAILURERATES2_FARS_MT where FYEAR = @yy and FMONTH = @mm and (MTID = @aOnlyModelMTID or @aOnlyModelMTID is null)
  
  
  insert into FC_FAILURERATES2_FARS_MT (FYEAR,FMONTH,MTID,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select A.FYEAR,A.FMONTH,A.MTID,A.FACODE,A.FCODE,sum(A.FCOUNT),sum(FCOUNT_INT),sum(FCOUNT_EXT)
  from FC_FAILURERATES2_FARS A
  where A.FYEAR = @yy 
    and A.FMONTH = @mm
    and (A.MTID = @aOnlyModelMTID or @aOnlyModelMTID is null)
  group by A.FYEAR,A.FMONTH,A.MTID,A.FACODE,A.FCODE
  
  insert into FC_FAILURERATES2_FARS_MT (FYEAR,FMONTH,MTID,FACODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select @yy,@mm,B.ID as MTID,A.ID as FACODE,0,0,0
  from FC_FAILUREANALYSISCODES A with (nolock)
  left join PR_MODELTYPE B with (nolock) on B.ID = A.MTID
  where (B.ID = @aOnlyModelMTID or @aOnlyModelMTID is null)
    and B.ID is not null
    and not exists (select N.FACODE 
                      from FC_FAILURERATES2_FARS_MT N
                     where N.FYEAR = @yy
                       and N.FMONTH = @mm
                       and N.MTID = B.ID
                       and N.FACODE = A.ID
                       and N.FCODE is null
                       )
     and exists (select K.ID from FC_FAILURERATES_PRODUCED K where K.MTID = B.ID)  

  insert into FC_FAILURERATES2_FARS_MT (FYEAR,FMONTH,MTID,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select @yy,@mm,B.ID as MTID,A.ID as FACODE,C.ID as FCODE,0,0,0
  from FC_FAILUREANALYSISCODES A with (nolock)
  left join PR_MODELTYPE B with (nolock) on B.ID = A.MTID
  left join FC_FAILURECODES C with (nolock) on C.MTID = B.ID
  where (B.ID = @aOnlyModelMTID or @aOnlyModelMTID is null)
    and B.ID is not null
    and C.ID is not null
    and not exists (select N.FACODE 
                      from FC_FAILURERATES2_FARS_MT N
                     where N.FYEAR = @yy
                       and N.FMONTH = @mm
                       and N.MTID = B.ID
                       and N.FACODE = A.ID
                       and N.FCODE = C.ID
                       )
     and exists (select K.ID from FC_FAILURERATES_PRODUCED K where K.MTID = B.ID)  


  update FC_FAILURERATES2_FARS_MT 
  set PRODUCED_COUNT = (select isnull(sum(B.PCOUNT),0) 
                             from FC_FAILURERATES_PRODUCED B with (nolock) 
                            where B.FYEAR = FC_FAILURERATES2_FARS_MT.FYEAR
                              and B.FMONTH = FC_FAILURERATES2_FARS_MT.FMONTH
                              and B.MTID = FC_FAILURERATES2_FARS_MT.MTID
                            )
     ,ALLFCOUNT = (select isnull(sum(B.FCOUNT),0) 
                             from FC_FAILURERATES2_FARS B with (nolock) 
                            where B.FYEAR = FC_FAILURERATES2_FARS_MT.FYEAR
                              and B.FMONTH = FC_FAILURERATES2_FARS_MT.FMONTH
                              and B.MTID = FC_FAILURERATES2_FARS_MT.MTID
                            )
   where FYEAR = @yy
     and FMONTH = @mm
     and (MTID = @aOnlyModelMTID or @aOnlyModelMTID is null)

  update FC_FAILURERATES2_FARS_MT 
  set FRATE = FCOUNT / PRODUCED_COUNT * 100  
   where FYEAR = @yy
     and FMONTH = @mm
     and (MTID = @aOnlyModelMTID or @aOnlyModelMTID is null)
     and PRODUCED_COUNT > 0

  update FC_FAILURERATES2_FARS_MT 
  set FRATE_2ALLFAILURES = FCOUNT / ALLFCOUNT * 100  
   where FYEAR = @yy
     and FMONTH = @mm
     and (MTID = @aOnlyModelMTID or @aOnlyModelMTID is null)
     and ALLFCOUNT > 0


   /*3 сводная (по коду анализа) таблица */ 
  delete from FC_FAILURERATES2_FARS_FACODE where FYEAR = @yy and FMONTH = @mm 

  insert into FC_FAILURERATES2_FARS_FACODE (FYEAR,FMONTH,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT,PRODUCED_COUNT,ALLFCOUNT)
  select A.FYEAR,A.FMONTH,A.FACODE,A.FCODE,sum(A.FCOUNT),sum(FCOUNT_INT),sum(FCOUNT_EXT),sum(PRODUCED_COUNT),sum(ALLFCOUNT)
  from FC_FAILURERATES2_FARS_MT A
  where A.FYEAR = @yy 
	and A.FMONTH = @mm
  group by A.FYEAR,A.FMONTH,A.FACODE,A.FCODE

  update FC_FAILURERATES2_FARS_FACODE
  set FRATE = FCOUNT / PRODUCED_COUNT * 100  
   where FYEAR = @yy
     and FMONTH = @mm
     and PRODUCED_COUNT > 0

  update FC_FAILURERATES2_FARS_FACODE 
  set FRATE_2ALLFAILURES = FCOUNT / ALLFCOUNT * 100  
   where FYEAR = @yy
     and FMONTH = @mm
     and ALLFCOUNT > 0
*/ 

   set nocount off
END