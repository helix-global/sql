create function [dbo].[COM_DURATION_NOTVACATION_SECONDS_MODE](@aEmplID int, @wtID int, @dbeg datetime, @dend datetime, @aMode int)
returns decimal(16,3) as 
begin

	/*
	19.06.2024 по сравнению с COM_DURATION_NOTVACATION_SECONDS 
	добавил @aMode чтобы, например, исключать определенные типы "отсутствий",
	которые в зависимости от трактовки: либо "отсутствия" либо "присутствия"
	*/
  
  declare @res decimal(16,3)
  
  set @res = DATEDIFF(s,@dbeg,@dend)


  if not exists (select A.ID 
                   from COM_VACATION A with (nolock) 
                  where A.EMPLID = @aEmplID 
                    and A.S_S in (1000141,2130051)/*appr*/
                    and A.DBEG < @dend
                    and dateadd(day,1,isnull(A.DEND,A.DBEG)) > @dbeg
                    )
                    return @res



 declare @absences decimal(16,3)
 
 select @absences = sum(duration) 
  from(
  select datediff(s,dbeg,dend) as duration
  from (
  select case when M.dbeg > @dbeg then M.dbeg else @dbeg end as dbeg
        ,case when M.dend > @dend then @dend else M.dend end as dend
  from ( 
select dbo.COM_VACATION_DBEG3(A.ID) as dbeg
      ,dbo.COM_VACATION_DEND3(A.ID) as dend  
  from COM_VACATION A with (nolock) 
   where A.EMPLID = @aEmplID 
     and A.S_S in (1000141,2130051) /*appr*/
     and A.DBEG < @dend
     and (isnull(@aMode,0) <> 2 or A.VACATIONTYPE <> 50/*business trip*/)
     and dateadd(day,1,isnull(A.DEND,A.DBEG)) > @dbeg
     ) M
     ) M2
     where M2.dbeg < @dend 
       and M2.dend > @dbeg
     ) M3
     where duration > 0
  
   if isnull(@absences ,0) > isnull(@res,0)
     set @absences = @res

  return isnull(@res,0) - isnull(@absences,0) 


  
end