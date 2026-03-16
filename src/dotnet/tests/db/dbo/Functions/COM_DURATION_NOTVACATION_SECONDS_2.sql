CREATE function [dbo].[COM_DURATION_NOTVACATION_SECONDS_2](@aEmplID int, @wtID int, @dbeg datetime, @dend datetime)
returns decimal(16,3) as 
begin
  
  declare @res decimal(16,3)
  
  set @res = DATEDIFF(s,@dbeg,@dend)




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
     and A.DBEG <= @dend
     and dateadd(day,2,isnull(A.DEND,A.DBEG)) >= @dbeg
     ) M
     ) M2
     where M2.dbeg <= @dend 
       and M2.dend >= @dbeg
     ) M3
     where duration > 0
  
   if isnull(@absences ,0) > isnull(@res,0)
     set @absences = @res

  return isnull(@res,0) - isnull(@absences,0) 


  
end