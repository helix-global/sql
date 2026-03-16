create function [dbo].COM_VACATION_FINEACCESS(@aCreator int, @aSubject int, @aUserID int)
returns nvarchar(100) with schemabinding as 
begin

if @aUserID <> @aCreator and @aUserID <> @aSubject
  return 'NoActionsMarked=CAN_ONLY_AUTHOR;'
     
return null 

end;