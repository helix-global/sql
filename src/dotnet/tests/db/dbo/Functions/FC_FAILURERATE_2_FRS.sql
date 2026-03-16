CREATE function [dbo].[FC_FAILURERATE_2_FRS] (@aID int,@aMode int)
returns @res table (ID int)
as 
begin
/*выдает список ID FAR по строке из FC_FAILURERATES_FARS_MT*/


declare @mtID int
declare @yy int
declare @mm int
declare @faCodeID int

select @mtID = A.MTID
      ,@yy = A.FYEAR 
      ,@mm = A.FMONTH
      ,@faCodeID = A.FACODE
from FC_FAILURERATES_FARS_MT A with (nolock)
where A.ID = @aID

declare @dbeg datetime
declare @dend datetime
  
set @dbeg = dbo.COM_ENCODE_DATE(@yy,@mm,1)
set @dend = dateadd(month,1,@dbeg)


insert into @res (ID) 
  select distinct A.ID
  from FC_REPORT A with (nolock)
  left join FC_REPORT_ANALYSIS_CODES AA with (nolock) on AA.VNESHID = A.ID
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  where isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) > @dbeg
    and isnull(C.COMPLETED_DT,A.DATE_PRODUCT3) < @dend
    and A.S_S in (1000103,1000104,1000123) /*analized,approved,closed*/
    and B.TYPEID = @mtID
    and AA.ANALYSISCODEID = @faCodeID


return

end