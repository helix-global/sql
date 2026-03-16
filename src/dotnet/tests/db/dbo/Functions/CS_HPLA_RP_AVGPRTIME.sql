CREATE function [dbo].[CS_HPLA_RP_AVGPRTIME](@modelID int, @date datetime, @avgMonthPeriod int)
returns decimal(18,2) as 
begin
 /* вспомогательная функция для отчета cs_ila_resource_report
  возвращает среднее время производства изделий заданной модели за предыдущие N месяцев
  */

  declare @res decimal(18,2)
  
  select @res = avg(A.DURATION)
  from PR_DEVICE_STATVALUES A with (nolock)
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  where B.MODELID = @modelID
    and B.COMPLETED_DT < @date
    and B.COMPLETED_DT >= dateadd(month,-@avgMonthPeriod,@date)
    and A.ORDERID = B.ORDERID
    and A.DURATION > 0
    
  return @res / 60.0   
  
end