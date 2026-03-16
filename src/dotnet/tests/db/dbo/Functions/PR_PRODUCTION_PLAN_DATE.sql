
CREATE FUNCTION [dbo].[PR_PRODUCTION_PLAN_DATE]
(
        @DepID INT
       ,@dBeg DATETIME
       ,@dEnd DATETIME
       ,@aMode int
)
RETURNS @RES TABLE (
              EXPDATE DATE
             ,WEEKN int
             ,DAY_OFWEEK int
             ,DEVICECOUNT int
             ,NONORM int
             ,EMPL_MH decimal(10,4)
             ,DEVICE_MH decimal(10,4)
             ,TR_PERCENT decimal(10,4)
             ,WEEK_PERCENT decimal(10,4)
             ,WEEK_EMPL_MH decimal(10,4)
             ,HOLIDAY int
)
AS 
BEGIN


    declare @dd date
    set @dd = @dBeg
    while @dd < @dEnd
    begin
       insert into @RES (EXPDATE,WEEKN,DAY_OFWEEK) 
           values (@dd
                   ,datepart(isowk,@dd)
                   ,(@@datefirst+datepart(weekday,@dd)-2)%7+1  )
       set @dd = dateadd(day,1,@dd)
    end
    update @RES set HOLIDAY = 1 where dbo.COM_IS_WORKDAY(EXPDATE,1) = 0
   

    declare @dev table (ID int,EXPDATE datetime,WEEKN int,MAPID int, REVID int,ERR int,MANH decimal(10,4))
    
    insert into @dev (ID,EXPDATE,MAPID,REVID,ERR)
     select A.ID
           ,ISNULL(/*C.COMPLETED_DT*/C.DD,B.EXPDATE)
           ,A.MAPID
           ,A.REVID
           ,0
     from PR_DEVICE A with (nolock) 
     LEFT join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
     left join PR_SUPPLY C  with (nolock) on C.ID = A.SORDERID
     where A.COMPLETED_DT is null
       and B.DEPARTMENTID = @DepID
       and ISNULL(/*C.COMPLETED_DT,*/C.DD,  B.EXPDATE) >= @dBeg
       and ISNULL(/*C.COMPLETED_DT,*/ C.DD, B.EXPDATE) <= @dEnd

    --update @dev set WEEKN = datediff(week, dateadd(day,-1,cast(datename(year,EXPDATE) as datetime)),dateadd(day,-1,EXPDATE)) + 1
    update @dev set WEEKN = datepart(isowk,EXPDATE)
    
    update @dev set ERR = 1
     where exists ( select G.ID
                      from PR_MAP_OPER G with (nolock)
                      left join PR_OPERATIONS D with (nolock) on D.ID = G.OPERID
                      left join PR_REV_OVER_MH H with (nolock) on H.OPERID = D.ID and H.REVID = "@dev".REVID
                      where G.MAPID = "@dev".MAPID
                        and ISNULL(H.MANHOUR2,D.MANHOUR) is null
                      )
     
    update @dev set MANH = (select MAX(FROMEND_TIME) from dbo.PR_DEVICE_REST_PROD_TIME_T("@dev".ID))
    where ERR = 0
    

    update @RES set DEVICECOUNT = (select COUNT(*) from @dev where EXPDATE = "@RES".EXPDATE  )
    update @RES set EMPL_MH = (select COUNT(*) 
                                 from COM_EMPLOYEE A with (nolock) 
                                where A.DEPID = @DepID
                                  and A.S_S = 1
                                  and ISNULL(A.NOPROD,0) = 0
                                     ) * 8 * 60
    update @RES set DEVICE_MH = (select sum(MANH) from @dev where EXPDATE = "@RES".EXPDATE  )
    update @RES set TR_PERCENT = (DEVICE_MH / EMPL_MH) * 100 where EMPL_MH > 0
    update @RES set NONORM = (select nullif(SUM(ERR),0) from @dev where EXPDATE = "@RES".EXPDATE )
    update @RES set WEEK_EMPL_MH = (select SUM(B.EMPL_MH) from @RES B where B.WEEKN = "@RES".WEEKN and ISNULL(B.HOLIDAY,0) = 0)
   
    update @RES set WEEK_PERCENT = (select sum(MANH) from @dev where WEEKN = "@RES".WEEKN ) where EMPL_MH > 0
    update @RES set WEEK_PERCENT = (WEEK_PERCENT /WEEK_EMPL_MH ) * 100 where EMPL_MH > 0


RETURN
END