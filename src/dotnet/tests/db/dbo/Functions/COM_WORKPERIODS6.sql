CREATE function [dbo].[COM_WORKPERIODS6] (@dBeg datetime, @dEnd datetime, @calendar int, @emplID int)
returns @ret table (DBEG datetime, DEND datetime)
as 
begin
/* в отличие от COM_WORKPERIODS если графика нет - берет 08:00 - 12:00 13:00-17:00 */

    declare @defWtId int, @depId int
    declare @rootDep nvarchar(30)
    set @rootDep = dbo.DEF_SYS_CONST_STR('com_root_department','')

    select @defWtId = W.ID
        from COM_WORKTIME W 
            join COM_DEPARTMENTS D on W.DEPID=D.ID
        where D.CODE=@rootDep 
            and isnull(W.WTDEFAULT,0)=1

    select @depId = E.DEPID
        from COM_EMPLOYEE E
            where E.ID=@emplID
    

    declare @cte table (dt datetime, wtid int)
    insert into @cte
        select cast(DDATE as datetime)
                ,coalesce(dbo.COM_PERSONALWT_BY_DATE(DDATE,@emplID), dbo.COM_DEPARTMENT_DEF_WORKTIME(@depId), @defWtId)  
            from dbo.COM_DAY_PERIOD(@dBeg,@dEnd)

    declare @workdays table (dt datetime, wtid int)
    insert into @workdays
        select dt, wtid from @cte where dbo.COM_IS_WORKDAY2(dt,@calendar,wtid) = 1
    

    declare @workdays_with_turn table (dt datetime, wturn int, wtid int)
    insert into @workdays_with_turn
        select dt
                ,b.WTURN
                , w.wtid
           from @workdays w
                join COM_WORKTIME_BR b on w.wtid=b.VNESHID
            group by w.dt, b.WTURN, w.wtid
           

    declare @workdays_with_turn_1 table (dt datetime, wturn int, wtid int)
    insert into @workdays_with_turn_1
        select dt,isnull(wturn,1),wtid as wturn from @workdays_with_turn

    declare @works table (tbeg time, tend time, wturn int, addday int)
    insert into @works
        select cast(A.TFROM as time) as tbeg
                ,cast(A.TTO as time) as tend
                ,ISNULL(A.WTURN,1) as wturn
                , case when cast(A.TTO as time) < cast(A.TFROM as time) then 1 else 0 end as addday
            from COM_WORKTIME_BR A with (nolock) 
                join @workdays_with_turn_1 W on A.VNESHID=W.wtid and A.WTURN=W.wturn
        
    declare @worksall table (dt datetime, tbeg time, tend time, addday int)
    insert into @worksall
         select A.dt,B.tbeg,B.tend,B.addday
          from @workdays_with_turn_1 A
            left join @works B on B.wturn = A.wturn

    declare @worksall2 table (dbeg datetime, dend datetime)
    insert into @worksall2
        select dt + cast(tbeg as datetime) as dbeg, dt + cast(tend as datetime) + isnull(addday,0) as dend 
              from @worksall 

    insert into @ret   
        select dbeg as DBEG, dend as DEND from @worksall2    

    return
end