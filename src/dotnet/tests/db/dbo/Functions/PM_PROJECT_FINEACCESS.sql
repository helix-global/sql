CREATE function [dbo].[PM_PROJECT_FINEACCESS](@aProjID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''

if dbo.DEF_USERINGROUP5(@aUserID,'PM','DH&VICE',null,null,null) <> 1 
  return 'FullReadOnly;NoAllActions';

declare @ownerDepID int

select @ownerDepID = A.DEPID
from PM_PROJECT A with (nolock)
where A.ID = @aProjID 

if dbo.COM_DEP_ACCESS(null,@ownerDepID,@aMode,@aUserID,@aDate) <> 1
  return 'FullReadOnly;NoAllActions';
	                
if LEN(@res) = 0
   return null
     
return @res  

end;