create function [dbo].[PR_DEVICE_ADDEDREPORTS_10]( @DevCmpl datetime, @RevID int )
returns nvarchar(max) 
as
begin

   /*
     версия работает по таблице, которую нужно обновлять при изменениях процедурой 
     exec PR_UPDATE_REPORTS 0,0,0
   */

   declare @res nvarchar(max)
   set @res = ''
   
   if @DevCmpl is null
     select @res = A.NOCMPL from PR_REPORTS_2DEVICE A with (nolock) where A.REVID = @RevID
   else
     select @res = A.CMPL from PR_REPORTS_2DEVICE A with (nolock) where A.REVID = @RevID
     
   return @res  

end;