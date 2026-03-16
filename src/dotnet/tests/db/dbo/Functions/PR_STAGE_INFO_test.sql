CREATE function [dbo].[PR_STAGE_INFO_test](@DeviceID int, @OrderID int , @StageID int, @aBeg datetime, @aEnd datetime, @aMode int)
returns decimal(10,4) as 
begin
/*
@aMode 
1 - возвращает:
         1 если участок завершен в заданный период; 
         2 если участок изменен в заданный период
2 - возвращает дельту % (за период) готовности участка
3 - возвращает % готовности участка
4 - возвращает сумму норм времени для всех операций участка
5 - возвращает 1 если на какой-нибудь операции участка нет нормы
6 - возвращает сумму норм времени для выполненных за период операций участка
7 - возвращает сумму норм времени для выполненных по @aEnd операций участка
8 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных за период 
9 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных по @aEnd 
12- возвращает дельту % (за период) готовности участка (оценка по кол-ву, когда нормы некорректны)
13- возвращает % готовности участка (оценка по кол-ву, когда нормы некорректны)
14 - возвращает количество операций участка
16 - возвращает количество операций участка выполненных за период 
17 - возвращает количество операций участка выполненных по @aEnd
*/
  declare @res decimal(10,4)
  
  if @aMode = 1
  begin

     /*
     если не существует НАЧАТЫХ операций по этому участку - участок не пройден вообще
     */  
     if not exists (select A.ID 
                     from PR_OPERATION A with (nolock)
					 JOIN PR_OPERATION_TIME OPT ON A.ID = OPT.OPERID
                     left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID 
                    where A.DEVICEID = @DeviceID
                      and A.ORDERID = @OrderID
                      and A.REVOPERID is not null
                      and B.STAGEID = @StageID
					  and OPT.DBEG < @aEnd)
        return 0;




		 /*
		 если существует незакрытая операция или операция, закрытая позже, или незакрытый ремонт
		 то участок не завершен, но "продвинут" за заданный период
		 */
         if exists (select A.ID 
                     from PR_OPERATION A with (nolock) 
                     left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID 
                    where A.DEVICEID = @DeviceID
                      and A.ORDERID = @OrderID
                      and A.REVOPERID is not null
                      and (A.COMPLETED_DT is null or A.COMPLETED_DT > @aEnd or (A.S_S = 1000038 and isnull(A.TROUBLEEXIT,0) = 0))
                      and B.STAGEID = @StageID)
         return 2;              


		 /* если максимальная дата завершения операции попадает в период, то участок завершен в этот период*/
		 declare @maxCompl datetime
		 select @maxCompl = MAX(A.COMPLETED_DT)
		   from PR_OPERATION A with (nolock) 
		   left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID 
		   where A.DEVICEID = @DeviceID
			 and A.ORDERID = @OrderID
			 and A.REVOPERID is not null
			 and B.STAGEID = @StageID
	         
		 if @maxCompl >= @aBeg and @maxCompl < @aEnd
		   return 1

  
     
     return null
  end
  else if @aMode = 2
  begin
     /* 2 - возвращает дельту % (за период) готовности участка*/

     declare @allStageTime decimal(10,4) /*сумма норм времени по всем операциям стадии*/
     declare @deltaStageTime decimal(10,4) /*сумма норм времени по завершенным за указанный период операций, относящихся к стадии*/
     declare @deltaStageAdd decimal(10,4) /*сумма времени затраченного по НЕзавершенным за указанный период операций, относящихся к стадии*/
     
     set @allStageTime = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,4)
     set @deltaStageTime = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,6)
     set @deltaStageAdd = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,8)
     
     if @allStageTime > 0
       set @res = ((ISNULL(@deltaStageTime,0) + isnull(@deltaStageAdd,0)) / @allStageTime) * 100
       
     return @res
  end
  else if @aMode = 3
  begin
     /* 3 - возвращает % готовности участка*/
     
     declare @allStageTime2 decimal(10,4) /*сумма норм времени по всем операциям стадии*/
     declare @cmplStageTime decimal(10,4) /*сумма норм времени по завершенным до @dEnd операций, относящихся к стадии*/
     declare @cmplStageAdd decimal(10,4) /*сумма времени затраченного по НЕзавершенным до @dEnd операций, относящихся к стадии*/
     
     set @allStageTime2 = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,4)
     set @cmplStageTime = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,7)
     set @cmplStageAdd = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,8)
     
     if @allStageTime2 > 0
       set @res = ((ISNULL(@cmplStageTime,0) + isnull(@cmplStageAdd,0)) / @allStageTime2) * 100
       
     return @res
  end
  else if @aMode = 4
  begin
     /* 4 - возвращает сумму норм времени для всех операций участка */
  
     select @res = SUM(coalesce(D.MANHOUR2,C.MANHOUR))
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       
     return @res   
  end 
  else if @aMode = 5
  begin
     /* 5 - возвращает 1 если на какой-нибудь операции участка нет нормы */
     
     if exists (
     select A.ID
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       and coalesce(D.MANHOUR2,C.MANHOUR) is null
       )
     return 1
     
  end 
  else if @aMode = 6
  begin
     /* 6 - возвращает сумму норм времени для выполненных за период операций участка */
  
     select @res = SUM(coalesce(D.MANHOUR2,C.MANHOUR))
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       and exists (select J.ID 
                    from PR_OPERATION J with (nolock)
                    where J.DEVICEID = @DeviceID
                      and J.ORDERID = @OrderID
                      and J.COMPLETED_DT is not null
                      and J.COMPLETED_DT between @aBeg and @aEnd
                      and J.REVOPERID = B.ID
                    )
       
     return @res   
  end 
  else if @aMode = 7
  begin
     /* 7 - возвращает сумму норм времени для выполненных по @aEnd операций участка */
  
     select @res = SUM(coalesce(D.MANHOUR2,C.MANHOUR))
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       and exists (select J.ID 
                    from PR_OPERATION J with (nolock)
                    where J.DEVICEID = @DeviceID
                      and J.ORDERID = @OrderID
                      and J.COMPLETED_DT is not null
                      and J.COMPLETED_DT < @aEnd
                      and J.REVOPERID = B.ID
                    )
       
     return @res   
  end 
  else if @aMode = 8
  begin
     /* 8 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных за период */
        declare @addT decimal(10,4) 
        select @addT = SUM(M3.RES)
        from (
        select case when M2.WT > M2.NORM then M2.NORM else M2.WT end as RES
        from (
        /*select dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),@aBeg,@aEnd) as WT*/
        select (select SUM(dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),@aBeg,@aEnd)) from PR_OPERATION_TIME B 
                 where B.OPERID = J.ID 
                   and B.DBEG < @aEnd 
                   and (B.DEND is null or B.DEND > @aBeg)
                ) as WT
              ,coalesce(D.MANHOUR2,C.MANHOUR) as NORM
        from PR_DEVICE A with (nolock)
        left join PR_MAP_OPER M with (nolock) on M.MAPID = A.MAPID
        left join PR_OPERATIONS C with (nolock) on C.ID = M.OPERID
        left join PR_OPERATION J with (nolock) on J.DEVICEID = A.ID and J.OPERTYPEID = M.OPERID
        /*left join PR_OPERATION_TIME B on B.OPERID = J.ID*/
        left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
        where A.ID = @DeviceID
          and C.STAGEID = @StageID
          and J.ORDERID = @OrderID
          and (J.COMPLETED_DT is null or J.COMPLETED_DT > @aEnd)
          /*and B.DBEG < @aEnd
          and (B.DEND is null or B.DEND > @aBeg)*/
          )M2
          )M3
          
        return @addT
  end
  else if @aMode = 9
  begin
     /* 9 - возвращает сумму времен (но не больше нормы) по недоделанным операциям участка выполненных по @aEnd  */
        declare @addT2 decimal(10,4) 
        select @addT2 = SUM(M3.RES)
        from (
        select case when M2.WT > M2.NORM then M2.NORM else M2.WT end as RES
        from (
        /*select dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),B.DBEG,@aEnd) as WT*/
        select (select SUM(dbo.PR_WORKTIME2BETWEEN(B.ID,GETDATE(),@aBeg,@aEnd)) from PR_OPERATION_TIME B 
                 where B.OPERID = J.ID 
                   and B.DBEG < @aEnd 
                   and (B.DEND is null or B.DEND > @aBeg)
                ) as WT
             , coalesce(D.MANHOUR2,C.MANHOUR) as NORM
        from PR_DEVICE A with (nolock)
        left join PR_MAP_OPER M with (nolock) on M.MAPID = A.MAPID
        left join PR_OPERATIONS C with (nolock) on C.ID = M.OPERID
        left join PR_OPERATION J with (nolock) on J.DEVICEID = A.ID and J.OPERTYPEID = M.OPERID
        /*left join PR_OPERATION_TIME B on B.OPERID = J.ID*/
        left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
        where A.ID = @DeviceID
          and C.STAGEID = @StageID
          and J.ORDERID = @OrderID
          and (J.COMPLETED_DT is null or J.COMPLETED_DT > @aEnd)
          /*and B.DBEG < @aEnd
          and (B.DEND is null or B.DEND > @aBeg)*/
          )M2
          )M3
          
        return @addT2
  end
  else if @aMode = 12
  begin

     declare @allStageQty decimal(10,4) /*количество операций стадии*/
     declare @deltaStageQty decimal(10,4) /*количество операций стадии завершенных за указанный период*/
     
     set @allStageQty = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,14)
     set @deltaStageQty = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,16)
     
     if @allStageQty > 0
       set @res = (@deltaStageQty / @allStageQty) * 100
       
     return @res
  end
  else if @aMode = 13
  begin

     declare @allStageQty2 decimal(10,4) /*количество операций стадии*/
     declare @cmplStageQty decimal(10,4) /*количество операций стадии завершенных до @dEnd */
     
     set @allStageQty2 = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,14)
     set @cmplStageQty = dbo.PR_STAGE_INFO(@DeviceID,@OrderID,@StageID,@aBeg,@aEnd,17)
     
     if @allStageQty2 > 0
       set @res = (@cmplStageQty / @allStageQty2) * 100
       
     return @res
  end
  else if @aMode = 14
  begin
     select @res = count(*)
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       
     return @res   
  end 
  else if @aMode = 16
  begin
     select @res = COUNT(*)
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       and exists (select J.ID 
                    from PR_OPERATION J with (nolock)
                    where J.DEVICEID = @DeviceID
                      and J.ORDERID = @OrderID
                      and J.COMPLETED_DT is not null
                      and J.COMPLETED_DT between @aBeg and @aEnd
                      and J.REVOPERID = B.ID
                    )
       
     return @res   
  end 
  else if @aMode = 17
  begin
     select @res = COUNT(*)
     from PR_DEVICE A with (nolock)
     left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
     left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
     left join PR_REV_OVER_MH D with (nolock) on D.REVID = A.REVID and D.OPERID = C.ID
     where A.ID = @DeviceID
       and C.STAGEID = @StageID
       and exists (select J.ID 
                    from PR_OPERATION J with (nolock)
                    where J.DEVICEID = @DeviceID
                      and J.ORDERID = @OrderID
                      and J.COMPLETED_DT is not null
                      and J.COMPLETED_DT < @aEnd
                      and J.REVOPERID = B.ID
                    )
       
     return @res   
  end 

  
  return null;  

end