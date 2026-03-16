create function [dbo].[COM_DEP_FINEACCESS2](@aDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

/* в отличии от COM_DEP_FINEACCESS нет NoAllActions */

declare @res nvarchar(max)
set @res = ''

if dbo.COM_DEP_ACCESS(null,@aDepID,@aMode,@aUserID,@aDate) <> 1
  return 'FullReadOnly';
	                
if LEN(@res) = 0
   return null
     
return @res  

end;