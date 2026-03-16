CREATE function [dbo].[COM_DURATION_NOTVACATION](@aEmplID int, @wtID int, @dbeg datetime, @dend datetime)
returns decimal(16,3) as 
begin
  
  declare @res decimal(16,3)
  
  set @res = DATEDIFF(mi,@dbeg,@dend)

  /* полный день - отпуск => результат 0 */
  if exists (select A.ID 
               from COM_VACATION A with (nolock) 
              where A.EMPLID = @aEmplID 
                and A.S_S = 1000141/*appr*/
                and isnull(A.PERIODTYPE,1) = 1
                and A.VACATIONTYPE not in (30,80,200) /*short abs, int.appoint*/
                and A.DBEG < @dend
                and dateadd(day,1,isnull(A.DEND,A.DBEG)) > @dbeg
                )
                return 0
  
  /* половины дней */
  declare @halfs decimal(16,3)  
  
  select @halfs = sum(duration) 
  from(
  select datediff(mi,dbeg,dend) as duration
  from (
  select case when M.dbeg > @dbeg then M.dbeg else @dbeg end as dbeg
        ,case when M.dend > @dend then @dend else M.dend end as dend
  from ( 
select dbo.COM_VACATION_DBEG3(A.ID) as dbeg
      ,dbo.COM_VACATION_DEND3(A.ID) as dend  
  from COM_VACATION A with (nolock) 
   where A.EMPLID = @aEmplID 
     and A.S_S in (1000141,2130051) /*appr*/
     and A.VACATIONTYPE not in (30,80,200)
     and isnull(A.PERIODTYPE,1) in (2,3)
     and A.DBEG >= cast(@dbeg as date) 
     ) M
     ) M2
     where M2.dbeg < @dend 
       and M2.dend > @dbeg
     ) M3
     where duration > 0
             
             set @halfs = null
                
   if isnull(@halfs ,0) > isnull(@res,0)
     set @halfs = @res
   
  /* короткие отсутствия */
  declare @short_vacation decimal(16,3)  
  select @short_vacation = sum(A.SHORTDURATION) 
    from COM_VACATION A with (nolock) 
   where A.EMPLID = @aEmplID 
     and A.S_S in (1000141,2130051)/*appr*/
     and A.VACATIONTYPE in (30,80,200)
     and (cast(A.DBEG as datetime) + cast(cast(A.SHORTSTART as time) as datetime) ) < @dend
     and dateadd(mi,A.SHORTDURATION,cast(A.DBEG as datetime) + cast(cast(A.SHORTSTART as time) as datetime)) > @dbeg

   
  return isnull(@res,0) - isnull(@short_vacation,0) - isnull(@halfs,0)
  
end