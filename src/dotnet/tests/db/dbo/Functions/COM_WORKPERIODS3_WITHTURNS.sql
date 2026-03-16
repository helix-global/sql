CREATE function [dbo].[COM_WORKPERIODS3_WITHTURNS] (@dBeg datetime, @dEnd datetime, @calendar int, @whID int, @emplID int)
returns table 
as 
/* в отличие от COM_WORKPERIODS2 учитывает периоды работы сотрудника в COM_EMPLOYEE и в COM_EMPL_PERIODS */

    return
    with 
	 empldays
	  as (select cast(DD as datetime) as dt from dbo.COM_EMPLOYED_DAYS(@emplID,@dBeg,@dEnd))  
	,workdays
	  as (select dt from empldays where dbo.COM_IS_WORKDAY2(dt,@calendar,@whID) = 1)  
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
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 else 0 end as adddaybeg
	            /*, case when datepart(hour,A.TTO) < 3 then 1 else 0 end as addday*/
	            , case when cast(A.TTO as time) < cast(A.TFROM as time) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
			from COM_WORKTIME_BR A with (nolock) where A.VNESHID = @whID
		union all 
		select cast('08:00' as time) as tbeg
			  ,cast('12:00' as time) as tend
			  ,1 as wturn
			  ,0 as adddaybeg
			  ,0 as addday
		  where @whID is null
		union all 
		select cast('13:00' as time) as tbeg
			  ,cast('17:00' as time) as tend
			  ,1 as wturn
			  ,0 as adddaybeg
			  ,0 as addday
		  where @whID is null				
		 )
	,worksall
	  as (
		  select A.dt,B.tbeg,B.tend,B.adddaybeg,B.addday,B.wturn
		  from workdays_with_turn_1 A
		  left join works B on B.wturn = A.wturn
		  /******** 12.12.2018 KB326 если в COM_TURNS в истории записана смена, которой сейчас нет в графике (график изменился) то взять первую смену */
		  where B.wturn is not null
		  union all
          select A.dt,C.tbeg,C.tend,C.adddaybeg,C.addday,B.wturn
		  from workdays_with_turn_1 A
		  left join works B on B.wturn = A.wturn
		  left join works C on C.wturn = 1
		  where B.wturn is null		  
		    and A.wturn > 1 
		  /*********    */
		  )      
	,worksall2
	  as (
		  select dt + cast(tbeg as datetime) + isnull(adddaybeg,0) as dbeg, dt + cast(tend as datetime) + isnull(addday,0) as dend, wturn
		  from worksall 
		  )      
    select dbeg as DBEG, dend as DEND, wturn as WTURN from worksall2