create function [dbo].[COM_ADDRESS_GROUP_FINEACCESS](@aCR int, @aUserID int)
returns nvarchar(max) with schemabinding
as
begin

if (@aCR = @aUserID)
   return null


return 'FullReadOnly;NoAllActions';
	                

end;