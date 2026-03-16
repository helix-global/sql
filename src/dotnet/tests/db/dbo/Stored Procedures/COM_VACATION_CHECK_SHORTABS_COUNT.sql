CREATE PROCEDURE [dbo].[COM_VACATION_CHECK_SHORTABS_COUNT] (@VacationID int, @mode int)
AS
BEGIN
set nocount on

declare @emplID int 
declare @vtype int
declare @dd datetime

select @emplID = A.EMPLID
      ,@vtype = A.VACATIONTYPE
      ,@dd = A.DBEG
from COM_VACATION A with (nolock)
where A.ID = @VacationID

if @vtype <> 30 /*short absence*/
begin
   set nocount off
   return
end

declare @cou int
select @cou = count(A.ID) 
from COM_VACATION A 
where A.EMPLID = @emplID
  and A.VACATIONTYPE = 30
  and A.S_S in (1000141,2130051,1000140)
  and year(A.DBEG) = year(@dd)
  and month(A.DBEG) = month(@dd)
  and A.ID <> @VacationID

if isnull(@cou,0) >= 4
begin
    if @mode = 1
       print '#WEmployee applied more than 4 short absence proposals this month'
    else   
	   print '#WYou applied more than 4 short absence proposals this month'
end	
  
set nocount off
END