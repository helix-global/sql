CREATE function [dbo].[COM_SHORT_ABSENCES_INDAY2](@dd datetime,@aEmplID int)
returns int as 
begin
   
   /*
   возвращает минуты коротких отсутствий в день
   ver.2 без учета времени, попавшего на перерыв
   */
   
   declare @wtID int
   declare @Calendar int
   
   select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@aEmplID,@dd)   
   select @Calendar = A.CALENDAR from COM_WORKTIME A with (nolock) where A.ID = @wtID
   
   
   declare @ddd date = cast(@dd as date)

   declare @res int

   /*здесь нужна именно COM_WORK_MINUTS5 т.к. COM_WORK_MINUTS6 вычитает отсутствия*/
   select @res = sum(dbo.COM_WORK_MINUTS5(dbo.COM_VACATION_DBEG4(A.ID),dbo.COM_VACATION_DEND4(A.ID),@wtID,@Calendar,@aEmplID))
    from COM_VACATION A with (nolock)
   where A.EMPLID = @aEmplID
     and A.S_S in (1000141,2130051) /*approved*/
     and A.VACATIONTYPE = 30
     and cast(A.DBEG as date) = @ddd 
  
   
   return isnull(@res  ,0)

end