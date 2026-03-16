CREATE function [dbo].[DA_CONCESSION_FINEACCESS_CREATE_NEW](@UserID int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''

   if((select COUNT(*) from DA_CONCESSION_APPROVE_EMPL where AUTHTYPE = 10  and dbo.COM_USER_BY_EMPL(EMPLID) = @UserID) >= 1)
		set @res = null
	else 
		set @res = 'FullReadOnly'
     
	return @res  

end;