CREATE function [dbo].[COM_SHORT_ABSENCES_INDAY](@dd datetime,@aEmplID int)
returns int as 
begin
   
   /*
   возвращает минуты коротких отсутствий в день
   TODO: ?? могут ли быть пересекающиеся по времени короткие отсутствия? 
   */
   
   declare @ddd date = cast(@dd as date)

   declare @res int

   select @res = sum(A.SHORTDURATION)
    from COM_VACATION A with (nolock)
   where A.EMPLID = @aEmplID
     and A.S_S in (1000141,2130051) /*approved*/
     and A.VACATIONTYPE = 30
     and cast(A.DBEG as date) = @ddd 
  
   
   return isnull(@res  ,0)

end