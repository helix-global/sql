CREATE function [dbo].[COM_WORKPERIODS_BY_DEP2] (@depId int, @dBeg datetime, @dEnd datetime, @calendar int, @emplID int, @includeChildDeps bit)
returns table 
as 
/* в отличие от COM_WORKPERIODS2 учитывает периоды работы сотрудника в COM_EMPLOYEE и в COM_EMPL_PERIODS */

    return
    with 
     empldays
      as (select cast(DD as datetime) as dt, isnull(WTID,0) as WTID  from dbo.COM_EMPLOYED_DAYS_BY_DEP2(@depId,@emplID,@dBeg,@dEnd,@includeChildDeps))  
    ,workdays
      as (select dt, isnull(WTID,0) as WTID from empldays where dbo.COM_IS_WORKDAY2(dt,@calendar,WTID) = 1)  
    ,workdays_with_turn
      as (select dt, isnull(WTID,0) as WTID
                ,(select G.WTURN from COM_TURNS G with (nolock) where G.EMPLID = @emplID and G.DD = dt) as wturn
           from workdays)
    ,workdays_with_turn_1
      as (select dt,isnull(wturn,1) as wturn, isnull(WTID,0) as WTID from workdays_with_turn)
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
                
                , A.VNESHID as WTID
            from COM_WORKTIME_BR A with (nolock) 
                where ISNULL(A.VNESHID,0) in (select WTID from workdays_with_turn_1)
        union all 
        select cast('08:00' as time) as tbeg
              ,cast('12:00' as time) as tend
              ,1 as wturn
              ,0 as adddaybeg
              ,0 as addday
              , 0
        union all 
        select cast('13:00' as time) as tbeg
              ,cast('17:00' as time) as tend
              ,1 as wturn
              ,0 as adddaybeg
              ,0 as addday
              ,0
         )
    ,worksall
      as (
          select A.dt,B.tbeg,B.tend,B.adddaybeg,B.addday
          from workdays_with_turn_1 A
          left join works B on B.wturn = A.wturn and B.WTID=A.WTID
          /******** 12.12.2018 KB326 если в COM_TURNS в истории записана смена, которой сейчас нет в графике (график изменился) то взять первую смену */
          where B.wturn is not null
          union all
          select A.dt,C.tbeg,C.tend,C.adddaybeg,C.addday
          from workdays_with_turn_1 A
          left join works B on B.wturn = A.wturn and B.WTID=A.WTID
          left join works C on C.wturn = 1 and C.WTID=A.WTID
          where B.wturn is null       
            and A.wturn > 1 
          /*********    */
          )      
    ,worksall2
      as (
          select dt + cast(tbeg as datetime)  + isnull(adddaybeg,0) as dbeg, dt + cast(tend as datetime) + isnull(addday,0) as dend 
          from worksall 
          )      
    select dbeg as DBEG, dend as DEND from worksall2