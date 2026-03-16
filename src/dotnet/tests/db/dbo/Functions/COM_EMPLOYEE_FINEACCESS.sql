CREATE function [dbo].[COM_EMPLOYEE_FINEACCESS](@aDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''


if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
begin

  if dbo.DEF_USERINGROUP7(@aUserID,'HR') = 1
     return 'FullReadOnly;NoAllActions;BypassActionsMarked=Keep4HR;';

  return 'FullReadOnly;NoAllActions;';
end
	                
if LEN(@res) = 0
   return null
     
return @res  

end;