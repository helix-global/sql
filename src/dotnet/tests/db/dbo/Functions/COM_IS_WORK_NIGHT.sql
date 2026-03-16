create function [dbo].[COM_IS_WORK_NIGHT](@aValue datetime,@aPeriodBeg time,@aPeriodEnd time)
returns int as 
begin
/* 
  функция возвращает 1 когда время попадает в период типа 20:00 - 00:25 
  т.е. учитывает "перенос" периода на сл.сутки
  периоды типа 00:15-03:00 перенесенными не считаются
*/   

  if @aPeriodBeg > @aPeriodEnd 
  begin 

    if cast(@aValue as time) > @aPeriodBeg  /*20:00 - 00:00*/
      return 1
    else if cast(@aValue as time) < @aPeriodEnd /* 00:00 - 00:25 */
      return 1

  end
  
  return 0
  
end