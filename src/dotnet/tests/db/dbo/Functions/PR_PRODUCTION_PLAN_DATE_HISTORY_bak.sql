

CREATE FUNCTION [dbo].[PR_PRODUCTION_PLAN_DATE_HISTORY_bak]
(
        @DepID INT
       ,@dBeg DATETIME
       ,@dEnd DATETIME
       ,@aMode int
)
RETURNS @RES TABLE (
              EXPDATE DATE PRIMARY KEY
             ,WEEKN int
             ,DAY_OFWEEK int
             ,DEVICECOUNT int
             ,NONORM int
             ,EMPL_MH decimal(10,2)
             ,DEVICE_MH decimal(10,2)
             ,TR_PERCENT decimal(10,2)
             ,WEEK_PERCENT decimal(10,2)
             ,WEEK_EMPL_MH decimal(10,2)
             ,HOLIDAY int
)
AS 
BEGIN


     declare @dd date
    set @dd = @dBeg

	/*заполнение календаря на период*/
    while @dd < @dEnd
    begin
       insert into @RES (EXPDATE,WEEKN,DAY_OFWEEK) 
           values (@dd
                   ,datepart(isowk,@dd)
                   ,(@@datefirst+datepart(weekday,@dd)-2)%7+1  )
       set @dd = dateadd(day,1,@dd)
    end
	/*-------------------*/
	/*проставление флага "выходной"*/
    update @RES set HOLIDAY = 1 where dbo.COM_IS_WORKDAY(EXPDATE,1) = 0
   

    declare @dev table (ID int,EXPDATE datetime,WEEKN int,MAPID int, REVID int,ERR int,MANH decimal(10,1), COMPLETED INT , DEV_QTY INT PRIMARY KEY(ID, WEEKN, EXPDATE))
    
	/*заполнение списка изделий*/
    insert into @dev (ID,EXPDATE,WEEKN, MAPID,REVID,ERR, COMPLETED,  DEV_QTY)
     select A.ID
           ,ISNULL(C.COMPLETED_DT,B.EXPDATE)
           ,datepart(isowk,ISNULL(C.COMPLETED_DT,B.EXPDATE))
           ,A.MAPID
           ,A.REVID
           ,0
		   ,CASE
				WHEN A.COMPLETED_DT IS NOT NULL THEN 1
				ELSE 0 
		   END AS COMPLETED
		   ,1 --для изделий, уже запущенных в производство (или для тех изделий, для которых созданы serial number), всегда равно 1
     from PR_DEVICE A with (nolock) 
     LEFT join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
     left join PR_SUPPLY C  with (nolock) on C.ID = A.SORDERID
     where --(A.COMPLETED_DT is null --OR (A.COMPLETED_DT >= @dBeg and A.COMPLETED_DT < @dEnd)) -- не только незаконченные изделия, но и те изделия, которые были сделаны в период
       --and 
	   B.DEPARTMENTID = @DepID
       and ISNULL(C.COMPLETED_DT,B.EXPDATE) >= @dBeg
       and ISNULL(C.COMPLETED_DT,B.EXPDATE) < @dEnd

	 UNION
	 
	 SELECT
		-1 * ROW_NUMBER() OVER (ORDER BY ORD.EXPDATE) AS ID
		,ORD.EXPDATE
		,datepart(isowk,ORD.EXPDATE)
		,REV.MAPID
		,REV.ID
		,0
		,0
		,ORD_T.QUANTITY -- для изделий, по которым ещё не созданы serial number, указываем кол-во изделий одной ревизии из заказа 
	 FROM PR_PRORDER_T ORD_T
	 JOIN PR_REVISION REV ON ORD_T.REVID = REV.ID
	 JOIN PR_PRORDER ORD ON ORD_T.PRORDERID = ORD.ID
	 LEFT JOIN PR_DEVICE DEV ON ORD.ID = DEV.ORDERID
	WHERE
		ORD.DEPARTMENTID = @DepID
	AND
		ORD.EXPDATE IS NOT NULL
	AND
		ORD.EXPDATE >= @dBeg AND ORD.EXPDATE < @dEnd
	AND
		ORD.ORDERTYPE = 0
	AND
		DEV.ID IS NULL

    --update @dev set WEEKN = datepart(isowk,EXPDATE)
    --update @dev set WEEKN = datediff(week, dateadd(day,-1,cast(datename(year,EXPDATE) as datetime)),dateadd(day,-1,EXPDATE)) + 1
    
    update @dev set ERR = 1
     where exists ( select G.ID
                      from PR_MAP_OPER G with (nolock)
                      left join PR_OPERATIONS D with (nolock) on D.ID = G.OPERID
                      left join PR_REV_OVER_MH H with (nolock) on H.OPERID = D.ID and H.REVID = "@dev".REVID
                      where G.MAPID = "@dev".MAPID
                        and ISNULL(H.MANHOUR2,D.MANHOUR) is null
                      )

    
	UPDATE @dev
		SET MANH = T.MANH
	FROM (select D.ID AS DEVICEID,
				SUM(COALESCE(C.MANHOUR2,B.MANHOUR, 0)) AS MANH
			from PR_DEVICE D with (nolock)
			left join PR_MAP_OPER A with (nolock) on A.MAPID = D.MAPID 
			left join PR_REVISION R with (nolock) on R.ID = D.REVID
			left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERID
			left join PR_REV_OVER_MH C with (nolock) on C.OPERID = B.ID and C.REVID = R.ID
			GROUP BY D.ID
			) T
	WHERE
		T.DEVICEID = ID

	UPDATE @dev
		SET MANH = T.MANH*DEV_QTY --для изделий, по которым ещё не созданы serial number, умножаем нормочасы одного изделия на кол-во изделий этой ревизии в заказе.
	FROM (
			select REV.ID AS REVISIONID
				,SUM(COALESCE(ROMH.MANHOUR2,OP.MANHOUR, 0)) AS MANH
			from PR_REVISION REV with (nolock)
			left join PR_MAP_OPER MO with (nolock) on MO.MAPID = REV.MAPID 
			left join PR_OPERATIONS OP with (nolock) on OP.ID = MO.OPERID
			left join PR_REV_OVER_MH ROMH with (nolock) on ROMH.OPERID = OP.ID and ROMH.REVID = REV.ID
			GROUP BY REV.ID
			) T
	WHERE
		T.REVISIONID = REVID
	AND
		ID < 0
	
	
    update @RES set DEVICECOUNT = (select SUM(DEV_QTY) from @dev where EXPDATE = "@RES".EXPDATE  )

    /*update @RES set EMPL_MH = (select COUNT(*) 
                                 from COM_EMPLOYEE A with (nolock) 
                                where A.DEPID = @DepID
                                  and A.S_S = 1
                                  and ISNULL(A.NOPROD,0) = 0
                                     ) * 8 * 60*/
	UPDATE @RES 
		SET EMPL_MH = (SELECT COUNT(ID)*8*60 FROM dbo.COM_EPLOYEES_IN_PRODUCTION(@DepID, "@RES".EXPDATE) )

    update @RES set DEVICE_MH = (select sum(MANH) from @dev where EXPDATE = "@RES".EXPDATE  )

    update @RES set TR_PERCENT = (DEVICE_MH / EMPL_MH) * 100 where EMPL_MH > 0

    update @RES set NONORM = (select nullif(SUM(ERR),0) from @dev where EXPDATE = "@RES".EXPDATE )

    update @RES set WEEK_EMPL_MH = (select SUM(B.EMPL_MH) from @RES B where B.WEEKN = "@RES".WEEKN and ISNULL(B.HOLIDAY,0) = 0) 
   
    update @RES set WEEK_PERCENT = (select sum(MANH) from @dev where WEEKN = "@RES".WEEKN ) where EMPL_MH > 0

    update @RES set WEEK_PERCENT = (WEEK_PERCENT /WEEK_EMPL_MH ) * 100 where EMPL_MH > 0

RETURN
END