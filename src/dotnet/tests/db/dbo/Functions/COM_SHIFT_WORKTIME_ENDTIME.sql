CREATE function [dbo].[COM_SHIFT_WORKTIME_ENDTIME](@aDT datetime, @aNow datetime ,@aEmplID int)
returns datetime as 
begin
   
   /* функция смещает окончание рабочего дня на окончание последнего прошедшего интервала переработки, веденного сотрудником вручную*/
   
    declare @LastOvertime datetime
    select @LastOvertime = max(A.DEND)
    from COM_ADDED_WORKTIME A with (nolock)
    where A.EMPLID = @aEmplID
      and A.DEND > @aDT
      and A.DEND < @aNow
      and A.AUTOADDEDTIME is null
      
    if @LastOvertime is not null
      return @LastOvertime  
    
    return @aDT

end