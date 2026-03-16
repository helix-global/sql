create function [dbo].[COM_VACATION_CANCEL_FINEACCESS](@aID int, @aUserID int)
returns nvarchar(100)  as 
begin

  declare @VacationUserID int /*на кого оформлен отпуск*/
  select @VacationUserID = C.ID
  from COM_VACATION_CANCEL A with (nolock)
  left join COM_VACATION B with (nolock) on B.ID = A.VACATIONID
  left join DEF_USERS C with (nolock) on C.EMPLOYEEID = B.EMPLID
  where A.ID = @aID
  
  if @aUserID <> @VacationUserID
    return 'NoActionsMarked=CAN_ONLY_EMPL;'
     
  return null 

end;