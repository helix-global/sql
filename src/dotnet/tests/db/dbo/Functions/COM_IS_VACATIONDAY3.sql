CREATE function [dbo].[COM_IS_VACATIONDAY3](@dd datetime,@aEmplID int)
returns int as 
begin
   
   /*
   возвращает тип отпуска (VACATIONTYPE) если @dd - полный день отпуск этого типа
   до этого проверяется что @dd - не выходной
   */
   
   declare @ddd date = cast(@dd as date)
   declare @res int
   
   declare @wtID int
   declare @Calendar int
   
   select @wtID = ISNULL(A.PERSONALWT,B.ID), @Calendar = ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @aEmplID   
   
   if dbo.COM_IS_WORKDAY2(@ddd,@Calendar,@wtID) = 0
     return null

   select @res = A.VACATIONTYPE
    from COM_VACATION A with (nolock)
   where A.EMPLID = @aEmplID
     and A.S_S in (1000141,2130051) /*approved*/
     and A.VACATIONTYPE not in (30,80,200)
     and A.DBEG <= @ddd 
     and isnull(A.DEND,A.DBEG) >= @ddd
     and isnull(A.PERIODTYPE,1) = 1


   if @res is not null
     return @res
     
   return null

end