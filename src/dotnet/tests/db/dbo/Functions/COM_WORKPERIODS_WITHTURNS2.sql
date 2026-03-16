CREATE function [dbo].[COM_WORKPERIODS_WITHTURNS2] (@dBeg datetime, @dEnd datetime, @calendar int, @whID int, @emplID int)
returns @res table (DBEG datetime,DEND datetime,WTURN int,WDD date)
as 
begin
/*ver2 учитывает если период между @dBeg @dEnd попал на смену сл. дня, начинающуюся вечером предыдущего дня
  ?? возможно, если в плане есть TDEXTDAY in (1,2) , то одновременно расширять и на +1 день к окончанию и на -1 день к началу ???
*/
    
    declare @n int = 0
    if exists (select K.ID from COM_WORKTIME_BR K with(nolock) where K.VNESHID = @whID and K.TDEXTDAY = 2)
       set @n = 1
    
    ;with 
     cte
	  as (select cast(DDATE as datetime) as dt from dbo.COM_DAY_PERIOD(@dBeg,@dEnd+@n))
	,workdays
	  as (select dt from cte where dbo.COM_IS_WORKDAY2(dt,@calendar,@whID) = 1)  
	,workdays_with_turn
	  as (select dt
	            ,(select G.WTURN from COM_TURNS G with (nolock) where G.EMPLID = @emplID and G.DD = dt) as wturn
	       from workdays)
	,workdays_with_turn_1
	  as (select dt,isnull(wturn,1) as wturn from workdays_with_turn)
	,works
	  as (select cast(A.TFROM as time) as tbeg
	            ,cast(A.TTO as time) as tend
	            ,ISNULL(A.WTURN,1) as wturn
	            /*
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 else 0 end as adddaybeg
	            , case when cast(A.TTO as time) < cast(A.TFROM as time) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
	            */
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 when isnull(A.TDEXTDAY,0) = 2 then -1 else 0 end as adddaybeg
	            , case when (cast(A.TTO as time) < cast(A.TFROM as time) and isnull(A.TDEXTDAY,0) <> 2) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
	            
			from COM_WORKTIME_BR A with (nolock) where A.VNESHID = @whID
		 )
	,worksall
	  as (
		  select A.dt,cast(B.tbeg as datetime) as tbeg,cast(B.tend as datetime) as tend,B.adddaybeg,B.addday,A.wturn
		  from workdays_with_turn_1 A
		  left join works B on B.wturn = A.wturn
		  )      
	,worksall2
	  as (
		  select dt + tbeg + isnull(adddaybeg,0) as dbeg, dt + tend + isnull(addday,0) as dend, wturn, dt
		  from worksall 
		  )      
	insert into @res (DBEG,DEND,WTURN,WDD)
    select dbeg as DBEG
    , dend as DEND
    , wturn as WTURN
    , dt as WDD from worksall2		  
    where dbeg < @dEnd
      and dend > @dBeg


  return
end