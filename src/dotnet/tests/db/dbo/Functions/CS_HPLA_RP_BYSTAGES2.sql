CREATE function [dbo].[CS_HPLA_RP_BYSTAGES2](@mtID int, @UserID int, @aMode int, @date date, @avgMonthPeriod int, @dBeg datetime, @dEnd datetime)
returns @res table (STAGEID int not null,ORDMONTH date,REQTIME decimal(18,2),AVAIL decimal(18,2),AVAILINPROD decimal(18,2))
begin
  
  /* вспомогательная функция для отчета cs_ila_resource_report
  возвращает список требуемых и доступных ресурсов по месяцам и стадиям
  
  */

    declare @nowD date = cast(getdate() as date)


    insert into @res (STAGEID,ORDMONTH,REQTIME)
    select A.STAGEID
          ,A.ORDMONTH
          ,SUM(A.REQTIME) 
    from dbo.CS_HPLA_RP_ORDERED_WITHSTAGES2(@mtID,@UserID,0,@nowD,@avgMonthPeriod, @dBeg, @dEnd) A
    group by ORDMONTH,STAGEID


  declare @maxDate date 
  select @maxDate = max(ORDMONTH) from @res
  set @maxDate = dateadd(month,1,@maxDate)
  
  declare @hasResources table (STAGEID int, DD date, AVAIL decimal(18,2), AVAILINPROD decimal(18,2))
  insert into @hasResources (STAGEID,DD,AVAIL,AVAILINPROD)
  select STAGEID,DD,AVAILRES,AVAILINPRODRES
  from dbo.CS_HPLA_RP_RESAVAILABLE(@mtID, @maxDate,0)

  
  update @res set AVAIL = (select sum(AVAIL)
                             from @hasResources
                            where STAGEID = "@res".STAGEID
                              and year(DD) = year("@res".ORDMONTH)
                              and month(DD) = month("@res".ORDMONTH)
                          ),
				AVAILINPROD = (select sum(AVAILINPROD)
                             from @hasResources
                            where STAGEID = "@res".STAGEID
                              and year(DD) = year("@res".ORDMONTH)
                              and month(DD) = month("@res".ORDMONTH)
                          )

                              
  return

end