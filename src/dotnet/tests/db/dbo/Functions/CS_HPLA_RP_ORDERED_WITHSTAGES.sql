CREATE function [dbo].[CS_HPLA_RP_ORDERED_WITHSTAGES](@mtID int, @UserID int, @aMode int, @date date, @avgMonthPeriod int)
returns @res table (ID int not null,MODELID int not null, STAGEID int not null,ORDDD date,ORDMONTH date,REQTIME decimal(18,2),AVAIL decimal(18,2))
begin
  
  /* вспомогательная функция для отчета cs_ila_resource_report
  возвращает список заказанных изделий по плановым датам в пересечении со стадиями
  требуемое время считается как среднее время завершения операций по этой модели
  за предыдущие N месяцев
  */
  
  insert into @res(ID,MODELID,ORDDD,ORDMONTH,STAGEID)		  
  select A.ID,A.MODELID, A.ORDDD,A.ORDMONTH,B.ID
  from dbo.CS_HPLA_RP_ORDERED(@mtID, @UserID, @aMode) A
  cross join PR_STAGES B with (nolock)
  where B.MTID = @mtID

  /*все варианты модель+операция из еще незавершенных изделий*/
  declare @modelsT table (MODELID int not null,OPERID int not null, AVGTIME decimal(18,2))
  
  insert into @modelsT(MODELID,OPERID)
  select distinct A.MODELID,C.OPERID 
  from @res A
  left join PR_DEVICE B with (nolock) on B.ID = A.ID
  left join PR_MAP_OPER C with (nolock) on C.MAPID = B.MAPID
  
  declare @startDate datetime = dateadd(month,-@avgMonthPeriod,@date)
  
  /*их среднее время завершения за предыдущие N месяцев*/
  update @modelsT set AVGTIME = (select avg(B.SUM_OPERATION_STAT_1) 
  from PR_OPERATION B with (nolock)  
  left join PR_DEVICE D with (nolock) on D.ID = B.DEVICEID and B.ORDERID = D.ORDERID
  where B.OPERTYPEID = "@modelsT".OPERID
    and D.MODELID = "@modelsT".MODELID
    and B.COMPLETED_DT >= @startDate
    and B.SUM_OPERATION_STAT_1 > 1
    )
  
  /*по незавершенным операциям считаем столько времени надо по средним значениям из @modelsT*/  
  update @res set REQTIME = (select sum(D.AVGTIME) 
  from PR_DEVICE A with (nolock)
  left join PR_MAP_OPER B with (nolock) on B.MAPID = A.MAPID
  left join PR_OPERATIONS C with (nolock) on C.ID = B.OPERID
  left join @modelsT D on D.MODELID = A.MODELID and D.OPERID = C.ID
  where A.ID = "@res".ID
    and C.STAGEID = "@res".STAGEID
    and not exists (select NN.DEVICEID 
                     from PR_DEVICE_SKIPPED_OP NN with (nolock) 
                    where NN.DEVICEID = A.ID 
                      and NN.ORDERID = A.ORDERID 
                      and NN.REVOPERID = B.ID)
    and not exists (select KK.ID
                      from PR_OPERATION KK with (nolock)
                     where KK.DEVICEID = A.ID
                       and KK.ORDERID = A.ORDERID
                       and KK.REVOPERID = B.ID
                       and KK.COMPLETED_DT is not null)                  
  )

  
    
  return

end