CREATE function [dbo].[COM_TURN_MIDDLE](@aEmplID int, @aDT datetime)
returns datetime as 
begin
  
   declare @res datetime
   declare @baseDate date = cast(@aDT as date)  
   declare @baseDT datetime = @baseDate
   declare @wtID int
   
   /*
   select @wtID = ISNULL(A.PERSONALWT,B.ID)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @aEmplID
   */
   select @wtID = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@aEmplID,@aDT)   
   
   if @wtID is null
     return dateadd(hour,12,@baseDT) /* если график не указан */
     
   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A with (nolock) where A.EMPLID = @aEmplID and A.DD = @baseDate
   
   set @wturn = ISNULL(@wturn,1)
   
   /*
   08.11.17 зафиксирован случай: сотрудник брал отпуск на полдня, в этом дне работал во 2-ю смену, согласно записи в COM_TURNS
   затем из графика убрали 2-ю смену или сменили сотруднику график и теперь эта функция возвращает null что приводит к искажению 
   результатов [COM_WORK_MINUTS4] по данным в прошлом.
   Вопрос: что возвращать в таком случае??? по первой смене нового графика или полдень? 
   Пока выбрал полдень ...
   */
   
   declare @DeclaredMiddle datetime
   select @DeclaredMiddle = A.WTURN_MIDDLE from COM_WORKTIME_SH A with (nolock) where A.VNESHID = @wtID and A.WTURN = @wturn
   if @DeclaredMiddle is not null
   begin
   
     declare @ttt time = cast(@DeclaredMiddle as time)
     set @res = @baseDate 
     set @res = @res + cast(@ttt as datetime)
     return @res
   
   end

   declare @TurnBeg time 
   
   select @TurnBeg = min(cast(A.TFROM as time))
     from COM_WORKTIME_BR A with (nolock) 
    where A.VNESHID = @wtID 
      and A.WTURN = @wturn 

   declare @TurnLen int /* = 8*60 */
   select @TurnLen = sum(dbo.COM_WORKPERIOD_LEN(A.WTURN,A.TFROM,A.TTO)) 
     from COM_WORKTIME_BR A with (nolock) 
    where A.VNESHID = @wtID 
      and A.WTURN = @wturn 

   set @res = @baseDate
   set @res = @res + cast(@TurnBeg as datetime)
   set @res = dateadd(mi,@TurnLen / 2,@res)
   
   if @res is null
     return dateadd(hour,12,@baseDT) /* см. большой комментарий выше */
   
   return @res
  
end