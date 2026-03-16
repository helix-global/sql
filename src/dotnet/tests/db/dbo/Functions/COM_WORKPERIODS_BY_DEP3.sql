CREATE function [dbo].[COM_WORKPERIODS_BY_DEP3] (@depId int, @dBeg datetime, @dEnd datetime, @calendar int, @emplID int, @includeChildDeps bit, @mode int)
returns @res table (DBEG datetime, DEND datetime)
as 
begin
/* @mode = 2 и @depId = FP включают режим при котором рабочим днем считается только тот в котором есть смена при условии что день в прошлом */
   
    declare @isFP int = 0
/*
    if @mode = 2
    begin
		declare @fpID int
		select top 1 @fpID = A.ID from COM_DEPARTMENTS A with(nolock) where A.GID = '27332ba0-fd72-4383-8c0a-83b99f45c50f'/*FP*/
    
		if exists (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@fpID,1) where ID = @depId)
			set @isFP = 1
    end
*/
    ;
    with 
     empldays
      as (select cast(DD as datetime) as dt, isnull(WTID,0) as WTID  from dbo.COM_EMPLOYED_DAYS_BY_DEP2(@depId,@emplID,@dBeg,@dEnd,@includeChildDeps))  
    ,workdays
      as (select dt, isnull(WTID,0) as WTID from empldays where dbo.COM_IS_WORKDAY2(dt,@calendar,WTID) = 1)  
    ,workdays2
      as (select dt,WTID 
            from workdays 
           where @isFP = 0 
              or (dt >= getdate())
              or (not exists(select P.ID from COM_WORKTIME_BR P with(nolock) where P.VNESHID = workdays.WTID and P.WTURN > 2 )) 
              or (exists (select G.WTURN from COM_TURNS G with (nolock) where G.EMPLID = @emplID and G.DD = dt)))
    ,workdays_with_turn
      as (select dt, isnull(WTID,0) as WTID
                ,(select G.WTURN from COM_TURNS G with (nolock) where G.EMPLID = @emplID and G.DD = dt) as wturn
           from workdays2)
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
          select dt + cast(tbeg as datetime)  + isnull(adddaybeg,0) as dbeg
               , dt + cast(tend as datetime) + isnull(addday,0) as dend 
          from worksall 
          )
    insert into @res (DBEG,DEND)                
    select dbeg, dend from worksall2          

    return 
end