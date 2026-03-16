CREATE function [dbo].[COM_WORKPERIODS] (@dBeg datetime, @dEnd datetime, @calendar int, @whID int, @emplID int)
returns table 
as 
    return
    with 
	 cte
	  as (select cast(DDATE as datetime) as dt from dbo.COM_DAY_PERIOD(@dBeg,@dEnd))
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
		  select A.dt,cast(B.tbeg as datetime) as tbeg,cast(B.tend as datetime) as tend,B.adddaybeg,B.addday
		  from workdays_with_turn_1 A
		  left join works B on B.wturn = A.wturn
		  )      
	,worksall2
	  as (
		  select dt + tbeg + isnull(adddaybeg,0) as dbeg, dt + tend + isnull(addday,0) as dend 
		  from worksall 
		  )      
    select dbeg as DBEG, dend as DEND from worksall2