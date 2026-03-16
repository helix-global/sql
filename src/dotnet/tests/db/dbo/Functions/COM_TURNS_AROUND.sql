CREATE function [dbo].[COM_TURNS_AROUND] (@dd datetime, @whID int, @emplID int)
returns table 
as 
/* вспомогательная функция выводит смены сегодня и вчера относительно @dd*/

    return
    with 
     ddays
     as (
         select cast(@dd as date) as dt
         union all 
         select dateadd(day,-1,cast(@dd as date)) 
         union all 
         select dateadd(day,1,cast(@dd as date)) 
         where exists (select KK.ID from COM_WORKTIME_BR KK with(nolock) where KK.VNESHID = @whID and isnull(KK.TDEXTDAY,0) = 2)
     )
	 ,works
	  as (
	      select cast(A.TFROM as time) as tbeg
	            ,cast(A.TTO as time) as tend
	            ,ISNULL(A.WTURN,1) as wturn
	            /*
	            ,case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 else 0 end as adddaybeg
	            ,case when cast(A.TTO as time) < cast(A.TFROM as time) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
	            */
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 when isnull(A.TDEXTDAY,0) = 2 then -1 else 0 end as adddaybeg
	            , case when (cast(A.TTO as time) < cast(A.TFROM as time) and isnull(A.TDEXTDAY,0) <> 2) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday	            
			from COM_WORKTIME_BR A with (nolock) 
			where A.VNESHID = @whID
		 )
	,worksall
	  as (
		  select cast(A.dt as datetime) as dt,B.tbeg,B.tend,B.adddaybeg,B.addday,B.wturn
		  from ddays A
		  cross join works B 
		  )      
	,worksall2
	  as (
		  select dt + cast(tbeg as datetime) + isnull(adddaybeg,0) as dbeg
		       , dt + cast(tend as datetime) + isnull(addday,0) as dend 
		       , dt
		       , wturn
		  from worksall 
		  )      
   ,worksall3
     as 
     (
        select A.dbeg as DBEG
        , A.dend as DEND 
        , cast(A.dt as date) as WORKDAY
        , A.wturn as WTURN
        , (select min(B.dbeg) from worksall2 B where B.wturn = A.wturn and cast(A.dt as date) = cast(B.dt as date)) as WTURNBEG
        , (select max(B.dend) from worksall2 B where B.wturn = A.wturn and cast(A.dt as date) = cast(B.dt as date)) as WTURNEND
        , (@@datefirst+datepart(weekday,A.dt)-2)%7+1 as WORKDAYOFWEEK
        from worksall2 A	
      )
    ,workdays
      as
      (
        select isnull(WD1,0) as wd1, isnull(WD2,0) as wd2, isnull(WD3,0) as wd3
              ,isnull(WD4,0) as wd4, isnull(WD5,0) as wd5, isnull(WD6,0) as wd6, isnull(WD7,0) as wd7
		from COM_WORKTIME A with (nolock)
		where A.ID = @whID
      )  
    select A.DBEG,A.DEND,A.WORKDAY,A.WTURN,A.WTURNBEG,A.WTURNEND
      , datediff(minute,A.WTURNBEG,@dd) as DIFF
      , abs(datediff(minute,A.WTURNBEG,@dd)) as DIFFABS
      ,(case when exists (select F.ID from COM_TURNS F with(nolock) where F.DD = A.WORKDAY and F.WTURN = A.WTURN and F.EMPLID = @emplID) then 1 else 0 end) as ACTIVATEDWTURN
	  , datediff(minute,A.WTURNEND,@dd) as DIFF_END
      , abs(datediff(minute,A.WTURNEND,@dd)) as DIFFABS_END
      , (case when (select count(distinct wturn) from works) = 1 then 1 else 0 end) as ONLYONEWTURN
      , case WORKDAYOFWEEK when 1 then (select wd1 from workdays) when 2 then (select wd2 from workdays)
        when 3 then (select wd3 from workdays) when 4 then (select wd4 from workdays)
        when 5 then (select wd5 from workdays) when 6 then (select wd6 from workdays)
        when 7 then (select wd7 from workdays) end as ISWORKDAYOFWEEK
      ,WORKDAYOFWEEK
    from worksall3 A