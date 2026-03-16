create PROCEDURE [dbo].[PRR_LABOR_UTILIZATION_RECALC] ( @aDepID int, @aMonths int)
AS
BEGIN

declare @dbeg datetime
declare @now datetime = getdate()

set @dbeg = dateadd(month,@aMonths,@now)

set @dbeg = dbo.COM_ENCODE_DATE(year(@dbeg),month(@dbeg),1)

delete from PRR_LABOR_UTILIZATION_CACHE where DEPID = @aDepID and DD >= cast(@dbeg as date)
insert into PRR_LABOR_UTILIZATION_CACHE (DEPID,DD,MONTH,YEAR,ALLPRODUCED,EMPL_COUNT,ALL_MH,ALL_MH_VACATIONS,ALL_MH_DELTA,MH_INOPERATIONS,MH_INOPERATIONS_INDEP,MH_INOPERATIONS_NOT_INDEP,DEV_PR)
select @aDepID
  ,dbo.COM_ENCODE_DATE(A.YEAR,A.MONTH,1)
  ,A.MONTH
  ,A.YEAR
  ,A.ALLPRODUCED
  ,A.EMPL_COUNT
  ,A.ALL_MH
  ,A.ALL_MH_VACATIONS
  ,A.ALL_MH_DELTA
  ,A.MH_INOPERATIONS
  ,A.MH_INOPERATIONS_INDEP
  ,A.MH_INOPERATIONS_NOT_INDEP
  ,A.DEV_PR
from dbo.PRR_LABOR_UTILIZATION(@aDepID, @aMonths) A

/*
 create table PRR_LABOR_UTILIZATION_CACHE (ID int not null identity,
             DEPID int not null
            ,DD date not null
			,MONTH INT not null
			,YEAR int not null
			,ALLPRODUCED int          
			,EMPL_COUNT int       -- количество сотрудников
			,ALL_MH decimal(18,2)           -- всего ресурсов за вычетом отпусков
			,ALL_MH_VACATIONS decimal(18,2) -- всего ресурсов без вычета отпусков
			,ALL_MH_DELTA decimal(18,2)     -- отпуск 
			,MH_INOPERATIONS decimal(18,2)  -- всего учтено на операциях
			,MH_INOPERATIONS_INDEP decimal(18,2)  -- всего учтено на операциях только сотрудниками отдела
			,MH_INOPERATIONS_NOT_INDEP decimal(18,2) -- всего учтено на операциях только сотрудниками других отделов
			,DEV_PR decimal(16,1)        -- процент утилизации
			)
			
  create unique index IX_PRR_LABOR_UTILIZATION_CACHE_1 on PRR_LABOR_UTILIZATION_CACHE (DEPID, DD)
			
*/			

END