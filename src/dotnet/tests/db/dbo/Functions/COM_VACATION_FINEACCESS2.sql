CREATE function [dbo].[COM_VACATION_FINEACCESS2](@aCreator int, @aSubject int, @aUserID int, @aVacationType int)
returns nvarchar(200) with schemabinding as 
begin

declare @res nvarchar(200) = null

/*
Навижен возвращает "Correction of this Absence Reason not allowed!" при попытках отменить больничный.
Можно убрать возможность оформлять отмены в PDB убрав этот комментарий, но тогда пользователи звонят по поводу отсутствия этого пункта 
if @aVacationType = 20
  set @res = 'NoActionsMarked=KRANK;'   
*/  

if @aUserID <> @aCreator and @aUserID <> @aSubject
  set @res = isnull(@res,'')+ 'NoActionsMarked=CAN_ONLY_AUTHOR;'
     
return @res

end;