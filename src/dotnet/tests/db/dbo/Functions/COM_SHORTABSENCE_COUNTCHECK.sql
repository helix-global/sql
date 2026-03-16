CREATE function [dbo].[COM_SHORTABSENCE_COUNTCHECK](@aID int,@aMode int,@aEmplID int,@vacationType int,@aDD datetime)
returns nvarchar(255) as 
begin

   /*
    KB2511 возвращает 1 если это vacation proposal более чем четвертое в этом месяце
   */

   if @vacationType <> 30
     return null
     
   declare @res int
   
   select @res = count(A.ID)
   from COM_VACATION A with (nolock)
   where A.EMPLID = @aEmplID
     and A.VACATIONTYPE = 30
     and A.S_S in (1000141,2130051,1000140)
     and year(A.DBEG) = year(@aDD)
     and month(A.DBEG) = month(@aDD)
     and A.ID < @aID
     
  if @res >= 4
    return 'More than 4 short absence proposals in month'   

  return null
  
end