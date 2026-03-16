CREATE function [dbo].[PR_MODEL_COMPAT_FINEACCESS](@aDocID int, @aDocDepID int, @aUserID int, @aMode int, @aDate datetime)
returns nvarchar(max)
as
begin

declare @res nvarchar(max)
set @res = ''
/*
if dbo.COM_DEP_ACCESS2(@aDocDepID,1,@aUserID,@aDate) <> 1
  set @res = 'FullReadOnly' 
*/
if dbo.COM_DEP_ACCESS(null,@aDocDepID,@aMode,@aUserID,@aDate) <> 1
  return 'FullReadOnly';
	                
if LEN(@res) = 0
   return null
     
return @res  

end;