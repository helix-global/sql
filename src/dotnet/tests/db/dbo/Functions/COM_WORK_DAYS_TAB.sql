CREATE function [dbo].[COM_WORK_DAYS_TAB] (@dBeg datetime, @dEnd datetime, @EmplID int)
returns @res table (YY int, MM int ,DD int, DDATE date, DDATE_PLUS1 date)
as 
begin
   /* 
   функция возвращает рабочие даты для сотрудника (без указания точных времен начала и окончания рабочего дня)
   убираются дни, где полностью отпуск
   добавляются дни в которых введена переработка
   */


   declare @wtID int
   declare @Calendar int

   select @wtID = ISNULL(A.PERSONALWT,B.ID)
        , @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @EmplID;

   insert into @res (YY,MM,DD,DDATE,DDATE_PLUS1)
   select YY,MM,DD,DDATE,DDATE_PLUS1
   from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A

   delete from @res where dbo.COM_IS_VACATIONDAY("@res".DDATE,@EmplID) = 1
    
   delete from @res 
    where dbo.COM_IS_WORKDAY2("@res".DDATE,@Calendar,@wtID) = 0 
      and not exists (select B.ID from COM_ADDED_WORKTIME B with (nolock) 
                       where B.EMPLID = @EmplID 
                         and cast(B.DBEG as date) = "@res".DDATE /* ? искать по периоду ? , но переработок больше дня не должно быть ?*/
                     )
                      
   return
    
end